USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation date : 1388/02/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : ��� �����
-- ==============================================
Create PROCEDURE [prs].[RptPrs_InstalmentDeduct] 
	@MonthCode		TinyInt,
	@PersonnelIDFr	VarChar(20) = Null,
	@PersonnelIDTo	VarChar(20) = Null,
	@LoanTypeIDFr	VarChar(20) = Null,
	@LoanTypeIDTo	VarChar(20) = Null,
	@ReceiptDateFr	VarChar(10) = Null,
	@ReceiptDateTo	VarChar(10) = Null,
	@AmountFr		Float = Null,
	@AmountTo		Float = Null,
	@ExtraParams	NVarChar(200) = Null
WITH ENCRYPTION
AS 
DECLARE @LangID		VarChar(3);
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	SET @LangID = Str(LTrim(pub.funGetCurrentLanguageID()));
	IF @LangID = '' SET @LangID = '1'
	----------------------------------------------------

	SET @StrWhere = '(1 = 1)'

	IF (@MonthCode Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND D.MonthCode = ' + Str(@MonthCode) 

	IF (@PersonnelIDFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND D.PersonnelID >= ''' + @PersonnelIDFr + ''''

	IF (@PersonnelIDTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND D.PersonnelID <= ''' + @PersonnelIDTo + ''''

	IF (@LoanTypeIDFr Is Not Null) AND @LoanTypeIDFr <> ''
		SET	@StrWhere = @StrWhere + ' AND D.LoanTypeID >= ''' + @LoanTypeIDFr + ''''
	
	IF (@LoanTypeIDTo Is Not Null) AND @LoanTypeIDTo <> ''
		SET	@StrWhere = @StrWhere + ' AND D.LoanTypeID <= ''' + @LoanTypeIDTo + ''''

	IF (@ReceiptDateFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND D.ReceiptDate >= ''' + @ReceiptDateFr + ''''

	IF (@ReceiptDateTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND D.ReceiptDate <= ''' + @ReceiptDateTo + ''''

	IF (@AmountFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND D.ThisMonthInstallment >= ' + Str(@AmountFr)

	IF (@AmountTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND D.ThisMonthInstallment <= ' + Str(@AmountTo)

	SET @StrSelect = '
	SELECT	D.*, P.FirstName + '' '' + P.LastName As PersonnelName, LT.LoanTypeName, L.LoanAmount, L.InstallmentAmount, L.OriginLoanAmount
	,Case WHEN DebitFromLoan =0 THEN LoanAmount - ISNULL(SumMonthInstallment,0) ELSE DebitFromLoan - ISNULL(SumMonthInstallment,0) END as DebitFromLoan1
	FROM 	prs.tblInstallmentDeductionsDtl D
				INNER JOIN prs.tblPersonnelsDtl P ON D.PersonnelID = P.PersonnelID AND P.LanguageID = ' + @LangID + '
				INNER JOIN prs.tblLoanTypesDtl LT ON LT.LoanTypeID = D.LoanTypeID AND LT.LanguageID = ' + @LangID + '
				INNER JOIN prs.tblLoanInstallmentsDtl L ON L.FiscalYear = D.FiscalYear AND L.PersonnelID = D.PersonnelID AND L.SerialNo = D.SerialNo AND L.ReceiptDate = D.ReceiptDate 
				LEFT OUTER JOIN  (SELECT PersonnelID,FiscalYear,SerialNo,ReceiptDate,SUM(ThisMonthInstallment) SumMonthInstallment FROM prs.tblInstallmentDeductionsDtl WHERE MonthCode<10 GROUP BY PersonnelID,FiscalYear,SerialNo,ReceiptDate) S 
					ON D.PersonnelID=S.PersonnelID AND D.FiscalYear=S.FiscalYear AND D.SerialNo=S.SerialNo AND D.ReceiptDate=S.ReceiptDate
	WHERE	' + @StrWhere + '
	ORDER BY D.PersonnelID, D.DocRowNo ' 
	
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
