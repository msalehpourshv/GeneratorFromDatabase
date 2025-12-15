USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [emp].[trgPeriodWorksLastUpdate] 
   ON  emp.tblPeriodWorks
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @PeriodWorkID varchar(20)
	

	Declare curPeriodWorksLastUpdate Cursor For 
	Select PeriodWorkID
	From Inserted

	Open curPeriodWorksLastUpdate

	FETCH NEXT FROM curPeriodWorksLastUpdate INTO	@PeriodWorkID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE emp.tblPeriodWorks
			SET LastUpdate = GETDATE()
			where PeriodWorkID = @PeriodWorkID
	        
				  
			FETCH NEXT FROM curPeriodWorksLastUpdate INTO	@PeriodWorkID
		END
		
	Close curPeriodWorksLastUpdate
	Deallocate curPeriodWorksLastUpdate
    
END
GO
