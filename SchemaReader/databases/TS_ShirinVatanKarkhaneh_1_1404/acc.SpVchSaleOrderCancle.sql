USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1401/07-20
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchSaleOrderCancle]
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

Declare @CurrencyRateTmp			Float
Declare @CurrencyAmountTmp			Float
Declare @CurrencyTypeIDTmp			VarChar(20)
	

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

	SET @ShowSaleDiscountInBill=ISNULL(@ShowSaleDiscountInBill,1)		
	
	IF @SaleAcntCodeInSaleTypes = 'False'
			SELECT	@SaleOrderAcntCode=SaleAcntCode,@DiscountAcntCode=SaleDiscountAcntCode	FROM inv.tblStores WHERE StoreID = @StoreID
		ELSE
			SELECT @SaleOrderAcntCode=SaleAcntCode,@DiscountAcntCode=SaleDiscountAcntCode	FROM sal.tblSaleTypes WHERE SaleTypeID = @SaleTypeID
	--------------------------------------------------------------------------------------------------------
	IF @SalAcntNameInVoucherDesc = 'True'
			Select @strAcntName = ' به ' + [pub].GetCodeName(@AcntCode, @LanguageID)
		ELSE
			SET @strAcntName = ''

	SET  @TotalDiscount = @Discount + @Discount2 + @CurrencyDiscount+@TotalLineDiscount

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
	--------------------------------------------------------------------------------------------------------
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
	SET @strRecDesc=N'انصراف سفارش فروش ' +  @strTitleSale + N' شماره' + @strFiscalSerial+ @strAcntName
	------------------------------------------------ سفارش فروش --------------------------------------------------------
	
	SELECT	@SumGoodsPrice = SUM(GoodsQuantity * GoodsPrice)
	FROM sal.tblSaleOrderDtl
	WHERE ProcessID=@intSourceProcessID AND ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND SerialNo=@intSourceSerialNo	   
	


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
			 @SaleOrderAcntCode ,ROUND(@SumGoodsPrice,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	

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
	
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID)
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,0,ROUND(@SumGoodsPrice-@TotalDiscount,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	
	
		IF @Sal_IncomeAndCostAccountFillFromCustomer=1
			SET @DiscountAcntCode = RTRIM(@DiscountAcntCode) + SUBSTRING(@AcntCode,LEN(RTRIM(@DiscountAcntCode))+1,20)
		IF @DiscountAcntCode is null OR @DiscountAcntCode = ''
		BEGIN
			SET @strMsgText=TS.pub.funGetMessages(11040,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END	

		SET @strRecDesc2 = ' تخفیف انصراف سفارش فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
		
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
		

								
		INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo-1 ,@intMaxDocRowNo-1,
					@DiscountAcntCode,0,ROUND(@TotalDiscount,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
	
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
					@AcntCode ,0,ROUND(@SumGoodsPrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	

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

		SET @strRecDesc2 = ' تخفیف انصراف سفارش فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName
	
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
				
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode ,ROUND(@TotalDiscount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),
					TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@DiscountAcntCode,0,ROUND(@TotalDiscount,@PriceDecimalsToForms) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
	
	END

	

END
GO
