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
Create PROCEDURE [acc].[SpVchSale]
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
	@LanguageID				TinyInt,
	@VchKind				TinyInt = 1

WITH ENCRYPTION
AS

BEGIN 
-----
Declare @strMsgText					NVarChar(2044)
Declare @strTitleSale		    	NVarChar(100)
Declare @DescDtl					NVarChar(1000)
Declare @DescHdr					NVarChar(1000)
Declare @DescHdr2					NVarChar(1000)
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
Declare @AdvertisingPercent			float
Declare @AdvertisingCostAcntCode	Varchar(20)
Declare @AdvertisingReserveAcntCode Varchar(20)
Declare @SaleAcntCode				Varchar(20)
Declare @StoreID					Varchar(20)
Declare @SaleTypeID					Varchar(20)
Declare @AcntCode					Varchar(20)
Declare @AtomAcntCode				Varchar(20)
Declare @VisitorAcntCode			Varchar(20)
Declare @VisitorCostAcntCode		Varchar(20)
Declare @VisitorAcntCode2			Varchar(20)
Declare @VisitorCostAcntCode2		Varchar(20)
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
Declare @AmountHdr				Float
Declare @IAToll					Float
Declare @GoodsPrice				Float
Declare @SubUnitPrice			Float
Declare @SubUnitPrice2			Float
Declare @GoodsQuantity			Float
Declare @SubUnitQuantity		Float
Declare @Discount				Float
Declare @Discount2				FLOAT
Declare @CurrencyDiscount		FLOAT
Declare @CustomerCardDiscount	FLOAT
Declare @TotalLineDiscount		Float
Declare @TotalLineDiscountFloor	Float
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
Declare @SumGoodsPriceFloor		Float
Declare @ConstTextSumGoodsPrice	Float
Declare @SumServicePrice		Float
Declare @SumServicePriceFloor	Float
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
Declare @DiscountDtl			FLOAT
Declare @TotalLineDiscountSrv	Float
Declare @decPrice				varchar(30)
Declare @CurrencyTransportationCost		Float
Declare @CurrencyTransportationIncome	Float
Declare @CurrencyTransportationCostChange	Float
Declare @CurrencyTransportationIncomeChange	Float


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
DECLARE @AllowOtherIncomeInDtl				 BIT
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
DECLARE @buy_AddConstText1ToGoodsPrice   BIT
DECLARE @buy_AddConstText2ToGoodsPrice   BIT
DECLARE @buy_AddConstText3ToGoodsPrice   BIT
DECLARE @buy_AddConstText4ToGoodsPrice   BIT

declare @Sal_StoreVariable1			nVarChar(100)
declare @Sal_StoreVariable2			nVarChar(100)
declare @Sal_StoreVariable3			nVarChar(100)
declare @Sal_StoreVariable4			nVarChar(100)
declare @Sal_StoreVariableAddVch1	bit
declare @Sal_StoreVariableAddVch2	bit
declare @Sal_StoreVariableAddVch3	bit
declare @Sal_StoreVariableAddVch4	bit
Declare @Var1						Float
Declare @Var2						Float
Declare @Var3						Float
Declare @Var4						Float
declare @PriceDecimalsToForms		tinyint
declare @UsedPriceDecimalsToFormsInVch BIT
declare @ShowRewardCostInSale		BIT
declare @inv_GoodsAcntGroup			BIT
Declare @inv_GoodsAcntGroupWithStoreID bit
declare @Sal_IncomeAndCostAccountFillFromCustomer BIT
declare @Sal_ViewSaleTypeNameInVchNo BIT
Declare @GoodsAcntCodeGroup	    	Varchar(20)
Declare @SaleGoodsAcntGroup			Varchar(20)
declare @AcntPartNumberBranchPartNo Integer		
DECLARE @TollOverWorthPercentInSale as float
declare @sal_AddDocDesc2AfterDocDescInVoucher	BIT
declare @Sal_SaleProcessForTaxTollSender	BIT
Declare @Sal_TaxAcntCompletWithCustCode bit

SET @TollOverWorthPercentInSale=0
SET @AcntPartNumberBranchPartNo=0
SET @inv_GoodsAcntGroup = 'False'
SET @inv_GoodsAcntGroupWithStoreID   = 'False'
SET @UsedPriceDecimalsToFormsInVch='False'
SET @ShowRewardCostInSale='False'
SET @Sal_ViewSaleTypeNameInVchNo='False'
SET @PriceDecimalsToForms = 0
SET @PriceDecimalsToForms = 0

IF @intSourceProcessNo = 1
	select @Sal_SaleProcessForTaxTollSender=SettingValue from pub.tblSettings where SettingKey='Sal_SaleProcessForTaxTollSender1'
ELSE IF @intSourceProcessNo = 2
	select @Sal_SaleProcessForTaxTollSender=SettingValue from pub.tblSettings where SettingKey='Sal_SaleProcessForTaxTollSender2'
ELSE IF @intSourceProcessNo = 3
	select @Sal_SaleProcessForTaxTollSender=SettingValue from pub.tblSettings where SettingKey='Sal_SaleProcessForTaxTollSender3'
ELSE IF @intSourceProcessNo = 4
	select @Sal_SaleProcessForTaxTollSender=SettingValue from pub.tblSettings where SettingKey='Sal_SaleProcessForTaxTollSender4'
ELSE IF @intSourceProcessNo = 10
	select @Sal_SaleProcessForTaxTollSender=SettingValue from pub.tblSettings where SettingKey='Sal_SaleProcessForTaxTollSender10'
ELSE IF @intSourceProcessNo = 11
	select @Sal_SaleProcessForTaxTollSender=SettingValue from pub.tblSettings where SettingKey='Sal_SaleProcessForTaxTollSender11'

IF @Sal_SaleProcessForTaxTollSender IS NULL
	SET @Sal_SaleProcessForTaxTollSender = 'False'

select @TollOverWorthPercentInSale=SettingValue from pub.tblSettings where SettingKey='TollOverWorthPercentInSale'
select @Sal_StoreVariable1=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariable1'
select @Sal_StoreVariable2=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariable2'
select @Sal_StoreVariable3=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariable3'
select @Sal_StoreVariable4=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariable4'
select @Sal_StoreVariableAddVch1=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariableAddVch1'
select @Sal_StoreVariableAddVch2=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariableAddVch2'
select @Sal_StoreVariableAddVch3=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariableAddVch3'
select @Sal_ViewSaleTypeNameInVchNo=SettingValue from pub.tblSettings where SettingKey='Sal_ViewSaleTypeNameInVchNo'
select @UsedPriceDecimalsToFormsInVch=SettingValue from pub.tblSettings where SettingKey='UsedPriceDecimalsToFormsInVch'
select @ShowRewardCostInSale=SettingValue from pub.tblSettings where SettingKey='ShowRewardCostInSale'
select @AcntPartNumberBranchPartNo=SettingValue from pub.tblSettings where SettingKey='AcntPartNumberBranchPartNo'
SELECT @inv_GoodsAcntGroup = SettingValue FROM pub.tblSettings WHERE UPPER(SettingKey) = UPPER('inv_GoodsAcntGroup')
SELECT @inv_GoodsAcntGroupWithStoreID=SettingValue FROM pub.tblSettings WHERE SettingKey='inv_GoodsAcntGroupWithStoreID'
select @sal_AddDocDesc2AfterDocDescInVoucher=SettingValue from pub.tblSettings where SettingKey='sal_AddDocDesc2AfterDocDescInVoucher'
select @Sal_TaxAcntCompletWithCustCode=SettingValue from pub.tblSettings where SettingKey='Sal_TaxAcntCompletWithCustCode'


select @TollOverWorthPercentInSale=SettingValue from pub.tblSettings where SettingKey='TollOverWorthPercentInSale'

IF @UsedPriceDecimalsToFormsInVch='True'
	SELECT @PriceDecimalsToForms=SettingValue from pub.tblSettings where SettingKey='PriceDecimalsToForms'

IF @inv_GoodsAcntGroup='True' OR @inv_GoodsAcntGroupWithStoreID = 'True'
	set @ShowRewardCostInSale='True'
-----
SET	@Discount = 0
SET @Discount2 = 0	
SET @CurrencyDiscount = 0	
SET @CurrencyTransportationCost = 0
SET @CurrencyTransportationIncome = 0
SET @CurrencyTransportationCostChange = 0
SET @CurrencyTransportationIncomeChange = 0
SET @CustomerCardDiscount = 0				
SET @TotalLineDiscountSrv = 0
SET @DiscountDtl = 0
SET @TotalLineDiscount = 0
SET @TotalLineDiscountFloor = 0
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
SET @DescHdr2 = ''
SET @DescDistribution = ''
SET @SettlementDate = ''
SET @StrQuantity = ''	
SET @CurrencyRate = 0 	
SET @CurrencyAmount = 0
SET @ShowSaleTransportationInBill = 'True'
SET @SaleAcntCodeInSaleTypes = 'False'
SET @GetAcntCodeFromStore = 'False'
SET @Sal_StoreDtl = 'False'
set @AllowOtherIncomeInDtl='False'
SET @AwardPayedAcntCode = ''
DECLARE @UnitPart TINYINT
SET @UnitPart  = 1

SET @CurrencyRateTmp = 0
SET @CurrencyAmountTmp = 0
SET @CurrencyTypeIDTmp = ''
SET @Sal_IncomeAndCostAccountFillFromCustomer = 0

SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

SELECT @buy_AddConstText1ToGoodsPrice = SettingValue FROM pub.tblSettings WHERE SettingKey = 'buy_AddConstText1ToGoodsPrice' 
SELECT @buy_AddConstText2ToGoodsPrice = SettingValue FROM pub.tblSettings WHERE SettingKey = 'buy_AddConstText2ToGoodsPrice' 
SELECT @buy_AddConstText3ToGoodsPrice = SettingValue FROM pub.tblSettings WHERE SettingKey = 'buy_AddConstText3ToGoodsPrice' 
SELECT @buy_AddConstText4ToGoodsPrice = SettingValue FROM pub.tblSettings WHERE SettingKey = 'buy_AddConstText4ToGoodsPrice' 


SELECT @AllowOtherIncomeInDtl = SettingValue FROM pub.tblSettings WHERE SettingKey = 'AllowOtherIncomeInDtl' 

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

SELECT @strTitleSale = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'TitleSale' + LTRIM(RTRIM(STR(@intSourceProcessNo)))

SELECT @HasDST = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'HasDST' 

SELECT @TaxOverWorthViewInCustomerInvoice = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'TaxOverWorthViewInCustomerInvoice' 

SELECT @ShowSettlementDate = SettingValue
FROM   pub.tblSettings
WHERE SettingKey = 'ShowSettlementDate' 

SELECT @OrderDescInSaleVoucher = SettingValue
FROM   pub.tblSettings
WHERE SettingKey = 'OrderDescInSaleVoucher' 	

SELECT @ShowSaleTransportationInBill = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'ShowSaleTransportationInBill' 

SELECT @SaleAcntCodeInSaleTypes = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'SaleAcntCodeInSaleTypes' 

SELECT @Sal_IncomeAndCostAccountFillFromCustomer = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'Sal_IncomeAndCostAccountFillFromCustomer' 


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
IF @intDocStep = 11
	BEGIN
		Declare @AfterSaleDiscount		Float
		Declare @AfterSaleDesc			NVarchar(1000)
		SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
		
		SET @strRecDesc=' تخفیفات پس از فروش ' + @strTitleSale + @strFiscalSerial
		
		SELECT	@StoreID=StoreID,@AcntCode=AcntCode,@AfterSaleDiscount=AfterSaleDiscount,@AfterSaleDesc=AfterSaleDesc ,
				@AfterSaleDiscountAcntCode=AfterSaleDiscountAcntCode ,@DescHdr= DocDesc,@DescHdr2= DocDesc2,@CurrencyRate=CurrencyRate,
				@BaseDistributionSerialNo = BaseDistributionSerialNo,@BaseDistributionFiscalYear=BaseDistributionFiscalYear,@VisitorAcntCode=VisitorAcntCode
				,@CurrencyTypeID=CurrencyTypeID
		FROM inv.tblStorageDocsHdr
		WHERE ProcessID=90 AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 

		IF @sal_AddDocDesc2AfterDocDescInVoucher = 'True'
			set @DescHdr=@DescHdr+' - '+@DescHdr2

		IF @SalAcntNameInVoucherDesc = 'True'
			Select @strAcntName = ' به ' + [pub].GetCodeName(@AcntCode, @LanguageID)
		ELSE
			SET @strAcntName = ''
		
		IF 	@BaseDistributionSerialNo <> 0 AND @BaseDistributionFiscalYear<>0
			BEGIN
				SET @DescDistribution = ' - پخش ' + LTRIM(RTRIM(STR(@BaseDistributionFiscalYear))) + '/' + LTRIM(RTRIM(STR(@BaseDistributionSerialNo))) + @strAcntName
				SET @strRecDesc = @strRecDesc + @DescDistribution + @strAcntName
			END	
			
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@AfterSaleDiscount,@PriceDecimalsToForms) / @CurrencyRate
		
		IF [acc].[funIsCurrencyAcntCode] (@AfterSaleDiscountAcntCode) = 'True'
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

		IF @Sal_IncomeAndCostAccountFillFromCustomer=1
			SET @AfterSaleDiscountAcntCode = RTRIM(@AfterSaleDiscountAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@AfterSaleDiscountAcntCode))+1,20)
				
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
				 @AfterSaleDiscountAcntCode,ROUND(@AfterSaleDiscount,@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AfterSaleDesc)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)	
