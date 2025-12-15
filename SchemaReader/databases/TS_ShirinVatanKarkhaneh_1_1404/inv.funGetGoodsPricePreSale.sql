USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [inv].[funGetGoodsPricePreSale]
(
	@GoodsID	Varchar(20),
	@StoreID	Varchar(20),
	@DocDate	Char(10),
	@SerialNo	Int
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

	DECLARE @GoodsPrice  FLOAT

	SET  @GoodsPrice = 0

		SELECT TOP 1 @GoodsPrice = GoodsAmount
		From inv.tblPreSaleDtl
		Where	GoodsID=@GoodsID  AND 
				DocDate<=@DocDate AND
				SerialNo < @SerialNo AND
				ProcessID = 240	
		ORDER BY DocDate Desc,SerialNo Desc	

	RETURN @GoodsPrice
END
GO
