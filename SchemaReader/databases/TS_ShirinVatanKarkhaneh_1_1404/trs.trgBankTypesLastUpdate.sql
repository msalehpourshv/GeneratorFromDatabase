USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [trs].[trgBankTypesLastUpdate] 
   ON  trs.tblBankTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @BankTypeID varchar(20)
	

	Declare curBankTypesLastUpdate Cursor For 
	Select BankTypeID
	From Inserted

	Open curBankTypesLastUpdate

	FETCH NEXT FROM curBankTypesLastUpdate INTO	@BankTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE trs.tblBankTypes
			SET LastUpdate = GETDATE()
			where BankTypeID = @BankTypeID
	        
				  
			FETCH NEXT FROM curBankTypesLastUpdate INTO	@BankTypeID
		END
		
	Close curBankTypesLastUpdate
	Deallocate curBankTypesLastUpdate
    
END
GO
