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
CREATE  PROCEDURE [inv].[sp_api_TakroSystem_GetConfirmedPosSaleDtl]
@ProcessId AS INT,
@ProcessNo AS INT,
@SerialNo AS INT,
@FiscalYear AS INT

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @TaxOverWorthPercentInSale  INT
	DECLARE @TollOverWorthPercentInSale INT
	DECLARE @From  INT
	DECLARE @To  INT
	DECLARE @PartNumber  INT
	DECLARE @Len1  INT
	DECLARE @Len2  INT
	DECLARE @Len3  INT
	DECLARE @Len4  INT
	DECLARE @TotalPrice BIT
	DECLARE @2Qty BIT
	DECLARE @2Price BIT
	DECLARE @Sal2 BIT
	DECLARE @HasDST BIT
BEGIN TRY

BEGIN ---Check Price And Quntity From Setting AND  Check GoodsLayer
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

	SELECT   @PartNumber=ISNULL(SettingValue,0) FROM  pub.tblSettings
	WHERE SettingKey = 'UnitPart' and 1=1

	SELECT   @Len1=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 FROM  pub.tblCodeLayer WHERE TableName='inv.tblGoods' and PartNumber=1 
	SELECT   @Len2=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 FROM  pub.tblCodeLayer WHERE TableName='inv.tblGoods' and PartNumber=2
	SELECT   @Len3=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 FROM  pub.tblCodeLayer WHERE TableName='inv.tblGoods' and PartNumber=3 
	SELECT   @Len4=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 FROM  pub.tblCodeLayer WHERE TableName='inv.tblGoods' and PartNumber=4
	
	IF(@PartNumber=0)
	 SET @PartNumber=1

	IF(@PartNumber=1)
	BEGIN
	 SET @To=@Len1
	 SET @From= 1
	END 

	IF(@PartNumber=2)
	BEGIN
	 SET @To=@Len2
	 SET @From= @Len1+1
	END 

	IF(@PartNumber=3)
	BEGIN
	 SET @To=@Len3
	 SET @From= @Len1+@Len2+1
	END 

	IF(@PartNumber=4)
	BEGIN
	 SET @To=@Len4
	 SET @From= @Len1+@Len2+@Len3+1
	END 
