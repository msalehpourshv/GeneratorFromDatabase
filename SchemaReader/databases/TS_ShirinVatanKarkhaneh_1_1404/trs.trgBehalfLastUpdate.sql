USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [trs].[trgBehalfLastUpdate] 
   ON  trs.tblBehalf
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @BehalfID varchar(20)
	

	Declare curBehalfLastUpdate Cursor For 
	Select BehalfID
	From Inserted

	Open curBehalfLastUpdate

	FETCH NEXT FROM curBehalfLastUpdate INTO	@BehalfID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE trs.tblBehalf
			SET LastUpdate = GETDATE()
			where BehalfID = @BehalfID
	        
				  
			FETCH NEXT FROM curBehalfLastUpdate INTO	@BehalfID
		END
		
	Close curBehalfLastUpdate
	Deallocate curBehalfLastUpdate
    
END
GO
