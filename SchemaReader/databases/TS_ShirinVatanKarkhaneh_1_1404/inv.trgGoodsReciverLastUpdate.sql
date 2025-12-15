USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgGoodsReciverLastUpdate] 
   ON  inv.tblGoodsReciver
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ReciverID varchar(20)
	

	Declare curGoodsReciverLastUpdate Cursor For 
	Select ReciverID
	From Inserted

	Open curGoodsReciverLastUpdate

	FETCH NEXT FROM curGoodsReciverLastUpdate INTO	@ReciverID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblGoodsReciver
			SET LastUpdate = GETDATE()
			where ReciverID = @ReciverID
	        
				  
			FETCH NEXT FROM curGoodsReciverLastUpdate INTO	@ReciverID
		END
		
	Close curGoodsReciverLastUpdate
	Deallocate curGoodsReciverLastUpdate
    
END
GO
