USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 86/11/23
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchBuy_Sum]
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
Declare @strBuyTitle				NVarChar(100)
Declare @SumAtomAmount				Float
Declare @BuyTaxOverWorthAcntCode	Varchar(20)
Declare @BuyTollOverWorthAcntCode	Varchar(20)
Declare @BuyDiscountAcntCode		Varchar(20)
Declare @BuyPenaltyAcntCode 		Varchar(20)
Declare @TransportationCostAcntCode	Varchar(20)
Declare @TransportationIncomeAcntCode Varchar(20)
Declare @StockAcntCode				Varchar(20)
Declare @StoreID					Varchar(20)
Declare @AcntCode					Varchar(20)
Declare @AtomAcntCode				Varchar(20)
Declare @OtherCostAcntCode			Varchar(20)
Declare @OtherIncomeAcntCode		Varchar(20)
Declare @EarnestMoneyAcntCode		Varchar(20)

Declare @SumPrice					Float
Declare @SumServicePrice			Float
Declare @SumAtom					Float
Declare @AtomAmount					Float
Declare @GoodsQuantity				Float
Declare @Discount					Float
Declare @Discount2					Float
Declare @TaxOverWorthCost_S			Float
Declare @TollOverWorthCost_S		Float
Declare @OtherCost					Float
Declare @OtherCost_S				Float
Declare @OtherIncome				Float
Declare @OtherIncome_S				Float
Declare @EarnestMoney				Float
Declare @EarnestMoney_S				Float
Declare @TotalLineDiscount			Float
Declare @TotalLinePenalty			Float
Declare @TransportationCost			Float
Declare @TransportationCost_S		Float
Declare @TransportationIncome		Float
Declare @TransportationIncome_S		Float
Declare @DocDate					VarChar(10)
Declare @DocDate2					VarChar(10)
Declare @AtomDesc					NVarChar(1000)
Declare @strRecDesc					NVarChar(1000)
Declare @DescHdr					NVarChar(1000)
DECLARE @TotalBuy2Account			BIT		
Declare @GoodsPrice					Float
Declare @ConstText1					VarChar(10)
Declare @ConstText2					VarChar(10)
Declare @ConstText3					VarChar(10)
Declare @ConstText4					VarChar(10)
Declare @CurrencyRate				Float
Declare @CurrencyAmount				FLOAT
Declare @CurrencyRate_Atom			Float
Declare @CurrencyAmount_Atom		FLOAT
Declare @ComssionCostPrice_S		Float
Declare @BasculePrice				FLOAT
Declare @LaborPrice					Float
Declare @TransportPrice				FLOAT
Declare @strFiscalSerial			NVarChar(70)
Declare @DescDtl					NVarChar(1000)
Declare @GoodsName					NVarChar(1000)
Declare @GoodsUnit					NVarChar(1000)
Declare @strRecDesc2				NVarChar(1000)
Declare @strDocDateIfDifference		NVarChar(1000)
Declare @strAgreeNo					VarChar(20)
Declare @CurrencyTypeID				VarChar(20)
Declare @CurrencyTypeID_Atom		VarChar(20)
Declare @ComssionCostPriceAcntCode	VarChar(20)
Declare @BasculePriceAcntCode		VarChar(20)
Declare @LaborPriceAcntCode			VarChar(20)
Declare @TransportPriceAcntCode		VarChar(20)
Declare	@intStartTmpMaxRowNo		Int
Declare @intStartTmpMaxDocRowNo		Int
Declare	@intTmpMaxRowNo				Int
Declare @intTmpMaxDocRowNo			Int
Declare @BaseProcessID				Int
Declare @BaseSerialNo				Int
DECLARE @CMRDescInBuyVoucher		BIT
DECLARE @SumSameAtomAcntCode		BIT
DECLARE @TaxOverWorthViewInBuy		BIT
DECLARE @VirtualQuantity			BIT

DECLARE @BuyAcntNameInVoucherDesc   BIT
DECLARE @buy_AddConstText1ToGoodsPrice   BIT
DECLARE @buy_AddConstText2ToGoodsPrice   BIT
DECLARE @buy_AddConstText3ToGoodsPrice   BIT
DECLARE @buy_AddConstText4ToGoodsPrice   BIT

DECLARE @strAcntName				NVarChar(500)
Declare @OtherDeductionsDescInBuy	NVarChar(500)

Declare @CurrencyRateTmp			Float
Declare @CurrencyAmountTmp			Float
Declare @CurrencyTypeIDTmp			VarChar(20)
Declare @Buy_TaxAcntCompletWithCustCode bit
--------------------------------------------------------------------------------------------------------
SET	@Discount = 0
SET @Discount2 = 0				
SET @SumAtomAmount = 0
SET @SumPrice = 0
SET @SumServicePrice = 0
SET @SumAtom = 0
SET @TotalLineDiscount = 0
SET @TotalLinePenalty= 0
SET @CurrencyRate = 0
SET @CurrencyAmount = 0
SET @CurrencyRate_Atom = 0
SET @CurrencyAmount_Atom = 0
SET @CMRDescInBuyVoucher = 'False'
SET @SumSameAtomAcntCode = 'False'
SET @GoodsQuantity = 0
SET @buy_AddConstText1ToGoodsPrice   = 'False'
SET @buy_AddConstText2ToGoodsPrice   = 'False'
SET @buy_AddConstText3ToGoodsPrice   = 'False'
SET @buy_AddConstText4ToGoodsPrice   = 'False'

----- 	
SET @CurrencyTypeID = ''
SET @CurrencyTypeID_Atom = ''

SET @CurrencyRateTmp = 0
SET @CurrencyAmountTmp = 0
SET @CurrencyTypeIDTmp = ''

SET @strBuyTitle = ''
DECLARE @UnitPart TINYINT
SET @UnitPart  = 1

select @Buy_TaxAcntCompletWithCustCode=SettingValue from pub.tblSettings where SettingKey='Buy_TaxAcntCompletWithCustCode'

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

SELECT @strBuyTitle = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'TitleBuy' + LTRIM(RTRIM(STR(@intSourceProcessNo)))

