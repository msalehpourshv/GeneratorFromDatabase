USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pub].[trgLineNumberLastUpdate] 
   ON  pub.tblLineNumber
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @LineID varchar(20)
	

	Declare curLineNumberLastUpdate Cursor For 
	Select LineID
	From Inserted

	Open curLineNumberLastUpdate

	FETCH NEXT FROM curLineNumberLastUpdate INTO	@LineID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pub.tblLineNumber
			SET LastUpdate = GETDATE()
			where LineID = @LineID
	        
				  
			FETCH NEXT FROM curLineNumberLastUpdate INTO	@LineID
		END
		
	Close curLineNumberLastUpdate
	Deallocate curLineNumberLastUpdate
    
END
GO
