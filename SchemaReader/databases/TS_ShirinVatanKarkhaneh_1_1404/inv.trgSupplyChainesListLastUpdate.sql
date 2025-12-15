USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgSupplyChainesListLastUpdate] 
   ON  inv.tblSupplyChainesList
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @SupplyChainID varchar(20)
	

	Declare curSupplyChainesListLastUpdate Cursor For 
	Select SupplyChainID
	From Inserted

	Open curSupplyChainesListLastUpdate

	FETCH NEXT FROM curSupplyChainesListLastUpdate INTO	@SupplyChainID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblSupplyChainesList
			SET LastUpdate = GETDATE()
			where SupplyChainID = @SupplyChainID
	        
				  
			FETCH NEXT FROM curSupplyChainesListLastUpdate INTO	@SupplyChainID
		END
		
	Close curSupplyChainesListLastUpdate
	Deallocate curSupplyChainesListLastUpdate
    
END
GO
