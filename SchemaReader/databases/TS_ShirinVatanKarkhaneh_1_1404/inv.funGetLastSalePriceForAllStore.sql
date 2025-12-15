USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetLastSalePriceForAllStore]
(
	@GoodsID Varchar(20),
	@DocDate Char(10),
	@SerialNo	Int
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

	DECLARE @GoodsPrice  FLOAT

	SET  @GoodsPrice = 0

	SELECT TOP 1 @GoodsPrice = GoodsPrice
	From inv.tblStorageDocsDtl
	Where	GoodsID  = @GoodsID  AND 
			DocDate < @DocDate  AND
			SerialNo < @SerialNo AND
			ProcessID = 90	
	ORDER BY DocDate Desc,VolumeRowNo Desc	

	RETURN @GoodsPrice
END
GO
