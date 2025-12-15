USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [sal].[trgSaleOrderHdrLastUpdate] 
   ON  [sal].[tblSaleOrderHdr]
   WITH ENCRYPTION
   AFTER INSERT,UPDATE
AS 

Begin
	
	DECLARE @ProcessID Int
	DECLARE @ProcessNo Int
	DECLARE @FiscalYear Int
	DECLARE @SerialNo  Int
	DECLARE @RowNo  Int
	
	Declare curSaleOrderHdrLastUpdate Cursor For 
	Select ProcessID,ProcessNo,FiscalYear,SerialNo
	From Inserted

	Open curSaleOrderHdrLastUpdate

	FETCH NEXT FROM curSaleOrderHdrLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE [sal].[tblSaleOrderHdr]
		SET LastUpdate = GETDATE()
		where ProcessID = @ProcessID
		AND   ProcessNo = @ProcessNo
		AND   FiscalYear = @FiscalYear
		AND   SerialNo = @SerialNo
				  
		FETCH NEXT FROM curSaleOrderHdrLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo
	END
		
	Close curSaleOrderHdrLastUpdate
	Deallocate curSaleOrderHdrLastUpdate
    
END
GO