--select @AfterSaleDiscount
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
					
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode ) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,0,ROUND(@AfterSaleDiscount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AfterSaleDesc + ' ' + @DescHdr )),0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)	
		 -- select @AfterSaleDiscount
		  return 
	END	

ELSE

	BEGIN
		
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
				@CurrencyTransportationCost = CurrencyTransportationCost ,
				@CurrencyTransportationIncome = CurrencyTransportationIncome ,
				@CurrencyTransportationCostChange = (CurrencyTransportationCost * CurrencyRate),
				@CurrencyTransportationIncomeChange = (CurrencyTransportationIncome * CurrencyRate),
				@CustomerCardDiscount = CCDiscount,@TransportationCost=TransportationCost,@TransportationIncome=TransportationIncome,
				@PackingCost=PackingCost,@TaxCost=TaxCost,@VisitorCostAcntCode=VisitorCostAcntCode,@VisitorAcntCode=VisitorAcntCode,
				@VisitorPercent=VisitorPercent,@VisitorCost=VisitorCost,@VisitorCostAcntCode2=VisitorCostAcntCode2,@VisitorAcntCode2=VisitorAcntCode2,
				@VisitorPercent2=VisitorPercent2,@VisitorCost2=VisitorCost2,@DistributeCostAcntCode=DistributeCostAcntCode,
				@DistributeAcntCode=DistributeAcntCode,@DistributePercent=DistributePercent,@DistributeAmount=DistributeAmount,
				@DiscountAcntCode=DiscountAcntCode,@EarnestMoney=EarnestMoney,@EarnestMoneyPercent=EarnestMoneyPercent,@CurrencyRate=CurrencyRate,
				@TransportationCostAcntCode=TransportationCostAcntCode,@TransportationIncomeAcntCode=TransportationIncomeAcntCode,
				@EarnestMoneyAcntCode=EarnestMoneyAcntCode,@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost,@SaleTypeID=SaleTypeID, 
				@OtherCostAcntCode=OtherCostAcntCode,@FixCostAcntCode=FixCostAcntCode,@OtherIncomeAcntCode=OtherIncomeAcntCode,@FixCost=FixCost,@OtherCost=OtherCost,@OtherIncome=OtherIncome,@DescHdr= DocDesc,@DescHdr2= DocDesc2,
				@BaseDistributionSerialNo = BaseDistributionSerialNo,@BaseDistributionFiscalYear=BaseDistributionFiscalYear,@SettlementDate=SettlementDate,
				@BaseSerialNo = BaseSerialNo,@BaseProcessID = BaseProcessID,@OwnerDocNo=OwnerDocNo,@CurrencyTypeID=CurrencyTypeID,
				@Address=[Address],@BaseProcessNo = BaseProcessNo,@BaseFiscalYear = BaseFiscalYear,@DiscountTaxOverWorth=DiscountTaxOverWorth,
	  			@ComssionCostPrice=ComssionCostPrice,@BasculePrice=BasculePrice,@LaborPrice=LaborPrice,@TransportPrice=TransportPrice,
	  			@BankID=BankID,@BankID2=BankID2,@CashID=CashID,@BankAmnt=BankAmnt,@BankAmnt2=BankAmnt2,@CashAmnt=CashAmnt,@AwardAmnt=AwardAmnt,@IATollCod=IATollCod,
	  			@IAToll=IAToll,@AmountHdr=Amount
		FROM inv.tblStorageDocsHdr
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 
		
		IF @sal_AddDocDesc2AfterDocDescInVoucher = 'True'
			set @DescHdr=@DescHdr+' - '+@DescHdr2
		
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
						,@AdvertisingPercent=AdvertisingPercent,@AdvertisingCostAcntCode=AdvertisingCostAcntCode,@AdvertisingReserveAcntCode=AdvertisingReserveAcntCode
				FROM inv.tblStores 
				WHERE StoreID = @StoreID

			END	
		ELSE
			BEGIN
				SELECT	@SaleAcntCode=SaleAcntCode,@PackingAcntCode=PackingAcntCode,@VisitorCostAcntCode= CASE WHEN @VisitorCostAcntCode = '' THEN VisitorCostAcntCode ELSE @VisitorCostAcntCode END , @VisitorCostAcntCode2=CASE WHEN @VisitorCostAcntCode2 = '' THEN VisitorCostAcntCode ELSE @VisitorCostAcntCode2 END, 
						@TaxAcntCode=TaxAcntCode,@SaleTaxOverWorthAcntCode=SaleTaxOverWorthAcntCode,@SaleTollOverWorthAcntCode=SaleTollOverWorthAcntCode
						,@AdvertisingPercent=AdvertisingPercent,@AdvertisingCostAcntCode=AdvertisingCostAcntCode,@AdvertisingReserveAcntCode=AdvertisingReserveAcntCode
				FROM sal.tblSaleTypes
				WHERE SaleTypeID = @SaleTypeID

			END	

		IF @Sal_IncomeAndCostAccountFillFromCustomer=1
		BEGIN
			SET @SaleAcntCode = RTRIM(@SaleAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@SaleAcntCode))+1,20)
			SET @PackingAcntCode = RTRIM(@PackingAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@PackingAcntCode))+1,20)
			SET @DiscountAcntCode = RTRIM(@DiscountAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@DiscountAcntCode))+1,20)
			SET @TransportationCostAcntCode = RTRIM(@TransportationCostAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@TransportationCostAcntCode))+1,20)
			SET @TransportationIncomeAcntCode = RTRIM(@TransportationIncomeAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@TransportationIncomeAcntCode))+1,20)
			SET @FixCostAcntCode = RTRIM(@FixCostAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@FixCostAcntCode))+1,20)
			SET @OtherCostAcntCode = RTRIM(@OtherCostAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@OtherCostAcntCode))+1,20)
			SET @OtherIncomeAcntCode = RTRIM(@OtherIncomeAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@OtherIncomeAcntCode))+1,20)
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
		IF @SaleTypeID <> '' AND @Sal_ViewSaleTypeNameInVchNo = 'True'
			BEGIN
				SELECT @SaleTypeText = ' - ' + SaleTypeName 
				FROM sal.tblSaleTypesDtl 
				WHERE SaleTypeID=@SaleTypeID AND LanguageID = @LanguageID
			END
		IF @SettlementDate <> '' AND @ShowSettlementDate = 'True'
			SET @SettlementDate = '- به تاریخ تسویه ' + @SettlementDate
		else
			SET @SettlementDate = ''

	---------------------------------------
	IF @BaseProcessID =180 
		BEGIN
			 
			IF (SELECT TOP 1 VchNo FROM sal.tblSaleOrderHdr 
			    WHERE ProcessID = @BaseProcessID AND 
				       ProcessNo = @BaseProcessNo AND 
					   FiscalYear= @BaseFiscalYear AND 	
				      SerialNo  = @BaseSerialNo 
				      AND VchNo > 0 )>0
				BEGIN
						
					SELECT @AcntCode = SettingValue
					FROM pub.tblSettings
					WHERE SettingKey = 'SaleOrderAcntCode'
					
					Declare @TempAcnt varchar(20)

					SELECT  @TempAcnt = AcntCode FROM sal.tblSaleOrderHdr 
					WHERE ProcessID = @BaseProcessID AND 
						   ProcessNo = @BaseProcessNo AND 
						   FiscalYear= @BaseFiscalYear AND 	
						  SerialNo  = @BaseSerialNo
					
					SET @AcntCode = @AcntCode + SUBSTRING(@TempAcnt ,LEN(@AcntCode)+1,20)
				END	   	
			
		END
		
	---------------------------------------
	declare @PreSaleProcessID int =@BaseProcessID
	declare @PreSaleProcessNo int =@BaseProcessNo
	declare @PreSaleFiscalYear int =@BaseFiscalYear
	declare @PreSaleSerialNo int =@BaseSerialNo

	IF 	@BaseProcessID = 180
	BEGIN
		SELECT @PreSaleProcessID=BaseDocType
			  ,@PreSaleProcessNo=BaseProcessNo
			  ,@PreSaleFiscalYear=BaseFiscalYear
			  ,@PreSaleSerialNo=BaseSerialNo
		FROM sal.tblSaleOrderHdr 
		WHERE ProcessID  = @BaseProcessID  AND 
			  ProcessNo  = @BaseProcessNo  AND
			  FiscalYear = @BaseFiscalYear AND 	
			  SerialNo   = @BaseSerialNo
	END
	
	IF @PreSaleProcessID =240 
		BEGIN
			Declare @FiscalYear int
			Declare @VchNo		int
			Declare @TempAcnt1 varchar(20)
	
			SET @FiscalYear =  RIGHT(db_name(),4)
			SET @VchNo=0
	
			if @PreSaleFiscalYear<>@FiscalYear  and @PreSaleFiscalYear<>0
			begin		
				DECLARE @Query			NVarchar(max)
				DECLARE @db_Old			NVarchar(50)
				DECLARE @ParmDefinition NVarChar(200)
				DECLARE @CountResult	VARCHAR(1000)
			
				SET @VchNo = 0
				SET @ParmDefinition = N'@CountOUT as int  OUTPUT,@CountOUT2 as VARCHAR(1000) OUTPUT';
				SET @db_Old = Substring(db_name(), 1, Len(db_name()) - 4) + ltrim(str(@PreSaleFiscalYear))					
			
				SET @Query = 'SELECT top 1  @CountOUT= VchNo, @CountOUT2 = AcntCode FROM ' + @db_Old + '.inv.tblPreSaleHdr 
					WHERE ProcessID = '+str(@PreSaleProcessID)+' AND 
						  FiscalYear= '+str(@PreSaleFiscalYear)+' AND 	
						  SerialNo  = '+str(@PreSaleSerialNo)+' AND
						  VchNo > 0 '
				print @Query
				Exec sp_executesql @Query,@ParmDefinition, @CountOUT = @VchNo OUTPUT, @CountOUT2 = @TempAcnt1 OUTPUT;;
			end 

			IF (SELECT  top 1 VchNo FROM inv.tblPreSaleHdr 
			    WHERE ProcessID = @PreSaleProcessID AND 
				      FiscalYear= @PreSaleFiscalYear AND 	
				      SerialNo  = @PreSaleSerialNo AND
				      VchNo > 0 )>0 or @VchNo>0
				BEGIN
						
					SELECT @AcntCode = isnull(SettingValue,'')
					FROM pub.tblSettings
					WHERE SettingKey = 'SaleOrderAcntCode'
					if @VchNo=0
					SELECT  @TempAcnt1 = AcntCode FROM inv.tblPreSaleHdr 
					WHERE ProcessID = @PreSaleProcessID AND 
						  FiscalYear= @PreSaleFiscalYear AND 	
						  SerialNo  = @PreSaleSerialNo
					
					SET @AcntCode = @AcntCode + SUBSTRING(@TempAcnt1 ,LEN(@AcntCode)+1,20)
				END	   	
		
		END			
		--------------------------------------------------------------------------------------------------------
		
		IF @SalAcntNameInVoucherDesc = 'True'
			Select @strAcntName = ' به ' + [pub].GetCodeName(@AcntCode, @LanguageID)
		ELSE
			SET @strAcntName = ''
					
		SET @SumGoodsPrice  = 0
		SET @SumGoodsPriceFloor  = 0
		SET @SumServicePrice = 0
		SET @SumServicePriceFloor = 0
