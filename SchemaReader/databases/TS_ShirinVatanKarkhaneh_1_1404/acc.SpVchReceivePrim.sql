USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/07/05
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchReceivePrim]
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
	Declare @strMsgText	NVarChar(2044)
	Declare @PayTypeID	Tinyint
	Declare @BankState	Tinyint
	Declare @SumAmount	float
	Declare @Amount		float
	Declare @RowDesc	Nvarchar(1000)	
	Declare @CreditCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode2	Varchar(20)
	Declare @AcntCode5	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	Declare @AcntCode	Varchar(20)
	Declare @CollectorAcntCode	Varchar(20)
	DECLARE @AcntName NVarchar(1000)
	Declare @CurrencyAmount	Float
	Declare @SumCurrencyAmount	float
	Declare @strSourceProcessNo NVARCHAR(100)
	Declare @BaseID Int
	Declare @CurrencyRateTmp			Float
	Declare @CurrencyAmountTmp			Float
	Declare @CurrencyTypeIDTmp			VarChar(20)
	DECLARE @BankCodeReplaceWithCustomerCodeInReceive BIT
	Declare @start int 

		
	SET @BankCodeReplaceWithCustomerCodeInReceive = 'False'
	SELECT   @BankCodeReplaceWithCustomerCodeInReceive=SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'BankCodeReplaceWithCustomerCodeInReceive'

	IF  @intSourceProcessNo< 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))
	
	--------------------------------------------------------------------------------------------------------
	SET @SumAmount = 0
	SET @CurrencyAmount = 0
	SET @SumCurrencyAmount = 0
	
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''
	
	SELECT @CollectorAcntCode=CollectorAcntCode 
	FROM trs.tblPayHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	-----
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	PayTypeID,Amount,RowDesc,CreditCode,ChequeNo,ChequeDate,AcntCode2,AcntCode5,BankState,CurrencyAmount,RD.ID
	FROM trs.tblPayDtl RD,trs.tblOurBanks OB
	WHERE RD.DebitCode=OB.BankCode AND
		  RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 
	order by RD.DocRowNo

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@CreditCode,@ChequeNo,@ChequeDate,@AcntCode2,@AcntCode5,@BankState,@CurrencyAmount,@BaseID

	While (@@Fetch_Status = 0)
		BEGIN
		
			SET @AcntCode = ''

			SET @strRecDesc = ' اسناد دريافتي اول دوره ' + @strSourceProcessNo + ' ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) + ' -'

				SET @strRecDesc = @strRecDesc + ' چک شماره ' + LTRIM(RTRIM(STR(@ChequeNo,30))) + ' سررسید ' + @ChequeDate

			-------------------------------------------
			IF @PayTypeID=6 
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
			IF @strMsgText <> ''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					Raiserror (@strMsgText,16,1)
					Return
				END

			-------------------------------------------
			SET @AcntName = @strRecDesc + ' از '  + pub.GetCodeName(@CreditCode,@LanguageID)
			
			IF [acc].[funIsCurrencyAcntCode] (@AcntCode) = 'True'
			Begin
				Set @CurrencyAmountTmp  = @CurrencyAmount
			End
			Else
			Begin
				Set @CurrencyAmountTmp  = 0
			End
				
			SET @SumAmount = @SumAmount + @Amount	
			SET @SumCurrencyAmount = @SumCurrencyAmount + @CurrencyAmountTmp	

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @BankCodeReplaceWithCustomerCodeInReceive='True' 
			BEGIN
				SET @start = [acc].[FunGetAcntInfoForRemain](2)
				IF LEN(@CreditCode)>@start
					SET @AcntCode = LEFT(pub.funPadRight(@AcntCode,' ',@start-1),@start-1) + SUBSTRING(@CreditCode,@start,20)
			END

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,BaseID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
						@AcntCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@AcntName)),@RowDesc,0,@CurrencyAmountTmp,@BaseID)			

			Fetch NEXT From Cursor_PayDtl Into @PayTypeID,@Amount,@RowDesc,@CreditCode,@ChequeNo,@ChequeDate,@AcntCode2,@AcntCode5,@BankState,@CurrencyAmount,@BaseID
		
		END 

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	IF [acc].[funIsCurrencyAcntCode] (@CollectorAcntCode) = 'True'
	Begin
		Set @CurrencyAmountTmp  = @SumCurrencyAmount
	End
	Else
	Begin
		Set @CurrencyAmountTmp  = 0
	End
				
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,BaseID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo,@intMaxDocRowNo,
				@CollectorAcntCode,0,@SumAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp,@BaseID)			
END
GO
