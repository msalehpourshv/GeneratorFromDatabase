USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [inv].[funGetGoodsRemain_ByInventoryType]
(	
	@ProcessID		TinyInt = NULL,
	@ProcessNo		TinyInt = NULL,
	@FiscalYear		Smallint = NULL,
	@SerialNo		Int = NULL,
	@VolumeRowNo    Int = NULL,
	@InventoryType	TinyInt,
	@GoodsID		Varchar(20),
	@BatchNo		Varchar(20),
	@DocDate		Char(10),
	@UserPriceID    Int = 0
)
RETURNS decimal(38,5)
WITH ENCRYPTION
AS
BEGIN
	
	IF @FiscalYear IS NULL OR @FiscalYear = 0
		SET @FiscalYear = RIGHT(db_name(),4)
		
	DECLARE @QtyRemain Decimal(28,9)
	
	SET @QtyRemain = 0

	IF (SELECT COUNT(GoodsID) FROM inv.tblGoods WHERE GoodsID = @GoodsID and IsService='True') = 1
		RETURN 100000
	
	IF @DocDate = '' OR @GoodsID = ''
	BEGIN 
		RETURN 0
	END
	
	IF @BatchNo = '' OR @BatchNo IS NULL
		BEGIN
			IF @InventoryType IS NULL  
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind),0) 
					FROM   inv.tblStorageDocsDtl
					WHERE  GoodsID = @GoodsID AND DocDate <= @DocDate AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE IF @VolumeRowNo IS NULL
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind),0) 
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID In (Select StoreID From inv.tblStores Where InventoryType = @InventoryType) AND GoodsID = @GoodsID AND DocDate <= @DocDate AND FiscalYear=@FiscalYear  AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind) ,0)
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID In (Select StoreID From inv.tblStores Where InventoryType = @InventoryType) AND GoodsID = @GoodsID  AND 
						 ((DocDate < @DocDate) OR (DocDate = @DocDate AND VolumeRowNo<= @VolumeRowNo))AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
		END
		
	ELSE
		BEGIN
			IF @InventoryType IS NULL  
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind),0) 
					FROM   inv.tblStorageDocsDtl
					WHERE  GoodsID = @GoodsID AND BatchNo = @BatchNo AND DocDate <= @DocDate AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE IF @VolumeRowNo IS NULL
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind),0) 
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID In (Select StoreID From inv.tblStores Where InventoryType = @InventoryType) AND GoodsID = @GoodsID AND BatchNo = @BatchNo AND DocDate <= @DocDate AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
			ELSE
				BEGIN
					SELECT @QtyRemain = IsNull(Sum(GoodsQuantity * EnterKind) ,0)
					FROM   inv.tblStorageDocsDtl
					WHERE  StoreID In (Select StoreID From inv.tblStores Where InventoryType = @InventoryType) AND GoodsID = @GoodsID  AND BatchNo = @BatchNo AND 
						 ((DocDate < @DocDate) OR (DocDate = @DocDate AND VolumeRowNo<= @VolumeRowNo))AND FiscalYear=@FiscalYear AND (@UserPriceID =0 or UserPriceID=@UserPriceID)
				END
		END

	RETURN @QtyRemain 

END
GO
