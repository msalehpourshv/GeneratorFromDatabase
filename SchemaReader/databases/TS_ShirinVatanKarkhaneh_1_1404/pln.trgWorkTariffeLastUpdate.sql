USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pln].[trgWorkTariffeLastUpdate] 
   ON  pln.tblWorkTariffe
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @WorkTariffeID varchar(20)
	

	Declare curWorkTariffeLastUpdate Cursor For 
	Select WorkTariffeID
	From Inserted

	Open curWorkTariffeLastUpdate

	FETCH NEXT FROM curWorkTariffeLastUpdate INTO	@WorkTariffeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pln.tblWorkTariffe
			SET LastUpdate = GETDATE()
			where WorkTariffeID = @WorkTariffeID
	        
				  
			FETCH NEXT FROM curWorkTariffeLastUpdate INTO	@WorkTariffeID
		END
		
	Close curWorkTariffeLastUpdate
	Deallocate curWorkTariffeLastUpdate
    
END
GO
