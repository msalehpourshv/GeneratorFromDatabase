USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgDepartmentsLastUpdate] 
   ON  prs.tblDepartments
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @DepartmentID varchar(20)
	

	Declare curDepartmentsLastUpdate Cursor For 
	Select DepartmentID
	From Inserted

	Open curDepartmentsLastUpdate

	FETCH NEXT FROM curDepartmentsLastUpdate INTO	@DepartmentID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblDepartments
			SET LastUpdate = GETDATE()
			where DepartmentID = @DepartmentID
	        
				  
			FETCH NEXT FROM curDepartmentsLastUpdate INTO	@DepartmentID
		END
		
	Close curDepartmentsLastUpdate
	Deallocate curDepartmentsLastUpdate
    
END
GO
