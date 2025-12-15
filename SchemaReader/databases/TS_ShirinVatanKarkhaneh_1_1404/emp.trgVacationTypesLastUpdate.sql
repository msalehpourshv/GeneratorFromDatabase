USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [emp].[trgVacationTypesLastUpdate] 
   ON  emp.tblVacationTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @VacationTypeID varchar(20)
	

	Declare curVacationTypesLastUpdate Cursor For 
	Select VacationTypeID
	From Inserted

	Open curVacationTypesLastUpdate

	FETCH NEXT FROM curVacationTypesLastUpdate INTO	@VacationTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE emp.tblVacationTypes
			SET LastUpdate = GETDATE()
			where VacationTypeID = @VacationTypeID
	        
				  
			FETCH NEXT FROM curVacationTypesLastUpdate INTO	@VacationTypeID
		END
		
	Close curVacationTypesLastUpdate
	Deallocate curVacationTypesLastUpdate
    
END
GO
