USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgFarmersLastUpdate] 
   ON  inv.tblFarmers
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @FarmerID varchar(20)
	

	Declare curFarmersLastUpdate Cursor For 
	Select FarmerID
	From Inserted

	Open curFarmersLastUpdate

	FETCH NEXT FROM curFarmersLastUpdate INTO	@FarmerID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblFarmers
			SET LastUpdate = GETDATE()
			where FarmerID = @FarmerID
	        
				  
			FETCH NEXT FROM curFarmersLastUpdate INTO	@FarmerID
		END
		
	Close curFarmersLastUpdate
	Deallocate curFarmersLastUpdate
    
END
GO
