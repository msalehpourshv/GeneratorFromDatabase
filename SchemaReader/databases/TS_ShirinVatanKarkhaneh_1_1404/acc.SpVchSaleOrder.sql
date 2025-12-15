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
Create PROCEDURE [acc].[SpVchSaleOrder]
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
Declare @strTitleSale				NVarChar(100)
Declare @DescDtl					NVarChar(1000)
Declare @strRecDesc					NVarChar(1000)
Declare @strRecDesc2				NVarChar(1000)
DECLARE @strAcntName				NVarChar(500)
Declare @DescHdr					NVarChar(1000)
Declare @strFiscalSerial			VarChar(20)
Declare @AcntCode					Varchar(20)
DECLARE @SaleOrderAcntCode			VARCHAR(20)
DECLARE @SaleOrderAcntCodeSetting	VARCHAR(20)
Declare @DiscountAcntCode			Varchar(20)
Declare @StoreID					Varchar(20)
Declare @SaleTypeID					Varchar(20)
Declare @CurrencyTypeID				VarChar(20)
declare @PriceDecimalsToForms		tinyint
Declare @CurrencyRate				Float
Declare @CurrencyAmount				Float
Declare @SumGoodsPrice				Float
Declare @Discount					Float
Declare @Discount2					FLOAT
Declare @CurrencyDiscount			FLOAT
DECLARE @TotalDiscount				FLOAT
Declare @TotalLineDiscount			FLOAT
DECLARE @SalAcntNameInVoucherDesc   BIT
DECLARE @SaleAcntCodeInSaleTypes	BIT
DECLARE @ShowSaleDiscountInBill		BIT		
declare @Sal_IncomeAndCostAccountFillFromCustomer BIT
Declare @EarnestMoneyAcntCode		Varchar(20)
Declare @EarnestMoney			Float
Declare @EarnestMoneyPercent	Float

Declare @CurrencyRateTmp			Float
Declare @CurrencyAmountTmp			Float
Declare @CurrencyTypeIDTmp			VarChar(20)
Declare @SaleTaxOverWorthAcntCode	Varchar(20)
Declare @SaleTollOverWorthAcntCode  Varchar(20)
Declare @TaxOverWorthCost			Float
Declare @TollOverWorthCost			Float
DECLARE @DiscountTaxOverWorth		BIT		
DECLARE @sal_SaleOrderForTaxTollCreateVoucher BIT			
Declare @Sal_TaxAcntCompletWithCustCode bit

select @Sal_TaxAcntCompletWithCustCode=SettingValue from pub.tblSettings where SettingKey='Sal_TaxAcntCompletWithCustCode'

SET @CurrencyTypeID = ''
SET @CurrencyRate = 0 	
SET @CurrencyAmount = 0
SET @CurrencyRateTmp = 0
SET @CurrencyAmountTmp = 0
SET @CurrencyTypeIDTmp = ''
--------------------------------------------------------------------------------------------------------
	SELECT	@SaleTypeID = SaleTypeID,@DescHdr= DocDesc,@StoreID=StoreID,@AcntCode=AcntCode
   		   ,@Discount =Discount , @Discount2 =Discount2  ,@TotalLineDiscount=TotalLineDiscount
		   ,@CurrencyRate=CurrencyRate,@CurrencyTypeID=CurrencyTypeID, @CurrencyDiscount =CurrencyDiscount
		   ,@EarnestMoney=EarnestMoney,@EarnestMoneyPercent=EarnestMoneyPercent,@EarnestMoneyAcntCode=EarnestMoneyAcntCode
		   ,@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost,@DiscountTaxOverWorth=DiscountTaxOverWorth
	FROM sal.tblSaleOrderHdr
	WHERE ProcessID=@intSourceProcessID AND ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND SerialNo=@intSourceSerialNo 		
	--------------------------------------------------------------------------------------------------------
	SET @strTitleSale = ''
	SET @SaleOrderAcntCode = ''
	SET @SaleOrderAcntCodeSetting = ''
	
	--------------------------------------------------------------------------------------------------------
	SELECT @strTitleSale = SettingValue								FROM pub.tblSettings WHERE SettingKey = 'TitleSale' + LTRIM(RTRIM(STR(@intSourceProcessNo)))
	SELECT @SalAcntNameInVoucherDesc = SettingValue					FROM pub.tblSettings WHERE SettingKey = 'SalAcntNameInVoucherDesc'	
	SELECT @PriceDecimalsToForms=SettingValue						FROM pub.tblSettings where SettingKey='PriceDecimalsToForms'				
	SELECT @Sal_IncomeAndCostAccountFillFromCustomer = SettingValue FROM pub.tblSettings WHERE SettingKey = 'Sal_IncomeAndCostAccountFillFromCustomer' 
	SELECT @ShowSaleDiscountInBill = SettingValue					FROM pub.tblSettings WHERE SettingKey = 'ShowSaleDiscountInBill'
	SELECT @SaleAcntCodeInSaleTypes = SettingValue					FROM pub.tblSettings WHERE SettingKey = 'SaleAcntCodeInSaleTypes' 
	SELECT @SaleOrderAcntCodeSetting = SettingValue 				FROM pub.tblSettings WHERE SettingKey = 'SaleOrderAcntCode'
	SELECT @sal_SaleOrderForTaxTollCreateVoucher = SettingValue 	FROM pub.tblSettings WHERE SettingKey = 'sal_SaleOrderForTaxTollCreateVoucher'
	
	SET @ShowSaleDiscountInBill=ISNULL(@ShowSaleDiscountInBill,1)	
	
	IF @SaleAcntCodeInSaleTypes = 'False'
		SELECT	@SaleOrderAcntCode=SaleAcntCode,@DiscountAcntCode=SaleDiscountAcntCode,
				@SaleTaxOverWorthAcntCode=SaleTaxOverWorthAcntCode,@SaleTollOverWorthAcntCode=SaleTollOverWorthAcntCode	
		FROM inv.tblStores WHERE StoreID = @StoreID
	ELSE
		SELECT @SaleOrderAcntCode=SaleAcntCode,@DiscountAcntCode=SaleDiscountAcntCode,
				@SaleTaxOverWorthAcntCode=SaleTaxOverWorthAcntCode,@SaleTollOverWorthAcntCode=SaleTollOverWorthAcntCode	
		FROM sal.tblSaleTypes WHERE SaleTypeID = @SaleTypeID
