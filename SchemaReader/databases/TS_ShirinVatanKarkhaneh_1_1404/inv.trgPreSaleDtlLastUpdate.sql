USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER [inv].[trgPreSaleDtlLastUpdate] 
   ON  [inv].[tblPreSaleDtl]
   WITH ENCRYPTION
   AFTER INSERT,UPDATE
AS 

Begin
	
	DECLARE @ProcessID Int
	DECLARE @ProcessNo Int
	DECLARE @FiscalYear Int
	DECLARE @SerialNo  Int
	DECLARE @RowNo  Int
	
	Declare curPreSaleDtlLastUpdate Cursor For 
	Select ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo
	From Inserted

	Open curPreSaleDtlLastUpdate

	FETCH NEXT FROM curPreSaleDtlLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@RowNo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE [inv].[tblPreSaleDtl]
		SET LastUpdate = GETDATE()
		where ProcessID = @ProcessID
		AND   ProcessNo = @ProcessNo
		AND   FiscalYear = @FiscalYear
		AND   SerialNo = @SerialNo
		AND   RowNo = @RowNo
				  
		FETCH NEXT FROM curPreSaleDtlLastUpdate INTO @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@RowNo
	END
		
	Close curPreSaleDtlLastUpdate
	Deallocate curPreSaleDtlLastUpdate
    
END
GO
