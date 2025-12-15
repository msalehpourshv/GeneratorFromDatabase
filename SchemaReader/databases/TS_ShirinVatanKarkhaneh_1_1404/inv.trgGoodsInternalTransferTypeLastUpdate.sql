USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgGoodsInternalTransferTypeLastUpdate] 
   ON  inv.tblGoodsInternalTransferType
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @IntTrnTypID varchar(20)
	

	Declare curGoodsInternalTransferTypeLastUpdate Cursor For 
	Select IntTrnTypID
	From Inserted

	Open curGoodsInternalTransferTypeLastUpdate

	FETCH NEXT FROM curGoodsInternalTransferTypeLastUpdate INTO	@IntTrnTypID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblGoodsInternalTransferType
			SET LastUpdate = GETDATE()
			where IntTrnTypID = @IntTrnTypID
	        
				  
			FETCH NEXT FROM curGoodsInternalTransferTypeLastUpdate INTO	@IntTrnTypID
		END
		
	Close curGoodsInternalTransferTypeLastUpdate
	Deallocate curGoodsInternalTransferTypeLastUpdate
    
END
GO
