USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/11/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchOurTrust_Send]
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
	
	Declare @strMsgText				NVarChar(2044)
	Declare @DescDtl				NVarChar(1000)
	Declare @strFiscalSerial		VarChar(20)
	Declare @strRecDesc				NVarChar(1000)
	Declare @strRecDesc2			NVarChar(1000)
	Declare @GoodsName				NVarChar(1000)
	Declare @GoodsUnit				NVarChar(1000)
	Declare @SaleTaxOverWorthAcntCode Varchar(20)
	Declare @SaleTollOverWorthAcntCode Varchar(20)
	Declare @OurTrustAcntCode		Varchar(20)
	Declare @StoreID				Varchar(20)
	Declare @AcntCode				Varchar(20)
	Declare @AtomAcntCode			Varchar(20)
	Declare @VisitorAcntCode		Varchar(20)
	Declare @VisitorCostAcntCode	Varchar(20)
	Declare @OtherCostAcntCode		Varchar(20)
	Declare @OtherIncomeAcntCode	Varchar(20)
	
	Declare @DiscountAcntCode	    Varchar(20)
	Declare @EarnestMoneyAcntCode	Varchar(20)
	Declare @TaxAcntCode			Varchar(20)
	Declare @TransportationCostAcntCode	Varchar(20)
	Declare @TransportationIncomeAcntCode	Varchar(20)
	Declare @PackingAcntCode		Varchar(20)
	Declare @GoodsPrice				Float
	Declare @GoodsQuantity			Float
	Declare @Discount				Float
	Declare @Discount2				Float
	Declare @TotalLineDiscount		Float
	Declare @TransportationCost		Float
	Declare @TransportationIncome	Float
	Declare @PackingCost			Float
	Declare @TaxCost				Float
	Declare @VisitorPercent			Float
	Declare @VisitorCost			Float
	Declare @EarnestMoney			Float
	Declare @EarnestMoneyPercent	Float
	Declare @SumGoodsPrice			Float
	Declare @VisitorCost2			Float
	Declare @TaxOverWorthCost		Float
	Declare @TollOverWorthCost		Float
	Declare @OtherCost				Float
	Declare @OtherIncome			Float

	DECLARE @TotalTrust2Account		BIT		
	DECLARE @DiscountMinusFromVisitor	BIT		
	Declare @DescHdr				NVarChar(1000)
	Declare @DescHdr2				NVarChar(1000)
	SET @DescHdr = ''
	SET @DescHdr2 = ''
	-----
	SET	@Discount = 0
	SET @Discount2 = 0				
	SET @TotalLineDiscount = 0
	SET @TotalTrust2Account = 0				
	SET @VisitorCost2 = 0
	SET @OurTrustAcntCode = ''

	--------------------------------------------------------------------------------------------------------
	SELECT @TotalTrust2Account = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TotalTrust2Account'

	SET @TotalTrust2Account=ISNULL(@TotalTrust2Account,1)

	SELECT @DiscountMinusFromVisitor = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DiscountMinusFromVisitor'

	--------------------------------------------------------------------------------------------------------
	SELECT	@StoreID=StoreID,@AcntCode=AcntCode,@Discount=Discount,@Discount2=Discount2+Discount3,@TotalLineDiscount=TotalLineDiscount,
			@TransportationCost=TransportationCost,@TransportationIncome=TransportationIncome,@PackingCost=PackingCost,@TaxCost=TaxCost,
			@VisitorAcntCode=VisitorCostAcntCode,@VisitorPercent=VisitorPercent,@VisitorCost=VisitorCost,
			@DiscountAcntCode=DiscountAcntCode,@EarnestMoney=EarnestMoney,@EarnestMoneyPercent=EarnestMoneyPercent,
			@TransportationCostAcntCode=TransportationCostAcntCode,@TransportationIncomeAcntCode=TransportationIncomeAcntCode,
            @EarnestMoneyAcntCode=EarnestMoneyAcntCode,@TaxOverWorthCost=TaxOverWorthCost,@TollOverWorthCost=TollOverWorthCost,
            @OtherCostAcntCode=OtherCostAcntCode,@OtherIncomeAcntCode=OtherIncomeAcntCode,@OtherCost=OtherCost,@OtherIncome=OtherIncome,
			@DescHdr= DocDesc,@DescHdr2= DocDesc2
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
	set @DescHdr=@DescHdr+' - '+@DescHdr2
	--------------------------------------------------------------------------------------------------------
    SELECT	@PackingAcntCode=PackingAcntCode,@VisitorCostAcntCode=VisitorCostAcntCode, 
			@TaxAcntCode=TaxAcntCode,@SaleTaxOverWorthAcntCode=SaleTaxOverWorthAcntCode,@SaleTollOverWorthAcntCode=SaleTollOverWorthAcntCode,@OurTrustAcntCode=OurTrustAcntCode
    FROM inv.tblStores 
    WHERE StoreID = @StoreID

	--------------------------------------------------------------------------------------------------------

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

	IF @OurTrustAcntCode='' 
		BEGIN
			--کد کالای امانی ما نزد دیگران در انبار خالی است
			SET @strMsgText=TS.pub.funGetMessages(11045,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END	
		
	IF @DiscountAcntCode='' AND (@Discount + @Discount2 + @TotalLineDiscount) <> 0
		BEGIN
			SET @strMsgText=N'کد تخفیفات خالی است'
			Raiserror (@strMsgText,16,1)
			Return
		END
	--------------------------------------------------------------------------------------------------------
	SET @SumGoodsPrice  = 0

	SELECT	@SumGoodsPrice  = SUM(ROUND(GoodsPrice *GoodsQuantity,0))
	FROM inv.tblStorageDocsDtl
	WHERE ProcessID  = @intSourceProcessID AND
		  ProcessNo  = @intSourceProcessNo AND
		  FiscalYear = @intSourceFiscalYear AND
		  SerialNo   = @intSourceSerialNo

	--------------------------------------------------------------------------------------------------------
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	SET @strRecDesc=' ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial
	
	--------------------------------------------------------------------------------------------------------
	----- اگر جمع کل فروش به حساب مشتری منظور میشود
	IF @TotalTrust2Account = 1
	BEGIN
		
		----- اگر تخفیف از جمع فروش کسر نمیشود
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,ROUND(@SumGoodsPrice - @EarnestMoney,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0)	

	END

	ELSE ----- IF @TotalTrust2Account = 0
	----- اگر تک تک آیتمهای فروش به حساب مشتری منظور میشود
	BEGIN
		Declare	curSale CURSOR For 
		SELECT	AcntCode,GoodsPrice,GoodsQuantity,DescDtl,pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName,pub.funGetGoodsUnitName(GoodsID,@LanguageID) AS GoodsUnit
		FROM inv.tblStorageDocsDtl
		WHERE ProcessID=@intSourceProcessID AND
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 
	
		----- فاکتور فروش سطر به سطر به حساب مشتری میرود
		Open  curSale; 
	
		Fetch NEXT From curSale Into @AcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@GoodsUnit
	
		While (@@Fetch_Status = 0)
			BEGIN
				IF @GoodsPrice <> 0
					BEGIN
						SET @strRecDesc2 = ' ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial + ' - ' + @GoodsName + ' - ' + ltrim(rtrim(str(@GoodsQuantity))) + @GoodsUnit + ' - فی ' + ltrim(rtrim(str(@GoodsPrice)))
								
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCode,ROUND(@GoodsPrice * @GoodsQuantity,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl)),0 )	
					END
	
				Fetch NEXT From curSale Into @AcntCode,@GoodsPrice,@GoodsQuantity,@DescDtl,@GoodsName,@GoodsUnit
			END
	
		Close curSale;
		Deallocate curSale; 

		IF @EarnestMoneyAcntCode <> '' AND @EarnestMoney <> 0
			BEGIN
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,0 ,ROUND(@EarnestMoney,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0)

			END
	END

	----- کل تخفیف به بستانکاری مشتری میرود
	IF @DiscountAcntCode is not null AND (@Discount + @Discount2 + @TotalLineDiscount) <> 0
		BEGIN
			SET @strRecDesc2 = ' تخفیف ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,0 ,ROUND(@Discount + @Discount2 + @TotalLineDiscount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0)
		END

	--------------------------------------------------------------------------------------------------------
	
	----- کل تخفیف به بدهکاری هزینه میرود
	IF @DiscountAcntCode is not null AND (@Discount + @Discount2 + @TotalLineDiscount) <> 0
		BEGIN
			SET @strRecDesc2 = ' تخفیف ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@DiscountAcntCode,ROUND(@Discount + @Discount2 + @TotalLineDiscount,0),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0)
		END

	--------------------------------------------------------------------------------------------------------
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				@OurTrustAcntCode,0,ROUND(@SumGoodsPrice,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0)

	-------------------------------------------------هزینه حمل و نقل---------------------------------------
	IF @TransportationCostAcntCode <> '' AND @TransportationCost <> 0
		BEGIN
			DECLARE @strRecDescTransCost VARCHAR(1000) 
			
			SET @strRecDescTransCost = ' هزینه حمل ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial

			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@TransportationCostAcntCode,ROUND(@TransportationCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),'',0)
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,0,ROUND(@TransportationCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTransCost)),'',0)

		END

	-------------------------------------------------درآمد حمل و نقل---------------------------------------
	IF @TransportationIncomeAcntCode <> '' AND @TransportationIncome <> 0
		BEGIN
			DECLARE @strRecDescTrans VARCHAR(1000) 
			
			SET @strRecDescTrans = ' درآمد حمل ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial

			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,ROUND(@TransportationIncome,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),'',0)
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@TransportationIncomeAcntCode,0,ROUND(@TransportationIncome,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),'',0)

		END

		------------------------------------------------هزینه بسته بندی------------------------------------
		IF @PackingAcntCode	<> '' AND @PackingCost <> 0
			BEGIN
				--------------------------------------------------------------------------------------------------------
			
				DECLARE @strRecDescPacking VARCHAR(1000) 
				SET @strRecDescPacking =' هزینه بسته بندی ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial
			
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,ROUND(@PackingCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescPacking)),'',0)
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@PackingAcntCode,0,ROUND(@PackingCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescPacking)),'',0)
				
			END

		-----------------------------------------------مالیات تجمیع عوارض--------------------------------------------
		IF @TaxAcntCode	<> '' AND @TaxCost <> 0
			BEGIN
				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescTax VARCHAR(1000) 
				SET @strRecDescTax = ' مالیات تجمیع عوارض ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,ROUND(@TaxCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTax)),'',0)
			
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@TaxAcntCode,0,ROUND(@TaxCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTax)),'',0)
				
			END
	
		----------------------------------------------- بازاریاب --------------------------------------------
		IF @VisitorAcntCode	<> '' AND @VisitorCostAcntCode	<> '' AND @VisitorCost <> 0
			BEGIN
				IF @VisitorPercent >0
					BEGIN
						IF @DiscountMinusFromVisitor = 1
							BEGIN	
								SET @VisitorCost2 = (@SumGoodsPrice * @VisitorPercent) / 100
							END
						ELSE
							BEGIN
								SET @VisitorCost2 = ((@SumGoodsPrice - (@Discount + @Discount2 + @TotalLineDiscount)) * @VisitorPercent) / 100
							END
					END
				IF @VisitorCost2 > 0
					SET @VisitorCost = @VisitorCost2

				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescVisitor VARCHAR(1000) 
				SET @strRecDescVisitor = ' هزینه بازاریاب ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorCostAcntCode,ROUND(@VisitorCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0)
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorAcntCode,0,ROUND(@VisitorCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescVisitor)),'',0)

			END
			
		----------------------------------------------- پیش دریافت --------------------------------------------
		IF @EarnestMoneyAcntCode <> '' AND @EarnestMoney <> 0
			BEGIN

				DECLARE @strRecDescEarnestMoney VARCHAR(1000) 
				SET @strRecDescEarnestMoney = ' پیش دریافت ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@EarnestMoneyAcntCode,ROUND(@EarnestMoney,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescEarnestMoney)),'',0)

			END

		-----------------------------------------------مالیات بر ارزش افزوده--------------------------------------------
		IF @SaleTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0
			BEGIN
				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescTaxOverWorth VARCHAR(1000) 
				SET @strRecDescTaxOverWorth = ' مالیات بر ارزش افزوده ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,ROUND(@TaxOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0)
			
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@SaleTaxOverWorthAcntCode,0,ROUND(@TaxOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0)
				
			END

		-----------------------------------------------مالیات بر ارزش افزوده--------------------------------------------
		IF @SaleTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0
			BEGIN
				--------------------------------------------------------------------------------------------------------
				DECLARE @strRecDescTollOverWorth VARCHAR(1000) 
				SET @strRecDescTollOverWorth = ' عوارض بر ارزش افزوده ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@AcntCode,ROUND(@TollOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0)
			
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@SaleTollOverWorthAcntCode,0,ROUND(@TollOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0)
				
			END
			
	-------------------------------------------------سایر هزینه ها در فروش---------------------------------------
	IF @OtherCostAcntCode <> '' AND @OtherCost <> 0
		BEGIN
			DECLARE @strRecDescOtherCost VARCHAR(1000) 
			
			SET @strRecDescOtherCost = 'سایر هزینه ها در ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial

			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@OtherCostAcntCode,ROUND(@OtherCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),'',0)
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,0,ROUND(@OtherCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherCost)),'',0)

		END

	-------------------------------------------------'سایر درآمد ها در فروش---------------------------------------
	IF @OtherIncomeAcntCode <> '' AND @OtherIncome <> 0
		BEGIN
			DECLARE @strRecDescIncome VARCHAR(1000) 
			
			SET @strRecDescIncome = 'سایر درآمد ها در ارسال كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial

			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,ROUND(@OtherIncome,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),'',0)
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@OtherIncomeAcntCode,0,ROUND(@OtherIncome,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescIncome)),'',0)

		END

			
END
GO
