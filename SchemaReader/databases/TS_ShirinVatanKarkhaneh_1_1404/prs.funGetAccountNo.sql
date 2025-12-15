USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prs].[funGetAccountNo]
(
	@PersonnelID	Char(20) 
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @AccountNo NVarChar(50)

	Set @AccountNo = N'-'

	SELECT @AccountNo = AccountNo 
	From  prs.tblPersonnelAccountsDtl
	Where  PersonnelID = @PersonnelID AND IsDefault = 1

	-- Return the result of the function
	RETURN @AccountNo 

END
GO
