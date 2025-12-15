USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/01/08
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [acc].[SpVchSaleWithService]
	@intVchNo				Int,
	@intDocStep				TinyInt,
	@strVchDate				Char(10),
	@intSourceProcessID		TinyInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				Int,
	@LanguageID				TinyInt

WITH ENCRYPTION
AS

BEGIN 
-----
Declare @strMsgText					NVarChar(2044)
Declare @strTitleSale		    	NVarChar(100)
Declare @DescDtl					NVarChar(1000)
Declare @DescHdr					NVarChar(1000)
Declare @DescDistribution			NVarChar(1000)
Declare @strFiscalSerial			VarChar(50)
Declare @strRecDesc					NVarChar(1000)
Declare @strRecDesc2				NVarChar(1000)
Declare @GoodsName					NVarChar(1000)
Declare @GoodsMainUnit				NVarChar(1000)
Declare @GoodsUnit					NVarChar(1000)
Declare @SaleTypeText				NVarChar(1000)
Declare @Address					NVarChar(2000)
Declare @SaleTaxOverWorthAcntCode	Varchar(20)
Declare @SaleTollOverWorthAcntCode  Varchar(20)
Declare @SaleAcntCode				Varchar(20)
Declare @StoreID					Varchar(20)
Declare @SaleTypeID					Varchar(20)
Declare @AcntCode					Varchar(20)
Declare @AtomAcntCode				Varchar(20)
Declare @VisitorAcntCode			Varchar(20)
Declare @VisitorCostAcntCode		Varchar(20)
Declare @VisitorAcntCode2			Varchar(20)
Declare @VisitorCostAcntCode2		Varchar(20)
Declare @VisitorAcntCodeInSale		Varchar(20)
Declare @DistributeAcntCode			Varchar(20)
Declare @DistributeCostAcntCode		Varchar(20)
Declare @OtherCostAcntCode			Varchar(20)
Declare @FixCostAcntCode			Varchar(20)
Declare @OtherIncomeAcntCode		Varchar(20)
Declare @IATollCod					Varchar(20)
Declare @SettlementDate				Varchar(50)

Declare @DiscountAcntCode			Varchar(20)
Declare @AfterSaleDiscountAcntCode  Varchar(20)
Declare @EarnestMoneyAcntCode		Varchar(20)
Declare @TaxAcntCode				Varchar(20)
Declare @TransportationCostAcntCode	Varchar(20)
Declare @TransportationIncomeAcntCode Varchar(20)
Declare @PackingAcntCode		Varchar(20)
Declare @CurrencyTypeID			VarChar(20)
Declare @ComssionCostPriceAcntCode	VarChar(20)
Declare @BasculePriceAcntCode	VarChar(20)
Declare @LaborPriceAcntCode		VarChar(20)
Declare @TransportPriceAcntCode	VarChar(20)
Declare @GoodsID				VarChar(20)	
Declare @AwardPayedAcntCode		VarChar(20)
Declare @BankID					VarChar(20)
Declare @BankID2				VarChar(20)
Declare @CashID					VarChar(20)
DECLARE @StrQuantity			VarChar(30)
Declare @SubUnitID				VarChar(20)
Declare @SubUnitID3				VarChar(20)
Declare @Height					Float
Declare @Width					Float
Declare @SubUnitQuantity3		Float
Declare @GoodsAmount3			Float
Declare @ServiceAmount			Float
Declare @Amount					Float
Declare @IAToll					Float
Declare @GoodsPrice				Float
Declare @SubUnitPrice			Float
Declare @GoodsQuantity			Float
Declare @Wage					Float
Declare @SubUnitQuantity		Float
Declare @Discount				Float
Declare @Discount2				FLOAT
Declare @CurrencyDiscount		FLOAT
Declare @CustomerCardDiscount	FLOAT
Declare @TotalLineDiscount		Float
Declare @TransportationCost		Float
Declare @TransportationIncome	Float
Declare @PackingCost			Float
Declare @TaxCost				Float
Declare @VisitorPercent			Float
Declare @VisitorCost			Float
Declare @VisitorPercent2		Float
Declare @VisitorCost2			Float
Declare @VisitorCostInGoods		Float
Declare @DistributePercent		Float
Declare @DistributeAmount		Float
Declare @EarnestMoney			Float
Declare @EarnestMoneyPercent	Float
Declare @SumGoodsPrice			Float
Declare @SumServicePrice		Float
Declare @SumGoodsPriceWithTax	Float
Declare @VisitorCostTmp			Float
Declare @VisitorCostTmp2		Float
Declare @TaxOverWorthCost		Float
Declare @TollOverWorthCost		Float
Declare @OtherCost				Float
Declare @FixCost				Float
Declare @OtherIncome			Float
Declare @CurrencyRate			Float
Declare @CurrencyAmount			Float
Declare @ComssionCostPrice		Float
Declare @BasculePrice			FLOAT
Declare @LaborPrice				Float
Declare @TransportPrice			FLOAT
Declare @BankAmnt				FLOAT
Declare @BankAmnt2				FLOAT
Declare @CashAmnt				FLOAT
Declare @AwardAmnt				FLOAT
Declare @decPrice				varchar(30)

DECLARE @DiscountTaxOverWorth				 BIT		
DECLARE @TotalSale2Account					 BIT		
DECLARE @ShowSaleDiscountInBill				 BIT		
DECLARE @DiscountMinusFromVisitor			 BIT		
DECLARE @HasDST							     BIT		
DECLARE @TaxOverWorthViewInCustomerInvoice   BIT
DECLARE @ShowSaleTransportationInBill		 BIT		
DECLARE @ShowSettlementDate				     BIT
DECLARE @OrderDescInSaleVoucher				 BIT
DECLARE @Sal_StoreDtl						 BIT
DECLARE @SaleAcntCodeInSaleTypes			 BIT
DECLARE @GetAcntCodeFromStore				 BIT

