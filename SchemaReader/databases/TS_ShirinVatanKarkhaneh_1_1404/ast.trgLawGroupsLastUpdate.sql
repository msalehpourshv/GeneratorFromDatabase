USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [ast].[trgLawGroupsLastUpdate] 
   ON  ast.tblLawGroups
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @LawGroupID varchar(20)
	

	Declare curLawGroupsLastUpdate Cursor For 
	Select LawGroupID
	From Inserted

	Open curLawGroupsLastUpdate

	FETCH NEXT FROM curLawGroupsLastUpdate INTO	@LawGroupID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE ast.tblLawGroups
			SET LastUpdate = GETDATE()
			where LawGroupID = @LawGroupID
	        
				  
			FETCH NEXT FROM curLawGroupsLastUpdate INTO	@LawGroupID
		END
		
	Close curLawGroupsLastUpdate
	Deallocate curLawGroupsLastUpdate
    
END
GO
