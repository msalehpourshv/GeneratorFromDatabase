USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation date : 1387/06/30
-- Viewed By	 : 
-- Last Modified : 1388/02/17
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : وام پرسنل
-- ==============================================
CREATE PROCEDURE [prs].[RptPrs_LoanInstalments] 
	@PersonnelIDFr			VarChar(20) = Null,
	@PersonnelIDTo			VarChar(20) = Null,
	@LoanTypeIDFr			VarChar(20) = Null,
	@LoanTypeIDTo			VarChar(20) = Null,
	@ReceiptDateFr			VarChar(10) = Null,
	@ReceiptDateTo			VarChar(10) = Null,
	@LoanAmountFr			Float = Null,
	@LoanAmountTo			Float = Null,
	@InstallmentAmountFr	Float = Null,
	@InstallmentAmountTo	Float = Null,
	@OriginLoanAmountFr		Float = Null,
	@OriginLoanAmountTo		Float = Null,
	@ExtraParams			NVarChar(200) = Null
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

	IF (@PersonnelIDFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.PersonnelID >= ''' + @PersonnelIDFr + ''''

	IF (@PersonnelIDTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.PersonnelID <= ''' + @PersonnelIDTo + ''''

	IF (@LoanTypeIDFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.LoanTypeID >= ''' + @LoanTypeIDFr + ''''
	
	IF (@LoanTypeIDTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.LoanTypeID <= ''' + @LoanTypeIDTo + ''''

	IF (@ReceiptDateFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.ReceiptDate >= ''' + @ReceiptDateFr + ''''

	IF (@ReceiptDateTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.ReceiptDate <= ''' + @ReceiptDateTo + ''''

	IF (@LoanAmountFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.LoanAmount >= ' + Str(@LoanAmountFr) 

	IF (@LoanAmountTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.LoanAmount <= ' + Str(@LoanAmountTo)

	IF (@InstallmentAmountFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.InstallmentAmount >= ' + Str(@InstallmentAmountFr)

	IF (@InstallmentAmountTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.InstallmentAmount <= ' + Str(@InstallmentAmountTo)

	IF (@OriginLoanAmountFr Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.OriginLoanAmount >= ' + Str(@OriginLoanAmountFr)

	IF (@OriginLoanAmountTo Is Not Null)
		SET	@StrWhere = @StrWhere + ' AND LD.OriginLoanAmount <= ' + Str(@OriginLoanAmountTo)

	SET @StrSelect = '
	SELECT	LD.*, P.FirstName + '' '' + P.LastName As PersonnelName, LT.LoanTypeName
	FROM 	prs.tblLoanInstallmentsDtl LD
				INNER JOIN prs.tblPersonnelsDtl P ON LD.PersonnelID = P.PersonnelID AND P.LanguageID = ' + @LangID + '
				INNER JOIN prs.tblLoanTypesDtl LT ON LT.LoanTypeID = LD.LoanTypeID AND LT.LanguageID = ' + @LangID + '
	WHERE	' + @StrWhere + '
	ORDER BY LD.PersonnelID, DocRowNo '
	
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
