USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [emp].[trgShiftsLastUpdate] 
   ON  emp.tblShifts
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ShiftID varchar(20)
	

	Declare curShiftsLastUpdate Cursor For 
	Select ShiftID
	From Inserted

	Open curShiftsLastUpdate

	FETCH NEXT FROM curShiftsLastUpdate INTO	@ShiftID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE emp.tblShifts
			SET LastUpdate = GETDATE()
			where ShiftID = @ShiftID
	        
				  
			FETCH NEXT FROM curShiftsLastUpdate INTO	@ShiftID
		END
		
	Close curShiftsLastUpdate
	Deallocate curShiftsLastUpdate
    
END
GO