SELECT @CMRDescInBuyVoucher = SettingValue
FROM   pub.tblSettings
WHERE SettingKey = 'CMRDescInBuyVoucher' 	

SELECT @SumSameAtomAcntCode = SettingValue
FROM   pub.tblSettings
WHERE SettingKey = 'SumSameAtomAcntCode'

SELECT @TaxOverWorthViewInBuy = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'TaxOverWorthViewInBuy' 

SELECT @ComssionCostPriceAcntCode = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'comssionCostBuy' 

SELECT @BasculePriceAcntCode = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'BasculCostBuy' 

SELECT @LaborPriceAcntCode = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'LaborCostBuy' 

SELECT @TransportPriceAcntCode = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'TransportCostBuy' 

SELECT @BuyAcntNameInVoucherDesc = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'BuyAcntNameInVoucherDesc'

SET @OtherDeductionsDescInBuy = ''

SELECT @OtherDeductionsDescInBuy = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'OtherDeductionsDescInBuy'

SELECT @VirtualQuantity = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'Buy_PayWithVirtualQuantity' 

SELECT @buy_AddConstText1ToGoodsPrice = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'buy_AddConstText1ToGoodsPrice' 

SELECT @buy_AddConstText2ToGoodsPrice = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'buy_AddConstText2ToGoodsPrice' 

SELECT @buy_AddConstText3ToGoodsPrice = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'buy_AddConstText3ToGoodsPrice' 

SELECT @buy_AddConstText4ToGoodsPrice = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'buy_AddConstText4ToGoodsPrice' 


SELECT  @TotalLineDiscount=SUM(TotalLineDiscount),@Discount=SUM(Discount),@Discount2=SUM(Discount2)+SUM(Discount3),
        @TaxOverWorthCost_S=SUM(TaxOverWorthCost),@TollOverWorthCost_S=SUM(TollOverWorthCost),
		@EarnestMoney_S=SUM(EarnestMoney),@OtherCost_S=SUM(OtherCost),@OtherIncome_S=SUM(OtherIncome),
		@ComssionCostPrice_S=SUM(ComssionCostPrice),@BasculePrice=SUM(BasculePrice),
		@LaborPrice=SUM(LaborPrice),@TransportPrice=SUM(TransportPrice),
		@TransportationCost_S=SUM(TransportationCost),@TransportationIncome_S=SUM(TransportationIncome)
FROM inv.tblStorageDocsHdr
WHERE ProcessID=55 AND
  ProcessNo=@intSourceProcessNo AND
  FiscalYear=@intSourceFiscalYear AND
  SerialNo IN (
			  select BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )


SELECT TOP 1 @StoreID=StoreID,@AcntCode=AcntCode,@strAgreeNo=AgreeNo,@DocDate2=DocDate2,
        @CurrencyRate=CurrencyRate,@CurrencyTypeID=CurrencyTypeID
FROM inv.tblStorageDocsHdr
WHERE ProcessID=55 AND
  ProcessNo=@intSourceProcessNo AND
  FiscalYear=@intSourceFiscalYear AND
  SerialNo IN (
			  select BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )


SELECT @StockAcntCode=StockAcntCode, 
       @BuyDiscountAcntCode=BuyDiscountAcntCode, 
       @BuyPenaltyAcntCode=BuyPenaltyAcntCode, 
       @BuyTaxOverWorthAcntCode = BuyTaxOverWorthAcntCode,
       @BuyTollOverWorthAcntCode = BuyTollOverWorthAcntCode
FROM inv.tblStores 
WHERE StoreID = @StoreID

			  
SELECT @SumPrice = ROUND(SUM(case when @VirtualQuantity=1 then VirtualQuantity else  GoodsQuantity end * 
							 (s.GoodsPrice + Case When IsNumeric(ConstText1) = 1 AND @buy_AddConstText1ToGoodsPrice = 'True' Then ConstText1 Else 0 End +
											 Case When IsNumeric(ConstText2) = 1 AND @buy_AddConstText2ToGoodsPrice = 'True'  Then ConstText2 Else 0 End + 
											 Case When IsNumeric(ConstText3) = 1 AND @buy_AddConstText3ToGoodsPrice = 'True'  Then ConstText3 Else 0 End + 
											 Case When IsNumeric(ConstText4) = 1 AND @buy_AddConstText4ToGoodsPrice = 'True'  Then ConstText4 Else 0 End)),0)
		,@TotalLinePenalty=ISNULL(Sum(PenaltyPercent*s.GoodsQuantity*s.GoodsPrice/100 ),0)
FROM inv.tblStorageDocsDtl s
INNER JOIN inv.tblGoods g
ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID 
WHERE g.IsService='False' AND
	g.PartNumber=@UnitPart AND 
	ProcessID  = 55 AND
	ProcessNo  = @intSourceProcessNo AND
	FiscalYear = @intSourceFiscalYear AND
	SerialNo   IN (
			  select BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )


SELECT @SumServicePrice = ROUND(SUM(case when @VirtualQuantity=1 then VirtualQuantity else GoodsQuantity end * 
									(s.GoodsPrice + Case When IsNumeric(ConstText1) = 1 AND @buy_AddConstText1ToGoodsPrice = 'True'  Then ConstText1 Else 0 End +
											 		Case When IsNumeric(ConstText2) = 1 AND @buy_AddConstText2ToGoodsPrice = 'True'  Then ConstText2 Else 0 End + 
											 		Case When IsNumeric(ConstText3) = 1 AND @buy_AddConstText3ToGoodsPrice = 'True'  Then ConstText3 Else 0 End + 
											 		Case When IsNumeric(ConstText4) = 1 AND @buy_AddConstText4ToGoodsPrice = 'True'  Then ConstText4 Else 0 End)),0)
FROM inv.tblStorageDocsDtl s
INNER JOIN inv.tblGoods g
ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
WHERE g.IsService='True' AND 
	g.PartNumber=@UnitPart AND 
	ProcessID  = 55 AND
	ProcessNo  = @intSourceProcessNo AND
	FiscalYear = @intSourceFiscalYear AND
	SerialNo   IN (
			  select BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )

