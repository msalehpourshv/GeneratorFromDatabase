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
-- =============================================
Create PROCEDURE [acc].[SpVchSaleRet]
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
	Declare @strMsgText							NVarChar(2044)
	Declare @strTitleSale						NVarChar(100)
	Declare @DescHdr							NVarChar(1000)
	Declare @DescDtl							NVarChar(1000)
	Declare @DescDistribution					NVarChar(1000)
	Declare @strRecDesc							NVarChar(1000)
	Declare @strRecDesc2						NVarChar(1000)
	Declare @strFiscalSerial					VarChar(20)
	Declare @StoreID							Varchar(20)
	Declare @AcntCode							Varchar(20)
	Declare @SaleReturnAcntCode					Varchar(20)
	Declare @DiscountAcntCode					Varchar(20)
	Declare @TransportationCostAcntCode			Varchar(20)
	Declare @TransportationIncomeAcntCode		Varchar(20)
	Declare @TransportationCost					Float
	Declare @TransportationIncome				Float
	Declare @AdvertisingPercent					FLOAT
	Declare @AdvertisingCostAcntCode			Varchar(20)
	Declare @AdvertisingReserveAcntCode			Varchar(20)
	Declare @EarnestMoneyAcntCode				Varchar(20)
	Declare @VisitorAcntCode					Varchar(20)
	Declare @VisitorAcntCode2					Varchar(20)
	Declare @VisitorCostAcntCode				Varchar(20)
	Declare @VisitorCostAcntCode2				Varchar(20)
	Declare @SaleTypeID							Varchar(20)
	Declare @SaleTaxOverWorthAcntCode			Varchar(20)
	Declare @SaleTollOverWorthAcntCode			Varchar(20)
	Declare @CurrencyTypeID						VarChar(20)
	Declare @OtherIncomeAcntCode				Varchar(20)
	Declare @OtherCostAcntCode					Varchar(20)
	Declare @OtherCost							Float
	Declare @VisitorPercent						Float
	Declare @VisitorPercent2					Float
	Declare @VisitorCost						Float
	Declare @VisitorCost2						Float
	Declare @VisitorCostTmp						Float
	Declare @VisitorCostTmp2					Float
	DECLARE @DiscountTaxOverWorth				BIT
	Declare @TotalLineDiscount					Float
	Declare @TotalLineDiscountSrv				Float
	Declare @Discount							Float
	Declare @Discount2							Float
	Declare @CustomerCardDiscount				Float
	Declare @EarnestMoney						Float
	Declare @EarnestMoneyPercent				Float
	Declare @GoodsAmount						Float
	Declare @GoodsPrice							Float
	Declare @GoodsQuantity						Float
	Declare @TaxOverWorthCost					Float
	Declare @TollOverWorthCost					Float
	Declare @SumGoodsPrice						Float
	Declare @SumServicePrice					Float
	Declare @CurrencyRate						Float
	Declare @CurrencyAmount						Float
	Declare @OtherIncome						Float
	Declare @DiscountMinusFromVisitor			Bit
	Declare @HasDST								BIT		
	DECLARE @TaxOverWorthViewInCustomerInvoice  BIT
	DECLARE @ShowSaleTransportationInBill		BIT		
	DECLARE @TotalSale2Account					BIT		
	Declare @SumGoodsPriceWithTax				Float
	DECLARE @BaseDistributionSerialNo			Integer		
	Declare @BaseDistributionFiscalYear			Smallint	
	Declare @SaleAcntCodeInSaleTypes			BIT
	DECLARE @GetAcntCodeFromStore				BIT
	Declare @Sal_StoreDtl						BIT
	Declare @inv_GoodsAcntGroup					BIT
	Declare @GoodsRetAcntCodeGroup	    		Varchar(20)
	Declare @SaleRetGoodsAcntGroup				Varchar(20)
	Declare @AcntPartNumberBranchPartNo Integer		
	DECLARE @ShowSaleDiscountInBill				BIT		
	DECLARE @PriceDecimalsToForms				tinyint
	DECLARE @UsedPriceDecimalsToFormsInVch		BIT
	DECLARE @ShowRewardCostInSale				BIT
	Declare @SalAcntNameInVoucherDesc			BIT
	Declare @Sal_IncomeAndCostAccountFillFromCustomer BIT
	Declare @strAcntName						NVarChar(500)		
	Declare @CurrencyRateTmp					Float
	Declare @CurrencyAmountTmp					Float
	Declare @CurrencyTypeIDTmp					VarChar(20)		
	Declare @Debit								Float
	Declare @Credit								Float	
	Declare @AmountHdr							Float
	DECLARE @UnitPart							TINYINT
	DECLARE @str_Goods							tinyint
	DECLARE @str_GoodsSum						tinyint
	DECLARE @AllowOtherIncomeInDtl				BIT
	Declare @Sal_TaxAcntCompletWithCustCode bit
	Declare @inv_GoodsAcntGroupWithStoreID bit


	--------------------------------------------------------------------------------------------------------
	SET	@Discount						= 0
	SET @Discount2						= 0				
	SET @TotalLineDiscount				= 0
	SET @TotalLineDiscountSrv			= 0
	SET @TotalSale2Account				= 0				
	SET @CustomerCardDiscount			= 0				
	SET @VisitorCostTmp					= 0
	SET @VisitorCostTmp2				= 0
	SET @CurrencyRate					= 0 	
	SET @CurrencyAmount					= 0 
	SET @ShowSaleTransportationInBill	= 'True'
	SET @ShowSaleDiscountInBill			= 1			
	SET @PriceDecimalsToForms			= 0
	SET @UsedPriceDecimalsToFormsInVch	= 'False'
	SET @ShowRewardCostInSale			= 'False'
	SET @CurrencyRateTmp				= 0
	SET @CurrencyAmountTmp				= 0
	SET @CurrencyTypeIDTmp				= ''
	SET @DescHdr						= ''
	SET @CurrencyTypeID					= ''
	SET @strTitleSale					= ''
	SET @DescDistribution				= ''
	SET @SaleTypeID						= ''
	SET @SaleAcntCodeInSaleTypes		= 'False'
	SET @GetAcntCodeFromStore			= 'False'
	SET @Sal_StoreDtl					= 'False'
	SET @inv_GoodsAcntGroup				= 'False'
	SET @inv_GoodsAcntGroupWithStoreID   = 'False'
	set @AllowOtherIncomeInDtl			= 'False'
	SET @AcntPartNumberBranchPartNo		= 0
	SET @UnitPart						= 1
	SEt @Sal_IncomeAndCostAccountFillFromCustomer = 0

	SELECT @UnitPart = SettingValue								FROM pub.tblSettings where SettingKey = 'UnitPart'
	SELECT @inv_GoodsAcntGroup = SettingValue					FROM pub.tblSettings WHERE UPPER(SettingKey) = UPPER('inv_GoodsAcntGroup')
	SELECT @inv_GoodsAcntGroupWithStoreID=SettingValue			FROM pub.tblSettings WHERE SettingKey='inv_GoodsAcntGroupWithStoreID'
	SELECT @ShowSaleDiscountInBill = SettingValue				FROM pub.tblSettings WHERE SettingKey = 'ShowSaleDiscountInBill'
	select @UsedPriceDecimalsToFormsInVch=SettingValue			FROM pub.tblSettings where SettingKey='UsedPriceDecimalsToFormsInVch'
	SELECT @strTitleSale = SettingValue							FROM pub.tblSettings WHERE SettingKey = 'TitleSale' + LTRIM(RTRIM(STR(@intSourceProcessNo)))
	SELECT @DiscountMinusFromVisitor = SettingValue				FROM pub.tblSettings WHERE SettingKey = 'DiscountMinusFromVisitor'
	SELECT @HasDST = SettingValue								FROM pub.tblSettings WHERE SettingKey = 'HasDST' 
	SELECT @TaxOverWorthViewInCustomerInvoice = SettingValue	FROM pub.tblSettings WHERE SettingKey = 'TaxOverWorthViewInCustomerInvoice' 
	SELECT @ShowSaleTransportationInBill = SettingValue			FROM pub.tblSettings WHERE SettingKey = 'ShowSaleTransportationInBill' 
	SELECT @TotalSale2Account = SettingValue					FROM pub.tblSettings WHERE SettingKey = 'TotalSale2Account'
	SELECT @SaleAcntCodeInSaleTypes = SettingValue				FROM pub.tblSettings WHERE SettingKey = 'SaleAcntCodeInSaleTypes'	
	SELECT @SalAcntNameInVoucherDesc = SettingValue				FROM pub.tblSettings WHERE SettingKey = 'SalAcntNameInVoucherDesc'
	SELECT @ShowRewardCostInSale=SettingValue					FROM pub.tblSettings WHERE SettingKey='ShowRewardCostInSale'
	SELECT @AcntPartNumberBranchPartNo=SettingValue				FROM pub.tblSettings where SettingKey='AcntPartNumberBranchPartNo'
	SELECT @Sal_IncomeAndCostAccountFillFromCustomer = SettingValue FROM pub.tblSettings WHERE SettingKey = 'Sal_IncomeAndCostAccountFillFromCustomer' 
	SELECT @AllowOtherIncomeInDtl = SettingValue				FROM pub.tblSettings WHERE SettingKey = 'AllowOtherIncomeInDtl' 
	select @Sal_TaxAcntCompletWithCustCode=SettingValue	from pub.tblSettings where SettingKey='Sal_TaxAcntCompletWithCustCode'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1	
	
	IF @inv_GoodsAcntGroup='True' OR @inv_GoodsAcntGroupWithStoreID = 'True'
		set @ShowRewardCostInSale='True'

	IF @UsedPriceDecimalsToFormsInVch='True'
		SELECT @PriceDecimalsToForms=SettingValue from pub.tblSettings where SettingKey='PriceDecimalsToForms'

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	SET @TotalSale2Account = ISNULL(@TotalSale2Account,1)

	IF @TotalSale2Account = 'False'
		SET @TaxOverWorthViewInCustomerInvoice = 'True'
			
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

	IF @SaleAcntCodeInSaleTypes = 'False'
		SELECT @Sal_StoreDtl = SettingValue		FROM pub.tblSettings		WHERE SettingKey = 'Sal_StoreDtl'
	

	SET @ShowSaleDiscountInBill=ISNULL(@ShowSaleDiscountInBill,1)

	--------------------------------------------------------------------------------------------------------
	SELECT	@StoreID=StoreID,@AcntCode=AcntCode,@VisitorAcntCode=VisitorAcntCode,@Discount=Discount,@Discount2=Discount2+Discount3,@TotalLineDiscount=TotalLineDiscount,
			@TransportationCost=TransportationCost,@TransportationIncome=TransportationIncome,@DiscountTaxOverWorth=DiscountTaxOverWorth,
			@CustomerCardDiscount = ABS(CCDiscount),@EarnestMoney=EarnestMoney,@EarnestMoneyPercent=EarnestMoneyPercent,@SaleTypeID=SaleTypeID,
			@VisitorAcntCode=VisitorAcntCode,@DescHdr= DocDesc,@VisitorPercent=VisitorPercent,@VisitorCost=VisitorCost,@CurrencyRate=CurrencyRate,
			@TransportationCostAcntCode=TransportationCostAcntCode,@TransportationIncomeAcntCode=TransportationIncomeAcntCode,@VisitorAcntCode2=VisitorAcntCode2,@VisitorPercent2=VisitorPercent2,@VisitorCost2=VisitorCost2,
			@DiscountAcntCode=DiscountAcntCode,@EarnestMoneyAcntCode=EarnestMoneyAcntCode,@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost,
			@BaseDistributionSerialNo = BaseDistributionSerialNo,@BaseDistributionFiscalYear=BaseDistributionFiscalYear,
			@CurrencyTypeID=CurrencyTypeID,@OtherIncomeAcntCode=OtherIncomeAcntCode,@OtherIncome=OtherIncome,
			@OtherCostAcntCode=OtherCostAcntCode,@OtherCost=OtherCost,@AmountHdr=Amount
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	--------------------------------------------------------------------------------------------------------
		IF @SalAcntNameInVoucherDesc = 'True'
			Select @strAcntName = ' به ' + [pub].GetCodeName(@AcntCode, @LanguageID)
		ELSE
			SET @strAcntName = ''
			
	--------------------------------------------------------------------------------------------------------
	IF @SaleAcntCodeInSaleTypes = 'False'
		SELECT	@SaleReturnAcntCode=SaleReturnAcntCode,	@VisitorCostAcntCode=VisitorCostAcntCode, @VisitorCostAcntCode2=VisitorCostAcntCode,
				@SaleTaxOverWorthAcntCode=SaleTaxOverWorthAcntCode,@SaleTollOverWorthAcntCode=SaleTollOverWorthAcntCode
			   ,@AdvertisingPercent=AdvertisingPercent,@AdvertisingCostAcntCode=AdvertisingCostAcntCode,@AdvertisingReserveAcntCode=AdvertisingReserveAcntCode
		FROM inv.tblStores 
		WHERE StoreID = @StoreID
	ELSE
		SELECT	@SaleReturnAcntCode=SaleReturnAcntCode,	@VisitorCostAcntCode=VisitorCostAcntCode, @VisitorCostAcntCode2=VisitorCostAcntCode,
				@SaleTaxOverWorthAcntCode=SaleTaxOverWorthAcntCode,@SaleTollOverWorthAcntCode=SaleTollOverWorthAcntCode
			   ,@AdvertisingPercent=AdvertisingPercent,@AdvertisingCostAcntCode=AdvertisingCostAcntCode,@AdvertisingReserveAcntCode=AdvertisingReserveAcntCode
		FROM sal.tblSaleTypes
		WHERE SaleTypeID = @SaleTypeID	

	IF @Sal_IncomeAndCostAccountFillFromCustomer=1
	BEGIN
		SET @SaleReturnAcntCode = RTRIM(@SaleReturnAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@SaleReturnAcntCode))+1,20)
		SET @DiscountAcntCode = RTRIM(@DiscountAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@DiscountAcntCode))+1,20)
		SET @TransportationCostAcntCode = RTRIM(@TransportationCostAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@TransportationCostAcntCode))+1,20)
		SET @TransportationIncomeAcntCode = RTRIM(@TransportationIncomeAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@TransportationIncomeAcntCode))+1,20)
		SET @OtherCostAcntCode = RTRIM(@OtherCostAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@OtherCostAcntCode))+1,20)
		SET @OtherIncomeAcntCode = RTRIM(@OtherIncomeAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@OtherIncomeAcntCode))+1,20)
	END
	--------------------------------------------------------------------------------------------------------
	IF @SaleReturnAcntCode='' AND @Sal_StoreDtl = 'False'
		BEGIN
			-- برگشت از فروش خالی است
			SET @strMsgText=TS.pub.funGetMessages(18003,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
	-------------------------------------------------------------------------------------------------------

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
	-------------------------------------------------------------------------------------------------------
	SET @SumGoodsPrice  = 0
	SET @SumServicePrice = 0
--	IF @HasDST = 'False' 
		SELECT	@SumGoodsPrice  = ISNULL(SUM(ROUND(s.GoodsPrice *GoodsQuantity,0)),0)
		FROM inv.tblStorageDocsDtl s
		inner join inv.tblGoods g
		on SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService = 'False' AND
			  g.PartNumber=@UnitPart AND 
			  ProcessID  = @intSourceProcessID AND
			  ProcessNo  = @intSourceProcessNo AND
			  FiscalYear = @intSourceFiscalYear AND
			  SerialNo   = @intSourceSerialNo AND
			  (@ShowRewardCostInSale='True' or IsReward = 'False')

		SELECT	@SumServicePrice  = ISNULL(SUM(ROUND(s.GoodsPrice *GoodsQuantity,0)),0)
		, @TotalLineDiscountSrv= isnull(Floor(SUM(Case when  g.SaleDiscountAcntCode='' then 0 else DiscountDtl+DiscountDtlTaxToll end)),0)
		FROM inv.tblStorageDocsDtl s
		inner join inv.tblGoods g
		on SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService = 'True' AND
			  g.PartNumber=@UnitPart AND 
			  ProcessID  = @intSourceProcessID AND
			  ProcessNo  = @intSourceProcessNo AND
			  FiscalYear = @intSourceFiscalYear AND
			  SerialNo   = @intSourceSerialNo			  
--	ELSE
--		SELECT	@SumGoodsPrice  = SUM(ROUND(GoodsPrice *SubUnitQuantity,0))
--		FROM inv.tblStorageDocsDtl
--		WHERE ProcessID  = @intSourceProcessID AND
--			  ProcessNo  = @intSourceProcessNo AND
--			  FiscalYear = @intSourceFiscalYear AND
--			  SerialNo   = @intSourceSerialNo
	
	--------------------------------------------------------------------------------------------------------
	IF 	@BaseDistributionSerialNo <> 0 AND @BaseDistributionFiscalYear<>0
		BEGIN
			SET @DescDistribution = ' - پخش ' + LTRIM(RTRIM(STR(@BaseDistributionFiscalYear))) + '/' + LTRIM(RTRIM(STR(@BaseDistributionSerialNo))) 
		END	
	--------------------------------------------------------------------------------------------------------
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + @DescDistribution
	SET @strRecDesc=N'برگشت از فروش ' +  @strTitleSale + ' شماره' + @strFiscalSerial + @strAcntName
	
	------------------------------------------------ برگشت از فروش --------------------------------------------------------

	if @SumGoodsPrice IS null 
		SET @SumGoodsPrice = 0	
		
	IF @inv_GoodsAcntGroupWithStoreID = 'True' 
		begin
		
			Declare	@SaleRetAcntCode1  varchar(20)
			Declare	@DtlPriceGoodsAcntGroupID1  FLOAT
		
			Declare	curSet CURSOR For 
			
			SELECT	d.StoreID,[acc].[funMerg_AcntCode]([acc].[funMergAcntCode](st.SaleAcntCode,s.SaleReturnAcntCode),P2AcntCode,P3AcntCode,P4AcntCode) SaleRetAcntCode1, ROUND(SUM(d.GoodsPrice * d.GoodsQuantity),@PriceDecimalsToForms)
			FROM inv.tblStorageDocsDtl d
			INNER JOIN inv.tblStores s ON s.StoreID=d.StoreID
			left JOIN inv.tblGoods g ON SUBSTRING(d.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
			LEFT JOIN inv.tblGoodsAcntGroup a on a.GoodsAcntGroupID=g.GoodsAcntGroupID
			LEFT JOIN sal.tblSaleTypes st ON st.SaleTypeID=d.SaleTypeID
			WHERE g.IsService='False' AND 
				 -- s.IsReward='False' AND 
				  --s.IsReward0='False' AND 
				  g.PartNumber=@UnitPart AND 
				  ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo
			group by d.StoreID,[acc].[funMerg_AcntCode]([acc].[funMergAcntCode](st.SaleAcntCode,s.SaleReturnAcntCode),P2AcntCode,P3AcntCode,P4AcntCode)
 
			----- فاکتور فروش سطر به سطر به حساب مشتری میرود
			Open  curSet; 
		
			Fetch NEXT From curSet Into @StoreID,@SaleRetAcntCode1,@DtlPriceGoodsAcntGroupID1
		
			While (@@Fetch_Status = 0)
				BEGIN

					IF @SaleRetAcntCode1=''
					BEGIN
						--کد فروش کالا خالي است 
						SET @strMsgText=TS.pub.funGetMessages(11047,@LanguageID)
						Raiserror (@strMsgText,16,1,@SaleRetAcntCode1)
						Return
					END


					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPriceGoodsAcntGroupID1,@PriceDecimalsToForms) / @CurrencyRate
							
					IF [acc].[funIsCurrencyAcntCode] (@SaleRetAcntCode1) = 'True'
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
								@SaleRetAcntCode1,ROUND(@DtlPriceGoodsAcntGroupID1,@PriceDecimalsToForms),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

								
					Fetch NEXT From curSet Into @StoreID,@SaleRetAcntCode1,@DtlPriceGoodsAcntGroupID1
				END
					
			Close curSet;
			Deallocate curSet; 

			end	
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
		
			Fetch NEXT From curSet Into @GoodsRetAcntCodeGroup,@DtlPriceGoodsAcntGroupID
		
			While (@@Fetch_Status = 0)
				BEGIN
					if  isnull(@GoodsRetAcntCodeGroup,'')=''
						set @SaleRetGoodsAcntGroup=@SaleReturnAcntCode
					else

					SELECT	@SaleRetGoodsAcntGroup=isnull(SaleRetAcntCode,'')
					FROM inv.tblGoodsAcntGroup 
					WHERE GoodsAcntGroupID = isnull(@GoodsRetAcntCodeGroup,'')
					
					set @GoodsRetAcntCodeGroup=isnull(@GoodsRetAcntCodeGroup,'')

					IF @SaleRetGoodsAcntGroup=''
						set @SaleRetGoodsAcntGroup=@SaleReturnAcntCode

					IF @SaleRetGoodsAcntGroup=''
					BEGIN
						--کد فروش کالا خالي است 
						SET @strMsgText=TS.pub.funGetMessages(11047,@LanguageID)
						Raiserror (@strMsgText,16,1,@GoodsRetAcntCodeGroup)
						Return
					END

					if @AcntPartNumberBranchPartNo<>0	and  len(@SaleRetGoodsAcntGroup)>acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)
						set @SaleRetGoodsAcntGroup=substring (@SaleRetGoodsAcntGroup,1,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) -1)+
						substring (@AcntCode,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) ,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2))+
						substring (@SaleRetGoodsAcntGroup,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)+acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2),20)

					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					IF @CurrencyRate <> 0 	
						SET @CurrencyAmount = ROUND(@DtlPriceGoodsAcntGroupID,@PriceDecimalsToForms) / @CurrencyRate
							
					IF [acc].[funIsCurrencyAcntCode] (@SaleRetGoodsAcntGroup) = 'True'
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
								@SaleRetGoodsAcntGroup,ROUND(@DtlPriceGoodsAcntGroupID,@PriceDecimalsToForms),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
								--select ROUND(@DtlPrice,0)
								
					Fetch NEXT From curSet Into @GoodsRetAcntCodeGroup,@DtlPriceGoodsAcntGroupID
				END
					
			Close curSet;
			Deallocate curSet; 

			end
	else IF @Sal_StoreDtl = 'False'
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
	
			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@SumGoodsPrice,0) / @CurrencyRate
	
			IF [acc].[funIsCurrencyAcntCode] (@SaleReturnAcntCode) = 'True'
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
						@SaleReturnAcntCode,ROUND(@SumGoodsPrice,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp ,@CurrencyTypeIDTmp,@VisitorAcntCode)
		END
	ELSE
		BEGIN
			DECLARE @SumGoodsPrice1 AS Float
			
			Declare	curStore CURSOR For 
			SELECT	s.StoreID,ISNULL(SUM(ROUND(s.GoodsPrice *GoodsQuantity,0)),0)
			FROM inv.tblStorageDocsDtl s
			inner join inv.tblGoods g
			on SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
			WHERE g.IsService = 'False' AND
				  g.PartNumber=@UnitPart AND 
				  ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo AND
				  (@ShowRewardCostInSale='True' or IsReward = 'False')
			GROUP BY s.StoreID

			Open  curStore; 
	
			Fetch NEXT From curStore Into @StoreID,@SumGoodsPrice1
	
			While (@@Fetch_Status = 0)
				BEGIN
					IF @SumGoodsPrice1 <> 0
						BEGIN

							SELECT	@SaleReturnAcntCode=SaleReturnAcntCode
							FROM inv.tblStores 
							WHERE StoreID = @StoreID

						--------------------------------------------------------------------------------------------------------
							IF @SaleReturnAcntCode='' 
								BEGIN
									-- برگشت از فروش خالی است
									SET @strMsgText=TS.pub.funGetMessages(18003,@LanguageID)
									Raiserror (@strMsgText,16,1)
									Return
								END
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							IF @CurrencyRate <> 0 	
								SET @CurrencyAmount = ROUND(@SumGoodsPrice1,0) / @CurrencyRate

							IF [acc].[funIsCurrencyAcntCode] (@SaleReturnAcntCode) = 'True'
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
										@SaleReturnAcntCode,ROUND(@SumGoodsPrice1,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp ,@CurrencyTypeIDTmp,@VisitorAcntCode)

						END
					Fetch NEXT From curStore Into @StoreID,@SumGoodsPrice1

				END
		Close curStore;
		Deallocate curStore; 

	END
	--------------------------------------------------------------------------------------------------------
	DECLARE @VisitorCostSrvAll			Float
	DECLARE @CostCenterAcntCode			VARCHAR(30)
	DECLARE @SaleReturnAcntCodeSrv		VARCHAR(30)
	DECLARE @GoodsName					NVARCHAR(300)
	Declare @DiscountDtl				FLOAT
	DECLARE @SaleDiscountAcntCodeSrv	VARCHAR(30) 	
	DECLARE @VisitorCostSrv				Float
	DECLARE @VisitorCostAcntCodeSrv		VARCHAR(30)

	Set @VisitorCostSrvAll =0
	--------------------------------------------------------------------------------------------------------
