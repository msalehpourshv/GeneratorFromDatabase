USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[FunGetMonthDays]
(
	@StrDate VarChar(10)
)
	RETURNS  tinyint 
WITH ENCRYPTION
AS
BEGIN
	Declare @Month AS int
	Declare @ReturnValue AS tinyint

	IF LEN(@StrDate) = 10
		SET @Month = SUBSTRING(@StrDate,6,2)
	IF @Month >=1 AND @Month <=6
		SET @ReturnValue = 31
	ELSE IF @Month >=7 AND @Month <=11
		SET @ReturnValue = 30
	ELSE IF @Month = 12
		BEGIN
			DECLARE @LeapYear INT
			SET @LeapYear = SUBSTRING(@StrDate,1,4)
			SET	@LeapYear =  @LeapYear%33
			IF 	@LeapYear =1 OR @LeapYear =5 OR @LeapYear =9 OR @LeapYear =13 OR @LeapYear =17 OR @LeapYear =22 OR @LeapYear =26 OR @LeapYear =30 
				SET @ReturnValue = 30
			ELSE	
				SET @ReturnValue = 29
				
		END
	ELSE
		SET @ReturnValue = 30
	
	Return @ReturnValue;
END 
GO
