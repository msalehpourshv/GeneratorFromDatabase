USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--=========== TS-QC:NOTOK ========================
--Author        : Hadi Sadeghi / Reza Nogrepasand
--Create date   : 91/12/27
--Viewed By	 : 
--Last Modified : 
--Description   : 
--================================================
CREATE  PROCEDURE [acc].[SpVch_SyncSaleBuy]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		int,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@StrSourceCodeFieldValue VARCHAR(100),
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				Int,
	@LanguageID				TinyInt
WITH ENCRYPTION
AS

BEGIN


	DECLARE @SaleAcntCode VARCHAR(20)
	DECLARE @BuyAcntCode VARCHAR(20)
	DECLARE @SalerAcntCode VARCHAR(20)
	DECLARE @BuyerAcntCode VARCHAR(20)
	DECLARE @BuyAmount FLOAT
	DECLARE @SaleAmount FLOAT
	DECLARE @FreightCost FLOAT
	DECLARE @OtherCost FLOAT
	
	
	
	Declare @strMsgText				NVarChar(2044)
	Declare @DescDtl				NVarChar(1000)
	Declare @strFiscalSerial		VarChar(50)
	Declare @strRecDesc				NVarChar(1000)
	Declare @strRecDesc2			NVarChar(1000)
	Declare @GoodsName				NVarChar(1000)
	Declare @GoodsUnit				NVarChar(1000)
	Declare @SaleTaxOverWorthAcntCode Varchar(20)
	Declare @SaleTollOverWorthAcntCode Varchar(20)
	
	Declare @FixCost				Float
	Declare @OtherIncome			Float
	Declare @CurrencyRate			Float
	Declare @CurrencyAmount			Float
	Declare @CurrencyTypeID			VarChar(20)
	Declare @SettlementDate			Varchar(50)
	 	
	DECLARE @TotalSale2Account		BIT		
	DECLARE @ShowSaleDiscountInBill	BIT		
	DECLARE @DiscountMinusFromVisitor	BIT		
	DECLARE @TaxOverWorthViewInCustomerInvoice BIT
	DECLARE @ShowSaleTransportationInBill BIT		
	DECLARE @ShowSettlementDate     BIT

	
	DECLARE @BaseFiscalYear Integer		
	DECLARE @BaseSerialNo Integer		
	DECLARE @BaseProcessID Integer		
	DECLARE @BaseProcessNo Integer		
	DECLARE @BaseDistributionSerialNo Integer		
	DECLARE @BaseDistributionFiscalYear Smallint	
	DECLARE @OwnerDocNo INT
	---
	
	SET @TotalSale2Account = 1				
	SET @ShowSaleDiscountInBill = 0			
	
	SET @BaseSerialNo = 0
	SET @BaseProcessID = 0
	SET @BaseProcessNo = 0
	SET @BaseFiscalYear = 0
	SET @SaleAcntCode = ''
	SET @OwnerDocNo =0
	
	SET @CurrencyTypeID = ''
	SET @SettlementDate = ''	
	SET @CurrencyRate = 0 	
	SET @CurrencyAmount = 0
	SET @ShowSaleTransportationInBill = 'True'
	
	SELECT @SaleAcntCode = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TrnSaleAcntCode' 
	
	SELECT @BuyAcntCode = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TrnBuyAcntCode' 
	
	
	
	SELECT @ShowSettlementDate = SettingValue
	FROM   pub.tblSettings
	WHERE SettingKey = 'ShowSettlementDate' 

	SELECT @ShowSaleTransportationInBill = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ShowSaleTransportationInBill' 
	
	------------------------------------------------------------------------------------------------------
	SET @ShowSaleDiscountInBill=ISNULL(@ShowSaleDiscountInBill,1)
	
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  
	SET @strRecDesc=' صورت وضعيت برگه شماره'  + @strFiscalSerial + @SettlementDate
	------------------------------------------------------------------------------------------------------
	
	SELECT @SalerAcntCode=ContractorAcntCode,@BuyerAcntCode = FactoryAcntCode,
	@FreightCost=FreightCost,@OtherCost=OtherCosts
	FROM cnt.tblSyncSaleBuyHdr
	WHERE SerialNo = @intSourceSerialNo AND FiscalYear=@intSourceFiscalYear
	AND ProcessID=@intSourceProcessID
	
	SELECT @SaleAmount=SUM(SalerTotalAmount),@BuyAmount = SUM(BuyerTotalAmount)
	FROM cnt.tblSyncSaleBuyDtl
	WHERE SerialNo = @intSourceSerialNo AND FiscalYear=@intSourceFiscalYear
	AND ProcessID=@intSourceProcessID
			
	------------------------------------------------------------------------------------------------------
	IF @SalerAcntCode=''
		BEGIN
			--کد فروشنده کالا خالي است 
			SET @strMsgText=TS.pub.funGetMessages(11029,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
		
		IF @BuyerAcntCode=''
		BEGIN
			--کد خريدار کالا خالي است 
			SET @strMsgText=TS.pub.funGetMessages(11029,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
		
	
	IF @SaleAcntCode=''
		BEGIN
			--کد فروش کالا خالي است 
			SET @strMsgText=TS.pub.funGetMessages(11029,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	
	IF @BuyAcntCode='' 
		BEGIN
			-- کد خريد كالا خالي است
			SET @strMsgText=TS.pub.funGetMessages(18005,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END				
	

	------------------------------------------------------------------------------------------------------
	
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

									
	IF @CurrencyRate <> 0 
		SET @CurrencyAmount = ROUND(@SaleAmount ,0) / @CurrencyRate
	
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@BuyerAcntCode,ROUND(@SaleAmount -(@FreightCost+@OtherCost),0) ,0,pub.funReverseForCrystal(@strRecDesc), '',0,'True',@CurrencyAmount,@CurrencyTypeID)	

	------------------------------------------------------------------------------------------------------
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	IF @CurrencyRate <> 0 	
		SET @CurrencyAmount = ROUND(@SaleAmount,0) / @CurrencyRate
			
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				@SaleAcntCode,0,ROUND(@SaleAmount -(@FreightCost+@OtherCost),0) ,pub.funReverseForCrystal(@strRecDesc),'',0,@CurrencyAmount,@CurrencyTypeID)

	------------------------------------------------------------------------------------------------------
	
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	IF @CurrencyRate <> 0 	
		SET @CurrencyAmount = ROUND(@BuyAmount,0) / @CurrencyRate
			
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				@BuyAcntCode,ROUND(@BuyAmount -(@FreightCost+@OtherCost),0),0 ,pub.funReverseForCrystal(@strRecDesc),'',0,@CurrencyAmount,@CurrencyTypeID)

	------------------------------------------------------------------------------------------------------
	
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	IF @CurrencyRate <> 0 	
		SET @CurrencyAmount = ROUND(@BuyAmount,0) / @CurrencyRate
			
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				@SalerAcntCode,0,ROUND(@BuyAmount-(@FreightCost+@OtherCost),0) ,pub.funReverseForCrystal(@strRecDesc),'',0,@CurrencyAmount,@CurrencyTypeID)
				
END
GO
