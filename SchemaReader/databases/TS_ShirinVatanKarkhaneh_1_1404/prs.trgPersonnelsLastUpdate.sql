USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgPersonnelsLastUpdate] 
   ON  prs.tblPersonnels
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @PersonnelID varchar(20)
	

	Declare curPersonnelsLastUpdate Cursor For 
	Select PersonnelID
	From Inserted

	Open curPersonnelsLastUpdate

	FETCH NEXT FROM curPersonnelsLastUpdate INTO	@PersonnelID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblPersonnels
			SET LastUpdate = GETDATE()
			where PersonnelID = @PersonnelID
	        
				  
			FETCH NEXT FROM curPersonnelsLastUpdate INTO	@PersonnelID
		END
		
	Close curPersonnelsLastUpdate
	Deallocate curPersonnelsLastUpdate
    
END
GO
