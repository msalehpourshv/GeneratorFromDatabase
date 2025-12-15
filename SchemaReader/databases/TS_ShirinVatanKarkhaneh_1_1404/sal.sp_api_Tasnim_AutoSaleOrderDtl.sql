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
create PROCEDURE [sal].[sp_api_Tasnim_AutoSaleOrderDtl]
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
@TollOverWorthCost as FLOAT

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
BEGIN TRY


	IF (SELECT Count(*) FROM inv.tblGoods
		where TechnicalNo=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد کالا  '+@GoodsID+' نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	else
	BEGIN
		SELECT @GoodsID=GoodsID FROM inv.tblGoods
		where TechnicalNo=@GoodsID 
	END
	
	INSERT INTO [sal].[tblSaleOrderDtl]
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,
	DocStep, DocDate, StoreID, AcntCode,
	GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsPrice,
	DescDtl,DiscountPercentDtl, DiscountDtl, IsReward, SubUnitPrice,TaxOverWorthCostDtl,TollOverWorthCostDtl)
	
	select 180, @ProcessNo, @FiscalYear, @SerialNo,@RowNo,@RowNo,
		   @DocStep, @DocDate, @StoreID, @AcntCode, 
		   @GoodsID,UnitID ,@Quantity ,@Quantity ,@GoodsPrice ,
		   @DescDtl ,@DiscountPercentDtl,@DiscountDtl,@IsReward,@GoodsPrice SubUnitPrice,@TaxOverWorthCost,@TollOverWorthCost
	
	FROM inv.tblGoods 
	where GoodsID=@GoodsID
    
	
	SELECT  180 ProcessID,@RowNo RowNo,@StoreID StoreID,@GoodsID GoodsID

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
