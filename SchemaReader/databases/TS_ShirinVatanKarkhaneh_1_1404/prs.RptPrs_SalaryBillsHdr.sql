USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/08/26
-- Viewed By	 : 
-- Last Modified : 1393/04/10
-- Last Modifier : TakroSystem\Hamid
-- Description	 : فیش حقوق پرسنل
-- ==============================================
Create PROCEDURE [prs].[RptPrs_SalaryBillsHdr]
	@MonthCode		Int,
	@SelectedPrs	Int = 0,
	@DecreeTypeID	VarChar(20) = Null,
	@DepartmentID	VarChar(20) = Null,
	@WorkShopID		VarChar(20) = Null,
	@JobID			VarChar(20) = Null,
	@RemainDate		Char(10) = Null,
	@LoanDate		Char(10) = Null,
	@RepOptions		VarChar(10) = '00',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect1		NVarChar(MAX);
DECLARE @StrSelect2		NVarChar(MAX);
DECLARE @StrSelect3		NVarChar(MAX);
DECLARE @StrSelect4		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(MAX);
DECLARE @ShowRemain		Bit;
DECLARE @ExternalCall	Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
DECLARE @StrTemp Char(5);
declare @PersonnelID	VarChar(20) 

BEGIN 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	SELECT @StrTemp = RTrim(LTrim(SettingValue))	FROM pub.tblSettings	WHERE SettingKey = 'DailyLeaveHours'
	----------------------------------------------------
	If (@StrTemp Is NULL)
		SET @StrTemp = '07:20'
	
	DECLARE @IntMinsPerDay	Int
	
	SET @IntMinsPerDay = prs.funGetMinutes(@StrTemp) 	
	
	IF (@IntMinsPerDay <= 0)
		set @IntMinsPerDay=440
	
	---- Init ------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1'
	IF (@SelectedPrs	Is Null)	SET @SelectedPrs = 0

	SET @ShowRemain		= Substring(@RepOptions, 1, 1)
	SET @ExternalCall	= Substring(@RepOptions, 2, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @PersonnelID	= pub.funSplitString(@RepInfo, '@', 7);

	SET @StrWhere = '(S.MonthCode = ' + Str(@MonthCode) + ')'
	
	IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'S.PersonnelID')

	IF (@DecreeTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DecreeTypeID = ''' + @DecreeTypeID + ''')'
	IF (@DepartmentID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DepartmentID LIKE ''' + @DepartmentID + '%'')'
	IF (@WorkShopID	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.WorkShopID = ''' + @WorkShopID + ''')'
	IF (@JobID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.JobID = ''' + @JobID + ''')'
	IF (@PersonnelID Is Not Null and @PersonnelID<>'')
		SET @StrWhere  = @StrWhere  + ' AND (D.PersonnelID = ''' + @PersonnelID + ''')'

	SET @StrSelect1 = '
		SELECT	D.PersonnelID, 
				P.FirstName + '' '' + P.LastName As PersonnelName, 
			    PH.InsuranceID As PersonnelInsuranceID, 
				D.Basepay, 
				D.LeavePay, 
				D.HourlyOvertimeBase, 
				D.JobCategoryPay, 
				D.PastWagesDailyPay,
				D.DailyInferiorPay, 
				D.DailyInferiorPayRemain, 
				D.JobCategoryPayInsure,
				D.PastWagesDailyPayInsure,
				D.DailyInferiorPayInsure,
				D.DailyInferiorPayRemainInsure,
			    D.VacationOvertimeBase, 
				D.HourlyOverProduct, 
				D.HourlyWorkDeductionBase,
				OvertimeAmount,
				VacationAmount,
				OverProductAmount,
				S.WorkDeductionAmount,
				S.DelayAmount,
				S.RedeemedVacationAmount,
				F.HourlyOvertime, 
				F.VacationOvertime, 
				F.OverProduct, 
				F.LeaveWithoutPay, 
				F.SickLeave, 
				F.MonthlyFunction, 
				F.MonthlyFunctionTime, 
				F.MonthlyTime, 
				F.Absence,
				prs.funGetDayHourMinsLeave( prs.funGetHourMinutesStandard(prs.funGetMinutes(F.LeaveTime)))  As LeaveTimeTime,
				prs.funGetDayHourMinsLeave( prs.funGetHourMinutesStandard(F.LeaveDay * prs.funGetMinutes(''' + @StrTemp + '''))) As LeaveTimeDay,
				prs.funGetDayHourMinsLeave( prs.funGetHourMinutesStandard(prs.funGetMinutes(F.LeaveTime) + (F.LeaveDay * prs.funGetMinutes(''' + @StrTemp + '''))))  As LeaveTime, 
				F.Delay, 
				F.WorkDeduction,
				Cast('''' As NVarChar(250)) As PaymentText,
				F.PeriodWork001, 
				F.PeriodWork002, 
				F.PeriodWork003, 
				F.PeriodWork004,
				(SELECT PeriodWorkName + '' (روز):''
				 FROM emp.tblPeriodWorksDtl
				 WHERE (PeriodWorkID = ''001'')) As PeriodWork001Name,
				(SELECT PeriodWorkName + '' (روز):''
				 FROM emp.tblPeriodWorksDtl
				 WHERE (PeriodWorkID = ''002'')) As PeriodWork002Name,
				(SELECT PeriodWorkName + '' (روز):''
				 FROM emp.tblPeriodWorksDtl
				 WHERE (PeriodWorkID = ''003'')) As PeriodWork003Name,
				(SELECT PeriodWorkName + '' (روز):''
				 FROM emp.tblPeriodWorksDtl
				 WHERE (PeriodWorkID = ''004'')) As PeriodWork004Name,
				(ISNULL(DD.SumLoanAmount,0) - ISNULL(LS.SumMonthInstallment,0)) LoanAmount, 
				F.RedeemedVacationDays,
				F.RedeemedVacationTime,
				prs.funGetHourMinutesStandard(prs.funGetMinutes(RedeemedVacationTime)+RedeemedVacationDays*  ' + str(@IntMinsPerDay )+') RedeemedVacationTimes,
				F.WithoutContactWorkDeduction, 
				prs.funGetDayHourMinsLeave((
					SELECT prs.funGetHourMinutesStandard((prs.funGetMinutes(LastYearRemainT) + 
														  prs.funGetMinutes(MonthT1) + 
														  prs.funGetMinutes(MonthT2) + 
														  prs.funGetMinutes(MonthT3) + 
														  prs.funGetMinutes(MonthT4) + 
														  prs.funGetMinutes(MonthT5) + 
														  prs.funGetMinutes(MonthT6) + 
														  prs.funGetMinutes(MonthT7) + 
														  prs.funGetMinutes(MonthT8) + 
														  prs.funGetMinutes(MonthT9) + 
														  prs.funGetMinutes(MonthT10) + 
														  prs.funGetMinutes(MonthT11) + 
														  prs.funGetMinutes(MonthT12)) + 
														((LastYearRemain + 
														  Month1 + 
														  Month2 + 
														  Month3 + 
														  Month4 + 
														  Month5 +
														  Month6 +
														  Month7 + 
														  Month8 + 
														  Month9 +
														  Month10 +
														  Month11 +
														  Month12) * prs.funGetMinutes(''' + @StrTemp + ''')))
					FROM emp.tblVacationMaxDtl
					WHERE (PersonnelID = S.PersonnelID))) AS TotalLeaveTimeYear,
				prs.funGetDayHourMinsLeave(prs.funGetTotalLeaveTime2Month(S.PersonnelID,' + Str(@MonthCode) + ',''' + @StrTemp + '''))TotalLeaveTime2Month,
				prs.funGetDayHourMinsLeave(prs.funGetHourMinutesStandard(
											  (prs.funGetMinutes 
												  (prs.funGetTotalLeaveTime2Month(S.PersonnelID,' + Str(@MonthCode) + ',''' + @StrTemp + ''')))-
											  (SELECT SUM(prs.funGetMinutes(LeaveTime) + 
														  prs.funGetMinutes(RedeemedVacationTime) + 
														  ((LeaveDay +
															RedeemedVacationDays) * prs.funGetMinutes(''' + @StrTemp + ''')))
												FROM prs.tblFunctionsDtl 
												WHERE (PersonnelID = S.PersonnelID) 
												  AND (MonthCode <= ' + Str(@MonthCode) + ')))) AS TotalLeaveTimeRemain2Month,
				prs.funGetDayHourMinsLeave(prs.funGetHourMinutesStandard((SELECT (prs.funGetMinutes(LastYearRemainT) + 
																				  prs.funGetMinutes(MonthT1) + 
																				  prs.funGetMinutes(MonthT2) + 
																				  prs.funGetMinutes(MonthT3) + 
																				  prs.funGetMinutes(MonthT4) + 
																				  prs.funGetMinutes(MonthT5) + 
																				  prs.funGetMinutes(MonthT6) + 
																				  prs.funGetMinutes(MonthT7) + 
																				  prs.funGetMinutes(MonthT8) +
																				  prs.funGetMinutes(MonthT9) + 
																				  prs.funGetMinutes(MonthT10) + 
																				  prs.funGetMinutes(MonthT11) + 
																				  prs.funGetMinutes(MonthT12)) + 
																			    ((LastYearRemain + 
																				  Month1 + 
																				  Month2 + 
																				  Month3 + 
																				  Month4 + 
																				  Month5 +
																				  Month6 +
																				  Month7 +
																				  Month8 + 
																				  Month9 +
																				  Month10 +
																				  Month11 +
																				  Month12) * prs.funGetMinutes(''' + @StrTemp + ''')) 
																		  FROM emp.tblVacationMaxDtl
																		  WHERE (PersonnelID = S.PersonnelID)) - 
																		  (SELECT SUM(prs.funGetMinutes(LeaveTime) + 
																					  prs.funGetMinutes(RedeemedVacationTime) + 
																					((LeaveDay +
																					  RedeemedVacationDays) * prs.funGetMinutes(''' + @StrTemp + ''')))
																		   FROM prs.tblFunctionsDtl 
																		   WHERE (PersonnelID = S.PersonnelID) 
																		     AND (MonthCode <= ' + Str(@MonthCode) + ')))) AS TotalLeaveTimeRemainYear,
				prs.funGetDayHourMinsLeave((
					SELECT prs.funGetHourMinutesStandard(Sum(prs.funGetMinutes(LeaveTime) + 
															(LeaveDay * prs.funGetMinutes(''' + @StrTemp + '''))))
					FROM prs.tblFunctionsDtl 
					WHERE (PersonnelID = S.PersonnelID) 
					  AND (MonthCode <= ' + Str(@MonthCode) + '))) AS TotalLeaveTime,
				prs.funGetDayHourMinsLeave(prs.funGetHourMinutesStandard(((SELECT (Sum(prs.funGetMinutes(LeaveTime) + 
																					  (LeaveDay * prs.funGetMinutes(''' + @StrTemp + '''))))
																		   FROM prs.tblFunctionsDtl 
																		   WHERE (PersonnelID = S.PersonnelID) 
																		     AND (MonthCode <= ' + Str(@MonthCode) + '))-
																		 ((SELECT (Sum(prs.funGetMinutes(LeaveTime) + 
																					  (LeaveDay * prs.funGetMinutes(''' + @StrTemp + '''))))
																		   FROM prs.tblFunctionsDtl 
																		   WHERE (PersonnelID = S.PersonnelID) 
																		     AND (MonthCode <= ' + Str(@MonthCode) + ')) /  ' + str(@IntMinsPerDay )+') * ' + str(@IntMinsPerDay )+')))	 AS TotalLeaveWhitTime,	
' 
SET @StrSelect2= '				
				(SELECT (Sum(prs.funGetMinutes(LeaveTime) + 
							(LeaveDay * prs.funGetMinutes(''' + @StrTemp + ''')) ))
				 FROM prs.tblFunctionsDtl 
				 WHERE (PersonnelID = S.PersonnelID) 
				   AND (MonthCode <= ' + Str(@MonthCode) + ')) / ' + str(@IntMinsPerDay )+'  AS TotalLeaveWhitDay,
				 prs.funGetDayHourMinsLeave((SELECT prs.funGetHourMinutesStandard(Sum(prs.funGetMinutes(LeaveTime)))
											 FROM prs.tblFunctionsDtl 
											 WHERE (PersonnelID = S.PersonnelID) 
											   AND (MonthCode <= ' + Str(@MonthCode) + '))) AS TotalLeaveTime1,
				prs.funGetDayHourMinsLeave((SELECT prs.funGetHourMinutesStandard(Sum((LeaveDay * prs.funGetMinutes(''' + @StrTemp + '''))))
											FROM prs.tblFunctionsDtl 
											WHERE (PersonnelID = S.PersonnelID) 
											  AND (MonthCode <= ' + Str(@MonthCode) + '))) AS TotalLeaveTime2,
				prs.funGetDayHourMinsLeave((SELECT prs.funGetHourMinutesStandard(Sum(prs.funGetMinutes(HourlyLeaveWithoutPay) + 
																					 (LeaveWithoutPay * prs.funGetMinutes(''' + @StrTemp + ''')) ))
											FROM prs.tblFunctionsDtl 
											WHERE (PersonnelID = S.PersonnelID) 
											  AND (MonthCode <= ' + Str(@MonthCode) + '))) AS TotalLeaveWithoutPay,
				D.AbsenceBase, 
				D.HourlyDelayBase, 
				F.HourlyLeaveWithoutPay, 
				ISNULL(SDH.SalaryDescs, '''') as SalaryDescHdr,
				ISNULL(SDD.SalaryDescs, '''') as SalaryDescDtl,
				ISNULL((SELECT TOP 1 AccountNo FROM prs.tblPersonnelAccountsDtl WHERE PersonnelID = S.PersonnelID ORDER BY IsDefault desc),'''') PersonnelAccountNo,
				F.InsuranceFunction, 
				DP.DepartmentName, 
				D.DepartmentID, 
				P.FatherName, 
				PH.IDNumber, 
				PH.NationalIDNumber, 
				PH.IssuancePlace, 
				pub.funGetLocationName(PH.IssuancePlace, '''+ @LangID+ ''') AS IssuancePlaceName, 
				PH.BirthDate, 
				PH.BirthPlace, 
				pub.funGetLocationName(PH.BirthPlace, '''+ @LangID+ ''') AS BirthPlaceName, 
				J.JobName,
				D.JobID, 
				S.EmployeeInsur,
				Cast(S.EmployeeInsur/7*23 As Bigint) As EmployerInsur, 
				ISNULL(C1.Cost,0) AS EndWork1, 
				ISNULL(C2.Cost,0) AS EndWork2,
				P.Address,
				P.Description,
				PH.BeforeFiscalYearRoundAmount,
				PH.Daughters,
				PH.Sons,
				PH.Email,
				PH.Gender,
				PH.EmployeeNumber,
				PH.HabitatCity,
				PH.HireDate,
				CASE WHEN D.InsuranceHireDate<>'''' THEN D.InsuranceHireDate ELSE  PH.InsuranceHireDate END InsuranceHireDate,
				PH.MilitaryStatus,
				PH.Mobile,
				CASE WHEN D.QuitJobDate<>'''' THEN D.QuitJobDate ELSE  PH.QuitJobDate END QuitJobDate,
				PH.Tel,
				PH.ZipCode,
				PH.IsStudent,
				CASE WHEN PH.YearTaxableAmount = RIGHT(DB_NAME(),4) THEN PH.IncomeTaxableAmount ELSE 0 END IncomeTaxableAmount,
				CASE WHEN PH.YearTaxableAmount = RIGHT(DB_NAME(),4) THEN PH.PayedTaxAmount ELSE 0 END PayedTaxAmount,
				CASE WHEN PH.YearTaxableAmount = RIGHT(DB_NAME(),4) THEN PH.IncomeTaxableAmountCelebration ELSE 0 END IncomeTaxableAmountCelebration,
				CASE WHEN PH.YearTaxableAmount = RIGHT(DB_NAME(),4) THEN PH.PayedTaxAmountCelebration ELSE 0 END PayedTaxAmountCelebration,
				CASE WHEN PH.YearTaxableAmount = RIGHT(DB_NAME(),4) THEN PH.MonthTaxableAmount ELSE 0 END MonthTaxableAmount,
				PH.CardNumber,
				D.HdrDesc,
				D.MissionDaily, 
				D.MissionTime,
				ISNULL((SELECT SUM(V.Debit-V.Credit)
						FROM acc.tblVoucherDtl V
						WHERE (V.AcntCode = D.AcntSalary) 
						  AND SerialNo<> S.VchNo 
						  AND (V.VchKind not in ( 0,3)) 
						  AND ((V.DocDate < ''' + @RemainDate + ''') 
						   OR (V.DocDate = ''' + @RemainDate + ''' 
						  AND V.SourceDocType NOT IN(3) 
						  AND V.SourceProcessID NOT IN(310,315)))),0) Remain,
				' + str(@IntMinsPerDay )+' MinsPerDay,
				''' + @StrTemp + ''' DailyLeaveHours
	' 
SET @StrSelect3= '	FROM prs.tblSalaryCalculation S
					INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = S.PersonnelID AND D.SerialNo = S.DecreeSerialNo
					INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = S.PersonnelID 
					INNER JOIN prs.tblDepartmentsDtl DP ON D.DepartmentID = DP.DepartmentID 
					INNER JOIN prs.tblPersonnels PH ON PH.PersonnelID = S.PersonnelID 
					INNER JOIN prs.tblFunctionsDtl F ON F.MonthCode = S.MonthCode AND F.PersonnelID = S.PersonnelID
			
	LEFT JOIN (SELECT PersonnelID, 
					  Sum(Cost) as Cost 
			   FROM prs.tblCelebrationDtl 
			   WHERE MonthCode <= ' + Str( @MonthCode) + ' 
			     AND (ProcessID = 325) 
				 AND (Payable = 0) 
			   GROUP BY PersonnelID) C1	ON C1.PersonnelID = S.PersonnelID
	LEFT JOIN (SELECT PersonnelID, 
					  Sum(Cost) as Cost 
			   FROM prs.tblCelebrationDtl 
			   WHERE MonthCode <= ' + Str( @MonthCode) + ' 
				 AND (ProcessID = 320) 
				 AND (Payable = 0) 
			   GROUP BY PersonnelID) C2	ON C2.PersonnelID = S.PersonnelID		
	LEFT JOIN (SELECT PersonnelID, 
					  ISNull(SUM(CASE WHEN DebitFromLoan = 0 THEN LoanAmount ELSE DebitFromLoan END), 0)  SumLoanAmount
			   FROM prs.tblLoanInstallmentsDtl 
			   WHERE (StartLoanDate <= ''' + @LoanDate + ''') 
			     AND Settlemented = 0
			   GROUP BY PersonnelID) DD ON DD.PersonnelID = S.PersonnelID
	LEFT JOIN (SELECT x.PersonnelID, 
					  ISNULL(SUM(x.ThisMonthInstallment), 0) AS SumMonthInstallment
			   FROM prs.tblInstallmentDeductionsDtl AS x 
			   INNER JOIN prs.tblLoanInstallmentsDtl AS y ON x.PersonnelID = y.PersonnelID 
														 AND x.FiscalYear = y.FiscalYear 
														 AND x.SerialNo = y.SerialNo  
														 AND x.ReceiptDate = y.ReceiptDate 
			   WHERE (y.Settlemented = 0) 
			     AND (MonthCode <= ' + Str(@MonthCode) + ')
			   GROUP BY x.PersonnelID) LS ON DD.PersonnelID = LS.PersonnelID
	LEFT JOIN prs.tblSalaryDescsHdr SDH ON SDH.MonthCode = S.MonthCode
	LEFT JOIN prs.tblSalaryDescsDtl SDD ON SDD.MonthCode = S.MonthCode 
									   AND SDD.PersonnelID = S.PersonnelID
	LEFT JOIN prs.tblJobsDtl AS J ON D.JobID = J.JobID 
								 AND J.LanguageID =  '''+ @LangID+ '''
	WHERE'+@StrWhere
	
	PRINT @StrSelect1;
	PRINT @StrSelect2;
	PRINT @StrSelect3;

	SET @StrSelect1=@StrSelect1+@StrSelect2+@StrSelect3
	EXEC sp_executesql @StrSelect1;
End
GO
