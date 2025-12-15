USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1401/06/23
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchBuyOrder]
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
Declare @AcntCode					Varchar(20)
Declare @SumPrice					Float
Declare @GoodsQuantity				Float
Declare @DocDate					VarChar(10)
Declare @DocDate2					VarChar(10)
Declare @AtomDesc					NVarChar(1000)
Declare @strRecDesc					NVarChar(1000)
Declare @DescHdr					NVarChar(1000)
Declare @strFiscalSerial			VarChar(20)
DECLARE @TotalBuy2Account			BIT		
Declare @GoodsPrice					Float
Declare @DescDtl					NVarChar(1000)
Declare @GoodsName					NVarChar(1000)
Declare @GoodsUnit					NVarChar(1000)
Declare @strRecDesc2				NVarChar(1000)
Declare @strDocDateIfDifference		NVarChar(1000)
Declare @strAgreeNo					VarChar(20)

DECLARE @BuyAcntNameInVoucherDesc   BIT

DECLARE @strAcntName				NVarChar(500)
DECLARE @BuyOrderAcntCodeSetting	VARCHAR(20)

declare @Buy_ShowStockAcntCodeDtl		bit
declare @DocRowNo					int
declare @IsService					bit
Declare @CurrencyTypeID				VarChar(20)
Declare @CurrencyRate				Float
Declare @CurrencyAmount				Float
Declare @CurrencyRateTmp			Float
Declare @CurrencyAmountTmp			Float
Declare @CurrencyTypeIDTmp			VarChar(20)
--------------------------------------------------------------------------------------------------------

SET @SumPrice = 0
SET @GoodsQuantity = 0

----- 	
SET @BuyOrderAcntCodeSetting = ''
SET @strFiscalSerial = ''

DECLARE @UnitPart TINYINT
SET @UnitPart  = 1

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

SELECT @BuyOrderAcntCodeSetting = SettingValue 	FROM pub.tblSettings WHERE SettingKey = 'BuyOrderAcntCode'

SELECT @BuyAcntNameInVoucherDesc = SettingValue FROM pub.tblSettings WHERE SettingKey = 'BuyAcntNameInVoucherDesc'

SET @CurrencyTypeID = ''
SET @CurrencyRate = 0 	
SET @CurrencyAmount = 0
SET @CurrencyRateTmp = 0
SET @CurrencyAmountTmp = 0
SET @CurrencyTypeIDTmp = ''

SELECT	@AcntCode=AcntCode,@strAgreeNo=AgreeNo,@DocDate=DocDate
		   ,@CurrencyRate=CurrencyRate,@CurrencyTypeID=CurrencyTypeID
FROM [cmr].[tblOrderHdr]
WHERE ProcessID=@intSourceProcessID AND
  ProcessNo=@intSourceProcessNo AND
  FiscalYear=@intSourceFiscalYear AND
  SerialNo=@intSourceSerialNo 
SELECT @SumPrice = ROUND(SUM(GoodsQuantity * s.GoodsPrice),0)
FROM [cmr].[tblOrderDtl] s
WHERE 
	ProcessID  = @intSourceProcessID AND
	ProcessNo  = @intSourceProcessNo AND
	FiscalYear = @intSourceFiscalYear AND
	SerialNo   = @intSourceSerialNo

	  
SET @SumPrice  = ISNULL (@SumPrice, 0)


SET @strDocDateIfDifference = ' مورخه ' + @DocDate


