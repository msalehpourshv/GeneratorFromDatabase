USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgInvTempReceiptDtlLastUpdate] 
   ON  [inv].[tblInvTempReceiptDtl]
   WITH ENCRYPTION
   AFTER INSERT,UPDATE
AS 

Begin
	
	DECLARE @ProcessID Int
	DECLARE @ProcessNo Int
	DECLARE @FiscalYear Int
	DECLARE @SerialNo  Int
	DECLARE @RowNo  Int
	
	Declare curInvTempReceiptDtlLastUpdate Cursor For 
	Select ProcessID,ProcessNo,FiscalYear,SerialNo
	From Inserted

	Open curInvTempReceiptDtlLastUpdate

	FETCH NEXT FROM curInvTempReceiptDtlLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE [inv].[tblInvTempReceiptDtl]
		SET LastUpdate = GETDATE()
		where ProcessID = @ProcessID
		AND   ProcessNo = @ProcessNo
		AND   FiscalYear = @FiscalYear
		AND   SerialNo = @SerialNo
				  
		FETCH NEXT FROM curInvTempReceiptDtlLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo
	END
		
	Close curInvTempReceiptDtlLastUpdate
	Deallocate curInvTempReceiptDtlLastUpdate
    
END
GO
