USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [pub].[FunGetMonthDay]
(
	@Year int,
	@Month int
)
	RETURNS  tinyint 
WITH ENCRYPTION
AS
BEGIN
	
	Declare @ReturnValue AS tinyint

	IF @Month >=1 AND @Month <=6
		SET @ReturnValue = 31
	ELSE IF @Month >=7 AND @Month <=11
		SET @ReturnValue = 30
	ELSE IF @Month = 12
		BEGIN
					
			SET	@Year =  @Year%33
			IF 	@Year =1 OR @Year =5 OR @Year =9 OR @Year =13 OR @Year =17 OR @Year =22 OR @Year =26 OR @Year =30 
				SET @ReturnValue = 30
			ELSE	
				SET @ReturnValue = 29
				
		END
	ELSE
		SET @ReturnValue = 30
	
	Return @ReturnValue;
END 
GO
