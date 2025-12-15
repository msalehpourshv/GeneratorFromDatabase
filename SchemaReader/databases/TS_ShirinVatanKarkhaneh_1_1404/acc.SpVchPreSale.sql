USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/04/31
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [acc].[SpVchPreSale]
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
	Declare @strMsgText					NVarChar(2044)
	Declare @strTitleSale		    	NVarChar(1000)
	Declare @DescHdr					NVarChar(4000)
	Declare @DescDtl					NVarChar(1000)
	Declare @strRecDesc					NVarChar(1000)
	Declare @strFiscalSerial			VarChar(50)
	Declare @AcntCode					Varchar(20)
	Declare @EarnestMoneyAcntCode		Varchar(20)
	Declare @EarnestMoney			Float
	Declare @EarnestMoneyPercent	Float
	Declare @SumGoodsPrice			Float
	Declare @TaxOverWorthCost		Float
	Declare @TollOverWorthCost		Float
	Declare @SaleTaxOverWorthAcntCode Varchar(20)
	Declare @SaleTollOverWorthAcntCode Varchar(20)
	Declare @StoreID Varchar(20)
	Declare @Discount				Float
	Declare @DocDesc				NVarChar(4000)
	DECLARE @SaleOrderAcntCode VARCHAR(20)
	DECLARE @PriceDecimalsToForms		tinyint
	DECLARE @UsedPriceDecimalsToFormsInVch BIT
	Declare @PackingAcntCode		Varchar(20)
	Declare @PackingCost			Float
	Declare @CurrencyAmount			Float
	Declare @Sal_TaxAcntCompletWithCustCode bit

	declare @Sal_PresaleVoucher BIT
	SET @Sal_PresaleVoucher='False'
	select @Sal_PresaleVoucher=SettingValue from pub.tblSettings where SettingKey='Sal_PresaleVoucher'
	
	SET @PriceDecimalsToForms = 0
	SET @UsedPriceDecimalsToFormsInVch='False'
	select @UsedPriceDecimalsToFormsInVch=SettingValue from pub.tblSettings where SettingKey='UsedPriceDecimalsToFormsInVch'
	select @Sal_TaxAcntCompletWithCustCode=SettingValue from pub.tblSettings where SettingKey='Sal_TaxAcntCompletWithCustCode'

	IF @UsedPriceDecimalsToFormsInVch='True'
		SELECT @PriceDecimalsToForms=SettingValue from pub.tblSettings where SettingKey='PriceDecimalsToForms'

	SET @CurrencyAmount = 0

	IF @Sal_PresaleVoucher ='True'
	 BEGIN
		-----
		Declare @DescDistribution			NVarChar(1000)
		Declare @strRecDesc2				NVarChar(1000)
		Declare @GoodsName					NVarChar(1000)
		Declare @GoodsMainUnit				NVarChar(1000)
		Declare @GoodsUnit					NVarChar(1000)
		Declare @SaleTypeText				NVarChar(1000)
		Declare @AdvertisingPercent			float
		Declare @AdvertisingCostAcntCode	Varchar(20)
		Declare @AdvertisingReserveAcntCode Varchar(20)
		Declare @SaleAcntCode				Varchar(20)
		Declare @SaleTypeID					Varchar(20)
		Declare @AtomAcntCode				Varchar(20)
		Declare @VisitorAcntCode			Varchar(20)
		Declare @VisitorCostAcntCode		Varchar(20)
		Declare @VisitorAcntCode2			Varchar(20)
		Declare @VisitorCostAcntCode2		Varchar(20)
		Declare @OtherCostAcntCode			Varchar(20)
		Declare @OtherIncomeAcntCode		Varchar(20)
		Declare @SettlementDate				Varchar(50)

		Declare @DiscountAcntCode			Varchar(20)
		Declare @AfterSaleDiscountAcntCode  Varchar(20)
		Declare @TaxAcntCode				Varchar(20)
		Declare @TransportationCostAcntCode	Varchar(20)
		Declare @TransportationIncomeAcntCode Varchar(20)
		Declare @CurrencyTypeID			VarChar(20)
		Declare @GoodsID				VarChar(20)	
		DECLARE @StrQuantity			VarChar(30)
		Declare @SubUnitID				VarChar(20)
		Declare @SubUnitID3				VarChar(20)
		Declare @Height					Float
		Declare @Width					Float
		Declare @SubUnitQuantity3		Float
		Declare @ServiceAmount			Float
		Declare @Amount					Float
		Declare @GoodsPrice				Float
		Declare @SubUnitPrice			Float
		Declare @SubUnitPrice2			Float
		Declare @GoodsQuantity			Float
		Declare @SubUnitQuantity		Float
		Declare @Discount2				FLOAT
		Declare @CurrencyDiscount		FLOAT
		Declare @TotalLineDiscount		Float
		Declare @TransportationCost		Float
		Declare @TransportationIncome	Float
		Declare @TaxCost				Float
		Declare @VisitorPercent			Float
		Declare @VisitorCost			Float
		Declare @VisitorPercent2		Float
		Declare @VisitorCost2			Float
		Declare @VisitorCostInGoods		Float
		Declare @DistributePercent		Float
		Declare @DistributeAmount		Float
		Declare @ConstTextSumGoodsPrice	Float
		Declare @SumServicePrice		Float
		Declare @SumGoodsPriceWithTax	Float
		Declare @VisitorCostTmp			Float
		Declare @VisitorCostTmp2		Float
		Declare @OtherCost				Float
		Declare @OtherIncome			Float
		Declare @CurrencyRate			Float
		Declare @decPrice				varchar(30)
		Declare @CurrencyTransportationCost		FLOAT
		Declare @CurrencyTransportationIncome	FLOAT

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
		declare @inv_GoodsAcntGroup			BIT
		Declare @GoodsAcntCodeGroup	    	Varchar(20)
		Declare @SaleGoodsAcntGroup			Varchar(20)
		declare @AcntPartNumberBranchPartNo Integer		

		SET @AcntPartNumberBranchPartNo=0
		SET @inv_GoodsAcntGroup = 'False'

		select @Sal_StoreVariable1=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariable1'
		select @Sal_StoreVariable2=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariable2'
		select @Sal_StoreVariable3=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariable3'
		select @Sal_StoreVariable4=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariable4'
		select @Sal_StoreVariableAddVch1=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariableAddVch1'
		select @Sal_StoreVariableAddVch2=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariableAddVch2'
		select @Sal_StoreVariableAddVch3=SettingValue from pub.tblSettings where SettingKey='Sal_StoreVariableAddVch3'
		select @AcntPartNumberBranchPartNo=SettingValue from pub.tblSettings where SettingKey='AcntPartNumberBranchPartNo'
		SELECT @inv_GoodsAcntGroup = SettingValue FROM pub.tblSettings WHERE UPPER(SettingKey) = UPPER('inv_GoodsAcntGroup')


		-----
		SET	@Discount = 0
		SET @Discount2 = 0	
		SET @CurrencyDiscount = 0
		SET @CurrencyTransportationCost = 0
		SET @CurrencyTransportationIncome = 0
		SET @TotalLineDiscount = 0
		SET @TotalSale2Account = 0				
		SET @ShowSaleDiscountInBill = 1			
		SET @VisitorCostTmp = 0
		SET @VisitorCostInGoods = 0
		SET @VisitorCostTmp2 = 0
		SET @SaleAcntCode = ''

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
		DECLARE @UnitPart TINYINT
		SET @UnitPart  = 1

		SET @CurrencyRateTmp = 0
		SET @CurrencyAmountTmp = 0
		SET @CurrencyTypeIDTmp = ''

		SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

		SELECT @buy_AddConstText1ToGoodsPrice = SettingValue FROM pub.tblSettings WHERE SettingKey = 'buy_AddConstText1ToGoodsPrice' 
		SELECT @buy_AddConstText2ToGoodsPrice = SettingValue FROM pub.tblSettings WHERE SettingKey = 'buy_AddConstText2ToGoodsPrice' 
		SELECT @buy_AddConstText3ToGoodsPrice = SettingValue FROM pub.tblSettings WHERE SettingKey = 'buy_AddConstText3ToGoodsPrice' 
		SELECT @buy_AddConstText4ToGoodsPrice = SettingValue FROM pub.tblSettings WHERE SettingKey = 'buy_AddConstText4ToGoodsPrice' 

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

		-- ===========================
		Select @SaleTypeID = SaleTypeID
		From inv.tblPreSaleHdr
		Where ProcessID = @intSourceProcessID And ProcessNo = @intSourceProcessNo And
			  FiscalYear = @intSourceFiscalYear And SerialNo = @intSourceSerialNo
			  
		Select @GetAcntCodeFromStore = GetAcntCodeFromStore 
		From sal.tblSaleTypes 
		Where SaleTypeID = @SaleTypeID

		If  @GetAcntCodeFromStore = 1 
			Set @SaleAcntCodeInSaleTypes = 'False'
		-- ===========================

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
			SELECT	@StoreID=StoreID,@AcntCode=AcntCode,@Discount=Discount,@Discount2=Discount2,
					@CurrencyDiscount=(CurrencyDiscount * CurrencyRate),
					@CurrencyTransportationCost = (CurrencyTransportationCost * CurrencyRate),
					@CurrencyTransportationIncome = (CurrencyTransportationIncome * CurrencyRate),
					@TransportationCost=TransportationCost,@TransportationIncome=TransportationIncome,
					@PackingCost=PackingCost,@TaxCost=TaxCost,@VisitorAcntCode=VisitorAcntCode,
					@VisitorPercent=VisitorPercent,@VisitorCost=VisitorCost,@VisitorAcntCode2=VisitorAcntCode2,
					@VisitorPercent2=VisitorPercent2,@VisitorCost2=VisitorCost2,@CurrencyRate=CurrencyRate,
					@EarnestMoney=EarnestMoney,@EarnestMoneyPercent=EarnestMoneyPercent,@EarnestMoneyAcntCode=EarnestMoneyAcntCode,
					@TransportationCostAcntCode=TransportationCostAcntCode,@TransportationIncomeAcntCode=TransportationIncomeAcntCode,
					@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost,@SaleTypeID=SaleTypeID, 
					@OtherCostAcntCode=OtherCostAcntCode,@OtherIncomeAcntCode=OtherIncomeAcntCode,@OtherCost=OtherCost,@OtherIncome=OtherIncome,@DescHdr= DocDesc,
					@SettlementDate=SettlementDate,@CurrencyTypeID=CurrencyTypeID
			FROM inv.tblPreSaleHdr
			WHERE ProcessID=@intSourceProcessID AND
				  ProcessNo=@intSourceProcessNo AND
				  FiscalYear=@intSourceFiscalYear AND
				  SerialNo=@intSourceSerialNo 

			IF @SalAcntNameInVoucherDesc = 'True'
				Select @strAcntName = ' به ' + [pub].GetCodeName(@AcntCode, @LanguageID)
			ELSE
				SET @strAcntName = ''

		--------------------------------------------------------------------------------------------------------
			
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
		--			IF @HasDST = 'False' 
					
				SELECT	@SumGoodsPrice  = SUM(Case When  SubUnitID=SubUnitID3  then  ROUND((s.GoodsAmount +(
					 Case When IsNumeric(s.ConstText1) = 1 AND @buy_AddConstText1ToGoodsPrice = 'True' Then s.ConstText1 Else 0 End +
					 Case When IsNumeric(s.ConstText2) = 1 AND @buy_AddConstText2ToGoodsPrice = 'True'  Then s.ConstText2 Else 0 End + 
					 Case When IsNumeric(s.ConstText3) = 1 AND @buy_AddConstText3ToGoodsPrice = 'True'  Then s.ConstText3 Else 0 End + 
					Case When IsNumeric(s.ConstText4) = 1 AND @buy_AddConstText4ToGoodsPrice = 'True'  Then s.ConstText4 Else 0 End)) * GoodsQuantity,@PriceDecimalsToForms) 
				+ROUND( ServiceAmount * GoodsQuantity,@PriceDecimalsToForms) else
				(s.GoodsAmount +(
					 Case When IsNumeric(s.ConstText1) = 1 AND @buy_AddConstText1ToGoodsPrice = 'True' Then s.ConstText1 Else 0 End +
					 Case When IsNumeric(s.ConstText2) = 1 AND @buy_AddConstText2ToGoodsPrice = 'True'  Then s.ConstText2 Else 0 End + 
					 Case When IsNumeric(s.ConstText3) = 1 AND @buy_AddConstText3ToGoodsPrice = 'True'  Then s.ConstText3 Else 0 End + 
					Case When IsNumeric(s.ConstText4) = 1 AND @buy_AddConstText4ToGoodsPrice = 'True'  Then s.ConstText4 Else 0 End))* GoodsQuantity
					 + ROUND(ServiceAmount * SubUnitQuantity3 * Height,0)
				end	), @TotalLineDiscount=ROUND(isnull(SUM(Discount),0),@PriceDecimalsToForms)
				FROM inv.tblPreSaleDtl s
				Left JOIN inv.tblGoods g
				ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
				WHERE g.IsService='False' AND 
					  g.PartNumber=@UnitPart AND 
					  ProcessID  = @intSourceProcessID AND
					  ProcessNo  = @intSourceProcessNo AND
					  FiscalYear = @intSourceFiscalYear AND
					  SerialNo   = @intSourceSerialNo 

				SELECT	@SumServicePrice  = ROUND(SUM(s.GoodsAmount *GoodsQuantity),@PriceDecimalsToForms), @TotalLineDiscount=@TotalLineDiscount + isnull(ROUND(SUM(Discount),@PriceDecimalsToForms),0)
				FROM inv.tblPreSaleDtl s
				Left JOIN inv.tblGoods g
				ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
				WHERE g.IsService='True' AND 
					  g.PartNumber=@UnitPart AND 
					  ProcessID  = @intSourceProcessID AND
					  ProcessNo  = @intSourceProcessNo AND
					  FiscalYear = @intSourceFiscalYear AND
					  SerialNo   = @intSourceSerialNo

			DECLARE @TotalDiscount FLOAT
			SET  @TotalDiscount = @Discount + @Discount2 + @CurrencyDiscount + @TotalLineDiscount 

			SET @SumGoodsPrice  = ISNULL (@SumGoodsPrice, 0)
			SET @SumServicePrice  = ISNULL (@SumServicePrice, 0)
			
			SET @SumGoodsPriceWithTax = @SumGoodsPrice  + @SumServicePrice
			
			IF @TaxOverWorthViewInCustomerInvoice = 'False'
				SET @SumGoodsPriceWithTax = @SumServicePrice + @SumGoodsPrice + @TollOverWorthCost + @TaxOverWorthCost

			IF @ShowSaleTransportationInBill = 'False'
				SET @SumGoodsPriceWithTax = @SumGoodsPriceWithTax + @TransportationIncome - @TransportationCost - @CurrencyTransportationCost + @CurrencyTransportationIncome

			DECLARE @TotalTransportationCost FLOAT
				SET @TotalTransportationCost =  @TransportationCost + @CurrencyTransportationCost - @CurrencyTransportationIncome

			IF @SumGoodsPriceWithTax = @TotalDiscount
				SET @ShowSaleDiscountInBill = 'TRUE'
				
			--------------------------------------------------------------------------------------------------------

			--------------------------------------------------------------------------------------------------------
			SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + @DescDistribution 
			SET @strRecDesc='پیش فاکتور '  + @strTitleSale + @strFiscalSerial + @SaleTypeText + @SettlementDate + @strAcntName
						
			--------------------------------------------------------------------------------------------------------
			----- اگر جمع کل فروش به حساب مشتری منظور میشود
			IF @TotalSale2Account = 1
			BEGIN
				
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
								
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							 @AcntCode,ROUND(@SumGoodsPriceWithTax - @EarnestMoney - (@TotalDiscount),@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp)
		--select ROUND(@SumGoodsPriceWithTax - (@TotalDiscount),0)
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
												
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,ROUND(@SumGoodsPriceWithTax- @EarnestMoney ,@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp)
		--select ROUND(@SumGoodsPriceWithTax,0)

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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,0 ,ROUND(@EarnestMoney,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
--select ROUND(@EarnestMoney,0)
				END

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
							SET @strRecDesc2 = ' تخفیف پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName
								
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
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
										@AcntCode,0 ,ROUND(@TotalDiscount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
								--		select ROUND(@TotalDiscount,0)
						END

				END	
			END

			ELSE ----- IF @TotalSale2Account = 0
			----- اگر تک تک آیتمهای فروش به حساب مشتری منظور میشود
			BEGIN
				
				--IF @HasDST = 'False' 
					Declare	curSale CURSOR For 
					SELECT	D.GoodsAmount
					 +ROUND( (
					 Case When IsNumeric(ConstText1) = 1 AND @buy_AddConstText1ToGoodsPrice = 'True' Then ConstText1 Else 0 End +
					 Case When IsNumeric(ConstText2) = 1 AND @buy_AddConstText2ToGoodsPrice = 'True'  Then ConstText2 Else 0 End + 
					 Case When IsNumeric(ConstText3) = 1 AND @buy_AddConstText3ToGoodsPrice = 'True'  Then ConstText3 Else 0 End + 
					Case When IsNumeric(ConstText4) = 1 AND @buy_AddConstText4ToGoodsPrice = 'True'  Then ConstText4 Else 0 End),@PriceDecimalsToForms)
					,D.GoodsQuantity,D.SubUnitQuantity,D.DescDtl,
							pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName,
							pub.funGetGoodsUnitName(D.GoodsID, @LanguageID) AS GoodsMainUnit, U.UnitName GoodsUnit, 
							D.SubUnitID, D.SubUnitID3, D.Height, D.Width, D.SubUnitQuantity3,D.ServiceAmount
							,D.Var1,D.Var2,D.Var3,D.Var4
					FROM inv.tblPreSaleDtl D
					left Join inv.tblUnitsDtl U ON D.SubUnitID = U.UnitID
					WHERE ProcessID=@intSourceProcessID AND
						  ProcessNo=@intSourceProcessNo AND
						  FiscalYear=@intSourceFiscalYear AND
						  SerialNo=@intSourceSerialNo 

				----- فاکتور فروش سطر به سطر به حساب مشتری میرود
				Open  curSale; 
			
				Fetch NEXT From curSale Into @GoodsPrice,@GoodsQuantity,@SubUnitQuantity,@DescDtl,@GoodsName,@GoodsMainUnit,@GoodsUnit,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @ServiceAmount,@Var1,@Var2,@Var3,@Var4
			
				While (@@Fetch_Status = 0)
					BEGIN
						IF @GoodsPrice <> 0
							BEGIN


								SET @decPrice =Ltrim(rtrim(str(@GoodsPrice)))  
								SET @StrQuantity = ltrim(rtrim(str(@GoodsQuantity,len(@GoodsQuantity),3))) 
								--SET @strRecDesc2 = ' پیش فاکتور ' + @strTitleSale + @strFiscalSerial + ' - ' + @GoodsName + ' - ' + @StrQuantity + @GoodsUnit + ' - فی ' + ltrim(rtrim(str(@GoodsPrice))) + @strAcntName
								SET @strRecDesc2 = ' پیش فاکتور ' + @strTitleSale + @strFiscalSerial + ' -  @GoodsName  - ' + @StrQuantity + @GoodsUnit + ' - فی ' + ltrim(rtrim(str(@decPrice))) + @strAcntName
									
								if  @Sal_StoreVariableAddVch1=1	SET @strRecDesc2 = @strRecDesc2 + ' ' + @Sal_StoreVariable1+ ' ' +str( @Var1)
								if  @Sal_StoreVariableAddVch2=1	SET @strRecDesc2 = @strRecDesc2 + ' ' + @Sal_StoreVariable2+ ' ' +str( @Var2)
								if  @Sal_StoreVariableAddVch3=1	SET @strRecDesc2 = @strRecDesc2 + ' ' + @Sal_StoreVariable3+ ' ' + str(@Var3)
								if  @Sal_StoreVariableAddVch4=1	SET @strRecDesc2 = @strRecDesc2 + ' ' + @Sal_StoreVariable4+ ' ' + str(@Var4)

								SET @intMaxDocRowNo = @intMaxDocRowNo + 1
								SET @intMaxRowNo = @intMaxRowNo + 1
								
								--, @Height, @Width, @SubUnitQuantity3, @ServiceAmount
								
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
										 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
								VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
										 @AcntCode,@Amount,0,TS.pub.funChangeFarsiStrings(@strRecDesc2), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp)
						--	select @Amount
							END
			
						Fetch NEXT From curSale Into @GoodsPrice,@GoodsQuantity,@SubUnitQuantity,@DescDtl,@GoodsName,@GoodsMainUnit,@GoodsUnit,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @ServiceAmount,@Var1,@Var2,@Var3,@Var4
					END
			
				Close curSale;
				Deallocate curSale; 

				IF  (@TotalDiscount) <> 0
					BEGIN
						SET @strRecDesc2 = ' تخفیف پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName
							
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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCode,0 ,ROUND(@TotalDiscount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
					--	select ROUND(@TotalDiscount,0)			
					END
				
			END

			--------------------------------------------------------------------------------------------------------
						-----
			--IF @HasDST = 'False' 
				Declare	curVisitor CURSOR For 
				SELECT	GoodsID,GoodsAmount,GoodsQuantity,SubUnitID,SubUnitID3, Height, Width, SubUnitQuantity3, ServiceAmount
				FROM inv.tblPreSaleDtl
				WHERE ProcessID=@intSourceProcessID AND
					  ProcessNo=@intSourceProcessNo AND
					  FiscalYear=@intSourceFiscalYear AND
					  SerialNo=@intSourceSerialNo 

			Open  curVisitor; 

			Fetch NEXT From curVisitor Into @GoodsID,@GoodsPrice,@GoodsQuantity,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @ServiceAmount

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
						
				Fetch NEXT From curVisitor Into @GoodsID,@GoodsPrice,@GoodsQuantity,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @ServiceAmount
			END
			
			Close curVisitor;
			Deallocate curVisitor; 
			-----
				
			----- کل تخفیف به بدهکاری هزینه میرود
			IF  (@TotalDiscount) <> 0
			begin
			IF @inv_GoodsAcntGroup = 'True' 
				BEGIN
				----------تخفیفات جایزه------------------------------------------------------------------------------------------------
					Declare	@DtlDiscountDtlReward  FLOAT
					Declare	@RowRewardAcntCode	   varchar(20)
				
					Declare	curSet CURSOR For 

					SELECT	g.GoodsAcntGroupID,RowRewardAcntCode,ROUND(SUM(s.Discount),@PriceDecimalsToForms)
					FROM inv.tblPreSaleDtl s
					INNER JOIN inv.tblGoods g
					ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
					INNER JOIN inv.tblGoodsAcntGroup ga ON ga.GoodsAcntGroupID=g.GoodsAcntGroupID
					WHERE g.IsService='False' AND 
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

							SET @strRecDesc2 = ' تخفیف جایزه سطری پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName
						
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
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
										@RowRewardAcntCode,ROUND(@DtlDiscountDtlReward,@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

							SET @TotalDiscount = @TotalDiscount - ROUND(@DtlDiscountDtlReward,@PriceDecimalsToForms) 
								
							Fetch NEXT From curSet Into @GoodsAcntCodeGroup,@RowRewardAcntCode,@DtlDiscountDtlReward
						END
						
					Close curSet;
					Deallocate curSet; 

				-------------تخفیفات بدون جایزه-----------------------------------------------------------------------------------
				
					Declare	@DtlDiscountDtl  FLOAT
					Declare	@RowDiscountAcntCode	   varchar(20)

					Declare	curSet CURSOR For 

					SELECT	g.GoodsAcntGroupID,RowDiscountAcntCode,ROUND(SUM(s.Discount),@PriceDecimalsToForms)
					FROM inv.tblPreSaleDtl s
					INNER JOIN inv.tblGoods g
					ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
					INNER JOIN inv.tblGoodsAcntGroup ga ON ga.GoodsAcntGroupID=g.GoodsAcntGroupID
					WHERE g.IsService='False' AND 
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
							SET @strRecDesc2 = ' تخفیف سطری پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName
						
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
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
										@RowDiscountAcntCode,ROUND(@DtlDiscountDtl,@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

							SET @TotalDiscount = @TotalDiscount - ROUND(@DtlDiscountDtl,@PriceDecimalsToForms) 
								
							Fetch NEXT From curSet Into @GoodsAcntCodeGroup,@RowDiscountAcntCode,@DtlDiscountDtl
						END
						
					Close curSet;
					Deallocate curSet; 

				END 

				IF  (@TotalDiscount) <> 0
				BEGIN
					IF @DiscountAcntCode is null OR @DiscountAcntCode = ''
						BEGIN
							--کد تخفیف فروش کالا خالي است 
							SET @strMsgText=TS.pub.funGetMessages(11040,@LanguageID)
							Raiserror (@strMsgText,16,1)
							Return
						END	
					SET @strRecDesc2 = ' تخفیف پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName
						
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@TotalDiscount,@PriceDecimalsToForms) / @CurrencyRate
					
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
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@DiscountAcntCode,ROUND(@TotalDiscount,@PriceDecimalsToForms),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
				END
			end

			--------------------------------------------------------------------------------------------------------
			IF @inv_GoodsAcntGroup = 'True' 
			begin
			
				Declare	@DtlPriceGoodsAcntGroupID  FLOAT
			
				Declare	curSet CURSOR For 

				SELECT	GoodsAcntGroupID,ROUND(SUM(s.GoodsAmount * GoodsQuantity),@PriceDecimalsToForms)
				FROM inv.tblPreSaleDtl s
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

						IF @SaleGoodsAcntGroup=''
						BEGIN
							--کد فروش کالا خالي است 
							SET @strMsgText=TS.pub.funGetMessages(11047,@LanguageID)
							Raiserror (@strMsgText,16,1,@GoodsAcntCodeGroup)
							Return
						END

						if @AcntPartNumberBranchPartNo<>0	and  len(@SaleGoodsAcntGroup)>acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)
							set @SaleGoodsAcntGroup=substring (@SaleGoodsAcntGroup,1,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) -1)+
							substring (@AcntCode,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) ,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2))+
							substring (@SaleGoodsAcntGroup,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)+acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2),20)

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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@SaleGoodsAcntGroup,0,ROUND(@DtlPriceGoodsAcntGroupID,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
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
				SELECT	StoreID,ROUND(SUM(s.GoodsAmount * GoodsQuantity),@PriceDecimalsToForms)
				FROM inv.tblPreSaleDtl s
				left JOIN inv.tblGoods g
				ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
				WHERE g.IsService='False' AND 
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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@SaleAcntCode,0,ROUND(@DtlPrice,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@SaleAcntCode,0,ROUND(@SumGoodsPrice,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
							--	select ROUND(@SumGoodsPrice,0) 
				END	

			--------------------------------------------------------------------------------------------------------
			--------------------------------------------------------------------------------------------------------
			DECLARE @CostCenterAcntCode VARCHAR(30)
			
			Declare	curService CURSOR For 
			SELECT	g.CostCenterAcntCode,s.GoodsAmount,SubUnitQuantity,DescDtl,pub.funGetGoodsName(s.GoodsID,@LanguageID) AS GoodsName
			,SubUnitID,SubUnitID3, Height, Width, SubUnitQuantity3, ServiceAmount
			FROM inv.tblPreSaleDtl s
			left JOIN inv.tblGoods g
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
			WHERE g.IsService = 'True' AND 
				  g.PartNumber=@UnitPart AND 
				  ProcessID=@intSourceProcessID AND
				  ProcessNo=@intSourceProcessNo AND
				  FiscalYear=@intSourceFiscalYear AND
				  SerialNo=@intSourceSerialNo 

				Open  curService; 
			
				Fetch NEXT From curService Into @CostCenterAcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @ServiceAmount
			
				While (@@Fetch_Status = 0)
					BEGIN
						IF @GoodsPrice <> 0
							BEGIN
								SET @strRecDesc2 = ' پیش فاکتور ' + @strTitleSale + @strFiscalSerial + ' - خدمات ' + @GoodsName + ' - ' + ltrim(rtrim(str(@GoodsQuantity,LEN(@GoodsQuantity),3)))  + ' - فی ' + ltrim(rtrim(str(@GoodsPrice))) + @strAcntName
										
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
													
								INSERT INTO acc.tblVoucherDtl
										(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
								VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
										 @CostCenterAcntCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp)
							END
			
						Fetch NEXT From curService Into @CostCenterAcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@SubUnitID,@SubUnitID3, @Height, @Width, @SubUnitQuantity3, @ServiceAmount
					END
			
				Close curService;
				Deallocate curService; 
			--------------------------------------------------------------------------------------------------------
			--------------------------------------------------------------------------------------------------------

			-------------------------------------------------هزینه حمل و نقل---------------------------------------
			IF @TransportationCostAcntCode <> '' AND @TransportationCost <> 0
				BEGIN
					DECLARE @strRecDescTransCost VARCHAR(1000) 
					
					--SET @strRecDescTransCost = ' هزینه حمل پیش فاکتور ' + @strTitleSale + @strFiscalSerial
					SET @strRecDescTransCost = ' كرايه حمل پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName

					--------------------------------------------------------------------------------------------------------
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
					BEGIN
						IF @TransportationCost = @TotalTransportationCost
							SET @CurrencyAmount = ROUND(@TransportationCost,@PriceDecimalsToForms) / @CurrencyRate
						ELSE
							SET @CurrencyAmount = ROUND(@TotalTransportationCost,@PriceDecimalsToForms) / @CurrencyRate
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@TransportationCostAcntCode,ROUND(@TransportationCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
					--------------------------------------------------------------------------------------------------------
					IF @ShowSaleTransportationInBill = 'True'  or @TotalSale2Account='False'
						BEGIN
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
										@AcntCode,0,ROUND(@TransportationCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID)
						END
				END

			-------------------------------------------------درآمد حمل و نقل---------------------------------------
			IF @TransportationIncomeAcntCode <> '' AND @TransportationIncome <> 0
				BEGIN
					DECLARE @strRecDescTrans VARCHAR(1000) 
					
					-- SET @strRecDescTrans = ' درآمد حمل پیش فاکتور ' + @strTitleSale + @strFiscalSerial
					SET @strRecDescTrans = ' كرايه حمل پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName

					--------------------------------------------------------------------------------------------------------
					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@TransportationIncome,@PriceDecimalsToForms) / @CurrencyRate
					
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
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
										@AcntCode,ROUND(@TransportationIncome,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
						END	
					--------------------------------------------------------------------------------------------------------
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@TransportationIncomeAcntCode,0,ROUND(@TransportationIncome,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),'',0,@CurrencyAmount,@CurrencyTypeID)

				END

				------------------------------------------------هزینه بسته بندی------------------------------------
				IF @PackingAcntCode	<> '' AND @PackingCost <> 0
					BEGIN
						--------------------------------------------------------------------------------------------------------
					
						DECLARE @strRecDescPacking VARCHAR(1000) 
						SET @strRecDescPacking =' هزینه بسته بندی پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName
					
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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@AcntCode,ROUND(@PackingCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescPacking)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
					
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
						SET @strRecDescTax = ' مالیات تجمیع عوارض پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName
						
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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@AcntCode,ROUND(@TaxCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTax)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,2)
					
						--------------------------------------------------------------------------------------------------------
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,BaseID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@TaxAcntCode,0,ROUND(@TaxCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTax)),'',0,@CurrencyAmount,2)
						
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
				SET @strRecDescVisitor = ' هزینه بازاریاب پیش فاکتور <<' + @strRecDescVisitor + '>>'+ @strTitleSale + @strFiscalSerial + @strAcntName
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@VisitorCost,@PriceDecimalsToForms) / @CurrencyRate
				
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
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorCostAcntCode,ROUND(@VisitorCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorAcntCode,0,ROUND(@VisitorCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0,@CurrencyAmount)
							
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
				SET @strRecDescVisitor2 = ' هزینه بازاریاب 2 پیش فاکتور <<' + @strRecDescVisitor2 + '>>'+ @strTitleSale + @strFiscalSerial + @strAcntName
				
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
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorCostAcntCode2,ROUND(@VisitorCost2,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorAcntCode2,0,ROUND(@VisitorCost2,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor2)),'',0,@CurrencyAmount)
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@EarnestMoneyAcntCode,ROUND(@EarnestMoney,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescEarnestMoney)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

		END
				
		-----------------------------------------------مالیات بر ارزش افزوده--------------------------------------------
		IF @SaleTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0
			BEGIN
				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescTaxOverWorth VARCHAR(1000) 
				SET @strRecDescTaxOverWorth = ' مالیات بر ارزش افزوده پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName
				
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,ROUND(@TaxOverWorthCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,2)
				END
					--------------------------------------------------------------------------------------------------------
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 						SELECT @SaleTaxOverWorthAcntCode = [pub].[funMergCode](@SaleTaxOverWorthAcntCode,@AcntCode)

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@SaleTaxOverWorthAcntCode,0,ROUND(@TaxOverWorthCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0,@CurrencyAmount,@CurrencyTypeID,2)
				
			END

			----------------------------------------------عوارض بر ارزش افزوده--------------------------------------------
			IF @SaleTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0
				BEGIN
					--------------------------------------------------------------------------------------------------------
					DECLARE @strRecDescTollOverWorth VARCHAR(1000) 
					SET @strRecDescTollOverWorth = ' عوارض بر ارزش افزوده پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName
					
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
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@AcntCode,ROUND(@TollOverWorthCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,3)
					End
				
						--------------------------------------------------------------------------------------------------------
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
						
						IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 							SELECT @SaleTollOverWorthAcntCode = [pub].[funMergCode](@SaleTollOverWorthAcntCode,@AcntCode)

						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,BaseID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@SaleTollOverWorthAcntCode,0,ROUND(@TollOverWorthCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0,@CurrencyAmount,3)
				END

														
		-------------------------------------------------سایر هزینه ها در فروش---------------------------------------
		IF @OtherCostAcntCode <> '' AND @OtherCost <> 0
			BEGIN
				DECLARE @strRecDescOtherCost VARCHAR(1000) 
				
				SET @strRecDescOtherCost = 'سایر هزینه ها در پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName

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
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@OtherCostAcntCode,ROUND(@OtherCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,0,ROUND(@OtherCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID)

			END

		-------------------------------------------------'سایر درآمد ها در فروش---------------------------------------
		IF @OtherIncomeAcntCode <> '' AND @OtherIncome <> 0
			BEGIN
				DECLARE @strRecDescIncome VARCHAR(1000) 
				
				--SET @strRecDescIncome = 'سایر درآمد ها در پیش فاکتور ' + @strTitleSale + @strFiscalSerial
				SET @strRecDescIncome = 'سایر اضافات در پیش فاکتور ' + @strTitleSale + @strFiscalSerial + @strAcntName

				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

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
								
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,ROUND(@OtherIncome,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),pub.funReverseForCrystal(@DescHdr),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@OtherIncomeAcntCode,0,ROUND(@OtherIncome,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),'',0,@CurrencyAmount,@CurrencyTypeID)

			END
			
			
			exec 	acc.SpBalanceVoucher @intVchNo,@AcntCode ,@intSourceProcessID,	@intSourceProcessNo,	@intSourceFiscalYear,	@intSourceSerialNo	
	END
	ELSE --@Sal_PresaleVoucher ='False'
	BEGIN
	
		SET @strTitleSale = ''
		SET @SaleOrderAcntCode = ''
		
		SELECT @strTitleSale = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'TitleSale' + LTRIM(RTRIM(STR(@intSourceProcessNo)))
		--------------------------------------------------------------------------------------------------------
		SELECT @SaleOrderAcntCode = LTRIM(RTRIM(SettingValue))
		FROM pub.tblSettings
		WHERE SettingKey = 'SaleOrderAcntCode'
		--------------------------------------------------------------------------------------------------------
		SELECT	@StoreID=StoreID,@AcntCode=AcntCode,@Discount=Discount,@Discount2=Discount2,
				@CurrencyDiscount=(CurrencyDiscount * CurrencyRate),
				@CurrencyTransportationCost = (CurrencyTransportationCost * CurrencyRate),
				@CurrencyTransportationIncome = (CurrencyTransportationIncome * CurrencyRate),
				@TransportationCost=TransportationCost,@TransportationIncome=TransportationIncome,
				@PackingCost=PackingCost,@TaxCost=TaxCost,@VisitorAcntCode=VisitorAcntCode,
				@VisitorPercent=VisitorPercent,@VisitorCost=VisitorCost,@VisitorAcntCode2=VisitorAcntCode2,
				@VisitorPercent2=VisitorPercent2,@VisitorCost2=VisitorCost2,@CurrencyRate=CurrencyRate,
				@EarnestMoney=EarnestMoney,@EarnestMoneyPercent=EarnestMoneyPercent,@EarnestMoneyAcntCode=EarnestMoneyAcntCode,
				@TransportationCostAcntCode=TransportationCostAcntCode,@TransportationIncomeAcntCode=TransportationIncomeAcntCode,
				@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost,@SaleTypeID=SaleTypeID, 
				@OtherCostAcntCode=OtherCostAcntCode,@OtherIncomeAcntCode=OtherIncomeAcntCode,@OtherCost=OtherCost,@OtherIncome=OtherIncome,@DescHdr= DocDesc,
				@SettlementDate=SettlementDate,@CurrencyTypeID=CurrencyTypeID,@DocDesc = DocDesc
		FROM inv.tblPreSaleHdr
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 

		SET @SaleOrderAcntCode = @SaleOrderAcntCode + SUBSTRING(@AcntCode ,LEN(@SaleOrderAcntCode)+1,20)

		IF @AcntCode='' or @AcntCode is null
			BEGIN

				--کد فروش کالا خالي است 
				SET @strMsgText=TS.pub.funGetMessages(11029,@LanguageID)
				Raiserror ('کد حسابداری خریدار خالی است',16,1)
				Return
			END
		IF @SaleOrderAcntCode='' or @SaleOrderAcntCode is null
			BEGIN

				--کد فروش کالا خالي است 
				SET @strMsgText=TS.pub.funGetMessages(11029,@LanguageID)
				Raiserror ('کد حسابداری پیش فرض  سفارش در تنظیمات خالی است',16,1)
				Return
			END
	-------------
		SELECT	@SaleTaxOverWorthAcntCode=SaleTaxOverWorthAcntCode,
		        @SaleTollOverWorthAcntCode=SaleTollOverWorthAcntCode,
			    @PackingAcntCode=PackingAcntCode
		FROM inv.tblStores 
		WHERE StoreID = @StoreID

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
		SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))

		SET @strRecDesc = N'پیش فاکتور برگه ' + @strFiscalSerial
		------------------------------------------------ ÓÝÇÑÔ ÝÑæÔ --------------------------------------------------------
		
		SELECT	@SumGoodsPrice = SUM(GoodsQuantity * GoodsAmount - Discount )
		FROM inv.tblPreSaleDtl 
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo
			   
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@SumGoodsPrice+@TaxOverWorthCost+@TollOverWorthCost-@Discount-@Discount2,@PriceDecimalsToForms) / @CurrencyRate
					
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
					@AcntCode,ROUND(@SumGoodsPrice+@TaxOverWorthCost+@TollOverWorthCost-@Discount-@Discount2,@PriceDecimalsToForms) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DocDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID)
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @SaleOrderAcntCode ,0,ROUND(@SumGoodsPrice+@TaxOverWorthCost+@TollOverWorthCost-@Discount-@Discount2,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DocDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp  )	

		IF @EarnestMoneyAcntCode <> '' AND @EarnestMoney <> 0
		BEGIN
		SET @strRecDesc = @strRecDesc + ' - پیش دریافت'
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount, CurrencyTypeID)
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @EarnestMoneyAcntCode,ROUND(@EarnestMoney,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DocDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	
													
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount, CurrencyTypeID)
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,0,ROUND(@EarnestMoney,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DocDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	

		END
		IF @PackingAcntCode	<> '' AND @PackingCost <> 0
		BEGIN
			--------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescPacking1 VARCHAR(1000) 
			SET @strRecDescPacking1 = N' هزینه بسته بندی پیش فاکتور برگه' + @strFiscalSerial
				
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,ROUND(@PackingCost,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescPacking1)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
				
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@SaleOrderAcntCode,0,ROUND(@PackingCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescPacking1)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
					
		END
	
	END
END
GO
