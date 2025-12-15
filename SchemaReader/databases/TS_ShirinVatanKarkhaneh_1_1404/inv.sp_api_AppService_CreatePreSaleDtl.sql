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
Create PROCEDURE [inv].[sp_api_AppService_CreatePreSaleDtl]
@ProcessNo as tinyint,
@FiscalYear as Int,
@ProcessId as Int,
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
@SaleTypeID as nvarchar(20),
@TaxOverWorthCost as FLOAT,
@TollOverWorthCost as FLOAT,
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

	SELECT @GoodsID= GoodsID FROM inv.tblGoods
		where TechnicalNo=@GoodsID
	
	INSERT INTO inv.tblPreSaleDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,
	DocStep, DocDate, StoreID,   AcntCode,
	GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsAmount,MainAmount,
	DescDtl, SubUnitPrice,TaxOverWorthCostDtl,TollOverWorthCostDtl,VisitorAcntCode)
	
	select 240, @ProcessNo, @FiscalYear, @SerialNo,@RowNo,@RowNo,
		   @DocStep, @DocDate, @StoreID,  @AcntCode, 
		   @GoodsID,UnitID ,@Quantity ,@Quantity ,@GoodsPrice ,@GoodsPrice,
		   @DescDtl+' Api' ,@GoodsPrice SubUnitPrice,@TaxOverWorthCost,@TollOverWorthCost,@VisitorAcntCode
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