SET @SumPrice  = ISNULL (@SumPrice, 0)
SET @SumServicePrice  = ISNULL (@SumServicePrice, 0)



SET @strDocDateIfDifference = ''

IF 	@CMRDescInBuyVoucher = 'True' AND @BaseSerialNo <> 0
BEGIN
IF  @BaseProcessID = 150
	SET @strDocDateIfDifference = ' -  درخواست خرید' + LTRIM(RTRIM(STR(@BaseSerialNo))) 
ELSE IF @BaseProcessID = 160
	SET @strDocDateIfDifference = ' - سفارش خرید' + LTRIM(RTRIM(STR(@BaseSerialNo))) 
ELSE IF @BaseProcessID = 160
	SET @strDocDateIfDifference = ' - رسید موقت ' + LTRIM(RTRIM(STR(@BaseSerialNo))) 
END	

IF @DocDate2<>'' AND @DocDate <> @DocDate2
SET @strDocDateIfDifference = ' مورخه ' + @DocDate


IF @StockAcntCode=''
BEGIN
	--کد موجودی کالا خالی است
	SET @strMsgText=TS.pub.funGetMessages(11001,@LanguageID)
	Raiserror (@strMsgText,16,1)
	Return
END

IF @BuyDiscountAcntCode='' AND ( @Discount<>0 OR @Discount2<>0 OR @TotalLineDiscount <>0)
BEGIN
	--کد تخفیفات خرید خالی است
	SET @strMsgText=TS.pub.funGetMessages(11030,@LanguageID)
	Raiserror (@strMsgText,16,1)
	Return
END
	if @TotalLinePenalty is null
		set @TotalLinePenalty=0

IF @BuyPenaltyAcntCode='' AND  @TotalLinePenalty <>0
BEGIN
	--کد تخفیفات خرید خالی است
	SET @strMsgText='کد جریمه تایید مشروط و ارفاقی در خرید خالی است'--TS.pub.funGetMessages(11030,@LanguageID)
	Raiserror (@strMsgText,16,1)
	Return
END



IF @BuyTaxOverWorthAcntCode='' AND @TaxOverWorthCost_S <>0
BEGIN
	--کد مالیات بر ارزش افزوده در خرید خالی است
	SET @strMsgText=TS.pub.funGetMessages(11038,@LanguageID)
	Raiserror (@strMsgText,16,1)
	Return
END

IF @BuyTollOverWorthAcntCode='' AND @TollOverWorthCost_S <>0
BEGIN
	--کد عوارض بر ارزش افزوده در خرید خالی است
	SET @strMsgText=TS.pub.funGetMessages(11042,@LanguageID)
	Raiserror (@strMsgText,16,1)
	Return
END

-----
SELECT @SumAtomAmount=SUM(ROUND(AtomAmount,0))
FROM inv.tblStorageDocsDtl
WHERE ProcessID=55 AND
  ProcessNo=@intSourceProcessNo AND
  FiscalYear=@intSourceFiscalYear AND
  SerialNo IN (
			  select BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )

-----

SET @strFiscalSerial =' به شماره فاکتور خرید ' +  @strAgreeNo + ' - ' + @strBuyTitle 

IF @BuyAcntNameInVoucherDesc = 'True'
	Select @strAcntName = ' از ' + [pub].GetCodeName(@AcntCode, @LanguageID)
ELSE
	SET @strAcntName = ''

SET @strRecDesc = ' خرید شماره' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName

-- جمع کالاهای خرید بدهکار شود؟
SELECT @TotalBuy2Account = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'TotalBuy2Account'

-----
SET @intMaxDocRowNo = @intMaxDocRowNo + 1
SET @intMaxRowNo = @intMaxRowNo + 1

SET	@intTmpMaxRowNo = @intMaxRowNo 
SET	@intTmpMaxDocRowNo = @intMaxDocRowNo 

----- 'آيا تخفيف از جمع فاکتور در خريد کسر شود يا نه ؟ بله = 1 خير = 0 
DECLARE @BuyDiscountVoucherMethod Bit

SELECT @BuyDiscountVoucherMethod=SettingValue
FROM pub.tblSettings
WHERE SettingKey='BuyDiscountVoucherMethod'

SET @BuyDiscountVoucherMethod = ISNULL(@BuyDiscountVoucherMethod, 1)

--?????		

Declare	curStore CURSOR For

SELECT	s.StoreID, g.StockAcntCode, 
		ROUND(sum((s.GoodsPrice + Case When IsNumeric(ConstText1) = 1  AND @buy_AddConstText1ToGoodsPrice = 'True' Then ConstText1 Else 0 End +
								  Case When IsNumeric(ConstText2) = 1  AND @buy_AddConstText2ToGoodsPrice = 'True' Then ConstText2 Else 0 End + 
								  Case When IsNumeric(ConstText3) = 1  AND @buy_AddConstText3ToGoodsPrice = 'True' Then ConstText3 Else 0 End + 
								  Case When IsNumeric(ConstText4) = 1  AND @buy_AddConstText4ToGoodsPrice = 'True' Then ConstText4 Else 0 End) * 
				Case When @VirtualQuantity=1 Then s.VirtualQuantity Else  s.GoodsQuantity End),0)
FROM inv.tblStorageDocsDtl s
INNER JOIN inv.tblStores g
ON s.StoreID=g.StoreID
INNER JOIN inv.tblGoods d
ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=d.GoodsID
WHERE d.IsService='False' AND  ProcessID=55 AND d.PartNumber=@UnitPart AND 
  ProcessNo=@intSourceProcessNo AND
  FiscalYear=@intSourceFiscalYear AND
  SerialNo IN (
			  SELECT BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  ) 
group by s.StoreID,g.StockAcntCode


Open curStore;

Fetch NEXT From curStore Into @StoreID,@StockAcntCode,@GoodsPrice

