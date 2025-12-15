USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author: Sadeghi, Hadi
-- Create Date: 09-19-2007 (1386/06/18)
-- ----------------------------------------------
-- کنترل برگ دریافت
-- ==============================================
Create PROCEDURE [trs].[spFrmPayReceiptRecord]
    @PayTypeID        TinyInt,
    @DebitCode	      VarChar(20)=Null,
    @ChequeNo	      VarChar(40) = Null,
	@LanguageID       TinyInt=1,
	@LocationID       VarChar(10)=Null,
	@BankTypeID       TinyInt=Null,
	@BranchCode       nVarChar(20)=Null,
	@BranchName       nVarChar(50)=Null,
	@AccountNo        nVarChar(20)=Null,
	@SumAmount        float=Null,
	@VoucherSerialNo  int=Null,
	@ProcessID		  int=1,
	@SerialNo         int=Null,
	@ProcessNo        tinyint=Null,
	@FiscalYear       smallint=Null,
	@DocDate          Char(10) =Null
WITH ENCRYPTION
AS

BEGIN

--	SET @LanguageID = pub.funGetCurrentLanguageID();

DECLARE @intReturnValue int 

Declare @strMsgText	 NVarChar(2044)
DECLARE @StrSelect	NVarChar(4000)
DECLARE @ParmDefinition NVarChar(400)
DECLARE @ErrMessage NVarChar(200)
Declare @StrCodeField	NVarChar(4000)
DECLARE @ReturnCode VarChar(20)
DECLARE @BankState VarChar(20)

SET @StrCodeField=''
SET @ParmDefinition = N'@ReturnCodeOUT Nvarchar(20) OUTPUT,@BankStateOut Nvarchar(20) OUTPUT';

If  @LanguageID is Null SET @LanguageID=1
If  @SumAmount is Null SET @SumAmount=0
If  @SerialNo is Null SET @SerialNo=0

If (@PayTypeID=1) -- صندوق
  BEGIN
    SET @StrCodeField='AcntCode1,@BankStateOut=BankState'
	--کد موجودی نقدی  خالی است 
	SET @intReturnValue =12054
  END

Else If (@PayTypeID=2) -- حواله
  BEGIN
    SET @StrCodeField='AcntCode3,@BankStateOut=BankState'
	--کد حواله خالی است 
	SET @intReturnValue =12055
  END

Else If (@PayTypeID=3) -- فیش نقدی
  BEGIN
    SET @StrCodeField='AcntCode1,@BankStateOut=BankState'
	--کد حسابداری موجودی بانک خالی است
	SET @intReturnValue =12056
  END
Else If (@PayTypeID=38) -- واریز اینترنتی
  BEGIN
    SET @StrCodeField='AcntCode1,@BankStateOut=BankState'
	--کد حسابداری موجودی بانک خالی است
	SET @intReturnValue =12056
  END
Else If (@PayTypeID=4) -- حواله بانکی
  BEGIN
    SET @StrCodeField='AcntCode1,@BankStateOut=BankState'
	--کد حسابداری موجودی بانک خالی است
	SET @intReturnValue =12057
  END

Else If (@PayTypeID=6) -- اسناد دریافتنی تجاری
  BEGIN
    SET @StrCodeField='AcntCode2,@BankStateOut=BankState'
	--كد حسابداري اسناد دریافتنی خالی است
	SET @intReturnValue =12058
  END

Else If (@PayTypeID=26) -- اسناد دریافتنی غیرتجاری
  BEGIN
    SET @StrCodeField='AcntCode5,@BankStateOut=BankState'
	--كد حسابداري اسناد دریافتنی خالی است
	SET @intReturnValue =12060
  END

