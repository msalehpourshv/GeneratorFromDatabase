USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [sal].[trgGoodsPricesDtlInsert] 
   ON  [sal].[tblGoodsPricesDtl]
   WITH ENCRYPTION
   AFTER INSERT
AS 

Begin
	
	DECLARE @PriceDate varchar(10)
	DECLARE @GoodsID varchar(20)
	DECLARE @RowNo int
	DECLARE @IsGroupCode Bit
	
	SELECT  @PriceDate = pub.funChangeDate_GergorianToPersian(getdate())
	
	Declare curGoodsPricesDtl Cursor For 
	Select GoodsID,RowNo,IsGroupCode
	From Inserted

	Open curGoodsPricesDtl

	FETCH NEXT FROM curGoodsPricesDtl INTO	@GoodsID,@RowNo,@IsGroupCode


	WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE sal.tblGoodsPricesDtl
			SET PriceDate = @PriceDate
			where GoodsID = @GoodsID and
				  RowNo   = @RowNo	and
				  IsGroupCode  = @IsGroupCode	
				  
			FETCH NEXT FROM curGoodsPricesDtl INTO	@GoodsID,@RowNo,@IsGroupCode
		END
		
		
	Close curGoodsPricesDtl
	Deallocate curGoodsPricesDtl
    
END
GO
