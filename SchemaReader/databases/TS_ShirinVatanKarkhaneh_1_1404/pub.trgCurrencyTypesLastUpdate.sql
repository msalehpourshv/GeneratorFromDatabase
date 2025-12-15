USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pub].[trgCurrencyTypesLastUpdate] 
   ON  pub.tblCurrencyTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @CurrencyTypeID varchar(20)
	

	Declare curCurrencyTypesLastUpdate Cursor For 
	Select CurrencyTypeID
	From Inserted

	Open curCurrencyTypesLastUpdate

	FETCH NEXT FROM curCurrencyTypesLastUpdate INTO	@CurrencyTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pub.tblCurrencyTypes
			SET LastUpdate = GETDATE()
			where CurrencyTypeID = @CurrencyTypeID
	        
				  
			FETCH NEXT FROM curCurrencyTypesLastUpdate INTO	@CurrencyTypeID
		END
		
	Close curCurrencyTypesLastUpdate
	Deallocate curCurrencyTypesLastUpdate
    
END
GO
