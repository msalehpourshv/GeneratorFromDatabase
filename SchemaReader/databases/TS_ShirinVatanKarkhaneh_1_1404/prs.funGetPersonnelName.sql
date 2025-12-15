USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prs].[funGetPersonnelName] 
(
	@PersonnelID	Char(20) ,
	@LanguageID	TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @PersonnelName NVarChar(50)

	Set @PersonnelName = N'-'

	SELECT @PersonnelName = RTRIM(FirstName) + '  ' + RTRIM(LastName)
	From  prs.tblPersonnelsDtl
	Where LanguageID = @LanguageID AND PersonnelID = @PersonnelID 

	-- Return the result of the function
	RETURN @PersonnelName 

END
GO
