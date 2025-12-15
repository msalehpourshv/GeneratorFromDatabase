USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [ast].[trgLocatesLastUpdate] 
   ON  ast.tblLocates
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @LocateID varchar(20)
	

	Declare curLocatesLastUpdate Cursor For 
	Select LocateID
	From Inserted

	Open curLocatesLastUpdate

	FETCH NEXT FROM curLocatesLastUpdate INTO	@LocateID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE ast.tblLocates
			SET LastUpdate = GETDATE()
			where LocateID = @LocateID
	        
				  
			FETCH NEXT FROM curLocatesLastUpdate INTO	@LocateID
		END
		
	Close curLocatesLastUpdate
	Deallocate curLocatesLastUpdate
    
END
GO
