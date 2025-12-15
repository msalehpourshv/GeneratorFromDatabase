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
CREATE PROCEDURE [inv].[spAutoBuyInSaleHdr]

@ProcessNo as Int,
@DocDate as CHAR(10),
@StoreID AS VARCHAR(20),
@FiscalYear as SMALLINT,
@TaxOverWorthCost as FLOAT,
@TollOverWorthCost as FLOAT,
@SumPrice as FLOAT,
@DocDesc as NVARCHAR(500),
@BranchID as VARCHAR(20),
@ToDate as CHAR(10),
@SessionNo as Int


WITH ENCRYPTION
 AS
BEGIN

BEGIN TRY

	DECLARE @maxSerialNo INT
	DECLARE @AcntCode AS VARCHAR(20)

	SET @maxSerialNo = 0
	
	DECLARE @BuyTypeID AS VARCHAR(20)

IF (SELECT COUNT(*)  FROM inv.tblBuyType)>0
	BEGIN
		SELECT TOP 1  @BuyTypeID=BuyTypeID FROM inv.tblBuyType
	END
	
	IF (SELECT COUNT(*)  FROM inv.tblBuyType)=0
	BEGIN
		set @BuyTypeID=''
	END
	
	SELECT @AcntCode= SettingValue
	FROM pub.tblSettings
	WHERE SettingKey='SalerAcntCodeInBuy'


	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=55 
	  AND ProcessNo=@ProcessNo
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
	EarnestMoney, EarnestMoneyPercent, EarnestMoneyAcntCode, BatchNo,
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
	CCNo , CCDiscount, CCPrivilege, SourceSerialNo,
	SourceProcessNo, DailyUsesBranchID, DiscountTaxOverWorth, ComssionCostPrice,
	BasculePrice, LaborPrice, TransportPrice,DailyUsesToDate)
	
	SELECT 55, @ProcessNo, @FiscalYear, @maxSerialNo, 0, 1, @DocDate, @StoreID, '', @AcntCode, '' VisitorAcntCode,
		  '' OrderAcntCode, '' CurrencyTypeID,0 CurrencyRate,0 Amount,0 DiscountPercent,0 Discount,0 Discount2, 
		  0 TotalLineDiscount,0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocType,0 VchNo, 
		   @DocDesc DocDesc,0 WageRate,0 ProductCount,'' ProductID,0 AgreeNo,0 RecID,@SessionNo SessionNo,@BuyTypeID SaleTypeID,'' TransporterID, 
		   '' LocationID,0 TransportationCost,0 PackingCost,0 TaxCost,'' VisitorCostAcntCode,0 VisitorPercent,0 VisitorCost, 
		   '' DiscountAcntCode,0 EarnestMoney,0 EarnestMoneyPercent,'' EarnestMoneyAcntCode,'' BatchNo, 
		   '' TransportationCostAcntCode,@SumPrice Price,@TaxOverWorthCost TaxOverWorthCost,0 VchNo2,'' IsConfirmed,'' SettlementDate, 
		   '' TransportationIncomeAcntCode,0 TransportationIncome,'' OtherCostAcntCode,'' OtherIncomeAcntCode,0 OtherCost, 
		  0 OtherIncome,'' DocDate2,'' DocDate3,'' DocDate4,0 AfterSaleDiscount,'' AfterSaleDesc,0 AfterSaleVchNo, 
		   '' AfterSaleDate,0 OldSerialNo,'False' HardRecivable,'True' IsAutoDoc,'' AfterSaleDiscountAcntCode,'' VchDate,0 SessionNo2, 
		  0 SessionNo3,0 SessionNo4,0 SessionNo5,@TollOverWorthCost TollOverWorthCost,'' DriverID,'' DistributerID1,'' DistributerID2, 
		  0 BaseDistributionProcessID,0 BaseDistributionProcessNo,0 BaseDistributionFiscalYear, 
		  0 BaseDistributionSerialNo,'' DestinationAddress,0 BaseSaleSerialNo,'' DistributeCostAcntCode,'' DistributeAcntCode,
		  0 DistributePercent,0 DistributeAmount,0 OwnerDocNo,'' FixCostAcntCode,0 FixCost,'False' ConfirmReceipt,'' TransporterID2,
		  0 CashAmount,0 ChequeAmount,'' [Address],'' CCNo ,0 CCDiscount,0 CCPrivilege,0 SourceSerialNo,
		  0 SourceProcessNo ,@BranchID DailyUsesBranchID,'False' DiscountTaxOverWorth,0 ComssionCostPrice,0 BasculePrice,
		  0 LaborPrice,0 TransportPrice,@ToDate DailyUsesToDate

         	-----------------

	
END TRY
BEGIN CATCH


	Declare @StrErrorMessage As Nvarchar(1024)
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
