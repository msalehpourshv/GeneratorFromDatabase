USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/08/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchPaymentPrim]
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
	Declare @AmountSum	float
	Declare @RowDesc	Nvarchar(1000)	
	Declare @DebitCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode1	Varchar(20)
	Declare @AcntCode2	Varchar(20)
	Declare @AcntCode3	Varchar(20)
	Declare @AcntCode5	Varchar(20)
	Declare @AccountNo	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	Declare @VolumeRowNo INT
	Declare @VolumeFiscalYear SmallInt
	Declare @AcntCode Varchar(20)
	Declare @AcntName NVarchar(1000)
	Declare @CollectorAcntCode	Varchar(20)
	Declare @intTmpMaxDocRowNo INT
	Declare @intTmpMaxRowNo INT
	Declare @CurrencyAmount	Float
	Declare @CurrencyAmountSum	Float
	DECLARE @strSourceProcessNo NVARCHAR(100)
	DECLARE @BaseID Int
	
	DECLARE @CurrencyRateTmp			Float
	DECLARE @CurrencyAmountTmp			Float
	DECLARE @CurrencyTypeIDTmp			VarChar(20)
	DECLARE @BankCodeReplaceWithCustomerCodeInPayment BIT
	Declare @start int 

		
	SELECT   @BankCodeReplaceWithCustomerCodeInPayment=SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInPayment'

	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))

	--------------------------------------------------------------------------------------------------------
	SET @strMsgText = ''
	SET @AmountSum = 0
	SET @CurrencyAmount = 0
	SET @CurrencyAmountSum = 0
	
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''
	
	-----
	SELECT @CollectorAcntCode=CollectorAcntCode 
	FROM trs.tblPayHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
	-----

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	SET @intTmpMaxDocRowNo = @intMaxDocRowNo
	SET @intTmpMaxRowNo = @intMaxRowNo

	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,DebitCode,ChequeNo,ChequeDate,AcntCode1,AcntCode2,AcntCode3,AcntCode5,AccountNo,BankState,VolumeRowNo,VolumeFiscalYear,CurrencyAmount,ID
	FROM trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE RD.CreditCode=OB.BankCode AND
		  RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@DebitCode,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@AccountNo,@BankState,@VolumeRowNo,@VolumeFiscalYear,@CurrencyAmount,@BaseID

	While (@@Fetch_Status = 0)
		BEGIN
			
			SET @AcntCode = ''

			SET @strRecDesc = ' اسناد پرداختني اول دوره ' + @strSourceProcessNo + ' ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' -'

			SET @strRecDesc = @strRecDesc + ' چک شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' سررسید ' + @ChequeDate

			IF @PayTypeID=8
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
			IF @strMsgText <> ''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					Raiserror (@strMsgText,16,1)
					Return
				END
			
			-----------------------------------------------------
					
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			IF [acc].[funIsCurrencyAcntCode] (@AcntCode) = 'True'
			Begin
				Set @CurrencyAmountTmp  = @CurrencyAmount
			End
			Else
			Begin
				Set @CurrencyAmountTmp  = 0
			End
				
			SET @AmountSum = @AmountSum + @Amount
			SET @CurrencyAmountSum = @CurrencyAmountSum + @CurrencyAmountTmp

			IF @BankCodeReplaceWithCustomerCodeInPayment='True' 
			BEGIN
				SET @start = [acc].[FunGetAcntInfoForRemain](2)
				IF LEN(@DebitCode)>@start
					SET @AcntCode = LEFT(pub.funPadRight(@AcntCode,' ',@start-1),@start-1) + SUBSTRING(@DebitCode,@start,20)
			END
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,0,@Amount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0,@CurrencyAmountTmp,@BaseID)			

			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@DebitCode,@ChequeNo,@ChequeDate,@AcntCode1,@AcntCode2,@AcntCode3,@AcntCode5,@AccountNo,@BankState,@VolumeRowNo,@VolumeFiscalYear,@CurrencyAmount,@BaseID

		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

		IF [acc].[funIsCurrencyAcntCode] (@CollectorAcntCode) = 'True'
		Begin
			Set @CurrencyAmountTmp  = @CurrencyAmountSum
		End
		Else
		Begin
			Set @CurrencyAmountTmp  = 0
		End
				
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intTmpMaxRowNo ,@intTmpMaxDocRowNo,
					@CollectorAcntCode,@AmountSum,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@RowDesc,0,@CurrencyAmountTmp)			

END
GO
