USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [emp].[trgMissionPlacesLastUpdate] 
   ON  emp.tblMissionPlaces
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @MissionPlaceID varchar(20)
	

	Declare curMissionPlacesLastUpdate Cursor For 
	Select MissionPlaceID
	From Inserted

	Open curMissionPlacesLastUpdate

	FETCH NEXT FROM curMissionPlacesLastUpdate INTO	@MissionPlaceID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE emp.tblMissionPlaces
			SET LastUpdate = GETDATE()
			where MissionPlaceID = @MissionPlaceID
	        
				  
			FETCH NEXT FROM curMissionPlacesLastUpdate INTO	@MissionPlaceID
		END
		
	Close curMissionPlacesLastUpdate
	Deallocate curMissionPlacesLastUpdate
    
END
GO
