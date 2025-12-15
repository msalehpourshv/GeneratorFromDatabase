USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1388/12/05
-- Viewed By	 : 
-- Last Modified : 1390/06/15
-- Last Modifier : TakroSystem\Zia
-- Description	 : آمار مرخصی یک ماه
-- =============================================
CREATE PROCEDURE [emp].[RptEmp_VacationStatistics_Month] 
	@PersonnelIDFr	VarChar(20) = Null, 
	@PersonnelIDTo	VarChar(20) = Null, 
	@ApprovalFr		VarChar(20) = Null,
	@ApprovalTo		VarChar(20) = Null,
	@ConfirmerFr	VarChar(20) = Null,
	@ConfirmerTo	VarChar(20) = Null,
	@ApproveDateFr	Char(10) = Null,
	@ApproveDateTo	Char(10) = Null,
	@StartDateFr	Char(10) = Null, 
	@StartDateTo	Char(10) = Null, 
	@EndDateFr		Char(10) = Null, 
	@EndDateTo		Char(10) = Null, 
	@DocDateFr		Char(10) = Null, 
	@DocDateTo		Char(10) = Null, 
	@ConfirmDateFr	Char(10) = Null,
	@ConfirmDateTo	Char(10) = Null,
	@SerialFr		int = Null,
	@SerialTo		int = Null,
	@CurrentYear	Int = 0,
	@MonthCode		Int = 1,
	@VacationTypeID	VarChar(20) = Null, 
	@ProcessList	VarChar(20) = '350,351,352,353,354',
	@RepOptions		VarChar(20) = '111',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhereP	NVarChar(max);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;

DECLARE	@Confirm0	int;
DECLARE	@Confirm1	int;
DECLARE	@Confirm2	int;
DECLARE	@VacOrMiss	int;

