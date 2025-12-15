USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pln].[trgLoseGroupLastUpdate] 
   ON  pln.tblLoseGroup
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @LoseGroupID varchar(20)
	

	Declare curLoseGroupLastUpdate Cursor For 
	Select LoseGroupID
	From Inserted

	Open curLoseGroupLastUpdate

	FETCH NEXT FROM curLoseGroupLastUpdate INTO	@LoseGroupID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pln.tblLoseGroup
			SET LastUpdate = GETDATE()
			where LoseGroupID = @LoseGroupID
	        
				  
			FETCH NEXT FROM curLoseGroupLastUpdate INTO	@LoseGroupID
		END
		
	Close curLoseGroupLastUpdate
	Deallocate curLoseGroupLastUpdate
    
END
GO