DECLARE @SalAcntNameInVoucherDesc   BIT
DECLARE @strAcntName				NVarChar(500)

DECLARE @BaseFiscalYear Integer		
DECLARE @BaseSerialNo Integer		
DECLARE @BaseProcessID Integer		
DECLARE @BaseProcessNo Integer		
DECLARE @BaseDistributionSerialNo Integer		
DECLARE @BaseDistributionFiscalYear Smallint	
DECLARE @OwnerDocNo INT

Declare @CurrencyRateTmp			Float
Declare @CurrencyAmountTmp			Float
Declare @CurrencyTypeIDTmp			VarChar(20)
Declare @Sal_TaxAcntCompletWithCustCode bit


-----
SET	@Discount = 0
SET @Discount2 = 0	
SET @CurrencyDiscount = 0	
SET @CustomerCardDiscount = 0				
SET @TotalLineDiscount = 0
SET @TotalSale2Account = 0				
SET @ShowSaleDiscountInBill = 1			
SET @VisitorCostTmp = 0
SET @VisitorCostInGoods = 0
SET @VisitorCostTmp2 = 0
SET @BaseSerialNo = 0
SET @BaseProcessID = 0
SET @BaseProcessNo = 0
SET @BaseFiscalYear = 0
SET @SaleAcntCode = ''
SET @OwnerDocNo =0

SET @CurrencyTypeID = ''
SET @SaleTypeID = ''
SET @SaleTypeText = ''
SET @strTitleSale = ''
SET @DescHdr = ''
SET @DescDistribution = ''
SET @SettlementDate = ''
SET @StrQuantity = ''	
SET @CurrencyRate = 0 	
SET @CurrencyAmount = 0
SET @ShowSaleTransportationInBill = 'True'
SET @SaleAcntCodeInSaleTypes = 'False'
SET @GetAcntCodeFromStore = 'False'
SET @Sal_StoreDtl = 'False'
SET @AwardPayedAcntCode = ''
DECLARE @UnitPart TINYINT
SET @UnitPart  = 1

SET @CurrencyRateTmp = 0
SET @CurrencyAmountTmp = 0
SET @CurrencyTypeIDTmp = ''

SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

IF @UnitPart IS NULL or @UnitPart = 0
	SET @UnitPart = 1

DECLARE @str_Goods  tinyint,
		@str_GoodsSum tinyint

select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
from pub.tblCodeLayer 
where TableName='inv.tblGoods' AND PartNumber<@UnitPart

select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
from pub.tblCodeLayer 
where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

SELECT @strTitleSale = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TitleSale' + LTRIM(RTRIM(STR(@intSourceProcessNo)))
SELECT @VisitorAcntCodeInSale = SettingValue from pub.tblSettings where SettingKey = 'VisitorAcntCodeInSale'

SELECT @HasDST = SettingValue FROM pub.tblSettings WHERE SettingKey = 'HasDST' 

SELECT @TaxOverWorthViewInCustomerInvoice = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TaxOverWorthViewInCustomerInvoice' 

SELECT @ShowSettlementDate = SettingValue FROM   pub.tblSettings WHERE SettingKey = 'ShowSettlementDate' 

SELECT @OrderDescInSaleVoucher = SettingValue FROM   pub.tblSettings WHERE SettingKey = 'OrderDescInSaleVoucher' 	

SELECT @ShowSaleTransportationInBill = SettingValue FROM pub.tblSettings WHERE SettingKey = 'ShowSaleTransportationInBill' 

SELECT @SaleAcntCodeInSaleTypes = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SaleAcntCodeInSaleTypes' 

select @Sal_TaxAcntCompletWithCustCode=SettingValue from pub.tblSettings where SettingKey='Sal_TaxAcntCompletWithCustCode'

-- ===========================
Select @SaleTypeID = SaleTypeID
From inv.tblStorageDocsHdr
Where ProcessID = @intSourceProcessID And ProcessNo = @intSourceProcessNo And
	  FiscalYear = @intSourceFiscalYear And SerialNo = @intSourceSerialNo
	  
Select @GetAcntCodeFromStore = GetAcntCodeFromStore 
From sal.tblSaleTypes 
Where SaleTypeID = @SaleTypeID

If  @GetAcntCodeFromStore = 1 
	Set @SaleAcntCodeInSaleTypes = 'False'
-- ===========================

SELECT @ComssionCostPriceAcntCode = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'comssionCostSale' 

SELECT @BasculePriceAcntCode = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'BasculCostSale' 

SELECT @LaborPriceAcntCode = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'LaborCostSale' 
	
SELECT @TransportPriceAcntCode = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'TransportCostSale' 

SELECT @AwardPayedAcntCode = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'AwardPayedAcntCode' 	

SELECT @Sal_StoreDtl = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'Sal_StoreDtl' 	

SELECT @SalAcntNameInVoucherDesc = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'SalAcntNameInVoucherDesc'

