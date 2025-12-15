USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgCustomerKindsLastUpdate] 
   ON  sal.tblCustomerKinds
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @CustomerKindID varchar(20)
	

	Declare curCustomerKindsLastUpdate Cursor For 
	Select CustomerKindID
	From Inserted

	Open curCustomerKindsLastUpdate

	FETCH NEXT FROM curCustomerKindsLastUpdate INTO	@CustomerKindID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE sal.tblCustomerKinds
			SET LastUpdate = GETDATE()
			where CustomerKindID = @CustomerKindID
	        
				  
			FETCH NEXT FROM curCustomerKindsLastUpdate INTO	@CustomerKindID
		END
		
	Close curCustomerKindsLastUpdate
	Deallocate curCustomerKindsLastUpdate
    
END
GO
