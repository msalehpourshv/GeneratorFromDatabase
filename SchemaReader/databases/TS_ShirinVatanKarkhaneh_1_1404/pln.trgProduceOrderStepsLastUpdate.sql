USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pln].[trgProduceOrderStepsLastUpdate] 
   ON  pln.tblProduceOrderSteps
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ProduceStepID varchar(20)
	

	Declare curProduceOrderStepsLastUpdate Cursor For 
	Select ProduceStepID
	From Inserted

	Open curProduceOrderStepsLastUpdate

	FETCH NEXT FROM curProduceOrderStepsLastUpdate INTO	@ProduceStepID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pln.tblProduceOrderSteps
			SET LastUpdate = GETDATE()
			where ProduceStepID = @ProduceStepID
	        
				  
			FETCH NEXT FROM curProduceOrderStepsLastUpdate INTO	@ProduceStepID
		END
		
	Close curProduceOrderStepsLastUpdate
	Deallocate curProduceOrderStepsLastUpdate
    
END
GO
