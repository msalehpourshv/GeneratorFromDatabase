USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/09/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : تبدیل ساعت و دقیقه به روز و ساعت
-- ==============================================
Create FUNCTION [prs].[funGetDayHourMins]  
(
	@HourMins Char(7)
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @IntDays Int
	DECLARE @IntHours Int
	DECLARE @IntMins Int

	DECLARE @StrTemp Char(5)
	DECLARE @StrResult NVarChar(50)
	DECLARE @StrResult2 NVarChar(50)

	DECLARE @IntMinsTotal	Int
	DECLARE @IntMinsRemain	Int
	DECLARE @IntHoursPerDay	Int
	DECLARE @IntMinsPerHour	Int
	DECLARE @IntMinsPerDay	Int

	SET @IntMinsPerHour = 60
	SET @StrResult = ''
	SET @StrResult2 = ''

	-- get <Hours Per Day> from db
	SELECT @StrTemp = RTrim(LTrim(SettingValue))
	FROM pub.tblSettings
	WHERE SettingKey = 'DailyHours'

	If (@StrTemp Is NULL)
		SET @StrTemp = '07:20'

	-- Init
	if substring(@HourMins,1,1)='-'
	set @StrResult2=' منفی '
	
	SET @IntMinsPerDay = prs.funGetMinutes(@StrTemp) 
	SET @IntMinsTotal =abs( prs.funGetMinutes(@HourMins) )
	SET @IntMinsRemain = @IntMinsTotal
	
	If (@IntMinsPerDay <= 0)
		RETURN @StrResult

	-- Calc Days
	SET @IntDays = (@IntMinsRemain / @IntMinsPerDay)
	SET @IntMinsRemain = @IntMinsRemain - (@IntMinsPerDay * @IntDays)

	If (@IntDays > 0)
	Begin
		If @StrResult <> ''
			SET @StrResult = @StrResult + ' و '

		SET @StrResult = @StrResult + LTrim(Str(@IntDays)) + ' روز'
	End

	-- Calc Hours
	SET @IntHours = (@IntMinsRemain / @IntMinsPerHour)
	SET @IntMinsRemain = @IntMinsRemain - (@IntMinsPerHour * @IntHours)

	If (@IntHours > 0)
	Begin
		If @StrResult <> ''
			SET @StrResult = @StrResult + ' و '

		SET @StrResult = @StrResult + LTrim(Str(@IntHours)) + ' ساعت'
	End

	-- Calc Mins
	SET @IntMins = @IntMinsRemain 

	If (@IntMins > 0)
	Begin
		If @StrResult <> ''
			SET @StrResult = @StrResult + ' و '

		SET @StrResult = @StrResult + LTrim(Str(@IntMins)) + ' دقیقه'
	End

	RETURN @StrResult2 +@StrResult

END
GO
