USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgTransportersLastUpdate] 
   ON  sal.tblTransporters
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @TransporterID varchar(20)
	

	Declare curTransportersLastUpdate Cursor For 
	Select TransporterID
	From Inserted

	Open curTransportersLastUpdate

	FETCH NEXT FROM curTransportersLastUpdate INTO	@TransporterID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE sal.tblTransporters
			SET LastUpdate = GETDATE()
			where TransporterID = @TransporterID
	        
				  
			FETCH NEXT FROM curTransportersLastUpdate INTO	@TransporterID
		END
		
	Close curTransportersLastUpdate
	Deallocate curTransportersLastUpdate
    
END
GO
