USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgReceiptOperatorLastUpdate] 
   ON  sal.tblReceiptOperator
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ReceiptOperatorID varchar(20)
	

	Declare curReceiptOperatorLastUpdate Cursor For 
	Select ReceiptOperatorID
	From Inserted

	Open curReceiptOperatorLastUpdate

	FETCH NEXT FROM curReceiptOperatorLastUpdate INTO	@ReceiptOperatorID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE sal.tblReceiptOperator
			SET LastUpdate = GETDATE()
			where ReceiptOperatorID = @ReceiptOperatorID
	        
				  
			FETCH NEXT FROM curReceiptOperatorLastUpdate INTO	@ReceiptOperatorID
		END
		
	Close curReceiptOperatorLastUpdate
	Deallocate curReceiptOperatorLastUpdate
    
END
GO
