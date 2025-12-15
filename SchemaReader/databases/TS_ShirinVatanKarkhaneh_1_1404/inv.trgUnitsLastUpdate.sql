USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgUnitsLastUpdate] 
   ON  inv.tblUnits
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @UnitID varchar(20)
	

	Declare curUnitsLastUpdate Cursor For 
	Select UnitID
	From Inserted

	Open curUnitsLastUpdate

	FETCH NEXT FROM curUnitsLastUpdate INTO	@UnitID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblUnits
			SET LastUpdate = GETDATE()
			where UnitID = @UnitID
	        
				  
			FETCH NEXT FROM curUnitsLastUpdate INTO	@UnitID
		END
		
	Close curUnitsLastUpdate
	Deallocate curUnitsLastUpdate
    
END
GO
