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
create PROCEDURE [acc].[SpVchPayment_BRN]
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
	DECLARE @AcntName NVarchar(1000)
	DECLARE @DocRowNo   Int
	DECLARE @IntErrNum  Int
	DECLARE @Cnt  Int
	   
	DECLARE @intMaxRowNo_DebitCode INT,
		@intMaxDocRowNo_DebitCode INT
	--------------------------------------------------------------------------------------------------------
	SET @strMsgText = ''
	
	SELECT	@Cnt = COUNT(*)
	FROM trs.tblPayDtl D
	INNER JOIN trs.tblPayHdr H
	ON  D.ProcessID=H.ProcessID and
		D.ProcessNo=H.ProcessNo and
		D.FiscalYear=H.FiscalYear and
		D.SerialNo=H.SerialNo
	WHERE D.ProcessID=@intSourceProcessID AND
		  D.ProcessNo=@intSourceProcessNo AND
		  D.FiscalYear=@intSourceFiscalYear AND
		  H.DocDate=@strVchDate AND 
		  VchNo=0 AND 
		  BRN = @StrSourceCodeFieldValue 

SET @intMaxRowNo_DebitCode = @intMaxRowNo
SET	@intMaxRowNo_DebitCode=@intMaxDocRowNo

SET @intMaxRowNo = @intMaxRowNo + @Cnt
SET	@intMaxDocRowNo =@intMaxDocRowNo + @Cnt

	create table #tblP (Acnt varchar(20),Amount float)
	-----
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	1 PayTypeID,SUM(Amount) Amount,'',D.DebitCode,0 ChequeNo,'' ChequeDate,AcntCode1,''AcntCode2,'' AcntCode3,'' AcntCode5,AcntCode7,''AccountNo,1 BankState,0 VolumeRowNo,0 VolumeFiscalYear,0 DocRowNo--,ID
	FROM trs.tblPayDtl D
	INNER JOIN trs.tblPayHdr H
	ON  D.ProcessID=H.ProcessID and
		D.ProcessNo=H.ProcessNo and
		D.FiscalYear=H.FiscalYear and
		D.SerialNo=H.SerialNo
	INNER JOIN trs.tblOurBanks OB
	ON D.CreditCode=OB.BankCode 
	WHERE D.ProcessID=@intSourceProcessID AND
		  D.ProcessNo=@intSourceProcessNo AND
		  D.FiscalYear=@intSourceFiscalYear AND
		  H.DocDate=@strVchDate AND 
		  VchNo=0 AND 
		  BRN = @StrSourceCodeFieldValue AND 
		  PayTypeID = 1
	GROUP BY D.DebitCode,AcntCode1,AcntCode7
	UNION ALL	  
	SELECT	PayTypeID,Amount,RowDesc,D.DebitCode,ChequeNo,ChequeDate,AcntCode1,AcntCode2,AcntCode3,AcntCode5,AcntCode7,AccountNo,BankState,VolumeRowNo,VolumeFiscalYear,DocRowNo
	FROM trs.tblPayDtl D
	INNER JOIN trs.tblPayHdr H
	ON  D.ProcessID=H.ProcessID and
		D.ProcessNo=H.ProcessNo and
		D.FiscalYear=H.FiscalYear and
		D.SerialNo=H.SerialNo
	INNER JOIN trs.tblOurBanks OB
	ON D.CreditCode=OB.BankCode 
	WHERE D.ProcessID=@intSourceProcessID AND
		  D.ProcessNo=@intSourceProcessNo AND
		  D.FiscalYear=@intSourceFiscalYear AND
		  H.DocDate=@strVchDate AND 
		  VchNo=0 AND 
		  BRN = @StrSourceCodeFieldValue AND 
		  PayTypeID <> 1 

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@DebitCode,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@AcntCode7,@AccountNo,@BankState,@VolumeRowNo,@VolumeFiscalYear,@DocRowNo

	While (@@Fetch_Status = 0)
		BEGIN
			
			SET @AcntCode = ''
			SET @IntErrNum = 0

			SET @strRecDesc = ' پرداخت شعبه '  + @StrSourceCodeFieldValue + ' به تاریخ ' + @strVchDate

			IF @PayTypeID=1
				SET @strRecDesc = @strRecDesc + ' نقد ' 
			ELSE IF @PayTypeID=2
				SET @strRecDesc = @strRecDesc + ' حواله '
			ELSE IF @PayTypeID=3
				SET @strRecDesc = @strRecDesc + ' فیش شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه ' + @ChequeDate
			ELSE IF @PayTypeID=4
				SET @strRecDesc = @strRecDesc + ' حواله شماره '  + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه ' + @ChequeDate
			ELSE IF @PayTypeID=5
                SET @strRecDesc = @strRecDesc + ' برداشت از حساب به مدرک شماره ' + @AccountNo + ' مورخه ' + @ChequeDate
			ELSE IF @PayTypeID=6 OR @PayTypeID=26
				SET @strRecDesc = @strRecDesc + ' چک اشخاص شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' سررسید ' + @ChequeDate
			ELSE IF @PayTypeID=7
				SET @strRecDesc = @strRecDesc + ' چک شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' سررسید ' + @ChequeDate
			ELSE IF @PayTypeID=8 OR @PayTypeID=28
				SET @strRecDesc = @strRecDesc + ' شماره ردیف ' +  LTRIM(RTRIM(STR(@VolumeRowNo))) + ' چک شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' سررسید ' + @ChequeDate
			ELSE IF @PayTypeID=36
				SET @strRecDesc = @strRecDesc + ' کارت هدیه  ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' مورخه ' + @ChequeDate

			-----------------------------------------------------
			IF @PayTypeID=1 OR @PayTypeID=3 OR @PayTypeID=4 OR @PayTypeID=5 OR @PayTypeID=7
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

				END ---- IF @PayTypeID=1 OR @PayTypeID=3 OR @PayTypeID=4 OR @PayTypeID=5 OR @PayTypeID=7

			-----------------------------------------------------
			ELSE IF @PayTypeID=2
				BEGIN
					SET @AcntCode=@AcntCode3
					IF @AcntCode3=''
						--کد حواله صندوق خالی است
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
								--كد اسناد دریافتنی تجاری خالی است
								SET @strMsgText=TS.pub.funGetMessages(11018,@LanguageID)
						END
					ELSE IF @TempPayTypeID=26
						BEGIN
							SET @AcntCode=@AcntCode5
							IF @AcntCode=''
								--كد اسناد دریافتنی غیر تجاری خالی است
								SET @strMsgText=TS.pub.funGetMessages(11024,@LanguageID)
						END
					ELSE 
						BEGIN
							SET @IntErrNum = 11041
							--برگ دریافت سند دریافتنی شماره دفتر $D یافت نشد 
							SET @strMsgText=TS.pub.funGetMessages(11041,@LanguageID)
						END
				END

			-----------------------------------------------------
			ELSE IF @PayTypeID=8
				BEGIN
					SET @AcntCode=@AcntCode2
					IF @AcntCode2=''
						--كد حسابداري اسناد پرداختني تجاری خالی است
						SET @strMsgText=TS.pub.funGetMessages(11026,@LanguageID)
				END

			-----------------------------------------------------
			ELSE IF @PayTypeID=28
				BEGIN
					SET @AcntCode=@AcntCode5
					IF @AcntCode5=''
						--كد حسابداري اسناد پرداختني غیرتجاری خالی است
						SET @strMsgText=TS.pub.funGetMessages(11028,@LanguageID)
				END
			-----------------------------------------------------
			ELSE IF @PayTypeID=36
				BEGIN
					SET @AcntCode=@AcntCode7
					IF @AcntCode7=''
						--كد حسابداري اسناد پرداختني غیرتجاری خالی است
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
					-- کد بدهکار و بستانکار در سطر %d نمی تواند یکی باشد
					SET @strMsgText=TS.pub.funGetMessages(12079,@LanguageID)
					Raiserror (@strMsgText,16,1,@DocRowNo)
					return
				END	
				
			if (select COUNT(*) from #tblP Where Acnt = @DebitCode ) = 0
				INSERT INTO #tblP select @DebitCode,@Amount	
			else
				UPDATE	#tblP SET 	Amount = Amount + 	@Amount
				where Acnt = DebitCode
			-----------------------------------------------------
			SET @AcntName =@strRecDesc 
			SET @AcntName =@AcntName + ' به '  + pub.GetCodeName(@DebitCode,@LanguageID)
					
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,8 ,@StrSourceCodeFieldValue)		

			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@DebitCode,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@AcntCode7,@AccountNo,@BankState,@VolumeRowNo,@VolumeFiscalYear,@DocRowNo

		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

	Declare	Cursor_PayDebit CURSOR For 
	select * from #tblP
	Open  Cursor_PayDebit; 

	Fetch NEXT From Cursor_PayDebit Into @DebitCode,@Amount

	While (@@Fetch_Status = 0)
		BEGIN
				
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			SET @strRecDesc = ' پرداخت شعبه '  + @StrSourceCodeFieldValue + ' به تاریخ ' + @strVchDate
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,SourceCodeFieldValue) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@DebitCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',8,@StrSourceCodeFieldValue)			
			
			Fetch NEXT From Cursor_PayDebit Into @DebitCode,@Amount
		
		END 

	Close Cursor_PayDebit;
	Deallocate Cursor_PayDebit; 	

END
GO
