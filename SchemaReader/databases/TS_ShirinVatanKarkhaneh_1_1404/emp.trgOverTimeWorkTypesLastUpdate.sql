USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [emp].[trgOverTimeWorkTypesLastUpdate] 
   ON  emp.tblOverTimeWorkTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @OverTimeWorkTypeID varchar(20)
	

	Declare curOverTimeWorkTypesLastUpdate Cursor For 
	Select OverTimeWorkTypeID
	From Inserted

	Open curOverTimeWorkTypesLastUpdate

	FETCH NEXT FROM curOverTimeWorkTypesLastUpdate INTO	@OverTimeWorkTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE emp.tblOverTimeWorkTypes
			SET LastUpdate = GETDATE()
			where OverTimeWorkTypeID = @OverTimeWorkTypeID
	        
				  
			FETCH NEXT FROM curOverTimeWorkTypesLastUpdate INTO	@OverTimeWorkTypeID
		END
		
	Close curOverTimeWorkTypesLastUpdate
	Deallocate curOverTimeWorkTypesLastUpdate
    
END
GO
