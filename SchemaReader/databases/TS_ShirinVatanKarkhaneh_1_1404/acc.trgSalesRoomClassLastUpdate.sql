USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [acc].[trgSalesRoomClassLastUpdate] 
   ON  acc.tblSalesRoomClass
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @SalesRoomClassID varchar(20)
	

	Declare curSalesRoomClassLastUpdate Cursor For 
	Select SalesRoomClassID
	From Inserted

	Open curSalesRoomClassLastUpdate

	FETCH NEXT FROM curSalesRoomClassLastUpdate INTO	@SalesRoomClassID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE acc.tblSalesRoomClass
			SET LastUpdate = GETDATE()
			where SalesRoomClassID = @SalesRoomClassID
	        
				  
			FETCH NEXT FROM curSalesRoomClassLastUpdate INTO	@SalesRoomClassID
		END
		
	Close curSalesRoomClassLastUpdate
	Deallocate curSalesRoomClassLastUpdate
    
END
GO
