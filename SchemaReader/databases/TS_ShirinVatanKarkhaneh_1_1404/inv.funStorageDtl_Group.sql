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
Create FUNCTION [inv].[funStorageDtl_Group]
(
	@GoodsGroup as int,
	@Type		as int
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
( 
	SELECT D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, MAX(D.RowNo) RowNo, MAX(D.DocRowNo)DocRowNo, 0 Price0,
		   MAX(D.VolumeRowNo)VolumeRowNo, MAX(D.DocStep) DocStep, MAX(D.DocDate) DocDate, D.StoreID, D.PhysicallyEffected, 
		   -1 EnterKind, '' StoreID2, D.AcntCode, D.VisitorAcntCode, D.OrderAcntCode, SUBSTRING(D.GoodsID, 1, @GoodsGroup) GoodsID, 
		   D.SubUnitID, D.SaleTypeID, D.VisitorPercent,D.VisitorPercent2,SUM(D.SubUnitQuantity)SubUnitQuantity ,SUM(D.GoodsQuantity) GoodsQuantity,
		   0 QtyRemain,D.GoodsAmount ,0 AmntRemain,0 AtomAmount, D.GoodsPrice ,'' DescDtl, 0 BaseProcessID, 0 BaseProcessNo, 
		   0 BaseFiscalYear, 0 BaseSerialNo, 0 BaseDocRowNo,0 BaseDocType, 0 AgreeNo, D.BatchNo, 0 DiscountPercentDtl, 
		   SUM(DiscountDtl) DiscountDtl,''  BaseDocDate, 0 VirtualQuantity, 0 IsReward, D.FormulaNo,'' GoodsID2,0 Wage,
		   0 WageRate, 0 FormulaProductCount,0 CurrencyAmount, 0 CalculatingAmount, '' VchDate2, D.SubUnitPrice, D.SubUnitPrice2, D.UserGoodsAmount, 
		   SUM(TaxOverWorthCostDtl) TaxOverWorthCostDtl, SUM(TollOverWorthCostDtl) TollOverWorthCostDtl,'' [ExpireDate], 0 Var1, 0 Var2, 0 Var3, 0 Var4, '' ProductSerialID,
		   '' BatchNo2, '' ExpireDate2, Sum(StoreVariable1) StoreVariable1, Sum(StoreVariable2) StoreVariable2,
		   '' ConstText1, '' ConstText2, '' ConstText3, '' ConstText4, PayOffTypeID, D.GoodsID3, GoodsPrice3, GoodsQuantity3,
		   SubUnitQuantity3, SubUnitID3, Height, Width, ServiceAmount,D.UserPriceID, H.AcntCode CustomerCode , GBarCode
		   ,KotagNo,	KotagDate,AssessmentLocation,ExitLocation ,H.PriceParvane ,OtherIncomePerentDtl,OtherIncomeDtl
		   ,GoodsPriceWithTax,PurePrice,DistributionPercent,DistributionPrice
	FROM inv.tblStorageDocsDtl D
	INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
	LEFT JOIN inv.tblStorageDocsSerials SS ON 
			  SS.ProcessID = D.ProcessID AND SS.ProcessNo = D.ProcessNo AND SS.FiscalYear = D.FiscalYear AND 
			  SS.SerialNo = D.SerialNo And SS.DocRowNo = D.DocRowNo
	where @Type=0
	GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.StoreID,	D.PhysicallyEffected, D.AcntCode, 
			 D.VisitorAcntCode, D.OrderAcntCode, SubString(D.GoodsID, 1, @GoodsGroup), D.SubUnitID, D.SaleTypeID,
			 D.VisitorPercent, D.VisitorPercent2, D.GoodsAmount, D.GoodsPrice, D.BatchNo, D.FormulaNo, D.SubUnitPrice,D.SubUnitPrice2, D.UserGoodsAmount,
			 PayOffTypeID, D.GoodsID3, GoodsPrice3, GoodsQuantity3, SubUnitQuantity3, SubUnitID3, Height, Width, ServiceAmount,D.UserPriceID, H.AcntCode, GBarCode
			  ,KotagNo,	KotagDate,AssessmentLocation,ExitLocation ,H.PriceParvane,OtherIncomePerentDtl,OtherIncomeDtl
			  ,GoodsPriceWithTax,PurePrice,DistributionPercent,DistributionPrice
union all
	SELECT D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, MAX(D.RowNo) RowNo, MAX(D.DocRowNo)DocRowNo, 0 Price0,
		   MAX(D.VolumeRowNo)VolumeRowNo, MAX(D.DocStep) DocStep, MAX(D.DocDate) DocDate, D.StoreID, D.PhysicallyEffected, 
		   -1 EnterKind, '' StoreID2, D.AcntCode, D.VisitorAcntCode, D.OrderAcntCode, SUBSTRING(D.GoodsID, 1, @GoodsGroup) GoodsID, 
		   D.SubUnitID, D.SaleTypeID, D.VisitorPercent,D.VisitorPercent2, SUM(D.SubUnitQuantity)SubUnitQuantity,SUM(D.GoodsQuantity) GoodsQuantity,
		   0 QtyRemain,Sum(D.GoodsAmount *D.GoodsQuantity)/SUM(D.GoodsQuantity) GoodsAmount,0 AmntRemain,0 AtomAmount,Sum(D.GoodsPrice *D.GoodsQuantity)/SUM(D.GoodsQuantity) GoodsPrice
		   ,'' DescDtl, 0 BaseProcessID, 0 BaseProcessNo, 0 BaseFiscalYear, 0 BaseSerialNo, 0 BaseDocRowNo,0 BaseDocType, 0 AgreeNo, D.BatchNo,0 DiscountPercentDtl, 
		   SUM(DiscountDtl) DiscountDtl,''  BaseDocDate, 0 VirtualQuantity, 0 IsReward, D.FormulaNo,'' GoodsID2,0 Wage,
		   0 WageRate, 0 FormulaProductCount,0 CurrencyAmount, 0 CalculatingAmount, '' VchDate2,Sum(D.SubUnitPrice *D.SubUnitQuantity)/SUM(D.SubUnitQuantity) SubUnitPrice
		   ,Sum(D.SubUnitPrice2 *D.SubUnitQuantity)/SUM(D.SubUnitQuantity) SubUnitPrice2, D.UserGoodsAmount, 
		   SUM(TaxOverWorthCostDtl) TaxOverWorthCostDtl, SUM(TollOverWorthCostDtl) TollOverWorthCostDtl,'' [ExpireDate], 0 Var1, 0 Var2, 0 Var3, 0 Var4, '' ProductSerialID,
		   '' BatchNo2, '' ExpireDate2, Sum(StoreVariable1) StoreVariable1, Sum(StoreVariable2) StoreVariable2,
		   '' ConstText1, '' ConstText2, '' ConstText3, '' ConstText4, PayOffTypeID, D.GoodsID3, GoodsPrice3, GoodsQuantity3,
		   SubUnitQuantity3, SubUnitID3, Height, Width, ServiceAmount,0 UserPriceID, H.AcntCode CustomerCode , GBarCode
		   ,KotagNo,	KotagDate,AssessmentLocation,ExitLocation ,H.PriceParvane	,OtherIncomePerentDtl,OtherIncomeDtl
		   ,GoodsPriceWithTax,PurePrice,DistributionPercent,DistributionPrice
	FROM inv.tblStorageDocsDtl D
	INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
	LEFT JOIN inv.tblStorageDocsSerials SS ON 
			  SS.ProcessID = D.ProcessID AND SS.ProcessNo = D.ProcessNo AND SS.FiscalYear = D.FiscalYear AND 
			  SS.SerialNo = D.SerialNo And SS.DocRowNo = D.DocRowNo
			  where @Type=1
	GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.StoreID,	D.PhysicallyEffected, D.AcntCode, 
			 D.VisitorAcntCode, D.OrderAcntCode, SubString(D.GoodsID, 1, @GoodsGroup), D.SubUnitID, D.SaleTypeID,
			 D.VisitorPercent, D.VisitorPercent2, D.BatchNo, D.FormulaNo, D.UserGoodsAmount,
			 PayOffTypeID, D.GoodsID3, GoodsPrice3, GoodsQuantity3, SubUnitQuantity3, SubUnitID3, Height, Width, ServiceAmount
			 , H.AcntCode, GBarCode,KotagNo,	KotagDate,AssessmentLocation,ExitLocation ,H.PriceParvane,OtherIncomePerentDtl,OtherIncomeDtl
			 ,GoodsPriceWithTax,PurePrice,DistributionPercent,DistributionPrice
)
GO
