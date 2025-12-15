USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [trn].[trgVehiclesLastUpdate] 
   ON  trn.tblVehicles
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @VehicleID varchar(20)
	

	Declare curVehiclesLastUpdate Cursor For 
	Select VehicleID
	From Inserted

	Open curVehiclesLastUpdate

	FETCH NEXT FROM curVehiclesLastUpdate INTO	@VehicleID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE trn.tblVehicles
			SET LastUpdate = GETDATE()
			where VehicleID = @VehicleID
	        
				  
			FETCH NEXT FROM curVehiclesLastUpdate INTO	@VehicleID
		END
		
	Close curVehiclesLastUpdate
	Deallocate curVehiclesLastUpdate
    
END
GO