END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	SELECT
	-------------------------------------------------محاسبه مبلغ نقدي-------------------------------------------------------------
	
	CAST(FLOOR(PriceNew*QtyNew -
	CASE WHEN MaxRow=R THEN DistributedDiscount+(DiscountAmount-TotalDistributedDiscount) 
	ELSE DistributedDiscount END +DiscountDtl)AS DECIMAL)	AS Cop,
	--------------------------------------------محاسبه مبالغ-------------------------------------------------------------------

	QtyNew AS SubUnitQuantity,
	
	PriceNew GoodsPrice,

	CAST(pub.funDecimalPlace(CurrencyAmount, 4)AS DECIMAL(28,4)) AS CurrencyAmount,

	CASE 
	WHEN CurrencyRate=0 THEN CAST(0 AS DECIMAL)
	WHEN CurrencyRate<>0 THEN CAST(pub.funDecimalPlace(((PriceNew*QtyNew) / CurrencyRate ),4) AS DECIMAL(28,4))
	END  AS Sscv,

	CAST(FLOOR(QtyNew*PriceNew) AS DECIMAL(28,0)) AS PriceBeforDiscount,

	CAST(FLOOR(
	CASE WHEN MaxRow=R THEN DistributedDiscount+(DiscountAmount-TotalDistributedDiscount) 
	ELSE DistributedDiscount END +DiscountDtl)AS DECIMAL(28,0)) AS DiscountDtl,

	CAST(FLOOR(PriceNew*QtyNew -
	CASE WHEN MaxRow=R THEN DistributedDiscount+(DiscountAmount-TotalDistributedDiscount) 
	ELSE DistributedDiscount END +DiscountDtl) AS DECIMAL(28,0)) AS PriceAfterDiscount,
	---------------------------------TaxOverWorth

	CAST(FLOOR(
	(PriceNew*QtyNew -CASE WHEN MaxRow=R THEN DistributedDiscount+(DiscountAmount-TotalDistributedDiscount) 
					  ELSE DistributedDiscount END +DiscountDtl)*
	CASE 
	WHEN G.Tax<>0 THEN G.Tax
	WHEN G.NotContainTax=1 THEN 0
	WHEN G.NotContainTax=0 and G.Tax=0 THEN @TaxOverWorthPercentInSale+@TollOverWorthPercentInSale
	END  /100) AS DECIMAL(28,0)) AS TaxOverWorth,
	--------------------------------
	CAST(
	FLOOR(PriceNew*QtyNew -CASE WHEN MaxRow=R THEN DistributedDiscount+(DiscountAmount-TotalDistributedDiscount) 
						   ELSE DistributedDiscount END +DiscountDtl)+
	FLOOR(
	(PriceNew*QtyNew -CASE WHEN MaxRow=R THEN DistributedDiscount+(DiscountAmount-TotalDistributedDiscount) 
					  ELSE DistributedDiscount END +DiscountDtl
	)*
	CASE 
	WHEN G.Tax<>0 THEN G.Tax
	WHEN G.NotContainTax=1 THEN 0
	WHEN G.NotContainTax=0 and G.Tax=0 THEN @TaxOverWorthPercentInSale+@TollOverWorthPercentInSale
	END  /100)
	AS DECIMAL(28,0)) AS Amount,

	--------------------------------------------------- مالیات	درصد------------------------------------------------------------------	
	CASE 
	WHEN ISNULL(G.NotContainTax,0)=1 THEN 0
	WHEN QtyNew*PriceNew=DiscountDtl THEN
		CASE
			WHEN CAST(ISNULL(G.Tax,0)+ISNULL(G.Toll,0) AS DECIMAL)=0  THEN  CAST(@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale AS DECIMAL)
		    WHEN CAST(ISNULL(G.Tax ,0)+ISNULL(G.Toll ,0)AS DECIMAL)<>0 THEN CAST( ISNULL(G.Tax,0 )+ISNULL(G.Toll,0 ) AS DECIMAL) 
		END 
	WHEN CAST(ISNULL(G.Tax,0)+ISNULL(G.Toll,0) AS DECIMAL)=0  THEN  CAST(@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale AS DECIMAL)
	WHEN CAST(ISNULL(G.Tax ,0)+ISNULL(G.Toll ,0)AS DECIMAL)<>0 THEN CAST( ISNULL(G.Tax,0 )+ISNULL(G.Toll,0 ) AS DECIMAL)
	END  Tax,

	----------------------------------------------------فیلد های دیگر----------------------------------------------------------
	CommissionerContractID,	CAST(0 AS DECIMAL) AS WeightDtl,

	CAST(FLOOR(CurrencyRate)AS DECIMAL(28,0)) AS CurrencyRate,

	PayType,ISNULL(C.ISOCode,'') AS CurrencyType,CAST(ISNULL(TPUnitID ,0) AS nvarchar(50)) AS UnitID ,
	LTRIM(RTRIM(inv.FunGetGoodsCID( SUBSTRING(D.GoodsID,@From,@To)))) AS GoodsCId,
	pub.funGetGoodsName( SUBSTRING(D.GoodsID,@From,@To),1) AS GoodsName,
	SUBSTRING(D.GoodsID,@From,@To),ISNULL(CAST(G.GoodsWeight AS DECIMAL),0) AS GoodsWeight
	-- INTO BBBBBBB
		FROM (     SELECT SUM(DistributedDiscount)over(partition by ProcessID,ProcessNo,FiscalYear,SerialNo,BranchID order by ProcessID,ProcessNo,FiscalYear,SerialNo,BranchID) TotalDistributedDiscount,
				   MAX(R)over(partition by ProcessID,ProcessNo,FiscalYear,SerialNo,BranchID order by ProcessID,ProcessNo,FiscalYear,SerialNo,BranchID) MaxRow,* 
			FROM  (SELECT   D.* ,PayType ,CurrencyRate,TPInp,CurrencyTypeID,
					--R
					ROW_NUMBER()over (partition by D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.BranchID order by D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.BranchID,RowNo ) R,
					--DiscountAmount
					Discount+Discount2+Discount3 DiscountAmount,	
					--DistributedDiscount
					ROUND( ((
					(D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 and G.Tax=0 THEN 100+@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END )			
					*GoodsQuantity-DiscountDtl) / ed.TotalAmount) * (Discount+Discount2+Discount3),0) AS DistributedDiscount, -- سرشکن به نسبت Amount
					--TotalPure
					((D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 and G.Tax=0 THEN 100+@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END )
					*GoodsQuantity)-DiscountDtl- ROUND( ((
					(D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 and G.Tax=0 THEN 100+@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END )
					*GoodsQuantity-DiscountDtl) / ed.TotalAmount) * (Discount+Discount2+Discount3),0) TotalPure,
					--QTY
					ISNULL(ROUND( CAST(GoodsQuantity AS float),7,0),0) AS  QtyNew,	
					--PRICENEW
					ISNULL(CAST(D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 and G.Tax=0 THEN 100+@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END 
					AS DECIMAL(28,7)),0) AS PriceNew,
					--MainPrice
					ISNULL(CAST(D.GoodsPrice  AS DECIMAL(28,7)),0) AS MainPrice
					FROM  inv.tblStorageDocsDtl D
					LEFT JOIN inv.tblGoods G ON G.GoodsID=SUBSTRING(D.GoodsID,@From,@To) AND G.PartNumber= @PartNumber
					INNER JOIN inv.tblStorageDocsHdr H ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear	
					INNER JOIN 
						(SELECT D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,
							SUM((D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 and G.Tax=0 THEN 100+@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END )
						    *GoodsQuantity-DiscountDtl) AS TotalAmount
						 FROM inv.tblStorageDocsDtl D
						 INNER JOIN inv.tblGoods G  ON D.GoodsID=G.GoodsID
						 INNER JOIN inv.tblStorageDocsHdr H 
						 ON D.ProcessID =H.ProcessID  AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo 
						 WHERE (Discount+Discount2+Discount3)> 0 and  NotDiscount = 0 and 
							(D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 and G.Tax=0 THEN 100+@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END )*
						    GoodsQuantity-DiscountDtl<>0-- فقط رکوردهایی که شامل سرشکن می‌شوند
						 GROUP BY D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.BranchID
						 ) ed ON D.ProcessID =ed.ProcessID  AND D.ProcessNo=ed.ProcessNo AND D.FiscalYear=ed.FiscalYear and D.SerialNo=ed.SerialNo 
			) D
		)D
	
	LEFT JOIN inv.tblGoods G ON G.GoodsID=SUBSTRING(D.GoodsID,@From,@To) AND G.PartNumber= @PartNumber

	
	LEFT JOIN inv.tblUnits U ON U.UnitID = CASE WHEN @2Qty=0 and @2Price=1 THEN ISNULL((select top 1 SubUnitID 
	                                                                             FROM inv.tblSubUnitsDtl SU 
																				 WHERE SU.GoodsID=D.GoodsID  and ShowInInvoice=1  ),D.SubUnitID) ELSE D.SubUnitID  END


	LEFT JOIN pub.tblCurrencyTypes C ON C.CurrencyTypeID=D.CurrencyTypeID

	WHERE D.SerialNo=@SerialNo AND D.ProcessID=@ProcessId AND D.ProcessNo=@ProcessNo AND D.FiscalYear=@FiscalYear
	
	ORDER BY  D.SerialNo,D.DocRowNo

END  TRY

BEGIN CATCH
	
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END  CATCH

END 	

GO
