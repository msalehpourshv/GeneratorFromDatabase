USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pub].[trgDriversLastUpdate] 
   ON  pub.tblDrivers
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @DriverID varchar(20)
	

	Declare curDriversLastUpdate Cursor For 
	Select DriverID
	From Inserted

	Open curDriversLastUpdate

	FETCH NEXT FROM curDriversLastUpdate INTO	@DriverID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pub.tblDrivers
			SET LastUpdate = GETDATE()
			where DriverID = @DriverID
	        
				  
			FETCH NEXT FROM curDriversLastUpdate INTO	@DriverID
		END
		
	Close curDriversLastUpdate
	Deallocate curDriversLastUpdate
    
END
GO
