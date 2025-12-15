USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/10/19
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[sp_api_AsmanRasa_CreateSendToProductionHdr]

@FiscalYear	As NVARCHAR(50) ,
@ProductCount As NVARCHAR(50) ,
@FormulaNo As NVARCHAR(50) ,
@AcntCode As NVARCHAR(50) ,
@TransferSerialNo As NVARCHAR(50) ,
@ProcessNo AS NVARCHAR(50),
@DocDate AS NVARCHAR(50),
@DocDesc AS NVARCHAR(50),
@StoreID AS NVARCHAR(50),
@OrderId AS NVARCHAR(50),
@ProductId AS NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @maxSerialNo nvarchar(50)
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @BatchId NVARCHAR(50)
	DECLARE @GoodsID nvarchar(50)
	DECLARE @GoodsID2 nvarchar(50)
	DECLARE @GoodsClassificationID nvarchar(50)


BEGIN TRY

SELECT @GoodsClassificationID=ISNULL(GoodsClassificationID,'') FROM inv.tblGoods WHERE TechnicalNo=@ProductId;
if( @GoodsClassificationID<>'' )
begin
	
SELECT @GoodsID2=GoodsID FROM inv.tblGoods WHERE TechnicalNo=@ProductId;

IF(select count(*) from inv.tblStorageDocsHdr where  ProcessID=70 AND TransferSerialNo=@TransferSerialNo and ProductID=@GoodsID2 and BatchNo=@OrderId)=0

Begin
select @GoodsID=ISNULL(GoodsID,'') from inv.tblGoods where TechnicalNo=@ProductId
		IF(@GoodsID='')
		BEGIN
			Set @StrErrorMessage = N' کد محصول '+@ProductId+' صحیح نیست '
			raiserror (@StrErrorMessage, 16, 1)
		END 

	IF(SELECT COUNT(*) FROM inv.tblStorageDocsHdr 
	WHERE  (SUBSTRING(TransferSerialNo,(LEN(TransferSerialNo)-LEN('43'))+1,LEN('43'))='43') AND SUBSTRING(TransferSerialNo,1,LEN(SUBSTRING(@OrderId,1,5)))=SUBSTRING(@OrderId,1,5) and ProcessID=70 and BatchNo=@OrderId)>0
	BEGIN
		SELECT 0 AS SerialNo
	END
	ELSE
	BEGIN
		SELECT @BatchId=BatchNo FROM inv.tblBatch where BatchNo=@OrderId

		



		SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
		FROM inv.tblStorageDocsHdr 
		WHERE ProcessID=70
		  AND ProcessNo=@ProcessNo
		  AND FiscalYear=@FiscalYear

		SET @maxSerialNo = @maxSerialNo +1

		INSERT INTO inv.tblStorageDocsHdr
			(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, AcntCode,
			 DocDesc,IsAutoDoc,TransferSerialNo,FormulaNo,ProductCount,BatchNo,ProductID)
	
		SELECT 70, @ProcessNo, @FiscalYear, @maxSerialNo, 1, @DocDate, @StoreID, @AcntCode,
			'Api'+@DocDesc,'True',@TransferSerialNo,@FormulaNo,@ProductCount,@BatchId,@GoodsID

		SELECT @maxSerialNo AS SerialNo , @BatchId AS BatchNo
	END
END

	ELSE
	 SELECT '0' AS SerialNo ,'0' AS BatchNo
end
	 SELECT '0' AS SerialNo ,'0' AS BatchNo
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
