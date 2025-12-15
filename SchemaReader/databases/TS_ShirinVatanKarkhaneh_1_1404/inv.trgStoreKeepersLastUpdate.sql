USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgStoreKeepersLastUpdate] 
   ON  inv.tblStoreKeepers
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @StoreKeeperID varchar(20)
	

	Declare curStoreKeepersLastUpdate Cursor For 
	Select StoreKeeperID
	From Inserted

	Open curStoreKeepersLastUpdate

	FETCH NEXT FROM curStoreKeepersLastUpdate INTO	@StoreKeeperID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblStoreKeepers
			SET LastUpdate = GETDATE()
			where StoreKeeperID = @StoreKeeperID
	        
				  
			FETCH NEXT FROM curStoreKeepersLastUpdate INTO	@StoreKeeperID
		END
		
	Close curStoreKeepersLastUpdate
	Deallocate curStoreKeepersLastUpdate
    
END
GO
