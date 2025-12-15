USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trn].[funGetVehicleName] 
(
	@VehicleID VARCHAR(20),
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @VehicleName NVarChar(50)

	Set @VehicleName = N'-'

	SELECT @VehicleName = VehicleName
	From trn.tblVehiclesDtl
	Where LanguageID = @LanguageID AND VehicleID = @VehicleID

	-- Return the result of the function
	RETURN @VehicleName 

END

GO
