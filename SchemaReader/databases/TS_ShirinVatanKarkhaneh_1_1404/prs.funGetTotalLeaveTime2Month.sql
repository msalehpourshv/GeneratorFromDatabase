USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create Date   : 1402/12/01
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : مجموع مرخصی های پرسنا تا ماه
-- ==============================================
--select prs.funGetTotalLeaveTime2Month('010429',10,'07:20')
Create FUNCTION prs.funGetTotalLeaveTime2Month
(
	@PersonnelID	Char(20) ,
	@MonthCode		integer ,
	@DailyLeaveHours Char(5)
)
RETURNS Char(7)
WITH ENCRYPTION
AS

BEGIN
 	DECLARE @TotalTime Char(7)
	Set @TotalTime ='0000:00'
	if @MonthCode<1
		Set @TotalTime ='0000:00'
	else if @MonthCode<2
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)) 
					+ (( LastYearRemain+ Month1) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 
else if @MonthCode<3
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes( MonthT2)) 
					+ (( LastYearRemain+ Month1+ Month2) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 
else if @MonthCode<4
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes( MonthT2)+prs.funGetMinutes( MonthT3)) 
					+ (( LastYearRemain+ Month1+ Month2+ Month3  ) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 
else if @MonthCode<5
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes( MonthT2)+prs.funGetMinutes( MonthT3)+prs.funGetMinutes( MonthT4)) 
					+ (( LastYearRemain+ Month1+ Month2+ Month3+ Month4 ) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 
else if @MonthCode<6
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes( MonthT2)+prs.funGetMinutes( MonthT3)+prs.funGetMinutes( MonthT4)+prs.funGetMinutes( MonthT5)) 
					+ (( LastYearRemain+ Month1+ Month2+ Month3+ Month4+ Month5 ) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 
else if @MonthCode<7
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes( MonthT2)+prs.funGetMinutes( MonthT3)+prs.funGetMinutes( MonthT4)+prs.funGetMinutes( MonthT5)+prs.funGetMinutes( MonthT6)) 
					+ (( LastYearRemain+ Month1+ Month2+ Month3+ Month4+ Month5+	Month6 ) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 
else if @MonthCode<8
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes( MonthT2)+prs.funGetMinutes( MonthT3)+prs.funGetMinutes( MonthT4)+prs.funGetMinutes( MonthT5)+prs.funGetMinutes( MonthT6)+prs.funGetMinutes( MonthT7)) 
					+ (( LastYearRemain+ Month1+ Month2+ Month3+ Month4+ Month5+	Month6+		Month7 ) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 
else if @MonthCode<9
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes( MonthT2)+prs.funGetMinutes( MonthT3)+prs.funGetMinutes( MonthT4)+prs.funGetMinutes( MonthT5)+prs.funGetMinutes( MonthT6)+prs.funGetMinutes( MonthT7)+prs.funGetMinutes( MonthT8)) 
					+ (( LastYearRemain+ Month1+ Month2+ Month3+ Month4+ Month5+	Month6+		Month7+		Month8 ) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 
else if @MonthCode<10
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes( MonthT2)+prs.funGetMinutes( MonthT3)+prs.funGetMinutes( MonthT4)+prs.funGetMinutes( MonthT5)+prs.funGetMinutes( MonthT6)+prs.funGetMinutes( MonthT7)+prs.funGetMinutes( MonthT8)+prs.funGetMinutes( MonthT9)) 
					+ (( LastYearRemain+ Month1+ Month2+ Month3+ Month4+ Month5+	Month6+		Month7+		Month8+ Month9) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 
else if @MonthCode<11
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes( MonthT2)+prs.funGetMinutes( MonthT3)+prs.funGetMinutes( MonthT4)+prs.funGetMinutes( MonthT5)+prs.funGetMinutes( MonthT6)+prs.funGetMinutes( MonthT7)+prs.funGetMinutes( MonthT8)+prs.funGetMinutes( MonthT9)+prs.funGetMinutes( MonthT10)) 
					+ (( LastYearRemain+ Month1+ Month2+ Month3+ Month4+ Month5+	Month6+		Month7+		Month8+ Month9+ Month10 ) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 
else if @MonthCode<12
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes( MonthT2)+prs.funGetMinutes( MonthT3)+prs.funGetMinutes( MonthT4)+prs.funGetMinutes( MonthT5)+prs.funGetMinutes( MonthT6)+prs.funGetMinutes( MonthT7)+prs.funGetMinutes( MonthT8)+prs.funGetMinutes( MonthT9)+prs.funGetMinutes( MonthT10)+prs.funGetMinutes( MonthT11)) 
					+ (( LastYearRemain+ Month1+ Month2+ Month3+ Month4+ Month5+	Month6+		Month7+		Month8+ Month9+ Month10+ Month11 ) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 
else if @MonthCode<13
	SELECT @TotalTime =prs.funGetHourMinutesStandard(
					(prs.funGetMinutes(LastYearRemainT)+prs.funGetMinutes(MonthT1)+prs.funGetMinutes( MonthT2)+prs.funGetMinutes( MonthT3)+prs.funGetMinutes( MonthT4)+prs.funGetMinutes( MonthT5)+prs.funGetMinutes( MonthT6)+prs.funGetMinutes( MonthT7)+prs.funGetMinutes( MonthT8)+prs.funGetMinutes( MonthT9)+prs.funGetMinutes( MonthT10)+prs.funGetMinutes( MonthT11)+prs.funGetMinutes( MonthT12)) 
					+ (( LastYearRemain+ Month1+ Month2+ Month3+ Month4+ Month5+	Month6+		Month7+		Month8+ Month9+ Month10+ Month11 + Month12) * prs.funGetMinutes(@DailyLeaveHours)) )
					FROM    emp.tblVacationMaxDtl
					WHERE (PersonnelID =@PersonnelID) 


	-- Return the result of the function
	RETURN @TotalTime 

END

GO
