USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1390/12/09
-- Viewed By	 : 
-- Last Modified : 1392/12/17
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [prs].[RptPrs_FunctionsStats]
	@MonthCodeFr	Int = Null,
	@MonthCodeTo	Int = Null,
	@SelectedPrs	Int = 0,
	@DecreeTypeID	VarChar(20) = Null,
	@DepartmentID	VarChar(20) = Null,
	@WorkShopID		VarChar(20) = Null,
	@JobID			VarChar(20) = Null,
	@RepOptions		VarChar(10) = '00',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

DECLARE @CodeClosed	Bit;

Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	---- Init ------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1'
	IF (@SelectedPrs	Is Null)	SET @SelectedPrs = 0
	
	SET @CodeClosed	= Substring(@RepOptions, 1, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	----------------------------------------------------
	set @StrWhere = '(1=1)'
	
	IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'FD.PersonnelID')

	IF (@DecreeTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (DH.DecreeTypeID = ''' + @DecreeTypeID + ''')'
	IF (@DepartmentID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (DH.DepartmentID LIKE ''' + @DepartmentID + '%'')'
	IF (@WorkShopID	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (DH.WorkShopID = ''' + @WorkShopID + ''')'
	IF (@JobID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (DH.JobID = ''' + @JobID + ''')'
		
	IF (@MonthCodeTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (FD.MonthCode <= ''' + LTRIM(RTrim(Str(@MonthCodeTo))) + ''')'		

	IF (@CodeClosed <> 1)
		SET @StrWhere = @StrWhere + ' AND (P2.CodeClosed <> 1) '

	SET @StrSelect = '
	SELECT	P.PersonnelID, P.FirstName + '' '' + P.LastName As PersonnelName, 
			sum(LeaveWithoutPay) SumLeaveWithoutPay,
			sum(SickLeave) SumSickLeave,
			sum(Absence) SumAbsence,
			sum(LeaveDay) SumLeaveDay,
			sum(MonthlyFunction) SumMonthlyFunction,
			sum(RedeemedVacationDays) RedeemedVacationDays, 
			sum(PeriodWork001) PeriodWork001, 
            sum(PeriodWork002) PeriodWork002, 
            sum(PeriodWork003) PeriodWork003, 
            sum(PeriodWork004) PeriodWork004, 
            sum(InsuranceFunction) InsuranceFunction,  
	        sum(FD.MissionDaily) MissionDaily,
			prs.funGetHourMinutesStandard(sum( prs.funGetMinutes(VacationOvertime) )) VacationOvertime , 
			prs.funGetHourMinutesStandard(sum( prs.funGetMinutes(HourlyOvertime) )) HourlyOvertime , 
			prs.funGetHourMinutesStandard(sum( prs.funGetMinutes(OverProduct) ))  OverProduct,
			prs.funGetHourMinutesStandard(sum( prs.funGetMinutes(Delay) )) Delay ,
			prs.funGetHourMinutesStandard(sum( prs.funGetMinutes(LeaveTime) ))  LeaveTime, 
			prs.funGetHourMinutesStandard(sum( prs.funGetMinutes(WorkDeduction) ))  WorkDeduction,
			prs.funGetHourMinutesStandard(sum( prs.funGetMinutes(WithoutContactWorkDeduction) )) WithoutContactWorkDeduction , 
			prs.funGetHourMinutesStandard(sum( prs.funGetMinutes(HourlyLeaveWithoutPay) ))  HourlyLeaveWithoutPay, 
			prs.funGetHourMinutesStandard(sum( prs.funGetMinutes(RedeemedVacationTime) ))  RedeemedVacationTime, 
			prs.funGetHourMinutesStandard(sum( prs.funGetMinutes(FD.MissionTime) )) MissionTime , 
			prs.funGetHourMinutesStandard(sum( prs.funGetMinutes(MonthlyFunctionTime) )) MonthlyFunctionTime 
	FROM	prs.tblFunctionsDtl FD
				inner join prs.tblSalaryCalculation SC on SC.MonthCode=FD.MonthCode and FD.PersonnelID=SC.PersonnelID 
				inner join prs.tblDecreeHdr DH ON DH.PersonnelID = SC.PersonnelID AND DH.SerialNo = SC.DecreeSerialNo
				inner join prs.tblPersonnelsDtl P ON P.PersonnelID = FD.PersonnelID  and P.LanguageID = '+LTRIM(RTrim(str(@LangID)))+'
				inner join prs.tblPersonnels P2 ON P2.PersonnelID = FD.PersonnelID 
	WHERE	' + @StrWhere + '
	GROUP BY P.PersonnelID, P.FirstName, P.LastName '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
