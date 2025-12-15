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
Create PROCEDURE [prd].[spResturanSales_AutoDtl]
@SerialNo INT,
@maxSerialNo INT,
@ToDate CHAR(10),
@FiscalYear SMALLINT,
@BranchID VARCHAR(20),
@HasSendTaxToll BIT


WITH ENCRYPTION
 AS
BEGIN

BEGIN TRY

	BEGIN TRAN 
	DECLARE @MaxRowNo INT
	DECLARE @MaxDocRowNo INT
	DECLARE @SourceSerialNo INT
	DECLARE @PayType INT
	DECLARE @TPInp INT
	DECLARE @DiscountAmount float
	DECLARE @TaxOverWorthAmount float
	DECLARE @TollOverWorthAmount float
	DECLARE @PackingCost float
	DECLARE @OtherIncome float
	DECLARE @TotalLineDiscount float

	DECLARE @StoreID1 AS VARCHAR(20)
	DECLARE @StoreID2 AS VARCHAR(20)
	DECLARE @AcntCode AS VARCHAR(20)
	DECLARE @DocDesc AS NVARCHAR(2000)
	DECLARE @BranchName AS NVARCHAR(200)
	DECLARE @SaleTypeID AS VARCHAR(20)
	DECLARE @ServiceAmountNum AS FLOAT
	DECLARE @PackingCostNum AS FLOAT
	DECLARE @OtherIncomeNum AS FLOAT
	DECLARE @TransportationIncomeNum AS FLOAT
	DECLARE @ServiceAmountCode AS NVARCHAR(20)
	DECLARE @PackingCostCode AS NVARCHAR(20)
	DECLARE @OtherIncomeCode AS NVARCHAR(20)
	DECLARE @TransportationIncomeCode AS NVARCHAR(20)

	SET @SourceSerialNo = 0
	SET @PayType = 0
	SET @TPInp = 0

	SELECT @ServiceAmountCode  = SettingValue 
	FROM pub.tblSettings
	WHERE SettingKey='Rst_ServiceAmountCode'

	SELECT @PackingCostCode  = SettingValue 
	FROM pub.tblSettings
	WHERE SettingKey='Rst_PackingCostCode'

	SELECT @OtherIncomeCode  = SettingValue 
	FROM pub.tblSettings
	WHERE SettingKey='Rst_OtherIncomeCode'

	SELECT @TransportationIncomeCode  = SettingValue 
	FROM pub.tblSettings
	WHERE SettingKey='Rst_TransportationIncomeCode'

	if @ServiceAmountCode		 = null Set @ServiceAmountCode  = ''
	if @PackingCostCode			 = null Set @PackingCostCode  = ''		
	if @OtherIncomeCode			 = null Set @OtherIncomeCode  = ''
	if @TransportationIncomeCode = null Set @TransportationIncomeCode  = ''	


	SELECT @StoreID1 = StoreID1, @StoreID2 = StoreID2 
	FROM sal.tblBranches
	WHERE  BranchID=@BranchID

	SELECT @BranchName = BranchName 
	FROM sal.tblBranchesDtl
	WHERE  BranchID=@BranchID and LanguageID=1

	SELECT @DiscountAmount =DiscountAmount,
	       @TaxOverWorthAmount = TaxOverWorthAmount,
		   @TollOverWorthAmount=TollOverWorthAmount,
		   @PackingCost=PackingCost,
		   @OtherIncome=OtherIncome,
		   @SaleTypeID = SaleTypeID,
		   @SourceSerialNo = SerialNo,
		   @PayType = PayType,
		   @TPInp = TPInp,
		   @AcntCode=UserAcntCode,
		   @TotalLineDiscount = TotalLineDiscount
	FROM sal.tblRestaurantSaleHdr
	WHERE ProcessID = 92 and BranchID=@BranchID and  SerialNo =@SerialNo
	------------------
	SET @DocDesc = N'���� ���� ���� ' + @BranchName + '('+ @BranchID + ') �ѐ� ' + str(LTRIM(@SerialNo))

	----------------------------
	if @HasSendTaxToll = 0
	begin
		INSERT INTO inv.tblStorageDocsDtl
		
		(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
		DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, StoreID2, AcntCode,SaleTypeID,
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
		SalePrice, PhrBatchNo, GregorianExpireDate,TaxOverWorthCostDtl,TollOverWorthCostDtl)
		
		select 90, 11, @FiscalYear, @maxSerialNo,RowNo,DocRowNo, 
			   0, 3, @ToDate, @StoreID2, 'True', -1, '', @AcntCode,@SaleTypeID, '', '', d.GoodsID,UnitID ,Qty,
			   Qty,0 QtyRemain,0 GoodsAmount,0 AmntRemain,0 AtomAmount,Price ,'' DescDtl,
			   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocRowNo,'' BaseDocType,0 AgreeNo,
			   '' BatchNo,0 DiscountPercentDtl,DiscountDtl DiscountDtl,'' BaseDocDate,0 VirtualQuantity,'False' IsReward,
			   0,'' GoodsID2,0 Wage,0 WageRate,0 FormulaProductCount,0 CurrencyAmount,0 CalculatingAmount,
			   '' VchDate2,0 SubUnitPrice,0 UserGoodsAmount,'' [ExpireDate],@SourceSerialNo,0 SourceProcessNo,@BranchID DailyUsesBranchID,
			   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'','',TaxOverWorthCostDtl,TollOverWorthCostDtl
		FROM sal.tblRestaurantSaleDtl d
		INNER JOIN inv.tblGoods g
		ON d.GoodsID=g.GoodsID
		WHERE d.ProcessID = 92 and BranchID=@BranchID and  SerialNo =@SerialNo 
	end

	if @HasSendTaxToll = 1
	begin
		INSERT INTO inv.tblStorageDocsDtl
		
		(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
		DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, StoreID2, AcntCode,SaleTypeID,
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
		SalePrice, PhrBatchNo, GregorianExpireDate,TaxOverWorthCostDtl,TollOverWorthCostDtl)
		
		select 90, 11, @FiscalYear, @maxSerialNo,RowNo,DocRowNo, 
			   0, 3, @ToDate, @StoreID2, 'True', -1, '', @AcntCode,@SaleTypeID, '', '', d.GoodsID,UnitID ,Qty,
			   Qty,0 QtyRemain,0 GoodsAmount,0 AmntRemain,0 AtomAmount,floor(Price) ,'' DescDtl,
			   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocRowNo,'' BaseDocType,0 AgreeNo,
			   '' BatchNo,0 DiscountPercentDtl,floor(DiscountDtl) DiscountDtl,'' BaseDocDate,0 VirtualQuantity,'False' IsReward,
			   0,'' GoodsID2,0 Wage,0 WageRate,0 FormulaProductCount,0 CurrencyAmount,0 CalculatingAmount,
			   '' VchDate2,0 SubUnitPrice,0 UserGoodsAmount,'' [ExpireDate],@SourceSerialNo,0 SourceProcessNo,@BranchID DailyUsesBranchID,
			   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'','',floor(TaxOverWorthCostDtl),floor(TollOverWorthCostDtl)
		FROM sal.tblRestaurantSaleDtl d
		INNER JOIN inv.tblGoods g
		ON d.GoodsID=g.GoodsID
		WHERE  d.ProcessID = 92 and BranchID=@BranchID and  SerialNo =@SerialNo 

	end
	-------------
	
		UPDATE inv.tblStorageDocsHdr
			set Price= D.TPrice, Amount= D.TPrice, TotalLineDiscount=DiscountDtl
				,TaxOverWorthCost=case when TaxOverWorthCostDtl>0 then TaxOverWorthCostDtl else TaxOverWorthCost end 
				,TollOverWorthCost=case when TollOverWorthCostDtl>0 then TollOverWorthCostDtl else TollOverWorthCost end 
		from inv.tblStorageDocsHdr H
		INNER JOIN (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,SUM(GoodsQuantity*GoodsPrice) TPrice,SUM(DiscountDtl) DiscountDtl
							,SUM(TaxOverWorthCostDtl) TaxOverWorthCostDtl,SUM(TollOverWorthCostDtl) TollOverWorthCostDtl
					FROM inv.tblStorageDocsDtl
					where ProcessID=90 AND ProcessNo=11 AND FiscalYear=@FiscalYear AND SerialNo=@maxSerialNo
					group by ProcessID,ProcessNo,FiscalYear,SerialNo ) D
		ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
		where H.ProcessID=90 
		AND H.ProcessNo=11 
		AND H.FiscalYear=@FiscalYear 
		AND H.SerialNo=@maxSerialNo 
		
		 UPDATE inv.tblStorageDocsHdr
			set  Amount= Price-[Discount]-[Discount2]-[TotalLineDiscount]-[AfterSaleDiscount]-[OtherCost]-[TransportationCost]	+[OtherIncome]+[TransportationIncome]+[PackingCost]+[TaxCost]-[FixCost]	+	case when DiscountTaxOverWorth=1 then 0 else  	[TaxOverWorthCost]+[TollOverWorthCost] end 	+[IAToll]-[DistributeAmount] 
		where ProcessID=90 
		AND ProcessNo=11 
		AND FiscalYear=@FiscalYear 
		AND SerialNo=@maxSerialNo 
				
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
