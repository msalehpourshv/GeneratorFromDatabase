USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgPatternsLastUpdate] 
   ON  inv.tblPatterns
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @PatternID varchar(20)
	

	Declare curPatternsLastUpdate Cursor For 
	Select PatternID
	From Inserted

	Open curPatternsLastUpdate

	FETCH NEXT FROM curPatternsLastUpdate INTO	@PatternID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblPatterns
			SET LastUpdate = GETDATE()
			where PatternID = @PatternID
	        
				  
			FETCH NEXT FROM curPatternsLastUpdate INTO	@PatternID
		END
		
	Close curPatternsLastUpdate
	Deallocate curPatternsLastUpdate
    
END
GO