--------------------------------------------------------------------------------------------------------
	IF @SalAcntNameInVoucherDesc = 'True'
			Select @strAcntName = ' به ' + [pub].GetCodeName(@AcntCode, @LanguageID)
		ELSE
			SET @strAcntName = ''

	SET  @TotalDiscount = @Discount + @Discount2 + @CurrencyDiscount+@TotalLineDiscount
	IF @DiscountTaxOverWorth = 'True'
		SET @TotalDiscount = @TotalDiscount + @TaxOverWorthCost + @TollOverWorthCost

	IF	@SaleOrderAcntCodeSetting<>''
		SET @SaleOrderAcntCode=@SaleOrderAcntCodeSetting

	SET @SaleOrderAcntCode = RTRIM(@SaleOrderAcntCode) + SUBSTRING(@AcntCode ,LEN(@SaleOrderAcntCode)+1,20)
	
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
	-- مقرر شد پس از گفتگوی مهندس با آقای جودی ادامه داده شود 
		--درخواست 914 و1516		
	IF @SaleTaxOverWorthAcntCode='' AND @TaxOverWorthCost <>0  and  @sal_SaleOrderForTaxTollCreateVoucher='True'
			BEGIN
				--کد مالیات بر ارزش افزوده در فروش خالی است
				SET @strMsgText=TS.pub.funGetMessages(11039,@LanguageID)
				Raiserror (@strMsgText,16,1)
				Return
			END
