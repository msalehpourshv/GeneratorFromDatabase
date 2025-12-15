USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trn].[funGetRefrigeratorName] 
(
	@RefrigeratorID VARCHAR(20),
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @RefrigeratorName NVarChar(50)

	Set @RefrigeratorName = N'-'

	SELECT @RefrigeratorName = RefrigeratorName
	From trn.tblRefrigeratorDtl
	Where LanguageID = @LanguageID AND RefrigeratorID = @RefrigeratorID

	-- Return the result of the function
	RETURN @RefrigeratorName 

END

GO
