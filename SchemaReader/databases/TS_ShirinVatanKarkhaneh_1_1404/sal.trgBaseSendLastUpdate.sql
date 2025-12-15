USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgBaseSendLastUpdate] 
   ON  sal.tblBaseSend
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @BaseSendID varchar(20)
	

	Declare curBaseSendLastUpdate Cursor For 
	Select BaseSendID
	From Inserted

	Open curBaseSendLastUpdate

	FETCH NEXT FROM curBaseSendLastUpdate INTO	@BaseSendID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE sal.tblBaseSend
			SET LastUpdate = GETDATE()
			where BaseSendID = @BaseSendID
	        
				  
			FETCH NEXT FROM curBaseSendLastUpdate INTO	@BaseSendID
		END
		
	Close curBaseSendLastUpdate
	Deallocate curBaseSendLastUpdate
    
END
GO
