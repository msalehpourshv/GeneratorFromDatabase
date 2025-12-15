USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgCustomGoodsParamLastUpdate] 
   ON  inv.tblCustomGoodsParam
   WITH ENCRYPTION
   AFTER INSERT,update
AS 

Begin
	
	DECLARE @CustomGoodsParamID varchar(20)
	

	Declare curCustomGoodsParamLastUpdate Cursor For 
	Select CustomGoodsParamID
	From Inserted

	Open curCustomGoodsParamLastUpdate

	FETCH NEXT FROM curCustomGoodsParamLastUpdate INTO	@CustomGoodsParamID


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE inv.tblCustomGoodsParam
			SET LastUpdate = GETDATE()
			where CustomGoodsParamID = @CustomGoodsParamID
	        
				  
			FETCH NEXT FROM curCustomGoodsParamLastUpdate INTO	@CustomGoodsParamID
		END
		
	Close curCustomGoodsParamLastUpdate
	Deallocate curCustomGoodsParamLastUpdate
    
END
GO
