USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
	-- =============================================
-- Author:		Javad Bayani
-- Create date: 1388/10/07 
-- Modfied Date: 1391/12/05 -- NOGREPASAND
-- Description:	This stored procedure return Petty Cashes Report.
-- =============================================
Create PROCEDURE [trs].[RptTrs_PettyCash_Docs]
	@ProcessID			Int = 5, 
	@ProcessNo			Int = 1, 
	@FiscalFr			Int = Null, 
	@SerialFr			Int = Null, 
	@FiscalTo			Int = Null, 
	@SerialTo			Int = Null, 
	@SelectedBanks		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@DocDateFr			Char(10) = Null, 
	@DocDateTo			Char(10) = Null, 
	@DescDtl			NVarChar(100) = Null, 
	@RepOptions			VarChar(10) = '1111', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrOrders	NVarChar(max);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE @NotAccept		bit; -- برای حالتی که سندشان صادر نشده است
DECLARE @UseDescHdr		bit;
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;
BEGIN 
	--============== S T A R T  C O D E ===================================================
	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '1111';
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';

	IF (@SelectedBanks Is Null)		SET @SelectedBanks = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;

	If (@FiscalFr	Is Null)		SET @SerialFr = Null;
	If (@FiscalTo	Is Null)		SET @SerialTo = Null;
	If (@SerialFr	Is Null)		SET @FiscalFr = Null;
	If (@SerialTo	Is Null)		SET @FiscalTo = Null;

	
	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @StrOrders		= pub.funSplitString(@RepInfo, '@', 6);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 7);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 8);

	SET @UseDescHdr	= Substring(@RepOptions, 1, 1)
	set @NotAccept=SUBSTRING(@RepOptions, 2,1)
	-- Where Clause -----------------------------------------
	Set @StrWhere = '(D.ProcessID=5) and (D.ProcessNo=' + ltrim(STR(@ProcessNo))+ ')'

	IF (@SerialFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialFr)) + '))' 

	IF (@SerialTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialTo)) + '))' 

	IF (@DocDateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.SpendDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.SpendDate <= ''' + @DocDateTo + ''')'

	If (@SelectedBanks > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedBanks, 'B.BankCode') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.CostAcntCode') 
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.CostAcntCode') 
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.CostAcntCode') 
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.CostAcntCode') 

	If (@DescDtl IS Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DescDtl LIKE N''%' + @DescDtl + '%'') '

	if(@NotAccept=1)
		SET  @StrWhere = @StrWhere + ' AND (H.VchNo=0)  '

	begin try
		drop table ##tbl_FinalResult
	end try
	begin catch
	end catch
		
	SET @StrSelect = '
	SELECT D.*, 
		   B.BankCode, 
		   H.DocDate, 
		   H.OurBankCode,
		   B.BankName, 
		   H.DescHdr,
		   H.VchNo,
		   pub.GetUserName(H.SessionNo) AS UserName,
		   pub.GetCodeName(D.CostAcntCode, 1) AS CostAcntName,	
		   acc.funGetAcntFullName(D.CostAcntCode) As CostAcntFullName
	INTO ##tbl_FinalResult
	FROM trs.tblPettyCashHdr H  
	INNER JOIN trs.tblPettyCashDtl D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	INNER JOIN trs.tblOurBanksDtl B ON H.OurBankCode = B.BankCode and B.LanguageID='+ @LangID +' 
	WHERE ' + @StrWhere +
   'ORDER BY ' + @StrOrders

	Print @StrSelect;	
	Exec sp_executesql @StrSelect 

	IF (@UserIsAdmin = 0)
	Begin
		Exec pub.SpFilterByPermission2 '##tbl_FinalResult', 'OurBankCode', 'trs.tblOurBanks', @UserID;
	End

	SET @StrSelect = 'SELECT * FROM ##tbl_FinalResult'

	Print @StrSelect;	
	Exec sp_executesql @StrSelect 
END

GO