--------------------------------------------------------------------------------------------------------

	
	---------------------------------
	SELECT @TotalSale2Account = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TotalSale2Account'

	SET @TotalSale2Account=ISNULL(@TotalSale2Account,1)

	IF @TotalSale2Account = 'False'
		SET @TaxOverWorthViewInCustomerInvoice = 'True'
	---------------------------------
	SELECT @ShowSaleDiscountInBill = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ShowSaleDiscountInBill'

	SET @ShowSaleDiscountInBill=ISNULL(@ShowSaleDiscountInBill,1)

	---------------------------------
	SELECT @DiscountMinusFromVisitor = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DiscountMinusFromVisitor'

	SET @DiscountMinusFromVisitor=ISNULL(@DiscountMinusFromVisitor,1)
	
	--------------------------------------------------------------------------------------------------------
	SELECT	@StoreID=StoreID,@AcntCode=AcntCode,@Discount=Discount,@Discount2=Discount2+Discount3,
			@CurrencyDiscount=(CurrencyDiscount * CurrencyRate),
			@CustomerCardDiscount = CCDiscount,@TransportationCost=TransportationCost,@TransportationIncome=TransportationIncome,
			@PackingCost=PackingCost,@TaxCost=TaxCost,@VisitorAcntCode=VisitorAcntCode,
			@VisitorPercent=VisitorPercent,@VisitorCost=VisitorCost,@VisitorCostAcntCode2=VisitorCostAcntCode2,@VisitorAcntCode2=VisitorAcntCode2,
			@VisitorPercent2=VisitorPercent2,@VisitorCost2=VisitorCost2,@DistributeCostAcntCode=DistributeCostAcntCode,
			@DistributeAcntCode=DistributeAcntCode,@DistributePercent=DistributePercent,@DistributeAmount=DistributeAmount,
			@DiscountAcntCode=DiscountAcntCode,@EarnestMoney=EarnestMoney,@EarnestMoneyPercent=EarnestMoneyPercent,@CurrencyRate=CurrencyRate,
			@TransportationCostAcntCode=TransportationCostAcntCode,@TransportationIncomeAcntCode=TransportationIncomeAcntCode,
			@EarnestMoneyAcntCode=EarnestMoneyAcntCode,@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost,@SaleTypeID=SaleTypeID, 
			@OtherCostAcntCode=OtherCostAcntCode,@FixCostAcntCode=FixCostAcntCode,@OtherIncomeAcntCode=OtherIncomeAcntCode,@FixCost=FixCost,@OtherCost=OtherCost,@OtherIncome=OtherIncome,@DescHdr= DocDesc,
			@BaseDistributionSerialNo = BaseDistributionSerialNo,@BaseDistributionFiscalYear=BaseDistributionFiscalYear,@SettlementDate=SettlementDate,
			@BaseSerialNo = BaseSerialNo,@BaseProcessID = BaseProcessID,@OwnerDocNo=OwnerDocNo,@CurrencyTypeID=CurrencyTypeID,
			@Address=[Address],@BaseProcessNo = BaseProcessNo,@BaseFiscalYear = BaseFiscalYear,@DiscountTaxOverWorth=DiscountTaxOverWorth,
  			@ComssionCostPrice=ComssionCostPrice,@BasculePrice=BasculePrice,@LaborPrice=LaborPrice,@TransportPrice=TransportPrice,
  			@BankID=BankID,@BankID2=BankID2,@CashID=CashID,@BankAmnt=BankAmnt,@BankAmnt2=BankAmnt2,@CashAmnt=CashAmnt,@AwardAmnt=AwardAmnt,@IATollCod=IATollCod,
  			@IAToll=IAToll
		
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	select @VisitorCostAcntCode=VisitorCostAcntCode,@TransportationIncomeAcntCode=TransportationIncomeAcntCode,@DiscountAcntCode=SaleDiscountAcntCode
	
	 From inv.tblStores where StoreID=@StoreID

	IF @SalAcntNameInVoucherDesc = 'True'
		Select @strAcntName = ' به ' + [pub].GetCodeName(@AcntCode, @LanguageID)
	ELSE
		SET @strAcntName = ''
		
--------------------------------------------------------------------------------------------------------
	IF @DistributeCostAcntCode = ''
	BEGIN
		IF @SaleAcntCodeInSaleTypes = 'False'
			SELECT	@DistributeCostAcntCode=DistributeCostAcntCode
			FROM inv.tblStores 
			WHERE StoreID = @StoreID
		ELSE	
			SELECT	@DistributeCostAcntCode=DistributeCostAcntCode
			FROM sal.tblSaleTypes
			WHERE SaleTypeID = @SaleTypeID
	END
	
	IF @SaleAcntCodeInSaleTypes = 'False'
		BEGIN
			SELECT	@SaleAcntCode=SaleAcntCode,@PackingAcntCode=PackingAcntCode,@VisitorCostAcntCode=CASE WHEN @VisitorCostAcntCode = '' THEN VisitorCostAcntCode ELSE @VisitorCostAcntCode END , @VisitorCostAcntCode2=CASE WHEN @VisitorCostAcntCode2 = '' THEN VisitorCostAcntCode ELSE @VisitorCostAcntCode2 END,
					@TaxAcntCode=TaxAcntCode,@SaleTaxOverWorthAcntCode=SaleTaxOverWorthAcntCode,@SaleTollOverWorthAcntCode=SaleTollOverWorthAcntCode
			FROM inv.tblStores 
			WHERE StoreID = @StoreID

		END	
	ELSE
		BEGIN
			SELECT	@SaleAcntCode=SaleAcntCode,@PackingAcntCode=PackingAcntCode,@VisitorCostAcntCode= CASE WHEN @VisitorCostAcntCode = '' THEN VisitorCostAcntCode ELSE @VisitorCostAcntCode END , @VisitorCostAcntCode2=CASE WHEN @VisitorCostAcntCode2 = '' THEN VisitorCostAcntCode ELSE @VisitorCostAcntCode2 END, 
					@TaxAcntCode=TaxAcntCode,@SaleTaxOverWorthAcntCode=SaleTaxOverWorthAcntCode,@SaleTollOverWorthAcntCode=SaleTollOverWorthAcntCode
			FROM sal.tblSaleTypes
			WHERE SaleTypeID = @SaleTypeID

		END			
			--------------------------------------------------------------------------------------------------------
