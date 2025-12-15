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
Create PROCEDURE [acc].[SpVchReceipt_BRN]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		TinyInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@StrSourceCodeFieldName VARCHAR(200),
	@StrSourceCodeFieldValue VARCHAR(200),
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				Int,
	@LanguageID				TinyInt
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
	DECLARE @AcntName   NVarchar(1000)
	DECLARE @DocRowNo   Int
	DECLARE @VolumeRowNo  Int
	
	create table #tblT (Acnt varchar(20),Amount float)
		  
	--------------------------------------------------------------------------------------------------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	1 PayTypeID,SUM(Amount) Amount,'',D.CreditCode,0 ChequeNo,'' ChequeDate,AcntCode1,''AcntCode2,'' AcntCode3,'' AcntCode5,AcntCode7,1 BankState,0 DocRowNo,0 VolumeRowNo--,ID
	FROM trs.tblPayDtl D
	INNER JOIN trs.tblPayHdr H
	ON  D.ProcessID=H.ProcessID and
		D.ProcessNo=H.ProcessNo and
		D.FiscalYear=H.FiscalYear and
		D.SerialNo=H.SerialNo
	INNER JOIN trs.tblOurBanks OB
	ON D.DebitCode=OB.BankCode 
	WHERE D.ProcessID=@intSourceProcessID AND
		  D.ProcessNo=@intSourceProcessNo AND
		  D.FiscalYear=@intSourceFiscalYear AND
		  H.DocDate=@strVchDate AND 
		  VchNo=0 AND 
		  BRN = @StrSourceCodeFieldValue AND 
		  PayTypeID = 1
	GROUP BY D.CreditCode,AcntCode1,AcntCode7
	UNION ALL	  
	SELECT	PayTypeID,Amount,RowDesc,D.CreditCode,ChequeNo,ChequeDate,AcntCode1,AcntCode2,AcntCode3,AcntCode5,AcntCode7,BankState,DocRowNo,VolumeRowNo
	FROM trs.tblPayDtl D
	INNER JOIN trs.tblPayHdr H
	ON  D.ProcessID=H.ProcessID and
		D.ProcessNo=H.ProcessNo and
		D.FiscalYear=H.FiscalYear and
		D.SerialNo=H.SerialNo
	INNER JOIN trs.tblOurBanks OB
	ON D.DebitCode=OB.BankCode 
	WHERE D.ProcessID=@intSourceProcessID AND
		  D.ProcessNo=@intSourceProcessNo AND
		  D.FiscalYear=@intSourceFiscalYear AND
		  H.DocDate=@strVchDate AND 
		  VchNo=0 AND 
		  BRN = @StrSourceCodeFieldValue AND 
		  PayTypeID <> 1 

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@CreditCode,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@AcntCode7,@BankState,@DocRowNo,@VolumeRowNo

	While (@@Fetch_Status = 0)
		BEGIN
		
			SET @AcntCode = ''

			SET @strRecDesc = ' دریافت شعبه '  + @StrSourceCodeFieldValue + ' به تاریخ ' + @strVchDate

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
					SET @AcntCode=@AcntCode3
					IF @AcntCode3=''
						--کد حواله خالی است
						SET @strMsgText=TS.pub.funGetMessages(11023,@LanguageID)
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
			-------------------------------------------
			ELSE IF @PayTypeID=36  OR @PayTypeID=37
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

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,8,@StrSourceCodeFieldValue)			

			if (select COUNT(*) from #tblT Where Acnt = @CreditCode ) = 0
				INSERT INTO #tblT select @CreditCode,@Amount	
			else
				UPDATE	#tblT SET 	Amount = Amount + 	@Amount
				where Acnt = @CreditCode
													  
			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@CreditCode,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@AcntCode7,@BankState,@DocRowNo,@VolumeRowNo
		
		END 

		Close Cursor_PayDtl;
		Deallocate Cursor_PayDtl; 


	Declare	Cursor_PayCredit CURSOR For 
	select * from #tblT
	Open  Cursor_PayCredit; 

	Fetch NEXT From Cursor_PayCredit Into @CreditCode,@Amount

	While (@@Fetch_Status = 0)
		BEGIN
		
			SET @strRecDesc = ' دریافت شعبه '  + @StrSourceCodeFieldValue + ' به تاریخ ' + @strVchDate
			
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo,@intMaxDocRowNo,
						@CreditCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',8,@StrSourceCodeFieldValue)			
			
			Fetch NEXT From Cursor_PayCredit Into @CreditCode,@Amount
		
		END 

	Close Cursor_PayCredit;
	Deallocate Cursor_PayCredit; 						
END
GO
