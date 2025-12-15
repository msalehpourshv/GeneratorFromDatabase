USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgJobsLastUpdate] 
   ON  prs.tblJobs
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @JobID varchar(20)
	

	Declare curJobsLastUpdate Cursor For 
	Select JobID
	From Inserted

	Open curJobsLastUpdate

	FETCH NEXT FROM curJobsLastUpdate INTO	@JobID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblJobs
			SET LastUpdate = GETDATE()
			where JobID = @JobID
	        
				  
			FETCH NEXT FROM curJobsLastUpdate INTO	@JobID
		END
		
	Close curJobsLastUpdate
	Deallocate curJobsLastUpdate
    
END
GO
