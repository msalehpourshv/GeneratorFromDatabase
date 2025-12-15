USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/09/08
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create  PROCEDURE [acc].[SpVchSale_Restaurant]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		TinyInt,
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
	-----
	
	Declare @strMsgText				NVarChar(2044)
	Declare @DescDtl				NVarChar(1000)
	Declare @strFiscalSerial		VarChar(50)
	Declare @strRecDesc				NVarChar(1000)
	Declare @strRecDesc2			NVarChar(1000)
	Declare @GoodsName				NVarChar(1000)
	Declare @GoodsUnit				NVarChar(1000)
	Declare @BranchName				NVarChar(1000)
	Declare @SaleTaxOverWorthAcntCode Varchar(20)
	Declare @SaleTollOverWorthAcntCode Varchar(20)
	Declare @SaleAcntCode			Varchar(20)
	Declare @CostCenterAcntCode		Varchar(20)	
	Declare @StoreID				Varchar(20)
	Declare @AcntCode				Varchar(20)
	Declare @AcntCode2				Varchar(20)
	Declare @UserAcntCode			Varchar(20)
 	Declare @OtherCostAcntCode		Varchar(20)
	Declare @FixCostAcntCode		Varchar(20)
	Declare @OtherIncomeAcntCode	Varchar(20)
	Declare @SettlementDate			Varchar(50)
	Declare @BranchID				Varchar(20)
	Declare @ServiceAcntCode		Varchar(20)
	Declare @RoundAcntCode			Varchar(20)
	
	Declare @DiscountAcntCode	    Varchar(20)
	Declare @TaxAcntCode			Varchar(20)
	Declare @TransportationCostAcntCode	Varchar(20)
	Declare @TransportationIncomeAcntCode Varchar(20)
	Declare @PackingAcntCode		Varchar(20)
	Declare @CurrencyTypeID			VarChar(20)
	Declare @GoodsPrice				Float
	Declare @DiscountDtl			Float
	Declare @GoodsQuantity			Float
	Declare @DiscountHdr			Float
	Declare @Discount				Float
	Declare @TransportationCost		Float
	Declare @TransportationIncome	Float
	Declare @PackingCost			Float
	Declare @TaxCost				Float
	Declare @VisitorPercent			Float
	Declare @VisitorCost			Float
	Declare @DistributePercent		Float
	Declare @DistributeAmount		Float
	Declare @SumGoodsPrice			Float
	Declare @SumGoodsPriceWithTax	Float
	Declare @VisitorCost2			Float
	Declare @TaxOverWorthCost		Float
	Declare @TollOverWorthCost		Float
	Declare @OtherCost				Float
	Declare @FixCost				Float
	Declare @OtherIncome			Float
	Declare @CurrencyRate			Float
	Declare @CurrencyAmount			Float
	Declare @ServiceAmount			Float
	Declare @RoundAmount			Float
	Declare @ContractEarnedAmount	Float
	Declare @CurrencyRateTmp			Float
	Declare @CurrencyAmountTmp			Float
	Declare @CurrencyTypeIDTmp			VarChar(20)
	
	DECLARE @ShowSaleDiscountInBill	BIT		
	DECLARE @DiscountMinusFromVisitor	BIT		
	DECLARE @TaxOverWorthViewInCustomerInvoice BIT
	DECLARE @ShowSaleTransportationInBill BIT		
	DECLARE @ShowSettlementDate     BIT
	DECLARE @IsPay     BIT
	Declare @Sal_TaxAcntCompletWithCustCode bit
	DECLARE @SaleAcntCodeInSaleTypes			 BIT
	
	DECLARE @BaseFiscalYear Integer		
	DECLARE @BaseSerialNo Integer		
	DECLARE @BaseProcessID Integer		
	DECLARE @BaseProcessNo Integer		
	DECLARE @BaseDistributionSerialNo Integer		
	DECLARE @BaseDistributionFiscalYear Smallint	
	DECLARE @OwnerDocNo INT
	DECLARE @PosAmount Float
	DECLARE @CashAmount float
	DECLARE @BankID varchar(20)
	DECLARE @BankAcntCode varchar(20)
	DECLARE @PayableAmount float
	DECLARE @IsDebit float
	Declare @inv_GoodsAcntGroupWithStoreID bit
	-----
	
	SET @inv_GoodsAcntGroupWithStoreID   = 'False'

	SELECT @inv_GoodsAcntGroupWithStoreID=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey='inv_GoodsAcntGroupWithStoreID'

	SET	@Discount = 0
	--SET @TotalSale2Account = 1				
	SET @ShowSaleDiscountInBill = 0			
	SET @VisitorCost2 = 0
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
	SET @IsPay = 'False'
	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''
	SET @SaleAcntCodeInSaleTypes = 'False'

	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @intStartP2  tinyint,
		@intLenP2 tinyint

	select @intStartP2 = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)+2
	from pub.tblCodeLayer 
	where TableName='acc.tblAcnt' AND PartNumber<2

	
	select @intLenP2 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'acc.tblAcnt' AND PartNumber=2

	DECLARE @str_Goods  tinyint,
		@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	SELECT @TaxOverWorthViewInCustomerInvoice = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'TaxOverWorthViewInCustomerInvoice' 
	
	SELECT @ShowSettlementDate = SettingValue
	FROM   pub.tblSettings
	WHERE SettingKey = 'ShowSettlementDate' 

	SELECT @ShowSaleTransportationInBill = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ShowSaleTransportationInBill' 
	select @Sal_TaxAcntCompletWithCustCode=SettingValue from pub.tblSettings where SettingKey='Sal_TaxAcntCompletWithCustCode'

	SELECT @SaleAcntCodeInSaleTypes = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SaleAcntCodeInSaleTypes' 


	SET @BranchID='' 
	SET @BranchID = pub.funSplitString(@StrSourceCodeFieldValue, '@', 2)  

	--------------------------------------------------------------------------------------------------------
	SET @ShowSaleDiscountInBill=ISNULL(@ShowSaleDiscountInBill,1)
	SET @TollOverWorthCost = 0
	--------------------------------------------------------------------------------------------------------
	UPDATE sal.tblRestaurantSaleHdr
	SET TotalLineDiscount = TL
	from sal.tblRestaurantSaleHdr h
	INNER JOIN (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,BranchID,SUM(DiscountDtl) TL 
	            FROM sal.tblRestaurantSaleDtl 
				WHERE ProcessID=@intSourceProcessID AND
					  ProcessNo=@intSourceProcessNo AND
					  FiscalYear=@intSourceFiscalYear AND
					  SerialNo=@intSourceSerialNo AND 
					  DocDate = @strVchDate AND 
					 ( BranchID= @BranchID OR @BranchID = '')
				GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,BranchID	 )  d
	ON h.ProcessID=d.ProcessID AND h.ProcessNo=d.ProcessNo AND h.FiscalYear=d.FiscalYear AND h.SerialNo=d.SerialNo AND h.DocDate = d.DocDate AND h.BranchID=d.BranchID
	
	UPDATE sal.tblRestaurantSaleHdr
	SET DiscountAmount = 0
	where ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo AND 
		  DocDate = @strVchDate AND 
		 ( BranchID= @BranchID OR @BranchID = '') AND
		 DiscountAmount <0 and DiscountAmount>-11


	SELECT	@StoreID=StoreID,@UserAcntCode=UserAcntCode,@AcntCode=GeustID,@AcntCode2=GeustID2,@DiscountHdr =DiscountAmount ,@Discount= DiscountAmount +TotalLineDiscount ,
        	@IsPay=IsPay,@TaxOverWorthCost=TaxOverWorthAmount,@TollOverWorthCost = TollOverWorthAmount,
        	@OtherIncome=OtherIncome,@PackingCost = PackingCost,
        	@ServiceAmount = ServiceAmount,@RoundAmount=RoundAmount,@TransportationIncome=TransportationIncome,
        	@ContractEarnedAmount=ContractEarnedAmount,
        	@CashAmount=CashAmount,@PosAmount=PosAmount,@BankID=BankID,
        	@PayableAmount=PayableAmount,@IsDebit=IsDebit,@BranchID = BranchID
	FROM sal.tblRestaurantSaleHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo AND 
		  DocDate = @strVchDate AND 
		 ( BranchID= @BranchID OR @BranchID = '')
		 
	
	SELECT @BranchName = BranchName 
	FROM sal.tblBranchesDtl 
	WHERE BranchID=@BranchID AND LanguageID=@LanguageID
	
	SELECT	@SaleAcntCode=SaleAcntCode,@SaleTaxOverWorthAcntCode=SaleTaxOverWorthAcntCode,
	        @SaleTollOverWorthAcntCode=SaleTollOverWorthAcntCode,@DiscountAcntCode= SaleDiscountAcntCode
	FROM inv.tblStores 
	WHERE StoreID = @StoreID

		
	SELECT @ServiceAcntCode=ServiceAcntCode,@RoundAcntCode = RoundAcntCode,
	       @PackingAcntCode=PackingCostAcntCode,
	       @OtherIncomeAcntCode=OtherIncomeAcntCode,
		   @TransportationIncomeAcntCode=TransportationIncomeAcntCode
	FROM sal.tblBranches
	WHERE BranchID = @BranchID
	
		
	SELECT @BankAcntCode=AcntCode1
	from trs.tblOurBanks
	where  BankCode=@BankID
	
	--------------------------------------------------------------------------------------------------------
	IF @AcntCode = ''
		BEGIN
			SET @AcntCode = @UserAcntCode
		END	
	IF @AcntCode2 = ''
		BEGIN
			SET @AcntCode2 = @UserAcntCode
		END	
	
	IF @SaleAcntCode=''
		BEGIN
			--کد فروش کالا خالي است 
			SET @strMsgText=TS.pub.funGetMessages(11029,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	IF @SaleTaxOverWorthAcntCode='' AND @TaxOverWorthCost <> 0
		BEGIN
			--کد مالیات بر ارزش افزوده در فروش خالی است
			SET @strMsgText=TS.pub.funGetMessages(11039,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	IF @SaleTollOverWorthAcntCode='' AND @TollOverWorthCost <> 0
		BEGIN
			--کد عوارض بر ارزش افزوده در فروش خالی است
			SET @strMsgText=TS.pub.funGetMessages(11043,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END				
		
	IF @ServiceAcntCode='' AND @ServiceAmount <> 0
		BEGIN
			--کد حسابداري سرویس در تعریف شعبه خالي است
			SET @strMsgText=TS.pub.funGetMessages(18005,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END				
		
	IF @RoundAcntCode='' AND @RoundAmount <> 0
		BEGIN
			--کد حسابداري پول خورد در تعریف شعبه خالي است
			SET @strMsgText=TS.pub.funGetMessages(18006,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END	

	IF @TransportationIncomeAcntCode='' AND @TransportationIncome <> 0
		BEGIN
			SET @strMsgText=N'کد حسابداري درآمد حمل در تعریف شعبه خالي است'
			Raiserror (@strMsgText,16,1)
			Return
		END	

	IF @OtherIncomeAcntCode = '' AND @OtherIncome <> 0
		BEGIN
			SET @strMsgText=N'کد حسابداري جمع اضافات در تعریف شعبه خالي است'
			Raiserror (@strMsgText,16,1)
			Return
		END		

	IF @PackingAcntCode = '' AND @PackingCost <> 0
		BEGIN
			SET @strMsgText=N'کد حسابداري هزینه بسته بندی در تعریف شعبه خالي است'
			Raiserror (@strMsgText,16,1)
			Return
		END								
---------------------------------------
		
--------------------------------------------------------------------------------------------------------
	

	--------------------------------------------------------------------------------------------------------
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  
	SET @strRecDesc='فروش ' + @BranchName + '-' + @strFiscalSerial + @SettlementDate
		
	----IF @AcntCode = ''
	--	set @AcntCode = '110101'
	--------------------------------------------------------------------------------------------------------
	----- اگر جمع کل فروش به حساب مشتری منظور میشود

	IF @IsPay = 'True'
		BEGIN
			SET @ContractEarnedAmount = 0
			SET @ContractEarnedAmount = 0
			SET @ContractEarnedAmount = 0
			
		END
								
	IF @CurrencyRate <> 0 
		SET @CurrencyAmount = ROUND(@PayableAmount-@PosAmount ,0) / @CurrencyRate
	
	
if @CashAmount>0 
begin
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,ROUND(@CashAmount,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)), '',0,'True',@CurrencyAmount,@CurrencyTypeID)	
end 
if  @IsDebit>0
begin

	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode2,ROUND(@IsDebit,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)), '',0,'True',@CurrencyAmount,@CurrencyTypeID)	
end

if @PosAmount>0
 begin	
 
	 IF @CurrencyRate <> 0 
		SET @CurrencyAmount = ROUND(@PosAmount ,0) / @CurrencyRate
	
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			 @BankAcntCode,ROUND(@PosAmount,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)), '',0,'True',@CurrencyAmount,@CurrencyTypeID)	

	end
