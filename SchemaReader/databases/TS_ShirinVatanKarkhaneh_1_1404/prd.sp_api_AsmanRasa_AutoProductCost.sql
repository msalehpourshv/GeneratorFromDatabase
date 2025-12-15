USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alianpour
-- Create date   : 1400/12/08
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE prd.sp_api_AsmanRasa_AutoProductCost

@DocDate AS NVARCHAR(10),
@TransferSerialNo AS NVARCHAR(50),
@BatchNo AS Nvarchar(200),
@AcntCode AS Nvarchar(200),
@ProductionAcntCode AS Nvarchar(200),
@ProductID AS Nvarchar(200),
@Quantity AS FLOAT,
@DocDesc AS Nvarchar(200),
@Amount AS FLOAT,
@FiscalYear AS INT

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @MaxSerialNo AS INT

BEGIN TRY
if(SUBSTRING(@DocDate,1,4)>='1401')
begin

	IF(SELECT COUNT(*)FROM [prd].[tblProductCostsHdr] 
	   WHERE TransferSerialNo=@TransferSerialNo AND ProductID=@ProductID)=0
	
	BEGIN
		SELECT @MaxSerialNo= ISNULL(MAX(SerialNo),0) 
		FROM [prd].[tblProductCostsHdr]
		WHERE ProcessID=77

		SET @MaxSerialNo=@MaxSerialNo+1;
	
		INSERT INTO prd.tblProductCostsHdr
		([ProcessID],[ProcessNo],[FiscalYear], [SerialNo], [DocDate], [BaseProcessID], [BaseProcessNo], [BaseFiscalYear], [BaseSerialNo], [BatchNo], 
		 [AcntCode], [GoodsInProductionAcntCode], [ProductID], [ProductQuantity], [DocDesc], [VchNo], [RecID], 
		 [SessionNo], [TransferSerialNo])

		SELECT 77,1,@FiscalYear,@MaxSerialNo,@DocDate,0,0,0,0,@BatchNo,
		 @AcntCode,@ProductionAcntCode,@ProductID,@Quantity,'Api'+@DocDesc,0,0,0,@TransferSerialNo

		--DTL
		INSERT INTO prd.tblProductCostsDtl
		([ProcessID],[ProcessNo],[FiscalYear], [SerialNo], [RowNo], [DocRowNo], [DocDate], [AcntCode], [Quantity], [Amount] )

		SELECT 77,1,@FiscalYear,@MaxSerialNo,1,1,@DocDate,@AcntCode,@Quantity,@Amount


		EXEC  acc.SpVch_CreateDoc 0,0,@DocDate,@DocDate,77,0,0,@MaxSerialNo,'prd.tblProductCostsHdr'
		,'VchNo',2,5,1,0

	END
end
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