--			IF @HasDST = 'False' 

			SELECT	@SumGoodsPrice  = SUM(Case When  SubUnitID=SubUnitID3  then  ROUND((s.GoodsPrice +(
				 Case When IsNumeric(s.ConstText1) = 1 AND @buy_AddConstText1ToGoodsPrice = 'True' Then s.ConstText1 Else 0 End +
				 Case When IsNumeric(s.ConstText2) = 1 AND @buy_AddConstText2ToGoodsPrice = 'True'  Then s.ConstText2 Else 0 End + 
				 Case When IsNumeric(s.ConstText3) = 1 AND @buy_AddConstText3ToGoodsPrice = 'True'  Then s.ConstText3 Else 0 End + 
				Case When IsNumeric(s.ConstText4) = 1 AND @buy_AddConstText4ToGoodsPrice = 'True'  Then s.ConstText4 Else 0 End)) * GoodsQuantity,@PriceDecimalsToForms) 
			+ROUND( ServiceAmount * GoodsQuantity,@PriceDecimalsToForms) else
			(s.GoodsPrice +(
				 Case When IsNumeric(s.ConstText1) = 1 AND @buy_AddConstText1ToGoodsPrice = 'True' Then s.ConstText1 Else 0 End +
				 Case When IsNumeric(s.ConstText2) = 1 AND @buy_AddConstText2ToGoodsPrice = 'True'  Then s.ConstText2 Else 0 End + 
				 Case When IsNumeric(s.ConstText3) = 1 AND @buy_AddConstText3ToGoodsPrice = 'True'  Then s.ConstText3 Else 0 End + 
				Case When IsNumeric(s.ConstText4) = 1 AND @buy_AddConstText4ToGoodsPrice = 'True'  Then s.ConstText4 Else 0 End))* GoodsQuantity
				 + ROUND(ServiceAmount * SubUnitQuantity3 * Height,0)
			end	), @TotalLineDiscount=ROUND(isnull(SUM(DiscountDtl+DiscountDtlTaxToll),0),@PriceDecimalsToForms),
			@SumGoodsPriceFloor  = SUM(Case When  SubUnitID=SubUnitID3  then  Floor((Cast(s.GoodsPrice as decimal(30,10 )) +(
				 Case When IsNumeric(s.ConstText1) = 1 AND @buy_AddConstText1ToGoodsPrice = 'True' Then s.ConstText1 Else 0 End +
				 Case When IsNumeric(s.ConstText2) = 1 AND @buy_AddConstText2ToGoodsPrice = 'True'  Then s.ConstText2 Else 0 End + 
				 Case When IsNumeric(s.ConstText3) = 1 AND @buy_AddConstText3ToGoodsPrice = 'True'  Then s.ConstText3 Else 0 End + 
				Case When IsNumeric(s.ConstText4) = 1 AND @buy_AddConstText4ToGoodsPrice = 'True'  Then s.ConstText4 Else 0 End)) * GoodsQuantity) 
			+Floor( ServiceAmount * GoodsQuantity) else
			FLOOR((Cast(s.GoodsPrice as decimal(30,10 )) +(
				 Case When IsNumeric(s.ConstText1) = 1 AND @buy_AddConstText1ToGoodsPrice = 'True' Then s.ConstText1 Else 0 End +
				 Case When IsNumeric(s.ConstText2) = 1 AND @buy_AddConstText2ToGoodsPrice = 'True'  Then s.ConstText2 Else 0 End + 
				 Case When IsNumeric(s.ConstText3) = 1 AND @buy_AddConstText3ToGoodsPrice = 'True'  Then s.ConstText3 Else 0 End + 
				Case When IsNumeric(s.ConstText4) = 1 AND @buy_AddConstText4ToGoodsPrice = 'True'  Then s.ConstText4 Else 0 End))* GoodsQuantity)
				 + Floor(ServiceAmount * SubUnitQuantity3 * Height)
			end	), @TotalLineDiscountFloor=isnull(SUM(Floor(DiscountDtl+DiscountDtlTaxToll)),0)
			FROM inv.tblStorageDocsDtl s
			Left JOIN inv.tblGoods g
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
			WHERE g.IsService='False' AND 
				  g.PartNumber=@UnitPart AND 
				  ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo AND
				  (@ShowRewardCostInSale='True' or IsReward = 'False')

			SELECT	@SumServicePrice  = ROUND(SUM(s.GoodsPrice *GoodsQuantity),@PriceDecimalsToForms), @TotalLineDiscount=@TotalLineDiscount + isnull(ROUND(SUM(DiscountDtl+DiscountDtlTaxToll),@PriceDecimalsToForms),0)
				   ,@SumServicePriceFloor  = SUM(Floor(Cast(s.GoodsPrice as decimal(30,10 )) *GoodsQuantity)), @TotalLineDiscountFloor=@TotalLineDiscountFloor + isnull(Floor(SUM(DiscountDtl+DiscountDtlTaxToll)),0)
				   , @TotalLineDiscountSrv=@TotalLineDiscountSrv+ isnull(Floor(SUM(Case when  g.SaleDiscountAcntCode='' then 0 else DiscountDtl+DiscountDtlTaxToll end)),0)
			FROM inv.tblStorageDocsDtl s
			Left JOIN inv.tblGoods g
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
			WHERE g.IsService='True' AND 
				  g.PartNumber=@UnitPart AND 
				  ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo
--			ELSE
--				SELECT	@SumGoodsPrice  = SUM(ROUND(GoodsPrice *SubUnitQuantity,0))
--				FROM inv.tblStorageDocsDtl
--				WHERE ProcessID  = @intSourceProcessID AND
--					  ProcessNo  = @intSourceProcessNo AND
--					  FiscalYear = @intSourceFiscalYear AND
--					  SerialNo   = @intSourceSerialNo 			 

		IF @Sal_SaleProcessForTaxTollSender = 'True'
		BEGIN
			SET @SumGoodsPrice=@SumGoodsPriceFloor
			SET @SumServicePrice=@SumServicePriceFloor
			SET @TotalLineDiscount=@TotalLineDiscountFloor
		END
		
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
			SET @SumGoodsPriceWithTax = @SumGoodsPriceWithTax + @TransportationIncome - @TransportationCost - @CurrencyTransportationCostChange + @CurrencyTransportationIncomeChange
		
		DECLARE @TotalTransportationCost FLOAT
			SET @TotalTransportationCost =  @TransportationCost + @CurrencyTransportationCostChange

		DECLARE @TotalTransportationIncome FLOAT
			SET @TotalTransportationIncome =  @TransportationIncome + @CurrencyTransportationIncomeChange

		IF @SumGoodsPriceWithTax = @TotalDiscount
			SET @ShowSaleDiscountInBill = 'TRUE'
			
		--------------------------------------------------------------------------------------------------------
		IF 	@BaseDistributionSerialNo <> 0 AND @BaseDistributionFiscalYear<>0
		BEGIN
			SET @DescDistribution = ' - پخش ' + LTRIM(RTRIM(STR(@BaseDistributionFiscalYear))) + '/' + LTRIM(RTRIM(STR(@BaseDistributionSerialNo))) 
		END	

		IF 	@BaseSerialNo <> 0  AND @OrderDescInSaleVoucher = 'True'
		BEGIN
			IF @BaseProcessID = 180
				SET @DescDistribution = @DescDistribution + ' - سفارش ' + LTRIM(RTRIM(STR(@BaseSerialNo))) 
			ELSE IF @BaseProcessID = 240
				SET @DescDistribution = @DescDistribution + ' - پیش فاکتور ' + LTRIM(RTRIM(STR(@BaseSerialNo))) 
		END	
		
		--------------------------------------------------------------------------------------------------------
		SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + @DescDistribution 
		IF @OwnerDocNo > 0
			SET @strRecDesc='فروش '  + @strTitleSale + @strFiscalSerial + @SaleTypeText + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @SettlementDate + @strAcntName
		ELSE
			SET @strRecDesc='فروش '  + @strTitleSale + @strFiscalSerial + @SaleTypeText + @SettlementDate + @strAcntName
					
		IF @Address <> ''
			SET @strRecDesc= @strRecDesc + ' آدرس : ' + @Address + @strAcntName
			
		--------------------------------------------------------------------------------------------------------
		----- اگر جمع کل فروش به حساب مشتری منظور میشود
		IF @TotalSale2Account = 1
		BEGIN
			DECLARE @OtherIncomeNotShow Decimal
			SET @OtherIncomeNotShow = 0
			IF @AllowOtherIncomeInDtl = 1
				SET @OtherIncomeNotShow =  @OtherIncome
			----- اگر تخفیف از جمع فروش کسر نمیشود
			IF @ShowSaleDiscountInBill = 0
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
							
				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = (@SumGoodsPriceWithTax - @EarnestMoney - (@TotalDiscount)) / @CurrencyRate
				
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
				
				IF ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - @EarnestMoney - (@TotalDiscount) - @BankAmnt - @BankAmnt2 - @CashAmnt - @AwardAmnt,@PriceDecimalsToForms)>0
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCode,ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - @EarnestMoney - (@TotalDiscount) - @BankAmnt - @BankAmnt2 - @CashAmnt - @AwardAmnt,@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
				ELSE
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCode,0,-1*ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - @EarnestMoney - (@TotalDiscount) - @BankAmnt - @BankAmnt2 - @CashAmnt - @AwardAmnt,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)


--select ROUND(@SumGoodsPriceWithTax - @EarnestMoney - (@TotalDiscount) - @BankAmnt - @BankAmnt2 - @CashAmnt - @AwardAmnt,0)
			END

			ELSE ----- IF @ShowSaleDiscountInBill = 1
			----- اگر تخفیف از جمع فروش کسر میشود
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = (@SumGoodsPriceWithTax - @EarnestMoney) / @CurrencyRate
				
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
					
				IF ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - @EarnestMoney - @BankAmnt - @BankAmnt2 - @CashAmnt - @AwardAmnt,@PriceDecimalsToForms)>0
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - @EarnestMoney - @BankAmnt - @BankAmnt2 - @CashAmnt - @AwardAmnt,@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
				ELSE
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,0,-1*ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - @EarnestMoney - @BankAmnt - @BankAmnt2 - @CashAmnt - @AwardAmnt,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