if @ContractEarnedAmount>0 
begin
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,ROUND(@ContractEarnedAmount,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc+'  پیش پرداخت ')), '',0,'True',@CurrencyAmount,@CurrencyTypeID)	
end 
	--------------------------------------------------------------------------------------------------------

IF 	@ContractEarnedAmount = 0 AND @PosAmount = 0 AND @IsDebit = 0 AND @CashAmount = 0
BEGIN

	SELECT @ContractEarnedAmount = SUM(Price*Qty) + ISNULL(@TaxOverWorthCost,0)+ISNULL(@TollOverWorthCost,0) - ISNULL(@Discount,0) + ISNULL(@PackingCost,0)+ ISNULL(@ServiceAmount,0) + ISNULL(@OtherIncome,0)
	FROM sal.tblRestaurantSaleDtl
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo AND 
		  DocDate = @strVchDate AND 
		  BranchID= @BranchID
		  
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,ROUND(@ContractEarnedAmount,0) ,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc+'  فروش ')), '',0,'True',@CurrencyAmount,@CurrencyTypeID)	

END

IF @inv_GoodsAcntGroupWithStoreID='True'
	BEGIN

		----- کل تخفیف به بدهکاری هزینه میرود
		IF  (@DiscountHdr ) <> 0
			BEGIN
				IF @DiscountAcntCode is null OR @DiscountAcntCode = ''
					BEGIN
						--کد تخفیف فروش کالا خالي است 
						SET @strMsgText=TS.pub.funGetMessages(11040,@LanguageID)
						Raiserror (@strMsgText,16,1)
						Return
					END	
				IF @OwnerDocNo > 0
					SET @strRecDesc2 = ' تخفیف فروش ' +  @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo)))
				ELSE
					SET @strRecDesc2 = ' تخفیف فروش ' + @strFiscalSerial						
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@DiscountHdr  ,0) / @CurrencyRate
			
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@DiscountAcntCode,ROUND(@DiscountHdr ,0),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmount,@CurrencyTypeID)
			END


		IF @SaleAcntCodeInSaleTypes = 'True'
			Declare	curStore CURSOR For
			SELECT	g.StoreID,[acc].[funMerg_AcntCode]([acc].[funMergAcntCode](CASE WHEN IsService=1 THEN d.CostCenterAcntCode ELSE st.SaleDiscountAcntCode END,g.SaleDiscountAcntCode),SUBSTRING(UserAcntCode,@intStartP2,@intLenP2) ,P3AcntCode,P4AcntCode) DiscountAcntCode, 
							  [acc].[funMerg_AcntCode]([acc].[funMergAcntCode](CASE WHEN IsService=1 THEN d.CostCenterAcntCode ELSE st.SaleAcntCode END,g.SaleAcntCode),SUBSTRING(UserAcntCode,@intStartP2,@intLenP2) ,P3AcntCode,P4AcntCode) SaleAcntCode, 
					ROUND(SUM(s.Price *(s.Qty-s.RetQty)),0) GoodsPrice,
					ROUND(SUM(s.DiscountDtl),0) DiscountDtl

			FROM sal.tblRestaurantSaleDtl s
			inner join sal.tblRestaurantSaleHdr sd  on  s.ProcessID=sd.ProcessID and s.ProcessNo=sd.ProcessNo and s.FiscalYear=sd.FiscalYear and s.SerialNo=sd.SerialNo and s.BranchID=sd.BranchID
			INNER JOIN inv.tblStores g
			ON g.StoreID=@StoreID
			INNER JOIN inv.tblGoods d
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=d.GoodsID AND d.PartNumber=@UnitPart
			LEFT JOIN inv.tblGoodsAcntGroup a on a.GoodsAcntGroupID=d.GoodsAcntGroupID
			LEFT JOIN sal.tblSaleTypes st ON st.SaleTypeID=s.SaleTypeID
			WHERE s.ProcessID  = @intSourceProcessID AND
				  s.ProcessNo  = @intSourceProcessNo AND
				  s.FiscalYear = @intSourceFiscalYear AND
				  s.SerialNo   = @intSourceSerialNo AND 
				  s.DocDate    = @strVchDate AND
				  s.BranchID    = @BranchID
			group by g.StoreID,[acc].[funMerg_AcntCode]([acc].[funMergAcntCode](CASE WHEN IsService=1 THEN d.CostCenterAcntCode ELSE st.SaleDiscountAcntCode END,g.SaleDiscountAcntCode),SUBSTRING(UserAcntCode,@intStartP2,@intLenP2) ,P3AcntCode,P4AcntCode),
							   [acc].[funMerg_AcntCode]([acc].[funMergAcntCode](CASE WHEN IsService=1 THEN d.CostCenterAcntCode ELSE st.SaleAcntCode END,g.SaleAcntCode),SUBSTRING(UserAcntCode,@intStartP2,@intLenP2) ,P3AcntCode,P4AcntCode)
		ELSE
			Declare	curStore CURSOR For
			SELECT	g.StoreID,[acc].[funMerg_AcntCode](g.SaleDiscountAcntCode,P2AcntCode,P3AcntCode,P4AcntCode) DiscountAcntCode, 
							  [acc].[funMerg_AcntCode](g.SaleAcntCode,P2AcntCode,P3AcntCode,P4AcntCode) SaleAcntCode, 
					ROUND(SUM(Price *(Qty-RetQty)),0) GoodsPrice,
					ROUND(SUM(DiscountDtl),0) DiscountDtl

			FROM sal.tblRestaurantSaleDtl s
			INNER JOIN inv.tblStores g
			ON g.StoreID=@StoreID
			INNER JOIN inv.tblGoods d
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=d.GoodsID AND d.PartNumber=@UnitPart
			LEFT JOIN inv.tblGoodsAcntGroup a on a.GoodsAcntGroupID=d.GoodsAcntGroupID
			WHERE ProcessID  = @intSourceProcessID AND
				  ProcessNo  = @intSourceProcessNo AND
				  FiscalYear = @intSourceFiscalYear AND
				  SerialNo   = @intSourceSerialNo AND 
				  DocDate    = @strVchDate AND
				  BranchID    = @BranchID
			group by g.StoreID,[acc].[funMerg_AcntCode](g.SaleDiscountAcntCode,P2AcntCode,P3AcntCode,P4AcntCode),
							   [acc].[funMerg_AcntCode](g.SaleAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)		
		Open curStore;

		Fetch NEXT From curStore Into @StoreID,@DiscountAcntCode,@SaleAcntCode,@GoodsPrice,@DiscountDtl

		While (@@Fetch_Status = 0)
		BEGIN

				----- کل تخفیف به بدهکاری هزینه میرود
		IF  (@DiscountDtl ) <> 0
			BEGIN
				IF @DiscountAcntCode is null OR @DiscountAcntCode = ''
					BEGIN
						--کد تخفیف فروش کالا خالي است 
						SET @strMsgText=TS.pub.funGetMessages(11040,@LanguageID)
						Raiserror (@strMsgText,16,1)
						Return
					END	
				IF @OwnerDocNo > 0
					SET @strRecDesc2 = ' تخفیف فروش ' +  @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo)))
				ELSE
					SET @strRecDesc2 = ' تخفیف فروش ' + @strFiscalSerial						
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@DiscountDtl  ,0) / @CurrencyRate
			
				IF [acc].[funIsCurrencyAcntCode] (@DiscountAcntCode) = 'True'
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
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@DiscountAcntCode,ROUND(@DiscountDtl ,0),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmountTmp,@CurrencyTypeIDTmp)
			END

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			IF @CurrencyRate <> 0 
				SET @CurrencyAmount = ROUND(@GoodsPrice ,0) / @CurrencyRate

			IF [acc].[funIsCurrencyAcntCode] (@SaleAcntCode) = 'True'
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
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@SaleAcntCode,0,ROUND(@GoodsPrice,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp ,@CurrencyTypeIDTmp)	

		FETCH NEXT From curStore Into @StoreID,@DiscountAcntCode,@SaleAcntCode,@GoodsPrice,@DiscountDtl
		END -- curStore
		Close curStore;
		Deallocate curStore;

	END
	ELSE
	BEGIN

		----- کل تخفیف به بدهکاری هزینه میرود
		IF  (@Discount ) <> 0
			BEGIN
				IF @DiscountAcntCode is null OR @DiscountAcntCode = ''
					BEGIN
						--کد تخفیف فروش کالا خالي است 
						SET @strMsgText=TS.pub.funGetMessages(11040,@LanguageID)
						Raiserror (@strMsgText,16,1)
						Return
					END	
				IF @OwnerDocNo > 0
					SET @strRecDesc2 = ' تخفیف فروش ' +  @strFiscalSerial + ' فاکتور شماره ' + ltrim(rtrim(str(@OwnerDocNo)))
				ELSE
					SET @strRecDesc2 = ' تخفیف فروش ' + @strFiscalSerial						
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1

				IF @CurrencyRate <> 0 	
					SET @CurrencyAmount = ROUND(@Discount  ,0) / @CurrencyRate
			
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							@DiscountAcntCode,ROUND(@Discount ,0),0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),'',0,@CurrencyAmount,@CurrencyTypeID)
			END

		------------ فروش محصولات ------------------------------------------------------------------------------------

	SET @SumGoodsPrice  = 0

	SELECT	@SumGoodsPrice  = ROUND(SUM(Price *(Qty-RetQty)),0)
	FROM sal.tblRestaurantSaleDtl s
		INNER JOIN inv.tblGoods d
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=d.GoodsID AND d.PartNumber=@UnitPart	
	WHERE d.IsService='False' AND 
		ProcessID  = @intSourceProcessID AND
		ProcessNo  = @intSourceProcessNo AND
		FiscalYear = @intSourceFiscalYear AND
		SerialNo   = @intSourceSerialNo AND 
		DocDate    = @strVchDate AND
		BranchID    = @BranchID
		
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@SumGoodsPrice,0) / @CurrencyRate
			
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@SaleAcntCode,0,ROUND(@SumGoodsPrice ,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount,@CurrencyTypeID)

	
	SET @SumGoodsPrice  = 0
	Declare	curGService CURSOR For
	

		SELECT	 ROUND(Sum (Price *(Qty-RetQty)),0)
		, CostCenterAcntCode, pub.funGetGoodsName(s.GoodsID,1) AS GoodsName
		FROM sal.tblRestaurantSaleDtl s
		INNER JOIN inv.tblGoods d
			ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=d.GoodsID AND d.PartNumber=@UnitPart
		WHERE  IsService='True' AND
			  ProcessID  = @intSourceProcessID AND
			  ProcessNo  = @intSourceProcessNo AND
			  FiscalYear = @intSourceFiscalYear AND
			  SerialNo   = @intSourceSerialNo AND 
			  DocDate    = @strVchDate AND
			  BranchID    = @BranchID	
		group by CostCenterAcntCode,s.GoodsID
		Open curGService;

		Fetch NEXT From curGService Into @SumGoodsPrice,@CostCenterAcntCode,@GoodsName

		While (@@Fetch_Status = 0)
		BEGIN	 

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@SumGoodsPrice,0) / @CurrencyRate
			
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@CostCenterAcntCode,0,ROUND(@SumGoodsPrice ,0) ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@GoodsName  + ' ' + @BranchName + '-' + @strFiscalSerial + @SettlementDate )),'',0,@CurrencyAmount,@CurrencyTypeID)


			FETCH NEXT From curGService Into  @SumGoodsPrice,@CostCenterAcntCode, @GoodsName
		END -- curStore
		Close curGService;
		Deallocate curGService;

	END		
	-----------------------------------------------مالیات بر ارزش افزوده--------------------------------------------
	IF @SaleTaxOverWorthAcntCode <> '' AND @TaxOverWorthCost <> 0
		BEGIN
			--------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescTaxOverWorth VARCHAR(1000) 
			SET @strRecDescTaxOverWorth = ' مالیات بر ارزش افزوده فروش ' +  @strFiscalSerial
			
			--SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			--SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@TaxOverWorthCost,0) / @CurrencyRate
			
			--IF @TaxOverWorthViewInCustomerInvoice = 'True'
			--	INSERT INTO acc.tblVoucherDtl
			--			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
			--				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			--	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			--				@AcntCode,ROUND(@TaxOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0,@CurrencyAmount,@CurrencyTypeID)
		
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 					SELECT @SaleTaxOverWorthAcntCode = [pub].[funMergCode](@SaleTaxOverWorthAcntCode,@AcntCode)

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@SaleTaxOverWorthAcntCode,0,ROUND(@TaxOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTaxOverWorth)),'',0,@CurrencyAmount,@CurrencyTypeID)
			
		END

		-----------------------------------------------عوارض بر ارزش افزوده--------------------------------------------
	IF @SaleTollOverWorthAcntCode <> '' AND @TollOverWorthCost <> 0
		BEGIN
			--------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescTollOverWorth VARCHAR(1000) 
			SET @strRecDescTollOverWorth = ' عوارض بر ارزش افزوده فروش ' +  @strFiscalSerial
			
			--SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			--SET @intMaxRowNo = @intMaxRowNo + 1

			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@TollOverWorthCost,0) / @CurrencyRate
			
			--IF @TaxOverWorthViewInCustomerInvoice = 'True'
			--	INSERT INTO acc.tblVoucherDtl
			--			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
			--				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			--	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
			--				@AcntCode,ROUND(@TollOverWorthCost,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0,@CurrencyAmount,@CurrencyTypeID)
		
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			IF @Sal_TaxAcntCompletWithCustCode = 'True' 				
 					SELECT @SaleTollOverWorthAcntCode = [pub].[funMergCode](@SaleTollOverWorthAcntCode,@AcntCode)


			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@SaleTollOverWorthAcntCode,0,ROUND(@TollOverWorthCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTollOverWorth)),'',0,@CurrencyAmount)
			
		END

		-----------------------------------------------سایر اضافات--------------------------------------------
	IF @OtherIncomeAcntCode <> '' AND @OtherIncome <> 0
		BEGIN
			--------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescOtherIncome VARCHAR(1000) 
			SET @strRecDescOtherIncome = ' جمع اضافات  ' +  @strFiscalSerial
			
			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@OtherIncome,0) / @CurrencyRate
			
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@OtherIncomeAcntCode,0,ROUND(@OtherIncome,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescOtherIncome)),'',0,@CurrencyAmount)
			
		END	

	IF @PackingAcntCode <> '' AND @PackingCost <> 0
		BEGIN
			--------------------------------------------------------------------------------------------------------
			DECLARE @strRecDescPackingCost VARCHAR(1000) 
			SET @strRecDescPackingCost = ' هزینه بسته بندی  ' +  @strFiscalSerial
			
			IF @CurrencyRate <> 0 	
				SET @CurrencyAmount = ROUND(@PackingCost,0) / @CurrencyRate
			
			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@PackingAcntCode,0,ROUND(@PackingCost,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescPackingCost)),'',0,@CurrencyAmount)
			
		END	
						
	IF @ServiceAmount <> 0
	BEGIN
		DECLARE @strRecDescService VARCHAR(1000) 
		SET @strRecDescService = ' حق سرويس فروش ' +  @strFiscalSerial
				
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@ServiceAmount,0) / @CurrencyRate


		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@ServiceAcntCode,0,ROUND(@ServiceAmount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescService)),'',0,@CurrencyAmount)
	END								

	IF @RoundAmount <> 0
	BEGIN
		DECLARE @strRecDescRound VARCHAR(1000) 
		DECLARE @DebitAcntCode VARCHAR(20) 
		DECLARE @CreditAcntCode VARCHAR(20) 
		SET @strRecDescRound = ' مبلغ روند فروش ' +  @strFiscalSerial

		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1


		if @RoundAmount > 0
		BEGIN
			SET @DebitAcntCode=@AcntCode
			SET @CreditAcntCode=@RoundAcntCode
		END
		ELSE
		BEGIN 
			SET @CreditAcntCode=@AcntCode
			SET @DebitAcntCode=@RoundAcntCode
			SET @RoundAmount = @RoundAmount * (-1)
		END

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@RoundAmount,0) / @CurrencyRate

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@DebitAcntCode,ROUND(@RoundAmount,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescRound)),'',0,@CurrencyAmount)
					
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@RoundAmount,0) / @CurrencyRate

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,SourceCodeFieldValue,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@StrSourceCodeFieldValue,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@CreditAcntCode,0,ROUND(@RoundAmount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescRound)),'',0,@CurrencyAmount)
	END		
	
	IF @TransportationIncomeAcntCode <> '' AND @TransportationIncome <> 0
	BEGIN
		DECLARE @strRecDescTrans VARCHAR(1000) 
				
		SET @strRecDescTrans = ' كرايه حمل فروش ' + @strFiscalSerial 

		--------------------------------------------------------------------------------------------------------
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = @TransportationIncome / @CurrencyRate
				
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@AcntCode,ROUND(@TransportationIncome,0) ,0 ,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),'',0,@CurrencyAmount,'')

		--------------------------------------------------------------------------------------------------------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1

		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					@TransportationIncomeAcntCode,0,ROUND(@TransportationIncome,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),'',0,@CurrencyAmount,'')

	END

END
GO
