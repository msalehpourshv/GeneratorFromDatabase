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
CREATE PROCEDURE [trs].[SpTrs_LoansRemain_Warn]
	@ProcessNo		Int = 0,
	@InsDateTo		Char(10) = Null,
	@SortFields		VarChar(50) = Null,
	@RepOptions		VarChar(20) = '1',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @SortByInst	bit

DECLARE @PID_Rec	Int
DECLARE @PID_Pay	Int

DECLARE @StrSelect	NVarChar(max)
DECLARE	@StrWhere	NVarChar(max)

DECLARE @LangID		Char(1)
DECLARE @SessionNo	VarChar(10)
DECLARE @ReportID	VarChar(10)
Begin   

	Set NoCount On;

	-- // Setting ProcessID ----
	set @SortByInst = 0

	Set @PID_Rec = 7
	Set @PID_Pay = 8
	
	SET @SortByInst	= Substring(@RepOptions, 1, 1) 

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	Set @StrWhere = '(1=1)'
	
	if (@ProcessNo <> 0)
		Set @StrWhere = @StrWhere + ' and (H.ProcessNo=' + ltrim(str(@ProcessNo)) + ')'
	
	If (@InsDateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.InstallmentDate <= ''' + @InsDateTo + ''')'

	Set @StrSelect = N'
	SELECT	D.ProcessID, T.*, H.VchNo, H.DocDate, D.InstallmentDate, 
			D.InstallmentAmount, D.InstallmentCost, H.LoanAcntCode, H.BankAcntCode
	FROM	trs.tblLoanHdr H 
				INNER JOIN trs.tblLoanDtl D ON H.FiscalYear= D.FiscalYear AND H.ProcessNo = D.ProcessNo AND H.SerialNo = D.SerialNo AND H.ProcessID = D.ProcessID
				INNER JOIN 
				(
					SELECT	D.ProcessNo, D.FiscalYear, D.SerialNo, D.InstallmentNo 
					FROM	trs.tblLoanDtl D 
								inner join trs.tblLoanHdr H on H.FiscalYear= D.FiscalYear AND H.ProcessNo = D.ProcessNo AND H.SerialNo = D.SerialNo AND H.ProcessID = D.ProcessID
					WHERE	D.ProcessID = ' + LTRim(Str(@PID_Rec)) + '
					EXCEPT
					SELECT	D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, D.InstallmentNo 
					FROM	trs.tblLoanDtl D  
								inner join trs.tblLoanHdr H on H.FiscalYear= D.FiscalYear AND H.ProcessNo = D.ProcessNo AND H.SerialNo = D.SerialNo AND H.ProcessID = D.ProcessID
					WHERE	D.ProcessID = ' + LTRim(Str(@PID_Pay))  + '
				) T ON D.ProcessID = ' + LTrim(Str(@PID_Rec)) + ' AND D.ProcessNo = T.ProcessNo AND D.FiscalYear = T.FiscalYear AND D.SerialNo = T.SerialNo AND D.InstallmentNo = T.InstallmentNo 
	WHERE ' + @StrWhere 

	If (@SortByInst = 1)
		Set @StrSelect = @StrSelect + '	
	ORDER BY T.FiscalYear, H.LoanAcntCode, T.InstallmentNo, D.SerialNo '
	Else
		Set @StrSelect = @StrSelect + '	
	ORDER BY T.FiscalYear, D.InstallmentDate, D.SerialNo '
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
