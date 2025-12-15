USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgGoodsGroupsLastUpdate] 
   ON  inv.tblGoodsGroups
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @GoodsGroupID varchar(20)
	

	Declare curGoodsGroupsLastUpdate Cursor For 
	Select GoodsGroupID
	From Inserted

	Open curGoodsGroupsLastUpdate

	FETCH NEXT FROM curGoodsGroupsLastUpdate INTO	@GoodsGroupID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblGoodsGroups
			SET LastUpdate = GETDATE()
			where GoodsGroupID = @GoodsGroupID
	        
				  
			FETCH NEXT FROM curGoodsGroupsLastUpdate INTO	@GoodsGroupID
		END
		
	Close curGoodsGroupsLastUpdate
	Deallocate curGoodsGroupsLastUpdate
    
END
GO
