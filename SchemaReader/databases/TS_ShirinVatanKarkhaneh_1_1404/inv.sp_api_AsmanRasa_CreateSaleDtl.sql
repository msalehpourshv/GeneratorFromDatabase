USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/06/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE [inv].[sp_api_AsmanRasa_CreateSaleDtl]
@ProcessNo as tinyint,
@FiscalYear as Int,
@SerialNo as Int,
@DocDate as CHAR(10),
@AcntCode AS VARCHAR(20),
@GoodsID AS VARCHAR(20),
@Quantity as FLOAT,
@GoodsPrice as FLOAT,
@DescDtl as NVARCHAR(500),
@DiscountDtl as FLOAT,
@SaleTypeID as nvarchar(20),
@StoreID as nvarchar(20),
@TaxOverWorthCost as FLOAT,
@Batch As NVARCHAR(50) ,
@TollOverWorthCost as FLOAT,
@IsReturn AS VARCHAR(50),
@ReturnMaxSerialNo AS VARCHAR(50),
@TransferSerialNo AS VARCHAR(50)
WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @maxRowNo AS VARCHAR(20)
DECLARE @HasBatch AS INT

BEGIN TRY
if(SUBSTRING(@DocDate,1,4)>='1401')
begin
	IF (SELECT Count(*) FROM inv.tblGoods
		where TechnicalNo=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N' کد محصول '+@GoodsID+' صحیح نیست '
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	--if(@GoodsID='375 1045' or @GoodsID='375 1046' or @GoodsID='375 1047' or @GoodsID='375 1048' or @GoodsID='376 1049'or @GoodsID='376 1050'or @GoodsID='376 1051'or @GoodsID='376 1052')
	-- set @Batch=''


	SELECT @GoodsID=GoodsID FROM inv.tblGoods
	WHERE TechnicalNo=@GoodsID
	
	SELECT @HasBatch=HasBatchNo FROM inv.tblGoods
	WHERE GoodsID=@GoodsID

	IF(@HasBatch=0)
	BEGIN
		SET @Batch=''

	END 

	if(select count (* )from inv.tblStorageDocsDtl
		where ProcessID=80 and BatchNo =pub.funSplitString (@TransferSerialNo,'_' ,1)  and GoodsID=@GoodsID )>0 and @HasBatch=1
		SET @Batch=pub.funSplitString (@TransferSerialNo,'_' ,1)

	IF(@IsReturn='1')
	BEGIN
		DECLARE @MaxReturnRow AS int =0

		SELECT @MaxReturnRow = isnull(MAX(RowNo),0)
		FROM inv.tblStorageDocsDtl
		WHERE ProcessID=100 AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear AND SerialNo=@ReturnMaxSerialNo


		SET @MaxReturnRow = @MaxReturnRow +1

		INSERT INTO inv.tblStorageDocsDtl 
		(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, 
		DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, AcntCode,
		GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsPrice,
		DescDtl, DiscountDtl, IsReward, SubUnitPrice,TaxOverWorthCostDtl,TollOverWorthCostDtl,BatchNo)

	select 
		100, @ProcessNo, @FiscalYear, @ReturnMaxSerialNo,@MaxReturnRow,@MaxReturnRow,
		2, @DocDate, @StoreID, 'True', 1, @AcntCode, 
		@GoodsID,UnitID ,@Quantity ,@Quantity ,@GoodsPrice ,
		'Api'+@DescDtl ,@DiscountDtl,0,@GoodsPrice SubUnitPrice,@TaxOverWorthCost,@TollOverWorthCost,@Batch

	FROM inv.tblGoods 
	where GoodsID=@GoodsID
	--EXEC  acc.SpVch_CreateDoc  0,0,@DocDate,@DocDate,100,@ProcessNo,@FiscalYear,@MaxReturnRow,'inv.tblStorageDocsHdr','VchNo',2,5,1,0

	END

	SELECT @maxRowNo = isnull(MAX(RowNo),0)
		FROM inv.tblStorageDocsDtl
		WHERE ProcessID=90
		  AND ProcessNo=@ProcessNo
		  AND FiscalYear=@FiscalYear
		  AND SerialNo=@SerialNo


	SET @maxRowNo = @maxRowNo +1



	INSERT INTO inv.tblStorageDocsDtl 
		(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, 
		DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, AcntCode,
		GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsPrice,IsReward,
		DescDtl, DiscountDtl, SubUnitPrice,TaxOverWorthCostDtl,TollOverWorthCostDtl,BatchNo)

	select 
		90, @ProcessNo, @FiscalYear, @SerialNo,@maxRowNo,@maxRowNo,
		3, @DocDate, @StoreID, 'True', -1, @AcntCode, 
		@GoodsID,UnitID ,@Quantity ,@Quantity ,@GoodsPrice ,CASE WHEN @GoodsPrice=0 THEN 'true' WHEN @GoodsPrice!=0 THEN 'false' end,
		'Api'+@DescDtl ,@DiscountDtl,@GoodsPrice SubUnitPrice,@TaxOverWorthCost,@TollOverWorthCost,@Batch

	FROM inv.tblGoods 
	where GoodsID=@GoodsID

	EXEC  acc.SpVch_CreateDoc  0,0,@DocDate,@DocDate,90,@ProcessNo,@FiscalYear,@SerialNo,'inv.tblStorageDocsHdr','VchNo',2,5,1,0 --??
end

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
