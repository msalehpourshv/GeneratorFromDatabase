USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sal].[funGetRialsCalculation] 
(
	@GoodsID				Varchar(20),
	@StoreID				Varchar(20),
	@DocDate				Char(10),
	@BasePriceTypeID		TinyInt,
	@RoundableDigitsInPrice TinyInt,
	@AddendAmountToPrice Float,
	@AddendPercentToPrice Tinyint

)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	
	DECLARE @Amount Float
	DECLARE @GoodsAmount Float
	DECLARE @GoodsQuantity Float
	
	SET @Amount = 0
	
	--------------------------------------------------
	IF @BasePriceTypeID =1
		SELECT TOP 1 @Amount=GoodsAmount
		From inv.tblStorageDocsDtl
		Where	GoodsID=@GoodsID  AND 
				DocDate<=@DocDate AND
				EnterKind = 1	
		ORDER BY DocDate Desc,VolumeRowNo Desc	

	--------------------------------------------------
	ELSE IF @BasePriceTypeID =2
		IF @StoreID <> ''
			SELECT TOP 1 @Amount=GoodsAmount
			From inv.tblStorageDocsDtl
			Where	GoodsID=@GoodsID  AND 
					StoreID=@StoreID  AND
					DocDate<=@DocDate AND
					EnterKind = 1	
			ORDER BY DocDate Desc,VolumeRowNo Desc	
		ELSE
			SET @Amount = 0

	--------------------------------------------------
	ELSE IF @BasePriceTypeID =3
	BEGIN
		SELECT @GoodsAmount=SUM(GoodsAmount*GoodsQuantity), @GoodsQuantity=SUM(GoodsQuantity)
		From inv.tblStorageDocsDtl
		Where	GoodsID=@GoodsID  AND 
				DocDate<=@DocDate AND
				EnterKind = 1	

		SET @Amount = @GoodsAmount / @GoodsQuantity
	END
	
	--------------------------------------------------
	ELSE IF @BasePriceTypeID = 4
	BEGIN
		IF @StoreID <> ''
			BEGIN 
				SELECT @GoodsAmount=SUM(GoodsAmount*GoodsQuantity), @GoodsQuantity=SUM(GoodsQuantity)
				From inv.tblStorageDocsDtl
				Where	GoodsID=@GoodsID  AND 
						StoreID=@StoreID  AND
						DocDate<=@DocDate AND
						EnterKind = 1	

				SET @Amount = @GoodsAmount / @GoodsQuantity
			END
			
		ELSE
			SET @Amount = 0
		
	END
	
	--------------------------------------------------
	ELSE IF @BasePriceTypeID =5
		SELECT TOP 1 @Amount=GoodsAmount
		From inv.tblStorageDocsDtl
		Where	GoodsID=@GoodsID  AND 
				DocDate<=@DocDate AND
				EnterKind = 1	
		ORDER BY DocDate Desc,VolumeRowNo Desc	

	--------------------------------------------------
	ELSE IF @BasePriceTypeID =6
		IF @StoreID <> ''
			SELECT TOP 1 @Amount=GoodsAmount
			From inv.tblStorageDocsDtl
			Where	GoodsID=@GoodsID  AND 
					StoreID=@StoreID  AND
					DocDate<=@DocDate AND
					EnterKind = 1	
			ORDER BY DocDate Desc,VolumeRowNo Desc		
		ELSE
			SET @Amount = 0
		
	--------------------------------------------------
	IF @Amount > 0	
		SET @Amount = (@Amount + @AddendAmountToPrice) + ((@Amount + @AddendAmountToPrice) * @AddendPercentToPrice) / 100
	
	--------------------------------------------------
	RETURN @Amount 

END
GO
