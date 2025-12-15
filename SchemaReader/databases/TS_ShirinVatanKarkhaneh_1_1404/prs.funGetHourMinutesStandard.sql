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
-- Description	 : تبدیل دقیقه به ساعت و دقیقه
-- ==============================================
Create FUNCTION prs.funGetHourMinutesStandard
(
	@Minute	Int
)
RETURNS Char(7)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result Char(7)
	DECLARE @IntTemp Int

	SET @Result = '0000:00'

	If @Minute = 0 
		RETURN @Result

	-- Calc Hours
	SET @IntTemp = @Minute / 60
	IF @IntTemp=0
		SET @Result = '00'
	ELSE IF @IntTemp<10 and @IntTemp>0
		SET @Result = '0' + LTrim(RTrim(Str(@IntTemp)))
	ELSE	
		SET @Result = LTrim(RTrim(Str(@IntTemp)))

	-- Append ':'
	SET @Result = LTRim(Rtrim(@Result)) + ':'


	-- Calc Minutes
	SET @IntTemp = @Minute - (@IntTemp * 60)	
	SET @IntTemp =ABS(@IntTemp)
	IF @IntTemp=0
		SET @Result =  LTRim(Rtrim(@Result)) 
	IF @IntTemp=0
		SET @Result =  LTRim(Rtrim(@Result)) + '00' 
	else 
	IF @IntTemp<10 and @IntTemp>0
		SET @Result =  LTRim(Rtrim(@Result)) + '0' + LTrim(RTrim(Str(@IntTemp)))
	ELSe
		SET @Result = LTRim(Rtrim(@Result)) + LTrim(RTrim(Str(@IntTemp)))
	RETURN @Result 

END
GO
