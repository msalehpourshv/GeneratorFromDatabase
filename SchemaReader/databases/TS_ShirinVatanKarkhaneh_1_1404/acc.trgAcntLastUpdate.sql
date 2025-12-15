USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [acc].[trgAcntLastUpdate] 
   ON  acc.tblAcnt
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @AcntCode varchar(20)
	DECLARE @PartNumber int

	Declare curAcntLastUpdate Cursor For 
	Select AcntCode,PartNumber
	From Inserted

	Open curAcntLastUpdate

	FETCH NEXT FROM curAcntLastUpdate INTO	@AcntCode,@PartNumber


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE acc.tblAcnt
			SET LastUpdate = GETDATE()
			where AcntCode = @AcntCode
	         AND PartNumber = @PartNumber
				  
			FETCH NEXT FROM curAcntLastUpdate INTO	@AcntCode,@PartNumber
		END
		
	Close curAcntLastUpdate
	Deallocate curAcntLastUpdate
    
END
GO
