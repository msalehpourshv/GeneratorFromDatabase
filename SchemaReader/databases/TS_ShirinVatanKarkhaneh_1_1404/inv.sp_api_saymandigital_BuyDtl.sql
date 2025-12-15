USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1401/01/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================

Create PROCEDURE [inv].[sp_api_saymandigital_BuyDtl]
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

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @StoreLayer  AS INT

BEGIN TRY


	IF (SELECT Count(*) FROM inv.tblGoods
		where TechnicalNo=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N'�� ���� ������� ���'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	else
	BEGIN
		SELECT @GoodsID=GoodsID FROM inv.tblGoods
		where TechnicalNo=@GoodsID 
	END
	
	declare @debit as varchar(200)

	select @debit=substring( StockAcntCode ,7,14)
	from inv.tblStores
	where StoreID=@StoreID
	
	set @debit=replace(@debit,'6000000','600000')
	
	INSERT INTO inv.tblStorageDocsDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
	DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, AcntCode,
	GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsPrice,
	DescDtl,DiscountPercentDtl, DiscountDtl, IsReward, SubUnitPrice,TaxOverWorthCostDtl,TollOverWorthCostDtl)
	
	select 55, @ProcessNo, @FiscalYear, @SerialNo,@RowNo,@RowNo,0,
		   @DocStep, @DocDate, @StoreID, 'True', +1,'91502 '+ @debit, 
		   @GoodsID,UnitID ,@Quantity ,@Quantity ,@GoodsPrice ,
		   @DescDtl ,@DiscountPercentDtl,@DiscountDtl,@IsReward,@GoodsPrice SubUnitPrice,@TaxOverWorthCost,@TollOverWorthCost
	FROM inv.tblGoods 
	where GoodsID=@GoodsID

	SELECT 55 as ProcessID,@GoodsID as GoodsID,@RowNo as RowNo
    
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
