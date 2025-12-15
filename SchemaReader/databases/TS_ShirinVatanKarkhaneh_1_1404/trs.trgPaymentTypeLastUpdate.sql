USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [trs].[trgPaymentTypeLastUpdate] 
   ON  trs.tblPaymentType
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @PaymentTypeID varchar(20)
	

	Declare curPaymentTypeLastUpdate Cursor For 
	Select PaymentTypeID
	From Inserted

	Open curPaymentTypeLastUpdate

	FETCH NEXT FROM curPaymentTypeLastUpdate INTO	@PaymentTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE trs.tblPaymentType
			SET LastUpdate = GETDATE()
			where PaymentTypeID = @PaymentTypeID
	        
				  
			FETCH NEXT FROM curPaymentTypeLastUpdate INTO	@PaymentTypeID
		END
		
	Close curPaymentTypeLastUpdate
	Deallocate curPaymentTypeLastUpdate
    
END
GO
