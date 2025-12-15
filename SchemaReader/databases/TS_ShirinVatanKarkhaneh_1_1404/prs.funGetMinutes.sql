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
-- Description	 : تبدیل ساعت و دقیقه به جمع دقیقه
-- ==============================================
Create FUNCTION prs.funGetMinutes
(
	@HourMinute	Char(7)	
)
RETURNS Int
WITH ENCRYPTION
AS
BEGIN
	DECLARE @strTemp VarChar(5)
	DECLARE @Result Int
	DECLARE @Idx Int

	DECLARE @Sign Int=1

	if SUBSTRING(@HourMinute,1,1)='-'
		set @Sign=-1
	
	SET @Result = 0

	If LTrim(@HourMinute) = '' 
		RETURN @Result

	SELECT @Idx = CharIndex(':', @HourMinute)

	If @Idx = 0 
		RETURN @Result

	SET @strTemp = Left(@HourMinute, @Idx - 1)
	SET @strTemp = LTrim(RTrim(@strTemp))
	if @strTemp<0
		set  @strTemp=ABS(@strTemp)
	
	If @strTemp <> ''
		SET @Result = @Result + Cast(@strTemp As Int) * 60

	SET @strTemp = Substring(@HourMinute, @Idx + 1, 2)
	SET @strTemp = LTrim(RTrim(@strTemp))

	If @strTemp <> ''
		SET @Result = @Result + Cast(@strTemp As Int)

	RETURN @Result *@Sign

END


GO