IF @VisitorCostAcntCode=''  AND @VisitorCost <> 0
		BEGIN
			--کد فروش کالا خالي است 
			SET @strMsgText='کد حسابداری هزینه نصاب (هزینه پورسانت بازاریاب در فروش انبار) خالی است'
			Raiserror (@strMsgText,16,1)
			Return
		END
		
	IF @TransportationIncomeAcntCode=''  AND @TransportationIncome <> 0
		BEGIN
			--کد فروش کالا خالي است 
			SET @strMsgText='کد حسابداری درآمد هزینه حمل در فروش خالی است'
			Raiserror (@strMsgText,16,1)
			Return
		END
	--------------------------------------------------------------------------------------------------------
	IF @SaleAcntCode=''
		BEGIN
			--کد فروش کالا خالي است 
			SET @strMsgText=TS.pub.funGetMessages(11029,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	IF @SaleTaxOverWorthAcntCode='' AND @TaxOverWorthCost <>0
		BEGIN
			--کد مالیات بر ارزش افزوده در فروش خالی است
			SET @strMsgText=TS.pub.funGetMessages(11039,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	IF @SaleTollOverWorthAcntCode='' AND @TollOverWorthCost <>0
		BEGIN
			--کد عوارض بر ارزش افزوده در فروش خالی است
			SET @strMsgText=TS.pub.funGetMessages(11043,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END				
	--------------------------------------------------------------------------------------------------------
	IF @SaleTypeID <> '' 
		BEGIN
		
			SELECT @SaleTypeText = ' - ' + SaleTypeName 
			FROM sal.tblSaleTypesDtl 
			WHERE SaleTypeID=@SaleTypeID AND LanguageID = @LanguageID
		
		END
	IF @SettlementDate <> '' AND @ShowSettlementDate = 'True'
		SET @SettlementDate = '- به تاریخ تسویه ' + @SettlementDate
	else
		SET @SettlementDate = ''

	--------------------------------------------------------------------------------------------------------
	
	IF @SalAcntNameInVoucherDesc = 'True'
		Select @strAcntName = ' به ' + [pub].GetCodeName(@AcntCode, @LanguageID)
	ELSE
		SET @strAcntName = ''
				
	SET @SumGoodsPrice  = 0
	SET @SumServicePrice = 0
		SELECT	@SumGoodsPrice=ROUND(SUM(s.GoodsPrice * Case when GoodsQuantity >0 then GoodsQuantity  else VirtualQuantity end ),0), @TotalLineDiscount=isnull(SUM(ROUND(DiscountDtl,0)),0)
		FROM inv.tblStorageDocsDtl s
		Left JOIN inv.tblGoods g
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE --g.IsService='False' AND 
			  g.PartNumber=@UnitPart AND 
			  ProcessID  = @intSourceProcessID AND
			  ProcessNo  = @intSourceProcessNo AND
			  FiscalYear = @intSourceFiscalYear AND
			  SerialNo   = @intSourceSerialNo AND
			  IsReward = 'False'

		SELECT	@SumServicePrice  = ROUND(SUM(s.GoodsPrice *CASE WHEN GoodsQuantity>0 THEN GoodsQuantity ELSE VirtualQuantity END),0), @TotalLineDiscount=@TotalLineDiscount + isnull(SUM(ROUND(DiscountDtl,0)),0)
		FROM inv.tblStorageDocsDtl s
		Left JOIN inv.tblGoods g
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService='True' AND 
			  g.PartNumber=@UnitPart AND 
			  ProcessID  = @intSourceProcessID AND
			  ProcessNo  = @intSourceProcessNo AND
			  FiscalYear = @intSourceFiscalYear AND
			  SerialNo   = @intSourceSerialNo

	
	DECLARE @TotalDiscount FLOAT
	SET  @TotalDiscount = @Discount + @Discount2 + @CurrencyDiscount + @TotalLineDiscount + @CustomerCardDiscount
	
	IF @DiscountTaxOverWorth = 'True'
		SET @TotalDiscount = @TotalDiscount + @TaxOverWorthCost + @TollOverWorthCost
	
	SET @SumGoodsPrice  = ISNULL (@SumGoodsPrice, 0)
	SET @SumServicePrice  = ISNULL (@SumServicePrice, 0)
	
	SET @SumGoodsPriceWithTax = @SumGoodsPrice  + @SumServicePrice
	
	IF @TaxOverWorthViewInCustomerInvoice = 'False'
		SET @SumGoodsPriceWithTax = @SumServicePrice + @SumGoodsPrice + @TollOverWorthCost + @TaxOverWorthCost

	IF @ShowSaleTransportationInBill = 'False'
		SET @SumGoodsPriceWithTax = @SumGoodsPriceWithTax + @TransportationIncome - @TransportationCost

	IF @SumGoodsPriceWithTax = @TotalDiscount
		SET @ShowSaleDiscountInBill = 'TRUE'
		
	--------------------------------------------------------------------------------------------------------
	IF 	@BaseDistributionSerialNo <> 0 AND @BaseDistributionFiscalYear<>0
	BEGIN
		SET @DescDistribution = ' - پخش ' + LTRIM(RTRIM(STR(@BaseDistributionFiscalYear))) + '/' + LTRIM(RTRIM(STR(@BaseDistributionSerialNo))) 
	END	

	IF 	@BaseSerialNo <> 0 AND @BaseProcessID = 180 AND @OrderDescInSaleVoucher = 'True'
	BEGIN
		SET @DescDistribution = @DescDistribution + ' - سفارش ' + LTRIM(RTRIM(STR(@BaseSerialNo))) 
	END	
	--------------------------------------------------------------------------------------------------------
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + @DescDistribution 
	IF @OwnerDocNo > 0
		SET @strRecDesc='فروش '  + @strTitleSale + @strFiscalSerial + @SaleTypeText + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @SettlementDate + @strAcntName
	ELSE
		SET @strRecDesc= 'فروش '  + @strTitleSale + @strFiscalSerial + @SaleTypeText + @SettlementDate + @strAcntName
	
	IF @Address <> ''
		SET @strRecDesc= @strRecDesc + ' آدرس : ' + @Address + @strAcntName
		
	--------------------------------------------------------------------------------------------------------
		Declare @SumQty as Dec=0
		Declare @Price as Dec=0
		
		SELECT	@SumQty= sum(SubUnitQuantity3*Height )
		FROM inv.tblStorageDocsDtl D
		left Join inv.tblUnitsDtl U ON D.SubUnitID = U.UnitID
		WHERE ProcessID=@intSourceProcessID AND
				ProcessNo=@intSourceProcessNo AND
				FiscalYear=@intSourceFiscalYear AND
				SerialNo=@intSourceSerialNo AND
				IsReward = 'False'

	SELECT top 1 @Price=isnull(Price ,0) FROM sal.tblCarriageRatesDtl  where ToArea >=@SumQty ORDER BY ToArea  
			set @TransportationCost=@Price*@SumQty
		
		Declare	curSale CURSOR For 
			SELECT	D.GoodsPrice,D.SubUnitPrice,CASE WHEN GoodsQuantity>0 THEN GoodsQuantity ELSE VirtualQuantity END GoodsQuantity,D.SubUnitQuantity,D.DescDtl,
					pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName,
					pub.funGetGoodsUnitName(D.GoodsID, @LanguageID) AS GoodsMainUnit, U.UnitName GoodsUnit, 
					D.SubUnitID, D.SubUnitID3, D.Height, D.Width, D.SubUnitQuantity3, 
					D.GoodsAmount3, D.ServiceAmount,D.Wage,D.GoodsID
			FROM inv.tblStorageDocsDtl D
			left Join inv.tblUnitsDtl U ON D.SubUnitID = U.UnitID
			WHERE ProcessID=@intSourceProcessID AND
				  ProcessNo=@intSourceProcessNo AND
				  FiscalYear=@intSourceFiscalYear AND
				  SerialNo=@intSourceSerialNo AND
				  IsReward = 'False'				
				  
				  			  
				  		--ELSE
		--	Declare	curSale CURSOR For 
		--	SELECT	GoodsPrice,GoodsQuantity,DescDtl,pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName,pub.funGetGoodsUnitName(GoodsID,@LanguageID) AS GoodsUnit,SubUnitID,SubUnitID3, Height, Width, SubUnitQuantity3, GoodsAmount3,ServiceAmount
		--	FROM inv.tblStorageDocsDtl
		--	WHERE ProcessID=@intSourceProcessID AND
		--		  ProcessNo=@intSourceProcessNo AND
		--		  FiscalYear=@intSourceFiscalYear AND
		--		  SerialNo=@intSourceSerialNo AND
		--		  IsReward = 'False'

		----- فاکتور فروش سطر به سطر به حساب مشتری میرود
		Open  curSale; 
	
		Fetch NEXT From curSale Into @GoodsPrice,@SubUnitPrice,@GoodsQuantity,@SubUnitQuantity,@DescDtl,@GoodsName,@GoodsMainUnit,@GoodsUnit,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount,@Wage,@GoodsID
	
		While (@@Fetch_Status = 0)
			BEGIN
				IF @GoodsPrice <> 0
					BEGIN

						SET @decPrice = Ltrim(rtrim(str(@SubUnitPrice)))
						SET	@StrQuantity = ltrim(rtrim(str(@SubUnitQuantity)))

						if (round(@SubUnitQuantity,0) <> @SubUnitQuantity)
							SET @StrQuantity = ltrim(rtrim(str(@SubUnitQuantity,30,2)))

						IF @decPrice = '0'
						BEGIN
							SET @decPrice =Ltrim(rtrim(str(@GoodsPrice)))  
							SET @StrQuantity = ltrim(rtrim(str(@GoodsQuantity))) 
						END	
						
						SET @strRecDesc2 = ' فروش ' + @strTitleSale + @strFiscalSerial + ' - ' + @GoodsName + ' - ' + @StrQuantity + @GoodsUnit + ' - فی ' + ltrim(rtrim(str(@decPrice))) + @strAcntName
								
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
							
						if @TransportationIncome>0
							SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,0)-@Wage
						else
							SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,0)
						if (Select IsService from inv.tblGoods where SUBSTRING(GoodsID,@str_Goods+1,@str_GoodsSum)=@GoodsID	AND PartNumber=@UnitPart) =1
								Select @SaleAcntCode=CostCenterAcntCode from inv.tblGoods where SUBSTRING(GoodsID,@str_Goods+1,@str_GoodsSum)=@GoodsID	AND PartNumber=@UnitPart
							Set @CurrencyRateTmp	= 0
							Set @CurrencyAmountTmp  = 0
							Set @CurrencyTypeIDTmp  = ''
											
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @SaleAcntCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
					END
	
				Fetch NEXT From curSale Into @GoodsPrice,@SubUnitPrice,@GoodsQuantity,@SubUnitQuantity,@DescDtl,@GoodsName,@GoodsMainUnit,@GoodsUnit,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount,@Wage,@GoodsID
			END
	
		Close curSale;
		Deallocate curSale; 

		----- کل تخفیف به بستانکاری مشتری میرود
		IF  (@TotalDiscount) <> 0
			BEGIN
				IF @OwnerDocNo > 0
					SET @strRecDesc2 = ' تخفیف فروش ' + @strTitleSale  + @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @strAcntName
				ELSE
					SET @strRecDesc2 = ' تخفیف فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
					
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@TotalDiscount,0) / @CurrencyRate
				
					Set @CurrencyRateTmp	= 0
					Set @CurrencyAmountTmp  = 0
					Set @CurrencyTypeIDTmp  = ''
				--	select 		@SaleAcntCode					
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @AcntCode,0 ,ROUND(@TotalDiscount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
			END
		
	--------------------------------------------------------------------------------------------------------

		Declare	curVisitor CURSOR For 
		SELECT	GoodsID,GoodsPrice,CASE WHEN GoodsQuantity>0 THEN GoodsQuantity ELSE VirtualQuantity END GoodsQuantity,SubUnitID,SubUnitID3, Height, Width, SubUnitQuantity3, GoodsAmount3,ServiceAmount
		FROM inv.tblStorageDocsDtl
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 

	Open  curVisitor; 

	Fetch NEXT From curVisitor Into @GoodsID,@GoodsPrice,@GoodsQuantity,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount

	While (@@Fetch_Status = 0)
	BEGIN
		declare @Percent as FLOAT
		
		SELECT @Percent = VisitorPercent 
		FROM inv.tblGoods 
		WHERE GoodsID = SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart 
			
			if @SubUnitID=@SubUnitID3
							SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,0) + ROUND(@ServiceAmount * @GoodsQuantity,0)
							else
							SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,0) + ROUND(@ServiceAmount * @SubUnitQuantity3*@Height,0)
							
			
		IF @Percent<>0
			SET @VisitorCostInGoods = @VisitorCostInGoods + (@Amount* @Percent / 100)
				
		Fetch NEXT From curVisitor Into @GoodsID,@GoodsPrice,@GoodsQuantity,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount
	END
	
	Close curVisitor;
	Deallocate curVisitor; 
	-----
		
	----- کل تخفیف به بدهکاری هزینه میرود
	IF  (@TotalDiscount) <> 0
		BEGIN
			IF @DiscountAcntCode is null OR @DiscountAcntCode = ''
				BEGIN
					--کد تخفیف فروش کالا خالي است 
					SET @strMsgText=TS.pub.funGetMessages(11040,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
				END	
			IF @OwnerDocNo > 0
				SET @strRecDesc2 = ' تخفیف فروش ' + @strTitleSale  + @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @strAcntName
			ELSE
				SET @strRecDesc2 = ' تخفیف فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
				
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@TotalDiscount,0) / @CurrencyRate
			
			IF [acc].[funIsCurrencyAcntCode] (@DiscountAcntCode) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
								
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@DiscountAcntCode,ROUND(@TotalDiscount,0),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
		END


		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@SumGoodsPrice,0) / @CurrencyRate
				
		IF [acc].[funIsCurrencyAcntCode] (@SaleAcntCode) = 'True'
		Begin
			Set @CurrencyRateTmp	= @CurrencyRate
			Set @CurrencyAmountTmp  = @CurrencyAmount
			Set @CurrencyTypeIDTmp  = @CurrencyTypeID
		End
		Else
		Begin
			Set @CurrencyRateTmp	= 0
			Set @CurrencyAmountTmp  = 0
			Set @CurrencyTypeIDTmp  = ''
		End
										
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,IsShowDetail) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,ROUND(@SumGoodsPrice,0),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,'True')
					
					--@SaleAcntCode
	--------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------
	DECLARE @CostCenterAcntCode VARCHAR(30)
	
	Declare	curService CURSOR For 
	SELECT	g.CostCenterAcntCode,s.GoodsPrice,SubUnitQuantity,DescDtl,pub.funGetGoodsName(s.GoodsID,@LanguageID) AS GoodsName
	,SubUnitID,SubUnitID3, Height, Width, SubUnitQuantity3, GoodsAmount3,ServiceAmount
	FROM inv.tblStorageDocsDtl s
	left JOIN inv.tblGoods g
	ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
	WHERE g.IsService = 'True' AND 
	      g.PartNumber=@UnitPart AND 
		  ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

		Open  curService; 
	
		Fetch NEXT From curService Into @CostCenterAcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount
	
		While (@@Fetch_Status = 0)
			BEGIN
				IF @GoodsPrice <> 0
					BEGIN
						SET @strRecDesc2 = ' فروش ' + @strTitleSale + @strFiscalSerial + ' - خدمات ' + @GoodsName + ' - ' + ltrim(rtrim(str(@GoodsQuantity)))  + ' - فی ' + ltrim(rtrim(str(@GoodsPrice))) + @strAcntName
								
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
				if @SubUnitID=@SubUnitID3
							SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,0) +ROUND( @ServiceAmount * @GoodsQuantity,0)
							else
							SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,0) +ROUND( @ServiceAmount * @SubUnitQuantity3*@Height*@Width,0)
					
						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = @Amount / @CurrencyRate
						
						IF [acc].[funIsCurrencyAcntCode] (@CostCenterAcntCode) = 'True'
						Begin
							Set @CurrencyRateTmp	= @CurrencyRate
							Set @CurrencyAmountTmp  = @CurrencyAmount
							Set @CurrencyTypeIDTmp  = @CurrencyTypeID
						End
						Else
						Begin
							Set @CurrencyRateTmp	= 0
							Set @CurrencyAmountTmp  = 0
							Set @CurrencyTypeIDTmp  = ''
						End
											
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @CostCenterAcntCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp)							 
					END
	
				Fetch NEXT From curService Into @CostCenterAcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount
			END
	
		Close curService;
		Deallocate curService; 
	--------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------

	-------------------------------------------------هزینه حمل و نقل---------------------------------------
	IF @TransportationCostAcntCode <> '' AND @TransportationCost <> 0
		BEGIN
			DECLARE @strRecDescTransCost VARCHAR(1000) 
			
			--SET @strRecDescTransCost = ' هزینه حمل فروش ' + @strTitleSale + @strFiscalSerial
			SET @strRecDescTransCost = ' كرايه حمل فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@TransportationCost,0) / @CurrencyRate
			
			IF [acc].[funIsCurrencyAcntCode] (@TransportationCostAcntCode) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
											
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@TransportationCostAcntCode,ROUND(@TransportationCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)						
			--------------------------------------------------------------------------------------------------------
			IF @ShowSaleTransportationInBill = 'True'
				BEGIN
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,0,ROUND(@TransportationCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID)								
				END
		END

	-------------------------------------------------درآمد حمل و نقل---------------------------------------
	IF @TransportationIncomeAcntCode <> '' AND @TransportationIncome <> 0
		BEGIN
		
			DECLARE @strRecDescTrans VARCHAR(1000) 
			
			-- SET @strRecDescTrans = ' درآمد حمل فروش ' + @strTitleSale + @strFiscalSerial
			SET @strRecDescTrans = ' كرايه حمل فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

			--------------------------------------------------------------------------------------------------------
			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@TransportationIncome,0) / @CurrencyRate
			
			IF [acc].[funIsCurrencyAcntCode] (@AcntCode) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
								
			IF @ShowSaleTransportationInBill = 'True'
				BEGIN
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,ROUND(@TransportationIncome,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
				END	
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@TransportationIncomeAcntCode,0,ROUND(@TransportationIncome,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),'',0,@CurrencyAmount,@CurrencyTypeID)
		END
