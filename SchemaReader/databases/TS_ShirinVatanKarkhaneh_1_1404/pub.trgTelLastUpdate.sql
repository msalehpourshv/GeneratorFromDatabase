USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pub].[trgTelLastUpdate] 
   ON  pub.tblTel
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @TelID varchar(20)
	

	Declare curTelLastUpdate Cursor For 
	Select TelID
	From Inserted

	Open curTelLastUpdate

	FETCH NEXT FROM curTelLastUpdate INTO	@TelID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pub.tblTel
			SET LastUpdate = GETDATE()
			where TelID = @TelID
	        
				  
			FETCH NEXT FROM curTelLastUpdate INTO	@TelID
		END
		
	Close curTelLastUpdate
	Deallocate curTelLastUpdate
    
END
GO