DECLARE @StrMonthS	varChar(10);
DECLARE @StrMonthF	varChar(10);
DECLARE @StrMonthPrevF	varChar(10);
BEGIN

	SET NOCOUNT ON;

	-- Init Variables --------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)	SET @RepOptions = '111';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @Confirm0	= Substring(@RepOptions, 1, 1);
	SET @Confirm1	= Substring(@RepOptions, 2, 1);
	SET @Confirm2	= Substring(@RepOptions, 3, 1);
	SET @VacOrMiss	= Substring(@RepOptions, 4, 1);
	
	-- Where Clause -----------------------------------------------------------
	SET @StrWhereP = '(PD.PersonnelID <> '''')'
	SET @StrWhere  = '(D.PersonnelID = PD.PersonnelID)'
	
	IF (@PersonnelIDFr Is Not Null)
		SET @StrWhereP = @StrWhereP + ' AND (PD.PersonnelID >= ''' + @PersonnelIDFr + ''')'
	IF (@PersonnelIDTo Is Not Null)
		SET @StrWhereP = @StrWhereP + ' AND (PD.PersonnelID <= ''' + @PersonnelIDTo + ''')'

	IF (@ApprovalFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ApprovalPersID >= ''' + @ApprovalFr + ''')'
	IF (@ApprovalTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ApprovalPersID <= ''' + @ApprovalTo + ''')'

	IF (@ConfirmerFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ApprovalPersID >= ''' + @ConfirmerFr + ''')'
	IF (@ConfirmerTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ApprovalPersID <= ''' + @ConfirmerTo + ''')'

	IF (@ApproveDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ApproveDate >= ''' + @ApproveDateFr + ''')'
	IF (@ApproveDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ApproveDate <= ''' + @ApproveDateTo + ''')'

	IF (@StartDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.StartDate >= ''' + @StartDateFr + ''')'
	IF (@StartDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.StartDate <= ''' + @StartDateTo + ''')'

	IF (@EndDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.EndDate >= ''' + @EndDateFr + ''')'
	IF (@EndDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.EndDate <= ''' + @EndDateTo + ''')'

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	IF (@ConfirmDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ConfirmDate >= ''' + @ConfirmDateFr + ''')'
	IF (@ConfirmDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ConfirmDate <= ''' + @ConfirmDateTo + ''')'

	IF (@VacationTypeID Is Not Null)
	IF @VacOrMiss=1
		SET @StrWhere = @StrWhere + ' AND (D.VacationTypeID = ''' + @VacationTypeID + ''')'
		ELSE
			SET @StrWhere = @StrWhere + ' AND (D.MissionTypeID = ''' + @VacationTypeID + ''')'

	IF (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo >= ' + LTrim(Str(@SerialFr)) + ')'
	IF (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo <= ' + LTrim(Str(@SerialTo)) + ')'
	IF (@ProcessList Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessID in (' + @ProcessList + '))'
		
	IF (@Confirm0 = 0)
		SET @StrWhere = @StrWhere + ' AND (D.NotConfirm <> 0)'
	IF (@Confirm1 = 0)
		SET @StrWhere = @StrWhere + ' AND (D.NotConfirm <> 1)'
	IF (@Confirm2 = 0)
		SET @StrWhere = @StrWhere + ' AND (D.NotConfirm <> 2)'

	---------------------------------------------------------------------------
	-- یافتن اولین روز ماه جاری

	SET @StrMonthS = LTrim(Str(@MonthCode))

	if len(@StrMonthS) = 1
		SET @StrMonthS = '0' + @StrMonthS

	SET @StrMonthS = LTrim(Str(@CurrentYear)) + '/' + @StrMonthS + '/01'

	---------------------------------------------------------------------------
	-- یافتن آخرین روز ماه جاری

	SET @StrMonthF = LTrim(Str(@MonthCode))

	if len(@StrMonthF) = 1
		SET @StrMonthF = '0' + @StrMonthF

	SET @StrMonthF = LTrim(Str(@CurrentYear)) + '/' + @StrMonthF

	if (@MonthCode < 7)
		SET @StrMonthF = @StrMonthF + '/31'
	else if (@MonthCode < 12)
		SET @StrMonthF = @StrMonthF + '/30'
	else
		if (@CurrentYear = 1387 OR @CurrentYear = 1391 Or @CurrentYear = 1395 Or @CurrentYear = 1399)
			SET @StrMonthF = @StrMonthF + '/30'
		else
			SET @StrMonthF = @StrMonthF + '/29'
	
	---------------------------------------------------------------------------
	-- یافتن آخرین روز ماه قبل
	if (@MonthCode > 1)
		SET @StrMonthPrevF = LTrim(Str(@MonthCode - 1))
	else
		SET @StrMonthPrevF = '12'

	if len(@StrMonthPrevF) = 1
		SET @StrMonthPrevF = '0' + @StrMonthPrevF

	SET @StrMonthPrevF = LTrim(Str(@CurrentYear)) + '/' + @StrMonthPrevF

	if (@MonthCode - 1 < 7)
		SET @StrMonthPrevF = @StrMonthPrevF + '/31'
	else if (@MonthCode - 1 < 12)
		SET @StrMonthPrevF = @StrMonthPrevF + '/30'
	else
		if (@CurrentYear-1 = 1387 OR @CurrentYear-1 = 1391 Or @CurrentYear-1 = 1395 Or @CurrentYear-1 = 1399)
			SET @StrMonthPrevF = @StrMonthPrevF + '/30'
		else
			SET @StrMonthPrevF = @StrMonthPrevF + '/29'

	---------------------------------------------------------------------------
	DECLARE @idx Int 
	SET @idx  = 1
	DECLARE @StrMonthes NVarChar(max)
	
	set @StrMonthes = ''

	while (@idx < @MonthCode)
	begin
		SET @StrMonthes = @StrMonthes + 'Month' + ltrim(str(@idx)) + '+'
		SET @idx = @idx + 1
	end	

	if @StrMonthes <> '' 
		SET @StrMonthes = substring(@StrMonthes,1, len(@StrMonthes) - 1)
	else
		SET @StrMonthes = '0'
	--print @StrMonths
	
	SET @StrSelect = '
	SELECT T.*, [prs].[funGetDaysLeave](VacationMinsLeft) + T.VacationDaysLeft VacationDaysLeftSum
	FROM
	(
		SELECT	PD.*, 
				PD.FirstName + '' '' + PD.LastName As PersonnelName,
				-- مانده مرخصی از سال قبل
				[prs].[funGetDaysLeave](
					IsNull((
							SELECT	SUM(D.LastYearRemain)
							FROM	emp.tblVacationMaxDtl D
							WHERE	D.PersonnelID = PD.PersonnelID
						),0)
				) + 
				-- تعداد روزهائی که پرسنل میتوانست تا ماه قبل به مرخصی برود
				IsNull(
					(
						SELECT	SUM(' + @StrMonthes + ') AS ThisYear
						FROM	emp.tblVacationMaxDtl D
						WHERE	D.PersonnelID = PD.PersonnelID
					), 0) - 
				-- تعداد روزهائی که پرسنل تا ماه قبل به مرخصی رفته است
				IsNull((
					isnull((
						SELECT Sum(pub.funFarsiDateDiff(''Day'', StartDate, EndDate) + 1)
						FROM
						(
							SELECT 	StartDate, 
									CASE WHEN (EndDate > ''' + @StrMonthPrevF + ''') THEN ''' + @StrMonthPrevF + ''' ELSE EndDate END AS EndDate
							FROM	emp.VwVacationDtl D
							WHERE	' + @StrWhere + ' AND (D.ProcessID in (350,352,360)) AND (StartDate < ''' + @StrMonthS + ''')
						) T
					),0) - 
					isnull((
						SELECT Sum(pub.funFarsiDateDiff(''Day'', StartDate, EndDate) + 1)
						FROM
						(
							SELECT 	StartDate, 
									CASE WHEN (EndDate > ''' + @StrMonthPrevF + ''') THEN ''' + @StrMonthPrevF + ''' ELSE EndDate END AS EndDate
							FROM	emp.VwVacationDtl D
							WHERE	' + @StrWhere + ' AND (D.ProcessID in (355,356)) AND (D.StartDate < ''' + @StrMonthS + ''')
						) T
					),0) 
				), 0) -
				-- تعداد روزهائی که بصورت ساعتی تا ماه قبل به مرخصی رفته است
				IsNull((
						SELECT	[prs].[funGetDaysLeave](SUM(D.Interval-ISNULL(D.RetInterval,0))) As VacationHoursLeft
						FROM	emp.VwVacationDtl D
						WHERE	' + @StrWhere + ' AND (D.ProcessID in (351,353,361)) AND (D.StartDate < ''' + @StrMonthS + ''')
						), 0) LastMonthVacation,
				-- تعداد روزهائی که پرسنل میتواند این ماه به مرخصی برود
				IsNull(
					(
						SELECT	SUM(D.Month' + ltrim(Str(@MonthCode)) + ') AS ThisYear
						FROM	emp.tblVacationMaxDtl D
						WHERE	D.PersonnelID = PD.PersonnelID
					), 0) ThisMonthVacation,
				-- تعداد روزهائی که پرسنل این ماه به مرخصی رفته است
				IsNull(
					(
						SELECT Sum(pub.funFarsiDateDiff(''Day'', StartDate, EndDate) + 1) 
						FROM
						(
							SELECT 	CASE WHEN (StartDate < ''' + @StrMonthS + ''') THEN ''' + @StrMonthS + ''' ELSE StartDate END AS StartDate,
									CASE WHEN (EndDate > ''' + @StrMonthF + ''') THEN ''' + @StrMonthF + ''' ELSE EndDate END AS EndDate
							FROM	emp.VwVacationDtl D
							WHERE	' + @StrWhere + ' AND (D.ProcessID in (350,352,360)) AND ( (D.StartDate >= ''' + @StrMonthS + ''' AND D.StartDate <= ''' + @StrMonthF + ''') Or (D.EndDate >= ''' + @StrMonthS + '''  AND D.EndDate <= ''' + @StrMonthF + ''') )
						) T
				), 0) VacationDaysLeft,
				-- تعداد ساعاتی که پرسنل این ماه به مرخصی رفته است
				IsNull((
						SELECT	prs.funGetHourMinutes(SUM(D.Interval-ISNULL(D.RetInterval,0))) As VacationHoursLeft
						FROM	emp.VwVacationDtl D
						WHERE	' + @StrWhere + ' AND (D.ProcessID in (351,353,361)) AND (D.StartDate >= ''' + @StrMonthS + ''') AND (D.StartDate <= ''' + @StrMonthF + ''')
					), 0) VacationHoursLeft,
				-- تعداد دقایقی که پرسنل این ماه به مرخصی رفته است
				IsNull(
					(
						SELECT	SUM(Interval-ISNULL(RetInterval,0)) As VacationMinsLeft
						FROM	emp.VwVacationDtl D
						WHERE	' + @StrWhere + ' AND (D.ProcessID in (351,353,361)) AND (D.StartDate >= ''' + @StrMonthS + ''') AND (D.StartDate <= ''' + @StrMonthF + ''')
					), 0) VacationMinsLeft
		FROM	prs.tblPersonnelsDtl PD
		WHERE ' + @StrWhereP + '
	) T '

	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
