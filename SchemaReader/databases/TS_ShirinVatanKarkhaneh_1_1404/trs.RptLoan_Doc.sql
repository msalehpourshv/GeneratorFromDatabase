USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/19
-- Viewed By	 : 
-- Last Modified : 1388/10/09
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : یک شماره برگه مربوط به وام
-- ==============================================
Create PROCEDURE [trs].[RptLoan_Doc]
	@ProcessID		Int,
	@ProcessNo		Int,
	@FiscalYear		Int,
	@SerialNo		Int,
	@FiscalYearTo	Int,
	@SerialNoTo		Int,
	@LanguageID		TinyInt = 1
WITH ENCRYPTION
As
Begin   

	SET NOCOUNT ON;

	If (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear
	If (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo

	SELECT	D.*, H.DocDate, H.BankAcntCode, H.LoanAcntCode, 
			H.PayableLoanAcntCode, H.CostAcntCode, H.FineAcntCode, H.VchNo, H.LoanHdrDesc,
			pub.GetCodeName(H.LoanAcntCode, @LanguageID) AS LoanAcntName,
			pub.GetCodeName(H.BankAcntCode, @LanguageID) AS BankAcntName,
			pub.GetCodeName(H.CostAcntCode, @LanguageID) AS CostAcntName,
			pub.GetCodeName(H.FineAcntCode, @LanguageID) AS FineAcntName,
			pub.GetCodeName(H.PayableLoanAcntCode, @LanguageID) AS PayableCostAcntName,
			pub.GetUserName(H.SessionNo) AS UserName,HB.LoanAcntCode BaseLoanAcntCode
			,pub.GetCodeName(HB.LoanAcntCode, @LanguageID) AS BaseLoanAcntName,
			pub.GetCodeName(HB.BankAcntCode, @LanguageID) AS BaseBankAcntName,
			pub.GetCodeName(HB.CostAcntCode, @LanguageID) AS BaseCostAcntName,
			pub.GetCodeName(HB.FineAcntCode, @LanguageID) AS BaseFineAcntName,
			pub.GetCodeName(HB.PayableLoanAcntCode, @LanguageID) AS PayableCostAcntName
			, A1.NationalIdentity, A1.NationalIDNumber, A1.EconomicalCode, A1.Tel, A1.Mobile, A1.Address1, A1.Address2
	FROM	trs.tblLoanHdr H 
	INNER JOIN trs.tblLoanDtl D ON	H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	LEFT JOIN trs.tblLoanHdr HB ON	HB.ProcessID = D.BaseProcessID AND HB.ProcessNo = D.BaseProcessNo AND HB.FiscalYear = D.BaseFiscalYear AND HB.SerialNo = D.BaseSerialNo
	OUTER APPLY acc.funGetCodeInfo(H.LoanAcntCode) AS A1
	Where	(H.ProcessID = @ProcessID) AND (H.ProcessNo = @ProcessNo) AND 
			(H.FiscalYear >= @FiscalYear) AND (H.SerialNo >= @SerialNo) AND
			(H.FiscalYear <= @FiscalYearTo) AND (H.SerialNo <= @SerialNoTo)
End
GO
