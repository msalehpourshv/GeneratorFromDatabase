USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [emp].[trgCardReadersLastUpdate] 
   ON  emp.tblCardReaders
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @CardReaderID varchar(20)
	

	Declare curCardReadersLastUpdate Cursor For 
	Select CardReaderID
	From Inserted

	Open curCardReadersLastUpdate

	FETCH NEXT FROM curCardReadersLastUpdate INTO	@CardReaderID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE emp.tblCardReaders
			SET LastUpdate = GETDATE()
			where CardReaderID = @CardReaderID
	        
				  
			FETCH NEXT FROM curCardReadersLastUpdate INTO	@CardReaderID
		END
		
	Close curCardReadersLastUpdate
	Deallocate curCardReadersLastUpdate
    
END
GO