SET @BuyOrderAcntCodeSetting = RTRIM(@BuyOrderAcntCodeSetting) + SUBSTRING(@AcntCode ,LEN(@BuyOrderAcntCodeSetting)+1,20)
----------------------------------------------------------------------------------------------------------------------------------
-- موجودی کالاها سطری باشد
SELECT @Buy_ShowStockAcntCodeDtl = SettingValue	FROM pub.tblSettings WHERE SettingKey = 'Buy_ShowStockAcntCodeDtl' 
  
 set @Buy_ShowStockAcntCodeDtl =isnull(@Buy_ShowStockAcntCodeDtl ,'False')
 
 if @Buy_ShowStockAcntCodeDtl ='True'
 begin
		-----
		SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 

		IF @strAgreeNo <> ''
		SET @strFiscalSerial = @strFiscalSerial + ' - به شماره فاکتور سفارش خرید ' + @strAgreeNo

		IF @BuyAcntNameInVoucherDesc = 'True'
			Select @strAcntName = ' از ' + [pub].GetCodeName(@AcntCode, @LanguageID)
		ELSE
			SET @strAcntName = ''
		--------11111111111111---------------------------------
		SET @strRecDesc = 'سفارش خرید شماره ' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName

		-- جمع کالاهای خرید بدهکار شود؟
		SELECT @TotalBuy2Account = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'TotalBuy2Account'

		--?????	
		Declare	curStore CURSOR For
			SELECT	s.GoodsPrice ,s.DocRowNo, s.GoodsQuantity ,DescDtl
						,pub.funGetGoodsName(s.GoodsID,@LanguageID) AS GoodsName,pub.funGetGoodsUnitName(s.GoodsID,@LanguageID) AS GoodsUnit
		FROM [cmr].[tblOrderDtl] s
		INNER JOIN inv.tblGoods d
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=d.GoodsID
		WHERE  ProcessID=@intSourceProcessID AND d.PartNumber=@UnitPart AND 
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
		Open curStore;

		Fetch NEXT From curStore Into @GoodsPrice,@DocRowNo,@GoodsQuantity,@DescDtl,@GoodsName,@GoodsUnit,@IsService

		While (@@Fetch_Status = 0)
		BEGIN		

				SET @strRecDesc = 'سفارش خرید شماره ' + ISNULL(@strFiscalSerial,'') +  @strDocDateIfDifference + ' - ' + 
				    ISNULL(@GoodsName,'') + ' - ' + ISNULL(ltrim(rtrim(STR(@GoodsQuantity,LEN(@GoodsQuantity),3))),'') + ISNULL(@GoodsUnit,'') + ' - فی ' + 
				    ISNULL(ltrim(rtrim(str(@GoodsPrice))),'') + @strAcntName

			set @GoodsPrice=@GoodsPrice*@GoodsQuantity
		
	
		-----
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = @GoodsPrice/ @CurrencyRate
		
		IF [acc].[funIsCurrencyAcntCode] (@BuyOrderAcntCodeSetting) = 'True'
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

		set  @strRecDesc2 =''
			--if @TotalBuy2Account=1
			SET @strRecDesc2 =TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr))
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
				 @BuyOrderAcntCodeSetting,ROUND(@GoodsPrice,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	

		FETCH NEXT From curStore Into  @GoodsPrice,@DocRowNo,@GoodsQuantity,@DescDtl,@GoodsName,@GoodsUnit,@IsService
		END -- curStore
		Close curStore;
		Deallocate curStore; 
		--?????		
	end 
else
	begin
		-----
		SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 

		IF @strAgreeNo <> ''
			SET @strFiscalSerial = @strFiscalSerial + ' - ' +  ' به شماره فاکتور سفارش خرید ' + @strAgreeNo

		IF @BuyAcntNameInVoucherDesc = 'True'
			Select @strAcntName = ' از ' + [pub].GetCodeName(@AcntCode, @LanguageID)
		ELSE
			SET @strAcntName = ''
		--------11111111111111---------------------------------
		SET @strRecDesc = 'سفارش خرید شماره ' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName
		  
		-- جمع کالاهای خرید بدهکار شود؟
		SELECT @TotalBuy2Account = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'TotalBuy2Account'

		-----
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = @SumPrice/ @CurrencyRate		
		IF [acc].[funIsCurrencyAcntCode] (@BuyOrderAcntCodeSetting) = 'True'
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
			
		set  @strRecDesc2 =''
		SET @strRecDesc2 =TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr))
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
				 @BuyOrderAcntCodeSetting,ROUND(@SumPrice,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@strRecDesc2,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	

		--?????		
end
----------------------------------------------------------------------------------------------------------------------------------
IF @TotalBuy2Account = 0

IF @TotalBuy2Account = 1

BEGIN
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
END		

ELSE
BEGIN

Declare	curBuy CURSOR For 
 
SELECT	AcntCode,s.GoodsPrice , GoodsQuantity,DescDtl,pub.funGetGoodsName(s.GoodsID,@LanguageID) AS GoodsName,pub.funGetGoodsUnitName(s.GoodsID,@LanguageID) AS GoodsUnit,IsService
FROM inv.tblStorageDocsDtl s
INNER JOIN inv.tblGoods g
ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
WHERE ProcessID=@intSourceProcessID AND  g.PartNumber=@UnitPart AND 
	  ProcessNo=@intSourceProcessNo AND
	  FiscalYear=@intSourceFiscalYear AND
	  SerialNo=@intSourceSerialNo 

----- فاکتور خرید سطر به سطر به حساب مشتری میرود
SET @SumPrice = 0

Open curBuy;
	
Fetch NEXT From curBuy Into @AcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@GoodsUnit,@IsService

While (@@Fetch_Status = 0)
	BEGIN
		IF @GoodsPrice <> 0
			BEGIN

				SET @strRecDesc2 = 'سفارش خرید ' +  ' شماره ' + ISNULL(@strFiscalSerial,'') +  @strDocDateIfDifference + ' - ' + 
				    ISNULL(@GoodsName,'') + ' - ' + ISNULL(ltrim(rtrim(STR(@GoodsQuantity,LEN(@GoodsQuantity),3))),'') + ISNULL(@GoodsUnit,'') + ' - فی ' + 
				    ISNULL(ltrim(rtrim(str(@GoodsPrice))),'') + @strAcntName

				 IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = (@GoodsPrice * @GoodsQuantity)/ @CurrencyRate		
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
				
				IF @IsService = 'False'
					SET @SumPrice = @SumPrice + ROUND(@GoodsPrice * @GoodsQuantity,0)
				ELSE
					SET @strRecDesc2 = 'سفارش خرید ' + ' شماره' + ISNULL(@strFiscalSerial,'') +  @strDocDateIfDifference + ' - خدمات ' + ISNULL(@GoodsName,'') + ' - ' + ISNULL(ltrim(rtrim(STR(@GoodsQuantity,LEN(@GoodsQuantity),3))),'') + ISNULL(@GoodsUnit,'') + ' - فی ' + ISNULL(ltrim(rtrim(str(@GoodsPrice))),'') + @strAcntName
				
				
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						 @AcntCode,0,ROUND(@GoodsPrice * @GoodsQuantity,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp )	
			end

		Fetch NEXT From curBuy Into @AcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@GoodsUnit,@IsService
	ENd

Close curBuy;
Deallocate curBuy; 	
END	

-----------
SET @strRecDesc='سفارش خرید شماره '  +  @strFiscalSerial + @strDocDateIfDifference + @strAcntName

IF @TotalBuy2Account = 1
BEGIN

	IF @CurrencyRate <> 0 	
		SET @CurrencyAmount =@SumPrice / @CurrencyRate		
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
	
	Declare @SumPurePrice FLOAT

	Set @SumPurePrice = @SumPrice 
		
		
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo ,
				@AcntCode,0,ROUND(@SumPurePrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp )	

END				

	--------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------
	
	EXEC [acc].[SpBalanceSourceVoucher]
		 @intVchNo,
		 @intSourceProcessID,
		 @intSourceProcessNo,
		 @intSourceFiscalYear,
		 @intSourceSerialNo,
		 @BuyOrderAcntCodeSetting
	
	--------------------------------------------------------------------------------------------------------
END
GO
