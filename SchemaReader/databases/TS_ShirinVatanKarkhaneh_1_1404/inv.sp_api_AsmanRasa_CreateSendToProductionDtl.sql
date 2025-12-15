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
CREATE PROCEDURE [inv].[sp_api_AsmanRasa_CreateSendToProductionDtl]

@FiscalYear	As NVARCHAR(50) ,
@ProductCount As NVARCHAR(50) ,
@FormulaNo As NVARCHAR(50) ,
@AcntCode As NVARCHAR(50) ,
@TransferSerialNo As NVARCHAR(50) ,
@ProcessNo AS NVARCHAR(50),
@DocDate AS NVARCHAR(50),
@DocDesc AS NVARCHAR(50),
@GoodsId AS NVARCHAR(50),
@StoreID AS NVARCHAR(50),
@SerialNo  AS int,
@BatchId AS NVARCHAR(50),
@UnitID AS NVARCHAR(50),
@GoodsQuantity   as float

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @maxRowNo NVARCHAR(MAX)

BEGIN TRY

if(SUBSTRING(@DocDate,1,4)>='1401'  )
begin

	SELECT @maxRowNo = isnull(MAX(RowNo),0)
	FROM inv.tblStorageDocsDtl 
	WHERE ProcessID=70
		  AND ProcessNo=@ProcessNo
		  AND FiscalYear=@FiscalYear
		  AND SerialNo=@SerialNo

	SET @maxRowNo = @maxRowNo +1


	IF(SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID=@GoodsId AND HasBatchNo=1)=1
	BEGIN
		SELECT @BatchId=BatchNo from inv.tblStorageDocsHdr
		WHERE SerialNo=@SerialNo and ProcessID=70 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear
	END

	INSERT INTO inv.tblStorageDocsDtl
		(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, AcntCode,
		 DescDtl,FormulaNo,GoodsID,BatchNo,EnterKind,RowNo,DocRowNo,SubUnitID,GoodsQuantity,SubUnitQuantity)
	
	SELECT 70, @ProcessNo, @FiscalYear, @SerialNo, 1, @DocDate, @StoreID, @AcntCode,
		'Api'+@DocDesc,@FormulaNo,@GoodsId,@BatchId,-1,@maxRowNo,@maxRowNo,@UnitID,@GoodsQuantity,@GoodsQuantity
end
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
