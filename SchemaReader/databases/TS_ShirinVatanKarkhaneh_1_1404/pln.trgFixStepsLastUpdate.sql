USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pln].[trgFixStepsLastUpdate] 
   ON  pln.tblFixSteps
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @FixStepID varchar(20)
	

	Declare curFixStepsLastUpdate Cursor For 
	Select FixStepID
	From Inserted

	Open curFixStepsLastUpdate

	FETCH NEXT FROM curFixStepsLastUpdate INTO	@FixStepID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pln.tblFixSteps
			SET LastUpdate = GETDATE()
			where FixStepID = @FixStepID
	        
				  
			FETCH NEXT FROM curFixStepsLastUpdate INTO	@FixStepID
		END
		
	Close curFixStepsLastUpdate
	Deallocate curFixStepsLastUpdate
    
END
GO
