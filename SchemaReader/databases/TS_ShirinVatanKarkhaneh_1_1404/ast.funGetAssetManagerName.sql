USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [ast].[funGetAssetManagerName] 
(
	@AssetManagerID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @AssetManagerName NVarChar(50)

	Set @AssetManagerName = N'-'

	SELECT @AssetManagerName = AssetManagerName 
	From ast.tblAssetManagersDtl
	Where LanguageID = @LanguageID AND AssetManagerID = @AssetManagerID

	-- Return the result of the function
	RETURN @AssetManagerName 

END













GO
