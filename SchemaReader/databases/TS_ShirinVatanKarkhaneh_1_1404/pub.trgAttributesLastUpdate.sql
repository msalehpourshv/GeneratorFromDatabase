USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pub].[trgAttributesLastUpdate] 
   ON  pub.tblAttributes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @AttributeID varchar(20)
	

	Declare curAttributesLastUpdate Cursor For 
	Select AttributeID
	From Inserted

	Open curAttributesLastUpdate

	FETCH NEXT FROM curAttributesLastUpdate INTO	@AttributeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pub.tblAttributes
			SET LastUpdate = GETDATE()
			where AttributeID = @AttributeID
	        
				  
			FETCH NEXT FROM curAttributesLastUpdate INTO	@AttributeID
		END
		
	Close curAttributesLastUpdate
	Deallocate curAttributesLastUpdate
    
END
GO