--select ROUND(@SumGoodsPriceWithTax - @EarnestMoney - @BankAmnt - @BankAmnt2 - @CashAmnt - @AwardAmnt,0)

				IF  (@TotalDiscount) <> 0
					BEGIN
						IF @DiscountAcntCode is null OR @DiscountAcntCode = ''
							BEGIN
								SELECT	@DiscountAcntCode=SaleDiscountAcntCode
								FROM inv.tblStores 
								WHERE StoreID = @StoreID
								IF @DiscountAcntCode is null OR @DiscountAcntCode = ''--کد تخفیف فروش کالا خالي است 
								BEGIN
									SET @strMsgText=TS.pub.funGetMessages(11040,@LanguageID)
									Raiserror (@strMsgText,16,1)
									Return
								END	
							END	
						IF @OwnerDocNo > 0
							SET @strRecDesc2 = ' تخفیف فروش ' + @strTitleSale  + @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @strAcntName
						ELSE
							SET @strRecDesc2 = ' تخفیف فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
							
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = ROUND(@TotalDiscount,0) / @CurrencyRate
						
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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@AcntCode,0 ,ROUND(@TotalDiscount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
							--		select ROUND(@TotalDiscount,0)
					END

			END	
		END

		ELSE ----- IF @TotalSale2Account = 0
		----- اگر تک تک آیتمهای فروش به حساب مشتری منظور میشود
		BEGIN
			
			--IF @HasDST = 'False' 
				Declare	curSale CURSOR For 
				SELECT	D.GoodsPrice
				 +ROUND( (
				 Case When IsNumeric(ConstText1) = 1 AND @buy_AddConstText1ToGoodsPrice = 'True' Then ConstText1 Else 0 End +
				 Case When IsNumeric(ConstText2) = 1 AND @buy_AddConstText2ToGoodsPrice = 'True'  Then ConstText2 Else 0 End + 
				 Case When IsNumeric(ConstText3) = 1 AND @buy_AddConstText3ToGoodsPrice = 'True'  Then ConstText3 Else 0 End + 
				Case When IsNumeric(ConstText4) = 1 AND @buy_AddConstText4ToGoodsPrice = 'True'  Then ConstText4 Else 0 End),@PriceDecimalsToForms)
				,D.SubUnitPrice,D.SubUnitPrice2,D.GoodsQuantity,D.SubUnitQuantity,D.DescDtl,
						pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName,
						pub.funGetGoodsUnitName(D.GoodsID, @LanguageID) AS GoodsMainUnit, U.UnitName GoodsUnit, 
						D.SubUnitID, D.SubUnitID3, D.Height, D.Width, D.SubUnitQuantity3, 
						D.GoodsAmount3, D.ServiceAmount
						,D.Var1,D.Var2,D.Var3,D.Var4
				FROM inv.tblStorageDocsDtl D
				left Join inv.tblUnitsDtl U ON D.SubUnitID = U.UnitID
				WHERE ProcessID=@intSourceProcessID AND
					  ProcessNo=@intSourceProcessNo AND
					  FiscalYear=@intSourceFiscalYear AND
					  SerialNo=@intSourceSerialNo AND
					  (@ShowRewardCostInSale='True' or IsReward = 'False')
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
		
			Fetch NEXT From curSale Into @GoodsPrice,@SubUnitPrice,@SubUnitPrice2,@GoodsQuantity,@SubUnitQuantity,@DescDtl,@GoodsName,@GoodsMainUnit,@GoodsUnit,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount,@Var1,@Var2,@Var3,@Var4
		
			While (@@Fetch_Status = 0)
				BEGIN
					IF @GoodsPrice <> 0
						BEGIN

							SET @decPrice = Ltrim(rtrim(str(@SubUnitPrice,30)))
							SET	@StrQuantity = ltrim(rtrim(str(@SubUnitQuantity,30)))

							if (round(@SubUnitQuantity,0) <> @SubUnitQuantity)
								SET @StrQuantity = ltrim(rtrim(str(@SubUnitQuantity,30,2)))

							IF @decPrice = '0'
							BEGIN
								IF @SubUnitQuantity<>@GoodsQuantity AND @SubUnitPrice2>0
								BEGIN
									SET @decPrice =Ltrim(rtrim(str(@SubUnitPrice2,30)))  
									SET @StrQuantity = ltrim(rtrim(str(@SubUnitQuantity,len(@SubUnitQuantity),3))) 
								END
								ELSE
								BEGIN
									SET @decPrice =Ltrim(rtrim(str(@GoodsPrice,30)))  
									SET @StrQuantity = ltrim(rtrim(str(@GoodsQuantity,len(@GoodsQuantity),3))) 
								END
							END	
							--SET @strRecDesc2 = ' فروش ' + @strTitleSale + @strFiscalSerial + ' - ' + @GoodsName + ' - ' + @StrQuantity + @GoodsUnit + ' - فی ' + ltrim(rtrim(str(@GoodsPrice))) + @strAcntName
							SET @strRecDesc2 = ' فروش ' + @strTitleSale + @strFiscalSerial + ' -  @GoodsName  - ' + @StrQuantity + @GoodsUnit + ' - فی ' + @decPrice + @strAcntName
								
							if  @Sal_StoreVariableAddVch1=1	SET @strRecDesc2 = @strRecDesc2 + ' ' + @Sal_StoreVariable1+ ' ' +str( @Var1)
							if  @Sal_StoreVariableAddVch2=1	SET @strRecDesc2 = @strRecDesc2 + ' ' + @Sal_StoreVariable2+ ' ' +str( @Var2)
							if  @Sal_StoreVariableAddVch3=1	SET @strRecDesc2 = @strRecDesc2 + ' ' + @Sal_StoreVariable3+ ' ' + str(@Var3)
							if  @Sal_StoreVariableAddVch4=1	SET @strRecDesc2 = @strRecDesc2 + ' ' + @Sal_StoreVariable4+ ' ' + str(@Var4)
	
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1
							
							--, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount
							
							if @SubUnitID = @SubUnitID3
								SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,@PriceDecimalsToForms) + ROUND( @ServiceAmount * @GoodsQuantity, @PriceDecimalsToForms)
								else
								SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,@PriceDecimalsToForms) + ROUND( @ServiceAmount * @SubUnitQuantity3 * @Height, @PriceDecimalsToForms)
				
							IF @CurrencyRate <> 0 	
								SET @CurrencyAmount = @Amount / @CurrencyRate
							
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

							set @strRecDesc2 = pub.funReverseForCrystal(@strRecDesc2)
							set	@strRecDesc2 = REPLACE(@strRecDesc2,'@GoodsName',@GoodsName)
							
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									 @AcntCode,@Amount,0,TS.pub.funChangeFarsiStrings(@strRecDesc2), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
					--	select @Amount
						END
		
					Fetch NEXT From curSale Into @GoodsPrice,@SubUnitPrice,@SubUnitPrice2,@GoodsQuantity,@SubUnitQuantity,@DescDtl,@GoodsName,@GoodsMainUnit,@GoodsUnit,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount,@Var1,@Var2,@Var3,@Var4
				END
		
			Close curSale;
			Deallocate curSale; 

			IF (@BankID <>'' AND @BankAmnt>0) OR (@BankID2 <>'' AND @BankAmnt2>0) OR (@CashID <>'' AND @CashAmnt>0) OR (@AwardPayedAcntCode <>'' AND @AwardAmnt>0)
				BEGIN
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@BankAmnt+@AwardAmnt,@PriceDecimalsToForms) / @CurrencyRate
					
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,0 ,ROUND(@BankAmnt+@BankAmnt2+@CashAmnt+@AwardAmnt,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
				--	select ROUND(@BankAmnt+@BankAmnt2+@CashAmnt+@AwardAmnt,0)
				END

			--IF (@BankID2 <>'' AND @BankAmnt2>0) OR (@AwardPayedAcntCode <>'' AND @AwardAmnt>0)
			--	BEGIN
			--		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			--		SET @intMaxRowNo = @intMaxRowNo + 1

			--		IF @CurrencyRate <> 0 	
			--			SET @CurrencyAmount = ROUND(@BankAmnt+@AwardAmnt,0) / @CurrencyRate
					
			--		INSERT INTO acc.tblVoucherDtl
			--				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
			--					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			--		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
			--					@AcntCode,0 ,ROUND(@BankAmnt+@AwardAmnt,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)
					
			--	END
													
			IF @EarnestMoneyAcntCode <> '' AND @EarnestMoney <> 0
				BEGIN
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@EarnestMoney,@PriceDecimalsToForms) / @CurrencyRate
					
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,0 ,ROUND(@EarnestMoney,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
--select ROUND(@EarnestMoney,0)
				END

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
						SET @CurrencyAmount = ROUND(@TotalDiscount,@PriceDecimalsToForms) / @CurrencyRate
					
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							 @AcntCode,0 ,ROUND(@TotalDiscount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
				--	select ROUND(@TotalDiscount,0)			
				END
			
		END


		IF @BankID <>'' AND @BankAmnt>0
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				DECLARE @AcntOurBank VARCHAR(20)
				IF @OwnerDocNo > 0
					SET @strRecDesc2 = ' دریافت بابت فروش ' + @strTitleSale  + @strFiscalSerial + ' فاکتور  ' + ltrim(rtrim(str(@OwnerDocNo))) + @strAcntName
				ELSE
					SET @strRecDesc2 = ' دریافت بابت فروش ' + @strTitleSale  + @strFiscalSerial + @strAcntName

				SELECT @AcntOurBank =AcntCode1 from trs.tblOurBanks WHERE BankCode = @BankID
				
				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@BankAmnt,@PriceDecimalsToForms) / @CurrencyRate
				
				IF [acc].[funIsCurrencyAcntCode] (@AcntOurBank) = 'True'
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
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntOurBank ,ROUND(@BankAmnt,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
							--select ROUND(@BankAmnt,0)
			END

		IF @BankID2 <>'' AND @BankAmnt2>0
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				DECLARE @AcntOurBank2 VARCHAR(20)
				IF @OwnerDocNo > 0
					SET @strRecDesc2 = ' دریافت بابت فروش ' + @strTitleSale  + @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @strAcntName
				ELSE
					SET @strRecDesc2 = ' دریافت بابت فروش ' + @strTitleSale  + @strFiscalSerial + @strAcntName
					
				SELECT @AcntOurBank2 =AcntCode1 from trs.tblOurBanks WHERE BankCode = @BankID2
				
				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@BankAmnt2,@PriceDecimalsToForms) / @CurrencyRate
				
				IF [acc].[funIsCurrencyAcntCode] (@AcntOurBank2) = 'True'
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
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntOurBank2 ,ROUND(@BankAmnt2,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			END

		IF @CashID <>'' AND @CashAmnt>0
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				DECLARE @AcntOurBank3 VARCHAR(20)
				IF @OwnerDocNo > 0
					SET @strRecDesc2 = ' دریافت بابت فروش ' + @strTitleSale  + @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @strAcntName
				ELSE
					SET @strRecDesc2 = ' دریافت بابت فروش ' + @strTitleSale  + @strFiscalSerial + @strAcntName

				SELECT @AcntOurBank3 =AcntCode1 from trs.tblOurBanks WHERE BankCode = @CashID
				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@BankAmnt2,@PriceDecimalsToForms) / @CurrencyRate
				
				IF [acc].[funIsCurrencyAcntCode] (@AcntOurBank3) = 'True'
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
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntOurBank3 ,ROUND(@CashAmnt,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			--select ROUND(@CashAmnt,0) 
			END
						
		IF @AwardPayedAcntCode <>'' AND @AwardAmnt>0
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				IF @OwnerDocNo > 0
					SET @strRecDesc2 = ' هدیه ' + @strTitleSale  + @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @strAcntName
				else
					SET @strRecDesc2 = ' هدیه ' + @strTitleSale  + @strFiscalSerial + @strAcntName
				
				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@AwardAmnt,@PriceDecimalsToForms) / @CurrencyRate
				
				IF [acc].[funIsCurrencyAcntCode] (@AwardPayedAcntCode) = 'True'
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
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@AwardPayedAcntCode ,ROUND(@AwardAmnt,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			END
				
		--------------------------------------------------------------------------------------------------------

					-----
		--IF @HasDST = 'False' 
			Declare	curVisitor CURSOR For 
			SELECT	GoodsID,GoodsPrice,GoodsQuantity,SubUnitID,SubUnitID3, Height, Width, SubUnitQuantity3, GoodsAmount3,ServiceAmount
			FROM inv.tblStorageDocsDtl
			WHERE ProcessID=@intSourceProcessID AND
				  ProcessNo=@intSourceProcessNo AND
				  FiscalYear=@intSourceFiscalYear AND
				  SerialNo=@intSourceSerialNo 
		--ELSE
		--	Declare	curVisitor CURSOR For 
		--	SELECT	GoodsID,GoodsPrice,SubUnitQuantity,SubUnitID,SubUnitID3, Height, Width, SubUnitQuantity3, GoodsAmount3,ServiceAmount
		--	FROM inv.tblStorageDocsDtl
		--	WHERE ProcessID=@intSourceProcessID AND
		--		  ProcessNo=@intSourceProcessNo AND
		--		  FiscalYear=@intSourceFiscalYear AND
		--		  SerialNo=@intSourceSerialNo 

		Open  curVisitor; 

		Fetch NEXT From curVisitor Into @GoodsID,@GoodsPrice,@GoodsQuantity,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount

		While (@@Fetch_Status = 0)
		BEGIN
			declare @Percent as FLOAT
			
			SELECT @Percent = VisitorPercent 
			FROM inv.tblGoods 
			WHERE GoodsID = SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart 
				
				if @SubUnitID=@SubUnitID3
								SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,@PriceDecimalsToForms) + ROUND(@ServiceAmount * @GoodsQuantity,@PriceDecimalsToForms)
								else
								SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,@PriceDecimalsToForms) + ROUND(@ServiceAmount * @SubUnitQuantity3*@Height,@PriceDecimalsToForms)
								
				
			IF @Percent<>0
				SET @VisitorCostInGoods = @VisitorCostInGoods + (@Amount* @Percent / 100)
					
			Fetch NEXT From curVisitor Into @GoodsID,@GoodsPrice,@GoodsQuantity,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount
		END
		
		Close curVisitor;
		Deallocate curVisitor; 
		-----
			
		----- کل تخفیف به بدهکاری هزینه میرود
		IF  (@TotalDiscount-@TotalLineDiscountSrv) <> 0
		begin
			IF @inv_GoodsAcntGroupWithStoreID = 'True' 
			BEGIN
			----------تخفیفات جایزه------------------------------------------------------------------------------------------------
				Declare	@DtlDiscountDtlReward1  FLOAT
				Declare	@RowRewardAcntCode1	   varchar(20)
			
				Declare	curSet CURSOR For 

				SELECT	s.StoreID,[acc].[funMerg_AcntCode](ss.RowRewardAcntCode,P2AcntCode,P3AcntCode,P4AcntCode) RowRewardAcntCode1,ROUND(SUM(s.DiscountDtl+DiscountDtlTaxToll),@PriceDecimalsToForms)
				FROM inv.tblStorageDocsDtl s
				INNER JOIN inv.tblStores ss
				ON s.StoreID=ss.StoreID
				INNER JOIN inv.tblGoods g
				ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
				INNER JOIN inv.tblGoodsAcntGroup ga ON ga.GoodsAcntGroupID=g.GoodsAcntGroupID
				WHERE g.IsService='False' AND 
					  (s.IsReward='True' Or 
					  s.IsReward0='True' )AND 
					  g.PartNumber=@UnitPart AND 
					  ProcessID  = @intSourceProcessID AND
					  ProcessNo  = @intSourceProcessNo AND
					  FiscalYear = @intSourceFiscalYear AND
					  SerialNo   = @intSourceSerialNo AND
					  ss.RowDiscountAcntCode<>''
				group by s.StoreID,[acc].[funMerg_AcntCode](ss.RowRewardAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)
				----- فاکتور فروش سطر به سطر به حساب مشتری میرود
				Open  curSet; 
		
				Fetch NEXT From curSet Into @StoreID,@RowRewardAcntCode1,@DtlDiscountDtlReward1
		
				While (@@Fetch_Status = 0)
					BEGIN
						IF @RowRewardAcntCode1 is null OR @RowRewardAcntCode1 = ''
						BEGIN
							--کد تخفیف فروش کالا خالي است 
							SET @strMsgText=N'کد تخفیف جایزه  برگشت از فروش در تعریف انبار خالی است '
							Raiserror (@strMsgText,16,1)
							Return
						END	

						IF @OwnerDocNo > 0
							SET @strRecDesc2 = ' تخفیف جایزه سطری فروش ' + @strTitleSale  + @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @strAcntName
						ELSE
							SET @strRecDesc2 = ' تخفیف جایزه سطری فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
					

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = ROUND(@DtlDiscountDtlReward1,@PriceDecimalsToForms) / @CurrencyRate
							
						IF [acc].[funIsCurrencyAcntCode] (@RowRewardAcntCode1) = 'True'
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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@RowRewardAcntCode1,ROUND(@DtlDiscountDtlReward1,@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

						SET @TotalDiscount = @TotalDiscount - ROUND(@DtlDiscountDtlReward1,@PriceDecimalsToForms) 
							
						Fetch NEXT From curSet Into  @StoreID,@RowRewardAcntCode1,@DtlDiscountDtlReward1
					END
					
				Close curSet;
				Deallocate curSet; 

			-------------تخفیفات بدون جایزه-----------------------------------------------------------------------------------
	 
				Declare	@DtlDiscountDtl1  FLOAT
				Declare	@RowDiscountAcntCode1	   varchar(20)

				Declare	curSet CURSOR For 

				SELECT	s.StoreID,[acc].[funMerg_AcntCode](ss.RowDiscountAcntCode,P2AcntCode,P3AcntCode,P4AcntCode) RowDiscountAcntCode1,floor(SUM(s.DiscountDtl+DiscountDtlTaxToll))
				FROM inv.tblStorageDocsDtl s
				INNER JOIN inv.tblStores ss
				ON s.StoreID=ss.StoreID
				INNER JOIN inv.tblGoods g
				ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
				INNER JOIN inv.tblGoodsAcntGroup ga ON ga.GoodsAcntGroupID=g.GoodsAcntGroupID
				WHERE g.IsService='False' AND 
					  s.IsReward='False' AND 
					  s.IsReward0='False' AND 
					  g.PartNumber=@UnitPart AND 
					  ProcessID  = @intSourceProcessID AND
					  ProcessNo  = @intSourceProcessNo AND
					  FiscalYear = @intSourceFiscalYear AND
					  SerialNo   = @intSourceSerialNo AND
					  ga.RowDiscountAcntCode<>''
				group by s.StoreID,[acc].[funMerg_AcntCode](ss.RowDiscountAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)
				----- فاکتور فروش سطر به سطر به حساب مشتری میرود
				Open  curSet; 
		
				Fetch NEXT From curSet Into @StoreID,@RowDiscountAcntCode1,@DtlDiscountDtl1
		
				While (@@Fetch_Status = 0)
					BEGIN
						IF @RowDiscountAcntCode1 is null OR @RowDiscountAcntCode1 = ''
						BEGIN
							--کد تخفیف فروش کالا خالي است 
							SET @strMsgText=N'کد تخفیف  برگشت از فروش در تعریف انبار خالي است '
							Raiserror (@strMsgText,16,1)
							Return
						END	
						IF @OwnerDocNo > 0
							SET @strRecDesc2 = ' تخفیف سطری فروش ' + @strTitleSale  + @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @strAcntName
						ELSE
							SET @strRecDesc2 = ' تخفیف سطری فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
					
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = ROUND(@DtlDiscountDtl1,@PriceDecimalsToForms) / @CurrencyRate
							
						IF [acc].[funIsCurrencyAcntCode] (@RowDiscountAcntCode1) = 'True'
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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@RowDiscountAcntCode1,ROUND(@DtlDiscountDtl1,@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

						SET @TotalDiscount = @TotalDiscount - ROUND(@DtlDiscountDtl1,@PriceDecimalsToForms) 
							
						Fetch NEXT From curSet Into @StoreID,@RowDiscountAcntCode1,@DtlDiscountDtl1
					END
					
				Close curSet;
				Deallocate curSet; 

				END

		ELSE IF @inv_GoodsAcntGroup = 'True' 
			BEGIN
			----------تخفیفات جایزه------------------------------------------------------------------------------------------------
				Declare	@DtlDiscountDtlReward  FLOAT
				Declare	@RowRewardAcntCode	   varchar(20)
			
				Declare	curSet CURSOR For 

				SELECT	g.GoodsAcntGroupID,RowRewardAcntCode,ROUND(SUM(s.DiscountDtl+DiscountDtlTaxToll),@PriceDecimalsToForms)
				FROM inv.tblStorageDocsDtl s
				INNER JOIN inv.tblGoods g
				ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
				INNER JOIN inv.tblGoodsAcntGroup ga ON ga.GoodsAcntGroupID=g.GoodsAcntGroupID
				WHERE g.IsService='False' AND 
					  (s.IsReward='True' Or 
					  s.IsReward0='True' )AND 
					  g.PartNumber=@UnitPart AND 
					  ProcessID  = @intSourceProcessID AND
					  ProcessNo  = @intSourceProcessNo AND
					  FiscalYear = @intSourceFiscalYear AND
					  SerialNo   = @intSourceSerialNo AND
					  g.GoodsAcntGroupID <>'' AND
					  ga.RowDiscountAcntCode<>''
				group by g.GoodsAcntGroupID,RowRewardAcntCode
				----- فاکتور فروش سطر به سطر به حساب مشتری میرود
				Open  curSet; 
		
				Fetch NEXT From curSet Into @GoodsAcntCodeGroup,@RowRewardAcntCode,@DtlDiscountDtlReward
		
				While (@@Fetch_Status = 0)
					BEGIN
				IF @RowRewardAcntCode is null OR @RowRewardAcntCode = ''
					BEGIN
						--کد تخفیف فروش کالا خالي است 
						SET @strMsgText=N'کد تخفیف جایزه فروش در رده کالا خالي است '
						Raiserror (@strMsgText,16,1)
						Return
					END	

						IF @OwnerDocNo > 0
							SET @strRecDesc2 = ' تخفیف جایزه سطری فروش ' + @strTitleSale  + @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @strAcntName
						ELSE
							SET @strRecDesc2 = ' تخفیف جایزه سطری فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
					
						if @AcntPartNumberBranchPartNo<>0	and  len(@RowRewardAcntCode)>acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)
							set @RowRewardAcntCode=substring (@RowRewardAcntCode,1,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) -1)+
							substring (@AcntCode,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) ,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2))+
							substring (@RowRewardAcntCode,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)+acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2),20)

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = ROUND(@DtlDiscountDtlReward,@PriceDecimalsToForms) / @CurrencyRate
							
						IF [acc].[funIsCurrencyAcntCode] (@RowRewardAcntCode) = 'True'
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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@RowRewardAcntCode,ROUND(@DtlDiscountDtlReward,@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

						SET @TotalDiscount = @TotalDiscount - ROUND(@DtlDiscountDtlReward,@PriceDecimalsToForms) 
							
						Fetch NEXT From curSet Into @GoodsAcntCodeGroup,@RowRewardAcntCode,@DtlDiscountDtlReward
					END
					
				Close curSet;
				Deallocate curSet; 

			-------------تخفیفات بدون جایزه-----------------------------------------------------------------------------------
	 
				Declare	@DtlDiscountDtl  FLOAT
				Declare	@RowDiscountAcntCode	   varchar(20)

				Declare	curSet CURSOR For 

				SELECT	g.GoodsAcntGroupID,RowDiscountAcntCode,floor(SUM(s.DiscountDtl+DiscountDtlTaxToll))
				FROM inv.tblStorageDocsDtl s
				INNER JOIN inv.tblGoods g
				ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
				INNER JOIN inv.tblGoodsAcntGroup ga ON ga.GoodsAcntGroupID=g.GoodsAcntGroupID
				WHERE g.IsService='False' AND 
					  s.IsReward='False' AND 
					  s.IsReward0='False' AND 
					  g.PartNumber=@UnitPart AND 
					  ProcessID  = @intSourceProcessID AND
					  ProcessNo  = @intSourceProcessNo AND
					  FiscalYear = @intSourceFiscalYear AND
					  SerialNo   = @intSourceSerialNo AND
					  g.GoodsAcntGroupID <>'' AND
					  ga.RowDiscountAcntCode<>''
				group by g.GoodsAcntGroupID,RowDiscountAcntCode
				----- فاکتور فروش سطر به سطر به حساب مشتری میرود
				Open  curSet; 
		
				Fetch NEXT From curSet Into @GoodsAcntCodeGroup,@RowDiscountAcntCode,@DtlDiscountDtl
		
				While (@@Fetch_Status = 0)
					BEGIN
					IF @RowDiscountAcntCode is null OR @RowDiscountAcntCode = ''
					BEGIN
						--کد تخفیف فروش کالا خالي است 
						SET @strMsgText=N'کد تخفیف فروش در رده کالا خالي است '
						Raiserror (@strMsgText,16,1)
						Return
					END	
						IF @OwnerDocNo > 0
							SET @strRecDesc2 = ' تخفیف سطری فروش ' + @strTitleSale  + @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo))) + @strAcntName
						ELSE
							SET @strRecDesc2 = ' تخفیف سطری فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
					
						if @AcntPartNumberBranchPartNo<>0	and  len(@RowDiscountAcntCode)>acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)
							set @RowDiscountAcntCode=substring (@RowDiscountAcntCode,1,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) -1)+
							substring (@AcntCode,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) ,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2))+
							substring (@RowDiscountAcntCode,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)+acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2),20)

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = ROUND(@DtlDiscountDtl,@PriceDecimalsToForms) / @CurrencyRate
							
						IF [acc].[funIsCurrencyAcntCode] (@RowDiscountAcntCode) = 'True'
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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@RowDiscountAcntCode,ROUND(@DtlDiscountDtl,@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

						SET @TotalDiscount = @TotalDiscount - ROUND(@DtlDiscountDtl,@PriceDecimalsToForms) 
							
						Fetch NEXT From curSet Into @GoodsAcntCodeGroup,@RowDiscountAcntCode,@DtlDiscountDtl
					END
					
				Close curSet;
				Deallocate curSet; 

				END 

				--kk
			IF  (@TotalDiscount-@TotalLineDiscountSrv) <> 0
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
					SET @CurrencyAmount = ROUND(@TotalDiscount-@TotalLineDiscountSrv,@PriceDecimalsToForms) / @CurrencyRate
				
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
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@DiscountAcntCode,ROUND(@TotalDiscount-@TotalLineDiscountSrv,@PriceDecimalsToForms),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			END
		end
			--------------------------------------------------------------------------------------------------------
		IF @inv_GoodsAcntGroupWithStoreID = 'True' 
		begin
		
			Declare	@DtlPriceGoodsAcntGroupID1  FLOAT
			Declare	@SaleAcntCode1  varchar(20)
		

			IF @SaleAcntCodeInSaleTypes = 'True'
				Declare	curSet CURSOR For 
				SELECT	s.StoreID,[acc].[funMerg_AcntCode]([acc].[funMergAcntCode](st.SaleAcntCode,ss.SaleAcntCode),P2AcntCode,P3AcntCode,P4AcntCode) SaleAcntCode1,ROUND(SUM(s.GoodsPrice * GoodsQuantity),@PriceDecimalsToForms)
				FROM inv.tblStorageDocsDtl s
				INNER JOIN inv.tblStores ss ON s.StoreID=ss.StoreID
				left JOIN inv.tblGoods g
				ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
				LEFT JOIN inv.tblGoodsAcntGroup a on a.GoodsAcntGroupID=g.GoodsAcntGroupID
				LEFT JOIN sal.tblSaleTypes st ON st.SaleTypeID=s.SaleTypeID
				WHERE g.IsService='False' AND 
					  g.PartNumber=@UnitPart AND 
					  ProcessID  = @intSourceProcessID AND
					  ProcessNo  = @intSourceProcessNo AND
					  FiscalYear = @intSourceFiscalYear AND
					  SerialNo   = @intSourceSerialNo
				group by s.StoreID,[acc].[funMerg_AcntCode]([acc].[funMergAcntCode](st.SaleAcntCode,ss.SaleAcntCode),P2AcntCode,P3AcntCode,P4AcntCode)
			ELSE
				Declare	curSet CURSOR For 
				SELECT	s.StoreID,[acc].[funMerg_AcntCode](ss.SaleAcntCode,P2AcntCode,P3AcntCode,P4AcntCode) SaleAcntCode1,ROUND(SUM(s.GoodsPrice * GoodsQuantity),@PriceDecimalsToForms)
				FROM inv.tblStorageDocsDtl s
				INNER JOIN inv.tblStores ss ON s.StoreID=ss.StoreID
				left JOIN inv.tblGoods g
				ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
				LEFT JOIN inv.tblGoodsAcntGroup a on a.GoodsAcntGroupID=g.GoodsAcntGroupID
				WHERE g.IsService='False' AND 
					  g.PartNumber=@UnitPart AND 
					  ProcessID  = @intSourceProcessID AND
					  ProcessNo  = @intSourceProcessNo AND
					  FiscalYear = @intSourceFiscalYear AND
					  SerialNo   = @intSourceSerialNo
				group by s.StoreID,[acc].[funMerg_AcntCode](ss.SaleAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)

			----- فاکتور فروش سطر به سطر به حساب مشتری میرود
			Open  curSet; 
		
			Fetch NEXT From curSet Into @StoreID,@SaleAcntCode1,@DtlPriceGoodsAcntGroupID1
		
			While (@@Fetch_Status = 0)
				BEGIN

					IF @SaleAcntCode1=''
					BEGIN
						--کد فروش کالا خالي است 
						SET @strMsgText=TS.pub.funGetMessages(11047,@LanguageID)
						Raiserror (@strMsgText,16,1,@StoreID)
						Return
					END


					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPriceGoodsAcntGroupID1,@PriceDecimalsToForms) / @CurrencyRate
							
					IF [acc].[funIsCurrencyAcntCode] (@SaleAcntCode1) = 'True'
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@SaleAcntCode1,0,ROUND(@DtlPriceGoodsAcntGroupID1,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
								--select ROUND(@DtlPrice,0)
								
					Fetch NEXT From curSet Into @StoreID,@SaleAcntCode1,@DtlPriceGoodsAcntGroupID1
				END
					
			Close curSet;
			Deallocate curSet; 

			end

		--------------------------------------------------------------------------------------------------------
		ELSE IF @inv_GoodsAcntGroup = 'True' 
		begin
		
			Declare	@DtlPriceGoodsAcntGroupID  FLOAT
		
			Declare	curSet CURSOR For 

			SELECT	GoodsAcntGroupID,ROUND(SUM(s.GoodsPrice * GoodsQuantity),@PriceDecimalsToForms)
			FROM inv.tblStorageDocsDtl s
			left JOIN inv.tblGoods g
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
			WHERE g.IsService='False' AND 
				 -- s.IsReward='False' AND 
				  --s.IsReward0='False' AND 
				  g.PartNumber=@UnitPart AND 
				  ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo
			group by GoodsAcntGroupID
			----- فاکتور فروش سطر به سطر به حساب مشتری میرود
			Open  curSet; 
		
			Fetch NEXT From curSet Into @GoodsAcntCodeGroup,@DtlPriceGoodsAcntGroupID
		
			While (@@Fetch_Status = 0)
				BEGIN
					if  isnull(@GoodsAcntCodeGroup,'')=''
						set @SaleGoodsAcntGroup=@SaleAcntCode
					else

						SELECT	@SaleGoodsAcntGroup=isnull(AcntCode,'')
						FROM inv.tblGoodsAcntGroup 
						WHERE GoodsAcntGroupID = isnull(@GoodsAcntCodeGroup,'')


					set @GoodsAcntCodeGroup=isnull(@GoodsAcntCodeGroup,'')

					IF @SaleGoodsAcntGroup=''
						set @SaleGoodsAcntGroup=@SaleAcntCode
							

					if @AcntPartNumberBranchPartNo<>0	and  len(@SaleGoodsAcntGroup)>acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)
						set @SaleGoodsAcntGroup=substring (@SaleGoodsAcntGroup,1,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) -1)+
						substring (@AcntCode,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) ,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2))+
						substring (@SaleGoodsAcntGroup,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)+acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2),20)

					IF @SaleGoodsAcntGroup IS NULL OR LTRIM(RTRIM(@SaleGoodsAcntGroup))=''
					BEGIN
						--کد فروش کالا خالي است 
						SET @strMsgText='کد فروش در تعریف رده کالا %s خالی است و یا رده کالا وجود ندارد'
						Raiserror (@strMsgText,16,1,@GoodsAcntCodeGroup)
						Return
					END

					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPriceGoodsAcntGroupID,@PriceDecimalsToForms) / @CurrencyRate
							
					IF [acc].[funIsCurrencyAcntCode] (@SaleGoodsAcntGroup) = 'True'
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@SaleGoodsAcntGroup,0,ROUND(@DtlPriceGoodsAcntGroupID,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
								--select ROUND(@DtlPrice,0)
								
					Fetch NEXT From curSet Into @GoodsAcntCodeGroup,@DtlPriceGoodsAcntGroupID
				END
					
			Close curSet;
			Deallocate curSet; 

			end

		--------------------------------------------------------------------------------------------------------
		else IF @Sal_StoreDtl = 'True'
		BEGIN			
			Declare	@DtlPrice  FLOAT
			
			Declare	curSet CURSOR For 
			SELECT	StoreID,CASE WHEN @Sal_SaleProcessForTaxTollSender='False' THEN ROUND(SUM(s.GoodsPrice * GoodsQuantity),@PriceDecimalsToForms) ELSE SUM(floor(Cast(s.GoodsPrice as decimal(30,10 )) * GoodsQuantity)) END
			FROM inv.tblStorageDocsDtl s
			left JOIN inv.tblGoods g
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
			WHERE g.IsService='False' AND 
				  s.IsReward='False' AND 
				  s.IsReward0='False' AND 
				  g.PartNumber=@UnitPart AND 
				  ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo
			group by StoreID
			----- فاکتور فروش سطر به سطر به حساب مشتری میرود
			Open  curSet; 
		
			Fetch NEXT From curSet Into @StoreID,@DtlPrice
		
			While (@@Fetch_Status = 0)
				BEGIN
	
				IF @SaleAcntCodeInSaleTypes = 'False'
					SELECT	@SaleAcntCode=SaleAcntCode
					FROM inv.tblStores 
					WHERE StoreID = @StoreID
					
					IF @SaleAcntCode=''
					BEGIN
						--کد فروش کالا خالي است 
						SET @strMsgText=TS.pub.funGetMessages(11047,@LanguageID)
						Raiserror (@strMsgText,16,1,@StoreID)
						Return
					END
					
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPrice,@PriceDecimalsToForms) / @CurrencyRate
							
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@SaleAcntCode,0,ROUND(@DtlPrice,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
								--select ROUND(@DtlPrice,0)
					Fetch NEXT From curSet Into @StoreID,@DtlPrice
				END
					
			Close curSet;
			Deallocate curSet; 
			END
		ELSE
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@SumGoodsPrice,@PriceDecimalsToForms) / @CurrencyRate
						
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
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@SaleAcntCode,0,ROUND(@SumGoodsPrice,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
						--	select ROUND(@SumGoodsPrice,0) 
			END	

		--------------------------------------------------------------------------------------------------------
		DECLARE @CostCenterAcntCode			VARCHAR(30)
		DECLARE @SaleReturnAcntCodeSrv		VARCHAR(30)
		DECLARE @VisitorCostAcntCodeSrv		VARCHAR(30)
		DECLARE @SaleDiscountAcntCodeSrv	VARCHAR(30)
		DECLARE @VisitorCostSrv				Float
		DECLARE @VisitorCostSrvAll			Float
	
		Set @VisitorCostSrvAll=0
		
if 1=1  --@CostCenterAcntCode
begin
		--------------------------------------------------------------------------------------------------------
					
	SELECT	g.CostCenterAcntCode,s.GoodsPrice,SubUnitQuantity,DescDtl,pub.funGetGoodsName(s.GoodsID,@LanguageID) AS GoodsName
		,SubUnitID,SubUnitID3, Height, Width, SubUnitQuantity3, GoodsAmount3,ServiceAmount
		into #tblcurService
		FROM inv.tblStorageDocsDtl s
		left JOIN inv.tblGoods g
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE 1=0
		
		declare @Sal_TotalSaleService as bit						
		select @Sal_TotalSaleService=SettingValue from pub.tblSettings where SettingKey='Sal_TotalSaleService'

		set @Sal_TotalSaleService=isnull(@Sal_TotalSaleService,'False')

		declare @Sal_TotalCreditSaleService as bit						
		select @Sal_TotalCreditSaleService=SettingValue from pub.tblSettings where SettingKey='Sal_TotalCreditSaleService'
		set @Sal_TotalCreditSaleService=isnull(@Sal_TotalCreditSaleService,'False')
	
	
if @Sal_TotalCreditSaleService='True'

insert into #tblcurService
		SELECT	g.CostCenterAcntCode,sum(s.GoodsPrice*SubUnitQuantity)/sum(SubUnitQuantity),sum(SubUnitQuantity),'' DescDtl, '' AS GoodsName
		,'' SubUnitID,'' SubUnitID3,0 Height,0 Width,0 SubUnitQuantity3,0 GoodsAmount3,0 ServiceAmount
		FROM inv.tblStorageDocsDtl s
		left JOIN inv.tblGoods g
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService = 'True' AND 
		      g.PartNumber=@UnitPart AND 
			  ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo
			  group by g.CostCenterAcntCode

ELSE if @Sal_TotalSaleService='True'

insert into #tblcurService
		SELECT	g.CostCenterAcntCode,sum(s.GoodsPrice*SubUnitQuantity)/sum(SubUnitQuantity),sum(SubUnitQuantity),'' DescDtl,pub.funGetGoodsName(s.GoodsID,@LanguageID) AS GoodsName
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
			  group by g.CostCenterAcntCode, s.GoodsID
		,SubUnitID,SubUnitID3, Height, Width, SubUnitQuantity3, GoodsAmount3,ServiceAmount

else	

	insert into #tblcurService
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


		Declare	curService CURSOR For 	
			select * from #tblcurService

			Open  curService; 
		
			Fetch NEXT From curService Into @CostCenterAcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount
		
			While (@@Fetch_Status = 0)
				BEGIN
					IF @GoodsPrice <> 0
						BEGIN
							if @GoodsName = ''
								SET @strRecDesc2 = ' فروش ' + @strTitleSale + @strFiscalSerial + ' - خدمات ' 
							ELSE
								SET @strRecDesc2 = ' فروش ' + @strTitleSale + @strFiscalSerial + ' - خدمات ' + @GoodsName + ' - ' + ltrim(rtrim(str(@GoodsQuantity,LEN(@GoodsQuantity),3)))  + ' - فی ' + ltrim(rtrim(str(@GoodsPrice))) + @strAcntName
									
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1
							if @SubUnitID=@SubUnitID3
								SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,@PriceDecimalsToForms) +ROUND( @ServiceAmount * @GoodsQuantity,@PriceDecimalsToForms)
							else
								SET @Amount = ROUND(@GoodsPrice * @GoodsQuantity,@PriceDecimalsToForms) +ROUND( @ServiceAmount * @SubUnitQuantity3*@Height*@Width,@PriceDecimalsToForms)
						
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
						IF @CostCenterAcntCode=''
							BEGIN
								--کد فروش کالا خالي است 
								SET @strMsgText=' کد حسابداری خدمات خالی است ' + ' کالای ' + @GoodsName
								Raiserror (@strMsgText,16,1,@StoreID)
								Close curService;
								Deallocate curService; 
								Return
							END				
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									 @CostCenterAcntCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
						END
		
					Fetch NEXT From curService Into @CostCenterAcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @GoodsAmount3,@ServiceAmount
				END
		
			Close curService;
			Deallocate curService; 
		--------------------------------------------------------------------------------------------------------
