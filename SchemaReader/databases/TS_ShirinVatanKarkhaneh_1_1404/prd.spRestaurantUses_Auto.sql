USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1403-01-27
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [prd].[spRestaurantUses_Auto]
@SerialNo as int,
@ToDate as CHAR(10),
@FiscalYear as SMALLINT,
@BranchID AS NVARCHAR(20)

WITH ENCRYPTION
 AS
BEGIN

BEGIN TRY

	BEGIN TRAN 
	DECLARE @MaxRowNo INT
	DECLARE @MaxDocRowNo INT
	DECLARE @maxSerialNo INT
	DECLARE @SourceSerialNo INT
	DECLARE @PayType INT
	DECLARE @TPInp INT

	DECLARE @StoreID1 AS VARCHAR(20)
	DECLARE @StoreID2 AS VARCHAR(20)
	DECLARE @AcntCode AS VARCHAR(20)
	DECLARE @DocDesc AS NVARCHAR(2000)
	DECLARE @BranchName AS NVARCHAR(200)
	DECLARE @SaleTypeID AS VARCHAR(20)

	SET @maxSerialNo = 0
	SET @SourceSerialNo = 0
	SET @PayType = 0
	SET @TPInp = 0

	

	SELECT @StoreID1 = StoreID1, 
		   @StoreID2 = StoreID2 
	FROM sal.tblBranches
	WHERE BranchID = @BranchID

	SELECT @BranchName = BranchName 
	FROM sal.tblBranchesDtl
	WHERE BranchID = @BranchID 
	  AND LanguageID = 1

	SELECT @SaleTypeID = SaleTypeID,
		   @SourceSerialNo = SerialNo,
		   @PayType = PayType,
		   @TPInp = TPInp,
		   @AcntCode=UserAcntCode
	FROM sal.tblRestaurantSaleHdr
	WHERE ProcessID = 112 
	  AND BranchID = @BranchID 
	  AND SerialNo = @SerialNo
	------------------
	SET @maxSerialNo = 0
	SET @DocDesc = N'���� ���� ���� ' + @BranchName + '('+ @BranchID + ') �ѐ� ' + str(LTRIM(@SerialNo))

	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID = 110 
	  AND ProcessNo = 1
	  AND FiscalYear = @FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo + 1

	BEGIN
	INSERT INTO inv.tblStorageDocsHdr
	(ProcessID, ProcessNo, FiscalYear, SerialNo, FormulaNo, DocStep, DocDate,RSTExitDate,
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
	BaseDistributionProcessID, BaseDistributionProcessNo, BaseDistributionFiscalYear, 
	BaseDistributionSerialNo, DestinationAddress, BaseSaleSerialNo, DistributeCostAcntCode, 
	DistributeAcntCode,	DistributePercent, DistributeAmount, OwnerDocNo, 
	FixCostAcntCode, FixCost, ConfirmReceipt, TransporterID2, CashAmount, 
	ChequeAmount, [Address], CCNo, CCDiscount, CCPrivilege, SourceSerialNo,
	SourceProcessNo, SourceProcessID, SourceFiscalYear, DailyUsesBranchID, 
	DiscountTaxOverWorth, ComssionCostPrice, BasculePrice, LaborPrice, TransportPrice,PayType,TPInp)
	
	SELECT 110, 1, @FiscalYear, @maxSerialNo, 0, 1, @ToDate, @ToDate, 
		   @StoreID2, '', @AcntCode, '' VisitorAcntCode, '' OrderAcntCode, '' CurrencyTypeID,
		   0 CurrencyRate,0 Amount,0 DiscountPercent,0 Discount,0 Discount2, 0 TotalLineDiscount,
		   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocType,0 VchNo, 
		   @DocDesc DocDesc,0 WageRate,0 ProductCount,'' ProductID,0 AgreeNo,0 RecID,0 SessionNo,
		   '' SaleTypeID,'' TransporterID, '' LocationID,0 TransportationCost,0 PackingCost,
		   0 TaxCost,'' VisitorCostAcntCode,0 VisitorPercent,0 VisitorCost, '' DiscountAcntCode,
		   0 EarnestMoney,0 EarnestMoneyPercent,'' EarnestMoneyAcntCode,'' BatchNo,  @BranchID BRN,
		   '' TransportationCostAcntCode,0 Price,0 TaxOverWorthCost,0 VchNo2,'' IsConfirmed,
		   '' SettlementDate, '' TransportationIncomeAcntCode,0 TransportationIncome,
		   '' OtherCostAcntCode,'' OtherIncomeAcntCode,0 OtherCost, 0 OtherIncome,'' DocDate2,
		   '' DocDate3,'' DocDate4,0 AfterSaleDiscount,'' AfterSaleDesc,0 AfterSaleVchNo, 
		   '' AfterSaleDate,0 OldSerialNo,'False' HardRecivable,'True' IsAutoDoc,
		   '' AfterSaleDiscountAcntCode,@ToDate VchDate,0 SessionNo2, 0 SessionNo3,0 SessionNo4,
		   0 SessionNo5,0 TollOverWorthCost,'' DriverID,'' DistributerID1,'' DistributerID2, 
		   0 BaseDistributionProcessID,0 BaseDistributionProcessNo,0 BaseDistributionFiscalYear, 
		   0 BaseDistributionSerialNo,'' DestinationAddress,0 BaseSaleSerialNo,'' DistributeCostAcntCode,
		   '' DistributeAcntCode, 0 DistributePercent,0 DistributeAmount,0 OwnerDocNo,
		   '' FixCostAcntCode,0 FixCost,'False' ConfirmReceipt,'' TransporterID2, 0 CashAmount,
		   0 ChequeAmount,'' [Address],'' CCNo,0 CCDiscount,0 CCPrivilege ,@SourceSerialNo SourceSerialNo, 
		   11 SourceProcessNo, 112 SourceProcessID, @FiscalYear SourceFiscalYear, @BranchID DailyUsesBranchID,
		   'False' DiscountTaxOverWorth,0 ComssionCostPrice,0 BasculePrice,0 LaborPrice,0 TransportPrice,@PayType,@TPInp

	--INSERT INTO inv.tblStorageDocsDtl
		
	--	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
	--	DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, StoreID2, AcntCode,SaleTypeID,
	--	VisitorAcntCode, OrderAcntCode, GoodsID, SubUnitID, SubUnitQuantity,
	--	GoodsQuantity, QtyRemain, GoodsAmount, AmntRemain, AtomAmount, GoodsPrice,
	--	DescDtl, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,
	--	BaseDocRowNo, BaseDocType, AgreeNo, BatchNo, DiscountPercentDtl, DiscountDtl,
	--	BaseDocDate, VirtualQuantity, IsReward, FormulaNo, GoodsID2, Wage, WageRate,
	--	FormulaProductCount, CurrencyAmount, CalculatingAmount, VchDate2, SubUnitPrice,
	--	UserGoodsAmount, [ExpireDate], SourceSerialNo, SourceProcessNo, SourceProcessID, SourceFiscalYear,
	--	DailyUsesBranchID, GoodsAmount1, GoodsAmount2, GoodsAmount3, GoodsAmount4,
	--	GoodsAmount5, GoodsAmount6, GoodsAmount7, GoodsAmount8, GoodsAmount9,
	--	GoodsAmount10, GoodsAmount11, GoodsAmount12, StoreVariable1, StoreVariable2,
	--	SalePrice, PhrBatchNo, GregorianExpireDate,TaxOverWorthCostDtl,TollOverWorthCostDtl)
		
		--select 110, 1, @FiscalYear, @maxSerialNo, ROW_Number()over(partition by d.DocDate,d.BranchID order by d.DocDate,d.BranchID,d.GoodsID) RowNo,
		--	   ROW_Number()over(partition by d.DocDate,d.BranchID order by d.DocDate,d.BranchID,d.GoodsID) DocRowNo, 
		--	   0, 1, @ToDate, @StoreID2, 'True', -1, '', @AcntCode,'' SaleTypeID, '', '', d.GoodsID,UnitID ,Sum(Qty) Qty,
		--	   Sum(Qty) Qty,0 QtyRemain,0 GoodsAmount,0 AmntRemain,0 AtomAmount,Price ,'' DescDtl,
		--	   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocRowNo,'' BaseDocType,0 AgreeNo,
		--	   '' BatchNo,0 DiscountPercentDtl,0 DiscountDtl,'' BaseDocDate,0 VirtualQuantity,'False' IsReward,
		--	   0,'' GoodsID2,0 Wage,0 WageRate,0 FormulaProductCount,0 CurrencyAmount,0 CalculatingAmount,
		--	   '' VchDate2,0 SubUnitPrice,0 UserGoodsAmount,'' [ExpireDate],@SourceSerialNo SourceSerialNo, 
		--	   11 SourceProcessNo, 112 SourceProcessID, @FiscalYear SourceFiscalYear, @BranchID DailyUsesBranchID,
		--	   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'','',0,0
		--FROM sal.tblRestaurantSaleDtl d
		--INNER JOIN inv.tblGoods g
		--ON d.GoodsID=g.GoodsID
		--WHERE ProcessID = 112
		--  AND BranchID = @BranchID 
		--  AND SerialNo = @SerialNo 
		--Group by d.GoodsID, d.DocDate, d.BranchID, UnitID,Price
	END
				
	COMMIT TRAN
	END TRY
	BEGIN CATCH

	ROLLBACK TRAN
	Declare @StrErrorMessage As Nvarchar(1024)
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

SELECT @maxSerialNo
END	
GO