----------------------------------------------- بازاریاب --------------------------------------------
--Select @VisitorAcntCode VisitorAcntCode,@VisitorCostAcntCode VisitorCostAcntCode,@VisitorCost VisitorCost,@VisitorCostInGoods VisitorCostInGoods
IF @VisitorAcntCode	<> '' AND @VisitorCostAcntCode	<> '' AND (@VisitorCost <> 0 OR @VisitorCostInGoods <> 0)
	BEGIN
	
		set 	@VisitorAcntCode = substring (@VisitorAcntCodeInSale ,1,acc.FunGetAcntInfoForRemain(2)-1) +@VisitorAcntCode

--	select @VisitorAcntCode
		IF @VisitorPercent > 0
			BEGIN
				IF @DiscountMinusFromVisitor = 1
					BEGIN	
						SET @VisitorCostTmp = (@SumGoodsPrice * @VisitorPercent) / 100
					END
				ELSE
					BEGIN
						SET @VisitorCostTmp = ((@SumGoodsPrice - (@TotalDiscount )) * @VisitorPercent) / 100
					END
			END
			
		IF @VisitorCostTmp > 0
			SET @VisitorCost = @VisitorCostTmp

		SET @VisitorCost = @VisitorCost + @VisitorCostInGoods
		----------------------------------------------------------------------------------------------------------
		DECLARE @strRecDescVisitor VARCHAR(1000) 
		Declare @NamePartNo AS Tinyint

		SET @NamePartNo = 1
		
		SELECT @NamePartNo = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

		SELECT @strRecDescVisitor = [acc].[funGetAcntName]([pub].[funSplitString](@AcntCode,' ' ,@NamePartNo),@NamePartNo,@LanguageID)
		SET @strRecDescVisitor = ' هزینه نصاب فروش <<' + @strRecDescVisitor + '>>'+ @strTitleSale + @strFiscalSerial + @strAcntName
		
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@VisitorCost,0) / @CurrencyRate
		
		IF [acc].[funIsCurrencyAcntCode] (@VisitorCostAcntCode) = 'True'
		Begin
			Set @CurrencyRateTmp	= @CurrencyRate
			Set @CurrencyAmountTmp  = @CurrencyAmount
			Set @CurrencyTypeIDTmp  = @CurrencyTypeID
		End
		Else
		Begin
			Set @CurrencyRateTmp	= 0
			Set @CurrencyAmountTmp  = 0
			Set @CurrencyTypeIDTmp  = ''
		End
								
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@VisitorCostAcntCode,ROUND(@VisitorCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
									
		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@VisitorAcntCode,0,ROUND(@VisitorCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0,@CurrencyAmount)
										
					
	END				
		-----------------------------------------------مالیات بر ارزش افزوده--------------------------------------------
IF @SaleTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0
	BEGIN
		--------------------------------------------------------------------------------------------------------
		DECLARE @strRecDescTaxOverWorth VARCHAR(1000) 
		SET @strRecDescTaxOverWorth = ' مالیات بر ارزش افزوده فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
		
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@TaxOverWorthCost,0) / @CurrencyRate
		
		IF [acc].[funIsCurrencyAcntCode] (@AcntCode) = 'True'
		Begin
			Set @CurrencyRateTmp	= @CurrencyRate
			Set @CurrencyAmountTmp  = @CurrencyAmount
			Set @CurrencyTypeIDTmp  = @CurrencyTypeID
		End
		Else
		Begin
			Set @CurrencyRateTmp	= 0
			Set @CurrencyAmountTmp  = 0
			Set @CurrencyTypeIDTmp  = ''
		End
						
		IF @TaxOverWorthViewInCustomerInvoice = 'True'
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,ROUND(@TaxOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,2)
		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 			SELECT @SaleTaxOverWorthAcntCode = [pub].[funMergCode](@SaleTaxOverWorthAcntCode,@AcntCode)

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@SaleTaxOverWorthAcntCode,0,ROUND(@TaxOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0,@CurrencyAmount,@CurrencyTypeID,2)
		
	END

		-----------------------------------------------عوارض بر ارزش افزوده--------------------------------------------
	IF @SaleTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0
		BEGIN
			--------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescTollOverWorth VARCHAR(1000) 
			SET @strRecDescTollOverWorth = ' عوارض بر ارزش افزوده فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@TollOverWorthCost,0) / @CurrencyRate
			
			IF [acc].[funIsCurrencyAcntCode] (@AcntCode) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
							
			IF @TaxOverWorthViewInCustomerInvoice = 'True'
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,ROUND(@TollOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,3)
		
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 				SELECT @SaleTollOverWorthAcntCode = [pub].[funMergCode](@SaleTollOverWorthAcntCode,@AcntCode)

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@SaleTollOverWorthAcntCode,0,ROUND(@TollOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0,@CurrencyAmount,3)
			
		END

	-------------------------------------------------سایر هزینه ها در فروش---------------------------------------
