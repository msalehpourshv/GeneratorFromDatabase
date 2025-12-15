USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgGoodsClassificationLastUpdate] 
   ON  inv.tblGoodsClassification
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @GoodsClassificationID varchar(20)
	

	Declare curGoodsClassificationLastUpdate Cursor For 
	Select GoodsClassificationID
	From Inserted

	Open curGoodsClassificationLastUpdate

	FETCH NEXT FROM curGoodsClassificationLastUpdate INTO	@GoodsClassificationID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblGoodsClassification
			SET LastUpdate = GETDATE()
			where GoodsClassificationID = @GoodsClassificationID
	        
				  
			FETCH NEXT FROM curGoodsClassificationLastUpdate INTO	@GoodsClassificationID
		END
		
	Close curGoodsClassificationLastUpdate
	Deallocate curGoodsClassificationLastUpdate
    
END
GO
