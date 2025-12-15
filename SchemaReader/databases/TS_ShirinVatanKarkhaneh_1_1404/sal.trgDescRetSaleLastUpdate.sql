USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgDescRetSaleLastUpdate] 
   ON  sal.tblDescRetSale
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @DescRetSaleID varchar(20)
	

	Declare curDescRetSaleLastUpdate Cursor For 
	Select DescRetSaleID
	From Inserted

	Open curDescRetSaleLastUpdate

	FETCH NEXT FROM curDescRetSaleLastUpdate INTO	@DescRetSaleID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE sal.tblDescRetSale
			SET LastUpdate = GETDATE()
			where DescRetSaleID = @DescRetSaleID
	        
				  
			FETCH NEXT FROM curDescRetSaleLastUpdate INTO	@DescRetSaleID
		END
		
	Close curDescRetSaleLastUpdate
	Deallocate curDescRetSaleLastUpdate
    
END
GO