If (@StrCodeField<>'')
Begin
	SET @StrSelect=
     N' SELECT @ReturnCodeOUT=' + @StrCodeField +  
      ' FROM trs.tblOurBanks 
        WHERE BankCode=''' + @DebitCode + ''''

	EXECUTE  sp_executesql @StrSelect,@ParmDefinition,@ReturnCodeOUT=@ReturnCode OUTPUT,@BankStateOut=@BankState OUTPUT;

	IF (@ReturnCode)='' OR (@ReturnCode IS NULL)
	BEGIN
		SET @strMsgText=TS.pub.funGetMessages(@intReturnValue,@LanguageID)
		Raiserror (@strMsgText,16,1,@ChequeNo)
		Return
	END
        
    -- كنترل سقف تنخواه
    IF (@BankState=2) 
    BEGIN

	   declare @AcntCode1 varchar(20)
	   declare @AcntCode2 varchar(20)
	   declare @AcntCode3 varchar(20)
	   declare @AcntCode5 varchar(20)
	   declare @SumAcntCode float
	   declare @DebitRoof float
	   declare @Difference float
	   declare @StrWhere NVarChar(400)

       SET @StrWhere=''

	IF (cast(@VoucherSerialNo as int)>0)
	set @StrWhere=
		' AND NOT(SerialNo=' + LTRIM(STR(@VoucherSerialNo)) + 
		' AND SourceProcessID=' +  LTRIM(STR(@ProcessID)) +
		' AND SourceProcessNo=' +  LTRIM(STR(@ProcessNo)) +
		' AND SourceSerialNo=' + LTRIM(STR(@SerialNo)) +
		' AND SourceFiscalYear=' + LTRIM(STR(@FiscalYear)) + ')' 

       SELECT @AcntCode1=AcntCode1,@AcntCode2=AcntCode2,@AcntCode3=AcntCode3,@AcntCode5=AcntCode5,@DebitRoof=DebitRoof
       FROM trs.tblOurBanks
       WHERE BankCode= @DebitCode  

       SET @ParmDefinition = N'@SumAcntCodeOUT float OUTPUT';

       SET @StrSelect=
        N'SELECT @SumAcntCodeOUT=ISNULL(SUM(Debit-Credit),0)
          FROM acc.tblVoucherDtl
          WHERE DocDate<=''' + @DocDate + ''' AND
		        ((''' + @AcntCode1 + '''<>'''' AND AcntCode=''' + @AcntCode1 + ''') OR 
                (''' + @AcntCode1 + '''<>'''' AND AcntCode=''' + @AcntCode2 + ''') OR 
                (''' + @AcntCode1 + '''<>'''' AND AcntCode=''' + @AcntCode3 + ''') OR 
                (''' + @AcntCode1 + '''<>'''' AND AcntCode=''' + @AcntCode5 + '''))' +
                @StrWhere

		EXECUTE  sp_executesql @StrSelect,@ParmDefinition,@SumAcntCodeOUT=@SumAcntCode OUTPUT
      
		SET @Difference=@SumAcntCode+@SumAmount-@DebitRoof
		if @Difference>0
		BEGIN 
			--%sاز سقف اعتبار بیشتر است
			SET @strMsgText=TS.pub.funGetMessages(12059,@LanguageID)
			DECLARE @Difference1 Nvarchar(20)
			SET @Difference1=Ltrim(Str(@Difference))
			Raiserror (@strMsgText,16,1,@Difference1)
			Return
		 END

    END  --  IF (@BankState=2)

END -- 	If (@StrCodeField<>'')
 
If (@PayTypeID=38 or @PayTypeID=3 or @PayTypeID=4 ) -- فيش يا حواله
BEGIN

   -- برگرداندن مشخصات بانك به فرم 
   SELECT OB.BankTypeID,LocationID,BranchCode,BankAccountNo,BranchName,AccountOwnerName ,BankTypeName
   FROM trs.tblOurBanks OB   
   inner join trs.tblOurBanksDtl OBD on OB.BankCode=OBD.BankCode AND OBD.LanguageID=@LanguageID
   inner join trs.tblBankTypesDtl TB on TB.BankTypeID=OB.BankTypeID AND TB.LanguageID=@LanguageID 
	WHERE OB.BankCode= @DebitCode 
END

ELSE IF((@PayTypeID=6 OR @PayTypeID=26)AND @ChequeNo IS Not Null) 
BEGIN

    -- بررسي ثبت چك
   DECLARE @RecCount int
   SET @ErrMessage=''

    SELECT @RecCount=COUNT(*) 
    FROM trs.tblPayDtl 
    WHERE ChequeNo=@ChequeNo AND 
          BankTypeID=@BankTypeID AND 
          AccountNo=@AccountNo AND 
          PayTypeID IN (6,26) AND 
          NOT (ProcessID=@ProcessID AND 
			   ProcessNo=@ProcessNo AND 
			   FiscalYear=@FiscalYear AND 
			   SerialNo=@SerialNo)AND 
			   AccountNo NOT IN ('','0')
         
	DECLARE @strControl Varchar(6)
	SET @strControl='0'

    IF @RecCount > 0
		SET @strControl='1'
--      SET @ErrMessage=N' این شماره چک قبلا ثبت شده است' 

	IF @BankTypeID <> ''
	BEGIN
		-- بررسي برگشت چك
		SELECT @RecCount=COUNT(*) 
		FROM trs.tblPayDtl 
		WHERE ProcessID IN (17,18,24) AND
			  LocationID=@LocationID AND
	 		  BankTypeID=@BankTypeID AND
	 		  (BranchCode=@BranchCode OR
			   BranchName=@BranchName) AND
			   AccountNo=@AccountNo AND 
			   AccountNo NOT IN ('','0')

		IF (@RecCount>0)
			SET @strControl=@strControl + '1'
		ELSE
			SET @strControl=@strControl + '0'


		IF @strControl='10'
		BEGIN
			--این شماره چک قبلا ثبت شده است
			SET @strMsgText=TS.pub.funGetMessages(12061,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
		ELSE IF @strControl='01'
		BEGIN
			--از این حساب قبلا چکی برگشت خورده است
			SET @strMsgText=TS.pub.funGetMessages(12062,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
		ELSE IF @strControl='11'
		BEGIN
			--این شماره چک قبلا ثبت شده است
			--از این حساب قبلا چکی برگشت خورده است
			SET @strMsgText=TS.pub.funGetMessages(12063,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
	END
END -- IF(@PayTypeID=6 AND @ChequeNo IS Not Null) 56

END 
GO
