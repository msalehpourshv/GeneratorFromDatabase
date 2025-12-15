USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sal].[funGetCurrencyPrice] 
(
	@GoodsID Varchar(20),
	@DocDate Char(10),
	@SaleTypeID Varchar(20)
)
RETURNS FLOAT
WITH ENCRYPTION
AS
BEGIN
	DECLARE @RoundableDigitsInPrice Tinyint
	DECLARE @CurrencyTypeID VARCHAR(20)
	DECLARE @CurrencyPrice Float
	DECLARE @CurrencyRate Float
	DECLARE @Coefficient Float

	SELECT top 1 @RoundableDigitsInPrice = RoundableDigitsInPrice, @CurrencyTypeID=CurrencyTypeID, 
			@CurrencyPrice=CurrencyPrice, @Coefficient=Coefficient
	From sal.tblGoodsPricesDtl 
	Where	LEN(GoodsID) > 0 AND GoodsID=SUBSTRING(@GoodsID,1,LEN(GoodsID)) AND
			SaleTypeID=@SaleTypeID AND SalePriceTypeID = 3
	order by LEN(GoodsID) desc	
	
	SELECT TOP 1 @CurrencyRate = CurrencyRate 
		FROM pub.tblCurrencyRatesDtl
		WHERE @CurrencyTypeID = CurrencyTypeID AND DocDate <= @DocDate
		ORDER BY DocDate Desc,DocTime Desc	

		IF @RoundableDigitsInPrice >0
			RETURN  ROUND(IsNull((@CurrencyRate * @CurrencyPrice * @Coefficient), 0),-1 * @RoundableDigitsInPrice)
		ELSE
			RETURN  IsNull((@CurrencyRate * @CurrencyPrice * @Coefficient), 0)
				
	RETURN 0
			
END
GO
