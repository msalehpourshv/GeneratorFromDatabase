USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [ast].[funGetLawGroupName] 
(
	@LawGroupID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @LawGroupName NVarChar(50)

	Set @LawGroupName = N'-'

	SELECT @LawGroupName = LawGroupName 
	From ast.tblLawGroupsDtl
	Where LanguageID = @LanguageID AND LawGroupID = @LawGroupID

	-- Return the result of the function
	RETURN @LawGroupName 

END
GO
