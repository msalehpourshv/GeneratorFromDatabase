USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation date : 1387/09/05
-- Viewed By	 : 
-- Last Modified : 1393/02/20
-- Last Modifier : TakroSystem\Hamid
-- Description	 : لیست حقوق و مزایای سالانه پرسنل
-- ==============================================
Create PROCEDURE [prs].[RptPrs_SalaryList]
	@MonthCode		TinyInt,
	@SelectedPrs	Int = 0,
	@DecreeTypeID	VarChar(20) = Null,
	@DepartmentID	VarChar(20) = Null,
	@WorkShopID		VarChar(20) = Null,
	@JobID			VarChar(20) = Null,
	@RemainDate		Char(10) = Null,
	@RepOptions		VarChar(10) = '00',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(MAX);
DECLARE @StrFrom	NVarChar(MAX);
DECLARE @StrWhere	NVarChar(MAX);

DECLARE @ShowRemain		Bit; -- مانده حساب قبلی بیاید؟
DECLARE @ShowNegSal		Bit; -- حقوق منفی نمایش داده شود؟

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 

DECLARE @StrFieldsSum1	NVarChar(4000);
DECLARE @StrFieldsSum2	NVarChar(4000);
DECLARE @StrFieldList1	NVarChar(4000);
DECLARE @StrFieldList2	NVarChar(4000);
DECLARE @SelectedInsur	Int ;

BEGIN
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1'
	IF (@SelectedPrs	Is Null)	SET @SelectedPrs = 0

	SET @ShowRemain	= Substring(@RepOptions, 1, 1)
	SET @ShowNegSal	= Substring(@RepOptions, 2, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @SelectedInsur	= pub.funSplitString(@RepInfo, '@', 6);

	BEGIN TRY
		DROP TABLE #tbl_RptPrs_SalaryList_B
		DROP TABLE #tbl_RptPrs_SalaryList_M
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tbl_RptPrs_SalaryList_B
	(
		PersonnelID		VarChar(20) COLLATE ARABIC_CS_AS,
		BasePay			Float,
		DaysInMonth		Int,
		EmployeeInsur	float
	);

	CREATE TABLE #tbl_RptPrs_SalaryList_M
	(
		PersonnelID		VarChar(20) COLLATE ARABIC_CS_AS,
		BenefitName		VarChar(50) COLLATE ARABIC_CS_AS,
		BenefitAmount	Float,
		BenefitTime		varchar(50),
		BenefitUnit		nvarchar(30),		
		BenefitType		Int
	);
	----------------------------------------------------
	
	SET @StrWhere = 'S.MonthCode = ' + LTrim(Str(@MonthCode))
	
	IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'S.PersonnelID')

	If (@DecreeTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DecreeTypeID = ''' + @DecreeTypeID + ''''
	If (@WorkShopID	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.WorkShopID = ''' + @WorkShopID + ''''
	If (@DepartmentID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DepartmentID LIKE ''' + @DepartmentID + '%'''
	If (@JobID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.JobID = ''' + @JobID + ''''
		
	--SET @StrWhere = @StrWhere + ' AND PAD.IsDefault = 1 '
	
	IF (@SelectedInsur <> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedInsur, 'DH.InsuranceTypeID') 
		
	--------------------------------------------------------------------

	INSERT INTO #tbl_RptPrs_SalaryList_B
	SELECT S.PersonnelID, D.Basepay, F.MonthlyFunction, S.EmployeeInsur
	FROM  prs.tblFunctionsDtl F 
		INNER JOIN prs.tblSalaryCalculation S ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
		INNER JOIN prs.tblDecreeHdr D ON S.DecreeSerialNo = D.SerialNo AND S.PersonnelID = D.PersonnelID AND F.PersonnelID = D.PersonnelID
	WHERE S.MonthCode = @MonthCode
	ORDER BY S.PersonnelID

	DECLARE @MyRepOptions VarChar(10)

	IF (@ShowRemain = 1) 
		SET @MyRepOptions = '11'
	ELSE
		SET @MyRepOptions = '01'

	SET @RepInfo	= pub.funSplitString(@RepInfo, '@', 1)	
		+'@'+ pub.funSplitString(@RepInfo, '@', 2)	
		+'@'+ pub.funSplitString(@RepInfo, '@', 3)	
		+'@'+ pub.funSplitString(@RepInfo, '@', 4)	
		+'@'+ pub.funSplitString(@RepInfo, '@', 5);
	
	INSERT INTO #tbl_RptPrs_SalaryList_M
	EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthCode, @SelectedPrs, @DecreeTypeID, @DepartmentID, @WorkShopID, @JobID, @RemainDate, null, @MyRepOptions, @RepInfo

	SET @StrSelect = '
		SELECT T.*, (T.TotalFunction * B.BasePay) TotalSalary, B.EmployeeInsur
		FROM
		(
			SELECT	S.PersonnelID, PH.HireDate, PD.FirstName + '' '' + PD.LastName As PersonnelName,  (SELECT     TOP (1) AccountNo
                            FROM          prs.tblPersonnelAccountsDtl
                            WHERE      (IsDefault = 1) AND (S.PersonnelID = PersonnelID)) AS  AccountNo,
							(SELECT     TOP (1) BankCartNo
                            FROM          prs.tblPersonnelAccountsDtl
                            WHERE      (IsDefault = 1) AND (S.PersonnelID = PersonnelID)) AS  BankCartNo,
							(SELECT     TOP (1) ShabaAccountNumber
                            FROM          prs.tblPersonnelAccountsDtl
                            WHERE      (IsDefault = 1) AND (S.PersonnelID = PersonnelID)) AS  ShabaAccountNumber,
					(
						SELECT	SUM(MonthlyFunction) 
						FROM	prs.tblFunctionsDtl F
						WHERE	F.PersonnelID = S.PersonnelID AND 
								F.MonthCode = ' + LTrim(Str(@MonthCode)) + '
					) As TotalFunction, 
					ISNULL(SUM(CASE WHEN (M.BenefitType >0) THEN M.BenefitAmount ELSE 0 END), 0) BenefitSum,
					ISNULL(SUM(CASE WHEN (M.BenefitType <0) THEN M.BenefitAmount ELSE 0 END), 0) DeductionSum
			FROM 	prs.tblSalaryCalculation S 
						INNER JOIN prs.tblPersonnels    PH ON S.PersonnelID = PH.PersonnelID 
						INNER JOIN prs.tblPersonnelsDtl PD ON S.PersonnelID = PD.PersonnelID AND PD.LanguageID = ' + @LangID + '
						INNER JOIN prs.tblDecreeHdr D ON S.DecreeSerialNo = D.SerialNo AND S.PersonnelID = D.PersonnelID 
						INNER JOIN prs.tblDecreeHdr DH ON DH.SerialNo = S.DecreeSerialNo AND DH.PersonnelID = S.PersonnelID
						INNER JOIN #tbl_RptPrs_SalaryList_M M ON M.PersonnelID = S.PersonnelID 
			WHERE ' + @StrWhere + '
			GROUP BY S.PersonnelID, PD.FirstName, PD.LastName, PH.HireDate
		) T INNER JOIN #tbl_RptPrs_SalaryList_B B ON B.PersonnelID = T.PersonnelID '

	IF (@ShowNegSal = 0) 
		SET @StrSelect = @StrSelect + ' 
		WHERE  (T.BenefitSum - T.DeductionSum) >= 0 '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
END
GO
