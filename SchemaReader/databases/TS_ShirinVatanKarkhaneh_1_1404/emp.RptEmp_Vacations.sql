USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/06/30
-- Viewed By	 : 
-- Last Modified : 1392/06/14
-- Last Modifier : Nogrepasand
-- Description	 : مرخصی
-- =============================================
CREATE PROCEDURE [emp].[RptEmp_Vacations]
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
	@VacationTypeID	VARCHAR(20) = Null, 
	@MissionTypeID	VARCHAR(20) = Null, 
	@ProcessList	VARCHAR(20) = Null,
	@MissionPlaceID VARCHAR(20)=NULL,
	@RepOptions		VarChar(20) = '1111',
	@RepInfo		VarChar(100) = '1@1@1'
WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(2000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;

DECLARE	@Confirm0	int;
DECLARE	@Confirm1	int;
DECLARE	@Confirm2	int;
DECLARE	@SortByDate	bit;
BEGIN

	SET NOCOUNT ON;

	-- Init Variables --------
	IF (@RepInfo Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)	SET @RepOptions = '1111';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @Confirm0	= Substring(@RepOptions, 1, 1);
	SET @Confirm1	= Substring(@RepOptions, 2, 1);
	SET @Confirm2	= Substring(@RepOptions, 3, 1);
	SET @SortByDate	= Substring(@RepOptions, 4, 1);

	-- Where Clause -----------------------------------------------------------
	SET @StrWhere = '(1=1)'

	IF (@PersonnelIDFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.PersonnelID >= ''' + @PersonnelIDFr + ''')'
	IF (@PersonnelIDTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.PersonnelID <= ''' + @PersonnelIDTo + ''')'

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
		SET @StrWhere = @StrWhere + ' AND (D.VacationTypeID = ''' + @VacationTypeID + ''')'
	IF (@MissionTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.MissionTypeID = ''' + @MissionTypeID + ''')'

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
		
	IF (@VacationTypeID IS NOT NULL)
		SET @StrWhere = @StrWhere + ' AND (D.MissionPlaceID = '''+ @VacationTypeID +''')'
	---------------------------------------------------------------------------

	SET @StrSelect = '
	SELECT	D.*, P.FirstName + '' '' + P.LastName AS PersonnelName, 
			CASE WHEN D.ProcessID in (351,353,361) THEN 0 else D.Interval end As DurationDays, 
			CASE WHEN D.ProcessID in (351,353,361) THEN D.Interval else 0 end As DurationMins, 
			CASE WHEN D.ProcessID in (351,353,361) THEN 0 else D.RetInterval end As RetDurationDays, 
			CASE WHEN D.ProcessID in (351,353,361) THEN D.RetInterval else 0 end As RetDurationMins, 
			CASE WHEN D.ProcessID in (351,353,361) THEN ''ساعتی'' ELSE ''روزانه'' END AS CalculationBaseText,
			[pub].[GetUserName](HdrSessionNo) AS RequestUserName, [pub].[GetUserName](HdrSessionNo2) AS ConfirmUserName,
			MD.MissionPlaceName
	FROM	emp.VwVacationDtl D 
			INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = D.PersonnelID AND P.LanguageID = ' + @LangID + '
			left join emp.tblMissionPlacesDtl MD on MD.MissionPlaceID = D.MissionPlaceID
	WHERE ' + @StrWhere

	if (@SortByDate=1)
	set @StrSelect = @StrSelect + '
	ORDER BY StartDate'
	else 
	set @StrSelect = @StrSelect + '
	ORDER BY DocDate'

	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
