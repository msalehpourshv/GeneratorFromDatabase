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
create PROCEDURE [inv].[sp_api_Tasnim_AutoSaleDtl]
@ProcessNo as tinyint,
@FiscalYear as Int,
@SerialNo as Int,
@RowNo as Int,
@DocStep as tinyint,
@DocDate as CHAR(10),
@StoreID AS VARCHAR(20),
@AcntCode AS VARCHAR(20),
@GoodsID AS VARCHAR(20),
@Quantity as FLOAT,
@GoodsPrice as FLOAT,
@DescDtl as NVARCHAR(500),
@DiscountPercentDtl as FLOAT,
@DiscountDtl as FLOAT,
@IsReward as bit,
@SaleTypeID as nvarchar(20),
@TaxOverWorthCost as FLOAT,
@TollOverWorthCost as FLOAT,
@BaseSerialNo as Int

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)

BEGIN TRY


	IF (SELECT Count(*) FROM inv.tblGoods
		where TechnicalNo=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد کالا نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	else
	BEGIN
		SELECT @GoodsID=GoodsID FROM inv.tblGoods
		where TechnicalNo=@GoodsID 
	END
	
	INSERT INTO inv.tblStorageDocsDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
	DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, AcntCode,
	GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsPrice,
	DescDtl,DiscountPercentDtl, DiscountDtl, IsReward, SubUnitPrice,TaxOverWorthCostDtl,TollOverWorthCostDtl)
	
	select 90, @ProcessNo, @FiscalYear, @SerialNo,@RowNo,@RowNo,0,
		   @DocStep, @DocDate, @StoreID, 'True', -1, @AcntCode, 
		   @GoodsID,UnitID ,@Quantity ,@Quantity ,@GoodsPrice ,
		   @DescDtl ,@DiscountPercentDtl,@DiscountDtl,@IsReward,@GoodsPrice SubUnitPrice,@TaxOverWorthCost,@TollOverWorthCost
	FROM inv.tblGoods 
	where GoodsID=@GoodsID
    
	IF @BaseSerialNo<>0
		begin
		update inv.tblStorageDocsDtl
		set BaseSerialNo=@BaseSerialNo,BaseProcessNo=@ProcessNo,BaseProcessID=180,BaseDocType=180,
		BaseFiscalYear=@FiscalYear,BaseDocRowNo=@RowNo
		where SerialNo=@SerialNo and ProcessID=90 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear
	END
	SELECT  90 ProcessID,@RowNo RowNo,@StoreID StoreID,@GoodsID GoodsID

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
