USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetLocationAreaCode] 
(
	@LocationID Char(20) 
)
RETURNS NVarChar(10)
WITH ENCRYPTION
AS

BEGIN

		-- Declare the return variable here
	DECLARE @AreaCode Nvarchar(10)

	Set @AreaCode = N''

	SELECT @AreaCode = AreaCode 
	From pub.tblLocations
	Where  LocationID = @LocationID

	-- Return the result of the function
	RETURN @AreaCode 

END













GO
