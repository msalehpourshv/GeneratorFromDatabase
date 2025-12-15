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
Create PROCEDURE [acc].[SpVchReceipt]
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
	Declare @db_0000	NVARCHAR(50);
	Declare @sql		Nvarchar(4000) 
	Declare @ParmDefinition NVarChar(200)
	Declare @strMsgText	NVarChar(2044)
	Declare @PayTypeID	Tinyint
	Declare @BankState	Tinyint
	Declare @Amount		float
	Declare @RowDesc	Nvarchar(1000)	
	Declare @DescHdr	Nvarchar(1000)	
	Declare @CreditCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode1	Varchar(20)
	Declare @AcntCode2	Varchar(20)
	Declare @AcntCode3	Varchar(20)
	Declare @AcntCode5	Varchar(20)
	Declare @AcntCode7	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	Declare @AcntCode	Varchar(20)
	DECLARE @VisitorAcntCode Varchar(20)	
	DECLARE @AcntName   NVarchar(1000)
	DECLARE @DocRowNo   Int
	DECLARE @VolumeRowNo  Int
	DECLARE @AtomAcntCode Varchar(20)
	Declare @CurrencyTypeID	VarChar(20)
	Declare @CurrencyTypeIDDtl	VarChar(20)
	DECLARE @AtomAmount FLOAT 
	Declare @AtomCurrencyAmount	Float
	DECLARE @AtomDesc   Nvarchar(2000)	
	Declare @CurrencyAmount	Float
	Declare @CurrencyAmountAtom	Float
	Declare @CurrencyRate	Float
	Declare @CurrencyRateDtl	Float
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @AcntDiscount  Varchar(20)
	DECLARE @DiscountAmount float
	DECLARE @BaseID Int
	
	DECLARE @CurrencyRateTmp			Float
	DECLARE @CurrencyAmountTmp			Float
	DECLARE @CurrencyTypeIDTmp			VarChar(20)
	DECLARE @BankCodeReplaceWithCustomerCodeInReceive BIT
	Declare @start int 
	Declare @intSourceDocRowNo int 
	 
	DECLARE @UsedPriceDecimalsToFormsInVch BIT
	DECLARE @PriceDecimalsToForms		tinyint 	
 	DECLARE @Has2CurrencyInPay BIT
	Declare @CurrencyRateHdr	Float
	Declare @CurrencyTypeIDHdr	VarChar(20)
	Declare @CurrencyAmountHdr	Float
    Declare @strDocDate			Char(10)	
	DECLARE @strAcntName				NVarChar(500)
	DECLARE @trs_AcntNameInVoucherDesc  BIT
	SELECT @trs_AcntNameInVoucherDesc = SettingValue FROM pub.tblSettings WHERE SettingKey = 'trs_AcntNameInVoucherDesc'

	SET @Has2CurrencyInPay = 'False'

	SELECT   @Has2CurrencyInPay=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Has2CurrencyInPay'	
		
	SET @BankCodeReplaceWithCustomerCodeInReceive = 'False'

	SELECT   @BankCodeReplaceWithCustomerCodeInReceive=SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInReceive'	
	
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))
	
				
	DECLARE @Trs_RegCreditDebitFor2AcntCode BIT;
		
				
	SELECT @Trs_RegCreditDebitFor2AcntCode = SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'Trs_RegCreditDebitFor2AcntCode'

	DECLARE @trs_CurrencyTypeInRow BIT;

	SELECT @trs_CurrencyTypeInRow = SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'trs_CurrencyTypeInRow'

	SET @PriceDecimalsToForms = 0
	SET @UsedPriceDecimalsToFormsInVch='False'

	select @UsedPriceDecimalsToFormsInVch=SettingValue from pub.tblSettings where SettingKey='UsedPriceDecimalsToFormsInVch'

	IF @UsedPriceDecimalsToFormsInVch='True'
		SELECT @PriceDecimalsToForms=SettingValue from pub.tblSettings where SettingKey='PriceDecimalsToForms'

	-----
	SET @CurrencyRate = 0
	SET @CurrencyRateDtl = 0
	SET @CurrencyAmountAtom = 0
	SET @CurrencyAmount = 0
	SET @CurrencyTypeID = ''
	SET @CurrencyTypeIDDtl = ''
	
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''
	
	-----
	SELECT	@VisitorAcntCode=isnull(VisitorAcntCode,''),@CurrencyRateHdr=CurrencyRate,@CurrencyTypeIDHdr=CurrencyTypeID,
			@CurrencyRate=CurrencyRate,@CurrencyTypeID=CurrencyTypeID,@AcntDiscount=AcntDiscount,
			@DiscountAmount=DiscountAmount,@DescHdr=DescHdr, @strDocDate=DocDate
			
	FROM trs.tblPayHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
	
	IF @Has2CurrencyInPay='True' and @CurrencyRateHdr=0 And @CurrencyTypeIDHdr<>''
		BEGIN
				set @strMsgText='نرخ ارز اصلی خالی است'
				Raiserror (@strMsgText,16,1)
				Return
		END	
		IF @strDocDate<>@strVchDate
		BEGIN
				set @strMsgText='تاریخ برگه با سند یکسان نیست'  + '       '+ 'پرداخت' + str(@intSourceSerialNo)
				Raiserror (@strMsgText,16,1)
				Return
		END	
	--------------------------------------------------------------------------------------------------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	RD.CurrencyRate,RD.CurrencyTypeID,PayTypeID,Amount,RowDesc,CreditCode,ChequeNo,ChequeDate,AcntCode1,AcntCode2,AcntCode3,AcntCode5,AcntCode7,BankState,DocRowNo,CurrencyAmount,VolumeRowNo,ID
	FROM trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE RD.DebitCode=OB.BankCode AND
		  RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into  @CurrencyRateDtl,@CurrencyTypeIDDtl,@PayTypeID,@Amount,@RowDesc,@CreditCode,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@AcntCode7,@BankState,@DocRowNo,@CurrencyAmount,@VolumeRowNo,@BaseID

	While (@@Fetch_Status = 0)
		BEGIN
		
			SET @AcntCode = ''
		
			SET @strRecDesc = ' دریافت ' + @strSourceProcessNo + ' ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' -'

			IF @PayTypeID=1
				SET @strRecDesc = @strRecDesc + ' نقد '
			ElSE IF @PayTypeID=2
				SET @strRecDesc = @strRecDesc + ' حواله '			
			ElSE IF @PayTypeID=3
				SET @strRecDesc = @strRecDesc + ' فیش شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه ' + @ChequeDate
			ElSE IF @PayTypeID=4
				SET @strRecDesc = @strRecDesc + ' حواله شماره '  + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه ' + @ChequeDate
			ElSE IF @PayTypeID=6 OR @PayTypeID=26
				SET @strRecDesc = @strRecDesc + ' شماره ردیف ' +  LTRIM(RTRIM(STR(@VolumeRowNo))) + ' چک شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' سررسید ' + @ChequeDate
			ElSE IF @PayTypeID=35
				SET @strRecDesc = @strRecDesc + ' کارتخوان  ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه ' + @ChequeDate
			ElSE IF @PayTypeID=36
				SET @strRecDesc = @strRecDesc + ' کارت هدیه  ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه ' + @ChequeDate
			ElSE IF @PayTypeID=37
				SET @strRecDesc = @strRecDesc + ' بن کارت  ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه ' + @ChequeDate
			ElSE IF @PayTypeID=38
				SET @strRecDesc = @strRecDesc + ' واریز اینترنتی به شماره پیگیری ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه ' + @ChequeDate

			-------------------------------------------
			IF @PayTypeID=1 OR @PayTypeID=3 OR @PayTypeID=4 OR @PayTypeID=5 OR @PayTypeID=35 OR @PayTypeID=38 
				BEGIN

					SET @AcntCode=@AcntCode1

					IF @AcntCode1 = ''
						BEGIN
							IF @BankState=1
								--کد موجودی نقدی صندوق خالی است
								SET @strMsgText=TS.pub.funGetMessages(11017,@LanguageID)

							ELSE IF @BankState=2
								--کد حسابداری تنخواه خالی است
								SET @strMsgText=TS.pub.funGetMessages(11021,@LanguageID)

							ELSE IF @BankState=3
								--کد حسابداری موجودی بانک خالی است
								SET @strMsgText=TS.pub.funGetMessages(11025,@LanguageID)

						END
				END
			
			-------------------------------------------
			ELSE IF @PayTypeID=2
				BEGIN
				IF @BankState=3
					SET @strMsgText=N'مشکل در صدور سند.دریافت کننده در حواله باید صندوق یا تنخواه باشد'
				ELSE
					BEGIN
						SET @AcntCode=@AcntCode3
						IF @AcntCode3=''
							--کد حواله خالی است
							SET @strMsgText=TS.pub.funGetMessages(11023,@LanguageID)
					END
				END

			-------------------------------------------
			ELSE IF @PayTypeID=6 
				BEGIN
					SET @AcntCode=@AcntCode2
					IF @AcntCode2=''
						--كد اسناد دریافتنی تجاری خالی است
						SET @strMsgText=TS.pub.funGetMessages(11018,@LanguageID)
				END

			-------------------------------------------
			ELSE IF @PayTypeID=26 
				BEGIN
					SET @AcntCode=@AcntCode5
					IF @AcntCode5=''
						--كد اسناد دریافتنی غیرتجاری خالی است
						SET @strMsgText=TS.pub.funGetMessages(11020,@LanguageID)
				END
			ELSE  IF @PayTypeID=36
				BEGIN
					SET @AcntCode=@AcntCode7
					IF @AcntCode7=''
						--كد اسناد دریافتنی غیرتجاری خالی است
						SET @strMsgText=TS.pub.funGetMessages(11048,@LanguageID)
				END
			ELSE  IF @PayTypeID=37
				BEGIN
					SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

					SET @sql = 
					'SELECT top 1 @ResaultOUT = H.DebitAcntCode 
					    FROM ' + @db_0000 + '.sal.tblCreditCardDtl D 
						INNER JOIN ' + @db_0000 + '.sal.tblCreditCardHdr H 
						ON H.SerialNo=D.SerialNo 
						WHERE FromDate<=''' + @strVchDate + ''' AND 
							ToDate>=''' + @strVchDate + ''' AND 
							FromCreditCardNo<=' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' AND 
							ToCreditCardNo>=' + LTRIM(RTRIM(STR(@ChequeNo,30)))

					SET @ParmDefinition = N'@ResaultOUT VARCHAR(20) OUTPUT';

					Exec sp_executesql @sql,@ParmDefinition, @ResaultOUT = @AcntCode7 OUTPUT;

					SET @AcntCode=@AcntCode7
					IF @AcntCode7=''
						--كد اسناد دریافتنی غیرتجاری خالی است
						SET @strMsgText=TS.pub.funGetMessages(11048,@LanguageID)
				END

			-------------------------------------------
			IF @strMsgText <> ''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					Raiserror (@strMsgText,16,1)
					Return
				END

			-------------------------------------------
			SET @AcntName = @strRecDesc + ' از '  + pub.GetCodeName(@CreditCode,@LanguageID)

			IF @AcntCode = @CreditCode
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					-- کد بدهکار و بستانکار در سطر %d نمی تواند یکی باشد
					SET @strMsgText=TS.pub.funGetMessages(12079,@LanguageID)
					Raiserror (@strMsgText,16,1,@DocRowNo)
					return
				END			
						
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF [acc].[funIsCurrencyAcntCode] (@AcntCode) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
				if @trs_CurrencyTypeInRow='True'
				begin
					Set @CurrencyRateTmp	= @CurrencyRateDtl
					Set @CurrencyTypeIDTmp  = @CurrencyTypeIDDtl
				end
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End
			
			IF  @BankCodeReplaceWithCustomerCodeInReceive='True' AND (@PayTypeID =6 OR @PayTypeID =16 OR @PayTypeID =26)
			BEGIN
				SET @start = [acc].[FunGetAcntInfoForRemain](2)
				IF LEN(@CreditCode)>@start
					SET @AcntCode = LEFT(pub.funPadRight(@AcntCode,' ',@start-1),@start-1) + SUBSTRING(@CreditCode,@start,20)
			END
						
			IF @trs_AcntNameInVoucherDesc = 'True'
				Select @strAcntName = ' از ' + [pub].GetCodeName(@CreditCode, @LanguageID)
			ELSE
				SET @strAcntName = ''
		
		if  charindex (@strAcntName,@AcntName)=0
				SET @AcntName = @AcntName + @strAcntName		

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,ROUND(@Amount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			


			IF (SELECT COUNT(*) 
				FROM trs.tblPayAtm 
				WHERE ProcessID  = @intSourceProcessID AND 
					  ProcessNo  = @intSourceProcessNo AND 
					  FiscalYear = @intSourceFiscalYear AND 
					  SerialNo   = @intSourceSerialNo AND 
					  DocRowNo   = @DocRowNo) >0
				BEGIN
	
					IF  @Trs_RegCreditDebitFor2AcntCode = 'True'
						begin
					 
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						SET @AcntName = @strRecDesc

						IF @PayTypeID not in (6,26)
							SET @AcntName = @AcntName + ' به '  + pub.GetCodeName(@AcntCode,@LanguageID)
											
						IF [acc].[funIsCurrencyAcntCode] (@CreditCode) = 'True'
						Begin
							Set @CurrencyRateTmp	= @CurrencyRate
							Set @CurrencyAmountTmp  = @CurrencyAmount
							Set @CurrencyTypeIDTmp  = @CurrencyTypeID
							if @trs_CurrencyTypeInRow='True'
							begin
								Set @CurrencyRateTmp	= @CurrencyRateDtl
								Set @CurrencyTypeIDTmp  = @CurrencyTypeIDDtl
							end
						End
						Else
						Begin
							Set @CurrencyRateTmp	= 0
							Set @CurrencyAmountTmp  = 0
							Set @CurrencyTypeIDTmp  = ''
						End
 
 						if  charindex (@strAcntName,@AcntName)=0
							SET @AcntName = @AcntName + @strAcntName									

						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
									@CreditCode,0,ROUND(@Amount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
					
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						SET @AcntName = @strRecDesc

						IF @PayTypeID not in (6,26)
							SET @AcntName = @AcntName + ' به '  + pub.GetCodeName(@AcntCode,@LanguageID)
											
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
									@CreditCode,ROUND(@Amount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
					
					end

					Declare	Cursor_PayAtom CURSOR For 
					SELECT	AtomAcntCode, AtomAmount,AtomCurrencyAmount, AtomDesc
					FROM trs.tblPayAtm 
					WHERE ProcessID	= @intSourceProcessID AND
						  ProcessNo	= @intSourceProcessNo AND
						  FiscalYear= @intSourceFiscalYear AND
						  SerialNo	= @intSourceSerialNo AND
						  DocRowNo   = @DocRowNo	

					Open  Cursor_PayAtom; 

					Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomCurrencyAmount,@AtomDesc

					While (@@Fetch_Status = 0)
						BEGIN

							SET @AcntName = @strRecDesc + ' از '  + pub.GetCodeName(@AtomAcntCode,@LanguageID)

							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1
							
							IF [acc].[funIsCurrencyAcntCode] (@AtomAcntCode) = 'True'
							Begin
								Set @CurrencyRateTmp	= @CurrencyRate
								Set @CurrencyAmountTmp  = @AtomCurrencyAmount
								Set @CurrencyTypeIDTmp  = @CurrencyTypeID
							if @trs_CurrencyTypeInRow='True'
							begin
								Set @CurrencyRateTmp	= @CurrencyRateDtl
								Set @CurrencyTypeIDTmp  = @CurrencyTypeIDDtl
							end

							End
							Else
							Begin
								Set @CurrencyRateTmp	= 0
								Set @CurrencyAmountTmp  = 0
								Set @CurrencyTypeIDTmp  = ''
							End
							IF @CurrencyRateTmp <> 0 	
								SET @CurrencyAmountAtom = ROUND(@AtomAmount,0) / @CurrencyRateTmp

							if  charindex (@strAcntName,@AcntName)=0
								SET @AcntName = @AcntName + @strAcntName		
										
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
										@AtomAcntCode,0,ROUND(@AtomAmount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@AtomDesc,0,@CurrencyAmountTmp ,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
							
------------------------------------------------------------------------------------------------------------------------------
							IF @Has2CurrencyInPay= 'True' And @CurrencyTypeIDHdr<>'' and @CurrencyTypeIDTmp<>@CurrencyTypeIDHdr
								Begin
									SET @intMaxDocRowNo = @intMaxDocRowNo + 1
									SET @intMaxRowNo = @intMaxRowNo + 1

									INSERT INTO acc.tblVoucherDtl
										(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
											AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
									VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
										@AtomAcntCode,ROUND(@AtomAmount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@AtomDesc,0,@CurrencyAmountTmp ,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
							
	 								SET @intMaxDocRowNo = @intMaxDocRowNo + 1
									SET @intMaxRowNo = @intMaxRowNo + 1

									Set @CurrencyAmountTmp=ROUND(@Amount,@PriceDecimalsToForms)/ @CurrencyRateHdr
									Set @CurrencyTypeIDTmp=@CurrencyTypeIDHdr

									INSERT INTO acc.tblVoucherDtl
										(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
											AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
									VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
										@AtomAcntCode,0,ROUND(@AtomAmount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@AtomDesc,0,@CurrencyAmountTmp ,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)											
								End
-------------------------------------------------------------------------------------------------------------------------------	

							Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomCurrencyAmount,@AtomDesc
						END
			
					Close Cursor_PayAtom;
					Deallocate Cursor_PayAtom; 
			
				END
			
			ELSE
			
				BEGIN
				
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1

					SET @AcntName = @strRecDesc

					IF @PayTypeID not in (6,26)
						SET @AcntName = @AcntName + ' به '  + pub.GetCodeName(@AcntCode,@LanguageID)
									
					IF [acc].[funIsCurrencyAcntCode] (@CreditCode) = 'True'
					Begin
						Set @CurrencyRateTmp	= @CurrencyRate
						Set @CurrencyAmountTmp  = @CurrencyAmount
						Set @CurrencyTypeIDTmp  = @CurrencyTypeID
						if @trs_CurrencyTypeInRow='True'
							begin
								Set @CurrencyRateTmp	= @CurrencyRateDtl
								Set @CurrencyTypeIDTmp  = @CurrencyTypeIDDtl
							end

					End
					Else
					Begin
						Set @CurrencyRateTmp	= 0
						Set @CurrencyAmountTmp  = 0
						Set @CurrencyTypeIDTmp  = ''
					End
					DECLARE @Desc as NVARCHAR(1000)													
					SET @Desc = @RowDesc
					IF @RowDesc <>@DescHdr
						SET @Desc =@DescHdr + ' - ' + @Desc
 						
					if  charindex (@strAcntName,@AcntName)=0
						SET @AcntName = @AcntName + @strAcntName		

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
								@CreditCode,0,ROUND(@Amount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@Desc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
								
------------------------------------------------------------------------------------------------------------------------------
					IF @Has2CurrencyInPay= 'True'  And @CurrencyTypeIDHdr<>'' and @CurrencyTypeIDTmp<>@CurrencyTypeIDHdr
						Begin
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
								@CreditCode,ROUND(@Amount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@Desc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			

	 						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							Set @CurrencyAmountTmp=ROUND(@Amount,@PriceDecimalsToForms)/ @CurrencyRateHdr
							Set @CurrencyTypeIDTmp=@CurrencyTypeIDHdr

							INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
								@CreditCode,0,ROUND(@Amount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@Desc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
						End
-------------------------------------------------------------------------------------------------------------------------------				
				END

			Fetch NEXT From Cursor_PayDtl Into @CurrencyRateDtl,@CurrencyTypeIDDtl,@PayTypeID,@Amount,@RowDesc,@CreditCode,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@AcntCode7,@BankState,@DocRowNo,@CurrencyAmount,@VolumeRowNo,@BaseID
		
		END 

if @DiscountAmount>0
begin
	SET @strRecDesc = ' دریافت ' + @strSourceProcessNo + ' ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' -'

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
	SET @AcntName =@strRecDesc+ '   '  +'تخفیف ' + '   '  + pub.GetCodeName(@AcntDiscount,@LanguageID)

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@DiscountAmount,0) / @CurrencyRate

			IF [acc].[funIsCurrencyAcntCode] (@AcntDiscount) = 'True'
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
 			
			if  charindex (@strAcntName,@AcntName)=0
				SET @AcntName = @AcntName + @strAcntName		

						
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntDiscount,ROUND(@DiscountAmount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,10000,@VisitorAcntCode)

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
	
	SET @AcntName =@strRecDesc+'   '  + 'تخفیف ' + '   '  + pub.GetCodeName(@CreditCode,@LanguageID)

		IF [acc].[funIsCurrencyAcntCode] (@CreditCode) = 'True'
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
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
				 @CreditCode,0,ROUND(@DiscountAmount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,10000,@VisitorAcntCode)			

end
	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

END
GO
