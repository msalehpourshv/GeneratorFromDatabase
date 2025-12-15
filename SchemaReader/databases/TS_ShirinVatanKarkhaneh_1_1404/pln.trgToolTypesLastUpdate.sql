USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pln].[trgToolTypesLastUpdate] 
   ON  pln.tblToolTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ToolTypeID varchar(20)
	

	Declare curToolTypesLastUpdate Cursor For 
	Select ToolTypeID
	From Inserted

	Open curToolTypesLastUpdate

	FETCH NEXT FROM curToolTypesLastUpdate INTO	@ToolTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pln.tblToolTypes
			SET LastUpdate = GETDATE()
			where ToolTypeID = @ToolTypeID
	        
				  
			FETCH NEXT FROM curToolTypesLastUpdate INTO	@ToolTypeID
		END
		
	Close curToolTypesLastUpdate
	Deallocate curToolTypesLastUpdate
    
END
GO
