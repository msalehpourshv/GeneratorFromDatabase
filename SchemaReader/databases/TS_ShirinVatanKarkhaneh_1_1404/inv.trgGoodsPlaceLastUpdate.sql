USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgGoodsPlaceLastUpdate] 
   ON  inv.tblGoodsPlace
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @GoodsPlaceID varchar(20)
	

	Declare curGoodsPlaceLastUpdate Cursor For 
	Select GoodsPlaceID
	From Inserted

	Open curGoodsPlaceLastUpdate

	FETCH NEXT FROM curGoodsPlaceLastUpdate INTO	@GoodsPlaceID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblGoodsPlace
			SET LastUpdate = GETDATE()
			where GoodsPlaceID = @GoodsPlaceID
	        
				  
			FETCH NEXT FROM curGoodsPlaceLastUpdate INTO	@GoodsPlaceID
		END
		
	Close curGoodsPlaceLastUpdate
	Deallocate curGoodsPlaceLastUpdate
    
END
GO
