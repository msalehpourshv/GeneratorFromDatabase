USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 88/03/04
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchPayableTrust]
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
	Declare @strMsgText	 NVarChar(2044)
	Declare @PayTypeID	Tinyint
	Declare @BankState	Tinyint
	Declare @Amount		float
	Declare @RowDesc	Nvarchar(200)	
	Declare @DebitCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode4	Varchar(20)
	Declare @AcntCode6	Varchar(20)
	Declare @strRecDesc NVarChar(500)
	Declare @CurrencyAmount	Float
	Declare @CurrencyAmountTmp Float
	Declare @CurrencyRate	Float
	Declare @CurrencyTypeID	VarChar(20)
	Declare @CurrencyTypeIDTmp	VarChar(20)
	DECLARE @CurrencyRateTmp	Float
	
	--------------------------------------------------------------------------------------------------------
	DECLARE @CurrentDate DATETIME
	DECLARE @BaseID Int
	
	SET @CurrencyRate = 0
	SET @CurrencyAmount = 0
	SET @CurrencyTypeID = ''
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''
	
	SET @CurrentDate = GETDATE()
    
	DECLARE @strSourceProcessNo NVARCHAR(100)
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))
	-----
	SELECT	@CurrencyRate=CurrencyRate,@CurrencyTypeID=CurrencyTypeID
	FROM trs.tblPayHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 		
	-----
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,ChequeNo,ChequeDate,AcntCode4,DebitCode,BankState,CurrencyAmount,AcntCode6,RD.ID
	FROM trs.tblPayDtl RD ,trs.tblOurBanks OB
	WHERE RD.CreditCode =OB.BankCode AND
		  RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@AcntCode4,@DebitCode,@BankState,@CurrencyAmount,@AcntCode6,@BaseID

	While (@@Fetch_Status = 0)
		BEGIN
			 
			 IF @PayTypeID=18 or @PayTypeID=33
			 BEGIN
			 	 IF @BankState<>3
					BEGIN
						Close Cursor_PayDtl;
						Deallocate Cursor_PayDtl; 
						-- نوع کد در تعاریف بانکها عوض شده است
						SET @strMsgText=TS.pub.funGetMessages(11033,@LanguageID)
						Raiserror (@strMsgText,16,1)
						Return
					END
					
				IF @AcntCode4=''
					BEGIN
						Close Cursor_PayDtl;
						Deallocate Cursor_PayDtl; 				
						--كد حسابداري اسناد تضمینی ما نزد دیگران خالی است
						SET @strMsgText=TS.pub.funGetMessages(11034,@LanguageID)
						Raiserror (@strMsgText,16,1)
						Return
					END
			 END
			 
			  IF @PayTypeID=32
			 BEGIN
			 	 IF @BankState<>1
					BEGIN
						Close Cursor_PayDtl;
						Deallocate Cursor_PayDtl; 
						-- نوع کد در تعاریف صندوق عوض شده است
						SET @strMsgText=TS.pub.funGetMessages(11036,@LanguageID)
						Raiserror (@strMsgText,16,1)
						Return
					END
					
				IF @AcntCode6=''
					BEGIN
						Close Cursor_PayDtl;
						Deallocate Cursor_PayDtl; 				
						--كد حسابداري اسناد تضمینی ما نزد دیگران خالی است
						SET @strMsgText=TS.pub.funGetMessages(11034,@LanguageID)
						Raiserror (@strMsgText,16,1)
						Return
					END
					
				SET @AcntCode4 = @AcntCode6	
			 END

			IF @PayTypeID=18
			BEGIN
					SET @strRecDesc = ' اسناد تضمینی ما نزد دیگران ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
								  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate
			END
		
			IF @PayTypeID=32
			BEGIN
					SET @strRecDesc = ' اسناد تضمینی ما نزد دیگران ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
								  ' به شماره سفته ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate
			END
			
			IF @PayTypeID=33
			BEGIN
					SET @strRecDesc = ' اسناد تضمینی ما نزد دیگران ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
								  ' به شماره ضمانتنامه ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate
			END
						
			-----	
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

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
	
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@DebitCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID)			

			-----
			DECLARE @FillPayableTrustAcntCodeFromDebit  VARCHAR(50)
			SET @FillPayableTrustAcntCodeFromDebit = 'False'
			
			SELECT @FillPayableTrustAcntCodeFromDebit = SettingValue 
			FROM pub.tblSettings 
			WHERE SettingKey = 'FillPayableTrustAcntCodeFromDebit'
			
			
			IF @FillPayableTrustAcntCodeFromDebit='True' AND LEN(@DebitCode)>LEN(@AcntCode4)
				BEGIN
					SET @AcntCode4 = @AcntCode4 + SUBSTRING(@DebitCode,LEN(RTRIM(@AcntCode4))+1,LEN(@DebitCode)- LEN(RTRIM(@AcntCode4))+1)
				END
			-----	
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF [acc].[funIsCurrencyAcntCode] (@AcntCode4) = 'True'
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode4,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0,@CurrencyAmountTmp,@CurrencyTypeIDTmp,@BaseID)			

	
			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@AcntCode4,@DebitCode,@BankState,@CurrencyAmount,@AcntCode6,@BaseID
	
	END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

END
GO
