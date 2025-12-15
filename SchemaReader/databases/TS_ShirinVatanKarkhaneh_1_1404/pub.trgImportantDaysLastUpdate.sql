USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pub].[trgImportantDaysLastUpdate] 
   ON  pub.tblImportantDays
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ImportantDayID varchar(20)
	

	Declare curImportantDaysLastUpdate Cursor For 
	Select ImportantDayID
	From Inserted

	Open curImportantDaysLastUpdate

	FETCH NEXT FROM curImportantDaysLastUpdate INTO	@ImportantDayID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pub.tblImportantDays
			SET LastUpdate = GETDATE()
			where ImportantDayID = @ImportantDayID
	        
				  
			FETCH NEXT FROM curImportantDaysLastUpdate INTO	@ImportantDayID
		END
		
	Close curImportantDaysLastUpdate
	Deallocate curImportantDaysLastUpdate
    
END
GO
