USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgSaleOrderDtlLastUpdate] 
   ON  [sal].[tblSaleOrderDtl]
   WITH ENCRYPTION
   AFTER INSERT,UPDATE
AS 

Begin
	
	DECLARE @ProcessID Int
	DECLARE @ProcessNo Int
	DECLARE @FiscalYear Int
	DECLARE @SerialNo  Int
	DECLARE @RowNo  Int
	
	Declare curSaleOrderDtlLastUpdate Cursor For 
	Select ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo
	From Inserted

	Open curSaleOrderDtlLastUpdate

	FETCH NEXT FROM curSaleOrderDtlLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@RowNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE [sal].[tblSaleOrderDtl]
		SET LastUpdate = GETDATE()
		where ProcessID = @ProcessID
		AND   ProcessNo = @ProcessNo
		AND   FiscalYear = @FiscalYear
		AND   SerialNo = @SerialNo
		AND   RowNo = @RowNo
				  
		FETCH NEXT FROM curSaleOrderDtlLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@RowNo
	END
		
	Close curSaleOrderDtlLastUpdate
	Deallocate curSaleOrderDtlLastUpdate
    
END
GO
