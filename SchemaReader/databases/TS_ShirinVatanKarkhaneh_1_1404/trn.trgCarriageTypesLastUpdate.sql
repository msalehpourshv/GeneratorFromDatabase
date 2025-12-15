USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [trn].[trgCarriageTypesLastUpdate] 
   ON  trn.tblCarriageTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @CarriageTypeID varchar(20)
	

	Declare curCarriageTypesLastUpdate Cursor For 
	Select CarriageTypeID
	From Inserted

	Open curCarriageTypesLastUpdate

	FETCH NEXT FROM curCarriageTypesLastUpdate INTO	@CarriageTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE trn.tblCarriageTypes
			SET LastUpdate = GETDATE()
			where CarriageTypeID = @CarriageTypeID
	        
				  
			FETCH NEXT FROM curCarriageTypesLastUpdate INTO	@CarriageTypeID
		END
		
	Close curCarriageTypesLastUpdate
	Deallocate curCarriageTypesLastUpdate
    
END
GO
