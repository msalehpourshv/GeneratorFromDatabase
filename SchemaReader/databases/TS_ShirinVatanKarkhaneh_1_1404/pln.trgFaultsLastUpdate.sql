USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pln].[trgFaultsLastUpdate] 
   ON  pln.tblFaults
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @FaultID varchar(20)
	

	Declare curFaultsLastUpdate Cursor For 
	Select FaultID
	From Inserted

	Open curFaultsLastUpdate

	FETCH NEXT FROM curFaultsLastUpdate INTO	@FaultID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pln.tblFaults
			SET LastUpdate = GETDATE()
			where FaultID = @FaultID
	        
				  
			FETCH NEXT FROM curFaultsLastUpdate INTO	@FaultID
		END
		
	Close curFaultsLastUpdate
	Deallocate curFaultsLastUpdate
    
END
GO
