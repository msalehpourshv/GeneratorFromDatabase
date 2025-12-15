USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgGoodsLastUpdate] 
   ON  inv.tblGoods
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @GoodsID varchar(20)
	DECLARE @PartNumber int

	Declare curGoodsLastUpdate Cursor For 
	Select GoodsID,PartNumber
	From Inserted

	Open curGoodsLastUpdate

	FETCH NEXT FROM curGoodsLastUpdate INTO	@GoodsID,@PartNumber


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblGoods
			SET LastUpdate = GETDATE()
			where GoodsID = @GoodsID
	         AND PartNumber = @PartNumber
				  
			FETCH NEXT FROM curGoodsLastUpdate INTO	@GoodsID,@PartNumber
		END
		
	Close curGoodsLastUpdate
	Deallocate curGoodsLastUpdate
    
END
GO
