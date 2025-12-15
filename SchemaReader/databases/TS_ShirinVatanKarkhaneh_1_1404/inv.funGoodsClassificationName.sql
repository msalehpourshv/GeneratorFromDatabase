USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGoodsClassificationName] 
(
	@GoodsClassificationID	Varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS
BEGIN

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Declare the return variable here
	DECLARE @GoodsClassificationName NVarChar(50)

	Set @GoodsClassificationName = N'-'

	SELECT @GoodsClassificationName = GoodsClassificationName
	From inv.tblGoodsClassificationDtl G
	Where LanguageID=@LanguageID AND GoodsClassificationID=@GoodsClassificationID

	-- Return the result of the function
	RETURN @GoodsClassificationName 

END
GO
