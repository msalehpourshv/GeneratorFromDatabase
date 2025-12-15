USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgStudyFieldsLastUpdate] 
   ON  prs.tblStudyFields
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @FieldID varchar(20)
	

	Declare curStudyFieldsLastUpdate Cursor For 
	Select FieldID
	From Inserted

	Open curStudyFieldsLastUpdate

	FETCH NEXT FROM curStudyFieldsLastUpdate INTO	@FieldID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblStudyFields
			SET LastUpdate = GETDATE()
			where FieldID = @FieldID
	        
				  
			FETCH NEXT FROM curStudyFieldsLastUpdate INTO	@FieldID
		END
		
	Close curStudyFieldsLastUpdate
	Deallocate curStudyFieldsLastUpdate
    
END
GO
