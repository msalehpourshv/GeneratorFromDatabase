USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/06/31
-- Viewed By	 : 
-- Last Modified : 1390/06/15
-- Last Modifier : TakroSystem\Zia
-- Description	 : آمار مرخصی
-- =============================================
CREATE PROCEDURE [emp].[RptEmp_VacationStatistics]
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
	@VacationTypeID	VarChar(20) = Null, 
	@ProcessList	VarChar(20) = '350,351,352,353,354',
	@RepOptions		VarChar(20) = '1111',
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
DECLARE	@VacORMiss	int;
BEGIN

	SET NOCOUNT ON;

	-- Init Variables --------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)	SET @RepOptions = '1111';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @Confirm0	= Substring(@RepOptions, 1, 1);
	SET @Confirm1	= Substring(@RepOptions, 2, 1);
	SET @Confirm2	= Substring(@RepOptions, 3, 1);
	SET @VacORMiss	= Substring(@RepOptions, 4, 1);

	-- Where Clause -----------------------------------------------------------
	SET @StrWhereP = '(PD.PersonnelID <> '''')'
	SET @StrWhere  = '(D.PersonnelID = PD.PersonnelID) and D.ProcessID in (' + @ProcessList + ')'
	
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
	IF @VacORMiss=1
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

	SET @StrSelect = '
	SELECT T.*, 
		[prs].[funGetDaysLeave](VacationMinsLeft) + T.VacationDaysLeft VacationDaysLeftSum
	FROM
	(
		SELECT	PD.*, 
				PD.FirstName + '' '' + PD.LastName As PersonnelName,
				[prs].[funGetDaysLeave](
					IsNull((
							SELECT	sum(D.LastYearRemain)
							FROM	emp.tblVacationMaxDtl D
							WHERE	(D.PersonnelID=PD.PersonnelID)
						), 0)
				) LastYearVacation,
				IsNull((
						SELECT	sum(Month1+Month2+Month3+Month4+Month5+Month6+Month7+Month8+Month9+Month10+Month11+Month12) AS ThisYear
						FROM	emp.tblVacationMaxDtl D
						WHERE	(D.PersonnelID=PD.PersonnelID)
					), 0) ThisYearVacation,
				IsNull((
					SELECT	SUM(Interval-ISNULL(RetInterval,0)) As VacationDaysLeft
					FROM	emp.VwVacationDtl D
					WHERE	' + @StrWhere + ' AND (D.ProcessID in (350,352, 360))
					), 0) VacationDaysLeft,
				IsNull((
						SELECT	prs.funGetHourMinutes(SUM(Interval-ISNULL(RetInterval,0))) As VacationHoursLeft
						FROM	emp.VwVacationDtl D
						WHERE	' + @StrWhere + ' AND (D.ProcessID in (351,353, 361))
					), 0) VacationHoursLeft,
				IsNull((
						SELECT	SUM(Interval-ISNULL(RetInterval,0)) As VacationMinsLeft
						FROM	emp.VwVacationDtl D
						WHERE	' + @StrWhere + ' AND (D.ProcessID in(351,353,361))
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
