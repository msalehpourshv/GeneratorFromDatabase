USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pub].[trgLocationsLastUpdate] 
   ON  pub.tblLocations
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @LocationID varchar(20)
	

	Declare curLocationsLastUpdate Cursor For 
	Select LocationID
	From Inserted

	Open curLocationsLastUpdate

	FETCH NEXT FROM curLocationsLastUpdate INTO	@LocationID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pub.tblLocations
			SET LastUpdate = GETDATE()
			where LocationID = @LocationID
	        
				  
			FETCH NEXT FROM curLocationsLastUpdate INTO	@LocationID
		END
		
	Close curLocationsLastUpdate
	Deallocate curLocationsLastUpdate
    
END
GO
