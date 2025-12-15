USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgBuyTypeLastUpdate] 
   ON  inv.tblBuyType
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @BuyTypeID varchar(20)
	

	Declare curBuyTypeLastUpdate Cursor For 
	Select BuyTypeID
	From Inserted

	Open curBuyTypeLastUpdate

	FETCH NEXT FROM curBuyTypeLastUpdate INTO	@BuyTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblBuyType
			SET LastUpdate = GETDATE()
			where BuyTypeID = @BuyTypeID
	        
				  
			FETCH NEXT FROM curBuyTypeLastUpdate INTO	@BuyTypeID
		END
		
	Close curBuyTypeLastUpdate
	Deallocate curBuyTypeLastUpdate
    
END
GO
