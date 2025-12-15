USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--use TS_HamilaMehr_1_1403
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 86/11/23
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchPayment]
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
	Declare @strMsgText	 NVarChar(2044)
	Declare @PayTypeID	Tinyint
	Declare @BankState	Tinyint
	Declare @Amount		float
	Declare @RowDesc	Nvarchar(1000)	
	Declare @DebitCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode1	Varchar(20)
	Declare @AcntCode2	Varchar(20)
	Declare @AcntCode3	Varchar(20)
	Declare @AcntCode5	Varchar(20)
	Declare @AcntCode7	Varchar(20)
	Declare @AccountNo	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	Declare @VolumeRowNo INT
	Declare @VolumeFiscalYear SmallInt
	DECLARE @AcntCode Varchar(20)
	DECLARE @VisitorAcntCode Varchar(20)	
	DECLARE @AcntName NVarchar(1000)
	DECLARE @AcntTempName NVarchar(1000)
	DECLARE @DocRowNo   Int
	DECLARE @IntErrNum  Int
	DECLARE @AtomAcntCode Varchar(20)
	Declare @CurrencyTypeID	VarChar(20)
	Declare @CurrencyTypeIDDtl	VarChar(20)
	Declare @CurrencyTypeIDTemp	VarChar(20)
	DECLARE @AtomAmount FLOAT 
	Declare @AtomCurrencyAmount	Float
	DECLARE @AtomDesc   Nvarchar(2000)	
	Declare @CurrencyAmount	Float
	Declare @CurrencyAmountAtom	Float
	Declare @CurrencyRate	Float
	Declare @CurrencyRateDtl	Float
	   
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @AcntDiscount  Varchar(20)
	DECLARE  @DiscountAmount float
	DECLARE @BaseID Int
	
	Declare @CurrencyRateTmp			Float
	Declare @CurrencyAmountTmp			Float
	Declare @CurrencyTypeIDTmp			VarChar(20)
	
	DECLARE @UsedPriceDecimalsToFormsInVch BIT
	DECLARE @PriceDecimalsToForms		tinyint 	

	DECLARE @BankCodeReplaceWithCustomerCodeInPayment BIT
	DECLARE @BankCodeReplaceWithCustomerCodeInReceive BIT
	Declare @start int 
	DECLARE @Has2CurrencyInPay BIT
	DECLARE @Payment_HasCreditForAllRowsInAtom BIT
	Declare @CurrencyRateHdr	Float
	Declare @CurrencyTypeIDHdr	VarChar(20)
	Declare @CurrencyAmountHdr	Float
	DECLARE @strAcntName				NVarChar(500)
	DECLARE @trs_AcntNameInVoucherDesc  BIT
	SELECT @trs_AcntNameInVoucherDesc = SettingValue FROM pub.tblSettings WHERE SettingKey = 'trs_AcntNameInVoucherDesc'

	SET @Has2CurrencyInPay = 'False'
	SET @Payment_HasCreditForAllRowsInAtom = 'False'

	SELECT   @Has2CurrencyInPay=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Has2CurrencyInPay'	
	SELECT   @Payment_HasCreditForAllRowsInAtom=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Payment_HasCreditForAllRowsInAtom'	
	

	SET @BankCodeReplaceWithCustomerCodeInPayment = 'False'
	SET @BankCodeReplaceWithCustomerCodeInReceive = 'False'

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
	
	SELECT   @BankCodeReplaceWithCustomerCodeInPayment=SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInPayment'
	
	SELECT   @BankCodeReplaceWithCustomerCodeInReceive=SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInReceive'	

	SET @PriceDecimalsToForms = 0
	SET @UsedPriceDecimalsToFormsInVch='False'

	select @UsedPriceDecimalsToFormsInVch=SettingValue from pub.tblSettings where SettingKey='UsedPriceDecimalsToFormsInVch'

	IF @UsedPriceDecimalsToFormsInVch='True'
		SELECT @PriceDecimalsToForms=SettingValue from pub.tblSettings where SettingKey='PriceDecimalsToForms'

	--------------------------------------------------------------------------------------------------------
	SET @strMsgText = ''
	SET @CurrencyRate = 0
	SET @CurrencyRateDtl = 0
	SET @CurrencyAmountAtom = 0
	SET @CurrencyAmount = 0
	SET @CurrencyTypeID = ''
	SET @CurrencyTypeIDDtl = ''
	SET @AcntTempName = ''
	SET @CurrencyTypeIDTemp = ''
	
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''
	
	-----
	SELECT	@VisitorAcntCode=isnull(VisitorAcntCode,''),@CurrencyRateHdr=CurrencyRate,@CurrencyTypeIDHdr=CurrencyTypeID,
			@CurrencyRate=CurrencyRate,@CurrencyTypeID=CurrencyTypeID,@AcntDiscount=AcntDiscount,@DiscountAmount=DiscountAmount
	FROM trs.tblPayHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
	IF @Has2CurrencyInPay='True' and @CurrencyRateHdr=0 And @CurrencyTypeIDHdr<>''
		BEGIN
				set @strMsgText='نرخ ارز اصلي خالي است'
				Raiserror (@strMsgText,16,1)
				Return
		END	
	-----
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	RD.CurrencyRate,RD.CurrencyTypeID,PayTypeID,Amount,RowDesc,DebitCode,ChequeNo,ChequeDate,AcntCode1,AcntCode2,AcntCode3,AcntCode5,AcntCode7,AccountNo,BankState,VolumeRowNo,VolumeFiscalYear,DocRowNo,CurrencyAmount,RD.ID
	FROM trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE RD.CreditCode=OB.BankCode AND
		  RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into  @CurrencyRateDtl,@CurrencyTypeIDDtl,@PayTypeID,@Amount,@RowDesc,@DebitCode,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@AcntCode7,@AccountNo,@BankState,@VolumeRowNo,@VolumeFiscalYear,@DocRowNo,@CurrencyAmount,@BaseID

	While (@@Fetch_Status = 0)
		BEGIN
			--SET @IsAtom='False'
			
			SET @AcntCode = ''
			SET @IntErrNum = 0
								
			IF @trs_AcntNameInVoucherDesc = 'True'
				Select @strAcntName = ' از ' + [pub].GetCodeName(@DebitCode, @LanguageID)
			ELSE
				SET @strAcntName = ''
		

			SET @strRecDesc = ' پرداخت ' + @strSourceProcessNo + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' -'

			IF @PayTypeID=1
				SET @strRecDesc = @strRecDesc + ' نقد ' 
			ELSE IF @PayTypeID=2
				SET @strRecDesc = @strRecDesc + ' حواله '
			ELSE IF @PayTypeID=3
			BEGIN
				SET @strRecDesc = @strRecDesc + ' فيش '
				IF @ChequeNo <> 0
					SET @strRecDesc = @strRecDesc + 'شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) 
				IF LTRIM(RTRIM(@ChequeDate)) <> ''
					SET @strRecDesc = @strRecDesc + ' مورخه ' + @ChequeDate
			END
			ELSE IF @PayTypeID=4
			BEGIN
				SET @strRecDesc = @strRecDesc + ' حواله '
				IF @ChequeNo <> 0
					SET @strRecDesc = @strRecDesc + 'شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) 
				IF LTRIM(RTRIM(@ChequeDate)) <> ''
					SET @strRecDesc = @strRecDesc + ' مورخه ' + @ChequeDate
			END
			ELSE IF @PayTypeID=5
			BEGIN
				SET @strRecDesc = @strRecDesc + ' برداشت از حساب '
				IF @ChequeNo <> 0
					SET @strRecDesc = @strRecDesc + 'به مدرک شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) 
				IF LTRIM(RTRIM(@ChequeDate)) <> ''
					SET @strRecDesc = @strRecDesc + ' مورخه ' + @ChequeDate
			END
			ELSE IF @PayTypeID=6 OR @PayTypeID=26
			BEGIN
				SET @strRecDesc = @strRecDesc + ' چک اشخاص '
				IF @ChequeNo <> 0
					SET @strRecDesc = @strRecDesc + 'شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) 
				IF LTRIM(RTRIM(@ChequeDate)) <> ''
					SET @strRecDesc = @strRecDesc + ' سررسيد ' + @ChequeDate
			END
			ELSE IF @PayTypeID=7
				SET @strRecDesc = @strRecDesc + ' چک شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' سررسيد ' + @ChequeDate
			ELSE IF @PayTypeID=8 OR @PayTypeID=28
				SET @strRecDesc = @strRecDesc + ' شماره رديف ' +  LTRIM(RTRIM(STR(@VolumeRowNo))) + ' چک شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' سررسيد ' + @ChequeDate
			ELSE IF @PayTypeID=36
				SET @strRecDesc = @strRecDesc + ' کارت هديه  ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه ' + @ChequeDate

			-----------------------------------------------------
			IF @PayTypeID=1 OR @PayTypeID=3 OR @PayTypeID=4 OR @PayTypeID=5 OR @PayTypeID=7  
				BEGIN
			
					SET @AcntCode=@AcntCode1

					IF @AcntCode1 = ''
						BEGIN 
							IF @BankState=1 
								--کد موجودي نقدي صندوق خالي است
								SET @strMsgText=TS.pub.funGetMessages(11017,@LanguageID)

							ELSE IF @BankState=2 
								--کد حسابداري تنخواه خالي است
								SET @strMsgText=TS.pub.funGetMessages(11021,@LanguageID)

							ELSE IF @BankState=3 
								--کد حسابداري موجودي بانک خالي است
								SET @strMsgText=TS.pub.funGetMessages(11025,@LanguageID)
						END

				END ---- IF @PayTypeID=1 OR @PayTypeID=3 OR @PayTypeID=4 OR @PayTypeID=5 OR @PayTypeID=7

			-----------------------------------------------------
			ELSE IF @PayTypeID=2
				BEGIN
					SET @AcntCode=@AcntCode3
					IF @AcntCode3=''
						--کد حواله صندوق خالي است
						SET @strMsgText=TS.pub.funGetMessages(11019,@LanguageID)
				END

			-----------------------------------------------------
			ELSE IF @PayTypeID=6 OR @PayTypeID=26
				BEGIN
					Declare @TempPayTypeID AS TinyInt
					SELECT @TempPayTypeID=PayTypeID
					FROM trs.tblPayDtl
					WHERE	ProcessID IN (1,10) AND
							VolumeFiscalYear=@VolumeFiscalYear AND
							VolumeRowNo=@VolumeRowNo

					IF @TempPayTypeID=6
						BEGIN
							SET @AcntCode=@AcntCode2
							IF @AcntCode=''
								--كد اسناد دريافتني تجاري خالي است
								SET @strMsgText=TS.pub.funGetMessages(11018,@LanguageID)
						END
					ELSE IF @TempPayTypeID=26
						BEGIN
							SET @AcntCode=@AcntCode5
							IF @AcntCode=''
								--كد اسناد دريافتني غير تجاري خالي است
								SET @strMsgText=TS.pub.funGetMessages(11024,@LanguageID)
						END
					ELSE 
						BEGIN
							SET @IntErrNum = 11041
							--برگ دريافت سند دريافتني شماره دفتر $D يافت نشد 
							SET @strMsgText=TS.pub.funGetMessages(11041,@LanguageID)
						END
				END

			-----------------------------------------------------
			ELSE IF @PayTypeID=8
				BEGIN
					SET @AcntCode=@AcntCode2
					IF @AcntCode2=''
						--كد حسابداري اسناد پرداختني تجاري خالي است
						SET @strMsgText=TS.pub.funGetMessages(11026,@LanguageID)
				END

			-----------------------------------------------------
			ELSE IF @PayTypeID=28
				BEGIN
					SET @AcntCode=@AcntCode5
					IF @AcntCode5=''
						--كد حسابداري اسناد پرداختني غيرتجاري خالي است
						SET @strMsgText=TS.pub.funGetMessages(11028,@LanguageID)
				END
			-----------------------------------------------------
			ELSE IF @PayTypeID=36
				BEGIN
					SET @AcntCode=@AcntCode7
					IF @AcntCode7=''
						--كد حسابداري اسناد پرداختني غيرتجاري خالي است
						SET @strMsgText=TS.pub.funGetMessages(11048,@LanguageID)
				END

			-----------------------------------------------------
			IF @strMsgText <> ''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					IF @IntErrNum = 11041
					    Raiserror (@strMsgText,16,1,@VolumeRowNo)
					ELSE
					    Raiserror (@strMsgText,16,1)
					    
					Return
				END
			
			-----------------------------------------------------
			SET @AcntName =@strRecDesc 

			IF @AcntCode = @DebitCode
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					-- کد بدهکار و بستانکار در سطر %d نمي تواند يکي باشد
					SET @strMsgText=TS.pub.funGetMessages(12079,@LanguageID)
					Raiserror (@strMsgText,16,1,@DocRowNo)
					return
				END	

			DECLARE @ControlAtomAmount as bit = 'False'				
			IF (SELECT COUNT(*) 
				FROM trs.tblPayAtm 
				WHERE ProcessID  = @intSourceProcessID AND 
					  ProcessNo  = @intSourceProcessNo AND 
					  FiscalYear = @intSourceFiscalYear AND 
					  SerialNo   = @intSourceSerialNo AND 
					  DocRowNo   = @DocRowNo) >0
				BEGIN
					set @ControlAtomAmount = 'True'

					declare @AtmAcnt as VARCHAR(20)
					SET @AtmAcnt = ''
				
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
							IF @PayTypeID not in (6,26)
							
								SET @AcntName = @strRecDesc + ' از '  + pub.GetCodeName(@AcntCode,@LanguageID)
							
							IF @AtomAcntCode <>@AtmAcnt
								SET @AcntTempName = @AcntTempName + ' به '  + pub.GetCodeName(@AtomAcntCode,@LanguageID)							
							
							SET @AtmAcnt = @AtomAcntCode

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
										AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
										@AtomAcntCode,ROUND(@AtomAmount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@AtomDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp ,@BaseID,@VisitorAcntCode)			
