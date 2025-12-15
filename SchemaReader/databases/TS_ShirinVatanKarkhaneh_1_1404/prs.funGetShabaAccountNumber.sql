USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prs].[funGetShabaAccountNumber]
(
	@PersonnelID	Char(20),
	@AccountNo		NVarChar(50)
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @ShabaAccountNumber NVarChar(50)

	Set @ShabaAccountNumber = N'-'

	SELECT @ShabaAccountNumber = ShabaAccountNumber 
	From  prs.tblPersonnelAccountsDtl
	Where  PersonnelID = @PersonnelID AND AccountNo = @AccountNo 

	-- Return the result of the function
	RETURN @ShabaAccountNumber 

END
GO
