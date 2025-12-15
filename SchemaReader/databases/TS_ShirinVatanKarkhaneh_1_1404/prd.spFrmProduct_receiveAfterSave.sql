USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 89/04/26
-- Description:	
-- =============================================

CREATE PROCEDURE [prd].[spFrmProduct_receiveAfterSave] 
 @ProcessID		tinyint,
 @ProcessNo		tinyint,
 @FiscalYear	smallint,
 @SerialNo		int,
 @LanguageID	tinyint
 
WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;
Declare @strMsgText	 NVarChar(2044)
Declare @rr		        NVarChar(500)

declare @BaseProcessID smallint
declare @BaseProcessNo smallint
declare @BaseFiscalYear  smallint
declare @BaseSerialNo Int
declare @GoodsQuantity float
declare @ProductCount  float
declare @RecProductCount  float
declare @SubtractValue  int
declare @ProductID VARCHAR(20)

Declare	Cursor_Rec CURSOR For 
    SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsQuantity
    FROM inv.tblStorageDocsDtl
    WHERE  ProcessID=@ProcessID AND
           ProcessNo=@ProcessNo AND
           FiscalYear=@FiscalYear AND
           SerialNo=@SerialNo 

Open  Cursor_Rec; 

Fetch NEXT From Cursor_Rec Into @BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@GoodsQuantity

While (@@Fetch_Status = 0)
BEGIN


	SELECT @ProductCount = ProductCount ,@ProductID = ProductID
	FROM inv.tblStorageDocsHdr
	WHERE  ProcessID = @BaseProcessID  AND
           ProcessNo = @BaseProcessNo  AND
           FiscalYear= @BaseFiscalYear AND
           SerialNo  = @BaseSerialNo
	

	SELECT @RecProductCount = SUM(GoodsQuantity) 
	FROM inv.tblStorageDocsDtl
	WHERE  ProcessID = 80 AND 
		   BaseProcessID = @BaseProcessID  AND
           BaseProcessNo = @BaseProcessNo  AND
           BaseFiscalYear= @BaseFiscalYear AND
           BaseSerialNo  = @BaseSerialNo AND GoodsID = @ProductID

	SET @SubtractValue = @RecProductCount - @ProductCount

	IF @SubtractValue > 0
	begin
		Close Cursor_Rec;
		Deallocate Cursor_Rec;
		--'مقدار محصول دریافتی از ارسال به تولید %d بیشتر است '
		SET @strMsgText=TS.pub.funGetMessages(16014,@LanguageID)
		Raiserror (@strMsgText,16,1,@SubtractValue)
		Return
	END
	Fetch NEXT From Cursor_Rec Into @BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@GoodsQuantity

End

Close Cursor_Rec;
Deallocate Cursor_Rec; 


END
GO
