USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [emp].[trgMissionTypesLastUpdate] 
   ON  emp.tblMissionTypes
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @MissionTypeID varchar(20)
	

	Declare curMissionTypesLastUpdate Cursor For 
	Select MissionTypeID
	From Inserted

	Open curMissionTypesLastUpdate

	FETCH NEXT FROM curMissionTypesLastUpdate INTO	@MissionTypeID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE emp.tblMissionTypes
			SET LastUpdate = GETDATE()
			where MissionTypeID = @MissionTypeID
	        
				  
			FETCH NEXT FROM curMissionTypesLastUpdate INTO	@MissionTypeID
		END
		
	Close curMissionTypesLastUpdate
	Deallocate curMissionTypesLastUpdate
    
END
GO
