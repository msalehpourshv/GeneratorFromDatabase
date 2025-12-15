USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetGoodsGroupName] 
(
	@GoodsGroupID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @GoodsGroupName NVarChar(50)

	Set @GoodsGroupName = N'-'

	SELECT @GoodsGroupName = GoodsGroupName 
	From inv.tblGoodsGroupsDtl 
	Where LanguageID = @LanguageID AND GoodsGroupID = @GoodsGroupID

	-- Return the result of the function
	RETURN @GoodsGroupName 

END

	











GO
