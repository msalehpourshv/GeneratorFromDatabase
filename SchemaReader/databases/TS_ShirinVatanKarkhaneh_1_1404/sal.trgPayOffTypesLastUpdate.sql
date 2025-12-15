USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgPayOffTypesLastUpdate] 
   ON  sal.tblPayOffTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @PayOffTypeID varchar(20)
	

	Declare curPayOffTypesLastUpdate Cursor For 
	Select PayOffTypeID
	From Inserted

	Open curPayOffTypesLastUpdate

	FETCH NEXT FROM curPayOffTypesLastUpdate INTO	@PayOffTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE sal.tblPayOffTypes
			SET LastUpdate = GETDATE()
			where PayOffTypeID = @PayOffTypeID
	        
				  
			FETCH NEXT FROM curPayOffTypesLastUpdate INTO	@PayOffTypeID
		END
		
	Close curPayOffTypesLastUpdate
	Deallocate curPayOffTypesLastUpdate
    
END
GO
