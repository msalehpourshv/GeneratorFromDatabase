USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/27
-- Viewed By	 : 
-- Last Modified : 1392/01/11
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Payable Documents Report>
-- ----------------------------------------------
-- گزارش اسناد پرداختنی
-- ==============================================
create PROCEDURE [trs].[SpTrs_PayableDocs_Warn]
	@ProcessNo		Int = 0,
	@UsanceDateTo	Char(10) = Null, -- تا تاریخ سررسید
	@SortFields		NVarChar(100) = Null,
	@RepOptions		VarChar(10) = '10000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
Declare @StrSelect		NVarChar(max);
Declare @StrWhere		NVarChar(max);

Declare @ShowUnreceipt	bit; -- وصول نشده ها
Declare @ShowReceipt	bit; -- وصول شده ها
Declare @ShowReturned	bit; -- برگشتی ها
Declare @ShowDailyChq	bit;

Declare @StrPrefix		NVarChar(10)
Declare @StrPID			NVarChar(20)
Declare @StrTID			NVarChar(20)
Declare @BaseDate		NVarChar(10)
DECLARE @StrBaseDate	nVarchar(20)
DECLARE	@TrsCalcAvgByDocDate bit;

DECLARE @LangID			Char(1)
DECLARE @SessionNo		VarChar(10)
DECLARE @ReportID		VarChar(10)
declare @UserIsAdmin   bit  
declare @CurrentUserID as varchar(10) = ''
Begin   
	SET NoCount On;
	
	-- Init

	
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '1100'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 0
	If (@SortFields Is Null)	SET @SortFields = 'ChequeState'

	SET @ShowUnreceipt	= Substring(@RepOptions, 1, 1) -- وصول نشده ها
	SET @ShowReceipt	= Substring(@RepOptions, 2, 1) -- وصول شده ها
	SET @ShowReturned	= Substring(@RepOptions, 3, 1) -- برگشتی ها
	SET @ShowDailyChq	= Substring(@RepOptions, 4, 1) -- چک روز
		
		
		
	if (@ShowDailyChq = 1)
		set @StrTID = '7,8,28'
	else
		set @StrTID = '8,28'

	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	
	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @CurrentUserID = pub.funSplitString(@RepInfo, '@', 4);
	set @UserIsAdmin = pub.funSplitString(@RepInfo, '@', 5);

	SET @StrSelect = '';
	set @StrPID = '0'

	select @TrsCalcAvgByDocDate = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'TrsCalcAvgByDocDate'

	if (@TrsCalcAvgByDocDate = 1)
		set @StrBaseDate = 'D.DocDate'
	else
		set @StrBaseDate = '''' + @BaseDate + ''''

	----------------------------------------------------------------------------------------
			
	If (@ShowUnreceipt = 1)
		set @StrPID	= @StrPID + ',2,25'
	If (@ShowReceipt = 1) 
		set @StrPID	= @StrPID + ',27'
	If (@ShowReturned = 1)
		set @StrPID	= @StrPID + ',28'
		
	set @StrPrefix = 'D'
		
	set @StrWhere = '(D.PayTypeID in (' + @StrTID + '))	AND (D.ProcessID in (' + @StrPID + '))'
		
	If	(@UsanceDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate <= ''' + @UsanceDateTo + ''')'
		
	If	(@ProcessNo <> 0)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo=' + ltrim(STR(@ProcessNo)) + ')'

	/* ======  Check User Acess In Acc Codes  =========================================== */

BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblOurBanks
	END TRY
	BEGIN CATCH
	END CATCH
	
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 CREATE TABLE #tblOurBanks
	(
		CreditCode 			Varchar(20)collate arabic_cs_as null
	)
	
	 
	if (@UserIsAdmin = 0)
	begin
	 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @CurrentUserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @CurrentUserID ; 
			SET @StrWhere =  @StrWhere + '  and  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode  ) )'
	end 
	
	/* ======= Create Main String Query Section ======== */
	SET @StrSelect = '
	SELECT	D.*, BH.AcntCode2, BH.BankCode, BD.BankName, BD.BankAddress, 
			pub.GetCodeName(D.DebitCode, '  + @LangID + ') AS DebitName, 
			pub.GetCodeName(D.CreditCode, ' + @LangID + ') AS CreditName,
			pub.GetBankName(D.DebitCode, '  + @LangID + ') AS DebitNameB, 
			pub.GetBankName(D.CreditCode, ' + @LangID + ') AS CreditNameB,
			BT.BankTypeName, LD.LocationName, D.ProcessID AS ChequeState 
	FROM	trs.tblPayDtl D 
			LEFT  JOIN trs.tblPayHdr H ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
			LEFT  JOIN trs.tblOurBanks BH ON BH.BankCode = D.CreditCode  
			LEFT  JOIN trs.tblOurBanksDtl BD ON BH.BankCode = BD.BankCode 
			LEFT  JOIN pub.tblLocationsDtl LD ON LD.LocationID = D.LocationID AND LD.LanguageID = ' + @LangID + '
			LEFT  JOIN trs.tblBankTypesDtl BT ON D.BankTypeID = BT.BankTypeID AND BT.LanguageID = ' + @LangID + '
			INNER JOIN trs.vwLastEvent_Payment [LAST] ON [LAST].VolumeFiscalYear=D.VolumeFiscalYear and [LAST].VolumeRowNo=D.VolumeRowNo and [LAST].EventNo=D.EventNo AND ([LAST].PayTypeID in (' + @StrTID + '))
	WHERE ' + @StrWhere + '
	ORDER BY ' + @SortFields

	Print @StrSelect
	Exec sp_executesql @StrSelect;
End
GO