end

if 2=2--@SaleDiscountAcntCodeSrv
begin
		--------------------------------------------------------------------------------------------------------
 			
	SELECT	g.SaleDiscountAcntCode,s.DiscountDtl
		into #tblcurServiceDiscount
		FROM inv.tblStorageDocsDtl s
		left JOIN inv.tblGoods g
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE 1=0
	
	if @Sal_TotalCreditSaleService='True'

	insert into #tblcurServiceDiscount
		SELECT	g.SaleDiscountAcntCode,sum(DiscountDtl)
		FROM inv.tblStorageDocsDtl s
		left JOIN inv.tblGoods g
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService = 'True' AND 
		      g.PartNumber=@UnitPart AND 
			  ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo And 
			  g.SaleDiscountAcntCode<>''
			  group by g.SaleDiscountAcntCode

	ELSE if @Sal_TotalSaleService='True'

	insert into #tblcurServiceDiscount
		SELECT	g.SaleDiscountAcntCode,sum(DiscountDtl)
		FROM inv.tblStorageDocsDtl s
		left JOIN inv.tblGoods g
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService = 'True' AND 
		      g.PartNumber=@UnitPart AND 
			  ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo And 
			  g.SaleDiscountAcntCode<>''
			  group by g.SaleDiscountAcntCode, s.GoodsID

	else	

	insert into #tblcurServiceDiscount
	 	SELECT	g.SaleDiscountAcntCode,s.DiscountDtl
		FROM inv.tblStorageDocsDtl s
		left JOIN inv.tblGoods g
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService = 'True' AND 
		      g.PartNumber=@UnitPart AND 
			  ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo  And 
			  g.SaleDiscountAcntCode<>'' 

		Declare	curServiceDiscount CURSOR For 	
			select * from #tblcurServiceDiscount

			Open  curServiceDiscount; 
		
			Fetch NEXT From curServiceDiscount Into @SaleDiscountAcntCodeSrv ,@DiscountDtl
		
			While (@@Fetch_Status = 0)
				BEGIN
					IF @DiscountDtl <> 0
					BEGIN							

						SET @strRecDesc2 = ' تخفیف فروش ' + @strTitleSale + @strFiscalSerial 

							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							IF @CurrencyRate <> 0 	
								SET @CurrencyAmount = @DiscountDtl / @CurrencyRate
							
							IF [acc].[funIsCurrencyAcntCode] (@SaleDiscountAcntCodeSrv) = 'True'
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

						IF @SaleDiscountAcntCodeSrv=''
							BEGIN
								--کد فروش کالا خالي است 
								SET @strMsgText=' کد حسابداری تخفیف خدمات خالی است ' + ' کالای ' + @GoodsName
								Raiserror (@strMsgText,16,1,@StoreID)
								Close curServiceDiscount;
								Deallocate curServiceDiscount; 
								Return
							END				
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									 @SaleDiscountAcntCodeSrv,@DiscountDtl,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
						END
		
								Fetch NEXT From curServiceDiscount Into @SaleDiscountAcntCodeSrv ,@DiscountDtl

				END
		
			Close curServiceDiscount;
			Deallocate curServiceDiscount; 
		--------------------------------------------------------------------------------------------------------
