USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER prd.trgFormulasHdrLastUpdate 
   ON  [prd].[tblFormulasHdr]
   WITH ENCRYPTION
   AFTER INSERT,UPDATE
AS 

Begin
	
	DECLARE @ProductID	Varchar(20)
	DECLARE @SerialNo	Int
	
	Declare curFormulasHdrLastUpdate Cursor For 
	Select ProductID,SerialNo 
	From Inserted

	Open curFormulasHdrLastUpdate

	FETCH NEXT FROM curFormulasHdrLastUpdate INTO @ProductID,@SerialNo 

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE [prd].[tblFormulasHdr]
		SET LastUpdate = GETDATE()
		where ProductID = @ProductID
		AND   SerialNo = @SerialNo
				  
		FETCH NEXT FROM curFormulasHdrLastUpdate INTO @ProductID,@SerialNo 
	END
		
	Close curFormulasHdrLastUpdate
	Deallocate curFormulasHdrLastUpdate
    
END
GO
