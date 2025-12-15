USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [prs].[trgWorkShopsLastUpdate] 
   ON  prs.tblWorkShops
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @WorkShopID varchar(20)
	

	Declare curWorkShopsLastUpdate Cursor For 
	Select WorkShopID
	From Inserted

	Open curWorkShopsLastUpdate

	FETCH NEXT FROM curWorkShopsLastUpdate INTO	@WorkShopID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE prs.tblWorkShops
			SET LastUpdate = GETDATE()
			where WorkShopID = @WorkShopID
	        
				  
			FETCH NEXT FROM curWorkShopsLastUpdate INTO	@WorkShopID
		END
		
	Close curWorkShopsLastUpdate
	Deallocate curWorkShopsLastUpdate
    
END
GO
