USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/08/26
-- Viewed By	 : 
-- Last Modified : 1390/05/30
-- Last Modifier : TakroSystem\Zia
-- Description	 : فیش حقوق پرسنل
-- ==============================================
Create PROCEDURE [prs].[RptPrs_SalaryBillsHdrEx]
	@MonthCodeFr	Int,
	@MonthCodeTo	Int,
	@SelectedPrs	Int = 0,
	@DecreeTypeID	VarChar(20) = Null,
	@DepartmentID	VarChar(20) = Null,
	@WorkShopID		VarChar(20) = Null,
	@JobID			VarChar(20) = Null,
	@RepOptions		VarChar(10) = '00',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(max);
DECLARE @StrShowMonth	NVarChar(max);
DECLARE @ShowRemain		Bit;
DECLARE @ExternalCall	Bit;
DECLARE @ShowMonth		Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
DECLARE @StrTemp		Char(5);
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	---- Init ------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1'
	IF (@SelectedPrs	Is Null)	SET @SelectedPrs = 0

	SET @ShowRemain		= Substring(@RepOptions, 1, 1)
	SET @ExternalCall	= Substring(@RepOptions, 2, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @ShowMonth	= pub.funSplitString(@RepInfo, '@', 6);
	
	----------------------------------------------------
	SELECT @StrTemp = RTrim(LTrim(SettingValue))
	FROM pub.tblSettings
	WHERE SettingKey = 'DailyLeaveHours'
	
	SET @StrWhere = '(S.MonthCode>=' + Str(@MonthCodeFr) + ') and (S.MonthCode<=' + Str(@MonthCodeTo) + ')'
	
	IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'S.PersonnelID')

	If (@DecreeTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DecreeTypeID = ''' + @DecreeTypeID + ''')'
	If (@DepartmentID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DepartmentID LIKE ''' + @DepartmentID + '%'')'
	If (@WorkShopID	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.WorkShopID = ''' + @WorkShopID + ''')'
	If (@JobID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.JobID = ''' + @JobID + ''')'
	
	if @ShowMonth='True'
		set @StrShowMonth =' S.MonthCode MonthCodeHdr'
	else 
		set @StrShowMonth =' 0 MonthCodeHdr '


	SET @StrSelect = '
	SELECT	D.PersonnelID,'+@StrShowMonth+', P.FirstName + '' '' + P.LastName As PersonnelName,
			Avg(D.Basepay) Basepay,
			Avg(D.LeavePay) LeavePay,
			Avg(D.HourlyOvertimeBase) HourlyOvertimeBase,
			Avg(D.VacationOvertimeBase) VacationOvertimeBase,
			Sum(D.HourlyOverProduct) HourlyOverProduct,
			Avg(D.HourlyWorkDeductionBase) HourlyWorkDeductionBase,
			prs.funGetHourMinutes( Sum(prs.funGetMinutes(F.HourlyOvertime)) ) HourlyOvertime,
			prs.funGetHourMinutes( Sum(prs.funGetMinutes(F.VacationOvertime)) ) VacationOvertime,
			prs.funGetHourMinutes( Sum(prs.funGetMinutes(F.OverProduct)) ) OverProduct,
			Sum(F.Absence) Absence,
			Sum(F.LeaveWithoutPay) LeaveWithoutPay,
			Sum(F.SickLeave) SickLeave,
			Sum(F.MonthlyFunction) MonthlyFunction,
			prs.funGetHourMinutes( Sum(prs.funGetMinutes(F.MonthlyFunctionTime)) ) MonthlyFunctionTime, 
			prs.funGetHourMinutes( Sum(prs.funGetMinutes(F.MonthlyTime)) ) MonthlyTime, 
			prs.funGetHourMinutes( Sum(prs.funGetMinutes(F.LeaveTime) + (F.LeaveDay * prs.funGetMinutes(''' + @StrTemp + '''))) ) LeaveTime, 
			prs.funGetHourMinutes( Sum(prs.funGetMinutes(F.Delay)) ) Delay,
			prs.funGetHourMinutes( Sum(prs.funGetMinutes(F.WorkDeduction)) ) WorkDeduction,
			Cast('''' As NVarChar(250)) As PaymentText,
			Sum(F.PeriodWork001) PeriodWork001,
			Sum(F.PeriodWork002) PeriodWork002,
			Sum(F.PeriodWork003) PeriodWork003,
			Sum(F.PeriodWork004) PeriodWork004,
			(
				SELECT	PeriodWorkName + '' (روز):''
				FROM	emp.tblPeriodWorksDtl
				WHERE	(PeriodWorkID = ''001'')
			) As PeriodWork001Name,
			(
				SELECT	PeriodWorkName + '' (روز):''
				FROM	emp.tblPeriodWorksDtl
				WHERE	(PeriodWorkID = ''002'')
			) As PeriodWork002Name,
			(
				SELECT	PeriodWorkName + '' (روز):''
				FROM	emp.tblPeriodWorksDtl
				WHERE	(PeriodWorkID = ''003'')
			) As PeriodWork003Name,
			(
				SELECT	PeriodWorkName + '' (روز):''
				FROM	emp.tblPeriodWorksDtl
				WHERE	(PeriodWorkID = ''004'')
			) As PeriodWork004Name,
			0 as LoanAmount,
			Sum(F.RedeemedVacationDays) RedeemedVacationDays,
			prs.funGetHourMinutes( Sum(prs.funGetMinutes(F.RedeemedVacationTime)) ) RedeemedVacationTime,
			prs.funGetHourMinutes( Sum(prs.funGetMinutes(F.WithoutContactWorkDeduction)) ) WithoutContactWorkDeduction,
			prs.funGetDayHourMinsLeave((
				SELECT prs.funGetHourMinutes( Sum(prs.funGetMinutes(LeaveTime) + (LeaveDay * prs.funGetMinutes(''' + @StrTemp + ''')) ) )
				FROM prs.tblFunctionsDtl 
				WHERE (PersonnelID = S.PersonnelID) AND (MonthCode >= ' + Str(@MonthCodeFr) + ') AND (MonthCode <= ' + Str(@MonthCodeTo) + ')
			)) AS TotalLeaveTime,
			Avg(D.AbsenceBase) AbsenceBase,
			Avg(D.HourlyDelayBase) HourlyDelayBase,
			prs.funGetHourMinutes( Sum(prs.funGetMinutes(F.HourlyLeaveWithoutPay)) ) HourlyLeaveWithoutPay,
			'''' as SalaryDescHdr,
			'''' as SalaryDescDtl,
			isnull((select top 1 AccountNo from prs.tblPersonnelAccountsDtl where PersonnelID=S.PersonnelID),'''') PersonnelAccountNo
			,D.MissionDaily, D.MissionTime
	FROM	prs.tblSalaryCalculation S 
				INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
				INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = S.PersonnelID 
				INNER JOIN prs.tblFunctionsDtl F ON F.MonthCode = S.MonthCode AND F.PersonnelID = S.PersonnelID
				LEFT  JOIN 
				(
					SELECT PersonnelID, ISNull(SUM(Case WHEN DebitFromLoan =0 THEN LoanAmount ELSE DebitFromLoan END), 0)  SumLoanAmount
					FROM prs.tblLoanInstallmentsDtl 
					GROUP BY PersonnelID
				) DD ON DD.PersonnelID = S.PersonnelID
				LEFT JOIN prs.tblSalaryDescsHdr SDH on SDH.MonthCode = S.MonthCode
				LEFT JOIN prs.tblSalaryDescsDtl SDD on SDD.MonthCode = S.MonthCode and SDD.PersonnelID = S.PersonnelID
	WHERE	' + @StrWhere + '	'

	if @ShowMonth='True'
		SET @StrSelect = @StrSelect+' GROUP BY S.MonthCode,S.PersonnelID, D.PersonnelID, P.FirstName, P.LastName,D.MissionDaily, D.MissionTime '
	else 
		SET @StrSelect = @StrSelect+' GROUP BY S.PersonnelID, D.PersonnelID, P.FirstName, P.LastName,D.MissionDaily, D.MissionTime '


	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
