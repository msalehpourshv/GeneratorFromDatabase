USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgContainerPosInStoresLastUpdate] 
   ON  inv.tblContainerPosInStores
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ContainerStoresID varchar(20)
	

	Declare curContainerStoresIDLastUpdate Cursor For 
	Select ContainerStoresID
	From Inserted

	Open curContainerStoresIDLastUpdate

	FETCH NEXT FROM curContainerStoresIDLastUpdate INTO	@ContainerStoresID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblContainerPosInStores
			SET LastUpdate = GETDATE()
			where ContainerStoresID = @ContainerStoresID
	        
				  
			FETCH NEXT FROM curContainerStoresIDLastUpdate INTO	@ContainerStoresID
		END
		
	Close curContainerStoresIDLastUpdate
	Deallocate curContainerStoresIDLastUpdate
    
END
GO
