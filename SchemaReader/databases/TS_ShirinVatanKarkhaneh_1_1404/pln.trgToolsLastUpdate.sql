USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pln].[trgToolsLastUpdate] 
   ON  pln.tblTools
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ToolID varchar(20)
	

	Declare curToolsLastUpdate Cursor For 
	Select ToolID
	From Inserted

	Open curToolsLastUpdate

	FETCH NEXT FROM curToolsLastUpdate INTO	@ToolID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pln.tblTools
			SET LastUpdate = GETDATE()
			where ToolID = @ToolID
	        
				  
			FETCH NEXT FROM curToolsLastUpdate INTO	@ToolID
		END
		
	Close curToolsLastUpdate
	Deallocate curToolsLastUpdate
    
END
GO
