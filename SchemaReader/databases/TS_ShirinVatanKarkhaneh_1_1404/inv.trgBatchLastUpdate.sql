USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgBatchLastUpdate] 
   ON  inv.tblBatch
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @BatchNo varchar(20)
	

	Declare curBatchLastUpdate Cursor For 
	Select BatchNo
	From Inserted

	Open curBatchLastUpdate

	FETCH NEXT FROM curBatchLastUpdate INTO	@BatchNo


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblBatch
			SET LastUpdate = GETDATE()
			where BatchNo = @BatchNo
	        
				  
			FETCH NEXT FROM curBatchLastUpdate INTO	@BatchNo
		END
		
	Close curBatchLastUpdate
	Deallocate curBatchLastUpdate
    
END
GO
