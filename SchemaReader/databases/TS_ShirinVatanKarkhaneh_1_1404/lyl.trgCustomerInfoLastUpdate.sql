USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [lyl].[trgCustomerInfoLastUpdate] 
   ON  lyl.tblCustomerInfo
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @CustomerInfoID varchar(20)
	

	Declare curCustomerInfoLastUpdate Cursor For 
	Select CustomerInfoID
	From Inserted

	Open curCustomerInfoLastUpdate

	FETCH NEXT FROM curCustomerInfoLastUpdate INTO	@CustomerInfoID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE lyl.tblCustomerInfo
			SET LastUpdate = GETDATE()
			where CustomerInfoID = @CustomerInfoID
	        
				  
			FETCH NEXT FROM curCustomerInfoLastUpdate INTO	@CustomerInfoID
		END
		
	Close curCustomerInfoLastUpdate
	Deallocate curCustomerInfoLastUpdate
    
END
GO
