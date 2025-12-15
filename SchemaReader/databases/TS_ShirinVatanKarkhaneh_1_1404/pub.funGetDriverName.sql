USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetDriverName] 
(
	@DriverID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Declare the return variable here
	DECLARE @DriverName NVarChar(50)

	Set @DriverName = N'-'

	SELECT @DriverName = FirstName + ' ' + LastName
	From pub.tblDriversDtl
	Where LanguageID = @LanguageID AND DriverID = @DriverID

	-- Return the result of the function
	RETURN @DriverName 

END












GO
