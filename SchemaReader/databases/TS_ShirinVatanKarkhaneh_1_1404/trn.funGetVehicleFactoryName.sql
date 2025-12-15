USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trn].[funGetVehicleFactoryName] 
(
	@FactoryID VARCHAR(20),
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @FactoryName NVarChar(50)

	Set @FactoryName = N'-'

	SELECT @FactoryName = FactoryName
	From trn.tblVehicleFactoriesDtl
	Where LanguageID = @LanguageID AND FactoryID = @FactoryID

	-- Return the result of the function
	RETURN @FactoryName 

END














GO
