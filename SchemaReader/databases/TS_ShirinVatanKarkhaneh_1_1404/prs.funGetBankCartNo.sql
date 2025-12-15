USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prs].[funGetBankCartNo]
(
	@PersonnelID	Char(20) 
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @BankCartNo NVarChar(50)

	Set @BankCartNo = N'-'

	SELECT @BankCartNo = BankCartNo 
	From  prs.tblPersonnelAccountsDtl
	Where  PersonnelID = @PersonnelID AND IsDefault = 1

	-- Return the result of the function
	RETURN @BankCartNo 

END
GO
