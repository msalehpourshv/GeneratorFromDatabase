USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prd].[trgProducersLastUpdate] 
   ON  prd.tblProducers
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ProducerID varchar(20)
	

	Declare curProducersLastUpdate Cursor For 
	Select ProducerID
	From Inserted

	Open curProducersLastUpdate

	FETCH NEXT FROM curProducersLastUpdate INTO	@ProducerID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prd.tblProducers
			SET LastUpdate = GETDATE()
			where ProducerID = @ProducerID
	        
				  
			FETCH NEXT FROM curProducersLastUpdate INTO	@ProducerID
		END
		
	Close curProducersLastUpdate
	Deallocate curProducersLastUpdate
    
END
GO
