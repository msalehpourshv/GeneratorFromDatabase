USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [ast].[trgAstGroupSpecsLastUpdate] 
   ON  ast.tblAstGroupSpecs
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @AstGroupSpecID varchar(20)
	

	Declare curAstGroupSpecsLastUpdate Cursor For 
	Select AstGroupSpecID
	From Inserted

	Open curAstGroupSpecsLastUpdate

	FETCH NEXT FROM curAstGroupSpecsLastUpdate INTO	@AstGroupSpecID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE ast.tblAstGroupSpecs
			SET LastUpdate = GETDATE()
			where AstGroupSpecID = @AstGroupSpecID
	        
				  
			FETCH NEXT FROM curAstGroupSpecsLastUpdate INTO	@AstGroupSpecID
		END
		
	Close curAstGroupSpecsLastUpdate
	Deallocate curAstGroupSpecsLastUpdate
    
END
GO