-- مقرر شد پس از گفتگوی مهندس با آقای جودی ادامه داده شود 
		--درخواست 914 و1516		
	IF @SaleTollOverWorthAcntCode='' AND @TollOverWorthCost <>0  and  @sal_SaleOrderForTaxTollCreateVoucher='True'
			BEGIN
				--کد عوارض بر ارزش افزوده در فروش خالی است
				SET @strMsgText=TS.pub.funGetMessages(11043,@LanguageID)
				Raiserror (@strMsgText,16,1)
				Return
			END			
	--------------------------------------------------------------------------------------------------------
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
	SET @strRecDesc=N'سفارش فروش ' +  @strTitleSale + N' شماره' + @strFiscalSerial+ @strAcntName
	------------------------------------------------ سفارش فروش --------------------------------------------------------
	
	SELECT	@SumGoodsPrice = SUM(GoodsQuantity * GoodsPrice)
	FROM sal.tblSaleOrderDtl
	WHERE ProcessID=@intSourceProcessID AND ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND SerialNo=@intSourceSerialNo	   

	----- اگر تخفیف از جمع فروش کسر نمیشود
	IF @ShowSaleDiscountInBill = 0
	BEGIN
		
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = (@SumGoodsPrice-@TotalDiscount)/ @CurrencyRate
		
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

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
	
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID)
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,ROUND(@SumGoodsPrice-@TotalDiscount+ Case when  @sal_SaleOrderForTaxTollCreateVoucher='True' then @TaxOverWorthCost+@TollOverWorthCost else 0 end ,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	
	
		IF @Sal_IncomeAndCostAccountFillFromCustomer=1
			SET @DiscountAcntCode = RTRIM(@DiscountAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@DiscountAcntCode))+1,20)
		IF @DiscountAcntCode is null OR @DiscountAcntCode = ''
		BEGIN
			SET @strMsgText=TS.pub.funGetMessages(11040,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END	

		SET @strRecDesc2 = ' تخفیف سفارش فروش  ' + @strTitleSale + @strFiscalSerial + @strAcntName
		
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = @TotalDiscount/ @CurrencyRate
		
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
		
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		---  مقرر شد به جای @@DiscountAcntCode  
		---از @SaleOrderAcntCode
		---استفاده شود تا تخفیفات دوباره به حساب تخفیف نرود بار اول در سفارش و بار دوم در فروش
						
		INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@SaleOrderAcntCode,ROUND(@TotalDiscount,@PriceDecimalsToForms),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
	
		set @TotalDiscount=0
	end
else
	BEGIN

		
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = @SumGoodsPrice/ @CurrencyRate
		
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

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
	
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID)
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,ROUND(@SumGoodsPrice+ Case when  @sal_SaleOrderForTaxTollCreateVoucher='True' then @TaxOverWorthCost+@TollOverWorthCost else 0 end ,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	

	end
IF  (@TotalDiscount) <> 0
	BEGIN

		IF @Sal_IncomeAndCostAccountFillFromCustomer=1
			SET @DiscountAcntCode = RTRIM(@DiscountAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@DiscountAcntCode))+1,20)
		IF @DiscountAcntCode is null OR @DiscountAcntCode = ''
		BEGIN
			SET @strMsgText=TS.pub.funGetMessages(11040,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END	

		SET @strRecDesc2 = ' تخفیف سفارش فروش  ' + @strTitleSale + @strFiscalSerial + @strAcntName
	
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = @TotalDiscount/ @CurrencyRate
		
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
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		---  مقرر شد به جای @@DiscountAcntCode  
		---از @SaleOrderAcntCode
		---استفاده شود تا تخفیفات دوباره به حساب تخفیف نرود بار اول در سفارش و بار دوم در فروش

		INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@SaleOrderAcntCode,ROUND(@TotalDiscount,@PriceDecimalsToForms),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = @TotalDiscount/ @CurrencyRate
		
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

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
				
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,0 ,ROUND(@TotalDiscount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),
					TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )

	END

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = @SumGoodsPrice/ @CurrencyRate
		
		IF [acc].[funIsCurrencyAcntCode] (@SaleOrderAcntCode) = 'True'
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

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID)
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @SaleOrderAcntCode ,0,ROUND(@SumGoodsPrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	

			-----------------------------------------------مالیات بر ارزش افزوده--------------------------------------------
		-- مقرر شد پس از گفتگوی مهندس با آقای جودی ادامه داده شود 
		--درخواست 914 و1516
	IF @SaleTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0 and @sal_SaleOrderForTaxTollCreateVoucher='True'
		BEGIN
			--------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescTaxOverWorth VARCHAR(1000) 
			SET @strRecDescTaxOverWorth = ' مالیات بر ارزش افزوده سفارش فروش  ' + @strTitleSale + @strFiscalSerial + @strAcntName
			
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
		
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 				SELECT @SaleTaxOverWorthAcntCode = [pub].[funMergCode](@SaleTaxOverWorthAcntCode,@AcntCode)

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@SaleTaxOverWorthAcntCode,0,ROUND(@TaxOverWorthCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0,@CurrencyAmount,@CurrencyTypeID,2)
			
		END

		----------------------------------------------عوارض بر ارزش افزوده--------------------------------------------
		-- مقرر شد پس از گفتگوی مهندس با آقای جودی ادامه داده شود 
		--درخواست 914 و1516
		IF @SaleTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0 and @sal_SaleOrderForTaxTollCreateVoucher='True'
			BEGIN
				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescTollOverWorth VARCHAR(1000) 
				SET @strRecDescTollOverWorth = ' عوارض بر ارزش افزوده سفارش فروش  ' + @strTitleSale + @strFiscalSerial + @strAcntName
				
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
								
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 					SELECT @SaleTollOverWorthAcntCode = [pub].[funMergCode](@SaleTollOverWorthAcntCode,@AcntCode)

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,BaseID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@SaleTollOverWorthAcntCode,0,ROUND(@TollOverWorthCost,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0,@CurrencyAmount,3)
			END

	----------------------------------------------- پیش دریافت --------------------------------------------
		IF @EarnestMoneyAcntCode <> '' AND @EarnestMoney <> 0
		BEGIN

			DECLARE @strRecDescEarnestMoney VARCHAR(1000) 
			SET @strRecDescEarnestMoney = ' پیش دریافت سفارش فروش  ' + @strTitleSale + @strFiscalSerial + @strAcntName
			
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
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@EarnestMoneyAcntCode,ROUND(@EarnestMoney,@PriceDecimalsToForms) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescEarnestMoney)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,0,ROUND(@EarnestMoney,@PriceDecimalsToForms)  ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescEarnestMoney)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
	END
			
END
GO