While (@@Fetch_Status = 0)
BEGIN
	-- سربار 
	SELECT	 @SumAtom= isnull(sum(a.AtomAmount*a.GoodsQuantity),0)
	FROM inv.tblStorageDocsDtl s
	INNER JOIN inv.tblStorageDocsAtom a
	ON s.ProcessID=a.ProcessID and s.ProcessNo=a.ProcessNo
	and s.FiscalYear=a.FiscalYear and s.SerialNo=a.SerialNo
	and s.DocRowNo=a.DocRowNo
	WHERE s.ProcessID=55 AND
	  s.ProcessNo=@intSourceProcessNo AND
	  s.FiscalYear=@intSourceFiscalYear AND
	  s.SerialNo  IN (
			  SELECT BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  ) AND
	  s.StoreID=@StoreID

-- سربار

SET @intMaxDocRowNo = @intMaxDocRowNo + 1
SET @intMaxRowNo = @intMaxRowNo + 1
	
IF @CurrencyRate <> 0 
	SET @CurrencyAmount = ROUND(@GoodsPrice + @SumAtom,0) / @CurrencyRate

IF [acc].[funIsCurrencyAcntCode] (@StockAcntCode) = 'True'
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
		 @StockAcntCode,ROUND(@GoodsPrice + @SumAtom,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)	

FETCH NEXT From curStore Into @StoreID,@StockAcntCode,@GoodsPrice
END -- curStore
Close curStore;
Deallocate curStore; 
--?????		

IF @TotalBuy2Account = 0
SET @BuyDiscountVoucherMethod = 0

IF @TotalBuy2Account = 1

BEGIN
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
END		

ELSE
BEGIN
declare @IsService as bit

Declare	curBuy CURSOR For 
 
SELECT	AcntCode, (s.GoodsPrice + Case When IsNumeric(ConstText1) = 1  AND @buy_AddConstText1ToGoodsPrice = 'True' Then ConstText1 Else 0 End +
								  Case When IsNumeric(ConstText2) = 1  AND @buy_AddConstText2ToGoodsPrice = 'True' Then ConstText2 Else 0 End + 
								  Case When IsNumeric(ConstText3) = 1  AND @buy_AddConstText3ToGoodsPrice = 'True' Then ConstText3 Else 0 End + 
								  Case When IsNumeric(ConstText4) = 1  AND @buy_AddConstText4ToGoodsPrice = 'True' Then ConstText4 Else 0 End) GoodsPrice , case when @VirtualQuantity=1 then VirtualQuantity else  GoodsQuantity end,DescDtl,pub.funGetGoodsName(s.GoodsID,@LanguageID) AS GoodsName,pub.funGetGoodsUnitName(s.GoodsID,@LanguageID) AS GoodsUnit,IsService
FROM inv.tblStorageDocsDtl s
INNER JOIN inv.tblGoods g
ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
WHERE ProcessID=55 AND  g.PartNumber=@UnitPart AND 
	  ProcessNo=@intSourceProcessNo AND
	  FiscalYear=@intSourceFiscalYear AND
	  SerialNo  IN (
			  SELECT BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  ) 

----- فاکتور خرید سطر به سطر به حساب مشتری میرود
SET @SumPrice = 0

Open curBuy;
	
Fetch NEXT From curBuy Into @AcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@GoodsUnit,@IsService

While (@@Fetch_Status = 0)
	BEGIN
		IF @GoodsPrice <> 0
			BEGIN

				SET @strRecDesc2 = ' خرید ' + @strBuyTitle + ' شماره ' + ISNULL(@strFiscalSerial,'') +  @strDocDateIfDifference + ' - ' + 
				    ISNULL(@GoodsName,'') + ' - ' + ISNULL(ltrim(rtrim(STR(@GoodsQuantity,LEN(@GoodsQuantity),3))),'') + ISNULL(@GoodsUnit,'') + ' - فی ' + 
				    ISNULL(ltrim(rtrim(str(@GoodsPrice))),'') + @strAcntName
			
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				
				IF @IsService = 'False'
					SET @SumPrice = @SumPrice + ROUND(@GoodsPrice * @GoodsQuantity,0)
				ELSE
					SET @strRecDesc2 = ' خرید ' + @strBuyTitle + ' شماره' + ISNULL(@strFiscalSerial,'') +  @strDocDateIfDifference + ' - خدمات ' + ISNULL(@GoodsName,'') + ' - ' + ISNULL(ltrim(rtrim(STR(@GoodsQuantity,LEN(@GoodsQuantity),3))),'') + ISNULL(@GoodsUnit,'') + ' - فی ' + ISNULL(ltrim(rtrim(str(@GoodsPrice))),'') + @strAcntName
				
				IF @CurrencyRate <> 0 AND @CurrencyTypeID <> ''
					SET @CurrencyAmount = ROUND(@GoodsPrice * @GoodsQuantity,0) / @CurrencyRate
					
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
						 @AcntCode,0,ROUND(@GoodsPrice * @GoodsQuantity,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)	
			end

		Fetch NEXT From curBuy Into @AcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@GoodsUnit,@IsService
	ENd

Close curBuy;
Deallocate curBuy; 	
END	

-----

IF @TotalBuy2Account = 0 AND @EarnestMoney_S <> 0
BEGIN
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	DECLARE @strRecDescEarnestMoney1 VARCHAR(1000) 
	SET @strRecDescEarnestMoney1 = ' پیش پرداخت خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strAcntName
	
	IF @CurrencyRate <> 0
		SET @CurrencyAmount = ROUND(@EarnestMoney_S,0) / @CurrencyRate
	
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
				@AcntCode,ROUND(@EarnestMoney_S,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescEarnestMoney1)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

END
-----
IF @BuyDiscountAcntCode<>'' AND (@Discount<>0 OR @Discount2<>0 OR @TotalLineDiscount <> 0)
BEGIN

	SET @strRecDesc=' تخفیف فاکتور خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName

	-----
	IF @BuyDiscountVoucherMethod = 0
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0
				SET @CurrencyAmount = ROUND(@Discount + @Discount2 + @TotalLineDiscount,0) / @CurrencyRate
			
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
					 @AcntCode,ROUND(@Discount + @Discount2 + @TotalLineDiscount,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)	
		END

	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	IF @CurrencyRate <> 0
		SET @CurrencyAmount = ROUND(@Discount + @Discount2 ,0) / @CurrencyRate
	 
	IF [acc].[funIsCurrencyAcntCode] (@BuyDiscountAcntCode) = 'True'
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
			 @BuyDiscountAcntCode,0,ROUND(@Discount + @Discount2 ,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)	
	
 

