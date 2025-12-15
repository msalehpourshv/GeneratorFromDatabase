USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pln].[trgProductionLinesLastUpdate] 
   ON  pln.tblProductionLines
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ProductionLineID varchar(20)
	

	Declare curProductionLinesLastUpdate Cursor For 
	Select ProductionLineID
	From Inserted

	Open curProductionLinesLastUpdate

	FETCH NEXT FROM curProductionLinesLastUpdate INTO	@ProductionLineID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pln.tblProductionLines
			SET LastUpdate = GETDATE()
			where ProductionLineID = @ProductionLineID
	        
				  
			FETCH NEXT FROM curProductionLinesLastUpdate INTO	@ProductionLineID
		END
		
	Close curProductionLinesLastUpdate
	Deallocate curProductionLinesLastUpdate
    
END
GO
