USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [acc].[trgServiceCodingLastUpdate] 
   ON  acc.tblServiceCoding
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ServiceID varchar(20)
	DECLARE @PartNumber int

	Declare curServiceCodingLastUpdate Cursor For 
	Select ServiceID,PartNumber
	From Inserted

	Open curServiceCodingLastUpdate

	FETCH NEXT FROM curServiceCodingLastUpdate INTO	@ServiceID,@PartNumber


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE acc.tblServiceCoding
			SET LastUpdate = GETDATE()
			where ServiceID = @ServiceID
	         AND PartNumber = @PartNumber
				  
			FETCH NEXT FROM curServiceCodingLastUpdate INTO	@ServiceID,@PartNumber
		END
		
	Close curServiceCodingLastUpdate
	Deallocate curServiceCodingLastUpdate
    
END
GO
