USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE [inv].[sp_api_TakroSystem_GetConfirmedSaleDtl]
@ProcessId as int,
@ProcessNo as int,
@SerialNo as int,
@FiscalYear as int

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @TaxOverWorthPercentInSale as INT
	DECLARE @TollOverWorthPercentInSale INT
	declare @From as int
	declare @To as int
	declare @PartNumber as int
	declare @Len1 as int
	declare @Len2 as int
	declare @Len3 as int
	declare @Len4 as int
	DECLARE @TotalPrice bit
	DECLARE @2Qty bit
	DECLARE @2Price bit
	DECLARE @Sal2 bit
	DECLARE @HasDST bit
BEGIN TRY


	--<NativeText("دو ستونی بودن مقدار در فرم ها")>
	--  Public Shared Inv_QuantityIsTwoColumn As Boolean = False ' مقدار اصلی و فرعی در خرید و فروش
	--<NativeText("قیمت اصلی و فرعی در خرید و فروش")>
	-- Public Shared Inv_ShowSecondPrice As Boolean = False ' قیمت اصلی و فرعی در خرید و فروش
	-- <NativeText("قیمت فروش بر اساس واحد فرعی")>
	-- Public Shared Sal_SaleWithSecondryPrice As Boolean = False  'قیمت فروش بر اساس واحد فرعی
	SELECT @TotalPrice=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Inv_CalcTotalPriceWithUnitType'
	SELECT @2Qty=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Inv_QuantityIsTwoColumn'
	SELECT @2Price=SettingValue FROM pub.tblSettings 	WHERE SettingKey = 'Inv_ShowSecondPrice'
	SELECT @Sal2=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Sal_SaleWithSecondryPrice'
	SELECT @HasDST=SettingValue FROM pub.tblSettings 	WHERE SettingKey = 'HasDST'
	SET @TotalPrice=ISNULL(@TotalPrice,0)
	SELECT @TaxOverWorthPercentInSale=SettingValue 
	FROM pub.tblSettings 
	WHERE SettingKey = 'TaxOverWorthPercentInSale'

	SELECT @TollOverWorthPercentInSale=SettingValue 
	FROM pub.tblSettings 
	WHERE SettingKey = 'TollOverWorthPercentInSale'


	select @PartNumber=isnull(SettingValue,0) from pub.tblSettings
	where SettingKey = 'UnitPart' and 1=1

	select @Len1=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1 
	select @Len2=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=2
	select @Len3=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=3 
	select @Len4=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=4
	
	if(@PartNumber=0)
	 set @PartNumber=1

	if(@PartNumber=1)
	begin
	 set @To=@Len1
	 set @From= 1
	end

	if(@PartNumber=2)
	begin
	 set @To=@Len2
	 set @From= @Len1+1
	end

	if(@PartNumber=3)
	begin
	 set @To=@Len3
	 set @From= @Len1+@Len2+1
	end

	if(@PartNumber=4)
	begin
	 set @To=@Len4
	 set @From= @Len1+@Len2+@Len3+1
	end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	SELECT 
	-------------------------------------------------محاسبه مبلغ نقدي-------------------------------------------------------------
	
	CASE
	WHEN PayType=0 THEN 0
	WHEN PayType=1 THEN  cast(floor(PriceNew*cast(QtyNew as decimal(28,7)) -DiscountDtlAll)as decimal)			
	WHEN PayType=2 THEN cast(0 as decimal)
	END AS Cop,

	--------------------------------------------محاسبه مبالغ-------------------------------------------------------------------

	QtyNew AS SubUnitQuantity,
	
	cast(PriceNew as decimal(27,7))GoodsPrice,

	cast(pub.funDecimalPlace(CurrencyAmount, 4)as decimal(28,4)) AS CurrencyAmount,

	CASE 
	WHEN CurrencyRate=0 THEN CAST(0 AS DECIMAL)
	WHEN CurrencyRate<>0 THEN cast(pub.funDecimalPlace(((PriceNew*cast(QtyNew as decimal(28,7))) / CurrencyRate ),4) as decimal(28,4))
	END AS Sscv,

	cast(FLOOR(cast(QtyNew as decimal(28,7))*PriceNew )as decimal(28,0)) AS PriceBeforDiscount,

	cast(floor(D.DiscountDtlAll  )as decimal(28,0)) AS DiscountDtl,

	cast(floor(PriceNew*cast(QtyNew as decimal(28,7)) -DiscountDtlAll)as decimal(28,0))
	AS PriceAfterDiscount,

	cast(floor(D.TaxOverWorthCostDtl + D.TollOverWorthCostDtl) as decimal(28,0))
	AS TaxOverWorth,
	
	CASE 
	WHEN TPInp<>7 THEN cast(floor(PriceNew*cast(QtyNew as decimal(28,7)) -DiscountDtlAll  + (TaxOverWorthCostDtl+TollOverWorthCostDtl ))as decimal(28,0))
										 
	WHEN TPInp=7 THEN cast(floor(PriceNew*cast(QtyNew as decimal(28,7))+ (TaxOverWorthCostDtl+TollOverWorthCostDtl ))as decimal(28,0))
	END Amount,

	--------------------------------------------------- مالیات	------------------------------------------------------------------	
	CASE 
	WHEN ISNULL(G.NotContainTax,0)=1 THEN 0
	WHEN cast(QtyNew as decimal(28,7))*PriceNew=DiscountDtl THEN
		CASE
			WHEN CAST(ISNULL(G.Tax,0)+ISNULL(G.Toll,0) AS DECIMAL)=0  THEN  CAST(@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale AS decimal)
		    WHEN CAST(ISNULL(G.Tax ,0)+ISNULL(G.Toll ,0)AS DECIMAL)<>0 THEN CAST( ISNULL(G.Tax,0 )+ISNULL(G.Toll,0 ) AS DECIMAL) 
		END
	WHEN TaxOverWorthCostDtl=0 and IsReward=0 THEN 0
	WHEN CAST(ISNULL(G.Tax,0)+ISNULL(G.Toll,0) AS DECIMAL)=0  THEN  CAST(@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale AS decimal)
	WHEN CAST(ISNULL(G.Tax ,0)+ISNULL(G.Toll ,0)AS DECIMAL)<>0 THEN CAST( ISNULL(G.Tax,0 )+ISNULL(G.Toll,0 ) AS DECIMAL)
	END Tax,

	----------------------------------------------------فیلد های دیگر----------------------------------------------------------
	CommissionerContractID,
	CASE 
	WHEN TPInp =7 THEN cast(pub.funDecimalPlace(G.GoodsWeight*cast(QtyNew as decimal(28,7)) ,3) as decimal(28,3))
	WHEN TPInp<>7 THEN CAST(0 AS DECIMAL)
	END AS WeightDtl,

	cast(floor(CurrencyRate)as decimal(28,0)) AS CurrencyRate,

	PayType,ISNULL(C.ISOCode,'') AS CurrencyType, CAST (isnull(TPUnitID ,0) as nvarchar(50)) AS UnitID ,
	LTRIM(RTRIM(inv.FunGetGoodsCID( substring(D.GoodsID,@From,@To)))) as GoodsCId,pub.funGetGoodsName( substring(D.GoodsID,@From,@To),1) as GoodsName,substring(D.GoodsID,@From,@To),ISNULL(CAST(G.GoodsWeight as decimal),0) as GoodsWeight
	-- INTO BBBBBBB
	from (select D.* ,PayType ,CurrencyRate,TPInp,CurrencyTypeID,
			ISNULL(ROUND(
			case when @TotalPrice=1 and @Sal2=1 then 
				cast(SubUnitQuantity as float)
			else						
			CASE WHEN @2Qty=0 and @2Price=1 THEN cast(SubUnitQuantity2 as float) ELSE CASE WHEN @2Qty=0 and (@HasDST=1 or @Sal2=1 ) THEN cast(SubUnitQuantity as float) ELSE  cast(GoodsQuantity as float)  END END END,7,0),0) AS  QtyNew,	
			
			ISNULL(CAST(case when @TotalPrice=1 and @Sal2=1 then 
			case when GoodsQuantity=SubUnitQuantity then GoodsPrice else			SubUnitPrice2 end 
			else						
			CASE WHEN @2Qty=0 and @2Price=1 THEN SubUnitPrice2    ELSE CASE WHEN @2Qty=0 and (@HasDST=1 or @Sal2=1 ) THEN SubUnitPrice    ELSE  GoodsPrice    END END END AS float),0) AS PriceNew
			, DiscountDtl+ Case when DiscountTaxOverWorth=0 then 0 else TaxOverWorthCostDtl+DiscountDtlTaxToll+TollOverWorthCostDtl end  DiscountDtlAll
			from inv.tblStorageDocsDtl D
			inner JOIN inv.tblStorageDocsHdr H ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear	
			) D
	
	LEFT JOIN inv.tblGoods G ON G.GoodsID=substring(D.GoodsID,@From,@To) AND G.PartNumber= @PartNumber

	
	LEFT JOIN inv.tblUnits U ON U.UnitID = CASE WHEN @2Qty=0 and @2Price=1 THEN ISNULL((select top 1 SubUnitID 
	                                                                             FROM inv.tblSubUnitsDtl SU 
																				 WHERE SU.GoodsID=D.GoodsID  and ShowInInvoice=1  ),D.SubUnitID) ELSE D.SubUnitID  END



	LEFT JOIN pub.tblCurrencyTypes C ON C.CurrencyTypeID=D.CurrencyTypeID


	WHERE D.SerialNo=@SerialNo AND D.ProcessID=@ProcessId AND D.ProcessNo=@ProcessNo AND D.FiscalYear=@FiscalYear
	

	ORDER BY  D.SerialNo,D.DocRowNo

END TRY

BEGIN CATCH
	
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
