USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/20
-- Viewed By	 : 
-- Last Modified : 1392/01/06
-- Description	 : <Loans Remain Instalments>
-- ----------------------------------------------
-- گزارش اقساط مانده وامهای دریافت شده
-- ==============================================
Create PROCEDURE [trs].[RptTrs_LoansRemainIns]
	@ProcessNo		Int = 1,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@VchDateFr		Char(10) = Null,
	@VchDateTo		Char(10) = Null,
	@InsDateFr		Char(10) = Null,
	@InsDateTo		Char(10) = Null,
	@SortFields		VarChar(50) = Null,
	@RepOptions		VarChar(20) = '1',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
As
DECLARE @SortByInst		bit
DECLARE @SortByDate		bit
DECLARE @SortByCredit	bit
DECLARE @SortByBank		bit

DECLARE @PID_Rec		Int
DECLARE @PID_Pay		Int

DECLARE @StrSelect		NVarChar(max)
DECLARE	@StrWhere		NVarChar(max)

DECLARE @LangID			Char(1)
DECLARE @SessionNo		VarChar(10)
DECLARE @ReportID		VarChar(10)
DECLARE @BankAcnt1 int;
DECLARE @BankAcnt2 int;
DECLARE @BankAcnt3 int;
DECLARE @BankAcnt4 int;
DECLARE @ProcessID		Int;

Begin   

	Set NoCount On;
	
	set @BankAcnt1=0
	set @BankAcnt2=0
	set @BankAcnt3=0
	set @BankAcnt4=0

	-- // Setting ProcessID ----
	set @SortByInst   = 0
	set @SortByDate	  = 0
	set @SortByCredit = 0
	set @SortByBank   = 0

	Set @PID_Rec = 7
	Set @PID_Pay = 8
	
	SET @SortByInst		= Substring(@RepOptions, 1, 1) 
	SET @SortByDate		= Substring(@RepOptions, 2, 1) 
	SET @SortByCredit	= Substring(@RepOptions, 3, 1) 
	SET @SortByBank		= Substring(@RepOptions, 4, 1) 

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	--  user ID 4 
	--  ISadmin 5  
	set @BankAcnt1  = pub.funSplitString(@RepInfo, '@', 6);
	set @BankAcnt2  = pub.funSplitString(@RepInfo, '@', 7);
	set @BankAcnt3  = pub.funSplitString(@RepInfo, '@', 8);
	set @BankAcnt4  = pub.funSplitString(@RepInfo, '@', 9);
	set @ProcessID  = pub.funSplitString(@RepInfo, '@', 10);


if @ProcessID=0 
	set @ProcessID=7
if @ProcessID=47
	begin
		Set @PID_Rec = 47
		Set @PID_Pay = 48
	end
	IF (@SelectedAcnt1 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)	SET @SelectedAcnt4 = 0;
		
	Set @StrWhere = '(H.ProcessID=' + ltrim(str(@ProcessID)) + ') and (H.ProcessNo=' + ltrim(str(@ProcessNo)) + ')'
	
	If (@DocDateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	If (@VchDateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.VchDate >= ''' + @VchDateFr + ''')'
	If (@VchDateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.VchDate <= ''' + @VchDateTo + ''')'

	If (@InsDateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.InstallmentDate >= ''' + @InsDateFr + ''')'
	If (@InsDateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.InstallmentDate <= ''' + @InsDateTo + ''')'

	If	(@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.LoanAcntCode') 
	If	(@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.LoanAcntCode') 
	If	(@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.LoanAcntCode') 
	If	(@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.LoanAcntCode') 
			If	(@BankAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankAcnt1, 'H.BankAcntCode') 
		If	(@BankAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankAcnt2, 'H.BankAcntCode') 
		If	(@BankAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankAcnt3, 'H.BankAcntCode') 
		If	(@BankAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BankAcnt4, 'H.BankAcntCode') 

	Set @StrSelect = '	
	SELECT	D.ProcessID,  D.ProcessNo, D.FiscalYear, D.SerialNo, D.InstallmentNo, D.InstallmentDate
	, D.InstallmentAmount	-isnull(T.InstallmentAmount,0) InstallmentAmount
	,D.InstallmentCost-isnull(T.InstallmentCost,0)-isnull(T.PrepaymenAmount,0)	InstallmentCost
	,D.InstallmentFine-isnull(T.InstallmentFine,0) InstallmentFine,
			H.VchNo, H.LoanAcntCode, H.BankAcntCode, H.PayableLoanAcntCode AS PayableCostAcntCode, H.DocDate,
			pub.GetCodeName(H.LoanAcntCode, 1) AS LoanAcntName,
			pub.GetCodeName(H.BankAcntCode, 1) AS BankAcntName,
			acc.funLayerAcntName(H.LoanAcntCode, 2, 1) BankAcntName21,
			acc.funLayerAcntName(H.LoanAcntCode, 2, 2) BankAcntName22,
			pub.GetCodeName(H.PayableLoanAcntCode, 1) AS PayableCostAcntName
	FROM	trs.tblLoanHdr H 
				INNER JOIN trs.tblLoanDtl D ON H.FiscalYear= D.FiscalYear AND H.ProcessNo = D.ProcessNo AND H.SerialNo = D.SerialNo AND H.ProcessID = D.ProcessID
				Left JOIN 
				(SELECT isnull(sum(InstallmentAmount),0) InstallmentAmount ,isnull(sum(InstallmentCost),0) InstallmentCost ,isnull(sum(InstallmentFine),0) InstallmentFine ,
					BaseProcessID,BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,InstallmentNo, D.FiscalYear , H.PrepaymenAmount
					from trs.tblLoanHdr H 
					INNER JOIN trs.tblLoanDtl D ON H.FiscalYear= D.FiscalYear AND H.ProcessNo = D.ProcessNo AND H.SerialNo = D.SerialNo AND H.ProcessID = D.ProcessID							 
					WHERE D.ProcessID = ' + LTRim(Str(@PID_Pay))  + '
				Group by BaseProcessID,BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo ,InstallmentNo  , D.FiscalYear, H.PrepaymenAmount
				) T ON  D.ProcessID = T.BaseProcessID AND D.ProcessNo = T.BaseProcessNo AND D.FiscalYear = T.BaseFiscalYear AND D.SerialNo = T.BaseSerialNo AND D.InstallmentNo = T.InstallmentNo 
	WHERE D.ProcessID = ' + LTrim(Str(@PID_Rec)) + ' AND ' + @StrWhere 
	+' and (D.InstallmentAmount-isnull(T.InstallmentAmount,0)>0 or D.InstallmentCost-isnull(T.InstallmentCost,0)>0 or D.InstallmentFine-isnull(T.InstallmentFine,0)>0)'

	If (@SortByInst = 1)
		Set @StrSelect = @StrSelect + '	ORDER BY D.FiscalYear,D.InstallmentNo, H.LoanAcntCode, D.SerialNo '
	
	Else If (@SortByDate = 1)
		Set @StrSelect = @StrSelect + '	ORDER BY D.InstallmentDate, T.FiscalYear, D.SerialNo '
	
	Else If (@SortByCredit = 1)
		Set @StrSelect = @StrSelect + '	ORDER BY T.FiscalYear, H.LoanAcntCode, D.SerialNo '

	Else If (@SortByBank = 1)
		Set @StrSelect = @StrSelect + '	ORDER BY T.FiscalYear, H.BankAcntCode, D.SerialNo '
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