IF @TotalLineDiscount <> 0
BEGIN
	
	--??????
	
	Declare	@DiscountDtl as  float
	set @DiscountDtl=0
	
Declare	curLineDisc CURSOR For
 
	SELECT	s.StoreID,g.StockAcntCode,sum(s.DiscountDtl)
	FROM inv.tblStorageDocsDtl s
	INNER JOIN inv.tblStores g
	ON s.StoreID=g.StoreID
	WHERE ProcessID=55 AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo  IN (
			  SELECT BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  ) 
	group by s.StoreID,g.StockAcntCode


	Open curLineDisc;
		
	Fetch NEXT From curLineDisc Into @StoreID,@StockAcntCode,@DiscountDtl
	
	While (@@Fetch_Status = 0)
	 BEGIN
	
		SET @strRecDesc=' تخفیف سطری فاکتور خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName
		-----
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		IF @CurrencyRate <> 0
			SET @CurrencyAmount = ROUND( @TotalLineDiscount,0) / @CurrencyRate
		 
		IF [acc].[funIsCurrencyAcntCode] (@StockAcntCode) = 'True'
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
				 @StockAcntCode,0,ROUND(@DiscountDtl,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)	
	
		Fetch NEXT From curLineDisc Into @StoreID,@StockAcntCode,@DiscountDtl
	
	END -- curLineDisc
	Close curLineDisc;
	Deallocate curLineDisc; 

	 
	--??????
	
ENd
	
			
		
ENd
-------------------------------------------------جریمه   ---------------------------------------

-----
IF @BuyPenaltyAcntCode<>'' AND @TotalLinePenalty <> 0
BEGIN
	--??????
	
	Declare	@PenaltyPercent as  float
	set @PenaltyPercent=0
	
Declare	curLinePenalty CURSOR For
 
	SELECT PenaltyPercent*GoodsQuantity*GoodsPrice/100 
	FROM inv.tblStorageDocsDtl s
	WHERE ProcessID=55 AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo  IN (
			  SELECT BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )
	


	Open curLinePenalty;
		
	Fetch NEXT From curLinePenalty Into @PenaltyPercent
	
	While (@@Fetch_Status = 0)
	 BEGIN
	
		SET @strRecDesc=' جریمه تایید مشروط یا ارفاقی سطری فاکتور خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName
		-----
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		IF @CurrencyRate <> 0
			SET @CurrencyAmount = ROUND( @TotalLinePenalty,0) / @CurrencyRate
		 
		IF [acc].[funIsCurrencyAcntCode] (@BuyPenaltyAcntCode) = 'True'
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
				 @BuyPenaltyAcntCode,0,ROUND(@PenaltyPercent,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)	
	
		Fetch NEXT From curLinePenalty Into @PenaltyPercent
	
	END -- curLinePenalty
	Close curLinePenalty;
	Deallocate curLinePenalty; 

	 
	--??????
END
	
-----
IF @SumSameAtomAcntCode = 'False'
Declare	Cursor_BuyAtom CURSOR For 
SELECT	AtomAcntCode,CurrencyRate,CurrencyTypeID,(AtomAmount*GoodsQuantity) as Total,AtomDesc
FROM inv.tblStorageDocsAtom
WHERE ProcessID=55 AND
	  ProcessNo=@intSourceProcessNo AND
	  FiscalYear=@intSourceFiscalYear AND
	  SerialNo  IN (
			  SELECT BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  ) 
ELSE
Declare	Cursor_BuyAtom CURSOR For 
SELECT	AtomAcntCode,CurrencyRate,CurrencyTypeID,SUM(AtomAmount * GoodsQuantity) as Total,'' AtomDesc
FROM inv.tblStorageDocsAtom
WHERE ProcessID=55 AND
	  ProcessNo=@intSourceProcessNo AND
	  FiscalYear=@intSourceFiscalYear AND
	  SerialNo  IN (
			  SELECT BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )
GROUP BY AtomAcntCode,CurrencyRate,CurrencyTypeID
	  	
-----
SET @SumAtom = 0

Open  Cursor_BuyAtom; 

Fetch NEXT From Cursor_BuyAtom Into @AtomAcntCode,@CurrencyRate_Atom,@CurrencyTypeID_Atom,@AtomAmount,@AtomDesc

While (@@Fetch_Status = 0)
BEGIN

	SET @strRecDesc=' سربار خرید ' + @strBuyTitle + @strFiscalSerial + @strDocDateIfDifference + @strAcntName
	SET @strRecDesc= @strRecDesc + '  ' + @AtomDesc
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	SET @SumAtom = @SumAtom + ROUND(@AtomAmount ,0)
	
	IF @CurrencyRate_Atom <> 0
		SET @CurrencyAmount_Atom = ROUND(@AtomAmount ,0) / @CurrencyRate_Atom
	
	IF [acc].[funIsCurrencyAcntCode] (@AtomAcntCode) = 'True'
	Begin
		Set @CurrencyRateTmp	= @CurrencyRate_Atom
		Set @CurrencyAmountTmp  = @CurrencyAmount_Atom
		Set @CurrencyTypeIDTmp  = @CurrencyTypeID_Atom
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
			 @AtomAcntCode,0,ROUND(@AtomAmount ,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp)	

	Fetch NEXT From Cursor_BuyAtom Into @AtomAcntCode,@CurrencyRate_Atom,@CurrencyTypeID_Atom,@AtomAmount,@AtomDesc
	
END

Close Cursor_BuyAtom;
Deallocate Cursor_BuyAtom; 			

-----------
SET @strRecDesc='خرید ' + @strBuyTitle + ' شماره '  +  @strFiscalSerial + @strDocDateIfDifference + @strAcntName

