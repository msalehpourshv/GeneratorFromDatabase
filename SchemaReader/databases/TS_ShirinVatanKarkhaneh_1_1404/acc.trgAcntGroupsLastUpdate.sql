USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [acc].[trgAcntGroupsLastUpdate] 
   ON  acc.tblAcntGroups
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @AcntGroupID varchar(20)
	DECLARE @PartNumber int

	Declare curAcntGroupsLastUpdate Cursor For 
	Select AcntGroupID,PartNumber
	From Inserted

	Open curAcntGroupsLastUpdate

	FETCH NEXT FROM curAcntGroupsLastUpdate INTO	@AcntGroupID,@PartNumber


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE acc.tblAcntGroups
			SET LastUpdate = GETDATE()
			where AcntGroupID = @AcntGroupID
	         AND PartNumber = @PartNumber
				  
			FETCH NEXT FROM curAcntGroupsLastUpdate INTO	@AcntGroupID,@PartNumber
		END
		
	Close curAcntGroupsLastUpdate
	Deallocate curAcntGroupsLastUpdate
    
END
GO
