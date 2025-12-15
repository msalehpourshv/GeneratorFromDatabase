USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgStudiesLastUpdate] 
   ON  prs.tblStudies
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @StudyID varchar(20)
	

	Declare curStudiesLastUpdate Cursor For 
	Select StudyID
	From Inserted

	Open curStudiesLastUpdate

	FETCH NEXT FROM curStudiesLastUpdate INTO	@StudyID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblStudies
			SET LastUpdate = GETDATE()
			where StudyID = @StudyID
	        
				  
			FETCH NEXT FROM curStudiesLastUpdate INTO	@StudyID
		END
		
	Close curStudiesLastUpdate
	Deallocate curStudiesLastUpdate
    
END
GO
