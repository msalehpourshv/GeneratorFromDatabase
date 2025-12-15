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
Create PROCEDURE [acc].[SpVchBuyRet]
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
	Declare @SumGoodsPrice				Float
	Declare @SumServicePrice			Float
	Declare @BuyReturnAcntCode			Varchar(20)
	Declare @StoreID					Varchar(20)
	Declare @AcntCode					Varchar(20)
	Declare @VisitorAcntCode			Varchar(20)	
	Declare @DocDate					VarChar(10)
	Declare @DocDate2					VarChar(10)
	Declare @StockAcntCode				Varchar(20)
	Declare @BuyTaxOverWorthAcntCode	Varchar(20)
	Declare @BuyTollOverWorthAcntCode	Varchar(20)
	Declare @BuyDiscountAcntCode		Varchar(20)
	Declare @CurrencyTypeID				VarChar(20)
	Declare @Discount					Float
	Declare @Discount2					Float
	Declare @TaxOverWorthCost			Float
	Declare @TollOverWorthCost			Float
	Declare @CurrencyRate				Float
	Declare @CurrencyAmount				Float
	Declare @TotalLineDiscount			Float
	Declare @GoodsQuantity				Float
	Declare @strBuyTitle				NVarChar(100)
	DECLARE @strRecDescDis				NVARCHAR(1000)
	Declare @strRecDesc					NVarChar(1000)
	Declare @strMsgText					NVarChar(2044)
	Declare @DescHdr					NVarChar(1000)
	Declare @strFiscalSerial			NVarChar(70)
	Declare @strDocDateIfDifference		NVarChar(1000)
	Declare @BaseProcessID				Int
	Declare @BaseSerialNo				Int
	Declare @BaseFiscalYear				Int
	Declare @AgreeNo					VarChar(20)

	DECLARE @BuyAcntNameInVoucherDesc   BIT
    DECLARE @strAcntName				NVarChar(500)

	Declare @CurrencyRateTmp			Float
	Declare @CurrencyAmountTmp			Float
	Declare @CurrencyTypeIDTmp			VarChar(20)
	Declare @Buy_TaxAcntCompletWithCustCode bit  
	Declare @inv_GoodsAcntGroupWithStoreID bit

	--------------------------------------------------------------------------------------------------------
	SET @GoodsQuantity=0
	SET @SumServicePrice=0		
	SET @SumGoodsPrice=0		
	SET	@Discount = 0
	SET @Discount2 = 0		
	SET @CurrencyAmount = 0		
	SET @CurrencyRate = 0		
	SET @TotalLineDiscount = 0
	
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''
	SET @inv_GoodsAcntGroupWithStoreID   = 'False'
	
	SET @CurrencyTypeID = ''
	SET @strBuyTitle = ''
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

	SELECT @inv_GoodsAcntGroupWithStoreID=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey='inv_GoodsAcntGroupWithStoreID'	
	
	SELECT @strBuyTitle = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TitleBuy' + LTRIM(RTRIM(STR(@intSourceProcessNo)))
	
	----- 'آيا تخفيف از جمع فاکتور در خريد کسر شود يا نه ؟ بله = 1 خير = 0 
	DECLARE @BuyDiscountVoucherMethod Bit

	SELECT @BuyDiscountVoucherMethod=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey='BuyDiscountVoucherMethod'
  
	SET @BuyDiscountVoucherMethod = ISNULL(@BuyDiscountVoucherMethod, 1)

	SELECT @BuyAcntNameInVoucherDesc = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'BuyAcntNameInVoucherDesc'
	
	select @Buy_TaxAcntCompletWithCustCode=SettingValue from pub.tblSettings where SettingKey='Buy_TaxAcntCompletWithCustCode'

	-----
	SELECT	@StoreID=StoreID, @AcntCode=AcntCode, @VisitorAcntCode=VisitorAcntCode,@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost,
			@DocDate=DocDate,@DocDate2=DocDate2,@Discount=Discount,@Discount2=Discount2+Discount3,@DescHdr = DocDesc,@CurrencyRate=CurrencyRate,
			@CurrencyTypeID=CurrencyTypeID,@TotalLineDiscount=TotalLineDiscount,@BaseProcessID = BaseProcessID,
			@BaseFiscalYear = BaseFiscalYear,@BaseSerialNo = BaseSerialNo,@AgreeNo = AgreeNo
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

   SELECT	@BuyReturnAcntCode=BuyReturnAcntCode, @BuyDiscountAcntCode=BuyDiscountAcntCode, 
            @BuyTaxOverWorthAcntCode=BuyTaxOverWorthAcntCode,
            @BuyTollOverWorthAcntCode=BuyTollOverWorthAcntCode,@StockAcntCode=StockAcntCode
   FROM inv.tblStores 
   WHERE StoreID = @StoreID

	IF @BuyReturnAcntCode=''
		BEGIN
			--کد برگشت از خرید خالی است
			SET @strMsgText=TS.pub.funGetMessages(11002,@LanguageID)
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
		
	IF @BuyTaxOverWorthAcntCode='' AND @TaxOverWorthCost <>0
		BEGIN
			--کد مالیات بر ارزش افزوده در خرید خالی است
			SET @strMsgText=TS.pub.funGetMessages(11038,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	IF @BuyTollOverWorthAcntCode='' AND @TollOverWorthCost <>0
		BEGIN
			--کد عوارض بر ارزش افزوده در خرید خالی است
			SET @strMsgText=TS.pub.funGetMessages(11042,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
				
	SELECT	@SumGoodsPrice =SUM(GoodsQuantity*s.GoodsPrice)		
	FROM inv.tblStorageDocsDtl s
	INNER JOIN inv.tblGoods g
	ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
	WHERE g.IsService='False' AND 
		  g.PartNumber=@UnitPart AND 
			ProcessID  = @intSourceProcessID AND
			ProcessNo  = @intSourceProcessNo AND
			FiscalYear = @intSourceFiscalYear AND
			SerialNo   = @intSourceSerialNo
			
	SELECT	@SumGoodsPrice =round(@SumGoodsPrice,0)	

	SELECT	@SumServicePrice =SUM(ROUND(GoodsQuantity*s.GoodsPrice,0))		
	FROM inv.tblStorageDocsDtl s
	INNER JOIN inv.tblGoods g	
	ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID
	WHERE g.IsService='True' AND 
			g.PartNumber=@UnitPart AND 
			ProcessID  = @intSourceProcessID AND
			ProcessNo  = @intSourceProcessNo AND
			FiscalYear = @intSourceFiscalYear AND
			SerialNo   = @intSourceSerialNo

	SET @SumGoodsPrice = ISNULL(@SumGoodsPrice,0)			 
	SET @SumServicePrice = ISNULL(@SumServicePrice,0)
				 
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
	IF @BuyAcntNameInVoucherDesc = 'True'
		Select @strAcntName = ' از ' + [pub].GetCodeName(@AcntCode, @LanguageID)
	ELSE
		SET @strAcntName = ''
			
	SET @strRecDesc='برگشت از خرید ' + @strBuyTitle + ' شماره'  + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + @strAcntName
	SET @strDocDateIfDifference = ''

	--IF @BaseSerialNo <> 0
	--BEGIN
	--	IF @BaseProcessID = 55
	--		SET @strRecDesc = @strRecDesc + ' - طبق خرید ' + LTRIM(RTRIM(STR(@BaseFiscalYear))) + '/' + LTRIM(RTRIM(STR(@BaseSerialNo))) 
	--END
	
	IF @AgreeNo <> ''
		SET @strRecDesc = @strRecDesc + ' - به شماره فاکتور خرید ' + LTRIM(RTRIM(@AgreeNo))
	
	IF @DocDate2 <> '' AND @DocDate <> @DocDate2
		SET @strDocDateIfDifference = ' مورخه ' + @DocDate
		
	DECLARE @SumGoodsPrice1 FLOAT
	SET @SumGoodsPrice1 = @SumGoodsPrice
	
	IF @BuyDiscountVoucherMethod = 1
		SET @SumGoodsPrice1 = @SumGoodsPrice1 - (@Discount + @Discount2 + @TotalLineDiscount )

	----- Price
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	
	IF @CurrencyRate <> 0 				
		SET @CurrencyAmount = ROUND(@SumGoodsPrice1,0) / @CurrencyRate
	
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
				@AcntCode,ROUND(@SumGoodsPrice1+ @SumServicePrice,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)	

	set @strRecDescDis = @strRecDesc
	
	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	IF @CurrencyRate <> 0 				
		SET @CurrencyAmount = ROUND(@SumGoodsPrice,0) / @CurrencyRate
		
--??????

	declare @DicountDtl as float
	set @DicountDtl=0
	declare @GoodsPrice1 as float
	set @GoodsPrice1=0
	
	IF @inv_GoodsAcntGroupWithStoreID = 'True'
		Declare	curStore CURSOR For
		SELECT	d.StoreID,[acc].[funMerg_AcntCode](s.BuyReturnAcntCode,P2AcntCode,P3AcntCode,P4AcntCode) BuyReturnAcntCode,sum(d.GoodsPrice*d.GoodsQuantity),
		sum(DiscountDtl)
		FROM inv.tblStorageDocsDtl d
		INNER JOIN inv.tblStores s	ON d.StoreID=s.StoreID
		INNER JOIN inv.tblGoods g
		ON SUBSTRING(d.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID	
		LEFT JOIN inv.tblGoodsAcntGroup a
		on a.GoodsAcntGroupID=g.GoodsAcntGroupID
		WHERE g.IsService = 'False' AND 
		ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 
		group by d.StoreID,[acc].[funMerg_AcntCode](s.BuyReturnAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)
	ELSE
		Declare	curStore CURSOR For
		SELECT	d.StoreID,s.BuyReturnAcntCode,sum(d.GoodsPrice*d.GoodsQuantity),
		sum(DiscountDtl)
		FROM inv.tblStorageDocsDtl d
		INNER JOIN inv.tblStores s	ON d.StoreID=s.StoreID
		INNER JOIN inv.tblGoods g
		ON SUBSTRING(d.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID	
		WHERE g.IsService = 'False' AND 
		ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 
		group by d.StoreID,s.BuyReturnAcntCode

	Open curStore;
		
	Fetch NEXT From curStore Into @StoreID,@BuyReturnAcntCode,@GoodsPrice1,@DicountDtl
	
	While (@@Fetch_Status = 0)
		BEGIN
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
				
			IF @CurrencyRate <> 0
				SET @CurrencyAmount = ROUND(@GoodsPrice1 ,0) / @CurrencyRate

			IF [acc].[funIsCurrencyAcntCode] (@BuyReturnAcntCode) = 'True'
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
					 @BuyReturnAcntCode,0,ROUND(@GoodsPrice1-@DicountDtl,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)	

		 
		Fetch NEXT From curStore Into @StoreID,@BuyReturnAcntCode,@GoodsPrice1,@DicountDtl
		ENd -- curStore
		Close curStore;
		Deallocate curStore; 


	-----
	IF @BuyDiscountAcntCode<>'' AND (@Discount<>0 OR @Discount2<>0 OR @TotalLineDiscount <> 0)
		BEGIN

			SET @strRecDesc=' تخفیف فاکتور برگشت از خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName

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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode)
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @BuyDiscountAcntCode,ROUND(@Discount + @Discount2 ,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

	IF  @TotalLineDiscount <> 0
		BEGIN
			Declare	@DiscountDtl as  float
			set @DiscountDtl=0
			
			
			IF @inv_GoodsAcntGroupWithStoreID = 'True'
				Declare	curLineDisc CURSOR For
				SELECT	s.StoreID,[acc].[funMerg_AcntCode](sd.StockAcntCode,P2AcntCode,P3AcntCode,P4AcntCode) StockAcntCode,sum(s.DiscountDtl)
				FROM inv.tblStorageDocsDtl s
				INNER JOIN inv.tblStores sd
				ON s.StoreID=sd.StoreID
				INNER JOIN inv.tblGoods g
				ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=g.GoodsID AND g.PartNumber=@UnitPart 
				LEFT JOIN inv.tblGoodsAcntGroup a
				ON a.GoodsAcntGroupID=g.GoodsAcntGroupID
				WHERE ProcessID=@intSourceProcessID AND
					  ProcessNo=@intSourceProcessNo AND
					  FiscalYear=@intSourceFiscalYear AND
					  SerialNo=@intSourceSerialNo 
				group by s.StoreID,[acc].[funMerg_AcntCode](sd.StockAcntCode,P2AcntCode,P3AcntCode,P4AcntCode) 			
			ELSE
				Declare	curLineDisc CURSOR For
				SELECT	s.StoreID,sd.StockAcntCode,sum(s.DiscountDtl)
				FROM inv.tblStorageDocsDtl s
				INNER JOIN inv.tblStores sd
				ON s.StoreID=sd.StoreID
				WHERE ProcessID=@intSourceProcessID AND
					  ProcessNo=@intSourceProcessNo AND
					  FiscalYear=@intSourceFiscalYear AND
					  SerialNo=@intSourceSerialNo 
				group by s.StoreID,sd.StockAcntCode


			Open curLineDisc;
				
			Fetch NEXT From curLineDisc Into @StoreID,@StockAcntCode,@DiscountDtl
			
			While (@@Fetch_Status = 0)
			 BEGIN
			
			
				SET @strRecDesc=' تخفیف سطری فاکتور برگشت از خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName
				-----
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				
				IF @CurrencyRate <> 0
					SET @CurrencyAmount = ROUND( @DiscountDtl,0) / @CurrencyRate
				 
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
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID,VisitorAcntCode)
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							@StockAcntCode,0,ROUND(@DiscountDtl,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescDis)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)	

				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode)
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						 @StockAcntCode,ROUND(@DiscountDtl,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

				Fetch NEXT From curLineDisc Into @StoreID,@StockAcntCode,@DiscountDtl
			ENd-- curLineDisc
			Close curLineDisc;
			Deallocate curLineDisc; 
					
		END --end if  @TotalLineDiscount <> 0
			
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
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode)
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
							 @AcntCode,0,ROUND(@Discount + @Discount2 + @TotalLineDiscount ,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
			 
				END
		END

	-----
	IF @BuyTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0	
		BEGIN

			SET @strRecDesc=' مالیات بر ارزش افزوده فاکتور برگشت از خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName

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
											
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode)
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,ROUND(@TaxOverWorthCost,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

			-----
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @Buy_TaxAcntCompletWithCustCode = 'True' 				
 				SELECT @BuyTaxOverWorthAcntCode = [pub].[funMergCode](@BuyTaxOverWorthAcntCode,@AcntCode)

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode)
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @BuyTaxOverWorthAcntCode,0,ROUND(@TaxOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)
		END

	-----
	IF @BuyTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0	
		BEGIN

			SET @strRecDesc=' عوارض بر ارزش افزوده فاکتور برگشت از خرید ' + @strBuyTitle + ' شماره' + @strFiscalSerial + @strDocDateIfDifference + @strAcntName

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
							
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode)
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,ROUND(@TollOverWorthCost,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)

			-----
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @Buy_TaxAcntCompletWithCustCode = 'True' 				
		 		SELECT @BuyTollOverWorthAcntCode = [pub].[funMergCode](@BuyTollOverWorthAcntCode,@AcntCode)

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,VisitorAcntCode)
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @BuyTollOverWorthAcntCode,0,ROUND(@TollOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount,@CurrencyTypeID,@VisitorAcntCode)
		END

		--------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------
		declare @GoodsPrice as Float
		declare @GoodsName as NVARCHAR(500)
		declare @DescDtl as NVARCHAR(500)
		
		DECLARE @CostCenterAcntCode VARCHAR(30)
		
		Declare	curService CURSOR For 
		SELECT	g.CostCenterAcntCode,s.GoodsPrice,SubUnitQuantity,DescDtl,pub.funGetGoodsName(s.GoodsID,@LanguageID) AS GoodsName
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
							SET @strRecDesc = ' برگشت از خرید ' + @strBuyTitle + @strFiscalSerial + ' - خدمات ' + @GoodsName + ' - ' + ltrim(rtrim(str(@GoodsQuantity)))  + ' - فی ' + ltrim(rtrim(str(@GoodsPrice))) + @strAcntName
									
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
									 @CostCenterAcntCode,0,ROUND(@GoodsPrice * @GoodsQuantity,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0 ,'True',@CurrencyAmountTmp,@CurrencyTypeIDTmp,@VisitorAcntCode)
						END
		
					Fetch NEXT From curService Into @CostCenterAcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName
				END
		
			Close curService;
			Deallocate curService; 
		--------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------
END
GO