------------------------------------------------------------------------------------------------------------------------------
							IF @Has2CurrencyInPay= 'True' And @CurrencyTypeIDHdr<>''  and @CurrencyTypeIDTmp<>@CurrencyTypeIDHdr
								Begin
									SET @intMaxDocRowNo = @intMaxDocRowNo + 1
									SET @intMaxRowNo = @intMaxRowNo + 1

									INSERT INTO acc.tblVoucherDtl
										(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
											AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
									VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
										@AtomAcntCode,0,ROUND(@AtomAmount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@AtomDesc,0,@CurrencyAmountTmp ,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
							
	 								SET @intMaxDocRowNo = @intMaxDocRowNo + 1
									SET @intMaxRowNo = @intMaxRowNo + 1

									Set @CurrencyAmountTmp=ROUND(@Amount,@PriceDecimalsToForms)/ @CurrencyRateHdr
									Set @CurrencyTypeIDTmp=@CurrencyTypeIDHdr

									INSERT INTO acc.tblVoucherDtl
										(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
											AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
									VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
										@AtomAcntCode,ROUND(@AtomAmount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@AtomDesc,0,@CurrencyAmountTmp ,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)											
								End
							IF @Payment_HasCreditForAllRowsInAtom = 'True'
							begin
									SET @AcntName =@strRecDesc 
									SET @AcntName =@AcntName + ' به '  + pub.GetCodeName(@DebitCode,@LanguageID)
									IF @AcntTempName <>''
									begin
											SET @AcntName = @strRecDesc +  @AcntTempName
											set @AcntTempName = ''
									end
					
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

									IF  @BankCodeReplaceWithCustomerCodeInPayment='True' AND (@PayTypeID =8 OR @PayTypeID =28)
									BEGIN
										SET @start = [acc].[FunGetAcntInfoForRemain](2)
										IF LEN(@DebitCode)>@start
											SET @AcntCode = LEFT(pub.funPadRight(@AcntCode,' ',@start-1),@start-1) + SUBSTRING(@DebitCode,@start,20)
									END
									IF  @BankCodeReplaceWithCustomerCodeInReceive='True' AND (@PayTypeID =6 OR @PayTypeID =16 OR @PayTypeID =26)
									BEGIN
										DECLARE @CustomerCode1 varchar(20)
										SELECT Top 1 @CustomerCode1 = CreditCode
										FROM	trs.tblPayDtl
										WHERE	ProcessID IN (1,10) AND 
												PayTypeID IN (6,16,26) AND 
												VolumeFiscalYear = @VolumeFiscalYear AND 
												VolumeRowNo = @VolumeRowNo
										ORDER By EventNo ASC
										SET @start = [acc].[FunGetAcntInfoForRemain](2)
										IF LEN(@DebitCode)>@start
											SET @AcntCode = LEFT(pub.funPadRight(@AcntCode,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode1,@start,20)
									END

									INSERT INTO acc.tblVoucherDtl
										(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
											AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
									VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
										@AcntCode,0,ROUND(@AtomAmount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@AtomDesc,0,@CurrencyAmountTmp ,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			

							end
-------------------------------------------------------------------------------------------------------------------------------	

							Fetch NEXT From Cursor_PayAtom Into @AtomAcntCode,@AtomAmount,@AtomCurrencyAmount,@AtomDesc
						END
					Close Cursor_PayAtom;
					Deallocate Cursor_PayAtom; 

					--IF @BankCodeReplaceWithCustomerCodeInPayment='True' AND (@PayTypeID =8 OR @PayTypeID =28)
					--BEGIN
					--	SET @start = [acc].[FunGetAcntInfoForRemain](2)
						
					--	Declare	Cursor_GroupPayAtom CURSOR For 
					--	SELECT	SUBSTRING(AtomAcntCode,@start,20) AtomAcntCode, SUM(AtomAmount) AtomAmount
					--	FROM trs.tblPayAtm 
					--	WHERE ProcessID	= @intSourceProcessID AND
					--		  ProcessNo	= @intSourceProcessNo AND
					--		  FiscalYear= @intSourceFiscalYear AND
					--		  SerialNo	= @intSourceSerialNo AND
					--		  DocRowNo   = @DocRowNo
					--	GROUP BY SUBSTRING(AtomAcntCode,@start,20)	  

					--	Open  Cursor_GroupPayAtom; 

					--	Fetch NEXT From Cursor_GroupPayAtom Into @AtomAcntCode,@AtomAmount

					--	While (@@Fetch_Status = 0)
					--		BEGIN

					--		SET @IsAtom='True'
					--		--IF LEN(@AtomAcntCode)>@start
					--			SET @AcntCode = LEFT(pub.funPadRight(@AcntCode,' ',@start-1),@start-1) + @AtomAcntCode

					--		SET @AcntName =@strRecDesc 
					--		SET @AcntName =@AcntName + ' به '  + pub.GetCodeName(@DebitCode,@LanguageID)
					--		IF @AcntTempName <>''
					--		begin
					--				SET @AcntName = @strRecDesc +  @AcntTempName
					--				set @AcntTempName = ''
					--		end
					
					--			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					--			SET @intMaxRowNo = @intMaxRowNo + 1

					--			IF [acc].[funIsCurrencyAcntCode] (@AcntCode) = 'True'
					--			Begin
					--				Set @CurrencyRateTmp	= @CurrencyRate
					--				Set @CurrencyAmountTmp  = @CurrencyAmount
					--				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
					--				if @trs_CurrencyTypeInRow='True'
					--				begin
					--					Set @CurrencyRateTmp	= @CurrencyRateDtl
					--					Set @CurrencyTypeIDTmp  = @CurrencyTypeIDDtl
					--				end
					--			End
					--			Else
					--			Begin
					--				Set @CurrencyRateTmp	= 0
					--				Set @CurrencyAmountTmp  = 0
					--				Set @CurrencyTypeIDTmp  = ''
					--			End						
					--		INSERT INTO acc.tblVoucherDtl
					--				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					--					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
					--		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					--					@AcntCode,0,ROUND(@AtomAmount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)		
					
					
					--		Fetch NEXT From Cursor_GroupPayAtom Into @AtomAcntCode,@AtomAmount
					--		END
					--	Close Cursor_GroupPayAtom;
					--	Deallocate Cursor_GroupPayAtom; 	
					--END


					
					IF  @Trs_RegCreditDebitFor2AcntCode = 'True'
					begin
						IF @PayTypeID not in (6,26)
							SET @AcntName = @AcntName + ' از '  + pub.GetCodeName(@AcntCode,@LanguageID)

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
					IF [acc].[funIsCurrencyAcntCode] (@DebitCode) = 'True'
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
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@DebitCode,0,ROUND(@Amount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
		
						IF @PayTypeID not in (6,26)
							SET @AcntName = @AcntName + ' از '  + pub.GetCodeName(@AcntCode,@LanguageID)

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						IF [acc].[funIsCurrencyAcntCode] (@DebitCode) = 'True'
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
							
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
									@DebitCode,ROUND(@Amount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
		
	
					end


				END
			ELSE
				BEGIN
					IF @PayTypeID not in (6,26)
						SET @AcntName = @AcntName + ' از '  + pub.GetCodeName(@AcntCode,@LanguageID)

					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
 
					IF [acc].[funIsCurrencyAcntCode] (@DebitCode) = 'True'
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
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@DebitCode,ROUND(@Amount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
	------------------------------------------------------------------------------------------------------------------------------
					IF @Has2CurrencyInPay= 'True'  And @CurrencyTypeIDHdr<>''  and @CurrencyTypeIDTmp<>@CurrencyTypeIDHdr
						Begin
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
								@DebitCode,0,ROUND(@Amount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			

	 						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1

							Set @CurrencyAmountTmp=ROUND(@Amount,@PriceDecimalsToForms)/ @CurrencyRateHdr
							Set @CurrencyTypeIDTmp=@CurrencyTypeIDHdr

							INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo,@intMaxDocRowNo,
								@DebitCode,ROUND(@Amount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			
						End
-------------------------------------------------------------------------------------------------------------------------------				
	
				END
			-----------------------------------------------------
			IF @Payment_HasCreditForAllRowsInAtom = 'False' or @ControlAtomAmount = 'False'
			BEGIN
					SET @AcntName =@strRecDesc 
					SET @AcntName =@AcntName + ' به '  + pub.GetCodeName(@DebitCode,@LanguageID)
					IF @AcntTempName <>''
					begin
							SET @AcntName = @strRecDesc +  @AcntTempName
							set @AcntTempName = ''
					end
					
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

					IF  @BankCodeReplaceWithCustomerCodeInPayment='True' AND (@PayTypeID =8 OR @PayTypeID =28)
					BEGIN
						SET @start = [acc].[FunGetAcntInfoForRemain](2)
						IF LEN(@DebitCode)>@start
							SET @AcntCode = LEFT(pub.funPadRight(@AcntCode,' ',@start-1),@start-1) + SUBSTRING(@DebitCode,@start,20)
					END
					IF  @BankCodeReplaceWithCustomerCodeInReceive='True' AND (@PayTypeID =6 OR @PayTypeID =16 OR @PayTypeID =26)
					BEGIN
						DECLARE @CustomerCode varchar(20)
						SELECT Top 1 @CustomerCode = CreditCode
						FROM	trs.tblPayDtl
						WHERE	ProcessID IN (1,10) AND 
								PayTypeID IN (6,16,26) AND 
								VolumeFiscalYear = @VolumeFiscalYear AND 
								VolumeRowNo = @VolumeRowNo
						ORDER By EventNo ASC
						SET @start = [acc].[FunGetAcntInfoForRemain](2)
						IF LEN(@DebitCode)>@start
							SET @AcntCode = LEFT(pub.funPadRight(@AcntCode,' ',@start-1),@start-1) + SUBSTRING(@CustomerCode,@start,20)
					END
					--IF @IsAtom='False'			
					if  charindex (@strAcntName,@AcntName)=0
						SET @AcntName = @AcntName + @strAcntName	

					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceDocRowNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID ,BaseID,VisitorAcntCode) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@DocRowNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
								@AcntCode,0,ROUND(@Amount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0 ,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)		
			END
			Fetch NEXT From Cursor_PayDtl Into  @CurrencyRateDtl,@CurrencyTypeIDDtl,@PayTypeID,@Amount,@RowDesc,@DebitCode,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@AcntCode7,@AccountNo,@BankState,@VolumeRowNo,@VolumeFiscalYear,@DocRowNo,@CurrencyAmount,@BaseID

		END

		
if @DiscountAmount>0
begin
	SET @strRecDesc = ' پرداخت ' + @strSourceProcessNo + ' ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' -'

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
	SET @AcntName =@strRecDesc+ '   '  +'تخفيف ' + '   '  + pub.GetCodeName(@AcntDiscount,@LanguageID)

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
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,0,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntDiscount,0,ROUND(@DiscountAmount,@PriceDecimalsToForms),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
	
	SET @AcntName = @strRecDesc + ' '  + 'تخفيف ' + ' ' + pub.GetCodeName(@DebitCode,@LanguageID)

	IF [acc].[funIsCurrencyAcntCode] (@DebitCode) = 'True'
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
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,0,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					@DebitCode,ROUND(@DiscountAmount,@PriceDecimalsToForms),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID,@VisitorAcntCode)			

end
	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

END
GO
