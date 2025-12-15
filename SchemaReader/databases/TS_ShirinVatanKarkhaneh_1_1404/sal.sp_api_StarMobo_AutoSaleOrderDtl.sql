USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/01/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[sp_api_StarMobo_AutoSaleOrderDtl]
@ProcessNo as tinyint,
@FiscalYear as Int,
@SerialNo as Int,
@RowNo as Int,
@DocStep as tinyint,
@DocDate as CHAR(10),
@AcntCode AS VARCHAR(20),
@GoodsID AS VARCHAR(20),
@Quantity as FLOAT,
@GoodsPrice as FLOAT,
@DescDtl as NVARCHAR(500),
@DiscountPercentDtl as FLOAT,
@DiscountDtl as FLOAT,
@IsReward as bit,
@SaleTypeID as nvarchar(20)='00002',
@TaxOverWorthCost as FLOAT,
@TollOverWorthCost as FLOAT

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
BEGIN TRY
if(@SerialNo<>0)
Begin
	SET @GoodsPrice=@GoodsPrice*10
	SET @AcntCode='111307 '+@AcntCode
	IF (SELECT Count(*) FROM inv.tblGoods
		where GoodsID=@GoodsID )<>1
	
	BEGIN
		Set @StrErrorMessage = N'کد کالا  '+@GoodsID+' نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	
	INSERT INTO sal.tblSaleOrderDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,
	DocStep, DocDate,AcntCode,GoodsID, SubUnitID, SubUnitQuantity,
	GoodsQuantity, GoodsPrice,DescDtl,DiscountPercentDtl, DiscountDtl, IsReward, SubUnitPrice)
	
	select 180, @ProcessNo, @FiscalYear, @SerialNo,@RowNo,@RowNo,
		   @DocStep, @DocDate,@AcntCode, @GoodsID, UnitID , @Quantity ,
		   @Quantity ,@GoodsPrice ,@DescDtl ,@DiscountPercentDtl,@DiscountDtl,@IsReward,@GoodsPrice SubUnitPrice
	FROM inv.tblGoods 
	where GoodsID=@GoodsID
END
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
