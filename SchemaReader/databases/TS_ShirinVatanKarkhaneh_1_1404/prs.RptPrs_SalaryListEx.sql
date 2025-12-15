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
CREATE PROCEDURE [prs].[RptPrs_SalaryListEx]
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
Begin 
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

	BEGIN TRY
		DROP TABLE #tbl_RptPrs_SalaryList_B
		DROP TABLE #tbl_RptPrs_SalaryList_M
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tbl_RptPrs_SalaryList_B
	(
		PersonnelID		NVarChar(100) COLLATE ARABIC_CS_AS,
		BasePay			Float,
		DaysInMonth		Int,
		EmployeeInsur	float
	);

	CREATE TABLE #tbl_RptPrs_SalaryList_M
	(
		PersonnelID		NVarChar(100) COLLATE ARABIC_CS_AS,
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
		SET @StrWhere = @StrWhere + ' AND D.DepartmentID = ''' + @DepartmentID + ''''
	If (@JobID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.JobID = ''' + @JobID + ''''
		
	--SET @StrWhere = @StrWhere + ' AND PAD.IsDefault = 1 '
		
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
	
	update #tbl_RptPrs_SalaryList_M
	set BenefitName = CHAR(9)+ BenefitName
	where BenefitName = N'حقوق'

	update #tbl_RptPrs_SalaryList_M
	set BenefitName = NCHAR(9) +  BenefitName + NCHAR(9)
	where BenefitType >0

	select *
	into #tblX
	from #tbl_RptPrs_SalaryList_M
	order by BenefitName , BenefitAmount desc
	
	SET @StrSelect = '
		SELECT (T.PersonnelID + '' - '' + P.FirstName + '' '' + P.LastName) As PersonnelID, 
			    T.BenefitName, T.BenefitAmount, T.BenefitType
		FROM
		(
			SELECT	M.*
			FROM 	prs.tblSalaryCalculation S 
						INNER JOIN prs.tblDecreeHdr D ON S.DecreeSerialNo = D.SerialNo AND S.PersonnelID = D.PersonnelID 
						INNER JOIN #tblX M ON M.PersonnelID = S.PersonnelID 
			WHERE ' + @StrWhere + '
		) T 
		INNER JOIN #tbl_RptPrs_SalaryList_B B ON B.PersonnelID = T.PersonnelID
		INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = T.PersonnelID '

	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
