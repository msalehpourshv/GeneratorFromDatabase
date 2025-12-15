USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [ast].[funGetAstGroupSpecName] 
(
	@AstGroupSpecID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @AstGroupsSpecName NVarChar(50)

	Set @AstGroupsSpecName = N'-'

	SELECT @AstGroupsSpecName = AstGroupsSpecName 
	From ast.tblAstGroupSpecsDtl
	Where LanguageID = @LanguageID AND AstGroupSpecID = @AstGroupSpecID

	-- Return the result of the function
	RETURN @AstGroupsSpecName 

END













GO
