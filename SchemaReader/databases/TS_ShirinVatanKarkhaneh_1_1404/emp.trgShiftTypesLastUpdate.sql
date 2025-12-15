USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [emp].[trgShiftTypesLastUpdate] 
   ON  emp.tblShiftTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ShiftTypeID varchar(20)
	

	Declare curShiftTypesLastUpdate Cursor For 
	Select ShiftTypeID
	From Inserted

	Open curShiftTypesLastUpdate

	FETCH NEXT FROM curShiftTypesLastUpdate INTO	@ShiftTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE emp.tblShiftTypes
			SET LastUpdate = GETDATE()
			where ShiftTypeID = @ShiftTypeID
	        
				  
			FETCH NEXT FROM curShiftTypesLastUpdate INTO	@ShiftTypeID
		END
		
	Close curShiftTypesLastUpdate
	Deallocate curShiftTypesLastUpdate
    
END
GO
