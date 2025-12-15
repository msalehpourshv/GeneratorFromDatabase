USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/10/05
-- Viewed By	 : 
-- Last Modified : 91/11/25
-- Description   : 
-- =============================================
CREATE PROCEDURE [prd].[spResturanDailyUses]
@FromDate as CHAR(10),
@ToDate as CHAR(10),
@FiscalYear as SMALLINT,
@BranchID AS VARCHAR(20)
WITH ENCRYPTION
 AS
BEGIN

BEGIN TRY

	BEGIN TRAN 
	DECLARE @maxSerialNo INT
	DECLARE @StoreID1 AS VARCHAR(20)
	DECLARE @StoreID2 AS VARCHAR(20)
	DECLARE @AcntCode AS VARCHAR(20)

	SET @maxSerialNo = 0

	SELECT @StoreID1 = StoreID1, @StoreID2 = StoreID2 
	FROM sal.tblBranches
	WHERE  BranchID=@BranchID

	SELECT @AcntCode= GoodsInProductionAcntCode 
	FROM inv.tblStores
	WHERE StoreID= @StoreID1

	SELECT @maxSerialNo = SerialNo
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=70 
	  AND ProcessNo=1
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1

	INSERT INTO inv.tblStorageDocsHdr
	(ProcessID, ProcessNo, FiscalYear, SerialNo, FormulaNo, DocStep, DocDate,
	StoreID, StoreID2, AcntCode, VisitorAcntCode, OrderAcntCode, CurrencyTypeID,
	CurrencyRate, Amount, DiscountPercent, Discount, Discount2, TotalLineDiscount,
	BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocType, VchNo,
	DocDesc, WageRate, ProductCount, ProductID, AgreeNo, RecID, SessionNo,
	SaleTypeID, TransporterID, LocationID, TransportationCost, PackingCost,
	TaxCost, VisitorCostAcntCode, VisitorPercent, VisitorCost, DiscountAcntCode,
	EarnestMoney, EarnestMoneyPercent, EarnestMoneyAcntCode, BatchNo,BRN,
	TransportationCostAcntCode, Price, TaxOverWorthCost, VchNo2, IsConfirmed,
	SettlementDate, TransportationIncomeAcntCode, TransportationIncome,
	OtherCostAcntCode, OtherIncomeAcntCode, OtherCost, OtherIncome, DocDate2,
	DocDate3, DocDate4, AfterSaleDiscount, AfterSaleDesc, AfterSaleVchNo,
	AfterSaleDate, OldSerialNo, HardRecivable, IsAutoDoc,
	AfterSaleDiscountAcntCode, VchDate, SessionNo2, SessionNo3, SessionNo4,
	SessionNo5, TollOverWorthCost, DriverID, DistributerID1, DistributerID2,
	BaseDistributionProcessID, BaseDistributionProcessNo,
	BaseDistributionFiscalYear, BaseDistributionSerialNo, DestinationAddress,
	BaseSaleSerialNo, DistributeCostAcntCode, DistributeAcntCode,
	DistributePercent, DistributeAmount, OwnerDocNo, FixCostAcntCode, FixCost,
	ConfirmReceipt, TransporterID2, CashAmount, ChequeAmount, [Address],
	CCNo, CCDiscount, CCPrivilege, SourceSerialNo,
	SourceProcessNo, DailyUsesBranchID, DiscountTaxOverWorth, ComssionCostPrice,
	BasculePrice, LaborPrice, TransportPrice)
	
	SELECT 70, 1, @FiscalYear, @maxSerialNo, 0, 1, @ToDate, @StoreID1, '', @AcntCode, '' VisitorAcntCode,
		  '' OrderAcntCode, '' CurrencyTypeID,0 CurrencyRate,0 Amount,0 DiscountPercent,0 Discount,0 Discount2, 
		  0 TotalLineDiscount,0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocType,0 VchNo, 
		   '' DocDesc,0 WageRate,0 ProductCount,'' ProductID,0 AgreeNo,0 RecID,0 SessionNo,'' SaleTypeID,'' TransporterID, 
		   '' LocationID,0 TransportationCost,0 PackingCost,0 TaxCost,'' VisitorCostAcntCode,0 VisitorPercent,0 VisitorCost, 
		   '' DiscountAcntCode,0 EarnestMoney,0 EarnestMoneyPercent,'' EarnestMoneyAcntCode,'' BatchNo,@BranchID BRN,
		   '' TransportationCostAcntCode,0 Price,0 TaxOverWorthCost,0 VchNo2,'' IsConfirmed,'' SettlementDate, 
		   '' TransportationIncomeAcntCode,0 TransportationIncome,'' OtherCostAcntCode,'' OtherIncomeAcntCode,0 OtherCost, 
		  0 OtherIncome,'' DocDate2,'' DocDate3,'' DocDate4,0 AfterSaleDiscount,'' AfterSaleDesc,0 AfterSaleVchNo, 
		   '' AfterSaleDate,0 OldSerialNo,'False' HardRecivable,'True' IsAutoDoc,'' AfterSaleDiscountAcntCode,'' VchDate,0 SessionNo2, 
		  0 SessionNo3,0 SessionNo4,0 SessionNo5,0 TollOverWorthCost,'' DriverID,'' DistributerID1,'' DistributerID2, 
		  0 BaseDistributionProcessID,0 BaseDistributionProcessNo,0 BaseDistributionFiscalYear, 
		  0 BaseDistributionSerialNo,'' DestinationAddress,0 BaseSaleSerialNo,'' DistributeCostAcntCode,'' DistributeAcntCode,
		  0 DistributePercent,0 DistributeAmount,0 OwnerDocNo,'' FixCostAcntCode,0 FixCost,'False' ConfirmReceipt,'' TransporterID2,
		  0 CashAmount,0 ChequeAmount,'' [Address],'' CCNo,0 CCDiscount,0 CCPrivilege,0 SourceSerialNo,0 SourceProcessNo,
		  '' DailyUsesBranchID,'False' DiscountTaxOverWorth,0 ComssionCostPrice,0 BasculePrice,0 LaborPrice,0 TransportPrice

	INSERT INTO inv.tblStorageDocsDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
	DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, StoreID2, AcntCode,
	VisitorAcntCode, OrderAcntCode, GoodsID, SubUnitID, SubUnitQuantity,
	GoodsQuantity, QtyRemain, GoodsAmount, AmntRemain, AtomAmount, GoodsPrice,
	DescDtl, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,
	BaseDocRowNo, BaseDocType, AgreeNo, BatchNo, DiscountPercentDtl, DiscountDtl,
	BaseDocDate, VirtualQuantity, IsReward, FormulaNo, GoodsID2, Wage, WageRate,
	FormulaProductCount, CurrencyAmount, CalculatingAmount, VchDate2, SubUnitPrice,
	UserGoodsAmount, [ExpireDate], SourceSerialNo, SourceProcessNo,
	DailyUsesBranchID, GoodsAmount1, GoodsAmount2, GoodsAmount3, GoodsAmount4,
	GoodsAmount5, GoodsAmount6, GoodsAmount7, GoodsAmount8, GoodsAmount9,
	GoodsAmount10, GoodsAmount11, GoodsAmount12, StoreVariable1, StoreVariable2,
	SalePrice, PhrBatchNo, GregorianExpireDate)
	
	select 70, 1, @FiscalYear, @maxSerialNo, ROW_NUMBER()OVER (ORDER BY fd.GoodsID) RowNo,ROW_NUMBER()OVER (ORDER BY r.GoodsID) DocRowNo, 
		   0, 1, @ToDate, @StoreID1, 'True', -1, '', @AcntCode, '', '', fd.GoodsID,g.UnitID SubUnitID,Qty*fd.GoodsQuantity /f.ProductCount  SubUnitQuantity,
		   Qty*fd.GoodsQuantity /f.ProductCount GoodsQuantity,0 QtyRemain,0 GoodsAmount,0 AmntRemain,0 AtomAmount,0 GoodsPrice,'' DescDtl,
		   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocRowNo,'' BaseDocType,0 AgreeNo,
		   '' BatchNo,0 DiscountPercentDtl,0 DiscountDtl,'' BaseDocDate,0 VirtualQuantity,'False' IsReward,
		   f.SerialNo,'' GoodsID2,0 Wage,0 WageRate,0 FormulaProductCount,0 CurrencyAmount,0 CalculatingAmount,
		   '' VchDate2,0 SubUnitPrice,0 UserGoodsAmount,'' [ExpireDate],0 SourceSerialNo,0 SourceProcessNo,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',''
	FROM (SELECT GoodsID,SUM(Qty) - 
				   (
		   			SELECT  ISNULL (Sum(GoodsQuantity * EnterKind), 0)
					FROM inv.tblStorageDocsDtl
					WHERE StoreID = StoreID2 AND GoodsID = sal.tblRestaurantSaleDtl.GoodsID AND DocDate <= @ToDate
					AND (FiscalYear = @FiscalYear OR (FiscalYear <> @FiscalYear AND EnterKind=1))
				   	) Qty
		  FROM sal.tblRestaurantSaleDtl 
		  WHERE DocDate>=@FromDate AND DocDate<=@ToDate
		  GROUP BY GoodsID
		 ) r
	INNER JOIN (select ProductID,SerialNo,ProductCount FROM prd.tblFormulasHdr WHERE IsDefault='True') f
	ON r.GoodsID=f.ProductID
	INNER JOIN  prd.tblFormulasDtl fd
	ON fd.ProductID=f.ProductID AND fd.SerialNo=f.SerialNo
	INNER JOIN inv.tblGoods g 
	ON g.GoodsID=fd.GoodsID
	WHERE Qty>0  AND fd.GoodsQuantity >0

	----------------
	SET @maxSerialNo = 0

	SELECT @maxSerialNo = SerialNo
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=80 
	  AND ProcessNo=1
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1

	INSERT INTO inv.tblStorageDocsHdr
	(ProcessID, ProcessNo, FiscalYear, SerialNo, FormulaNo, DocStep, DocDate,
	StoreID, StoreID2, AcntCode, VisitorAcntCode, OrderAcntCode, CurrencyTypeID,
	CurrencyRate, Amount, DiscountPercent, Discount, Discount2, TotalLineDiscount,
	BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocType, VchNo,
	DocDesc, WageRate, ProductCount, ProductID, AgreeNo, RecID, SessionNo,
	SaleTypeID, TransporterID, LocationID, TransportationCost, PackingCost,
	TaxCost, VisitorCostAcntCode, VisitorPercent, VisitorCost, DiscountAcntCode,
	EarnestMoney, EarnestMoneyPercent, EarnestMoneyAcntCode, BatchNo,BRN,
	TransportationCostAcntCode, Price, TaxOverWorthCost, VchNo2, IsConfirmed,
	SettlementDate, TransportationIncomeAcntCode, TransportationIncome,
	OtherCostAcntCode, OtherIncomeAcntCode, OtherCost, OtherIncome, DocDate2,
	DocDate3, DocDate4, AfterSaleDiscount, AfterSaleDesc, AfterSaleVchNo,
	AfterSaleDate, OldSerialNo, HardRecivable, IsAutoDoc,
	AfterSaleDiscountAcntCode, VchDate, SessionNo2, SessionNo3, SessionNo4,
	SessionNo5, TollOverWorthCost, DriverID, DistributerID1, DistributerID2,
	BaseDistributionProcessID, BaseDistributionProcessNo,
	BaseDistributionFiscalYear, BaseDistributionSerialNo, DestinationAddress,
	BaseSaleSerialNo, DistributeCostAcntCode, DistributeAcntCode,
	DistributePercent, DistributeAmount, OwnerDocNo, FixCostAcntCode, FixCost,
	ConfirmReceipt, TransporterID2, CashAmount, ChequeAmount, [Address],
	CCNo, CCDiscount, CCPrivilege, SourceSerialNo,
	SourceProcessNo, DailyUsesBranchID, DiscountTaxOverWorth, ComssionCostPrice,
	BasculePrice, LaborPrice, TransportPrice)
	
	SELECT 80, 1, @FiscalYear, @maxSerialNo, 0, 1, @ToDate, @StoreID2, '', @AcntCode, '' VisitorAcntCode,
		  '' OrderAcntCode, '' CurrencyTypeID,0 CurrencyRate,0 Amount,0 DiscountPercent,0 Discount,0 Discount2, 
		  0 TotalLineDiscount,0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocType,0 VchNo, 
		   '' DocDesc,0 WageRate,0 ProductCount,'' ProductID,0 AgreeNo,0 RecID,0 SessionNo,'' SaleTypeID,'' TransporterID, 
		   '' LocationID,0 TransportationCost,0 PackingCost,0 TaxCost,'' VisitorCostAcntCode,0 VisitorPercent,0 VisitorCost, 
		   '' DiscountAcntCode,0 EarnestMoney,0 EarnestMoneyPercent,'' EarnestMoneyAcntCode,'' BatchNo,@BranchID BRN,
		   '' TransportationCostAcntCode,0 Price,0 TaxOverWorthCost,0 VchNo2,'' IsConfirmed,'' SettlementDate, 
		   '' TransportationIncomeAcntCode,0 TransportationIncome,'' OtherCostAcntCode,'' OtherIncomeAcntCode,0 OtherCost, 
		  0 OtherIncome,'' DocDate2,'' DocDate3,'' DocDate4,0 AfterSaleDiscount,'' AfterSaleDesc,0 AfterSaleVchNo, 
		   '' AfterSaleDate,0 OldSerialNo,'False' HardRecivable,'True' IsAutoDoc,'' AfterSaleDiscountAcntCode,'' VchDate,0 SessionNo2, 
		  0 SessionNo3,0 SessionNo4,0 SessionNo5,0 TollOverWorthCost,'' DriverID,'' DistributerID1,'' DistributerID2, 
		  0 BaseDistributionProcessID,0 BaseDistributionProcessNo,0 BaseDistributionFiscalYear, 
		  0 BaseDistributionSerialNo,'' DestinationAddress,0 BaseSaleSerialNo,'' DistributeCostAcntCode,'' DistributeAcntCode,
		  0 DistributePercent,0 DistributeAmount,0 OwnerDocNo,'' FixCostAcntCode,0 FixCost,'False' ConfirmReceipt,'' TransporterID2,
		  0 CashAmount,0 ChequeAmount,'' [Address],'' CCNo,0 CCDiscount,0 CCPrivilege ,0 SourceSerialNo,0 SourceProcessNo,
		  '' DailyUsesBranchID,'False' DiscountTaxOverWorth,0 ComssionCostPrice,0 BasculePrice,0 LaborPrice,0 TransportPrice
		  
	INSERT INTO inv.tblStorageDocsDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
	DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, StoreID2, AcntCode,
	VisitorAcntCode, OrderAcntCode, GoodsID, SubUnitID, SubUnitQuantity,
	GoodsQuantity, QtyRemain, GoodsAmount, AmntRemain, AtomAmount, GoodsPrice,
	DescDtl, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,
	BaseDocRowNo, BaseDocType, AgreeNo, BatchNo, DiscountPercentDtl, DiscountDtl,
	BaseDocDate, VirtualQuantity, IsReward, FormulaNo, GoodsID2, Wage, WageRate,
	FormulaProductCount, CurrencyAmount, CalculatingAmount, VchDate2, SubUnitPrice,
	UserGoodsAmount, [ExpireDate], SourceSerialNo, SourceProcessNo,
	DailyUsesBranchID, GoodsAmount1, GoodsAmount2, GoodsAmount3, GoodsAmount4,
	GoodsAmount5, GoodsAmount6, GoodsAmount7, GoodsAmount8, GoodsAmount9,
	GoodsAmount10, GoodsAmount11, GoodsAmount12, StoreVariable1, StoreVariable2,
	SalePrice, PhrBatchNo, GregorianExpireDate)
	
	select 80, 1, @FiscalYear, @maxSerialNo, ROW_NUMBER()OVER (ORDER BY r.GoodsID) RowNo,ROW_NUMBER()OVER (ORDER BY r.GoodsID) DocRowNo, 
		   0, 1, @ToDate, @StoreID2, 'True', +1, '', @AcntCode, '', '', r.GoodsID,UnitID SubUnitID,Qty SubUnitQuantity,
		   Qty GoodsQuantity,0 QtyRemain,0 GoodsAmount,0 AmntRemain,0 AtomAmount,0 GoodsPrice,'' DescDtl,
		   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocRowNo,'' BaseDocType,0 AgreeNo,
		   '' BatchNo,0 DiscountPercentDtl,0 DiscountDtl,'' BaseDocDate,0 VirtualQuantity,'False' IsReward,
		   f.SerialNo,'' GoodsID2,0 Wage,0 WageRate,0 FormulaProductCount,0 CurrencyAmount,0 CalculatingAmount,
		   '' VchDate2,0 SubUnitPrice,0 UserGoodsAmount,'' [ExpireDate],0 SourceSerialNo,0 SourceProcessNo,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',''
	FROM (SELECT GoodsID,SUM(Qty) - 
				   (
		   			SELECT  ISNULL (Sum(GoodsQuantity * EnterKind), 0)
					FROM inv.tblStorageDocsDtl
					WHERE StoreID = StoreID2 AND GoodsID = sal.tblRestaurantSaleDtl.GoodsID AND DocDate <= @ToDate
					AND (FiscalYear = @FiscalYear OR (FiscalYear <> @FiscalYear AND EnterKind=1))
				   	) Qty
		  FROM sal.tblRestaurantSaleDtl 
		  WHERE DocDate>=@FromDate AND DocDate<=@ToDate
		  GROUP BY GoodsID
		 ) r
	INNER JOIN (select ProductID,SerialNo FROM prd.tblFormulasHdr WHERE IsDefault='True') f
	ON r.GoodsID=f.ProductID
	INNER JOIN inv.tblGoods g 
	ON r.GoodsID=g.GoodsID
	WHERE Qty>0 

	------------------
	SET @maxSerialNo = 0

	SELECT @maxSerialNo = SerialNo
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=90 
	  AND ProcessNo=1
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo + 1

	INSERT INTO inv.tblStorageDocsHdr
		(ProcessID, ProcessNo, FiscalYear, SerialNo, FormulaNo, DocStep, DocDate,
	StoreID, StoreID2, AcntCode, VisitorAcntCode, OrderAcntCode, CurrencyTypeID,
	CurrencyRate, Amount, DiscountPercent, Discount, Discount2, TotalLineDiscount,
	BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocType, VchNo,
	DocDesc, WageRate, ProductCount, ProductID, AgreeNo, RecID, SessionNo,
	SaleTypeID, TransporterID, LocationID, TransportationCost, PackingCost,
	TaxCost, VisitorCostAcntCode, VisitorPercent, VisitorCost, DiscountAcntCode,
	EarnestMoney, EarnestMoneyPercent, EarnestMoneyAcntCode, BatchNo, BRN,
	TransportationCostAcntCode, Price, TaxOverWorthCost, VchNo2, IsConfirmed,
	SettlementDate, TransportationIncomeAcntCode, TransportationIncome,
	OtherCostAcntCode, OtherIncomeAcntCode, OtherCost, OtherIncome, DocDate2,
	DocDate3, DocDate4, AfterSaleDiscount, AfterSaleDesc, AfterSaleVchNo,
	AfterSaleDate, OldSerialNo, HardRecivable, IsAutoDoc,
	AfterSaleDiscountAcntCode, VchDate, SessionNo2, SessionNo3, SessionNo4,
	SessionNo5, TollOverWorthCost, DriverID, DistributerID1, DistributerID2,
	BaseDistributionProcessID, BaseDistributionProcessNo,
	BaseDistributionFiscalYear, BaseDistributionSerialNo, DestinationAddress,
	BaseSaleSerialNo, DistributeCostAcntCode, DistributeAcntCode,
	DistributePercent, DistributeAmount, OwnerDocNo, FixCostAcntCode, FixCost,
	ConfirmReceipt, TransporterID2, CashAmount, ChequeAmount, [Address],
	CCNo, CCDiscount, CCPrivilege, SourceSerialNo,
	SourceProcessNo, DailyUsesBranchID, DiscountTaxOverWorth, ComssionCostPrice,
	BasculePrice, LaborPrice, TransportPrice)
	
	SELECT 90, 11, @FiscalYear, @maxSerialNo, 0, 3, @ToDate, @StoreID2, '', @AcntCode, '' VisitorAcntCode,
		  '' OrderAcntCode, '' CurrencyTypeID,0 CurrencyRate,0 Amount,0 DiscountPercent,0 Discount,0 Discount2, 
		  0 TotalLineDiscount,0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocType,0 VchNo, 
		   '' DocDesc,0 WageRate,0 ProductCount,'' ProductID,0 AgreeNo,0 RecID,0 SessionNo,'' SaleTypeID,'' TransporterID, 
		   '' LocationID,0 TransportationCost,0 PackingCost,0 TaxCost,'' VisitorCostAcntCode,0 VisitorPercent,0 VisitorCost, 
		   '' DiscountAcntCode,0 EarnestMoney,0 EarnestMoneyPercent,'' EarnestMoneyAcntCode,'' BatchNo, @BranchID BRN,
		   '' TransportationCostAcntCode,0 Price,0 TaxOverWorthCost,0 VchNo2,'' IsConfirmed,'' SettlementDate, 
		   '' TransportationIncomeAcntCode,0 TransportationIncome,'' OtherCostAcntCode,'' OtherIncomeAcntCode,0 OtherCost, 
		  0 OtherIncome,'' DocDate2,'' DocDate3,'' DocDate4,0 AfterSaleDiscount,'' AfterSaleDesc,0 AfterSaleVchNo, 
		   '' AfterSaleDate,0 OldSerialNo,'False' HardRecivable,'True' IsAutoDoc,'' AfterSaleDiscountAcntCode,'' VchDate,0 SessionNo2, 
		  0 SessionNo3,0 SessionNo4,0 SessionNo5,0 TollOverWorthCost,'' DriverID,'' DistributerID1,'' DistributerID2, 
		  0 BaseDistributionProcessID,0 BaseDistributionProcessNo,0 BaseDistributionFiscalYear, 
		  0 BaseDistributionSerialNo,'' DestinationAddress,0 BaseSaleSerialNo,'' DistributeCostAcntCode,'' DistributeAcntCode,
		  0 DistributePercent,0 DistributeAmount,0 OwnerDocNo,'' FixCostAcntCode,0 FixCost,'False' ConfirmReceipt,'' TransporterID2,
		  0 CashAmount,0 ChequeAmount,'' [Address],'' CCNo,0 CCDiscount,0 CCPrivilege ,0 SourceSerialNo,0 SourceProcessNo,
		  '' DailyUsesBranchID,'False' DiscountTaxOverWorth,0 ComssionCostPrice,0 BasculePrice,0 LaborPrice,0 TransportPrice
		  
	INSERT INTO inv.tblStorageDocsDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
	DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, StoreID2, AcntCode,
	VisitorAcntCode, OrderAcntCode, GoodsID, SubUnitID, SubUnitQuantity,
	GoodsQuantity, QtyRemain, GoodsAmount, AmntRemain, AtomAmount, GoodsPrice,
	DescDtl, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,
	BaseDocRowNo, BaseDocType, AgreeNo, BatchNo, DiscountPercentDtl, DiscountDtl,
	BaseDocDate, VirtualQuantity, IsReward, FormulaNo, GoodsID2, Wage, WageRate,
	FormulaProductCount, CurrencyAmount, CalculatingAmount, VchDate2, SubUnitPrice,
	UserGoodsAmount, [ExpireDate], SourceSerialNo, SourceProcessNo,
	DailyUsesBranchID, GoodsAmount1, GoodsAmount2, GoodsAmount3, GoodsAmount4,
	GoodsAmount5, GoodsAmount6, GoodsAmount7, GoodsAmount8, GoodsAmount9,
	GoodsAmount10, GoodsAmount11, GoodsAmount12, StoreVariable1, StoreVariable2,
	SalePrice, PhrBatchNo, GregorianExpireDate)
	
	select 90, 11, @FiscalYear, @maxSerialNo, ROW_NUMBER()OVER (ORDER BY r.GoodsID) RowNo,ROW_NUMBER()OVER (ORDER BY r.GoodsID) DocRowNo, 
		   0, 3, @ToDate, r.StoreID, 'True', -1, '', @AcntCode, '', '', r.GoodsID,UnitID SubUnitID,Qty SubUnitQuantity,
		   Qty GoodsQuantity,0 QtyRemain,0 GoodsAmount,0 AmntRemain,0 AtomAmount,Price GoodsPrice,'' DescDtl,
		   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocRowNo,'' BaseDocType,0 AgreeNo,
		   '' BatchNo,0 DiscountPercentDtl,0 DiscountDtl,'' BaseDocDate,0 VirtualQuantity,'False' IsReward,
		   0,'' GoodsID2,0 Wage,0 WageRate,0 FormulaProductCount,0 CurrencyAmount,0 CalculatingAmount,
		   '' VchDate2,0 SubUnitPrice,0 UserGoodsAmount,'' [ExpireDate],0 SourceSerialNo,0 SourceProcessNo,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',''
	FROM (SELECT d.GoodsID,h.StoreID ,d.Price ,SUM(d.Qty) Qty
		  FROM sal.tblRestaurantSaleDtl d 
		  INNER JOIN sal.tblRestaurantSaleHdr h
		  ON  h.ProcessID = d.ProcessID 
		  AND h.ProcessNo = d.ProcessNo 
		  AND h.FiscalYear = d.FiscalYear 
		  AND h.SerialNo = d.SerialNo
		  AND h.BranchID = d.BranchID
		  AND h.DocDate = d.DocDate
		  WHERE d.DocDate>=@FromDate AND d.DocDate<=@ToDate
		  GROUP BY  d.GoodsID,h.StoreID ,d.Price
		 ) r
	INNER JOIN inv.tblGoods g 
	ON r.GoodsID=g.GoodsID

	INSERT INTO sal.tblResturanDailyUses
	VALUES(@BranchID,@ToDate)
	COMMIT TRAN
END TRY
BEGIN CATCH

	ROLLBACK TRAN
	Declare @StrErrorMessage As Nvarchar(1024)
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
