USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [acc].[trgVisitPathLastUpdate] 
   ON  acc.tblVisitPath
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @VisitPathID varchar(20)
	DECLARE @PartNumber int

	Declare curVisitPathLastUpdate Cursor For 
	Select VisitPathID,PartNumber
	From Inserted

	Open curVisitPathLastUpdate

	FETCH NEXT FROM curVisitPathLastUpdate INTO	@VisitPathID,@PartNumber


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE acc.tblVisitPath
			SET LastUpdate = GETDATE()
			where VisitPathID = @VisitPathID
	         AND PartNumber = @PartNumber
				  
			FETCH NEXT FROM curVisitPathLastUpdate INTO	@VisitPathID,@PartNumber
		END
		
	Close curVisitPathLastUpdate
	Deallocate curVisitPathLastUpdate
    
END
GO
