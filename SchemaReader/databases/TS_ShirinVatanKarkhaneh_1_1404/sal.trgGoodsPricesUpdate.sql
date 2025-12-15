USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER  [sal].[trgGoodsPricesUpdate]
   ON  [sal].[tblGoodsPricesDtl]
   WITH ENCRYPTION
   AFTER UPDATE
AS 

BEGIN
	DECLARE @OldSalePrice	float,	
	        @NewSalePrice	Float,
	        @OldUserPrice	Float,
	        @NewUserPrice	Float,
	        @OldGoodsID varchar(20),
	        @NewGoodsID varchar(20),
	        @NewSalePriceTypeID varchar(20),
	        @OldSalePriceTypeID varchar(20),
	        @NewSaleTypeID varchar(20),
	        @OldSaleTypeID varchar(20),
	        @OldRowNo int,
	        @NewRowNo int,
	        @OldUserPriceID int,
	        @NewUserPriceID int,
			@PriceDate char(10),
			@NewIsGroupCode Bit,
			@OldIsGroupCode Bit

	SELECT  @PriceDate = pub.funChangeDate_GergorianToPersian(getdate())
	       
	DECLARE curGoodsPricesInserted Cursor  For 
	SELECT	GoodsID,RowNo,IsGroupCode,SalePriceTypeID,SaleTypeID,UserPriceID,SalePrice,UserPrice
	FROM	Inserted

	DECLARE curGoodsPricesDeleted Cursor  For 
	SELECT	GoodsID,RowNo,IsGroupCode,SalePriceTypeID,SaleTypeID,UserPriceID,SalePrice,UserPrice
	FROM	Deleted

	OPEN curGoodsPricesInserted
	OPEN curGoodsPricesDeleted
	
	FETCH NEXT FROM curGoodsPricesInserted INTO	
		 @NewGoodsID,@NewRowNo,@NewIsGroupCode,@NewSalePriceTypeID,@NewSaleTypeID,@NewUserPriceID,@NewSalePrice,@NewUserPrice


	WHILE @@FETCH_STATUS = 0
		BEGIN 
			FETCH NEXT FROM curGoodsPricesDeleted INTO	
		 @OldGoodsID,@OldRowNo,@OldIsGroupCode,@OldSalePriceTypeID,@OldSaleTypeID,@OldUserPriceID,@OldSalePrice,@OldUserPrice

			IF	@NewGoodsID <> @OldGoodsID OR @NewRowNo <> @OldRowNo OR 
			    @NewSalePriceTypeID <> @OldSalePriceTypeID OR @NewSaleTypeID<>@OldSaleTypeID OR 
			    @NewUserPriceID <> @OldUserPriceID OR @NewSalePrice<>@OldSalePrice OR @NewUserPrice<>@OldUserPrice 
			BEGIN
				UPDATE sal.tblGoodsPricesDtl
				SET PriceDate = @PriceDate
				where GoodsID = @NewGoodsID and
					  RowNo   = @NewRowNo	and
					  IsGroupCode  = @NewIsGroupCode	

				UPDATE inv.tblGoods
				SET LastUpdate = GETDATE()
				where SUBSTRING(GoodsID,1,len(@NewGoodsID)) = @NewGoodsID 

			END  
			    
			FETCH NEXT FROM curGoodsPricesInserted INTO	
		 @NewGoodsID,@NewRowNo,@NewIsGroupCode,@NewSalePriceTypeID,@NewSaleTypeID,@NewUserPriceID,@NewSalePrice,@NewUserPrice


		END   

	Close curGoodsPricesInserted
	Deallocate curGoodsPricesInserted

	Close curGoodsPricesDeleted
	Deallocate curGoodsPricesDeleted
    
END
GO
