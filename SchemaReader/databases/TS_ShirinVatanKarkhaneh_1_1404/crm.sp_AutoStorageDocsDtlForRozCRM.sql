USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 1402/07/17  
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE crm.sp_AutoStorageDocsDtlForRozCRM
	@ProcessID			int,
	@ProcessNo			tinyint,
	@FiscalYear			Int,
	@SerialNo			Int,
	@RowNo				Int,
	@DocStep			tinyint,
	@SaleTypeID			nvarchar(20),
	@DocDate			CHAR(10),
	@AcntCode			VARCHAR(20),
	@StoreID			VARCHAR(60),
	@GoodsID			VARCHAR(60),
	@EnterKind			int,
	@Quantity			FLOAT,
	@SubUnitQuantity	FLOAT,
	@GoodsPrice			FLOAT,
	@DescDtl			NVARCHAR(500),
	@DiscountPercentDtl FLOAT,
	@DiscountDtl		FLOAT,
	@IsReward			bit,
	@TaxOverWorthCost	FLOAT,
	@TollOverWorthCost	FLOAT,
	@TransferSerialNo	nvarchar(20),
	@VisitorAcntCode	nvarchar(20),
	@ExtraParams		NVarChar(Max)

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @Enter AS SmallInt

BEGIN TRY

if(@SerialNo>0)
begin

-- check sale type ==============================================================================================================
	IF (SELECT Count(*) FROM sal.tblSaleTypes where SaleTypeID=@SaleTypeID) = 0
	BEGIN
		Set @StrErrorMessage = N'نوع فروش تعریف نشده است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	-- check store id ==============================================================================================================
	IF (SELECT Count(*) FROM inv.tblStores where StoreID=@StoreID) = 0
	BEGIN
		Set @StrErrorMessage =  N'انبار تعریف نشده است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	-- check GoodsID ==============================================================================================================	
	IF (SELECT Count(*) FROM inv.tblGoods where GoodsID=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N' کد محصول '+@GoodsID+' صحیح نیست '
		raiserror (@StrErrorMessage, 16, 1)
	END

	IF (select Count(*)
		FROM inv.tblStorageDocsDtl  b
			inner join inv.tblStorageDocsHdr a on a.ProcessID=b.ProcessID AND a.ProcessNo=b.ProcessNo AND a.FiscalYear=b.FiscalYear AND a.SerialNo=b.SerialNo
		where ((a.BaseSerialNo<> b.BaseSerialNo and a.BaseSerialNo<>0 and b.BaseSerialNo<>0) or ( a.AcntCode<>b.AcntCode))
		and a.ProcessID=@ProcessID AND a.ProcessNo=@ProcessNo AND a.FiscalYear=@FiscalYear AND a.SerialNo=@SerialNo )>0
	BEGIN
		Set @StrErrorMessage = N' مشکل ذخیره اطلاعات نادرست'
		raiserror (@StrErrorMessage, 16, 1)
	END	

	if (select count(*) from inv.tblStorageDocsDtl where ProcessID=@ProcessID AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear and  SerialNo=@SerialNo and GoodsID=@GoodsID and RowNo=@RowNo)=0
	begin	
		INSERT INTO inv.tblStorageDocsDtl
		(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,DocStep, DocDate, StoreID
			,PhysicallyEffected, EnterKind, AcntCode,GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsPrice
			,DescDtl,DiscountPercentDtl, DiscountDtl, IsReward, SubUnitPrice,TaxOverWorthCostDtl,TollOverWorthCostDtl,VisitorAcntCode)	
		select @ProcessID, @ProcessNo, @FiscalYear, @SerialNo,@RowNo,@RowNo,0, @DocStep, @DocDate, @StoreID
				, 'True', @EnterKind, @AcntCode, @GoodsID,UnitID ,@Quantity,@Quantity ,@GoodsPrice ,@DescDtl 
				,@DiscountPercentDtl,@DiscountDtl,@IsReward,@GoodsPrice ,@TaxOverWorthCost,@TollOverWorthCost,@VisitorAcntCode
		FROM inv.tblGoods 
		where GoodsID=@GoodsID
	end	
		
	UPDATE inv.tblStorageDocsHdr
	set Price= D.TPrice, Amount= D.TPrice, TotalLineDiscount=DiscountDtl
	,TaxOverWorthCost=case when TaxOverWorthCostDtl>0 then TaxOverWorthCostDtl else TaxOverWorthCost end 
	,TollOverWorthCost=case when TollOverWorthCostDtl>0 then TollOverWorthCostDtl else TollOverWorthCost end 
	from inv.tblStorageDocsHdr H
	INNER JOIN (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,SUM(GoodsQuantity*GoodsPrice) TPrice,SUM(DiscountDtl) DiscountDtl
						,SUM(TaxOverWorthCostDtl) TaxOverWorthCostDtl,SUM(TollOverWorthCostDtl) TollOverWorthCostDtl
				FROM inv.tblStorageDocsDtl
				where ProcessID=@ProcessID AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear AND SerialNo=@SerialNo
				group by ProcessID,ProcessNo,FiscalYear,SerialNo ) D
	ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
	where H.ProcessID=@ProcessID 
		AND H.ProcessNo=@ProcessNo 
		AND H.FiscalYear=@FiscalYear 
		AND H.SerialNo=@SerialNo 
		
 UPDATE inv.tblStorageDocsHdr
	set  Amount= Price-[Discount]-[Discount2]-[TotalLineDiscount]-[AfterSaleDiscount]-[OtherCost]-[TransportationCost]	+[OtherIncome]+[TransportationIncome]+[PackingCost]+[TaxCost]-[FixCost]	+	case when DiscountTaxOverWorth=1 then 0 else  	[TaxOverWorthCost]+[TollOverWorthCost] end 	+[IAToll]-[DistributeAmount] 
	where ProcessID=@ProcessID 
		AND ProcessNo=@ProcessNo 
		AND FiscalYear=@FiscalYear 
		AND SerialNo=@SerialNo 

	SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
				DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, AcntCode,
				GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity, GoodsPrice,
				DescDtl,DiscountPercentDtl, DiscountDtl, IsReward, SubUnitPrice,TaxOverWorthCostDtl,TollOverWorthCostDtl,VisitorAcntCode
		FROM inv.tblStorageDocsDtl 
		where ProcessID=@ProcessID 
		AND ProcessNo=@ProcessNo 
		AND FiscalYear=@FiscalYear 
		and  SerialNo=@SerialNo 
		and GoodsID=@GoodsID 
		and RowNo=@RowNo
			
end

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
