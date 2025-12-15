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
Create PROCEDURE [acc].[SpVchPettyCash]
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
	Declare @strMsgText			NVarChar(2044)
	Declare @PayTypeID			Tinyint
	Declare @BankState			Tinyint
	Declare @CostAmount			Bigint
	Declare @DescDtl			Nvarchar(1000)	
	Declare @DebitCode			Varchar(20)
	Declare @ShortageAcntCode	Varchar(20)
	Declare @ShortageAmount		Bigint
	Declare @CostAcntCode		Varchar(20)
	Declare @AcntCode1			Varchar(20)
    Declare @intSum				BIGINT
	Declare @strRecDesc 		NVarChar(1000)
	Declare @ApplicationName	VarChar(30)
	Declare @strSourceProcessNo NVARCHAR(100)
	
	Declare @CurrencyTypeID		VarChar(20)
	Declare @CurrencyAmount		Float
	Declare @CurrencyRate		Float
	
	set @CurrencyAmount=0
	SET @CurrencyRate = 0
	SET @CurrencyTypeID = ''
	
	IF  @intSourceProcessNo < 2
		SET @strSourceProcessNo = ''
	ELSE
		SET @strSourceProcessNo = LTRIM(RTRIM(STR(@intSourceProcessNo)))

	SELECT @ShortageAcntCode = ShortageAcntCode, @ShortageAmount = ShortageAmount, @CurrencyRate = CurrencyRate, 
		   @CurrencyTypeID = CurrencyTypeID
	FROM	trs.tblPettyCashHdr
	WHERE	ProcessID	= @intSourceProcessID  AND
			ProcessNo	= @intSourceProcessNo  AND
			FiscalYear  = @intSourceFiscalYear AND
			SerialNo	= @intSourceSerialNo 
			
	--------------------------------------------------------------------------------------------------------
	SELECT @ApplicationName = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ApplicationName'
	
	IF @ApplicationName = 'Industry'
		SET @strRecDesc = ' سند تنخواه گردان ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
	else
		SET @strRecDesc = ' سند هزینه ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
				
	SET @intSum = 0

	-------------
	Declare	Cursor_PayDtl CURSOR For 
	SELECT	CostAcntCode,CostAmount,DescDtl,CurrencyAmount	
	FROM trs.tblPettyCashDtl RD
	WHERE RD.ProcessID=@intSourceProcessID AND
		  RD.ProcessNo=@intSourceProcessNo AND
		  RD.FiscalYear=@intSourceFiscalYear AND
		  RD.SerialNo=@intSourceSerialNo 

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @CostAcntCode,@CostAmount,@DescDtl,@CurrencyAmount

	While (@@Fetch_Status = 0)
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@CostAcntCode,@CostAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc + ' - ' + @DescDtl)),@DescDtl,0 ,@CurrencyAmount, @CurrencyTypeID)			

			SET @intSum=@intSum + @CostAmount

			Fetch NEXT From Cursor_PayDtl Into @CostAcntCode,@CostAmount,@DescDtl,@CurrencyAmount
		END

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 

	-------------
	DECLARE @DescHdr NVarchar(300)

	SELECT	@AcntCode1=AcntCode1, @DescHdr=DescHdr,@BankState=BankState
	FROM trs.tblOurBanks OB ,
		(SELECT OurBankCode,DescHdr
		FROM	trs.tblPettyCashHdr
		WHERE	ProcessID=@intSourceProcessID AND
				ProcessNo=@intSourceProcessNo AND
				FiscalYear=@intSourceFiscalYear AND
				SerialNo=@intSourceSerialNo ) PC
	WHERE OB.BankCode=PC.OurBankCode

	--IF @BankState <> 1 AND @BankState <> 2
		--BEGIN
			---- نوع کد در تعاریف تنخواه عوض شده است
			--SET @strMsgText=TS.pub.funGetMessages(11033,@LanguageID)
			--Raiserror (@strMsgText,16,1)
			--Return
		--END
	IF @AcntCode1 IS NULL 
		BEGIN
			--کد حسابداری تنخواه خالی است
			SET @strMsgText=N'کد تنخواه با برگه ' + STR(@intSourceSerialNo) + '  در سیستم موجود نیست' 
			Raiserror (@strMsgText,16,1)
			Return
		END

	IF @AcntCode1='' 
		BEGIN
			--کد حسابداری تنخواه خالی است
			SET @strMsgText=TS.pub.funGetMessages(11021,@LanguageID) 
			Raiserror (@strMsgText,16,1)
			Return
		END

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@intSum-@ShortageAmount,0) / @CurrencyRate

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				@AcntCode1,0,@intSum-@ShortageAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc + ' - ' + @DescHdr)),@DescHdr,0,@CurrencyAmount,@CurrencyTypeID)			

	IF @ShortageAcntCode<>'' AND @ShortageAmount<>0
	BEGIN
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		SET @strRecDesc = ' کسر هزینه سند تنخواه گردان ' + @strSourceProcessNo + ' شماره ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))

	IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@ShortageAmount,0) / @CurrencyRate

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@ShortageAcntCode,0,@ShortageAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc + ' - ' + @DescHdr)),@DescHdr,0,@CurrencyAmount,@CurrencyTypeID)			
	END

END
GO
