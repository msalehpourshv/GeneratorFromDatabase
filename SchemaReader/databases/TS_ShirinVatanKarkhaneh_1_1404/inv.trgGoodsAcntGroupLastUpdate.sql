USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgGoodsAcntGroupLastUpdate] 
   ON  inv.tblGoodsAcntGroup
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @GoodsAcntGroupID varchar(20)
	

	Declare curGoodsAcntGroupLastUpdate Cursor For 
	Select GoodsAcntGroupID
	From Inserted

	Open curGoodsAcntGroupLastUpdate

	FETCH NEXT FROM curGoodsAcntGroupLastUpdate INTO	@GoodsAcntGroupID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblGoodsAcntGroup
			SET LastUpdate = GETDATE()
			where GoodsAcntGroupID = @GoodsAcntGroupID
	        
				  
			FETCH NEXT FROM curGoodsAcntGroupLastUpdate INTO	@GoodsAcntGroupID
		END
		
	Close curGoodsAcntGroupLastUpdate
	Deallocate curGoodsAcntGroupLastUpdate
    
END
GO
