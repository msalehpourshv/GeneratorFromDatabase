USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
	-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1389/03/10
-- Viewed By	 : 
-- Last Modified : 1389/12/12
-- Last Modifier : TakroSystem\Zia
-- Description   : Dynamic Reports All Columns
-- ==============================================
Create PROCEDURE [rpt].[SpDynaAllColumns]
	@ReportType	Int = 1
WITH ENCRYPTION
AS 
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	CREATE TABLE #tblMain
	(
		ColumnID	int,
		ColumnName	nVarChar(1024),
		ColumnText	nVarChar(50),
		ColumnType	int,
		TableID		int,
		TableName	VarChar(50) collate arabic_cs_as,
		TableText	VarChar(50) collate arabic_cs_as,
		TableAlias	VarChar(3) collate arabic_cs_as,
		CustomSchemas	VarChar(50) collate arabic_cs_as null,
		DataType	int
	);
	
	INSERT INTO #tblMain(ColumnID,ColumnName,ColumnText,ColumnType,TableID,TableName,TableText,TableAlias,CustomSchemas,DataType)
	SELECT 	A.ColumnID, A.ColumnName, A.ColumnText, A.ColumnTypeID, T.TableID, T.TableName, T.TableText, T.TableAlias, A.CustomSchemas, A.DataType
	FROM	rpt.tblDAllCols A 
				INNER JOIN rpt.tblDTables T ON A.TableID = T.TableID
	WHERE	(A.ReportType = @ReportType)

	IF (@ReportType = 1) -- Payroll
	Begin	 
		INSERT INTO #tblMain(ColumnID,ColumnName,ColumnText,ColumnType,TableID,TableName,TableText,TableAlias,CustomSchemas,DataType)
		SELECT	550 + Cast(D.BenefitID As Int), 'Benefit' + D.BenefitID, D.BenefitName, null, T.TableID, T.TableName, T.TableText, T.TableAlias, T.TableAlias, 3
		FROM	prs.tblBenefits1Dtl D
					inner join prs.tblBenefits1 H on H.BenefitID = D.BenefitID
					INNER JOIN rpt.tblDTables T ON T.TableID = 10 /* decree = 2 */
		WHERE	(D.BenefitID <> '') and (H.CreditShowInBill = 1) and (D.LanguageID = 1)
		UNION
		SELECT	580 + Cast(BenefitID As Int), 'Deduction' + BenefitID, BenefitName, null, T.TableID, T.TableName, T.TableText, T.TableAlias, T.TableAlias, 3
		FROM	prs.tblDeduction1Dtl
					INNER JOIN rpt.tblDTables T ON T.TableID = 10 /* decree = 2 */
		WHERE	(BenefitID <> '') and (LanguageID = 1)
		UNION
		SELECT	1100 + Cast(D.BenefitID As Int), 'Benefit' + D.BenefitID, D.BenefitName, null, T.TableID, T.TableName, T.TableText, T.TableAlias, T.TableAlias, 3
		FROM	prs.tblBenefits1Dtl D
					inner join prs.tblBenefits1 H on H.BenefitID = D.BenefitID
					INNER JOIN rpt.tblDTables T ON T.TableID = 2 /* decree = 2 */
		WHERE	(D.BenefitID <> '') and (H.CreditShowInBill = 1) and (D.LanguageID = 1)
		UNION
		SELECT	1200 + Cast(BenefitID As Int), 'Deduction' + BenefitID, BenefitName, null, T.TableID, T.TableName, T.TableText, T.TableAlias, T.TableAlias, 3
		FROM	prs.tblDeduction1Dtl
					INNER JOIN rpt.tblDTables T ON T.TableID = 2 /* decree = 2 */
		WHERE	(BenefitID <> '') and (LanguageID = 1)
		UNION
		SELECT	1300 + Cast(D.BenefitID As Int), 'BenefitU' + D.BenefitID, D.BenefitName, null, T.TableID, T.TableName, T.TableText, T.TableAlias, T.TableAlias, 3
		FROM	prs.tblBenefits2Dtl D
					inner join prs.tblBenefits2 H on H.BenefitID = D.BenefitID
					INNER JOIN rpt.tblDTables T ON T.TableID = 6 /* UC Benefits = 6 */
		WHERE	(D.BenefitID <> '') and (H.CreditShowInBill = 1) and (D.LanguageID = 1)
		UNION
		SELECT	1400 + Cast(BenefitID As Int), 'DeductionU' + BenefitID, BenefitName, null, T.TableID, T.TableName, T.TableText, T.TableAlias, T.TableAlias, 3
		FROM	prs.tblDeduction2Dtl
					INNER JOIN rpt.tblDTables T ON T.TableID = 7 /* UC Deduction = 7 */
		WHERE	(BenefitID <> '') and (LanguageID = 1)
		UNION
		SELECT	1500 + Cast(LoanTypeID As Int), 'ThisMonthInstallment_' + LoanTypeID, LoanTypeName, null, T.TableID, T.TableName, T.TableText, T.TableAlias, T.TableAlias, 3
		FROM	prs.tblLoanTypesDtl
					INNER JOIN rpt.tblDTables T ON T.TableID = 8 /* instalments = 8 */
		WHERE	(LoanTypeID <> '') and (LanguageID = 1)
		UNION
		SELECT	1600 + Cast(D.BenefitID As Int), 'Benefit' + D.BenefitID, 'م.م. ' + D.BenefitName, null, T.TableID, T.TableName, T.TableText, T.TableAlias, T.TableAlias, 3
		FROM	prs.tblBenefits1Dtl D
					inner join prs.tblBenefits1 H on H.BenefitID = D.BenefitID
					INNER JOIN rpt.tblDTables T ON T.TableID = 4 /* salary calc = 4 */
		WHERE	(D.BenefitID <> '') and (H.CreditShowInBill = 1) and (D.LanguageID = 1)
		UNION
		SELECT	1650 + Cast(BenefitID As Int), 'Deduction' + BenefitID, 'ک.م. ' + BenefitName, null, T.TableID, T.TableName, T.TableText, T.TableAlias, T.TableAlias, 3
		FROM	prs.tblDeduction1Dtl
					INNER JOIN rpt.tblDTables T ON T.TableID = 4 /* salary calc = 4 */
		WHERE	(BenefitID <> '') and (LanguageID = 1)	
		UNION
		SELECT	1700 + Cast(D.PeriodWorkID As Int), 'PeriodWork' + D.PeriodWorkID, D.PeriodWorkName, null, T.TableID, T.TableName, T.TableText, T.TableAlias, T.TableAlias, 3
		FROM	 emp.tblPeriodWorksDtl D
					inner join  emp.tblPeriodWorks H on H.PeriodWorkID = D.PeriodWorkID
					INNER JOIN rpt.tblDTables T ON T.TableID = 1 /* decree = 2 */
		WHERE	(D.PeriodWorkID <> '')  and (D.LanguageID = 1)	 
		 
	End

	update #tblMain
	set CustomSchemas = ''
	where CustomSchemas is null

	SELECT *
	FROM #tblMain
	--	UNION
	--SELECT	1000003 , 'SumDebitCredit'  , 'جمع' ,null, 0,'-','جدول سفارشي' ,'','',4
	

End
GO
