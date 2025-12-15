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
CREATE PROCEDURE [acc].[SpVchPayableTrustReturn]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		TinyInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				INT,
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
	Declare @CreditCode	Varchar(20)
	Declare @DebitCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode4	Varchar(20)
	Declare @AcntCode6	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @BaseID Int
	
	
	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))
		
	--------------------------------------------------------------------------------------------------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,ChequeNo,ChequeDate,CreditCode,DebitCode,ID
	FROM trs.tblPayDtl RD
	WHERE RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@CreditCode,@DebitCode,@BaseID

	While (@@Fetch_Status = 0)
		BEGIN
		
		IF @PayTypeID = 18
			SET @strRecDesc = ' استرداد اسناد تضمینی ما نزد دیگران ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره چک ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate
							  
		IF @PayTypeID = 33
			SET @strRecDesc = ' استرداد اسناد تضمینی ما نزد دیگران ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره ضمانتنامه ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' به سررسید ' + @ChequeDate							  
			
		IF @PayTypeID = 32
			SET @strRecDesc = ' استرداد اسناد تضمینی ما نزد دیگران ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) +
							  ' به شماره سفته ' + LTRIM(RTRIM(STR(@ChequeNo,30))) 

	SET @AcntCode4 = ''
			SET @AcntCode6 = ''
			
			SELECT @AcntCode4=AcntCode4,@AcntCode6=AcntCode6,@BankState=BankState
			FROM trs.tblOurBanks 
			WHERE BankCode=@DebitCode

			-----	
			IF (@PayTypeID = 18 OR @PayTypeID = 33 )
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
				IF  @BankState<>1
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
				SET @AcntCode4=@AcntCode6	
			END

			-----
			DECLARE @FillPayableTrustAcntCodeFromDebit  VARCHAR(50)
			SET @FillPayableTrustAcntCodeFromDebit = 'False'
			
			SELECT @FillPayableTrustAcntCodeFromDebit = SettingValue 
			FROM pub.tblSettings 
			WHERE SettingKey = 'FillPayableTrustAcntCodeFromDebit'
			
			
			IF @FillPayableTrustAcntCodeFromDebit='True' AND LEN(@CreditCode)>LEN(@AcntCode4)
				BEGIN
					SET @AcntCode4 = @AcntCode4 + SUBSTRING(@CreditCode,LEN(RTRIM(@AcntCode4))+1,LEN(@CreditCode)- LEN(RTRIM(@AcntCode4))+1)
				END
			-----	
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType ,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode4,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID)			

			-------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@CreditCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0 ,@BaseID)			

			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@ChequeNo,@ChequeDate,@CreditCode,@DebitCode,@BaseID
		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

END
GO
