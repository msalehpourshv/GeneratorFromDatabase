USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER sal.trgGoodsPricesDtlLastUpdate 
   ON  [sal].[tblGoodsPricesDtl]
   WITH ENCRYPTION
   AFTER INSERT,UPDATE
AS 

Begin
	
	Declare @GoodsID	Varchar(20)
	DECLARE @RowNo		Int
	
	Declare curGoodsPricesDtlLastUpdate Cursor For 
	Select GoodsID,RowNo
	From Inserted

	Open curGoodsPricesDtlLastUpdate

	FETCH NEXT FROM curGoodsPricesDtlLastUpdate INTO @GoodsID,@RowNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE [sal].[tblGoodsPricesDtl]
		SET LastUpdate = GETDATE()
		where GoodsID = @GoodsID
		AND   RowNo = @RowNo		 
				  
		FETCH NEXT FROM curGoodsPricesDtlLastUpdate INTO @GoodsID,@RowNo
	END
		
	Close curGoodsPricesDtlLastUpdate
	Deallocate curGoodsPricesDtlLastUpdate
    
END
GO
