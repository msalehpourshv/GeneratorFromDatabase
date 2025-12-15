USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [acc].[trgServiceFaultLastUpdate] 
   ON  acc.tblServiceFault
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ServiceFaultID varchar(20)
	

	Declare curServiceFaultLastUpdate Cursor For 
	Select ServiceFaultID
	From Inserted

	Open curServiceFaultLastUpdate

	FETCH NEXT FROM curServiceFaultLastUpdate INTO	@ServiceFaultID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE acc.tblServiceFault
			SET LastUpdate = GETDATE()
			where ServiceFaultID = @ServiceFaultID
	        
				  
			FETCH NEXT FROM curServiceFaultLastUpdate INTO	@ServiceFaultID
		END
		
	Close curServiceFaultLastUpdate
	Deallocate curServiceFaultLastUpdate
    
END
GO