if 1=1 --SaleReturnAcntCode or SaleReturnAcntCode
begin
	
	
	Declare	curService CURSOR For 
	SELECT	Case when SaleReturnAcntCode <>'' then SaleReturnAcntCode else g.CostCenterAcntCode end ,s.GoodsPrice,SubUnitQuantity,DescDtl,pub.funGetGoodsName(s.GoodsID,@LanguageID) AS GoodsName
	FROM inv.tblStorageDocsDtl s
	INNER JOIN inv.tblGoods g
	ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
	WHERE g.IsService = 'True' AND 
		  g.PartNumber=@UnitPart AND 
		  ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

		Open  curService; 
	
		Fetch NEXT From curService Into @CostCenterAcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName
	
		While (@@Fetch_Status = 0)
			BEGIN
				IF @GoodsPrice <> 0
					BEGIN
						SET @strRecDesc2 =N' برگشت از فروش ' + @strTitleSale + @strFiscalSerial + ' - خدمات ' + @GoodsName + ' - ' + ltrim(rtrim(str(@GoodsQuantity)))  + ' - فی ' + ltrim(rtrim(str(@GoodsPrice))) + @strAcntName
								
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = ROUND(@GoodsPrice * @GoodsQuantity,0) / @CurrencyRate
						
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
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								 @CostCenterAcntCode,ROUND(@GoodsPrice * @GoodsQuantity,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
					END
	
				Fetch NEXT From curService Into @CostCenterAcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName
			END
	
		Close curService;
		Deallocate curService; 
END
	--------------------------------------------------------------------------------------------------------
  
if 2=2--@SaleDiscountAcntCodeSrv
begin
		
		Declare	curServiceDiscount CURSOR For 	
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
									 @SaleDiscountAcntCodeSrv,0,@DiscountDtl,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
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
	

		Declare	curService CURSOR For 	
			 	SELECT	g.VisitorCostAcntCode, ROUND(VisitorCost*(GoodsQuantity*s.GoodsPrice-DiscountDtl) /Price,0)
		FROM inv.tblStorageDocsDtl s
		inner join inv.tblStorageDocsHdr H on H.ProcessID=s.ProcessID AND H.ProcessNo=s.ProcessNo AND H.FiscalYear=s.FiscalYear AND H.SerialNo=s.SerialNo 
		left JOIN inv.tblGoods g ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService = 'True' AND 
		      g.PartNumber=@UnitPart AND 
			  s.ProcessID=@intSourceProcessID AND s.ProcessNo=@intSourceProcessNo AND s.FiscalYear=@intSourceFiscalYear AND s.SerialNo=@intSourceSerialNo And 
			  g.VisitorCostAcntCode<>'' 

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
									 @VisitorCostAcntCodeSrv,0,@VisitorCostSrv,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
						END
		
					Fetch NEXT From curService Into @VisitorCostAcntCodeSrv ,@VisitorCostSrv
				END
		
			Close curService;
			Deallocate curService; 
		------------------------------------------------------------------------------------------------------
	end
			
		-------------------------------------------------درآمد حمل و نقل---------------------------------------
		IF @TransportationIncomeAcntCode <> '' AND @TransportationIncome <> 0
			BEGIN
				DECLARE @strRecDescTrans VARCHAR(1000) 
				
				-- SET @strRecDescTrans = ' درآمد حمل فروش ' + @strTitleSale + @strFiscalSerial
				SET @strRecDescTrans = ' کرایه حمل برگشت از فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

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
				IF @ShowSaleTransportationInBill = 'True' or @TotalSale2Account = 'False'
				BEGIN								
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,ROUND(@TransportationIncome,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
				END
				--------------------------------------------------------------------------------------------------------

				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@TransportationIncomeAcntCode,0,ROUND(@TransportationIncome,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)
			END
					
		-------------------------------------------------هزینه حمل و نقل---------------------------------------
		IF @TransportationCostAcntCode <> '' AND @TransportationCost <> 0
			BEGIN
				DECLARE @strRecDescTransCost VARCHAR(1000) 
				
				--SET @strRecDescTransCost = ' هزینه حمل فروش ' + @strTitleSale + @strFiscalSerial
				SET @strRecDescTransCost = ' کرایه حمل برگشت از فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

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
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@TransportationCostAcntCode,ROUND(@TransportationCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
				--------------------------------------------------------------------------------------------------------

				IF @ShowSaleTransportationInBill = 'True' OR @TotalSale2Account = 'False'
				BEGIN
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,0,ROUND(@TransportationCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)
				END
			END

	--------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------

	----------------------------------------------- پیش دریافت --------------------------------------------
	IF @EarnestMoneyAcntCode <> '' AND @EarnestMoney <> 0
		BEGIN

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@EarnestMoney,0) / @CurrencyRate
			
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
						@EarnestMoneyAcntCode,0,ROUND(@EarnestMoney,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

		END
	------------------------------------کم کردن جایزه از تخفیفات سطری--------------------------------------------------------------------
	
	Declare @RewardSum as bigint 
	
		SELECT	@RewardSum  = ISNULL(SUM(ROUND(s.GoodsPrice * GoodsQuantity,0)),0)
		FROM inv.tblStorageDocsDtl s
		inner join inv.tblGoods g
		on SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
		WHERE g.IsService = 'False' AND
			  g.PartNumber=@UnitPart AND 
			  ProcessID  = @intSourceProcessID AND
			  ProcessNo  = @intSourceProcessNo AND
			  FiscalYear = @intSourceFiscalYear AND
			  SerialNo   = @intSourceSerialNo AND
			  IsReward = 'True' AND
			  @ShowRewardCostInSale='False'
	
	set @TotalLineDiscount =  @TotalLineDiscount - @RewardSum
	-----------------------------------------------------------------------------------------------
	
	DECLARE @TotalDiscount FLOAT
	SET  @TotalDiscount = @Discount + @Discount2 + @TotalLineDiscount + @CustomerCardDiscount
		
	IF @DiscountTaxOverWorth = 'True'
		SET @TotalDiscount = @TotalDiscount + @TaxOverWorthCost + @TollOverWorthCost

	-- =======================================================
	SET @SumGoodsPrice = @SumGoodsPrice + @SumServicePrice

	SET @SumGoodsPriceWithTax = @SumGoodsPrice
		
	IF @TaxOverWorthViewInCustomerInvoice = 'False'
		SET @SumGoodsPriceWithTax = @SumGoodsPrice + @TollOverWorthCost + @TaxOverWorthCost

	IF @ShowSaleTransportationInBill = 'False'
		SET @SumGoodsPriceWithTax = @SumGoodsPriceWithTax - @TransportationIncome + @TransportationCost

	IF @SumGoodsPriceWithTax = @TotalDiscount
		SET @ShowSaleDiscountInBill = 'TRUE'
	
	DECLARE @OtherIncomeNotShow Decimal
	SET @OtherIncomeNotShow = 0
	IF @AllowOtherIncomeInDtl = 1
		SET @OtherIncomeNotShow =  @OtherCost

	IF @ShowSaleDiscountInBill = '0'
	BEGIN
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
				
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - @EarnestMoney - ROUND(@TotalDiscount,0),0) / @CurrencyRate
	
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
			
		-- ========================					
		Set @Debit = 0
		Set @Credit = 0
		
		If (ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - ROUND(@EarnestMoney,0) - ROUND(@TotalDiscount,0),0)) >= 0
		Begin
			Set @Debit = 0
			Set @Credit = ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - ROUND(@EarnestMoney,0) - ROUND(@TotalDiscount,0),0) 
		End
		Else
		Begin
			Set @Debit = ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - ROUND(@EarnestMoney,0) - ROUND(@TotalDiscount,0),0) * -1
			Set @Credit = 0
		End

		-- ========================					
				
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,@Debit ,@Credit,
					TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
	END					
	ELSE
		BEGIN
		IF @TotalSale2Account = 1
		BEGIN

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
				
			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - @EarnestMoney ,0) / @CurrencyRate
	
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,0 ,ROUND(@SumGoodsPriceWithTax + @OtherIncomeNotShow - ROUND(@EarnestMoney,0) ,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
		END
		ELSE
		BEGIN

		--123
				Declare @decPrice				varchar(30)
				DECLARE @StrQuantity			VarChar(30)
				Declare @SubUnitID				VarChar(20)
				Declare @SubUnitPrice			Float
				Declare @SubUnitQuantity			Float
				Declare @GoodsMainUnit				NVarChar(1000)
				Declare @GoodsUnit					NVarChar(1000)

				Declare	curSale CURSOR For 
					SELECT	D.GoodsPrice,D.SubUnitPrice,D.GoodsQuantity,D.SubUnitQuantity,D.DescDtl,
							pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName,
							pub.funGetGoodsUnitName(D.GoodsID, @LanguageID) AS GoodsMainUnit, U.UnitName GoodsUnit, D.SubUnitID
					FROM inv.tblStorageDocsDtl D
					left Join inv.tblUnitsDtl U ON D.SubUnitID = U.UnitID
					WHERE ProcessID=@intSourceProcessID AND
						  ProcessNo=@intSourceProcessNo AND
						  FiscalYear=@intSourceFiscalYear AND
						  SerialNo=@intSourceSerialNo AND
						  (@ShowRewardCostInSale='True' or IsReward = 'False')

				----- فاکتور فروش سطر به سطر به حساب مشتری میرود
				Open  curSale; 
		
				Fetch NEXT From curSale Into @GoodsPrice,@SubUnitPrice,@GoodsQuantity,@SubUnitQuantity,@DescDtl,@GoodsName,@GoodsMainUnit,@GoodsUnit,@SubUnitID
		
				While (@@Fetch_Status = 0)
					BEGIN
						IF @GoodsPrice <> 0
							BEGIN

								SET @decPrice = Ltrim(rtrim(str(@SubUnitPrice,30)))
								SET	@StrQuantity = ltrim(rtrim(str(@SubUnitQuantity,30)))

								if (round(@SubUnitQuantity,0) <> @SubUnitQuantity)
									SET @StrQuantity = ltrim(rtrim(str(@SubUnitQuantity,30,2)))

							
								SET @strRecDesc2 = 'برگشت از فروش ' + @strTitleSale + @strFiscalSerial + ' -  @GoodsName  - ' + @StrQuantity + @GoodsUnit + ' - فی ' + @decPrice + @strAcntName
								

								SET @intMaxDocRowNo = @intMaxDocRowNo + 1
								SET @intMaxRowNo = @intMaxRowNo + 1
							
								IF @CurrencyRate <> 0 	
									SET @CurrencyAmount = ROUND(@GoodsPrice * @GoodsQuantity,@PriceDecimalsToForms) / @CurrencyRate
							
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
										 @AcntCode,0,ROUND(@GoodsPrice * @GoodsQuantity,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(@strRecDesc2), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
							END
		
										Fetch NEXT From curSale Into @GoodsPrice,@SubUnitPrice,@GoodsQuantity,@SubUnitQuantity,@DescDtl,@GoodsName,@GoodsMainUnit,@GoodsUnit,@SubUnitID
					END
		
				Close curSale;
				Deallocate curSale; 


				--222
				--declare @STT as float
				--set @STT = 0
				--IF @TaxOverWorthViewInCustomerInvoice = 'False'
				--	SET @STT = @TollOverWorthCost + @TaxOverWorthCost

				--IF @ShowSaleTransportationInBill = 'False'
				--	SET @STT = @STT - @TransportationIncome + @TransportationCost
				
				--IF @STT>0

				--222
		--123

		END

	END					

	--------------------------------------------------------------------------------------------------------
	DECLARE @TotalRowDiscount FLOAT
	SET @TotalRowDiscount = 0
	----- کل تخفیف به بدهکاری هزینه میرود
	IF @TotalDiscount <> 0
	BEGIN
		
		IF @DiscountAcntCode is null OR @DiscountAcntCode = ''
			BEGIN
				--کد تخفیف فروش کالا خالي است 
				SET @strMsgText=TS.pub.funGetMessages(11040,@LanguageID)
				Raiserror (@strMsgText,16,1)
				Return
			END	
		SET @strRecDesc2 = N' تخفیف فاکتور برگشت از فروش ' + @strTitleSale + ' شماره' + @strFiscalSerial + @strAcntName

		IF @ShowSaleDiscountInBill = '1'
		BEGIN
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
					
		-- ========================					
		Set @Debit = 0
		Set @Credit = 0
		
		If @TotalDiscount >= 0
		Begin
			Set @Debit = ROUND(@TotalDiscount,0) 
			Set @Credit = 0
		End
		Else
		Begin
			Set @Debit = 0
			Set @Credit = ROUND(@TotalDiscount,0) * -1
		End
		-- ========================	
							
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,@Debit,@Credit,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

	END		 

				IF @inv_GoodsAcntGroupWithStoreID = 'True' 
				BEGIN
			------------------------------------------------------------------------
					Declare	@DtlRewardDtl1  FLOAT
					Declare	@RowRewardAcntCode1	   varchar(20)
		
					Declare	curSet CURSOR For 

					SELECT	s.StoreID,[acc].[funMerg_AcntCode](ss.RowRewardAcntCode,P2AcntCode,P3AcntCode,P4AcntCode) RowRewardAcntCode1,ROUND(SUM(s.DiscountDtl+DiscountDtlTaxToll),@PriceDecimalsToForms)
					FROM inv.tblStorageDocsDtl s
					INNER JOIN inv.tblStores ss
					ON s.StoreID=ss.StoreID
					INNER JOIN inv.tblGoods g
					ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
					LEFT JOIN inv.tblGoodsAcntGroup ga ON ga.GoodsAcntGroupID=g.GoodsAcntGroupID
					WHERE g.IsService='False' AND 
						  (s.IsReward='True' OR
						  s.IsReward0='True' ) AND 
						  g.PartNumber=@UnitPart AND 
						  ProcessID  = @intSourceProcessID AND
						  ProcessNo  = @intSourceProcessNo AND
						  FiscalYear = @intSourceFiscalYear AND
						  SerialNo   = @intSourceSerialNo AND
						  ss.RowRewardAcntCode<>''
					group by s.StoreID,[acc].[funMerg_AcntCode](ss.RowRewardAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)
					----- فاکتور فروش سطر به سطر به حساب مشتری میرود
					Open  curSet; 
		
					Fetch NEXT From curSet Into @StoreID,@RowRewardAcntCode1,@DtlRewardDtl1
		
					While (@@Fetch_Status = 0)
						BEGIN
							IF @RowRewardAcntCode1 is null OR @RowRewardAcntCode1 = ''
							BEGIN
								--کد تخفیف فروش کالا خالي است 
								SET @strMsgText=N'کد تخفیف جایزه  برگشت از فروش در تعریف انبار خالی است '
								Raiserror (@strMsgText,16,1)
								Return
							END	
							SET @strRecDesc2 = ' تخفیف جایزه سطری برگشت از فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
					
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							IF @CurrencyRate <> 0 	
								SET @CurrencyAmount = ROUND(@DtlRewardDtl1,@PriceDecimalsToForms) / @CurrencyRate
							
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
										@RowRewardAcntCode1,0,ROUND(@DtlRewardDtl1,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

							SET @TotalRowDiscount = @TotalRowDiscount + ROUND(@DtlRewardDtl1,@PriceDecimalsToForms) 
							
							Fetch NEXT From curSet Into @StoreID,@RowRewardAcntCode1,@DtlRewardDtl1
						END
					
					Close curSet;
					Deallocate curSet; 
					------------------------------------------------------------------------

					Declare	@DtlDiscountDtl1  FLOAT
					Declare	@RowDiscountAcntCode1	   varchar(20)
		
					Declare	curSet CURSOR For 

					SELECT	s.StoreID,[acc].[funMerg_AcntCode](ss.RowDiscountAcntCode,P2AcntCode,P3AcntCode,P4AcntCode) RowDiscountAcntCode1,ROUND(SUM(s.DiscountDtl+s.DiscountDtlTaxToll),@PriceDecimalsToForms)
					FROM inv.tblStorageDocsDtl s
					INNER JOIN inv.tblStores ss
					ON s.StoreID=ss.StoreID
					INNER JOIN inv.tblGoods g
					ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
					Left JOIN inv.tblGoodsAcntGroup ga ON ga.GoodsAcntGroupID=g.GoodsAcntGroupID
					WHERE g.IsService='False' AND 
						  s.IsReward='False' AND 
						  s.IsReward0='False' AND 
						  g.PartNumber=@UnitPart AND 
						  ProcessID  = @intSourceProcessID AND
						  ProcessNo  = @intSourceProcessNo AND
						  FiscalYear = @intSourceFiscalYear AND
						  SerialNo   = @intSourceSerialNo AND
						  ss.RowDiscountAcntCode<>''
					group by s.StoreID,g.GoodsAcntGroupID,[acc].[funMerg_AcntCode](ss.RowDiscountAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)
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
							SET @strRecDesc2 = ' تخفیف سطری برگشت از فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
					

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
										@RowDiscountAcntCode1,0,ROUND(@DtlDiscountDtl1,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

							SET @TotalRowDiscount = @TotalRowDiscount + ROUND(@DtlDiscountDtl1,@PriceDecimalsToForms) 
							
							Fetch NEXT From curSet Into @StoreID,@RowDiscountAcntCode1,@DtlDiscountDtl1
						END
					
					Close curSet;
					Deallocate curSet; 

				END --@inv_GoodsAcntGroup

			ELSE IF @inv_GoodsAcntGroup = 'True' 
				BEGIN
			------------------------------------------------------------------------
					Declare	@DtlRewardDtl  FLOAT
					Declare	@RowRewardAcntCode	   varchar(20)
		
					Declare	curSet CURSOR For 

					SELECT	g.GoodsAcntGroupID,RowRewardAcntCode,ROUND(SUM(s.DiscountDtl+DiscountDtlTaxToll),@PriceDecimalsToForms)
					FROM inv.tblStorageDocsDtl s
					INNER JOIN inv.tblGoods g
					ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
					INNER JOIN inv.tblGoodsAcntGroup ga ON ga.GoodsAcntGroupID=g.GoodsAcntGroupID
					WHERE g.IsService='False' AND 
						  (s.IsReward='True' OR
						  s.IsReward0='True' ) AND 
						  g.PartNumber=@UnitPart AND 
						  ProcessID  = @intSourceProcessID AND
						  ProcessNo  = @intSourceProcessNo AND
						  FiscalYear = @intSourceFiscalYear AND
						  SerialNo   = @intSourceSerialNo AND
						  g.GoodsAcntGroupID <>'' AND
						  ga.RowRewardAcntCode<>''
					group by g.GoodsAcntGroupID,RowRewardAcntCode
					----- فاکتور فروش سطر به سطر به حساب مشتری میرود
					Open  curSet; 
		
					Fetch NEXT From curSet Into @GoodsRetAcntCodeGroup,@RowRewardAcntCode,@DtlRewardDtl
		
					While (@@Fetch_Status = 0)
						BEGIN
						IF @RowRewardAcntCode is null OR @RowRewardAcntCode = ''
							BEGIN
								--کد تخفیف فروش کالا خالي است 
								SET @strMsgText=N'کد تخفیف جایزه  برگشت از فروش در رده کالا خالي است '
								Raiserror (@strMsgText,16,1)
								Return
							END	
							SET @strRecDesc2 = ' تخفیف جایزه سطری برگشت از فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
					
							if @AcntPartNumberBranchPartNo<>0	and  len(@RowRewardAcntCode)>acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)
								set @RowRewardAcntCode=substring (@RowRewardAcntCode,1,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) -1)+
								substring (@AcntCode,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1) ,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2))+
								substring (@RowRewardAcntCode,acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,1)+acc.funGetAcntLayerStartandLen(@AcntPartNumberBranchPartNo,2),20)

							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							IF @CurrencyRate <> 0 	
								SET @CurrencyAmount = ROUND(@DtlRewardDtl,@PriceDecimalsToForms) / @CurrencyRate
							
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
										@RowRewardAcntCode,0,ROUND(@DtlRewardDtl,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

							SET @TotalRowDiscount = @TotalRowDiscount + ROUND(@DtlRewardDtl,@PriceDecimalsToForms) 
							
							Fetch NEXT From curSet Into @GoodsRetAcntCodeGroup,@RowRewardAcntCode,@DtlRewardDtl
						END
					
					Close curSet;
					Deallocate curSet; 
					------------------------------------------------------------------------

					Declare	@DtlDiscountDtl  FLOAT
					Declare	@RowDiscountAcntCode	   varchar(20)
		
					Declare	curSet CURSOR For 

					SELECT	g.GoodsAcntGroupID,RowDiscountAcntCode,ROUND(SUM(s.DiscountDtl+s.DiscountDtlTaxToll),@PriceDecimalsToForms)
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
		
					Fetch NEXT From curSet Into @GoodsRetAcntCodeGroup,@RowDiscountAcntCode,@DtlDiscountDtl
		
					While (@@Fetch_Status = 0)
						BEGIN
							IF @RowDiscountAcntCode is null OR @RowDiscountAcntCode = ''
							BEGIN
								--کد تخفیف فروش کالا خالي است 
								SET @strMsgText=N'کد تخفیف  برگشت از فروش در رده کالا خالي است '
								Raiserror (@strMsgText,16,1)
								Return
							END	
							SET @strRecDesc2 = ' تخفیف سطری برگشت از فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
					
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
										@RowDiscountAcntCode,0,ROUND(@DtlDiscountDtl,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

							SET @TotalRowDiscount = @TotalRowDiscount + ROUND(@DtlDiscountDtl,@PriceDecimalsToForms) 
							
							Fetch NEXT From curSet Into @GoodsRetAcntCodeGroup,@RowDiscountAcntCode,@DtlDiscountDtl
						END
					
					Close curSet;
					Deallocate curSet; 

				END --@inv_GoodsAcntGroup

		SET @strRecDesc2 = N' تخفیف فاکتور برگشت از فروش ' + @strTitleSale + ' شماره' + @strFiscalSerial + @strAcntName

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@TotalDiscount-@TotalLineDiscountSrv,0) / @CurrencyRate
		
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
					
		-- ========================					
		Set @Debit = 0
		Set @Credit = 0
		
		If @TotalDiscount-@TotalLineDiscountSrv - @TotalRowDiscount >= 0
		Begin
			Set @Debit = 0
			Set @Credit = ROUND(@TotalDiscount-@TotalLineDiscountSrv - @TotalRowDiscount,0)
		End
		Else
		Begin
			Set @Debit = ROUND(@TotalDiscount-@TotalLineDiscountSrv - @TotalRowDiscount,0) * -1
			Set @Credit = 0
		End
		-- ========================	
							
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					@DiscountAcntCode,@Debit,@Credit,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

		END

	
		Declare @GoodsID				VarChar(20)	
		Declare @VisitorCostInGoods		Float
		Declare @Amount					Float
		Declare @Height					Float
		Declare @Width					Float
		Declare @SubUnitQuantity3		Float
		Declare @GoodsAmount3			Float
		Declare @ServiceAmount			Float
		Declare @SubUnitID3				VarChar(20)

		SET @VisitorCostInGoods = 0
		Declare	curVisitor CURSOR For 
		SELECT	GoodsID,GoodsPrice,GoodsQuantity,SubUnitID,SubUnitID3, Height, Width, SubUnitQuantity3, GoodsAmount3,ServiceAmount
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
		----------------------------------------------- بازاریاب --------------------------------------------
		IF @VisitorAcntCode	<> '' AND @VisitorCostAcntCode	<> '' AND (@VisitorCost <> 0 OR @VisitorCostInGoods <> 0)
			BEGIN
				IF @VisitorPercent >0
					BEGIN
						IF @DiscountMinusFromVisitor = 1
							BEGIN	
								SET @VisitorCostTmp = (@SumGoodsPrice * @VisitorPercent) / 100
							END
						ELSE
							BEGIN
								SET @VisitorCostTmp = ((@SumGoodsPrice - (@TotalDiscount)) * @VisitorPercent) / 100
							END
					END
				IF @VisitorCostTmp > 0
					SET @VisitorCost = @VisitorCostTmp

				SET @VisitorCost = @VisitorCost + @VisitorCostInGoods
				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescVisitor VARCHAR(1000) 
				Declare @NamePartNo AS Tinyint

				SET @NamePartNo = 1
				
				SELECT @NamePartNo = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = N'AcntPartNumberForRemainCalculation'

				SELECT @strRecDescVisitor = [acc].[funGetAcntName]([pub].[funSplitString](@AcntCode,' ' ,@NamePartNo),@NamePartNo,@LanguageID)
				SET @strRecDescVisitor = @strRecDesc + N' هزینه بازاریاب فروش <<' + @strRecDescVisitor + '>>' + @strAcntName
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@VisitorCost-@VisitorCostSrvAll,0) / @CurrencyRate
				
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
							@VisitorAcntCode,ROUND(@VisitorCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorCostAcntCode,0,ROUND(@VisitorCost-@VisitorCostSrvAll,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

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
								SET @VisitorCostTmp2 = ((@SumGoodsPrice - (@TotalDiscount)) * @VisitorPercent2) / 100
							END
					END
				IF @VisitorCostTmp2 > 0
					SET @VisitorCost2 = @VisitorCostTmp2

				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescVisitor2 VARCHAR(1000) 
				--Declare @NamePartNo AS Tinyint

				SET @NamePartNo = 1
				
				SELECT @NamePartNo = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = N'AcntPartNumberForRemainCalculation'

				SELECT @strRecDescVisitor2 = [acc].[funGetAcntName]([pub].[funSplitString](@AcntCode,' ' ,@NamePartNo),@NamePartNo,@LanguageID)
				SET @strRecDescVisitor2 = @strRecDesc + N' هزینه بازاریاب 2 فروش <<' + @strRecDescVisitor2 + '>>' + @strAcntName
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@VisitorCost2,0) / @CurrencyRate
				
				IF [acc].[funIsCurrencyAcntCode] (@VisitorAcntCode2) = 'True'
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
							@VisitorAcntCode2, ROUND(@VisitorCost2,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorCostAcntCode2,0,ROUND(@VisitorCost2,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor2)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

			END

		-----------------------------------------------مالیات بر ارزش افزوده--------------------------------------------
		IF @SaleTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0
			BEGIN
				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescTaxOverWorth VARCHAR(1000) 
				SET @strRecDescTaxOverWorth = N' مالیات بر ارزش افزوده برگشت از فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@TaxOverWorthCost,0) / @CurrencyRate
				
				IF [acc].[funIsCurrencyAcntCode] (@SaleTaxOverWorthAcntCode) = 'True'
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

				IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 					SELECT @SaleTaxOverWorthAcntCode = [pub].[funMergCode](@SaleTaxOverWorthAcntCode,@AcntCode)

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@SaleTaxOverWorthAcntCode,ROUND(@TaxOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,2,@VisitorAcntCode)
													
				IF @TaxOverWorthViewInCustomerInvoice = 'True' OR @TotalSale2Account = 'False'
				Begin
					--------------------------------------------------------------------------------------------------------
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,0,ROUND(@TaxOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID,2,@VisitorAcntCode)
				End
			END
					-----------------------------------------------عوارض بر ارزش افزوده--------------------------------------------
		IF @SaleTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0
			BEGIN
				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescTollOverWorth VARCHAR(1000)
				SET @strRecDescTollOverWorth = N' عوارض بر ارزش افزوده برگشت از فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				
				IF @CurrencyRate <> 0
					SET @CurrencyAmount = ROUND(@TollOverWorthCost,0) / @CurrencyRate
				
				IF [acc].[funIsCurrencyAcntCode] (@SaleTollOverWorthAcntCode) = 'True'
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
									
				IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 					SELECT @SaleTollOverWorthAcntCode = [pub].[funMergCode](@SaleTollOverWorthAcntCode,@AcntCode)


					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@SaleTollOverWorthAcntCode,ROUND(@TollOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,3,@VisitorAcntCode)
			IF @TaxOverWorthViewInCustomerInvoice = 'True'
				Begin
					--------------------------------------------------------------------------------------------------------
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,0,ROUND(@TollOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID,3,@VisitorAcntCode)
				End
			END

		-------------------------------------------------'سایر درآمد ها در فروش---------------------------------------
		IF @OtherIncomeAcntCode <> '' AND @OtherIncome <> 0
			BEGIN
				DECLARE @strRecDescIncome VARCHAR(1000) 
				
				--SET @strRecDescIncome = 'سایر درآمد ها در فروش ' + @strTitleSale + @strFiscalSerial
				SET @strRecDescIncome = N'سایر اضافات در برگشت از فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@OtherIncome,0) / @CurrencyRate
				
				IF [acc].[funIsCurrencyAcntCode] (@OtherIncomeAcntCode) = 'True'
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
						 @OtherIncomeAcntCode,0,ROUND(@OtherIncome,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
				--------------------------------------------------------------------------------------------------------

				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,ROUND(@OtherIncome,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),pub.funReverseForCrystal(@DescHdr),0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)
				
			END		
			
		-------------------------------------------------سایر هزینه ها در فروش---------------------------------------
		IF @OtherCostAcntCode <> '' AND @OtherCost <> 0
		BEGIN
			DECLARE @strRecDescOtherCost VARCHAR(1000) 
			
			SET @strRecDescOtherCost = 'سایر هزینه ها در برگشت از فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@OtherCostAcntCode,ROUND(@OtherCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			--------------------------------------------------------------------------------------------------------
			if @AllowOtherIncomeInDtl ='False'  OR @TotalSale2Account = 'False'
				BEGIN
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
			
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,0,ROUND(@OtherCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)
				END
		END

			----- هزینه تبلیغات
	IF @AdvertisingCostAcntCode <> '' AND @AdvertisingReserveAcntCode <>'' AND @AdvertisingPercent <> 0 AND @AmountHdr>0
		BEGIN


			SELECT @AdvertisingReserveAcntCode = RTRIM(@AdvertisingReserveAcntCode) + SUBSTRING(@AcntCode,LEN(@AdvertisingReserveAcntCode)+1,20)

			DECLARE @strAdvertising VARCHAR(1000) 
			SET @strAdvertising = ' هزینه تبلیغات در برگشت از فروش' + @strTitleSale + ' شماره' + @strFiscalSerial
			 
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
					 @AdvertisingReserveAcntCode ,ROUND((@AmountHdr*@AdvertisingPercent/100),@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strAdvertising)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @AdvertisingCostAcntCode,0,ROUND((@AmountHdr*@AdvertisingPercent/100),@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strAdvertising)),'',0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)

		END		
END
GO
