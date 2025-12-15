USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- select [inv].[funGoodsLastSalePrice]('41010201001007' )
 
Create FUNCTION sal.funGoodsPrice 
(
	@GoodsID Varchar(20)
)
RETURNS int
WITH ENCRYPTION
AS
BEGIN

DECLARE @GoodsPrice  int

	SET  @GoodsPrice = 0

	
SELECT top 1 @GoodsPrice=SalePrice from sal.tblGoodsPricesDtl b WHERE b.GoodsID=@GoodsID
if (@GoodsPrice=0)
	SELECT     TOP (1) @GoodsPrice =GoodsPrice
FROM         inv.tblStorageDocsDtl
WHERE     (GoodsID = @GoodsID) AND (ProcessID = 90)
ORDER BY DocDate DESC
	
	RETURN @GoodsPrice

end
GO
