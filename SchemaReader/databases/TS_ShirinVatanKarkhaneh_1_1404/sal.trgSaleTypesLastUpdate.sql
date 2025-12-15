USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgSaleTypesLastUpdate] 
   ON  sal.tblSaleTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @SaleTypeID varchar(20)
	

	Declare curSaleTypesLastUpdate Cursor For 
	Select SaleTypeID
	From Inserted

	Open curSaleTypesLastUpdate

	FETCH NEXT FROM curSaleTypesLastUpdate INTO	@SaleTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE sal.tblSaleTypes
			SET LastUpdate = GETDATE()
			where SaleTypeID = @SaleTypeID
	        
				  
			FETCH NEXT FROM curSaleTypesLastUpdate INTO	@SaleTypeID
		END
		
	Close curSaleTypesLastUpdate
	Deallocate curSaleTypesLastUpdate
    
END
GO
