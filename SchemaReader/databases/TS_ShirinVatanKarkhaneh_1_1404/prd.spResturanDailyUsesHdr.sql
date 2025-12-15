USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Reza Nogrepasasnd
-- Create date   : 92/01/17
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE prd.spResturanDailyUsesHdr
@ProcessID AS int,
@FromDate as CHAR(10),
@ToDate as CHAR(10),
@FiscalYear as SMALLINT,
@BranchID AS NVARCHAR(20)

WITH ENCRYPTION
 AS
BEGIN

BEGIN TRY

	BEGIN TRAN 
	DECLARE @maxSerialNo INT
	DECLARE @DiscountAmount float
	DECLARE @TaxOverWorthAmount float
	DECLARE @TollOverWorthAmount float
	DECLARE @PackingCost float
	DECLARE @OtherIncome float

	DECLARE @StoreID1 AS VARCHAR(20)
	DECLARE @StoreID2 AS VARCHAR(20)
	DECLARE @StoreID3 AS VARCHAR(20)
	DECLARE @AcntCode AS VARCHAR(20)
	DECLARE @DocDesc AS NVARCHAR(2000)
	DECLARE @BranchName AS NVARCHAR(200)

	SET @maxSerialNo = 0

	SELECT @StoreID1 = StoreID1, @StoreID2 = StoreID2 , @StoreID3 = StoreID3
	FROM sal.tblBranches
	WHERE  BranchID=@BranchID

	SELECT @BranchName = BranchName 
	FROM sal.tblBranchesDtl
	WHERE  BranchID=@BranchID and LanguageID=1

	SELECT @AcntCode= GoodsInProductionAcntCode 
	FROM inv.tblStores
	WHERE StoreID= @StoreID1

	SELECT @DiscountAmount =isnull(SUM(DiscountAmount),0),
	       @TaxOverWorthAmount = isnull(SUM(TaxOverWorthAmount),0),
		   @TollOverWorthAmount=isnull(SUM(TollOverWorthAmount),0),
		   @PackingCost=isnull(SUM(PackingCost),0),
		   @OtherIncome=isnull(SUM(OtherIncome),0)
	FROM sal.tblRestaurantSaleHdr
	WHERE ProcessID in (92 ,94)
	  AND BranchID = @BranchID 
	  AND RSTDocDate >= @FromDate 
	  AND RSTDocDate <= @ToDate	 
	------------------
	SET @maxSerialNo = 0
DECLARE @StoreID AS VARCHAR(20) 
 
if @ProcessID  =90
begin
	SET @DocDesc = N'���� ���� ���� ' + @BranchName + '('+ @BranchID + ')'
	set @StoreID=@StoreID2
end 
else 
begin
	SET @DocDesc = N'���� �ѐ�� ���� ���� ' + @BranchName + '('+ @BranchID + ')'
	set @StoreID=@StoreID3
end 

	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=@ProcessID
	  AND ProcessNo=CASE WHEN @ProcessID = 110 THEN 1 ELSE 11 END 
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo + 1

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
	BaseDistributionProcessID, BaseDistributionProcessNo,
	BaseDistributionFiscalYear, BaseDistributionSerialNo, DestinationAddress,
	BaseSaleSerialNo, DistributeCostAcntCode, DistributeAcntCode,
	DistributePercent, DistributeAmount, OwnerDocNo, FixCostAcntCode, FixCost,
	ConfirmReceipt, TransporterID2, CashAmount, ChequeAmount, [Address],
	CCNo, CCDiscount, CCPrivilege, SourceSerialNo,
	SourceProcessNo, DailyUsesBranchID, DiscountTaxOverWorth, ComssionCostPrice,
	BasculePrice, LaborPrice, TransportPrice)
	
	SELECT @ProcessID, CASE WHEN @ProcessID = 110 THEN 1 ELSE 11 END , @FiscalYear, @maxSerialNo, 0, 3, @ToDate,  @ToDate, @StoreID, '', @AcntCode, '' VisitorAcntCode,
		  '' OrderAcntCode, '' CurrencyTypeID,0 CurrencyRate,0 Amount,0 DiscountPercent,0 Discount,@DiscountAmount Discount2, 
		  0 TotalLineDiscount,0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocType,0 VchNo, 
		   @DocDesc DocDesc,0 WageRate,0 ProductCount,'' ProductID,0 AgreeNo,0 RecID,0 SessionNo,'' SaleTypeID,'' TransporterID, 
		   '' LocationID,0 TransportationCost,@PackingCost PackingCost,0 TaxCost,'' VisitorCostAcntCode,0 VisitorPercent,0 VisitorCost, 
		   '' DiscountAcntCode,0 EarnestMoney,0 EarnestMoneyPercent,'' EarnestMoneyAcntCode,'' BatchNo,  @BranchID BRN,
		   '' TransportationCostAcntCode,0 Price,@TaxOverWorthAmount TaxOverWorthCost,0 VchNo2,'' IsConfirmed,'' SettlementDate, 
		   '' TransportationIncomeAcntCode,0 TransportationIncome,'' OtherCostAcntCode,'' OtherIncomeAcntCode,0 OtherCost, 
		  @OtherIncome OtherIncome,'' DocDate2,'' DocDate3,'' DocDate4,0 AfterSaleDiscount,'' AfterSaleDesc,0 AfterSaleVchNo, 
		   '' AfterSaleDate,0 OldSerialNo,'False' HardRecivable,'True' IsAutoDoc,'' AfterSaleDiscountAcntCode,'' VchDate,0 SessionNo2, 
		  0 SessionNo3,0 SessionNo4,0 SessionNo5,@TollOverWorthAmount TollOverWorthCost,'' DriverID,'' DistributerID1,'' DistributerID2, 
		  0 BaseDistributionProcessID,0 BaseDistributionProcessNo,0 BaseDistributionFiscalYear, 
		  0 BaseDistributionSerialNo,'' DestinationAddress,0 BaseSaleSerialNo,'' DistributeCostAcntCode,'' DistributeAcntCode,
		  0 DistributePercent,0 DistributeAmount,0 OwnerDocNo,'' FixCostAcntCode,0 FixCost,'False' ConfirmReceipt,'' TransporterID2,
		  0 CashAmount,0 ChequeAmount,'' [Address],'' CCNo,0 CCDiscount,0 CCPrivilege ,0 SourceSerialNo,0 SourceProcessNo,@BranchID DailyUsesBranchID,
		  'False' DiscountTaxOverWorth,0 ComssionCostPrice,0 BasculePrice,0 LaborPrice,0 TransportPrice		  
	
	if @ProcessID=90
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
