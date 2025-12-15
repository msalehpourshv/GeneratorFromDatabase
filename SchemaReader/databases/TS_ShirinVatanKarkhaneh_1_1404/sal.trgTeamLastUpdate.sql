USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgTeamLastUpdate] 
   ON  sal.tblTeam
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @TeamID varchar(20)
	

	Declare curTeamLastUpdate Cursor For 
	Select TeamID
	From Inserted

	Open curTeamLastUpdate

	FETCH NEXT FROM curTeamLastUpdate INTO	@TeamID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE sal.tblTeam
			SET LastUpdate = GETDATE()
			where TeamID = @TeamID
	        
				  
			FETCH NEXT FROM curTeamLastUpdate INTO	@TeamID
		END
		
	Close curTeamLastUpdate
	Deallocate curTeamLastUpdate
    
END
GO
