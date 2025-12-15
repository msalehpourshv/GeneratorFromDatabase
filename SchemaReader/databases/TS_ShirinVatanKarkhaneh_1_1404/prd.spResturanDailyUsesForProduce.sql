USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 98/05/07
-- Viewed By	 : 
-- Last Modified : 98/05/07
-- Description   : 
-- =============================================
Create PROCEDURE prd.spResturanDailyUsesForProduce
@FromDate as CHAR(10),
@ToDate as CHAR(10),
@FiscalYear as SMALLINT,
@BranchID AS NVARCHAR(20),
@GoodsID AS VARCHAR(20),
@Qty AS FLOAT,
@IsMainProduct as BIT

WITH ENCRYPTION
 AS
BEGIN

BEGIN TRY

	BEGIN TRAN 
	DECLARE @BasemaxSerialNo INT
	DECLARE @maxSerialNo INT
	DECLARE @FormulaNo AS INT
	DECLARE @StoreID1 AS VARCHAR(20)
	DECLARE @StoreID2 AS VARCHAR(20)
	DECLARE @AcntCode AS VARCHAR(20)
	DECLARE @DocDesc AS NVARCHAR(2000)
	DECLARE @BranchName AS NVARCHAR(200)

	SET @maxSerialNo = 0
	SET @FormulaNo = 0
	SELECT @StoreID1 = StoreID1, @StoreID2 = StoreID2 
	FROM sal.tblBranches
	WHERE  BranchID=@BranchID

	SELECT @BranchName = BranchName 
	FROM sal.tblBranchesDtl
	WHERE  BranchID=@BranchID and LanguageID=1

	IF @IsMainProduct = 'False'
		SET @StoreID2 = @StoreID1
		
	SELECT @AcntCode= GoodsInProductionAcntCode 
	FROM inv.tblStores
	WHERE StoreID= @StoreID1

	select TOP 1 @FormulaNo = SerialNo FROM prd.tblFormulasHdr WHERE ProductID = @GoodsID AND  IsDefault='True'
	
	SET @DocDesc = N'بابت خروج از انبار شعبه ' + @BranchName + '('+ @BranchID + ')'

	SELECT @maxSerialNo = ISNULL(MAX(SerialNo),0)
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
	
	SELECT 70, 1, @FiscalYear, @maxSerialNo, @FormulaNo, 1, @ToDate, @StoreID1, '', @AcntCode, '' VisitorAcntCode,
		  '' OrderAcntCode, '' CurrencyTypeID,0 CurrencyRate,0 Amount,0 DiscountPercent,0 Discount,0 Discount2, 
		  0 TotalLineDiscount,0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocType,0 VchNo, 
		   @DocDesc DocDesc,0 WageRate,@Qty ProductCount,@GoodsID ProductID,0 AgreeNo,0 RecID,0 SessionNo,'' SaleTypeID,'' TransporterID, 
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
		  @BranchID DailyUsesBranchID,'False' DiscountTaxOverWorth,0 ComssionCostPrice,0 BasculePrice,0 LaborPrice,0 TransportPrice
	
		select ProductID	,d.GoodsID,GoodsQuantity Quantity ,GoodsQuantity SubUnitQuantity,d.UnitID,DefaultStoreID	, GoodsQuantity ProductCount,DocRowNo
		,DescDtl	,ExtraField1	,ExtraField2	,ExtraField3	,ExtraField4	,ExtraField5	,GoodsName	,UnitID2	,GoodsName UnitName	, GoodsQuantity Balance	, GoodsQuantity SubBalance
		Into #ProductGoods
		from prd.tblFormulasDtl d 
		INNER JOIN inv.tblGoods g ON d.GoodsID=g.GoodsID 
		INNER JOIN inv.tblGoodsDtl gd ON d.GoodsID=gd.GoodsID 
		where 1=0

	 Declare @Prd_ProduceAutoBuyInResturante as bit
	SELECT @Prd_ProduceAutoBuyInResturante=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'Prd_ProduceAutoBuyInResturant'	
	SET @Prd_ProduceAutoBuyInResturante =isnull( @Prd_ProduceAutoBuyInResturante,0)

	 Declare @RepInfo as Varchar(50)

	 Set @RepInfo	= '1@1@1@@@@@' + ltrim(rtrim(str(@Prd_ProduceAutoBuyInResturante))) + '@@@'
		insert into #ProductGoods
		exec  [prd].[SpPrd_ProductGoods_One_UseSimilar]
											@ProductID	=@GoodsID,
											@ProductQty	  = @Qty,
											@SerialNo	 = 0,
											@DocDateTo	= @ToDate,
											@StoreID	= @StoreID1,
											@RepOptions	= '00001', 
											@RepInfo	= @RepInfo

	delete  from #ProductGoods where Quantity <=0

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

	select 70, 1, @FiscalYear, @maxSerialNo, ROW_NUMBER()OVER (ORDER BY f.GoodsID) RowNo,ROW_NUMBER()OVER (ORDER BY r.GoodsID) DocRowNo, 
		   0, 1, @ToDate, @StoreID1, 'True', -1, '', @AcntCode, '', '', f.GoodsID,f.UnitID SubUnitID,f.SubUnitQuantity SubUnitQuantity,
		   f.Quantity GoodsQuantity,0 QtyRemain,0 GoodsAmount,0 AmntRemain,0 AtomAmount,0 GoodsPrice,'' DescDtl,
		   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocRowNo,'' BaseDocType,0 AgreeNo,
		   '' BatchNo,0 DiscountPercentDtl,0 DiscountDtl,'' BaseDocDate,0 VirtualQuantity,'False' IsReward,
		   @FormulaNo,'' GoodsID2,0 Wage,0 WageRate,0 FormulaProductCount,0 CurrencyAmount,0 CalculatingAmount,
		   '' VchDate2,0 SubUnitPrice,0 UserGoodsAmount,'' [ExpireDate],0 SourceSerialNo,0 SourceProcessNo,@BranchID,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',''
	FROM (SELECT @GoodsID GoodsID, @Qty  AS Qty) r
	INNER JOIN #ProductGoods f
	ON r.GoodsID=f.ProductID
	
	----------------
	SET @BasemaxSerialNo = @maxSerialNo
	SET @maxSerialNo = 0

	SELECT @maxSerialNo =  ISNULL(MAX(SerialNo),0)
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
	
	SELECT 80, 1, @FiscalYear, @maxSerialNo, @FormulaNo, 1, @ToDate, @StoreID2, '', @AcntCode, '' VisitorAcntCode,
		  '' OrderAcntCode, '' CurrencyTypeID,0 CurrencyRate,0 Amount,0 DiscountPercent,0 Discount,0 Discount2, 
		  0 TotalLineDiscount,70 BaseProcessID,1 BaseProcessNo,@FiscalYear BaseFiscalYear,@BasemaxSerialNo BaseSerialNo,70 BaseDocType,0 VchNo, 
		   @DocDesc DocDesc,0 WageRate,0 ProductCount,'' ProductID,0 AgreeNo,0 RecID,0 SessionNo,'' SaleTypeID,'' TransporterID, 
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
		  @BranchID DailyUsesBranchID ,'False' DiscountTaxOverWorth,0 ComssionCostPrice,0 BasculePrice,0 LaborPrice,0 TransportPrice
		  
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
		   0, 1, @ToDate, @StoreID2, 'True', +1, '', @AcntCode, '', '', r.GoodsID,UnitID SubUnitID,@Qty SubUnitQuantity,
		   @Qty GoodsQuantity,0 QtyRemain,0 GoodsAmount,0 AmntRemain,0 AtomAmount,0 GoodsPrice,'' DescDtl,
		   70 BaseProcessID,1 BaseProcessNo,@FiscalYear BaseFiscalYear,@BasemaxSerialNo BaseSerialNo,0 BaseDocRowNo,'' BaseDocType,0 AgreeNo,
		   '' BatchNo,0 DiscountPercentDtl,0 DiscountDtl,'' BaseDocDate,0 VirtualQuantity,'False' IsReward,
		   @FormulaNo,'' GoodsID2,0 Wage,0 WageRate,0 FormulaProductCount,0 CurrencyAmount,0 CalculatingAmount,
		   '' VchDate2,0 SubUnitPrice,0 UserGoodsAmount,'' [ExpireDate],0 SourceSerialNo,0 SourceProcessNo,@BranchID,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',''
	FROM (SELECT @GoodsID as GoodsID,@Qty as Qty ) r
	INNER JOIN inv.tblGoods g 
	ON r.GoodsID=g.GoodsID

	--INSERT INTO sal.tblResturanDailyUses
	--VALUES(@BranchID,@ToDate)
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
