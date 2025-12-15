USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetLocationName] 
(
	@LocationID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Declare the return variable here
	DECLARE @LocationName NVarChar(50)

	Set @LocationName = N''

	SELECT @LocationName = LocationName 
	From pub.tblLocationsDtl 
	Where LanguageID = @LanguageID AND LocationID = @LocationID

	-- Return the result of the function
	RETURN @LocationName 

END












GO
