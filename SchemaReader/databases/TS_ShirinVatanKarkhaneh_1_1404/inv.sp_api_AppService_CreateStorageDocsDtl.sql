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
create PROCEDURE [inv].[sp_api_AppService_CreateStorageDocsDtl]
@ProcessNo as tinyint,
@FiscalYear as Int,
@ProcessId as Int,
@SerialNo as Int,
@EnterKind as Int,
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
@SaleTypeID as nvarchar(20),
@TaxOverWorthCost as FLOAT,
@TollOverWorthCost as FLOAT,
@IsCreateDoc as int,
@StoreID  As NVARCHAR(50) ,
@VisitorAcntCode as nvarchar(50)
WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)


BEGIN TRY

if(@SerialNo>0)
begin
	
	set @FiscalYear=SUBSTRING(@DocDate,1,4)


	IF (SELECT Count(*) FROM inv.tblGoods
		where GoodsID=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N' کد محصول '+@GoodsID+' صحیح نیست '
		raiserror (@StrErrorMessage, 16, 1)
	END

	IF (SELECT Count(*) FROM inv.tblGoods
		where GoodsID=@GoodsID and CodeClosed=1 )>0
	BEGIN
		Set @StrErrorMessage = N'این کد مسدود شده است امکان ایجاد ردیف با این کد کالا را ندارید'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	IF (select Count(*)
		FROM inv.tblStorageDocsDtl  b
			inner join inv.tblStorageDocsHdr a on a.ProcessID=b.ProcessID AND a.ProcessNo=b.ProcessNo AND a.FiscalYear=b.FiscalYear AND a.SerialNo=b.SerialNo
		where ((a.BaseSerialNo<> b.BaseSerialNo and a.BaseSerialNo<>0 and b.BaseSerialNo<>0) or ( a.AcntCode<>b.AcntCode))
		and a.ProcessID=90 AND a.ProcessNo=@ProcessNo AND a.FiscalYear=@FiscalYear AND a.SerialNo=@SerialNo )>0
	BEGIN
		Set @StrErrorMessage = N' مشکل ذخیره اطلاعات نادرست'
		raiserror (@StrErrorMessage, 16, 1)
	END

	SET @AcntCode='111301 '+@AcntCode

	SELECT @GoodsID= GoodsID FROM inv.tblGoods
		where TechnicalNo=@GoodsID
	
	INSERT INTO inv.tblStorageDocsDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
	DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, AcntCode,
	GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsPrice,
	DescDtl,DiscountPercentDtl, DiscountDtl, IsReward, SubUnitPrice,TaxOverWorthCostDtl,TollOverWorthCostDtl,VisitorAcntCode)
	
	select 90, @ProcessNo, @FiscalYear, @SerialNo,@RowNo,@RowNo,0,
		   @DocStep, @DocDate, @StoreID, 'True', -1, @AcntCode, 
		   @GoodsID,UnitID ,@Quantity ,@Quantity ,@GoodsPrice ,
		   @DescDtl ,@DiscountPercentDtl,@DiscountDtl,@IsReward,@GoodsPrice SubUnitPrice,@TaxOverWorthCost,@TollOverWorthCost,@VisitorAcntCode
	FROM inv.tblGoods 
	where GoodsID=@GoodsID

end

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
