USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgContainerLastUpdate] 
   ON  inv.tblContainer
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ContainerID varchar(20)
	

	Declare curContainerLastUpdate Cursor For 
	Select ContainerID
	From Inserted

	Open curContainerLastUpdate

	FETCH NEXT FROM curContainerLastUpdate INTO	@ContainerID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblContainer
			SET LastUpdate = GETDATE()
			where ContainerID = @ContainerID
	        
				  
			FETCH NEXT FROM curContainerLastUpdate INTO	@ContainerID
		END
		
	Close curContainerLastUpdate
	Deallocate curContainerLastUpdate
    
END
GO
