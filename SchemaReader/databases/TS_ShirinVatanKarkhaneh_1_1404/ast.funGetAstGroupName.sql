USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [ast].[funGetAstGroupName] 
(
	@AstGroupID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @AstGroupName NVarChar(50)

	Set @AstGroupName = N'-'

	SELECT @AstGroupName = AstGroupName 
	From ast.tblAstGroupsDtl
	Where LanguageID = @LanguageID AND AstGroupID = @AstGroupID

	-- Return the result of the function
	RETURN @AstGroupName 

END













GO
