USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [cmr].[trgOrderDtlLastUpdate] 
   ON  [cmr].[tblOrderDtl]
   WITH ENCRYPTION
   AFTER INSERT,UPDATE
AS 

Begin
	
	DECLARE @ProcessID Int
	DECLARE @ProcessNo Int
	DECLARE @FiscalYear Int
	DECLARE @SerialNo  Int
	DECLARE @RowNo  Int
	
	Declare curOrderDtlLastUpdate Cursor For 
	Select ProcessID,ProcessNo,FiscalYear,SerialNo
	From Inserted

	Open curOrderDtlLastUpdate

	FETCH NEXT FROM curOrderDtlLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE [cmr].[tblOrderDtl]
		SET LastUpdate = GETDATE()
		where ProcessID = @ProcessID
		AND   ProcessNo = @ProcessNo
		AND   FiscalYear = @FiscalYear
		AND   SerialNo = @SerialNo
				  
		FETCH NEXT FROM curOrderDtlLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo
	END
		
	Close curOrderDtlLastUpdate
	Deallocate curOrderDtlLastUpdate
    
END
GO