IF @TotalBuy2Account = 1
BEGIN

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	
	Declare @SumPurePrice FLOAT

	Set @SumPurePrice = @SumPrice - @EarnestMoney_S
		
	IF @BuyDiscountVoucherMethod = 1
		SET @SumPurePrice = @SumPurePrice - (@Discount + @Discount2 + @TotalLineDiscount+@TotalLinePenalty)

	IF @TaxOverWorthViewInBuy = 'True'
		SET @SumPurePrice = @SumPurePrice + @TollOverWorthCost_S + @TaxOverWorthCost_S 
		
    SET @SumPurePrice  = @SumPurePrice + @SumServicePrice
		
	IF @CurrencyRate <> 0
		SET @CurrencyAmount = ROUND(@SumPurePrice,0) / @CurrencyRate
	
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
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo ,
				@AcntCode,0,ROUND(@SumPurePrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp)	

END				

	--------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------
	declare @RowNo int
	DECLARE @CostCenterAcntCode VARCHAR(30)
	
	Declare	curService CURSOR For 
	SELECT	g.CostCenterAcntCode,(s.GoodsPrice + Case When IsNumeric(ConstText1) = 1  AND @buy_AddConstText1ToGoodsPrice = 'True' Then ConstText1 Else 0 End +
												 Case When IsNumeric(ConstText2) = 1  AND @buy_AddConstText2ToGoodsPrice = 'True' Then ConstText2 Else 0 End + 
												 Case When IsNumeric(ConstText3) = 1  AND @buy_AddConstText3ToGoodsPrice = 'True' Then ConstText3 Else 0 End + 
												 Case When IsNumeric(ConstText4) = 1  AND @buy_AddConstText4ToGoodsPrice = 'True' Then ConstText4 Else 0 End) GoodsPrice, 
			SubUnitQuantity,DescDtl,pub.funGetGoodsName(s.GoodsID,@LanguageID) AS GoodsName,s.RowNo
	FROM inv.tblStorageDocsDtl s
	INNER JOIN inv.tblGoods g
	ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
	WHERE g.IsService = 'True' AND  g.PartNumber=@UnitPart AND 
		  ProcessID=55 AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo  IN (
			  SELECT BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )

		Open  curService; 
	
		Fetch NEXT From curService Into @CostCenterAcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@RowNo
	
		While (@@Fetch_Status = 0)
			BEGIN
				IF @GoodsPrice <> 0
					BEGIN

						SELECT	 @SumAtom= isnull(sum(a.AtomAmount*a.GoodsQuantity),0)
						FROM inv.tblStorageDocsDtl s
						INNER JOIN inv.tblStorageDocsAtom a
						ON s.ProcessID=a.ProcessID and s.ProcessNo=a.ProcessNo
						and s.FiscalYear=a.FiscalYear and s.SerialNo=a.SerialNo
						and s.DocRowNo=a.DocRowNo
						WHERE s.ProcessID=55 AND
						  s.ProcessNo=@intSourceProcessNo AND
						  s.FiscalYear=@intSourceFiscalYear AND
						  s.SerialNo  IN (
							  SELECT BaseSerialNo from inv.tblAfterBuyVoucherDtl
							  WHERE ProcessID  = @intSourceProcessID AND
									ProcessNo  = @intSourceProcessNo AND
									FiscalYear = @intSourceFiscalYear AND
									SerialNo   = @intSourceSerialNo
							  ) 
						  AND s.RowNo  = @RowNo

						SET @strRecDesc2 = ' خرید ' + @strBuyTitle + @strFiscalSerial + ' - خدمات ' + @GoodsName + ' - ' + ltrim(rtrim(STR(@GoodsQuantity,LEN(@GoodsQuantity),3)))  + ' - فی ' + ltrim(rtrim(str(@GoodsPrice))) + @strAcntName
								
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
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @CostCenterAcntCode,ROUND((@GoodsPrice * @GoodsQuantity)+@SumAtom,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp)	
					END
	
				Fetch NEXT From curService Into @CostCenterAcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@RowNo
			END
	
		Close curService;
		Deallocate curService; 
	--------------------------------------------------------------------------------------------------------

---------------------------------------

	IF @BuyTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost_S <> 0	
	BEGIN

		SET @strRecDesc=' مالیات بر ارزش افزوده فاکتور خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 AND @CurrencyTypeID <> ''
			SET @CurrencyAmount = ROUND(@TaxOverWorthCost_S,0) / @CurrencyRate
			
		IF [acc].[funIsCurrencyAcntCode] (@BuyTaxOverWorthAcntCode) = 'True'
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
		
		IF @Buy_TaxAcntCompletWithCustCode = 'True' 				
 				SELECT @BuyTaxOverWorthAcntCode = [pub].[funMergCode](@BuyTaxOverWorthAcntCode,@AcntCode)

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @BuyTaxOverWorthAcntCode,ROUND(@TaxOverWorthCost_S,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp)	
		
		IF (@TotalBuy2Account = 0 OR @TaxOverWorthViewInBuy = 'False')
			BEGIN	
				-----
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @AcntCode,0,ROUND(@TaxOverWorthCost_S,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID)	
			END
	END
 	
---------------------------------------
	IF @BuyTollOverWorthAcntCode <> '' AND @TollOverWorthCost_S <> 0	
	BEGIN

		SET @strRecDesc=' عوارض بر ارزش افزوده فاکتور خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0
			SET @CurrencyAmount = ROUND(@TollOverWorthCost_S,0) / @CurrencyRate
		
		IF [acc].[funIsCurrencyAcntCode] (@BuyTollOverWorthAcntCode) = 'True'
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
				
		IF @Buy_TaxAcntCompletWithCustCode = 'True' 				
	 		SELECT @BuyTollOverWorthAcntCode = [pub].[funMergCode](@BuyTollOverWorthAcntCode,@AcntCode)

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @BuyTollOverWorthAcntCode,ROUND(@TollOverWorthCost_S,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp)	

		IF (@TotalBuy2Account = 0 OR @TaxOverWorthViewInBuy = 'False')
			BEGIN	
				-----
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @AcntCode,0,ROUND(@TollOverWorthCost_S,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID)	
			END
	END
	
  
-------------------------------------------------سایر هزینه ها  ---------------------------------------
Declare	cur_OtherCost CURSOR For 

