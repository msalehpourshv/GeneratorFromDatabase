USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pln].[trgMotorTypesLastUpdate] 
   ON  pln.tblMotorTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @MotorTypeID varchar(20)
	

	Declare curMotorTypesLastUpdate Cursor For 
	Select MotorTypeID
	From Inserted

	Open curMotorTypesLastUpdate

	FETCH NEXT FROM curMotorTypesLastUpdate INTO	@MotorTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pln.tblMotorTypes
			SET LastUpdate = GETDATE()
			where MotorTypeID = @MotorTypeID
	        
				  
			FETCH NEXT FROM curMotorTypesLastUpdate INTO	@MotorTypeID
		END
		
	Close curMotorTypesLastUpdate
	Deallocate curMotorTypesLastUpdate
    
END
GO
