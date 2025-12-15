USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgPackLastUpdate] 
   ON  sal.tblPack
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @PackID varchar(20)
	

	Declare curPackLastUpdate Cursor For 
	Select PackID
	From Inserted

	Open curPackLastUpdate

	FETCH NEXT FROM curPackLastUpdate INTO	@PackID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE sal.tblPack
			SET LastUpdate = GETDATE()
			where PackID = @PackID
	        
				  
			FETCH NEXT FROM curPackLastUpdate INTO	@PackID
		END
		
	Close curPackLastUpdate
	Deallocate curPackLastUpdate
    
END
GO