SELECT  OtherCostAcntCode,SUM(OtherCost) OtherCost
FROM inv.tblStorageDocsHdr
WHERE ProcessID=55 AND
  ProcessNo=@intSourceProcessNo AND
  FiscalYear=@intSourceFiscalYear AND
  SerialNo IN (
			  select BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )
GROUP BY OtherCostAcntCode			  
			  
		Open  cur_OtherCost; 
	
		Fetch NEXT From cur_OtherCost Into @OtherCostAcntCode,@OtherCost
	
		While (@@Fetch_Status = 0)
			BEGIN
			
				IF @OtherCostAcntCode <> '' AND @OtherCost <> 0
				BEGIN

					DECLARE @strRecDescOtherCost NVARCHAR(1000) 
					
					SET @strRecDescOtherCost = ' سایر اضافات در خرید ' + @strBuyTitle  + @strFiscalSerial + @strDocDateIfDifference + @strAcntName

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
								@OtherCostAcntCode,ROUND(@OtherCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),'' ,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
					
					--------------------------------------------------------------------------------------------------------
					IF @OtherCost_S <>0
					BEGIN
						IF @CurrencyRate <> 0
							SET @CurrencyAmount = ROUND(@OtherCost_S,0) / @CurrencyRate
						
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@AcntCode,0,ROUND(@OtherCost_S,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)) ,0,@CurrencyAmount,@CurrencyTypeID)
						SET @OtherCost_S =0
					END

				END
				Fetch NEXT From  cur_OtherCost Into @OtherCostAcntCode,@OtherCost
			END
	
		Close cur_OtherCost;
		Deallocate cur_OtherCost; 	
------------------------------------------------- سایر درآمد ها ---------------------------------------
Declare	cur_OtherIncome CURSOR For 

SELECT  OtherIncomeAcntCode,SUM(OtherIncome) OtherIncome
FROM inv.tblStorageDocsHdr
WHERE ProcessID=55 AND
  ProcessNo=@intSourceProcessNo AND
  FiscalYear=@intSourceFiscalYear AND
  SerialNo IN (
			  select BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )
GROUP BY OtherIncomeAcntCode			  
			  
		Open  cur_OtherIncome; 
	
		Fetch NEXT From cur_OtherIncome Into @OtherIncomeAcntCode,@OtherCost
	
		While (@@Fetch_Status = 0)
			BEGIN
				IF @OtherIncomeAcntCode <> '' AND @OtherIncome <> 0
				BEGIN

					DECLARE @strRecDescIncome NVARCHAR(1000) 
					
					IF @OtherDeductionsDescInBuy <> ''
						SET @strRecDescIncome = @OtherDeductionsDescInBuy + ' ' + @strBuyTitle  + @strFiscalSerial + @strDocDateIfDifference + @strAcntName
					ELSE
						SET @strRecDescIncome = ' سایر کسورات در خرید ' + @strBuyTitle  + @strFiscalSerial + @strDocDateIfDifference + @strAcntName

					--------------------------------------------------------------------------------------------------------
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
					IF @OtherIncome_S <>0
					BEGIN
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1		
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@AcntCode,ROUND(@OtherIncome_S,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
						SET @OtherIncome_S = 0			
					END
					--------------------------------------------------------------------------------------------------------
					IF @CurrencyRate <> 0
						SET @CurrencyAmount = ROUND(@OtherIncome,0) / @CurrencyRate

					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								@OtherIncomeAcntCode,0,ROUND(@OtherIncome,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),'' ,0,@CurrencyAmount,@CurrencyTypeID)
				END
				Fetch NEXT From  cur_OtherIncome Into @OtherIncomeAcntCode,@OtherCost
			END
	
		Close cur_OtherIncome;
		Deallocate cur_OtherIncome; 	
		
		
Declare	cur_EarnestMoney CURSOR For 

SELECT  EarnestMoneyAcntCode,SUM(EarnestMoney) EarnestMoney
FROM inv.tblStorageDocsHdr
WHERE ProcessID=55 AND
  ProcessNo=@intSourceProcessNo AND
  FiscalYear=@intSourceFiscalYear AND
  SerialNo IN (
			  select BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )
GROUP BY EarnestMoneyAcntCode			  
			  
		Open  cur_EarnestMoney; 
	
		Fetch NEXT From cur_EarnestMoney Into @EarnestMoneyAcntCode,@EarnestMoney
	
		While (@@Fetch_Status = 0)
			BEGIN

				-----
				IF @EarnestMoneyAcntCode <> '' AND @EarnestMoney <> 0
				BEGIN

					DECLARE @strRecDescEarnestMoney VARCHAR(1000) 
					SET @strRecDescEarnestMoney = ' پیش پرداخت خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strAcntName
					 
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
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @EarnestMoneyAcntCode,0,ROUND(@EarnestMoney,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescEarnestMoney)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

				END
				Fetch NEXT From  cur_EarnestMoney Into @EarnestMoneyAcntCode,@EarnestMoney
			END
	
		Close cur_EarnestMoney;
		Deallocate cur_EarnestMoney; 				

