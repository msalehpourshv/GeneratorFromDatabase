USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pln].[trgSerialStatusLastUpdate] 
   ON  pln.tblSerialStatus
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @SerialStatusID varchar(20)
	

	Declare curSerialStatusLastUpdate Cursor For 
	Select SerialStatusID
	From Inserted

	Open curSerialStatusLastUpdate

	FETCH NEXT FROM curSerialStatusLastUpdate INTO	@SerialStatusID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pln.tblSerialStatus
			SET LastUpdate = GETDATE()
			where SerialStatusID = @SerialStatusID
	        
				  
			FETCH NEXT FROM curSerialStatusLastUpdate INTO	@SerialStatusID
		END
		
	Close curSerialStatusLastUpdate
	Deallocate curSerialStatusLastUpdate
    
END
GO
