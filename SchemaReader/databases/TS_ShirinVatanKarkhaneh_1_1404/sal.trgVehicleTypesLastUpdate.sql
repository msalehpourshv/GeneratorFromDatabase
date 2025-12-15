USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgVehicleTypesLastUpdate] 
   ON  sal.tblVehicleTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @VehicleTypeID varchar(20)
	

	Declare curVehicleTypesLastUpdate Cursor For 
	Select VehicleTypeID
	From Inserted

	Open curVehicleTypesLastUpdate

	FETCH NEXT FROM curVehicleTypesLastUpdate INTO	@VehicleTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE sal.tblVehicleTypes
			SET LastUpdate = GETDATE()
			where VehicleTypeID = @VehicleTypeID
	        
				  
			FETCH NEXT FROM curVehicleTypesLastUpdate INTO	@VehicleTypeID
		END
		
	Close curVehicleTypesLastUpdate
	Deallocate curVehicleTypesLastUpdate
    
END
GO
