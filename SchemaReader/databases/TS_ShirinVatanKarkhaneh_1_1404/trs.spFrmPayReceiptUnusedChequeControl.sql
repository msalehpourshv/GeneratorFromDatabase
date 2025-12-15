USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author: Sadeghi, Hadi
-- Create Date:(1386/08/01)
-- ==============================================
Create PROCEDURE [trs].[spFrmPayReceiptUnusedChequeControl]
	@BankCode    Varchar(20),
	@ChequeNo    Bigint,
	@LanguageID  TinyInt = 1,
	@VolumeRowNo Int = NULL
WITH ENCRYPTION
AS

BEGIN

Declare @strMsgText	 NVarChar(2044)
DECLARE @Counter Int
DECLARE @RowNo Int
DECLARE @ProcessID Int
DECLARE @ChequeBookID smallint
DECLARE @ChequeBookFiscalYear smallint
DECLARE @ErrMessage Nvarchar(4000)
DECLARE @Trs_AvoidDuplicateChequesPay as bit
DECLARE @ChequeIsDigital as bit

select @Trs_AvoidDuplicateChequesPay=SettingValue from pub.tblSettings where SettingKey='Trs_AvoidDuplicateChequesPay'
set @ChequeBookID = 0
set @ProcessID = 0

SELECT	@ChequeBookID = ChequeBookID ,@ChequeBookFiscalYear = FiscalYear, @ChequeIsDigital = ChequeIsDigital
FROM trs.tblBankChequesDtl
WHERE BankCode = @BankCode AND
      FromChequeNo <= @ChequeNo AND
      ToChequeNo >= @ChequeNo

IF @ChequeBookID = 0
	BEGIN
		SELECT  TOP 1 @ProcessID=ProcessID ,@ChequeBookID=ChequeBookID,
		@ChequeBookFiscalYear = ChequeBookFiscalYear, @ChequeIsDigital = ChequeIsDigital
		FROM trs.tblPayDtl
		WHERE PayTypeID IN (7,8,18,28) AND 
			  ChequeNo = @ChequeNo AND 
			  (@VolumeRowNo IS NULL OR VolumeRowNo <> @VolumeRowNo)
		order by EventNo desc
		PRINT @ProcessID
		IF @ProcessID = 28 OR @ProcessID = 34
		BEGIN
			SELECT @RowNo=ISNULL(MAX(RowNo),0)+1 
			FROM trs.tblBankChequesDtl 
			WHERE BankCode=@BankCode
			INSERT INTO trs.tblBankChequesDtl 
				   (BankCode, RowNo, FiscalYear, ChequeBookID, FromChequeNo, ToChequeNo, ChequeDate, DocRowNo)
			SELECT @BankCode,@RowNo,@ChequeBookFiscalYear,@ChequeBookFiscalYear,@ChequeNo,@ChequeNo,pub.funChangeDate_GergorianToPersian(getdate()),@RowNo
		END
		ELSE
		BEGIN
			--به این شماره چکی وجود ندارد
			SET @strMsgText=TS.pub.funGetMessages(12066,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
	END

SELECT  @Counter=Count(*)
FROM trs.tblBankVoidChequesDtl
WHERE BankCode = @BankCode AND
      ChequeNo = @ChequeNo

IF @Counter>0
	BEGIN
		--این چک قبلا باطل شده است
		SET @strMsgText=TS.pub.funGetMessages(12068,@LanguageID)
		Raiserror (@strMsgText,16,1)
		Return
	END

SELECT  TOP 1 @ProcessID=ProcessID
FROM trs.tblPayDtl
WHERE PayTypeID IN (7,8,18,28) AND 
      ChequeBookID = @ChequeBookID AND
      ChequeNo = @ChequeNo AND 
      (@VolumeRowNo IS NULL OR VolumeRowNo <> @VolumeRowNo)
order by EventNo desc

IF @ProcessID <> 28 AND @ProcessID <> 34 AND @ProcessID <> 0 and @Trs_AvoidDuplicateChequesPay='True'
	BEGIN
		-- این چک قبلا پرداخت شده است
		SET @strMsgText=TS.pub.funGetMessages(12067,@LanguageID) 
		Raiserror (@strMsgText,16,1)
		Return
	END

select @ChequeNo AS ChequeNo,@ChequeBookID AS ChequeBookID, @ChequeBookFiscalYear AS ChequeBookFiscalYear, @ChequeIsDigital as ChequeIsDigital

END
GO
