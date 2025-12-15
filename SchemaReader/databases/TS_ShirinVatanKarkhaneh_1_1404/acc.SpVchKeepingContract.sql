USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 99/08/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchKeepingContract]
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
	Declare @strMsgText					NVarChar(2044)	
	Declare @strTitleSale		    NVarChar(100)
	Declare @DescDtl				NVarChar(1000)
	Declare @strRecDesc				NVarChar(1000)
	Declare @strFiscalSerial		VarChar(20)
	Declare @AcntCode				Varchar(20)
	Declare @SumGoodsPrice			Float
	DECLARE @AcntCodeKeepingContract VARCHAR(20)

	--------------------------------------------------------------------------------------------------------
	SET @strTitleSale = ''
	SET @AcntCodeKeepingContract = ''
	
	SELECT @strTitleSale = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TitleSale' + LTRIM(RTRIM(STR(@intSourceProcessNo)))
	--------------------------------------------------------------------------------------------------------
	SELECT @AcntCodeKeepingContract = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntCodeKeepingContract'

						
	--------------------------------------------------------------------------------------------------------
	SELECT	@AcntCode=AcntCode
	FROM sal.tblSaleOrderHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
	
	IF @AcntCode='' or @AcntCode is null
			BEGIN
				--کد فروش کالا خالي است 
				SET @strMsgText=TS.pub.funGetMessages(11029,@LanguageID)
				Raiserror ('کد حسابداری خریدار خالی است',16,1)
				Return
			END
	IF @AcntCodeKeepingContract='' or @AcntCodeKeepingContract is null
			BEGIN

				--کد فروش کالا خالي است 
				SET @strMsgText=TS.pub.funGetMessages(11029,@LanguageID)
				Raiserror ('کد بستانکاری قرارداد حق الحفاظ در تنظیمات خالی است',16,1)
				Return
			END
	--------------------------------------------------------------------------------------------------------
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))
	
	if @intSourceProcessID=190
		SET @strRecDesc=N'پیش نویس قرارداد حق الحفاظ ' +  @strTitleSale + N' شماره' + @strFiscalSerial
	if @intSourceProcessID=191
		SET @strRecDesc=N'قرارداد حق الحفاظ ' +  @strTitleSale + N' شماره' + @strFiscalSerial
	------------------------------------------------ سفارش فروش --------------------------------------------------------
	
	SELECT	@SumGoodsPrice = SUM(GoodsQuantity * GoodsPrice)
	FROM sal.tblSaleOrderDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo
		   
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount)
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				@AcntCode,ROUND(@SumGoodsPrice,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,0 )	

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
	
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount)
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @AcntCodeKeepingContract ,0,ROUND(@SumGoodsPrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,0 )	

END
GO