IF @FixCostAcntCode <> '' AND @FixCost <> 0
	BEGIN
		DECLARE @strRecDescFixCost VARCHAR(1000) 
		
		SET @strRecDescFixCost = ' هزینه نصب در فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@FixCost,0) / @CurrencyRate
			
		IF [acc].[funIsCurrencyAcntCode] (@FixCostAcntCode) = 'True'
		Begin
			Set @CurrencyRateTmp	= @CurrencyRate
			Set @CurrencyAmountTmp  = @CurrencyAmount
			Set @CurrencyTypeIDTmp  = @CurrencyTypeID
		End
		Else
		Begin
			Set @CurrencyRateTmp	= 0
			Set @CurrencyAmountTmp  = 0
			Set @CurrencyTypeIDTmp  = ''
		End
								
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @FixCostAcntCode,ROUND(@FixCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescFixCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
				 
		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,0,ROUND(@FixCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescFixCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID)

	END
												
-------------------------------------------------سایر هزینه ها در فروش---------------------------------------
IF @OtherCostAcntCode <> '' AND @OtherCost <> 0
	BEGIN
		DECLARE @strRecDescOtherCost VARCHAR(1000) 
		
		SET @strRecDescOtherCost = 'سایر هزینه ها در فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@OtherCost,0) / @CurrencyRate
			
		IF [acc].[funIsCurrencyAcntCode] (@OtherCostAcntCode) = 'True'
		Begin
			Set @CurrencyRateTmp	= @CurrencyRate
			Set @CurrencyAmountTmp  = @CurrencyAmount
			Set @CurrencyTypeIDTmp  = @CurrencyTypeID
		End
		Else
		Begin
			Set @CurrencyRateTmp	= 0
			Set @CurrencyAmountTmp  = 0
			Set @CurrencyTypeIDTmp  = ''
		End
							
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@OtherCostAcntCode,ROUND(@OtherCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
					
		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,0,ROUND(@OtherCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID)

	END

-------------------------------------------------'سایر درآمد ها در فروش---------------------------------------
IF @OtherIncomeAcntCode <> '' AND @OtherIncome <> 0
	BEGIN
		DECLARE @strRecDescIncome VARCHAR(1000) 
		
		--SET @strRecDescIncome = 'سایر درآمد ها در فروش ' + @strTitleSale + @strFiscalSerial
		SET @strRecDescIncome = 'سایر اضافات در فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@OtherIncome,0) / @CurrencyRate
		
		IF [acc].[funIsCurrencyAcntCode] (@AcntCode) = 'True'
		Begin
			Set @CurrencyRateTmp	= @CurrencyRate
			Set @CurrencyAmountTmp  = @CurrencyAmount
			Set @CurrencyTypeIDTmp  = @CurrencyTypeID
		End
		Else
		Begin
			Set @CurrencyRateTmp	= 0
			Set @CurrencyAmountTmp  = 0
			Set @CurrencyTypeIDTmp  = ''
		End
						
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,ROUND(@OtherIncome,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),pub.funReverseForCrystal(@DescHdr),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
					
		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@OtherIncomeAcntCode,0,ROUND(@OtherIncome,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),'',0,@CurrencyAmount,@CurrencyTypeID)

	END

	-----
IF @TransportPriceAcntCode <> '' AND @TransportPrice <> 0
	BEGIN

		DECLARE @strRecDescTransportPrice VARCHAR(1000) 
		SET @strRecDescTransportPrice = ' هزينه حمل فروش ' + @strTitleSale + ' شماره' + @strFiscalSerial + @strAcntName
		 
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0
			SET @CurrencyAmount = ROUND(@TransportPrice,0) / @CurrencyRate
		
		IF [acc].[funIsCurrencyAcntCode] (@AcntCode) = 'True'
		Begin
			Set @CurrencyRateTmp	= @CurrencyRate
			Set @CurrencyAmountTmp  = @CurrencyAmount
			Set @CurrencyTypeIDTmp  = @CurrencyTypeID
		End
		Else
		Begin
			Set @CurrencyRateTmp	= 0
			Set @CurrencyAmountTmp  = 0
			Set @CurrencyTypeIDTmp  = ''
		End
						
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @AcntCode,ROUND(@TransportPrice,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransportPrice)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @TransportPriceAcntCode,0,ROUND(@TransportPrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransportPrice)),'',0,@CurrencyAmount,@CurrencyTypeID)

	END	
		
exec 	acc.SpBalanceVoucher @intVchNo,@AcntCode ,@intSourceProcessID,
	@intSourceProcessNo,
	@intSourceFiscalYear,
	@intSourceSerialNo	

					
END
GO
