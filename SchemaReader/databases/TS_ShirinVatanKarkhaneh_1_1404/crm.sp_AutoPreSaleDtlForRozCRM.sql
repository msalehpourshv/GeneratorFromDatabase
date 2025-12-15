USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 1400/09/02
-- Viewed By	 : 
-- Last Modified : 
-- Description   : ورود پیش فاکتور از crm  رز
-- =============================================
Create PROCEDURE crm.sp_AutoPreSaleDtlForRozCRM
@ProcessNo as int,
@SerialNo as Int,
@GoodsID AS VARCHAR(20),
@UnitID AS VARCHAR(20),
@Quantity as FLOAT,
@GoodsPrice as FLOAT,
@DescDtl as NVARCHAR(500),
@DiscountPercentDtl as FLOAT,
@DiscountDtl as FLOAT,
@TaxOverWorthCost as FLOAT,
@TollOverWorthCost as FLOAT,
@Repeat as int


WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
BEGIN TRY

	declare @RowNo				int;
	declare @FiscalYear				int;
	set @FiscalYear=RIGHT (DB_NAME(),4) 

	IF (SELECT Count(*) FROM inv.tblGoods	where GoodsID =@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد کالا  '+@GoodsID+' نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	IF (SELECT Count(*) FROM inv.tblUnits	where UnitID =@UnitID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد واحد کالا  '+@UnitID+' نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END
	
	IF (SELECT Count(*) FROM inv.tblGoods	where GoodsID =@GoodsID and UnitID =@UnitID)<=0 and (SELECT Count(*) FROM inv.tblSubUnitsDtl where GoodsID =@GoodsID and SubUnitID =@UnitID)<=0
	BEGIN
		Set @StrErrorMessage = N'کد کالا  '+@GoodsID+' برای کد واحد کالا  '+@UnitID+' نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END		
	
	declare @DocDate as CHAR(10)
	declare @StoreID AS VARCHAR(20)
	declare @AcntCode AS VARCHAR(20)

	Select  @DocDate=DocDate ,@StoreID=StoreID,@AcntCode=AcntCode
	from inv.tblPreSaleHdr
	where ProcessID=240 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo
	
if (Select Count(*)	from inv.tblPreSaleDtl	where ProcessID=240 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo and GoodsID=@GoodsID and @Repeat=0)<=0
begin

	SELECT @RowNo = isnull(MAX(DocRowNo),0)
	FROM inv.tblPreSaleDtl
	WHERE ProcessID=240
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear

	INSERT INTO inv.tblPreSaleDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,
	DocStep, DocDate, StoreID, AcntCode,
	GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsAmount,MainAmount,
	DescDtl,DiscountPercent, Discount, SubUnitPrice,TaxOverWorthCostDtl,TollOverWorthCostDtl)
	
	select 240, @ProcessNo, @FiscalYear, @SerialNo,@RowNo+1,@RowNo+1,
		   1, @DocDate, @StoreID, @AcntCode, 
		   @GoodsID,@UnitID ,@Quantity ,  [inv].[funGetGoodsQuantityFromSubUnit](@GoodsID,@UnitID, @Quantity ),@GoodsPrice ,@GoodsPrice ,
		   @DescDtl ,@DiscountPercentDtl,@DiscountDtl,@GoodsPrice,@TaxOverWorthCost,@TollOverWorthCost
	

    
	
	SELECT   @SerialNo SerialNo, @AcntCode AcntCode,@StoreID StoreID,@RowNo RowNo,@GoodsID  GoodsID ,0 IsExist 	
	update  inv.tblPreSaleHdr
	set  
	Price =D.Amount, TotalLineDiscount=D.DiscountDtl
	,Discount=(D.Amount-D.DiscountDtl) *H.DiscountPercent/100 +case when TaxOverWorthCostDtl> 0 then TaxOverWorthCostDtl else TaxOverWorthCost end +case when TollOverWorthCostDtl> 0 then TollOverWorthCostDtl else TollOverWorthCost end 
	,Amount=D.Amount-D.DiscountDtl-Discount2-(((D.Amount-D.DiscountDtl) *H.DiscountPercent/100 +case when TaxOverWorthCostDtl> 0 then TaxOverWorthCostDtl else TaxOverWorthCost end +case when TollOverWorthCostDtl> 0 then TollOverWorthCostDtl else TollOverWorthCost end ) *H.DiscountPercent/100)	
	, TaxOverWorthCost =case when TaxOverWorthCostDtl> 0 then TaxOverWorthCostDtl else TaxOverWorthCost end 
	,TollOverWorthCost=case when TollOverWorthCostDtl> 0 then TollOverWorthCostDtl else TollOverWorthCost end 

	from  inv.tblPreSaleHdr H
	inner join  
	(	Select Sum (GoodsAmount*SubUnitQuantity) Amount,Sum(D.Discount)DiscountDtl,Sum(D.TaxOverWorthCostDtl)TaxOverWorthCostDtl,Sum(D.TollOverWorthCostDtl)TollOverWorthCostDtl, D.ProcessID, D.ProcessNo, D.FiscalYear,D.SerialNo
		from  inv.tblPreSaleHdr H
		inner join  inv.tblPreSaleDtl D
		on H.ProcessID=D.ProcessID
		And H.ProcessNo=D.ProcessNo
		And H.FiscalYear=D.FiscalYear
		And H.SerialNo=D.SerialNo
		where H.ProcessID=240 and H.ProcessNo=@ProcessNo and H.FiscalYear=@FiscalYear and H.SerialNo=@SerialNo
		Group by D.ProcessID, D.ProcessNo, D.FiscalYear,D.SerialNo
	)D 	on H.ProcessID=D.ProcessID
	And H.ProcessNo=D.ProcessNo
	And H.FiscalYear=D.FiscalYear
	And H.SerialNo=D.SerialNo

	where H.ProcessID=240 and H.ProcessNo=@ProcessNo and H.FiscalYear=@FiscalYear and H.SerialNo=@SerialNo

end 
else 
	Select  SerialNo, AcntCode,StoreID, RowNo,GoodsID ,1 IsExist 	from inv.tblPreSaleDtl	
		where ProcessID=240 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo
		and GoodsID=@GoodsID

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
