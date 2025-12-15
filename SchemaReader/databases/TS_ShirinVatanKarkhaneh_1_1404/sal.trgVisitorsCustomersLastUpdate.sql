USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create TRIGGER sal.trgVisitorsCustomersLastUpdate 
   ON sal.tblVisitorsCustomersHdr
   WITH ENCRYPTION
   AFTER INSERT,UPDATE
AS 

Begin
	
	DECLARE @VisitorAcntCode	Varchar(20)
	DECLARE @SerialNo	Int
	
	Declare curVisitorsCustomersHdrLastUpdate Cursor For 
	Select VisitorAcntCode,SerialNo 
	From Inserted

	Open curVisitorsCustomersHdrLastUpdate

	FETCH NEXT FROM curVisitorsCustomersHdrLastUpdate INTO @VisitorAcntCode,@SerialNo 

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE [sal].[tblVisitorsCustomersHdr]
		SET LastUpdate = GETDATE()
		where VisitorAcntCode = @VisitorAcntCode
		AND   SerialNo = @SerialNo
				  
		FETCH NEXT FROM curVisitorsCustomersHdrLastUpdate INTO @VisitorAcntCode,@SerialNo 
	END
		
	Close curVisitorsCustomersHdrLastUpdate
	Deallocate curVisitorsCustomersHdrLastUpdate
    
END
GO
