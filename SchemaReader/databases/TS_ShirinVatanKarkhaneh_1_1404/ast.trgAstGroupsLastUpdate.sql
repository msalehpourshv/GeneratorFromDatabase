USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [ast].[trgAstGroupsLastUpdate] 
   ON  ast.tblAstGroups
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @AstGroupID varchar(20)
	

	Declare curAstGroupsLastUpdate Cursor For 
	Select AstGroupID
	From Inserted

	Open curAstGroupsLastUpdate

	FETCH NEXT FROM curAstGroupsLastUpdate INTO	@AstGroupID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE ast.tblAstGroups
			SET LastUpdate = GETDATE()
			where AstGroupID = @AstGroupID
	        
				  
			FETCH NEXT FROM curAstGroupsLastUpdate INTO	@AstGroupID
		END
		
	Close curAstGroupsLastUpdate
	Deallocate curAstGroupsLastUpdate
    
END
GO
