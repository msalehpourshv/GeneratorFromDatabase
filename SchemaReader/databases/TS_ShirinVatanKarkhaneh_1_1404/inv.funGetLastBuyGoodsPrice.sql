USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetLastBuyGoodsPrice] 
(
	@GoodsID Varchar(20),
	@StoreID Varchar(20),
	@DocDate Char(10),
	@VolumeRowNo float,
	@LanguageID TinyInt
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

	DECLARE @GoodsPrice  FLOAT
	SET  @GoodsPrice = 0

	SELECT TOP 1 @GoodsPrice = GoodsPrice
	From inv.tblStorageDocsDtl
	Where	GoodsID=@GoodsID  AND 
			(DocDate<@DocDate OR (DocDate = @DocDate AND (@VolumeRowNo=0 OR VolumeRowNo < @VolumeRowNo))) AND 
			ProcessID IN (55,56) AND GoodsPrice <> 0
	ORDER BY DocDate Desc,VolumeRowNo Desc	

	RETURN @GoodsPrice
END
GO
