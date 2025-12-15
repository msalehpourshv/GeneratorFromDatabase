USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prs].[funLockStatus]
(
	-- Add the parameters for the function here
	@MonthCode		Tinyint
)
RETURNS Bit
WITH ENCRYPTION
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result Int
	SET @Result =0

	Select @Result = Count(*) 
	From prs.tblSalaryCalculation
	Where	@MonthCode=MonthCode

	IF @Result = 0
		Return 0
	ELSE
		Return 1

	-- Return the result of the function
	RETURN @Result
END
GO