end

if 3=3--@VisitorCostAcntCodeSrv
begin
		------------------------------------------------------------------------------------------------------
					
	SELECT	g.VisitorCostAcntCode,s.DiscountDtl
		into #tblcurServiceVisitor
		FROM inv.tblStorageDocsDtl s
		left JOIN inv.tblGoods g
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE 1=0
	
	
	if @Sal_TotalCreditSaleService='True'

	insert into #tblcurServiceVisitor
		SELECT	g.VisitorCostAcntCode,ROUND(sum( VisitorCost*(GoodsQuantity*s.GoodsPrice-DiscountDtl) /Price ),0)
		FROM inv.tblStorageDocsDtl s
		inner join inv.tblStorageDocsHdr H on H.ProcessID=s.ProcessID AND H.ProcessNo=s.ProcessNo AND H.FiscalYear=s.FiscalYear AND H.SerialNo=s.SerialNo 
		left JOIN inv.tblGoods g ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService = 'True' AND 
		      g.PartNumber=@UnitPart AND 
			  s.ProcessID=@intSourceProcessID AND s.ProcessNo=@intSourceProcessNo AND s.FiscalYear=@intSourceFiscalYear AND s.SerialNo=@intSourceSerialNo And 
			  g.VisitorCostAcntCode<>'' And H.VisitorAcntCode<>''
			  group by g.VisitorCostAcntCode

	ELSE if @Sal_TotalSaleService='True'

	insert into #tblcurServiceVisitor
		SELECT	g.VisitorCostAcntCode,ROUND(sum( VisitorCost*(GoodsQuantity*s.GoodsPrice-DiscountDtl) /Price ),0)
		FROM inv.tblStorageDocsDtl s
		inner join inv.tblStorageDocsHdr H on H.ProcessID=s.ProcessID AND H.ProcessNo=s.ProcessNo AND H.FiscalYear=s.FiscalYear AND H.SerialNo=s.SerialNo 
		left JOIN inv.tblGoods g ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService = 'True' AND 
		      g.PartNumber=@UnitPart AND 
			  s.ProcessID=@intSourceProcessID AND s.ProcessNo=@intSourceProcessNo AND s.FiscalYear=@intSourceFiscalYear AND s.SerialNo=@intSourceSerialNo And 
			  g.VisitorCostAcntCode<>'' And H.VisitorAcntCode<>''
			  group by g.VisitorCostAcntCode, s.GoodsID

	else	

	insert into #tblcurServiceVisitor
	 	SELECT	g.VisitorCostAcntCode,ROUND( VisitorCost*(GoodsQuantity*s.GoodsPrice-DiscountDtl) /Price ,0)
		FROM inv.tblStorageDocsDtl s
		inner join inv.tblStorageDocsHdr H on H.ProcessID=s.ProcessID AND H.ProcessNo=s.ProcessNo AND H.FiscalYear=s.FiscalYear AND H.SerialNo=s.SerialNo 
		left JOIN inv.tblGoods g ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService = 'True' AND 
		      g.PartNumber=@UnitPart AND 
			  s.ProcessID=@intSourceProcessID AND s.ProcessNo=@intSourceProcessNo AND s.FiscalYear=@intSourceFiscalYear AND s.SerialNo=@intSourceSerialNo And 
			  g.VisitorCostAcntCode<>'' And H.VisitorAcntCode<>'' 
		Declare	curService CURSOR For 	
			select * from #tblcurServiceVisitor

			Open  curService; 
		
			Fetch NEXT From curService Into @VisitorCostAcntCodeSrv ,@VisitorCostSrv
		
			While (@@Fetch_Status = 0)
				BEGIN
					IF @VisitorCostSrv <> 0
						BEGIN
							Set @VisitorCostSrvAll=@VisitorCostSrvAll+@VisitorCostSrv	
							SET @strRecDesc2 = ' هزینه بازاریاب فروش  ' + @strTitleSale + @strFiscalSerial + ' - خدمات ' 
									
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							IF @CurrencyRate <> 0 	
								SET @CurrencyAmount = @VisitorCostSrv / @CurrencyRate
							
							IF [acc].[funIsCurrencyAcntCode] (@VisitorCostAcntCodeSrv) = 'True'
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
						IF @VisitorCostAcntCodeSrv=''
							BEGIN
								--کد فروش کالا خالي است 
								SET @strMsgText=' کد حسابداری ویزتور خدمات خالی است ' + ' کالای ' + @GoodsName
								Raiserror (@strMsgText,16,1,@StoreID)
								Close curService;
								Deallocate curService; 
								Return
							END				
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									 @VisitorCostAcntCodeSrv,@VisitorCostSrv,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
						END
		
					Fetch NEXT From curService Into @VisitorCostAcntCodeSrv ,@VisitorCostSrv
				END
		
			Close curService;
			Deallocate curService; 
		------------------------------------------------------------------------------------------------------
	end
	
	-------------------------------------------------هزینه حمل و نقل---------------------------------------
		IF @TransportationCostAcntCode <> '' AND (@TransportationCost <> 0 OR @CurrencyTransportationCostChange<>0)
			BEGIN
				DECLARE @strRecDescTransCost VARCHAR(1000) 
				
					--SET @strRecDescTransCost = ' هزینه حمل فروش ' + @strTitleSale + @strFiscalSerial
					SET @strRecDescTransCost = ' كرايه حمل فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

					--------------------------------------------------------------------------------------------------------
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
					BEGIN
						SET @CurrencyAmount = (ROUND(@TransportationCost,@PriceDecimalsToForms) / @CurrencyRate ) + @CurrencyTransportationCost - 
											  (ROUND(@TransportationIncome,@PriceDecimalsToForms) / @CurrencyRate ) + @CurrencyTransportationIncome
					END
				
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@TransportationCostAcntCode,ROUND(@TotalTransportationCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
								--------------------------------------------------------------------------------------------------------

				IF @ShowSaleTransportationInBill = 'True'  or @TotalSale2Account='False'
					BEGIN
						declare @TempTransportationCostAcntCode as varchar(20)
						SET @TempTransportationCostAcntCode=''
						select @TempTransportationCostAcntCode=LTRIM(RTRIM(SettingValue)) from pub.tblSettings where SettingKey='TransportationCostAcntCode'
						
						IF LTRIM(@TempTransportationCostAcntCode)<>'' and LEN(@AcntCode)>LEN(@TempTransportationCostAcntCode)
						BEGIN
							SET @AcntCode = @TempTransportationCostAcntCode + SUBSTRING(@AcntCode,LEN(@TempTransportationCostAcntCode)+1,20)
						END

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						IF @CurrencyRate <> 0 	
						BEGIN
							SET @CurrencyAmount = @CurrencyTransportationCost + ROUND(@TransportationCost,@PriceDecimalsToForms) / @CurrencyRate - 
												  @CurrencyTransportationIncome + ROUND(@TransportationIncome,@PriceDecimalsToForms) / @CurrencyRate 
						END
				
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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@AcntCode,0,ROUND(@TotalTransportationCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)
					END
			END

		-------------------------------------------------درآمد حمل و نقل---------------------------------------
		IF @TransportationIncomeAcntCode <> '' AND (@TransportationIncome <> 0 OR @CurrencyTransportationIncomeChange<>0)
			BEGIN
				DECLARE @strRecDescTrans VARCHAR(1000) 
				
				-- SET @strRecDescTrans = ' درآمد حمل فروش ' + @strTitleSale + @strFiscalSerial
				SET @strRecDescTrans = ' كرايه حمل فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

				--------------------------------------------------------------------------------------------------------
				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@TransportationIncome,@PriceDecimalsToForms) / @CurrencyRate + @CurrencyTransportationIncome
				
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
									
				IF @ShowSaleTransportationInBill = 'True' or @TotalSale2Account='False'
					BEGIN
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@AcntCode,ROUND(@TotalTransportationIncome,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
					END	
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@TransportationIncomeAcntCode,0,ROUND(@TotalTransportationIncome,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

			END

			------------------------------------------------هزینه بسته بندی------------------------------------
			IF @PackingAcntCode	<> '' AND @PackingCost <> 0
				BEGIN
					--------------------------------------------------------------------------------------------------------
				
					DECLARE @strRecDescPacking VARCHAR(1000) 
					SET @strRecDescPacking =' هزینه بسته بندی فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
				
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@PackingCost,@PriceDecimalsToForms) / @CurrencyRate
				
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,ROUND(@PackingCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescPacking)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
				
					--------------------------------------------------------------------------------------------------------
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@PackingAcntCode,0,ROUND(@PackingCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescPacking)),'',0,@CurrencyAmount)
					
				END

			-----------------------------------------------مالیات تجمیع عوارض--------------------------------------------
	IF @TaxAcntCode	<> '' AND @TaxCost <> 0
				BEGIN
					--------------------------------------------------------------------------------------------------------
					DECLARE @strRecDescTax VARCHAR(1000) 
					SET @strRecDescTax = ' مالیات تجمیع عوارض فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
					
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@TaxCost,@PriceDecimalsToForms) / @CurrencyRate
					
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,ROUND(@TaxCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTax)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,2,@VisitorAcntCode)
				
					--------------------------------------------------------------------------------------------------------
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@TaxAcntCode,0,ROUND(@TaxCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTax)),'',0,@CurrencyAmount,2,@VisitorAcntCode)
					
				END

	----------------------------------------------- بازاریاب --------------------------------------------
	IF @VisitorAcntCode	<> '' AND @VisitorCostAcntCode	<> '' AND (@VisitorCost <> 0 OR @VisitorCostInGoods <> 0)
		BEGIN
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
				
			IF @VisitorCost=0
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
			SET @strRecDescVisitor = ' هزینه بازاریاب فروش <<' + @strRecDescVisitor + '>>'+ @strTitleSale + @strFiscalSerial + @strAcntName
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@VisitorCost-@VisitorCostSrvAll,@PriceDecimalsToForms) / @CurrencyRate
			
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
			IF @VisitorCost-@VisitorCostSrvAll >0						
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorCostAcntCode,ROUND(@VisitorCost-@VisitorCostSrvAll,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			ELSE
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorCostAcntCode,0 ,ROUND(@VisitorCostSrvAll-@VisitorCost,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF [acc].[funIsCurrencyAcntCode] (@VisitorAcntCode) = 'True'
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@VisitorAcntCode,0,ROUND(@VisitorCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			
		END				
	----------------------------------------------- بازاریاب 2 --------------------------------------------
	IF @VisitorAcntCode2 <> '' AND @VisitorCostAcntCode2 <> '' AND @VisitorCost2 <> 0
		BEGIN
			IF @VisitorPercent2 > 0
				BEGIN
					IF @DiscountMinusFromVisitor = 1
						BEGIN	
							SET @VisitorCostTmp2 = (@SumGoodsPrice * @VisitorPercent2) / 100
						END
					ELSE
						BEGIN
							SET @VisitorCostTmp2 = ((@SumGoodsPrice - (@TotalDiscount )) * @VisitorPercent2) / 100
						END
				END
				
			IF @VisitorCostTmp2 > 0
				SET @VisitorCost2 = @VisitorCostTmp2

			----------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescVisitor2 VARCHAR(1000) 
			--Declare @NamePartNo AS Tinyint

			SET @NamePartNo = 1
			
			SELECT @NamePartNo = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

			SELECT @strRecDescVisitor2 = [acc].[funGetAcntName]([pub].[funSplitString](@AcntCode,' ' ,@NamePartNo),@NamePartNo,@LanguageID)
			SET @strRecDescVisitor2 = ' هزینه بازاریاب 2 فروش <<' + @strRecDescVisitor2 + '>>'+ @strTitleSale + @strFiscalSerial + @strAcntName
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@VisitorCost2,@PriceDecimalsToForms) / @CurrencyRate
			
			IF [acc].[funIsCurrencyAcntCode] (@VisitorCostAcntCode2) = 'True'
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@VisitorCostAcntCode2,ROUND(@VisitorCost2,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@VisitorAcntCode2,0,ROUND(@VisitorCost2,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor2)),'',0,@CurrencyAmount)
		END
		
	----------------------------------------------- توزیع کننده --------------------------------------------
	IF @DistributeAcntCode	<> '' AND @DistributeCostAcntCode	<> '' AND @DistributeAmount <> 0
		
		BEGIN

			IF @DistributePercent >0
					SET @DistributeAmount = (@SumGoodsPrice * @DistributePercent) / 100

			----------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescDistribute VARCHAR(1000) 
			SET @strRecDescDistribute = ' توزیع کننده فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@DistributeAmount,@PriceDecimalsToForms) / @CurrencyRate
			
			IF [acc].[funIsCurrencyAcntCode] (@DistributeCostAcntCode) = 'True'
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@DistributeCostAcntCode,ROUND(@DistributeAmount,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescDistribute)),'',0,@CurrencyAmountTmp)
						
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@DistributeAcntCode,0,ROUND(@DistributeAmount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescDistribute)),'',0,@CurrencyAmount)

		END
				
			----------------------------------------------- پیش دریافت --------------------------------------------
	IF @EarnestMoneyAcntCode <> '' AND @EarnestMoney <> 0
		BEGIN

			DECLARE @strRecDescEarnestMoney VARCHAR(1000) 
			SET @strRecDescEarnestMoney = ' پیش دریافت فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@EarnestMoney,@PriceDecimalsToForms) / @CurrencyRate
			
			IF [acc].[funIsCurrencyAcntCode] (@EarnestMoneyAcntCode) = 'True'
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@EarnestMoneyAcntCode,ROUND(@EarnestMoney,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescEarnestMoney)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

		END

			-----------------------------------------------مالیات بر ارزش افزوده--------------------------------------------
	Declare @SaleOrderVoucherTax as bit
	set @SaleOrderVoucherTax ='False'
	IF @BaseProcessID =180 
		if (SELECT count(*) FROM acc.tblVoucherDtl
			    WHERE SourceProcessID = @BaseProcessID AND  SourceProcessNo = @BaseProcessNo AND 
				      SourceFiscalYear= @BaseFiscalYear AND SourceSerialNo  = @BaseSerialNo AND 
					  AcntCode = @SaleTaxOverWorthAcntCode)>0					   
			set @SaleOrderVoucherTax='True'

		IF @SaleTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0 and @SaleOrderVoucherTax ='False'
		BEGIN
			--------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescTaxOverWorth VARCHAR(1000) 
			if @TollOverWorthPercentInSale = 0 AND @TollOverWorthCost=0
				SET @strRecDescTaxOverWorth = ' مالیات و عوارض بر ارزش افزوده فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
			ELSE
				SET @strRecDescTaxOverWorth = ' مالیات بر ارزش افزوده فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@TaxOverWorthCost,@PriceDecimalsToForms) / @CurrencyRate
			
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
			BEGIN
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,ROUND(@TaxOverWorthCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,2,@VisitorAcntCode)
			END
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 					SELECT @SaleTaxOverWorthAcntCode = [pub].[funMergCode](@SaleTaxOverWorthAcntCode,@AcntCode)

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@SaleTaxOverWorthAcntCode,0,ROUND(@TaxOverWorthCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0,@CurrencyAmount,@CurrencyTypeID,2,@VisitorAcntCode)
			
		END

		----------------------------------------------عوارض بر ارزش افزوده--------------------------------------------
		IF @SaleTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0  and @SaleOrderVoucherTax ='False'
			BEGIN
				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescTollOverWorth VARCHAR(1000) 
				SET @strRecDescTollOverWorth = ' عوارض بر ارزش افزوده فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@TollOverWorthCost,@PriceDecimalsToForms) / @CurrencyRate
				
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
				Begin
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,ROUND(@TollOverWorthCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,3,@VisitorAcntCode)
				End
			
					--------------------------------------------------------------------------------------------------------
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 					SELECT @SaleTollOverWorthAcntCode = [pub].[funMergCode](@SaleTollOverWorthAcntCode,@AcntCode)

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@SaleTollOverWorthAcntCode,0,ROUND(@TollOverWorthCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0,@CurrencyAmount,3,@VisitorAcntCode)
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
				SET @CurrencyAmount = ROUND(@FixCost,@PriceDecimalsToForms) / @CurrencyRate
				
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @FixCostAcntCode,ROUND(@FixCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescFixCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,0,ROUND(@FixCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescFixCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

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
				SET @CurrencyAmount = ROUND(@OtherCost,@PriceDecimalsToForms) / @CurrencyRate
				
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@OtherCostAcntCode,ROUND(@OtherCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,0,ROUND(@OtherCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

		END

	-------------------------------------------------'سایر درآمد ها در فروش---------------------------------------
	IF @OtherIncomeAcntCode <> '' AND @OtherIncome <> 0
		BEGIN
			DECLARE @strRecDescIncome VARCHAR(1000) 
			
			--SET @strRecDescIncome = 'سایر درآمد ها در فروش ' + @strTitleSale + @strFiscalSerial
			SET @strRecDescIncome = 'سایر اضافات در فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

			--------------------------------------------------------------------------------------------------------


			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@OtherIncome,@PriceDecimalsToForms) / @CurrencyRate
			
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


			IF @AllowOtherIncomeInDtl ='False'
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,ROUND(@OtherIncome,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),pub.funReverseForCrystal(@DescHdr),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			END
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@OtherIncomeAcntCode,0,ROUND(@OtherIncome,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

		END

		-----
	IF @ComssionCostPriceAcntCode <> '' AND @ComssionCostPrice <> 0
		BEGIN

			DECLARE @strRecDescComssionCost VARCHAR(1000) 
			SET @strRecDescComssionCost = ' حق العمل كاري فروش ' + @strTitleSale + ' شماره' + @strFiscalSerial + @strAcntName
			 
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0
				SET @CurrencyAmount = ROUND(@ComssionCostPrice,@PriceDecimalsToForms) / @CurrencyRate
			
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
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,ROUND(@ComssionCostPrice,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescComssionCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @ComssionCostPriceAcntCode,0,ROUND(@ComssionCostPrice,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescComssionCost)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

		END		
		-----
	IF @BasculePriceAcntCode <> '' AND @BasculePrice <> 0
		BEGIN

			DECLARE @strRecDescBasculePrice VARCHAR(1000) 
			SET @strRecDescBasculePrice = ' هزينه باسكول فروش ' + @strTitleSale + ' شماره' + @strFiscalSerial + @strAcntName
			 
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0
				SET @CurrencyAmount = ROUND(@BasculePrice,@PriceDecimalsToForms) / @CurrencyRate
			
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
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,ROUND(@BasculePrice,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescBasculePrice)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @BasculePriceAcntCode,0,ROUND(@BasculePrice,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescBasculePrice)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

		END	
		-----
	IF @LaborPriceAcntCode <> '' AND @LaborPrice <> 0
		BEGIN

			DECLARE @strRecDescLaborPrice VARCHAR(1000) 
			SET @strRecDescLaborPrice = ' هزينه كارگر فروش ' + @strTitleSale + ' شماره' + @strFiscalSerial + @strAcntName
			 
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0
				SET @CurrencyAmount = ROUND(@LaborPrice,@PriceDecimalsToForms) / @CurrencyRate
			
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
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,ROUND(@LaborPrice,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescLaborPrice)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @LaborPriceAcntCode,0,ROUND(@LaborPrice,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescLaborPrice)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

		END	
		-----
	IF @TransportPriceAcntCode <> '' AND @TransportPrice <> 0
		BEGIN

			DECLARE @strRecDescTransportPrice VARCHAR(1000) 
			SET @strRecDescTransportPrice = ' هزينه حمل فروش ' + @strTitleSale + ' شماره' + @strFiscalSerial + @strAcntName
			 
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0
				SET @CurrencyAmount = ROUND(@TransportPrice,@PriceDecimalsToForms) / @CurrencyRate
			
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
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,ROUND(@TransportPrice,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransportPrice)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @TransportPriceAcntCode,0,ROUND(@TransportPrice,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransportPrice)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

		END	
			
		----- عوارض حساب رابط
	IF @IATollCod <> '' AND @IAToll <> 0
		BEGIN

			DECLARE @strIAToll VARCHAR(1000) 
			SET @strIAToll = ' عوارض حساب رابط ' + @strTitleSale + ' شماره' + @strFiscalSerial
			 
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0
				SET @CurrencyAmount = ROUND(@IAToll,@PriceDecimalsToForms) / @CurrencyRate
			
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
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,ROUND(@IAToll,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strIAToll)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @IATollCod,0,ROUND(@IAToll,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strIAToll)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

		END					
	----- هزینه تبلیغات
	IF @AdvertisingCostAcntCode <> '' AND @AdvertisingReserveAcntCode <>'' AND @AdvertisingPercent <> 0 AND @AmountHdr>0
		BEGIN


			SELECT @AdvertisingReserveAcntCode = RTRIM(@AdvertisingReserveAcntCode) + SUBSTRING(@AcntCode,LEN(@AdvertisingReserveAcntCode)+1,20)

			DECLARE @strAdvertising VARCHAR(1000) 
			SET @strAdvertising = ' هزینه تبلیغات  در فروش' + @strTitleSale + ' شماره' + @strFiscalSerial
			 
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0
				SET @CurrencyAmount = ROUND((@AmountHdr*@AdvertisingPercent/100),@PriceDecimalsToForms) / @CurrencyRate
			
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
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @AdvertisingCostAcntCode,ROUND((@AmountHdr*@AdvertisingPercent/100),@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strAdvertising)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @AdvertisingReserveAcntCode,0,ROUND((@AmountHdr*@AdvertisingPercent/100),@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strAdvertising)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

		END					
	END
	
	IF @TotalSale2Account = 1
		exec 	acc.SpBalanceVoucher @intVchNo,@SaleAcntCode ,@intSourceProcessID,	@intSourceProcessNo,	@intSourceFiscalYear,	@intSourceSerialNo	
	ELSE
		exec 	acc.SpBalanceVoucher @intVchNo,@AcntCode ,@intSourceProcessID,	@intSourceProcessNo,	@intSourceFiscalYear,	@intSourceSerialNo	

END
GO
