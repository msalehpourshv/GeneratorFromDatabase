USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgGoodsParametersLastUpdate] 
   ON  inv.tblGoodsParameters
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @GoodsParametersID varchar(20)
	

	Declare curGoodsParametersLastUpdate Cursor For 
	Select GoodsParametersID
	From Inserted

	Open curGoodsParametersLastUpdate

	FETCH NEXT FROM curGoodsParametersLastUpdate INTO	@GoodsParametersID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblGoodsParameters
			SET LastUpdate = GETDATE()
			where GoodsParametersID = @GoodsParametersID
	        
				  
			FETCH NEXT FROM curGoodsParametersLastUpdate INTO	@GoodsParametersID
		END
		
	Close curGoodsParametersLastUpdate
	Deallocate curGoodsParametersLastUpdate
    
END
GO
