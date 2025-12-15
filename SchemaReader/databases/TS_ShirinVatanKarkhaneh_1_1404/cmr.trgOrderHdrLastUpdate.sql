USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [cmr].[trgOrderHdrLastUpdate] 
   ON  [cmr].[tblOrderHdr]
   WITH ENCRYPTION
   AFTER INSERT,UPDATE
AS 

Begin
	
	DECLARE @ProcessID Int
	DECLARE @ProcessNo Int
	DECLARE @FiscalYear Int
	DECLARE @SerialNo  Int
	DECLARE @RowNo  Int
	
	Declare curOrderHdrLastUpdate Cursor For 
	Select ProcessID,ProcessNo,FiscalYear,SerialNo
	From Inserted

	Open curOrderHdrLastUpdate

	FETCH NEXT FROM curOrderHdrLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE [cmr].[tblOrderHdr]
		SET LastUpdate = GETDATE()
		where ProcessID = @ProcessID
		AND   ProcessNo = @ProcessNo
		AND   FiscalYear = @FiscalYear
		AND   SerialNo = @SerialNo
				  
		FETCH NEXT FROM curOrderHdrLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo
	END
		
	Close curOrderHdrLastUpdate
	Deallocate curOrderHdrLastUpdate
    
END
GO
