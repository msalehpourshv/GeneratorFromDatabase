USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [acc].[trgVoucherGroupCodeLastUpdate] 
   ON  acc.tblVoucherGroupCode
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @VoucherGroupCodeID varchar(20)
	

	Declare curVoucherGroupCodeLastUpdate Cursor For 
	Select VoucherGroupCodeID
	From Inserted

	Open curVoucherGroupCodeLastUpdate

	FETCH NEXT FROM curVoucherGroupCodeLastUpdate INTO	@VoucherGroupCodeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE acc.tblVoucherGroupCode
			SET LastUpdate = GETDATE()
			where VoucherGroupCodeID = @VoucherGroupCodeID
	        
				  
			FETCH NEXT FROM curVoucherGroupCodeLastUpdate INTO	@VoucherGroupCodeID
		END
		
	Close curVoucherGroupCodeLastUpdate
	Deallocate curVoucherGroupCodeLastUpdate
    
END
GO
