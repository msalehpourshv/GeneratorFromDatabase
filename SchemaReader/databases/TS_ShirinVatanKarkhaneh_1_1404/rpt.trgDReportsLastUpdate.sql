USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [rpt].[trgDReportsLastUpdate] 
   ON  rpt.tblDReports
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ReportID varchar(20)
	

	Declare curDReportsLastUpdate Cursor For 
	Select ReportID
	From Inserted

	Open curDReportsLastUpdate

	FETCH NEXT FROM curDReportsLastUpdate INTO	@ReportID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE rpt.tblDReports
			SET LastUpdate = GETDATE()
			where ReportID = @ReportID
	        
				  
			FETCH NEXT FROM curDReportsLastUpdate INTO	@ReportID
		END
		
	Close curDReportsLastUpdate
	Deallocate curDReportsLastUpdate
    
END
GO