-----
	IF @ComssionCostPriceAcntCode <> '' AND @ComssionCostPrice_S <> 0
	BEGIN

		DECLARE @strRecDescComssionCost VARCHAR(1000) 

		SET @strRecDescComssionCost = ' حق العمل كاري خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strAcntName
		 
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
		
		IF @CurrencyRate <> 0
			SET @CurrencyAmount = ROUND(@ComssionCostPrice_S,0) / @CurrencyRate
	
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @AcntCode,ROUND(@ComssionCostPrice_S,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescComssionCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @ComssionCostPriceAcntCode,0,ROUND(@ComssionCostPrice_S,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescComssionCost)),'',0,@CurrencyAmount,@CurrencyTypeID)

	END	
	
	IF @BasculePriceAcntCode <> '' AND @BasculePrice <> 0
	BEGIN

		DECLARE @strRecDescBasculePrice VARCHAR(1000) 

		SET @strRecDescBasculePrice = ' هزينه باسكول خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strAcntName
		 
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
		
		IF @CurrencyRate <> 0
			SET @CurrencyAmount = ROUND(@BasculePrice,0) / @CurrencyRate

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @AcntCode,ROUND(@BasculePrice,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescBasculePrice)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @BasculePriceAcntCode,0,ROUND(@BasculePrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescBasculePrice)),'',0,@CurrencyAmount,@CurrencyTypeID)

	END	
	
	IF @LaborPriceAcntCode <> '' AND @LaborPrice <> 0
	BEGIN

		DECLARE @strRecDescLaborPrice VARCHAR(1000) 

		SET @strRecDescLaborPrice = ' هزينه كارگر خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strAcntName
		 
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
	
		IF @CurrencyRate <> 0
			SET @CurrencyAmount = ROUND(@LaborPrice,0) / @CurrencyRate

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @AcntCode,ROUND(@LaborPrice,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescLaborPrice)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

		
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @LaborPriceAcntCode,0,ROUND(@LaborPrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescLaborPrice)),'',0,@CurrencyAmount,@CurrencyTypeID)

	END	
		
	IF @TransportPriceAcntCode <> '' AND @TransportPrice <> 0
	BEGIN

		DECLARE @strRecDescTransportPrice VARCHAR(1000) 
		 
		SET @strRecDescTransportPrice = ' هزينه حمل خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strAcntName
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

		IF @CurrencyRate <> 0
			SET @CurrencyAmount = ROUND(@TransportPrice,0) / @CurrencyRate
					
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @AcntCode,0,ROUND(@TransportPrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransportPrice)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @TransportPriceAcntCode,ROUND(@TransportPrice,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransportPrice)),'',0,@CurrencyAmount,@CurrencyTypeID)
	END		
	
-------------------------------------------------هزینه حمل و نقل---------------------------------------
Declare	cur_TransportationCost CURSOR For 

SELECT  TransportationCostAcntCode,SUM(TransportationCost) TransportationCost
FROM inv.tblStorageDocsHdr
WHERE ProcessID=55 AND
  ProcessNo=@intSourceProcessNo AND
  FiscalYear=@intSourceFiscalYear AND
  SerialNo IN (
			  select BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )
GROUP BY TransportationCostAcntCode			  
			  
		Open  cur_TransportationCost; 
	
		Fetch NEXT From cur_TransportationCost Into @TransportationCostAcntCode,@TransportationCost
	
		While (@@Fetch_Status = 0)
			BEGIN	
				IF @TransportationCostAcntCode <> '' AND @TransportationCost <> 0
					BEGIN
						DECLARE @strRecDescTransCost VARCHAR(1000) 

						--------------------------------------------------------------------------------------------------------
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
						IF @TransportationCost_S <>0
						BEGIN
							SET @strRecDescTransCost = ' هزینه حمل و نقل ' + @strBuyTitle + @strFiscalSerial + @strAcntName
							
							IF @CurrencyRate <> 0 	
								SET @CurrencyAmount = ROUND(@TransportationCost_S,0) / @CurrencyRate

							--------------------------------------------------------------------------------------------------------
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
										@AcntCode,ROUND(@TransportationCost_S,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID)
							
							SET @TransportationCost_S=0
						END							
						--------------------------------------------------------------------------------------------------------
						IF @CurrencyRate <> 0 	
							SET @CurrencyAmount = ROUND(@TransportationCost,0) / @CurrencyRate
						
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1							
						
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@TransportationCostAcntCode ,0,ROUND(@TransportationCost,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
					
					END
				Fetch NEXT From cur_TransportationCost Into @TransportationCostAcntCode,@TransportationCost
				
			END
	
		Close cur_TransportationCost;
		Deallocate cur_TransportationCost; 
-------------------------------------------------درآمد حمل و نقل---------------------------------------
Declare	cur_TransportationIncome CURSOR For 

SELECT  TransportationIncomeAcntCode,SUM(TransportationIncome) TransportationIncome
FROM inv.tblStorageDocsHdr
WHERE ProcessID=55 AND
  ProcessNo=@intSourceProcessNo AND
  FiscalYear=@intSourceFiscalYear AND
  SerialNo IN (
			  select BaseSerialNo from inv.tblAfterBuyVoucherDtl
			  WHERE ProcessID  = @intSourceProcessID AND
					ProcessNo  = @intSourceProcessNo AND
					FiscalYear = @intSourceFiscalYear AND
					SerialNo   = @intSourceSerialNo
			  )
GROUP BY TransportationIncomeAcntCode			  
			  
		Open  cur_TransportationIncome; 
	
		Fetch NEXT From cur_TransportationIncome Into @TransportationIncomeAcntCode,@TransportationIncome
	
		While (@@Fetch_Status = 0)
			BEGIN
				IF @TransportationIncomeAcntCode <> '' AND @TransportationIncome <> 0
					BEGIN
						DECLARE @strRecDescTrans VARCHAR(1000) 
						
						SET @strRecDescTrans = ' درآمد حمل و نقل ' + @strBuyTitle + @strFiscalSerial + @strAcntName

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

						--------------------------------------------------------------------------------------------------------
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
									@TransportationIncomeAcntCode,ROUND(@TransportationIncome,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),'',0,@CurrencyAmount,@CurrencyTypeID)
											
						--------------------------------------------------------------------------------------------------------
						IF @TransportationIncome_S <>0
						BEGIN
							IF @CurrencyRate <> 0 	
								SET @CurrencyAmount = ROUND(@TransportationIncome_S,0) / @CurrencyRate
												
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
										@AcntCode ,0,ROUND(@TransportationIncome_S,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
						END

					END
				Fetch NEXT From cur_TransportationIncome Into @TransportationIncomeAcntCode,@TransportationIncome
				
			END
	
		Close cur_TransportationIncome;
		Deallocate cur_TransportationIncome; 
	--------------------------------------------------------------------------------------------------------
	
	EXEC [acc].[SpBalanceSourceVoucher]
		 @intVchNo,
		 @intSourceProcessID,
		 @intSourceProcessNo,
		 @intSourceFiscalYear,
		 @intSourceSerialNo,
		 @StockAcntCode
	
	--------------------------------------------------------------------------------------------------------
END
GO
