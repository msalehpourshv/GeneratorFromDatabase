USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author: Sadeghi, Hadi
-- Create Date: 09-19-2007 (1386/06/18)
-- Description: <Store Documents>
-- ----------------------------------------------
-- کنترل برگ پرداخت
-- ==============================================
CREATE PROCEDURE [trs].[spFrmPayPaymentRecord]
    @PayTypeID        TinyInt,
    @CreditCode	      VarChar(20)=Null,
    @ChequeNo	      VarChar(20) = Null,
	@LanguageID       TinyInt=1,
	@LocationID       VarChar(10)=Null,
	@BankTypeID       TinyInt=Null,
	@BranchCode       nVarChar(20)=Null,
	@BranchName       nVarChar(50)=Null,
	@AccountNo        nVarChar(20)=Null,
	@decAmountSum	  float=Null,
	@VoucherSerialNo  int=Null,
	@ProcessID		  int=2,	
	@SerialNo         int=Null,
	@ProcessNo        tinyint=Null,
	@FiscalYear       smallint=Null,
	@DocDate          Char(10)=Null
WITH ENCRYPTION
AS
BEGIN
DECLARE @intReturnValue int

Declare @strMsgText	 NVarChar(2044)
DECLARE @StrSelect NVarChar(4000)
DECLARE @ParmDefinition NVarChar(200)
DECLARE @ErrMessage NVarChar(200)
DECLARE @StrCodeField	VarChar(20)
DECLARE @ReturnCode varchar(20)
DECLARE @AcntCode1 varchar(20)
DECLARE @AcntCode2 varchar(20)
DECLARE @AcntCode3 varchar(20)
DECLARE @AcntCode5 varchar(20)
DECLARE @SumAcntCode float
DECLARE @BankState	Tinyint
DECLARE @CreditRoof Bigint
DECLARE @Difference Bigint
DECLARE @StrWhere NVarChar(200)
DECLARE @S varchar(50)

SET @ParmDefinition = N'@ReturnCodeOUT NVarChar(20) OUTPUT';

IF  @decAmountSum is Null Set @decAmountSum=0
IF  @LanguageID is Null Set @LanguageID=1
IF  @SerialNo is Null Set @SerialNo=0

SELECT @BankState=BankState 
FROM trs.tblOurBanks 
WHERE BankCode = @CreditCode

If @PayTypeID=1 -- صندوق
BEGIN
	set @StrCodeField='AcntCode1'
	--کد موجودی نقدی خالی است 
	set @intReturnValue=12004 
END

Else IF @PayTypeID=2 -- حواله
BEGIN
	set @StrCodeField='AcntCode3'
	--کد حواله خالی است
	set @intReturnValue=12005 
END

Else IF @PayTypeID=3 -- فیش نقدی
BEGIN
	set @StrCodeField='AcntCode1'
	--کد حسابداری موجودی نقدی خالی است
	set @intReturnValue=12006 
END

Else IF @PayTypeID=4 -- حواله بانکی
BEGIN
	set @StrCodeField='AcntCode1'
	--کد حسابداری موجودی نقدی خالی است
	set @intReturnValue=12007
END

Else IF @PayTypeID=5 -- برداشت از حساب
BEGIN
	set @StrCodeField='AcntCode1'
	--کد حسابداری موجودی بانک خالی است
	set @intReturnValue=12008 
END

Else IF @PayTypeID=6 -- اسناد دریافتنی
BEGIN
	set @StrCodeField='AcntCode2'
	--کد حسابداری اسناد دریافتنی تجاری خالی است
	set @intReturnValue=12009 
END

Else IF @PayTypeID=26 -- اسناد دریافتنی
BEGIN
	set @StrCodeField='AcntCode5'
	--کد حسابداری اسناد دریافتنی غیرتجاری خالی است'
	set @intReturnValue=12010
END

Else IF @PayTypeID=7 -- اسناد پرداختنی
BEGIN
	set @StrCodeField='AcntCode1'
	--کد حسابداری موجودی بانک خالی است
	set @intReturnValue=12011 
END

Else IF @PayTypeID=8 -- اسناد پرداختنی
BEGIN
	set @StrCodeField='AcntCode2'
	--كد حسابداري اسناد پرداختني تجاری خالی است
	set @intReturnValue=12012 
END
Else IF @PayTypeID=28 -- اسناد پرداختنی
BEGIN
	set @StrCodeField='AcntCode5'
	--كد حسابداري اسناد پرداختني غیرتجاری خالی است
	set @intReturnValue=12013 
END

IF @StrCodeField <> ''
BEGIN
	-----

	SET @StrSelect=
       N' SELECT @ReturnCodeOUT=' + @StrCodeField +  
        ' FROM trs.tblOurBanks 
          WHERE BankCode=''' + @CreditCode + ''''

	EXECUTE sp_executesql @StrSelect,@ParmDefinition,@ReturnCodeOUT=@ReturnCode OUTPUT;

	IF (@ReturnCode)=''
	BEGIN
		SET @strMsgText=TS.pub.funGetMessages(@intReturnValue,@LanguageID)
		Raiserror (@strMsgText,16,1)
	END
      
    Set @StrWhere=''

	IF (cast(@VoucherSerialNo as int)>0)
	set @StrWhere=
		' AND NOT(SerialNo=' + LTRIM(STR(@VoucherSerialNo)) + 
		' AND SourceProcessID=' +  LTRIM(STR(@ProcessID)) +
		' AND SourceProcessNo=' +  LTRIM(STR(@ProcessNo)) +
		' AND SourceSerialNo=' + LTRIM(STR(@SerialNo)) +
		' AND SourceFiscalYear=' + LTRIM(STR(@FiscalYear)) + ')'

	IF (@BankState=2)
		BEGIN
			SELECT @AcntCode1=AcntCode1,@AcntCode2=AcntCode2,@AcntCode3=AcntCode3,@AcntCode5=AcntCode5,@CreditRoof=CreditRoof
			FROM trs.tblOurBanks
			WHERE BankCode= @CreditCode  

			SET @ParmDefinition = N'@SumAcntCodeOUT float OUTPUT';

		   set @StrSelect=
			N'SELECT @SumAcntCodeOUT=ISNULL(SUM(Credit-Debit),0)
			  FROM acc.tblVoucherDtl
			  WHERE DocDate <= ''' + @DocDate + ''' AND
					((''' + @AcntCode1 + '''<>'''' AND AcntCode LIKE ''' + @AcntCode1 + '%'') OR 
					(''' + @AcntCode2 + '''<>'''' AND AcntCode LIKE ''' + @AcntCode2 + '%'') OR 
					(''' + @AcntCode3 + '''<>'''' AND AcntCode LIKE ''' + @AcntCode3 + '%'') OR 
					(''' + @AcntCode5 + '''<>'''' AND AcntCode LIKE ''' + @AcntCode5 + '%''))' +
					@StrWhere
			
			EXECUTE  sp_executesql @StrSelect,@ParmDefinition,@SumAcntCodeOUT=@SumAcntCode OUTPUT

			SET @Difference=@SumAcntCode+@decAmountSum-@CreditRoof

			IF @Difference>0
				BEGIN 
					--سقف بستانکاری تنخواه %s بیشتر از حد مجاز می باشد
					SET @strMsgText=TS.pub.funGetMessages(12016,@LanguageID)
					set @S = LTRIM(str(@Difference))
					Raiserror (@strMsgText,16,1,@S)
					Return
				END     

		END
		
END

END
GO
