USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [ast].[trgAssetManagersLastUpdate] 
   ON  ast.tblAssetManagers
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @AssetManagerID varchar(20)
	

	Declare curAssetManagersLastUpdate Cursor For 
	Select AssetManagerID
	From Inserted

	Open curAssetManagersLastUpdate

	FETCH NEXT FROM curAssetManagersLastUpdate INTO	@AssetManagerID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE ast.tblAssetManagers
			SET LastUpdate = GETDATE()
			where AssetManagerID = @AssetManagerID
	        
				  
			FETCH NEXT FROM curAssetManagersLastUpdate INTO	@AssetManagerID
		END
		
	Close curAssetManagersLastUpdate
	Deallocate curAssetManagersLastUpdate
    
END
GO
