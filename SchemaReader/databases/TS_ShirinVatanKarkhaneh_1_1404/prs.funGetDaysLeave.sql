USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create date   : 1399/11/15
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : تبدیل دقیقه به روز
-- ==============================================
CREATE FUNCTION prs.funGetDaysLeave
(
	@Minuts Int
)
RETURNS Int
WITH ENCRYPTION
AS
BEGIN
	DECLARE @StrTemp Char(5)
	DECLARE @IntResult Int
	DECLARE @IntMinsPerDay	Int

	SET @IntResult = 0

	-- Get <Hours Per Day> from db
	SELECT @StrTemp = RTrim(LTrim(SettingValue))
	FROM pub.tblSettings
	WHERE SettingKey = 'DailyLeaveHours'

	If (@StrTemp Is NULL)
		SET @StrTemp = '07:20'

	-- Calc <Mins Per Day>
	SET @IntMinsPerDay = prs.funGetMinutes(@StrTemp) 

	-- Calc <Days>
	If (@IntMinsPerDay > 0)
		SET @IntResult = (@Minuts / @IntMinsPerDay)

	RETURN @IntResult
END
GO
