USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 99/02/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [prd].[spResturanDailyTransferHdr]
@FromDate as CHAR(10),
@ToDate as CHAR(10),
@FiscalYear as SMALLINT,
@StoreID AS VARCHAR(20),
@StoreID2 AS VARCHAR(20),
@BranchID AS VARCHAR(20)


WITH ENCRYPTION
 AS
BEGIN

BEGIN TRY

	BEGIN TRAN 
	DECLARE @maxSerialNo INT
	DECLARE @RowNo INT
	DECLARE @Remain decimal
	DECLARE @GoodsID Varchar(20)
	DECLARE @UnitID Varchar(20)


	SET @maxSerialNo = 0
	SET @RowNo = 0


	------------------
	SET @maxSerialNo = 0

	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID in (120 ,125)
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
	
	SELECT 120, 1, @FiscalYear, @maxSerialNo, 0, 3, @FromDate, @StoreID, @StoreID2, '', '' VisitorAcntCode,
		  '' OrderAcntCode, '' CurrencyTypeID,0 CurrencyRate,0 Amount,0 DiscountPercent,0 Discount,0 Discount2, 
		  0 TotalLineDiscount,0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocType,0 VchNo, 
		   'انتقال اتوماتیک کمبود رستوران' DocDesc,0 WageRate,0 ProductCount,'' ProductID,0 AgreeNo,0 RecID,0 SessionNo,'' SaleTypeID,'' TransporterID, 
		   '' LocationID,0 TransportationCost,0 PackingCost,0 TaxCost,'' VisitorCostAcntCode,0 VisitorPercent,0 VisitorCost, 
		   '' DiscountAcntCode,0 EarnestMoney,0 EarnestMoneyPercent,'' EarnestMoneyAcntCode,'' BatchNo,  @BranchID BRN,
		   '' TransportationCostAcntCode,0 Price,0 TaxOverWorthCost,0 VchNo2,'' IsConfirmed,'' SettlementDate, 
		   '' TransportationIncomeAcntCode,0 TransportationIncome,'' OtherCostAcntCode,'' OtherIncomeAcntCode,0 OtherCost, 
		  0 OtherIncome,'' DocDate2,'' DocDate3,'' DocDate4,0 AfterSaleDiscount,'' AfterSaleDesc,0 AfterSaleVchNo, 
		   '' AfterSaleDate,0 OldSerialNo,'False' HardRecivable,'True' IsAutoDoc,'' AfterSaleDiscountAcntCode,'' VchDate,0 SessionNo2, 
		  0 SessionNo3,0 SessionNo4,0 SessionNo5,0 TollOverWorthCost,'' DriverID,'' DistributerID1,'' DistributerID2, 
		  0 BaseDistributionProcessID,0 BaseDistributionProcessNo,0 BaseDistributionFiscalYear, 
		  0 BaseDistributionSerialNo,'' DestinationAddress,0 BaseSaleSerialNo,'' DistributeCostAcntCode,'' DistributeAcntCode,
		  0 DistributePercent,0 DistributeAmount,0 OwnerDocNo,'' FixCostAcntCode,0 FixCost,'False' ConfirmReceipt,'' TransporterID2,
		  0 CashAmount,0 ChequeAmount,'' [Address],'' CCNo,0 CCDiscount,0 CCPrivilege ,0 SourceSerialNo,0 SourceProcessNo,@BranchID DailyUsesBranchID,
		  'False' DiscountTaxOverWorth,0 ComssionCostPrice,0 BasculePrice,0 LaborPrice,0 TransportPrice


	Declare	Cursor_ CURSOR For 
	select  a.GoodsID,g.UnitID,CASE when Qty-Store2Qty>StoreQty THEN StoreQty ELSE Qty-Store2Qty END Remain
        from (
            SELECT d.GoodsID,SUM(d.Qty-d.RetQty) Qty 
              ,(Select  ISNULL (Sum(GoodsQuantity * EnterKind), 0)
                FROM inv.tblStorageDocsDtl a 
                  WHERE StoreID =@StoreID  AND a.GoodsID = d.GoodsID
                  AND DocDate<=@ToDate AND (FiscalYear =  @FiscalYear  OR (FiscalYear <>  @FiscalYear  AND EnterKind=1)))StoreQty
                ,(Select  ISNULL (Sum(GoodsQuantity * EnterKind), 0)
                FROM inv.tblStorageDocsDtl a 
                  WHERE StoreID = @StoreID2  AND a.GoodsID = d.GoodsID
                  AND DocDate<=@ToDate AND (FiscalYear =  @FiscalYear  OR (FiscalYear <>  @FiscalYear AND EnterKind=1)))Store2Qty
                From sal.tblRestaurantSaleDtl d 
                WHERE d.DocDate>= @FromDate AND d.DocDate<=@ToDate AND 
                      d.BranchID=@BranchID
              GROUP BY  d.GoodsID
             HAVING SUM(d.Qty-d.RetQty) >0 
        ) a
        inner join inv.tblGoods g on a.GoodsID=g.GoodsID
        where Qty>Store2Qty and StoreQty>0
        
	Open  Cursor_; 

	Fetch NEXT From Cursor_ Into  @GoodsID,@UnitID,@Remain

	While (@@Fetch_Status = 0)
		BEGIN
			SET @RowNo = @RowNo + 1
			
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
			

			select TOP 1 120, 1, @FiscalYear, @maxSerialNo,@RowNo RowNo,@RowNo DocRowNo, 
			   0, 3, @ToDate, @StoreID, 'True', -1, @StoreID2, '' AcntCode, '', '', @GoodsID,@UnitID SubUnitID,
			   @Remain SubUnitQuantity,@Remain GoodsQuantity,0 QtyRemain,0 GoodsAmount,0 AmntRemain,0 AtomAmount,0 GoodsPrice,'' DescDtl,
			   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocRowNo,'' BaseDocType,0 AgreeNo,
			   '' BatchNo,0 DiscountPercentDtl,0 DiscountDtl,'' BaseDocDate,0 VirtualQuantity,'False' IsReward,
			   0,'' GoodsID2,0 Wage,0 WageRate,0 FormulaProductCount,0 CurrencyAmount,0 CalculatingAmount,
			   '' VchDate2,0 SubUnitPrice,0 UserGoodsAmount,'' [ExpireDate],0 SourceSerialNo,0 SourceProcessNo,@BranchID DailyUsesBranchID,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',''
		
			Fetch NEXT From Cursor_ Into  @GoodsID,@UnitID,@Remain
		END
		Close Cursor_;
		Deallocate Cursor_; 
				  
	
	IF (SELECT COUNT(*) from inv.tblStorageDocsDtl WHERE ProcessID in (120,125) and ProcessNo=1 AND FiscalYear=@FiscalYear and SerialNo=@maxSerialNo)=0
			DELETE FROM inv.tblStorageDocsHdr WHERE ProcessID in (120,125) and ProcessNo=1 AND FiscalYear=@FiscalYear and SerialNo=@maxSerialNo

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
