USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetGoodsPriceSaleType]
(
	@GoodsID	Varchar(20),
	@StoreID	Varchar(20),
	@DocDate	Char(10),
	@SerialNo	Int,
	@LanguageID TinyInt
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

	DECLARE @GoodsPrice  FLOAT
	DECLARE @SaleTypeID	 varchar(20)	

	SET  @GoodsPrice = 0

		SELECT TOP 1 @GoodsPrice = GoodsPrice
		From inv.tblStorageDocsDtl
		Where	GoodsID=@GoodsID  AND 
				DocDate<=@DocDate AND
				SerialNo < @SerialNo AND
				ProcessID = 90	
		ORDER BY DocDate Desc,VolumeRowNo Desc	

	IF @GoodsPrice > 0
		RETURN @GoodsPrice
	ELSE
		BEGIN
			DECLARE cur_SaleType CURSOR For 
			SELECT SaleTypeID 
			FROM sal.tblSaleTypes
			WHERE SaleTypeID <>''

			Open  cur_SaleType; 
				
			Fetch NEXT From cur_SaleType Into @SaleTypeID
		
			While (@@Fetch_Status = 0)
				BEGIN
					
					SELECT @GoodsPrice = [sal].[funGetGoodsAmountSaleType] (@GoodsID,@StoreID,@DocDate,@SaleTypeID,@LanguageID,0,0)

					IF @GoodsPrice > 0 
						BEGIN
							Close cur_SaleType;
							Deallocate cur_SaleType; 	
							RETURN @GoodsPrice
						END

					Fetch NEXT From cur_SaleType Into @SaleTypeID
				END

			Close cur_SaleType;
			Deallocate cur_SaleType; 	
		END

	RETURN @GoodsPrice
END
GO
