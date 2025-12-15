USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/06/16
-- Viewed By	 : 
-- Last Modified : 1392/06/13
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
Create FUNCTION [inv].[funStorageDtl_Group_Currency]
(
	@GoodsGroup as int
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	SELECT D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, MAX(D.RowNo) RowNo, MAX(D.DocRowNo)DocRowNo,
		   MAX(D.VolumeRowNo)VolumeRowNo, MAX(D.DocStep) DocStep, MAX(D.DocDate) DocDate, D.StoreID,D.PhysicallyEffected,
		   -1 EnterKind, '' StoreID2, D.AcntCode,D.VisitorAcntCode, D.OrderAcntCode, SUBSTRING(D.GoodsID,1,
		   @GoodsGroup)GoodsID, D.SubUnitID, D.SaleTypeID, D.VisitorPercent, D.VisitorPercent2,SUM(D.SubUnitQuantity) SubUnitQuantity,
		   SUM(D.GoodsQuantity) GoodsQuantity, 0 QtyRemain, '' GoodsID3, 0 GoodsQuantity3, 0 SubUnitQuantity3, 0 GoodsPrice3,
		   0 SubUnitID3, 0 Height, 0 Width, 0 ServiceAmount, 0 Price0,
		   CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.GoodsAmount GoodsAmount,
		   CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.GoodsPrice GoodsPrice,
		   0 AmntRemain,0 AtomAmount, '' DescDtl, 0 BaseProcessID, 0 BaseProcessNo, 0 BaseFiscalYear, 0 BaseSerialNo, 
		   0 BaseDocRowNo, 0 BaseDocType, 0 AgreeNo, D.BatchNo, 0 DiscountPercentDtl, SUM(DiscountDtl) DiscountDtl, 
		   '' BaseDocDate, 0 VirtualQuantity, 0 IsReward, D.FormulaNo, '' GoodsID2, 0 Wage, 0 WageRate, 
		   0 FormulaProductCount, CurrencyAmount, 0 CalculatingAmount, '' VchDate2, 
		   CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.SubUnitPrice SubUnitPrice, 
		   CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.SubUnitPrice2 SubUnitPrice2, 
		   D.UserGoodsAmount, 0 TaxOverWorthCostDtl, 0 TollOverWorthCostDtl,'' [ExpireDate],Sum(StoreVariable1)  StoreVariable1, 
		   Sum(StoreVariable2) StoreVariable2, 0 Var1, 0 Var2, 0 Var3, 0 Var4,'' ProductSerialID, '' BatchNo2, '' ExpireDate2, 
		   '' ConstText1, '' ConstText2, '' ConstText3, '' ConstText4, GBarCode, 0 UserPriceID
		,KotagNo,KotagDate,AssessmentLocation,ExitLocation ,H.PriceParvane	,CustomerCode,OtherIncomePerentDtl,OtherIncomeDtl
		,GoodsPriceWithTax,PurePrice,DistributionPercent,DistributionPrice
	FROM inv.tblStorageDocsDtl D
	INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
	GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,D.StoreID, D.PhysicallyEffected,D.AcntCode,CurrencyAmount, 
			 D.VisitorAcntCode, D.OrderAcntCode, SUBSTRING(D.GoodsID,1,@GoodsGroup), D.SubUnitID, D.SaleTypeID,
			 D.VisitorPercent,D.VisitorPercent2, D.GoodsAmount,D.GoodsPrice,D.BatchNo, D.FormulaNo,D.SubUnitPrice,D.SubUnitPrice2,D.UserGoodsAmount,
			 H.CurrencyRate,GBarCode,KotagNo,KotagDate,AssessmentLocation,ExitLocation,H.PriceParvane ,CustomerCode,OtherIncomePerentDtl,OtherIncomeDtl
			 ,GoodsPriceWithTax,PurePrice,DistributionPercent,DistributionPrice
)
GO
