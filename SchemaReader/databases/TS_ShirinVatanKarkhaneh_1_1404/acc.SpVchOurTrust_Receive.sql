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
Create PROCEDURE [acc].[SpVchOurTrust_Receive]
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
	Declare @strRecDesc				NVarChar(1000)
	Declare @strRecDesc2			NVarChar(1000)
	Declare @strFiscalSerial		VarChar(20)
	Declare @StoreID				Varchar(20)
	Declare @AcntCode				Varchar(20)
	Declare @DiscountAcntCode	    Varchar(20)
	Declare @EarnestMoneyAcntCode	Varchar(20)
	Declare @VisitorAcntCode		Varchar(20)
	Declare @VisitorCostAcntCode	Varchar(20)
	Declare @OurTrustAcntCode		Varchar(20)
	Declare @VisitorPercent			Float
	Declare @VisitorCost			Float
	Declare @VisitorCost2			Float
	Declare @TotalLineDiscount		Float
	Declare @Discount				Float
	Declare @Discount2				Float
	Declare @EarnestMoney			Float
	Declare @EarnestMoneyPercent	Float
	Declare @GoodsAmount			Float
	Declare @GoodsPrice				Float
	Declare @GoodsQuantity			Float
	Declare @SumGoodsPrice			Float
	Declare @DiscountMinusFromVisitor Bit
	Declare @GoodsName				NVarChar(1000)
	Declare @GoodsUnit				NVarChar(1000)
	DECLARE @TotalTrust2Account		BIT		
	Declare @DescHdr				NVarChar(1000)
	Declare @DescHdr2				NVarChar(1000)
	SET @DescHdr = ''
	SET @DescHdr2 = ''
	--------------------------------------------------------------------------------------------------------
	SET	@Discount = 0
	SET @Discount2 = 0				
	SET @TotalLineDiscount = 0
	SET @VisitorCost2 = 0
	SET @OurTrustAcntCode = ''
	SET @TotalTrust2Account = 0				

	--------------------------------------------------------------------------------------------------------
	DECLARE @CurrentDate DATETIME
	SET @CurrentDate = GETDATE()

	SELECT @DiscountMinusFromVisitor = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DiscountMinusFromVisitor'

	SELECT @TotalTrust2Account = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TotalTrust2Account'

	SET @TotalTrust2Account=ISNULL(@TotalTrust2Account,1)

	--------------------------------------------------------------------------------------------------------
	SELECT	@StoreID=StoreID,@AcntCode=AcntCode,@Discount=Discount,@Discount2=Discount2,@TotalLineDiscount=TotalLineDiscount,
			@VisitorAcntCode=VisitorCostAcntCode,@EarnestMoney=EarnestMoney,@EarnestMoneyPercent=EarnestMoneyPercent,
			@VisitorAcntCode=VisitorCostAcntCode,@VisitorPercent=VisitorPercent,@VisitorCost=VisitorCost,
			@DiscountAcntCode=DiscountAcntCode,@EarnestMoneyAcntCode=EarnestMoneyAcntCode,
			@DescHdr= DocDesc,@DescHdr2= DocDesc2
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
	set @DescHdr=@DescHdr+' - '+@DescHdr2
	--------------------------------------------------------------------------------------------------------
    SELECT	@VisitorCostAcntCode=VisitorCostAcntCode,@OurTrustAcntCode=OurTrustAcntCode
    FROM inv.tblStores 
    WHERE StoreID = @StoreID

	--------------------------------------------------------------------------------------------------------
	IF @OurTrustAcntCode='' 
		BEGIN
			--کد کالای امانی ما نزد دیگران در انبار خالی است
			SET @strMsgText=TS.pub.funGetMessages(11045,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END	
	-------------------------------------------------------------------------------------------------------
	SET @SumGoodsPrice  = 0
	
	SELECT	@SumGoodsPrice  = SUM(GoodsPrice *GoodsQuantity)
	FROM inv.tblStorageDocsDtl
	WHERE ProcessID  = @intSourceProcessID AND
		  ProcessNo  = @intSourceProcessNo AND
		  FiscalYear = @intSourceFiscalYear AND
		  SerialNo   = @intSourceSerialNo

	--------------------------------------------------------------------------------------------------------
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	SET @strRecDesc=' دريافت كالاهاي اماني ما نزد دیگران شماره' + @strFiscalSerial
	----------------------------------------------------------------------------------------------------------------
	IF @TotalTrust2Account = 1
	BEGIN
		
		----- اگر تخفیف از جمع فروش کسر نمیشود
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@OurTrustAcntCode,ROUND(@SumGoodsPrice - @EarnestMoney,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0)	

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
						SET @strRecDesc2 = ' دريافت كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial + ' - ' + @GoodsName + ' - ' + ltrim(rtrim(str(@GoodsQuantity))) + @GoodsUnit + ' - فی ' + ltrim(rtrim(str(@GoodsPrice)))
								
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @OurTrustAcntCode,ROUND(@GoodsPrice * @GoodsQuantity,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl)),0 )	
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
							@OurTrustAcntCode,0 ,ROUND(@EarnestMoney,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0)

			END		
	END
	--	----- کل تخفیف به بستانکاری مشتری میرود
	--IF @DiscountAcntCode is not null AND (@Discount + @Discount2 + @TotalLineDiscount) <> 0
	--	BEGIN
	--		SET @strRecDesc2 = ' تخفیف دريافت كالاهاي اماني ما نزد دیگران ' + @strFiscalSerial
	--		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	--		SET @intMaxRowNo = @intMaxRowNo + 1

	--		INSERT INTO acc.tblVoucherDtl
	--			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
	--				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	--			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
	--					@AcntCode,0 ,ROUND(@Discount + @Discount2 + @TotalLineDiscount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0)
	--	END

	----------------------------------------------- پیش دریافت --------------------------------------------
		IF @EarnestMoneyAcntCode <> '' AND @EarnestMoney <> 0
		BEGIN

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@EarnestMoneyAcntCode,0,ROUND(@EarnestMoney,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0)

		END
	--------------------------------------------------------------------------------------------------------
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
				
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				@AcntCode,0 ,ROUND(@SumGoodsPrice - @EarnestMoney - (@Discount + @Discount2 + @TotalLineDiscount),0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0)	

	--------------------------------------------------------------------------------------------------------

	----- کل تخفیف به بدهکاری هزینه میرود
	IF @DiscountAcntCode is not null AND (@Discount + @Discount2 + @TotalLineDiscount) <> 0
	BEGIN
		SET @strRecDesc2 = ' تخفیف فاکتور دريافت كالاهاي اماني ما نزد دیگران شماره' + @strFiscalSerial
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@DiscountAcntCode,0,ROUND(@Discount + @Discount2 + @TotalLineDiscount,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0)
	END

		----------------------------------------------- بازاریاب --------------------------------------------
		IF @VisitorAcntCode	<> '' AND @VisitorCostAcntCode	<> '' AND @VisitorCost <> 0
			BEGIN
				IF @VisitorPercent >0
					BEGIN
						IF @DiscountMinusFromVisitor = 1
							BEGIN	
								SET @VisitorCost2 = (ROUND(@SumGoodsPrice,0) * @VisitorPercent) / 100
							END
						ELSE
							BEGIN
								SET @VisitorCost2 = ((ROUND(@SumGoodsPrice,0) - (@Discount + @Discount2 + @TotalLineDiscount)) * @VisitorPercent) / 100
							END
					END
				IF @VisitorCost2 > 0
					SET @VisitorCost = @VisitorCost2

				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorAcntCode,ROUND(@VisitorCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0)
				--------------------------------------------------------------------------------------------------------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@VisitorCostAcntCode,0,ROUND(@VisitorCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0)

			END		
END
GO
