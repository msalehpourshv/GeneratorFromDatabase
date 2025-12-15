USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation date : 1387/09/07
-- Viewed By	 : 
-- Last Modified : 1389/02/21
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : گزارش سرجمع هزینه های یک ماه
-- ==============================================
Create PROCEDURE [prs].[RptPrs_MonthlyExpenses1]
	@MonthCodeFr	Int = null,
	@MonthCodeTo	Int = null,
	@SelectedPrs	Int = 0,
	@DepartmentID	VarChar(20) = Null,
	@WorkShopID		VarChar(20) = Null,
	@RepOptions		VarChar(10) = '000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE @StrEx		NVarChar(max);
DECLARE @MonthV		NVarChar(50);
DECLARE @MonthG		NVarChar(50);
declare @IsSummary	bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@SelectedPrs Is Null)		SET @SelectedPrs = 0;
	If LTrim(@WorkShopID) = ''		SET @WorkShopID = NULL;
	If LTrim(@DepartmentID) = ''	SET @DepartmentID = NULL;

	-- *** hint: RepOptions must match with MonthlyExpense2 ***
	--SET @ShowDebit	= Substring(@RepOptions, 1, 1); -- not used
	SET @IsSummary	= Substring(@RepOptions, 2, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	----------------------------------------------------
	
	BEGIN TRY
		DROP TABLE #tbl_MEX1
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tbl_MEX1
	(
		MonthCode	int,
		[Key]		NVarChar(100),
		[Value]		NVarChar(50)
	);
	----------------------------------------------------
	--if (@IsSummary = 1)
	--begin
	--	set @MonthV = '0'
	--	set @MonthG = ''
	--end
	--else
	--begin
		set @MonthV = 'S.MonthCode'
		set @MonthG = 'group by S.MonthCode'
	--end

	SET @StrWhere = '(1=1)'
	
	if (@MonthCodeFr is not null) SET @StrWhere = @StrWhere + ' and (S.MonthCode>=' + Str(@MonthCodeFr) + ')'
	if (@MonthCodeTo is not null) SET @StrWhere = @StrWhere + ' and (S.MonthCode<=' + Str(@MonthCodeTo) + ')'

	IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'S.PersonnelID')
	If (@DepartmentID Is Not Null) and @DepartmentID <>'0'
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @DepartmentID, 'DH.DepartmentID') 
	If (@WorkShopID	Is Not Null) and @WorkShopID <>'0'
		SET @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @WorkShopID, 'DH.WorkShopID')  
		
	if (@IsSummary <> 1) or (@IsSummary=1 and @MonthCodeFr=@MonthCodeTo)
	begin
		SET @StrSelect = '
		INSERT INTO #tbl_MEX1(MonthCode, [Key], [Value])
		SELECT ' + ltrim(@MonthV) + ', ''تعداد پرسنل'' As [Key], Cast(Count(S.PersonnelID) As VarChar(50)) As [Value]
		FROM prs.tblSalaryCalculation S 
			inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
		WHERE ' + @StrWhere + '
		' + @MonthG
		
		Print @StrSelect;
		Exec sp_executesql @StrSelect;
	end

	SET @StrSelect = '
	INSERT INTO #tbl_MEX1(MonthCode, [Key], [Value])
	SELECT ' + ltrim(@MonthV) + ', ''اضافه کاری'', Cast(prs.funGetHourMinutes(IsNull(Sum(prs.funGetMinutes(F.HourlyOvertime)), 0)) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + '
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', ''اضافه کاری تعطیلی'', Cast(prs.funGetHourMinutes(IsNull(Sum(prs.funGetMinutes(VacationOvertime)), 0)) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', ''اضافه کاری تولید'', Cast(prs.funGetHourMinutes(IsNull(Sum(prs.funGetMinutes(OverProduct)), 0)) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', ''غیبت (روز)'', Cast(IsNull(Sum(Cast(Absence As Int)), 0) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + '
	' + @MonthG + ''

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect = '
	INSERT INTO #tbl_MEX1(MonthCode, [Key], [Value])
	SELECT ' + ltrim(@MonthV) + ', ''مرخصی بدون حقوق (روز)'', Cast(IsNull(Sum(Cast(LeaveWithoutPay As Int)), 0) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', ''مرخصی استعلاجی (روز)'', Cast(IsNull(Sum(Cast(SickLeave As Int)), 0) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', ''روزهای کارکرد'', Cast(IsNull(Sum(MonthlyFunction), 0) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', ''جمع مرخصی های روزانه'', Cast(IsNull(Sum(LeaveDay), 0) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', ''جمع مرخصی های ساعتی'', prs.funGetDayHourMinsLeave(prs.funGetHourMinutes(IsNull(Sum(prs.funGetMinutes(LeaveTime)), 0)))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', ''تأخیر'', Cast(prs.funGetHourMinutes(IsNull(Sum(prs.funGetMinutes(Delay)), 0)) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', ''تعداد روزهای مرخصی بازخرید شده'' As [Key], CAST(SUM(RedeemedVacationDays) As VarChar(50)) As [Value]
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + '
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', ''ساعات مرخصی بازخرید شده'' As [Key],  prs.funGetHourMinutes(IsNull(Sum(prs.funGetMinutes(RedeemedVacationTime)), 0)) As [Value]
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + '
	' + @MonthG + ''

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect ='
	INSERT INTO #tbl_MEX1(MonthCode, [Key], [Value])
	SELECT ' + ltrim(@MonthV) + ', ''کسر کار بدون تماس'', Cast(prs.funGetHourMinutes(IsNull(Sum(prs.funGetMinutes(WithoutContactWorkDeduction)), 0)) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', ''کسر کار'', Cast(prs.funGetHourMinutes(IsNull(Sum(prs.funGetMinutes(WorkDeduction)), 0)) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', 
		(
			SELECT	PeriodWorkName + '' (روز)''
			FROM	emp.tblPeriodWorksDtl
			WHERE	(PeriodWorkID = ''001'') 
		), Cast(IsNull(Sum(PeriodWork001), 0) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + '
	' + @MonthG + ''

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect ='
	INSERT INTO #tbl_MEX1(MonthCode, [Key], [Value])
	SELECT ' + ltrim(@MonthV) + ', 
		(
			SELECT	PeriodWorkName + '' (روز)''
			FROM	emp.tblPeriodWorksDtl
			WHERE	(PeriodWorkID = ''002'') 
		), Cast(IsNull(Sum(PeriodWork002), 0) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', 
		(
			SELECT	PeriodWorkName + '' (روز)''
			FROM	emp.tblPeriodWorksDtl
			WHERE	(PeriodWorkID = ''003'') 
		), Cast(IsNull(Sum(PeriodWork003), 0) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + ' 
	' + @MonthG + '
	UNION
	SELECT ' + ltrim(@MonthV) + ', 
			(
				SELECT	PeriodWorkName + '' (روز)''
				FROM	emp.tblPeriodWorksDtl
				WHERE	(PeriodWorkID = ''004'') 
			), Cast(IsNull(Sum(PeriodWork004), 0) As VarChar(50))
	FROM prs.tblFunctionsDtl F
		inner join prs.tblSalaryCalculation S on S.PersonnelID=F.PersonnelID and S.MonthCode=F.MonthCode
		inner join prs.tblDecreeHdr DH on S.PersonnelID=DH.PersonnelID and S.DecreeSerialNo=DH.SerialNo
	WHERE ' + @StrWhere + '
	' + @MonthG + ''

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	SELECT *
	FROM #tbl_MEX1
	WHERE Value <> '0'
	order by MonthCode
End
GO
