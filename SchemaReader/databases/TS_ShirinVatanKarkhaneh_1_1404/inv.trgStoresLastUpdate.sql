USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgStoresLastUpdate] 
   ON  inv.tblStores
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @StoreID varchar(20)
	

	Declare curStoresLastUpdate Cursor For 
	Select StoreID
	From Inserted

	Open curStoresLastUpdate

	FETCH NEXT FROM curStoresLastUpdate INTO	@StoreID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblStores
			SET LastUpdate = GETDATE()
			where StoreID = @StoreID
	        
				  
			FETCH NEXT FROM curStoresLastUpdate INTO	@StoreID
		END
		
	Close curStoresLastUpdate
	Deallocate curStoresLastUpdate
    
END
GO
