USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetServiceNameByPartNumber] 
(
	@GoodsID Char(20) ,
	@LanguageID TinyInt,
	@PartNumber int
)
RETURNS NVarChar(500)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @GoodsName NVarChar(500)

	SELECT @GoodsName = GoodsName 
	From inv.tblGoodsDtl 
	Where LanguageID = @LanguageID AND GoodsID = @GoodsID  and PartNumber = @PartNumber

	-- Return the result of the function
	RETURN @GoodsName 

END
GO
