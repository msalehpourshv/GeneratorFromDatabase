USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgDecreeTypesLastUpdate] 
   ON  prs.tblDecreeTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @DecreeTypeID varchar(20)
	

	Declare curDecreeTypesLastUpdate Cursor For 
	Select DecreeTypeID
	From Inserted

	Open curDecreeTypesLastUpdate

	FETCH NEXT FROM curDecreeTypesLastUpdate INTO	@DecreeTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblDecreeTypes
			SET LastUpdate = GETDATE()
			where DecreeTypeID = @DecreeTypeID
	        
				  
			FETCH NEXT FROM curDecreeTypesLastUpdate INTO	@DecreeTypeID
		END
		
	Close curDecreeTypesLastUpdate
	Deallocate curDecreeTypesLastUpdate
    
END
GO
