USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [pub].[trgColorsLastUpdate] 
   ON  pub.tblColors
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @ColorID varchar(20)
	

	Declare curColorsLastUpdate Cursor For 
	Select ColorID
	From Inserted

	Open curColorsLastUpdate

	FETCH NEXT FROM curColorsLastUpdate INTO	@ColorID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE pub.tblColors
			SET LastUpdate = GETDATE()
			where ColorID = @ColorID
	        
				  
			FETCH NEXT FROM curColorsLastUpdate INTO	@ColorID
		END
		
	Close curColorsLastUpdate
	Deallocate curColorsLastUpdate
    
END
GO
