USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--Drop table ##tblTmpAll

 -- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/12/18
-- Viewed By	 : 
-- Last Modified : 1393/07/01
-- Modifier		 : TakroSystem\Hamid
-- Description	 : چاپ فاکتورهای فروش
-- ==============================================
Create PROCEDURE sal.RptSal_Invoices
	@ProcessNo		TinyInt = Null,
	@FiscalYearFrom	Int = Null,
	@SerialNoFrom	Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DateFrom		Char(10) = Null,
	@DateTo			Char(10) = Null,
	@AcntCode		VarChar(20) = Null,
	@ShowHeader		Bit = 1,
	@ShowEcCodeC	Bit = 0,
	@ShowEcCodeS	Bit = 0,
	@ShowRemain		Bit = 0,
	@ShowFooter		Bit = 0,
	@ShowIvcCode	Bit = 0,
	@ShowDiscount	Bit = 0,
	@ShowQuantity	Bit = 0,
	@RowsCount		TinyInt = 0, -- if 0 then no empty rows
	@Grouped		Bit = 0,
	@SaleTypeID		VarChar(20) = Null,
	@ExtraParams	NVarChar(500) = Null

WITH ENCRYPTION
AS 

DECLARE @StrSelectA	NVarChar(Max);
DECLARE @StrSelectB	NVarChar(Max);
DECLARE @StrSelectC	NVarChar(Max);
DECLARE @StrSelectD	NVarChar(Max);
DECLARE @StrSelectE	NVarChar(Max);
DECLARE @StrSelect1	NVarChar(Max);
DECLARE @StrSelect2	NVarChar(Max);
DECLARE @StrSelect3	NVarChar(Max);
DECLARE @StrFrom	NVarChar(Max);
DECLARE @StrFrom2	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @StrWhere1	NVarChar(Max);
DECLARE @StrWhere2	NVarChar(Max);
DECLARE @LanguageID TinyInt;
DECLARE @AcntLast	NVarChar(20);
DECLARE @BaseDate	NVarChar(10);
DECLARE @StrFields1	NVarChar(Max);
DECLARE @StrFields2	NVarChar(Max);
DECLARE @StrFields3	NVarChar(Max);
DECLARE @StrFields4	NVarChar(Max);
DECLARE @StrFields5	NVarChar(Max);
DECLARE @Row		Int;
DECLARE @MaxRowNo	Int;
DECLARE @RowCnt		Int;
DECLARE @MinRowNo	Int;
DECLARE @FiscalYear SmallInt;
DECLARE @SerialNo	Int;
DECLARE @LangID		VarChar(3);
DECLARE @TransID	VarChar(20);
DECLARE @Remain1	Bit;
DECLARE @Remain2	Bit;
DECLARE @Remain3	Bit;
DECLARE @Remain4	Bit;
DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;
DECLARE @Customer1	Int;
DECLARE @Customer2	Int;
DECLARE @Customer3	Int;
DECLARE @Customer4	Int;
DECLARE @DisH1		VarChar(50);
DECLARE @DisH2		VarChar(50);
DECLARE @DisH3		VarChar(50);
DECLARE @DisH4		VarChar(50);
DECLARE @DisH5		VarChar(50);
DECLARE @DisD1		VarChar(50);
DECLARE @Eqal		NVarChar(2000);
DECLARE @EqalRet	NVarChar(2000);
DECLARE @Dist0		NVarChar(20);
DECLARE @Dist1		NVarChar(20);
DECLARE @Dist2		NVarChar(20);
DECLARE @Disti0		NVarChar(20);
DECLARE @Disti1		NVarChar(20);
DECLARE @Disti2		NVarChar(20);
DECLARE @DistInf	NVarChar(500);
DECLARE @SH			NVarChar(50);
DECLARE @SD			NVarChar(50);
DECLARE @IsSettle	bit;
DECLARE @IsCurrency	bit;
DECLARE @ShowRemainAndDay	bit;
DECLARE @SettleStr	char(1);
DECLARE @SvcFY		int;
DECLARE @SvcSN		int;
DECLARE @SessionNo  int;
DECLARE @ReportID   int;
DECLARE @StoreID	int ;

DECLARE @fval Float;
DECLARE @sval Varchar(50);
DECLARE @IATollPercent Varchar(50);

DECLARE @StoreVar1 varchar(50);
DECLARE @StoreVar2 varchar(50);
DECLARE @db_0000   nvarchar(50)

DECLARE	@HasSerial			Bit;
DECLARE	@FromExpireDate		Varchar(10);
DECLARE	@ToExpireDate		Varchar(10);
DECLARE @PrdBatchNoFr		NVarChar(20);
DECLARE @PrdBatchNoTo		NVarChar(20);
DECLARE @PrdSerialFr		NVarChar(20);
DECLARE @PrdSerialTo		NVarChar(20);

DECLARE @SaleTypeIDS		NVarChar(100);
DECLARE @SaleTypeNameS		NVarChar(100);

DECLARE @StartTargetLayer	TinyInt;
DECLARE @LenTargetLayer		TinyInt;
DECLARE @Part1End			TinyInt;
DECLARE @IsMultiLng			bit;
DECLARE @GoodsGroup		  int;
DECLARE @CalcSalesInRemain  bit;

DECLARE @CountCustomerKind  INT;

DECLARE @CastomerDefaultPrivilege  Float;

-- ======
DECLARE @process_id					int;
DECLARE @process_no					int;
DECLARE @fiscal_year				int;
DECLARE @serial_no					int;
DECLARE @rowNo_no					int;
DECLARE @goods_id					Varchar(20);
DECLARE @goods_quantityGoodsOty		DECIMAL(28,9);
DECLARE @goods_quantitySubUnitQty	DECIMAL(28,9);

-- ======
DECLARE @unit_nameGoodsOty			nvarchar(200);
DECLARE @unit_idGoodsOty			varchar(20);
DECLARE @unit_valueGoodsOty			float;
DECLARE @unit_valueGoodsOty_Temp	float;
DECLARE @Mainunit_valueGoodsOty		float;
DECLARE @CntGoodsQty				INT;

DECLARE @unit_nameGoodsOty1			nvarchar(200);
DECLARE @unit_idGoodsOty1			varchar(20);
DECLARE @unit_valueGoodsOty1		float;
DECLARE @Mainunit_valueGoodsOty1	float;

DECLARE @unit_nameGoodsOty2			nvarchar(200);
DECLARE @unit_idGoodsOty2			varchar(20);
DECLARE @unit_valueGoodsOty2		float;
DECLARE @Mainunit_valueGoodsOty2	float;

DECLARE @MainAndSubUnit  bit;
DECLARE @CalcLineTaxAndTollInRptInvoice  bit;

DECLARE @sal_AggregateSimilarGoodsInRpt		Bit;
DECLARE @sal_AggregateGoodsPrices			Bit;
	
DECLARE @strVirtualQuantity			NVarChar(200);
DECLARE @strTaxOverWorthCostDtl		NVarChar(200);
DECLARE @strTollOverWorthCostDtl	NVarChar(200);
DECLARE @strGoodsQuantity			NVarChar(200);
DECLARE @strGoodsPrice				NVarChar(200);
DECLARE @strSubUnitPrice			NVarChar(200);
DECLARE @strGoodsPrice3				NVarChar(200);
DECLARE @strGoodsQuantity3			NVarChar(200);
DECLARE @strSubUnitQuantity3		NVarChar(200);
DECLARE @strHeight					NVarChar(200);
DECLARE @strWidth					NVarChar(200);
DECLARE @strServiceAmount			NVarChar(200);

DECLARE @strSubUnitQuantity		  	NVarChar(200);
DECLARE @strDiscountPercentDtl	  	NVarChar(200);
DECLARE @strVisitorPercent		  	NVarChar(200);
DECLARE @strTotalQuantityGoodsOty   NVarChar(200);
DECLARE @strTotalQuantityGoodsOty1  NVarChar(200);
DECLARE @strTotalQuantityGoodsOty2  NVarChar(200);
DECLARE @DocRowNo					NVarChar(200);
DECLARE @RowNo						NVarChar(200);
DECLARE @DescDtl					NVarChar(200);
DECLARE @BaseProcessID				NVarChar(200);
DECLARE @BaseProcessNo				NVarChar(200);
DECLARE @BaseFiscalYear				NVarChar(200);
DECLARE @BaseSerialNo				NVarChar(200);
DECLARE @StoreVariable1				NVarChar(200);
DECLARE @StoreVariable2				NVarChar(200);
DECLARE @DiscountDtl				NVarChar(200);
DECLARE @CurrencyAmount				NVarChar(200);
DECLARE @ConstText2					NVarChar(200);
DECLARE @ConstText3					NVarChar(200);
DECLARE @ConstText4					NVarChar(200);
DECLARE @Var1						NVarChar(200);
DECLARE @Var2						NVarChar(200);
DECLARE @Var3						NVarChar(200);
DECLARE @Var4						NVarChar(200);
DECLARE @BatchField					NVarChar(200);
DECLARE @BatchGroupField			NVarChar(200);
DECLARE @GroupBy					NVarChar(Max);
DECLARE @GroupBy2					NVarChar(Max);
DECLARE @OrderBy					NVarChar(100);
DECLARE @strStoreID					VarChar(100);
DECLARE @UserSign1					NVarChar(1000);
DECLARE @UserSign2					NVarChar(1000);

DECLARE @bolReceiptsSum				Bit;
DECLARE @strReceiptsTable			NVarChar(Max);
DECLARE @strReceiptsFields			NVarChar(Max);

DECLARE @Sal_GetGoodsAmountAfterTaxToll AS Int
DECLARE @TaxOverWorthBeforDiscount		bit;
DECLARE @TaxOverWorthAfterIncomeInSale  bit;
declare @TaxSerialNoOrder			bit
declare @TaxSerialNoFrom			Int 
declare @TaxSerialNoTo				Int 	
declare @AvragePricesGroup			Int 
declare @ShowUserInvoiceSign		bit
declare @WithBatch					bit
declare @UserInvoiceSign1			NVarChar(1000);	
declare @UserInvoiceSign2			NVarChar(1000);	
declare @RecDebAcntCodeRet			VarChar(20);	
declare @TaxBranchID				VarChar(50);	
declare @GregorianDate              VarChar(30);
declare @NotShowReward				bit
declare @OnlyShowReward				bit
declare @ShowSecondPrice			bit
declare @CurrentUser	            VarChar(30);

DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;

Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	-- I N I T -----------------------------------------------------------------------------------
	set @ShowRemainAndDay = 0;
	set @Customer1 = 0;
	set @Customer2 = 0;
	set @Customer3 = 0;
	set @Customer4 = 0;
	set @sal_AggregateSimilarGoodsInRpt = 0
	SET @WithBatch = 'False'

	
	SELECT @TaxBranchID = SettingValue FROM pub.tblSettings WHERE SettingKey='TaxBranchID'
	SELECT @RecDebAcntCodeRet = SettingValue FROM pub.tblSettings WHERE SettingKey =  'RecDebAcntCodeRet'

	SELECT @TaxOverWorthBeforDiscount = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TaxOverWorthBeforDiscount'
	SELECT @TaxOverWorthAfterIncomeInSale = SettingValue FROM pub.tblSettings WHERE SettingKey = 'TaxOverWorthAfterIncomeInSale'
	
	IF @TaxBranchID is null SET @TaxBranchID = ''

	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	Set @strStoreID	 = ',H.StoreID'
	select @IsSettle = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'InvHasSettlementKind'
	
	set @fval = 0;
	
	set @IATollPercent = '0'
	set @IATollPercent = ISNULL((
		select replace(SettingValue,'/','.')
		from pub.tblSettings
		where SettingKey = 'InterfaceAccountTollPercent'), '0')
	
	if (@IATollPercent = '')
		set @IATollPercent = '0'	
	
	set @sval = '0'
	set @sval = ISNULL((
		select replace(SettingValue,'/','.')
		from pub.tblSettings
		where SettingKey = 'TaxOverWorthPercentInSale'), '0')
	if (@sval <> '')
		set @fval = @fval + CAST(@sval as float);
		
	set @sval = '0'
	set @sval = ISNULL((
		select replace(SettingValue,'/','.')
		from pub.tblSettings
		where SettingKey = 'TollOverWorthPercentInSale'), '0')
	if (@sval <> '')
		set @fval = @fval + CAST(@sval as float);

	set @sval = '-'
	set @sval = ISNULL((
		select SettingValue
		from pub.tblSettings
		where SettingKey = 'invStoreVariable1'), '')
	set @StoreVar1 = @sval;
	
	set @sval = '-'
	set @sval = ISNULL((
		select SettingValue
		from pub.tblSettings
		where SettingKey = 'invStoreVariable2'), '')
	set @StoreVar2 = @sval;

	set @SettleStr = case when (@IsSettle=1) then '1' else '0' end
	
	If (@ProcessNo Is Null) 
		SET @ProcessNo = 1;

	SET		@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	SELECT @LanguageID = pub.funGetCurrentLanguageID();
	SET @LangID			  = LTrim(Str(@LanguageID));

	SET @bolReceiptsSum = 'False'
	SET @strReceiptsTable = ''
	SET @strReceiptsFields = ',0 CashReceiptAmountPre, 0 CashFishReceiptAmountPre, 0 DepositReceiptAmountPre, 
							   0 ChequeReceiptAmountPre, 0 CashReceiptAmount, 0 DepositReceiptAmount, 0 CashFishReceiptAmount, 
							   0 ChequeReceiptAmount'
	
	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)

	-- =========================================================================================
	SET @TransID							= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @Remain1							= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @Remain2							= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @Remain3							= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @Remain4							= LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @DistInf							= LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	
		SET @Dist0	= LTrim(pub.funSplitString(@DistInf, '#', 1));
		SET @Dist1	= LTrim(pub.funSplitString(@DistInf, '#', 3));
		SET @Dist2	= LTrim(pub.funSplitString(@DistInf, '#', 5));
		SET @Disti0	= LTrim(pub.funSplitString(@DistInf, '#', 7));
		SET @Disti1	= LTrim(pub.funSplitString(@DistInf, '#', 10));
		SET @Disti2	= LTrim(pub.funSplitString(@DistInf, '#', 12));

	SET @SvcFY								= LTrim(pub.funSplitString(@ExtraParams, '@', 15));
	SET @SvcSN								= LTrim(pub.funSplitString(@ExtraParams, '@', 16));
	SET @Customer1							= LTrim(pub.funSplitString(@ExtraParams, '@', 17));
	SET @Customer2							= LTrim(pub.funSplitString(@ExtraParams, '@', 18));
	SET @Customer3							= LTrim(pub.funSplitString(@ExtraParams, '@', 19));
	SET @Customer4							= LTrim(pub.funSplitString(@ExtraParams, '@', 20));
	SET @SessionNo							= LTrim(pub.funSplitString(@ExtraParams, '@', 21));
	SET @ReportID							= LTrim(pub.funSplitString(@ExtraParams, '@', 22));
	SET @IsCurrency							= LTrim(pub.funSplitString(@ExtraParams, '@', 23));	
	SET @CurrentUser						= LTrim(pub.funSplitString(@ExtraParams, '@', 27));
	SET @ShowRemainAndDay					= LTrim(pub.funSplitString(@ExtraParams, '@', 28));
	SET @HasSerial							= LTrim(pub.funSplitString(@ExtraParams, '@', 29));
	SET @FromExpireDate						= LTrim(pub.funSplitString(@ExtraParams, '@', 30));
	SET @ToExpireDate						= LTrim(pub.funSplitString(@ExtraParams, '@', 31));
	SET @PrdBatchNoFr						= LTrim(pub.funSplitString(@ExtraParams, '@', 32));
	SET @PrdBatchNoTo						= LTrim(pub.funSplitString(@ExtraParams, '@', 33));
	SET @PrdSerialFr						= LTrim(pub.funSplitString(@ExtraParams, '@', 34));
	SET @PrdSerialTo						= LTrim(pub.funSplitString(@ExtraParams, '@', 35));
	SET @StartTargetLayer					= LTrim(pub.funSplitString(@ExtraParams, '@', 36));
	SET @LenTargetLayer						= LTrim(pub.funSplitString(@ExtraParams, '@', 37));
	SET @IsMultiLng							= LTrim(pub.funSplitString(@ExtraParams, '@', 38));
	SET @GoodsGroup		    				= LTrim(pub.funSplitString(@ExtraParams, '@', 39));
	SET @CalcSalesInRemain  				= LTrim(pub.funSplitString(@ExtraParams, '@', 40));
	SET @MainAndSubUnit						= LTrim(pub.funSplitString(@ExtraParams, '@', 41));
	SET @CalcLineTaxAndTollInRptInvoice		= LTrim(pub.funSplitString(@ExtraParams, '@', 43));
	SET @sal_AggregateSimilarGoodsInRpt		= LTrim(pub.funSplitString(@ExtraParams, '@', 44));
	SET @sal_AggregateGoodsPrices			= LTrim(pub.funSplitString(@ExtraParams, '@', 47));
	SET @bolReceiptsSum						= LTrim(pub.funSplitString(@ExtraParams, '@', 48));
	SET @Sal_GetGoodsAmountAfterTaxToll		= LTrim(pub.funSplitString(@ExtraParams, '@', 49));
	
	SET @TaxSerialNoOrder					= LTrim(pub.funSplitString(@ExtraParams, '@', 55));
	SET @TaxSerialNoFrom					= LTrim(pub.funSplitString(@ExtraParams, '@', 56));
	SET @TaxSerialNoTo						= LTrim(pub.funSplitString(@ExtraParams, '@', 57));
	SET @AvragePricesGroup					= LTrim(pub.funSplitString(@ExtraParams, '@', 58));
	SET @ShowUserInvoiceSign				= LTrim(pub.funSplitString(@ExtraParams, '@', 59));
	SET @WithBatch							= LTrim(pub.funSplitString(@ExtraParams, '@', 60));
	SET @GregorianDate						= LTrim(pub.funSplitString(@ExtraParams, '@', 61));
	SET @NotShowReward						= LTrim(pub.funSplitString(@ExtraParams, '@', 62));
	SET @OnlyShowReward						= LTrim(pub.funSplitString(@ExtraParams, '@', 63));
	SET @ShowSecondPrice					= LTrim(pub.funSplitString(@ExtraParams, '@', 64));
	SET @StoreID							= LTrim(pub.funSplitString(@ExtraParams, '@', 65));

	SET @UserID								= LTrim(pub.funSplitString(@ExtraParams, '@', 67));
	SET @UserIsAdmin						= LTrim(pub.funSplitString(@ExtraParams, '@', 68));
		
	DECLARE @UserInvoiceSign int
	SELECT @UserInvoiceSign = isnull(SettingValue,-1) from pub.tblSettings where SettingKey = 'UserInvoiceSign'	
	if @ShowUserInvoiceSign='False' or  @UserInvoiceSign <=0
	begin
		set @UserInvoiceSign1='  Cast('''' As Image) As UserInvoiceSignSignature,   '
		set @UserInvoiceSign2=''
	end
	else
	begin
		Set @UserInvoiceSign1= '
					UserInvoiceSign.UserSign as UserInvoiceSignSignature,'
		Set @UserInvoiceSign2= '
				left join #tbl_Invoice_Signatures UserInvoiceSign on UserInvoiceSign.UserID = ' + str(@UserInvoiceSign)+ ' '
	end
	
	--SET @sal_AggregateSimilarGoodsInRpt = 0
	
	--select @TaxSerialNoOrder,@TaxSerialNoFrom,@TaxSerialNoTo,@AvragePricesGroup

	--========================
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	--===============================
	SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)
		
	create table #tbl_Invoice_Signatures
	(
		UserID	int,
		UserSign	image
	);
	
	------
	set @StrSelectA = '
	INSERT INTO #tbl_Invoice_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + ltrim(rtrim(@db_0000)) + '.usr.tblUsers U '
	
	--print @StrSelectA;
	exec sp_executesql @StrSelectA;

	delete from #tbl_Invoice_Signatures where UserSign IS NULL

	--if (select COUNT(*)  from sys.tables where name='tbl_CDescription')=0
	--BEGIN
	--	EXEC [sal].[SpGetCustomreGoodsDescription]
	--END

	--Select @CountCustomerKind = Count(*)
	--From sal.tbl_CDescription
	--where CDescription<>''
	
	SET  @CountCustomerKind = 0
	-- ==========
	DECLARE @QuantityDecimals AS Int
	SELECT  @QuantityDecimals=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'QuantityDecimals'	
	SET		@QuantityDecimals = isnull(@QuantityDecimals,0)

	DECLARE @PriceDecimals AS Int
	SELECT  @PriceDecimals=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'PriceDecimals'	
	SET		@PriceDecimals = isnull(@PriceDecimals,0)

	-- ==========
	begin try
		drop table #tbl_result
	end try
	begin catch
	end catch
	
	Create Table #tbl_result
	(
		ProcessID					Int, 
		ProcessNo					Int,
		FiscalYear					Int,
		SerialNo					Int,
		RowNo						Int,	
		GoodsID						varchar(20) collate Arabic_CS_AS null,
		GoodsName					nvarchar(200) collate Arabic_CI_AS_KS_WS null,
		TotalQuantityGoodsOty		DECIMAL(28,9),
		UnitIDGoodsOty1				varchar(20) collate Arabic_CS_AS null,
		UnitNameGoodsOty1			nvarchar(200) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty1		DECIMAL(28,9),
		UnitIDGoodsOty2				varchar(20) collate Arabic_CS_AS null,
		UnitNameGoodsOty2			nvarchar(20) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty2		DECIMAL(28,9),
		Weight						float,
		Volume						float,
		BarCode						varchar(20) collate Arabic_CS_AS null
	);

	-- ==========
	DECLARE @tbl_units as table
	(
		unit_idGoodsOty				varchar(20) not null, 
		unit_nameGoodsOty			nvarchar(200) not null, 
		unit_valueGoodsOty			float not null,
		Mainunit_valueGoodsOty		float not null,
		cntGoodsOty					int not null								
	);		
		
	----------------------------------------------
	-- unreceipt cheques -------------------------
	----------------------------------------------
	CREATE TABLE #tbl_Sal_Invoices_Cheques
	(
		AcntCode varchar(20) collate arabic_cs_as not null,
		ChequesRemainAmount float not null
	)
	
	declare @Today char(10);
	set @Today = left(pub.funFarsiDate(GetDate()), 10);
	
	INSERT INTO #tbl_Sal_Invoices_Cheques(AcntCode, ChequesRemainAmount) 
	SELECT	VOL.FirstCreditCode, IsNull(Sum(PD.Amount), 0) 
	FROM	trs.tblPayDtl PD
			INNER JOIN 
			(
				SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo,
					(
						select top 1 X.CreditCode
						from trs.tblPayDtl X
						where   (X.ProcessID IN (1,10))
							and (X.PayTypeID IN (6,26))
							and (X.VolumeFiscalYear=PD.VolumeFiscalYear)
							and (X.VolumeRowNo=PD.VolumeRowNo)
					) FirstCreditCode
				FROM	trs.tblPayDtl PD
				WHERE	PD.PayTypeID IN (6, 26) 
				GROUP BY VolumeFiscalYear, VolumeRowNo
			) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26)
		AND (PD.ProcessID IN (1, 10, 17, 20, 21, 23, 40) or (PD.ProcessID = 2 AND PD.ChequeDate > @Today))
		AND (VOL.FirstCreditCode = PD.CreditCode)
	GROUP BY VOL.FirstCreditCode
	HAVING VOL.FirstCreditCode is not null
		
----------------------------------------------------------------------------------------------
select ProcessID	,ProcessNo	,FiscalYear	,SerialNo,RowNo	,DocRowNo	,GoodsID ,BatchNo	,
	 GoodsPrice SumPriceDtl	,AcntCode	,DocDate	, DocDate	VchDate	,  GoodsID CurrencyTypeID	, GoodsPrice CurrencyRate	
	, 1 IsReturn	,DiscountDtl	,TaxOverWorthCostDtl	,TollOverWorthCostDtl	,DiscountDtl	 Discount	, DiscountDtl Discount2	
	,CurrencyAmount	,DiscountDtl DiscountTaxOverWorth	,TaxOverWorthCostDtl TaxOverWorthCost	, TollOverWorthCostDtl TollOverWorthCost	
	, GoodsPrice SumDiscountHdr	, GoodsPrice SumPrice	, GoodsPrice SumPriceDtlWithTax	, DiscountDtl DiscountHdr	
	,TaxOverWorthCostDtl TaxDtl	,TollOverWorthCostDtl TollDtl	,GoodsPrice PurePrice	,DiscountDtl TotalDiscount	,TaxOverWorthCostDtl TaxTollDtl
	
Into #tblStorageDocs
from inv.tblStorageDocsDtl
where 1=0

declare @Ext varchar(100) 
set @Ext='90@'+str(@ProcessNo)+'@'+str(@FiscalYearFrom)+'@'+str(@SerialNoFrom)+'@'+str(@FiscalYearTo)+'@'+str(@SerialNoTo)+' '

insert into #tblStorageDocs
exec inv.SpStorageDocs  @Ext

	-- W H E R E ---------------------------------------------------------------------------------
	SET @StrWhere = ' D.ProcessID = 90 AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
    SET @StrWhere1 = '' 
    
	If (@Dist0 <> 'null') and (@Dist0 <> '')
		SET @StrWhere = @StrWhere + ' AND H.DriverID=''' + LTrim(@Dist0) + ''''
	If (@Dist1 <> 'null') and (@Dist1 <> '')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID1=''' + LTrim(@Dist1) + ''''
	If (@Dist2 <> 'null') and (@Dist2 <> '')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID2=''' + LTrim(@Dist2) + ''''

	If (@Disti0 <> 'null') and (@Disti0 <> '')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID=' + LTrim(@Disti0) 
	If (@Disti1 <> 'null') and (@Disti1 <> '')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionSerialNo>=' + LTrim(@Disti1) 
	If (@Disti2 <> 'null') and (@Disti2 <> '')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionSerialNo<=' + LTrim(@Disti2) 

	IF (@StoreID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'H.StoreID')

	IF (@Customer1 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer1, 'D.AcntCode')
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer1, 'D.AcntCode')
	End
	IF (@Customer2 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer2, 'D.AcntCode')
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer2, 'D.AcntCode')
	End
	IF (@Customer3 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer3, 'D.AcntCode')
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer3, 'D.AcntCode')
	End
	IF (@Customer4 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer4, 'D.AcntCode')
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer4, 'D.AcntCode')
	End

	If (@FiscalYearFrom	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear>' + LTrim(Str(@FiscalYearFrom)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalYearFrom)) + ' AND D.SerialNo>=' + LTrim(Str(@SerialNoFrom)) + ')) '
	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear<' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo<=' + LTrim(Str(@SerialNoTo)) + ')) '
	
	If @TaxSerialNoOrder='true'
		SET @StrWhere = @StrWhere + ' AND H.TaxSerialNoInvoice>0'
	
	If (@TaxSerialNoFrom >0)
		SET @StrWhere = @StrWhere + ' AND H.TaxSerialNoInvoice>=' + LTrim(Str(@TaxSerialNoFrom)) + ' '
	If (@TaxSerialNoTo >0)
		SET @StrWhere = @StrWhere + ' AND H.TaxSerialNoInvoice<=' + LTrim(Str(@TaxSerialNoTo)) + ' '
	
	IF (@TransID <> '0' And @TransID <> '') 
		SET @StrWhere = @StrWhere + ' AND H.TransporterID=''' + @TransID + ''''
		
	If (@DateFrom Is Not Null) OR (@DateTo Is Not Null)
		If (@DateFrom = @DateTo)
			SET @StrWhere = @StrWhere + ' AND D.DocDate=''' + @DateFrom + ''''
		Else 
		Begin
			If (@DateFrom Is Not Null)
				SET @StrWhere = @StrWhere + ' AND D.DocDate>=''' + @DateFrom + ''''
			If @DateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND D.DocDate<=''' + @DateTo + ''''
		End

	If (@AcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AcntCode=''' + @AcntCode + ''''

	If (@SaleTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.SaleTypeID=''' + @SaleTypeID + ''''

	-------------------------------------------------------------------------------------------
	if (@IsCurrency = 1)
	begin
		if (@GoodsGroup > 0)
		begin
 			set @SH = 'inv.vwStorageHdr_Group_Currency'
			set @SD = 'inv.funStorageDtl_Group_Currency ('+ltrim(STR(@GoodsGroup))+')'
		end
		else
		begin
			set @SH = 'inv.vwStorageHdr_Currency'
			set @SD = 'inv.vwStorageDtl_Currency'		
		end		
	end
	else
	begin
		if (@GoodsGroup > 0)
		begin
 			set @SH = 'inv.vwStorageHdr_Group'
			set @SD = 'inv.funStorageDtl_Group ('+ltrim(STR(@GoodsGroup))+','+str(@AvragePricesGroup)+')'
		end
		else
		begin
			set @SH = 'inv.tblStorageDocsHdr'
			set @SD = 'inv.tblStorageDocsDtl'		
		end
	end

	--=========================================
	IF @bolReceiptsSum = 'True'
	BEGIN
		SET @strReceiptsFields = ', (Select IsNull(Sum(Amount),0)
									 From trs.tblPayHdr PH
									 Inner Join trs.tblPayDtl PD ON PD.ProcessID = PH.ProcessID And PD.ProcessNo = PH.ProcessNo And
																    PD.FiscalYear = PH.FiscalYear And PD.SerialNo = PH.SerialNo And 
																    PD.PayTypeID Not In (3, 4, 6, 26)
									 Where PH.BaseProcessID  = H.ProcessID And PH.BaseProcessNo = H.ProcessNo And 
										   PH.BaseFiscalYear = H.FiscalYear And PH.BaseSerialNo = H.SerialNo And
										   PH.DocDate <= H.DocDate) CashReceiptAmountPre,
										   
									(Select IsNull(Sum(Amount),0)
									 From trs.tblPayHdr PH
									 Inner Join trs.tblPayDtl PD ON PD.ProcessID = PH.ProcessID And PD.ProcessNo = PH.ProcessNo And
																    PD.FiscalYear = PH.FiscalYear And PD.SerialNo = PH.SerialNo And 
																    PD.PayTypeID In (3)
									 Where PH.BaseProcessID  = H.ProcessID And PH.BaseProcessNo = H.ProcessNo And 
										   PH.BaseFiscalYear = H.FiscalYear And PH.BaseSerialNo = H.SerialNo And
										   PH.DocDate <= H.DocDate) CashFishReceiptAmountPre,

									(Select IsNull(Sum(Amount),0)
									 From trs.tblPayHdr PH
									 Inner Join trs.tblPayDtl PD ON PD.ProcessID = PH.ProcessID And PD.ProcessNo = PH.ProcessNo And
																    PD.FiscalYear = PH.FiscalYear And PD.SerialNo = PH.SerialNo And 
																    PD.PayTypeID In (4)
									 Where PH.BaseProcessID  = H.ProcessID And PH.BaseProcessNo = H.ProcessNo And 
										   PH.BaseFiscalYear = H.FiscalYear And PH.BaseSerialNo = H.SerialNo And
										   PH.DocDate <= H.DocDate) DepositReceiptAmountPre,
										   										   									
									(Select IsNull(Sum(Amount),0)
									 From trs.tblPayHdr PH
									 Inner Join trs.tblPayDtl PD ON PD.ProcessID = PH.ProcessID And PD.ProcessNo = PH.ProcessNo And
																    PD.FiscalYear = PH.FiscalYear And PD.SerialNo = PH.SerialNo And 
																    PD.PayTypeID In (6, 26)
									 Where PH.BaseProcessID  = H.ProcessID And PH.BaseProcessNo = H.ProcessNo And 
										   PH.BaseFiscalYear = H.FiscalYear And PH.BaseSerialNo = H.SerialNo And
										   PH.DocDate <= H.DocDate) ChequeReceiptAmountPre,
										   
									(Select IsNull(Sum(Amount),0)
									 From trs.tblPayHdr PH
									 Inner Join trs.tblPayDtl PD ON PD.ProcessID = PH.ProcessID And PD.ProcessNo = PH.ProcessNo And
																    PD.FiscalYear = PH.FiscalYear And PD.SerialNo = PH.SerialNo And 
																    PD.PayTypeID Not In (3, 4, 6, 26)
									 Where PH.BaseProcessID  = H.ProcessID And PH.BaseProcessNo = H.ProcessNo And 
										   PH.BaseFiscalYear = H.FiscalYear And PH.BaseSerialNo = H.SerialNo And
										   PH.DocDate > H.DocDate) CashReceiptAmount,
									
									(Select IsNull(Sum(Amount),0)
									 From trs.tblPayHdr PH
									 Inner Join trs.tblPayDtl PD ON PD.ProcessID = PH.ProcessID And PD.ProcessNo = PH.ProcessNo And
																    PD.FiscalYear = PH.FiscalYear And PD.SerialNo = PH.SerialNo And 
																    PD.PayTypeID Not In (3)
									 Where PH.BaseProcessID  = H.ProcessID And PH.BaseProcessNo = H.ProcessNo And 
										   PH.BaseFiscalYear = H.FiscalYear And PH.BaseSerialNo = H.SerialNo And
										   PH.DocDate > H.DocDate) CashFishReceiptAmount,
										   									
								
									(Select IsNull(Sum(Amount),0)
									 From trs.tblPayHdr PH
									 Inner Join trs.tblPayDtl PD ON PD.ProcessID = PH.ProcessID And PD.ProcessNo = PH.ProcessNo And
																    PD.FiscalYear = PH.FiscalYear And PD.SerialNo = PH.SerialNo And 
																    PD.PayTypeID Not In (4)
									 Where PH.BaseProcessID  = H.ProcessID And PH.BaseProcessNo = H.ProcessNo And 
										   PH.BaseFiscalYear = H.FiscalYear And PH.BaseSerialNo = H.SerialNo And
										   PH.DocDate > H.DocDate) DepositReceiptAmount,
										   										   									
									(Select IsNull(Sum(Amount),0)
									 From trs.tblPayHdr PH
									 Inner Join trs.tblPayDtl PD ON PD.ProcessID  = PH.ProcessID And PD.ProcessNo = PH.ProcessNo And
																    PD.FiscalYear = PH.FiscalYear And PD.SerialNo = PH.SerialNo And 
																    PD.PayTypeID In (6, 26)
									 Where PH.BaseProcessID = H.ProcessID And PH.BaseProcessNo = H.ProcessNo And 
										   PH.BaseFiscalYear = H.FiscalYear And PH.BaseSerialNo = H.SerialNo And
										   PH.DocDate > H.DocDate) ChequeReceiptAmount'
	END
	--=========================================
	
	-- ##### گروه بندی کالا تا لایه انتخاب شده
	--if (@GoodsGroup > 0)
	--  begin
	--		set @SH = 'inv.vwStorageHdr_Group'
	--		set @SD = '[inv].[funStorageDtl_Group] ('+ltrim(STR(@GoodsGroup))+')'
	--  end
	-- ##### گروه بندی کالا تا لایه انتخاب شده
	
	--=========================================
	Create Table #tbl_TmpQty
	(
		ProcessID			int,
		ProcessNo			int,
		FiscalYear			int,
		SerialNo			int,
		RowNo				int,
		GoodsID				Varchar(20) collate Arabic_CS_AS null,
		GoodsQuantity		DECIMAL(28,9)
	);
	
	-------------------------------------------------------------------------------------------
	declare @svcCount int;
	set @svcCount = 0;
	
	if (@SvcSN > 0)
		select @svcCount = COUNT(*)
		from acc.tblServicesDtl
		where (FiscalYear = @SvcFY) and (SerialNo = @SvcSN)
		
	if (@ShowDiscount = 1)
	begin
		set @DisH1 = 'H.Discount'
		set @DisH2 = 'H.Discount2+H.Discount3 Discount2'
		set @DisH3 = 'H.TotalLineDiscount'
		set @DisH4 = 'H.AfterSaleDiscount'
		set @DisH5 = 'H.CurrencyDiscount'
		set @DisD1 = 'D.DiscountDtl'
	end
	else
	begin
		set @DisH1 = 'cast(0 as float) Discount'
		set @DisH2 = 'cast(0 as float) Discount2'
		set @DisH3 = 'cast(0 as float) TotalLineDiscount'
		set @DisH4 = 'cast(0 as float) AfterSaleDiscount'
		set @DisH5 = 'cast(0 as float) CurrencyDiscount'
		set @DisD1 = 'cast(0 as float) DiscountDtl'
	end;

	-- to allocate more than 4000 characters its required
	set @StrFields1 = ''
	set @StrFields2 = ''
	set @StrFields3 = ''
	set @StrFields4 = ''
	set @StrFields5 = ''

	IF @sal_AggregateSimilarGoodsInRpt = 1
	BEGIN
		Set @strStoreID				   = ',H.StoreID'
		Set @strVirtualQuantity		   = 'Sum(D.VirtualQuantity) VirtualQuantity'
		Set @strTaxOverWorthCostDtl    = 'Sum(D.TaxOverWorthCostDtl) TaxOverWorthCostDtl'
		Set @strTollOverWorthCostDtl   = 'Sum(D.TollOverWorthCostDtl) TollOverWorthCostDtl'
		Set @strGoodsQuantity		   = 'Sum(D.GoodsQuantity) GoodsQuantity'

		IF @sal_AggregateGoodsPrices = 1
			Set @strGoodsPrice = 'Sum(D.GoodsPrice) GoodsPrice'
		Else
			Set @strGoodsPrice = 'ROUND(D.GoodsPrice,6) GoodsPrice'
		
		IF @ShowSecondPrice=0
			Set @strSubUnitPrice		   = 'Sum(D.SubUnitPrice) SubUnitPrice'
		ELSE
			Set @strSubUnitPrice		   = 'Sum(D.SubUnitPrice2) SubUnitPrice'

		Set @strGoodsPrice3			   = 'Sum(D.GoodsPrice3) GoodsPrice3'
		Set @strGoodsQuantity3		   = 'Sum(D.GoodsQuantity3) GoodsQuantity3'
		Set @strSubUnitQuantity3	   = 'Sum(D.SubUnitQuantity3) SubUnitQuantity3'
		Set @strHeight				   = 'Sum(D.Height) Height'
		Set @strWidth				   = 'Sum(D.Width) Width'
		Set @strServiceAmount		   = 'Sum(D.ServiceAmount) ServiceAmount'
		Set @strSubUnitQuantity		   = 'Sum(D.SubUnitQuantity) SubUnitQuantity'
		Set @strDiscountPercentDtl	   = 'Sum(D.DiscountPercentDtl) DiscountPercentDtl'
		Set @strVisitorPercent		   = 'Sum(D.VisitorPercent) VisitorPercent'
		Set @strTotalQuantityGoodsOty  = 'R2.TotalQuantityGoodsOty'
		Set @strTotalQuantityGoodsOty1 = 'R2.TotalQuantityGoodsOty1'
		Set @strTotalQuantityGoodsOty2 = 'R2.TotalQuantityGoodsOty2'
		Set @DocRowNo				   = '0'
		Set @RowNo					   = '0'
		Set @DescDtl				   = ''''' As DescDtl'
		Set @BaseProcessID			   = '0 As BaseProcessID'
		Set @BaseProcessNo			   = '0 As BaseProcessNo'
		Set @BaseFiscalYear			   = '0 As BaseFiscalYear'
		Set @BaseSerialNo			   = '0 As BaseSerialNo'
		Set @StoreVariable1			   = 'Sum(D.StoreVariable1) StoreVariable1'
		Set @StoreVariable2			   = 'Sum(D.StoreVariable2) StoreVariable2'
		Set @DiscountDtl			   = 'Sum(D.DiscountDtl)'
		Set @DisD1					   = 'Sum(D.DiscountDtl) DiscountDtl'
		Set @CurrencyAmount			   = 'Sum(D.CurrencyAmount) CurrencyAmount'
		Set @ConstText2				   = 'Sum(Cast(Case When IsNumeric(D.ConstText2)=1 then D.ConstText2 else 0 end As Float)) ConstText2,'''' ConstText1_1,'''' ConstText2_1'
		Set @ConstText3				   = 'Sum(Cast(Case When IsNumeric(D.ConstText3)=1 then D.ConstText3 else 0 end As Float)) ConstText3,'''' ConstText3_1'
		Set @ConstText4				   = 'Sum(Case When IsNumeric(D.ConstText4)=1 then D.ConstText4 else 0 end) ConstText4,'''' ConstText4_1'
		Set @Var1					   = 'Sum(D.Var1) Var1'
		Set @Var2					   = 'Sum(D.Var2) Var2'
		Set @Var3					   = 'Sum(D.Var3) Var3'
		Set @Var4					   = 'Sum(D.Var4) Var4,0 BascolWeight, 0 WasteWeight, 0 PureWeight, 0 LoadWeight'
		IF @WithBatch = 'True'
		BEGIN
			Set @BatchField				   = 'D.BatchNo'
			Set @BatchGroupField		   = ',D.BatchNo'
		END
		ELSE
		BEGIN
			Set @BatchField				   = ' '''' BatchNo'
			Set @BatchGroupField		   = ''
		END	 
		Set @GroupBy				   = '
			GROUP BY H.FiscalYear, D.FiscalYear, H.SerialNo, D.SerialNo, H.ProcessID, H.ProcessNo, H.VchDate, H.DocDate,TaxID,BaseTaxID,H.TPInp ,H.CurrencyValue,
					F.PersonType,TPEdited,TPEditedDate,TPContractNo,PayType,
					H.CashID,H.KotagNo,H.KotagDate,H.AssessmentLocation,H.PriceParvane,H.ExitLocation,H.OrderAcntCode, D.GoodsID, D.GoodsID2 ' + @strStoreID + ', 
					 D.GoodsID3'+ @BatchGroupField +', D.StoreID, H.TaxOverWorthCost, H.PayOffTypeID, PT.PayOffTypeName, D.SubUnitID3, DR.DriverID, DRH.DriverTel, DRH.DriverMobile,DRH.NationalNumber,DRH.VehicleNo,
					 PRS1.Tel, PRS1.Mobile, PRS2.Tel, PRS2.Mobile, H.TTMSPayOffTypeID, H.TaxSerialNoInvoice, D.IsReward,H.AfterSaleDesc, G.HasSerial,
					 H.TollOverWorthCost, H.TransportationCost,H.CurrencyTransportationCost,H.CurrencyTransportationIncome,H.IAToll, H.IATollCod, H.TaxCost, H.AcntCode, D.AcntCode, F.AcntName, F.EconomicalCode,
					 F.Address1, F.Address2, F.TableauText, H.DiscountTaxOverWorth, F.Tel, D.DocDate, D.AtomAmount, H.DocDesc, H.DocDesc2, H.VisitorAcntCode, H.VisitorAcntCode2,
					 H.VisitorPercent2, H.VisitorCost2, H.VisitorCostAcntCode2, H.AgreeNo, D.SubUnitID, H.OtherCostAcntCode, H.OtherIncomeAcntCode,
					 H.OtherCost, H.OtherIncome,D.OtherIncomePerentDtl,D.OtherIncomeDtl, H.TransportationIncome, H.TransportationIncomeAcntCode, H.SaleTypeID, D.SaleTypeID, OD.SaleTypeName,
					 OH.SaleTypeName, F.LocationID, R.AreaCode, H.CCNo, H.CCDiscount, H.CCPrivilege, F.ZipCode,GR.StoreZipCode, F.StoreZipCode, F.CustomerFirstName, F.CustomerLastName,
					 F.CompanyRegisterNo, F.NationalIDNumber, H.PackingCost , F.SalesRoomClass, SRC.SalesRoomClassName, F.OrganzationName, H.DiscountPercent,H.DiscountPercent2,
					 H.VchNo, H.EarnestMoney,F.AccExtraField1,F.AccExtraField2,F.AccExtraField3,F.AccExtraField4,F.AccExtraField5,F.AccExtraField6,
					 H.ExtraField1, S.GoodsCID,S.ExtraField1,S.ExtraField2,S.ExtraField3,S.ExtraField4,S.ExtraField5, S.TechnicalSpecifications, H.TransporterID,
					 N.TransporterName, SK.StoreKeeperName,SS.Tel, P.StoreName,P.Address, H.SessionNo, H.SessionNo2, H.SessionNo3, H.SessionNo4, H.SessionNo5, H.DocStep, H.Amount,H.Price, F.Mobile, F.SMSMobile,
					 T.UnitName, W.UnitName, U.UnitName, V.UnitValue ,  V.MainUnitValue , H.DestinationAddress, H.Address, F.Sequence, O2.DaysNo, H.BaseDistributionFiscalYear,
					 H.BaseDistributionSerialNo, S.TechnicalNo, S.GoodsLength, S.GoodsWidth, S.GoodsHeight, H.OwnerDocNo, L2.LocationName, H.CashAmount, F.SaleCash, 
					 H.ChequeAmount, H.ComssionCostPrice, H.BasculePrice, H.LaborPrice, H.TransportPrice, D.ProcessID, D.ProcessNo, H.TransporterID2, VF.Tel, VF2.Tel, VF.Mobile, VF2.Mobile,
					 F.AsnafID, F.OtherTels,F.Email, F.NationalIdentity, F.Fax, F.CustomerKindID, Case When IsNumeric(ConstText1) = 0 OR ConstText1 = ''0'' OR ConstText1 = '''' Then ''0'' Else ConstText1 End, 
					 H.C1, H.C2, H.C3, H.C4, H.C5, H.C6,H.C7, H.C8, H.C9, H.C10, H.C11, H.C12, H.CurrencyTypeID, H.CurrencyRate, DR.FirstName, DR.LastName, H.DistributerID1, H.DistributerID2, R2.UnitIDGoodsOty1, 
					 AfterSaleDiscount,H.CurrencyDiscount, D.UserPriceID,PS.DocDate,GU.UserPrice,H.TotalLineDiscount,H.Discount2,H.Discount3,H.Discount,GBarCode,GP.GoodsPlaceID,GP.GoodsPlaceName,  
					 R2.UnitNameGoodsOty1, R2.UnitIDGoodsOty2, R2.UnitNameGoodsOty2,S.GoodsWeight,S.PureWeight, R2.Weight, R2.Volume, R2.BarCode, H.SettlementDate,DistributDate,SH.DocDate ,GoodsPriceWithTax,PurePrice,DistributionPercent,DistributionPrice, ' + Case When @sal_AggregateGoodsPrices = 0 Then 'ROUND(D.GoodsPrice,6), ' Else '' End + 
					 Case When @CountCustomerKind > 0 Then ' IsNull(DS.CDescription, '''')' Else ' D.GoodsID' End + ', R2.TotalQuantityGoodsOty, R2.TotalQuantityGoodsOty1, R2.TotalQuantityGoodsOty2'
		Set @GroupBy2				   = 'Group By D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.GoodsID'
		Set @OrderBy				   = ''
		Set @UserSign1				   = '
					Cast('''' As Image) As UserSignature1, Cast('''' As Image) As UserSignature2, Cast('''' As Image) As UserSignature3, 
					Cast('''' As Image) As UserSignature4, Cast('''' As Image) As UserSignature5,'		
		Set @UserSign2				   = ''

		--Set @UserSign1				   = '
		--			S1.UserSign as UserSignature1, S2.UserSign as UserSignature2, S3.UserSign as UserSignature3, 
		--			S4.UserSign as UserSignature4, S5.UserSign as UserSignature5,'
		--Set @UserSign2				   = '
		--		left join #tbl_Invoice_Signatures S1 on S1.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo)
		--		left join #tbl_Invoice_Signatures S2 on S2.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo2)
		--		left join #tbl_Invoice_Signatures S3 on S3.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo3)
		--		left join #tbl_Invoice_Signatures S4 on S4.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo4)
		--		left join #tbl_Invoice_Signatures S5 on S5.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo5)'
	END
	ELSE
	BEGIN
		Set @strVirtualQuantity		   = 'D.VirtualQuantity'
		Set @strTaxOverWorthCostDtl    = 'D.TaxOverWorthCostDtl'
		Set @strTollOverWorthCostDtl   = 'D.TollOverWorthCostDtl'
		Set @strGoodsQuantity		   = 'D.GoodsQuantity'
		Set @strGoodsPrice			   = 'D.GoodsPrice'
		IF @ShowSecondPrice=0
			Set @strSubUnitPrice		   = 'D.SubUnitPrice'
		ELSE
			Set @strSubUnitPrice		   = 'D.SubUnitPrice2 SubUnitPrice'
		Set @strGoodsPrice3			   = 'D.GoodsPrice3'
		Set @strGoodsQuantity3		   = 'D.GoodsQuantity3'
		Set @strSubUnitQuantity3	   = 'D.SubUnitQuantity3'
		Set @strHeight				   = 'D.Height'
		Set @strWidth				   = 'D.Width'
		Set @strServiceAmount		   = 'D.ServiceAmount'
		Set @strSubUnitQuantity		   = 'D.SubUnitQuantity'
		Set @strDiscountPercentDtl	   = 'D.DiscountPercentDtl'
		Set @strVisitorPercent		   = 'D.VisitorPercent'
		Set @strTotalQuantityGoodsOty  = 'R2.TotalQuantityGoodsOty'
		Set @strTotalQuantityGoodsOty1 = 'R2.TotalQuantityGoodsOty1'
		Set @strTotalQuantityGoodsOty2 = 'R2.TotalQuantityGoodsOty2'
		Set @DocRowNo				   = 'D.DocRowNo'
		Set @RowNo					   = 'D.RowNo'
		Set @DescDtl				   = 'D.DescDtl'
		Set @BaseProcessID			   = 'D.BaseProcessID'
		Set @BaseProcessNo			   = 'D.BaseProcessNo'
		Set @BaseFiscalYear			   = 'D.BaseFiscalYear'
		Set @BaseSerialNo			   = 'D.BaseSerialNo'
		Set @BaseSerialNo			   = 'D.BaseSerialNo'
		Set @StoreVariable1			   = 'D.StoreVariable1'
		Set @StoreVariable2			   = 'D.StoreVariable2'
		Set @DiscountDtl			   = 'D.DiscountDtl'
		Set @CurrencyAmount			   = 'D.CurrencyAmount'
		Set @ConstText2				   = 'D.ConstText2,D.ConstText1 ConstText1_1,D.ConstText2 ConstText2_1'
		Set @ConstText3				   = 'D.ConstText3,D.ConstText3 ConstText3_1'
		Set @ConstText4				   = 'D.ConstText4,D.ConstText4 ConstText4_1'
		Set @Var1					   = 'D.Var1'
		Set @Var2					   = 'D.Var2'
		Set @Var3					   = 'D.Var3'
		Set @Var4					   = 'D.Var4,H.BascolWeight, H.WasteWeight, H.PureWeight, H.LoadWeight'				
		Set @BatchField				   = 'D.BatchNo'
		Set @BatchGroupField		   = ',D.BatchNo'
		Set @GroupBy				   = ''
		Set @GroupBy2				   = ''
		Set @OrderBy				   = 'ORDER BY SerialNo, DSequence, ' + @DocRowNo
		if @TaxSerialNoOrder='true'
			Set @OrderBy			   = 'ORDER BY TaxSerialNo, SerialNo, DSequence, ' + @DocRowNo
		Set @UserSign1				   = '
					S1.UserSign as UserSignature1, S2.UserSign as UserSignature2, S3.UserSign as UserSignature3, 
					S4.UserSign as UserSignature4, S5.UserSign as UserSignature5,'
		Set @UserSign2				   = '
				left join #tbl_Invoice_Signatures S1 on S1.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo)
				left join #tbl_Invoice_Signatures S2 on S2.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo2)
				left join #tbl_Invoice_Signatures S3 on S3.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo3)
				left join #tbl_Invoice_Signatures S4 on S4.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo4)
				left join #tbl_Invoice_Signatures S5 on S5.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo5)'
	END	
		
	-- =========================== 
	SET @StrSelect1 = 'Insert Into #tbl_TmpQty
					   Select D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, ' + @RowNo + ' RowNo, D.GoodsID, ' + @strGoodsQuantity + '
					   From ' + @SD + ' D
					   Inner Join ' + @SH + ' H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND 
												   H.SerialNo=D.SerialNo 
					   Where ' + @StrWhere + ' ' + 
					   @GroupBy2					   
	--Print @StrSelect1;
	Exec sp_executesql @StrSelect1;		
	
	-- ==========
	SET @StrSelect1 = 'Insert Into #tbl_result
					   select S.ProcessID, S.ProcessNo, S.FiscalYear, S.SerialNo, S.RowNo, S.GoodsID, '''', S.GoodsQuantity, '''', '''', 0, '''', '''', 0, 0, 0, ''''
					   from #tbl_TmpQty S'
	--print @StrSelect1;
	Exec sp_executesql @StrSelect1;	
			
	--Select * From #tbl_TmpQty
	--Select * From #tbl_result		
		
	-- ******************************************************************************
	-- *********************************** Units ************************************
	-- ******************************************************************************
	declare cur_goods cursor for
		select ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, GoodsID, GoodsQuantity
		from #tbl_TmpQty
	open cur_goods;
	
	fetch next from cur_goods into @process_id, @process_no, @fiscal_year, @serial_no, @rowNo_no, @goods_id, @goods_quantityGoodsOty
	
	while (@@fetch_status = 0)
	begin

--Print '==================================='
--Print '@process_id		        = ' + LTrim(RTrim(Str(@process_id)))
--Print '@process_no			    = ' + LTrim(RTrim(Str(@process_no)))
--Print '@fiscal_year            = ' + LTrim(RTrim(Str(@fiscal_year)))
--Print '@serial_no		        = ' + LTrim(RTrim(Str(@serial_no)))
--Print '@rowNo_no		        = ' + LTrim(RTrim(Str(@rowNo_no)))
--Print '@goods_id			    = ' + @goods_id
--Print '@goods_quantityGoodsOty = ' 
--Print @goods_quantityGoodsOty
--Print ''
		--====================== Units
		-- 1- empty units table
		delete from @tbl_units
		
		-- 2- fill units of 1 goods
		insert into @tbl_units
		select top 3 t.UnitID, u.UnitName, t.UnitValue, t.MainUnitValue,
		(SELECT COUNT(*) 
		 from(
				select UnitID, 1 As UnitValue,1 MainUnitValue
				from inv.tblGoods
				where GoodsID = @goods_id
				union
				select SubUnitID, UnitValue,MainUnitValue
				from inv.tblSubUnitsDtl S
				where GoodsID = @goods_id And ShowInInvoice = 1) z
		)cnt
		from
		(
			select UnitID, 1 As UnitValue,1 MainUnitValue
			from inv.tblGoods
			where GoodsID = @goods_id
			union
			select SubUnitID, UnitValue,MainUnitValue
			from inv.tblSubUnitsDtl S
			where GoodsID = @goods_id And ShowInInvoice = 1
			
		) t inner join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = @LangID
		order by (t.MainUnitValue/ t.UnitValue ) desc

--Select * From @tbl_units
--Print '@unit_idGoodsOty        = ' + Str(@unit_idGoodsOty)
--Print '@unit_nameGoodsOty	    = ' + @unit_nameGoodsOty
--Print '@unit_valueGoodsOty     = ' + Str(@unit_valueGoodsOty)
--Print '@Mainunit_valueGoodsOty = ' + Str(@Mainunit_valueGoodsOty)
--Print ''
		--====================== End Units
					
		-- read units row by row
		declare cur_units cursor for
			select *
			from @tbl_units
		open cur_units;

		-- init
		set @unit_idGoodsOty1			 = '';
		set @unit_nameGoodsOty1			 = '';
		set @unit_valueGoodsOty1		 =  0;
		set @Mainunit_valueGoodsOty1	 =  0;
		set @unit_idGoodsOty2			 = '';
		set @unit_nameGoodsOty2			 = '';
		set @unit_valueGoodsOty2		 =  0;
		set @Mainunit_valueGoodsOty2	 =  0;	
		
		-- First Unit
		fetch next from cur_units into @unit_idGoodsOty, @unit_nameGoodsOty, @unit_valueGoodsOty, @Mainunit_valueGoodsOty, @CntGoodsQty;

		if (@@fetch_status = 0)
		begin
			set @unit_idGoodsOty1		 = @unit_idGoodsOty;
			set @unit_nameGoodsOty1		 = @unit_nameGoodsOty;
								
			if @CntGoodsQty > 1
			Begin
				set @unit_valueGoodsOty1 = floor((@goods_quantityGoodsOty + 0.000000001) * @unit_valueGoodsOty / @Mainunit_valueGoodsOty)
			End
			Else
			Begin
				set @unit_valueGoodsOty1 = @goods_quantityGoodsOty * @unit_valueGoodsOty / @Mainunit_valueGoodsOty
			End

--Print '@unit_idGoodsOty        = ' + Str(@unit_idGoodsOty)
--Print '@unit_nameGoodsOty	   = ' + @unit_nameGoodsOty
--Print '@unit_valueGoodsOty     = ' + Str(@unit_valueGoodsOty)
--Print '@Mainunit_valueGoodsOty = ' + Str(@Mainunit_valueGoodsOty)
--Print ''			
		
			set @goods_quantityGoodsOty  = @goods_quantityGoodsOty - (@unit_valueGoodsOty1 * @Mainunit_valueGoodsOty / @unit_valueGoodsOty)

--Print ' @unit_idGoodsOty1    = ' + @unit_idGoodsOty1
--Print ' @unit_nameGoodsOty1  = ' + @unit_nameGoodsOty1
--Print ' @unit_valueGoodsOty1 = ' + str(@unit_valueGoodsOty1)

--Print ' @unit_idGoodsOty2    = ' + @unit_idGoodsOty2
--Print ' @unit_nameGoodsOty2  = ' + @unit_nameGoodsOty2
--Print ' @unit_valueGoodsOty2 = ' + str(@unit_valueGoodsOty2)
--Print ''

			-- Second Unit
			fetch next from cur_units into @unit_idGoodsOty, @unit_nameGoodsOty, @unit_valueGoodsOty, @Mainunit_valueGoodsOty, @CntGoodsQty;

			if (@@fetch_status = 0)
			begin
				set @unit_idGoodsOty2		= @unit_idGoodsOty;
				set @unit_nameGoodsOty2		= @unit_nameGoodsOty;
				
				if @CntGoodsQty > 2 
				Begin
					set @unit_valueGoodsOty2 = floor((@goods_quantityGoodsOty + 0.000000001) * @unit_valueGoodsOty / @Mainunit_valueGoodsOty)
				End
				else	
				Begin
					set @unit_valueGoodsOty2 = @goods_quantityGoodsOty * @unit_valueGoodsOty / @Mainunit_valueGoodsOty
				End
				
				set @goods_quantityGoodsOty  = @goods_quantityGoodsOty - (@unit_valueGoodsOty2 * @Mainunit_valueGoodsOty / @unit_valueGoodsOty)
				
			end;

		end;

		-- close units cursor
		close cur_units;
		deallocate cur_units;

		-- update result
		Update #tbl_result
		Set GoodsName					= IsNull([pub].[funGetGoodsName](G.GoodsID,@LangID),''),
			UnitIDGoodsOty1				= IsNull(@unit_idGoodsOty1,''),
			UnitNameGoodsOty1			= IsNull(@unit_nameGoodsOty1,''),
			TotalQuantityGoodsOty1		= IsNull(@unit_valueGoodsOty1,0),
			UnitIDGoodsOty2				= IsNull(@unit_idGoodsOty2,''),
			UnitNameGoodsOty2			= IsNull(@unit_nameGoodsOty2,''),
			TotalQuantityGoodsOty2		= IsNull(@unit_valueGoodsOty2,0),
			Weight						= IsNull(G.GoodsWeight,0),
			Volume						= IsNull(G.GoodsLength * G.GoodsHeight * G.GoodsWidth,0),
			BarCode						= IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
		From inv.tblGoods G
		INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LangID
		Where G.GoodsID = @goods_id AND #tbl_result.GoodsID = @goods_id And #tbl_result.ProcessID = @process_id And 
			  #tbl_result.ProcessNo = @process_no And #tbl_result.FiscalYear = @fiscal_year And #tbl_result.SerialNo = @serial_no AND 
			  #tbl_result.RowNo = Case When @sal_AggregateSimilarGoodsInRpt = 0 Then @rowNo_no Else 0 End

		-- next
		fetch next from cur_goods into @process_id, @process_no, @fiscal_year, @serial_no, @rowNo_no, @goods_id, @goods_quantityGoodsOty
	end

	-- close goods cursor
	Close cur_goods;
	Deallocate cur_goods;
	-- ******************************************************************************
	-- ********************************** Units End *********************************
	-- ******************************************************************************
	--Select * From #tbl_result

	--============================================						
	SET @StrFrom = ltrim(@SD) + ' D 
			INNER JOIN ' + ltrim(@SH) + ' H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
			Left JOIN inv.tblPreSaleHdr  PS ON PS.ProcessID=D.BaseProcessID AND PS.ProcessNo=D.BaseProcessNo AND PS.FiscalYear=D.BaseFiscalYear AND PS.SerialNo=D.BaseSerialNo
			LEFT JOIN sal.tblTransportersDtl N ON N.TransporterID=H.TransporterID AND N.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN sal.tblSaleTypes O2 ON D.SaleTypeID=O2.SaleTypeID
			LEFT JOIN sal.tblSaleTypesDtl OD ON D.SaleTypeID = OD.SaleTypeID AND OD.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN sal.tblSaleTypesDtl OH ON H.SaleTypeID = OH.SaleTypeID AND OH.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblStoresDtl P ON P.StoreID=H.StoreID AND P.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblStores  SS ON SS.StoreID=H.StoreID 
			LEFT JOIN inv.tblGoodsUserPrice GU ON GU.ID=D.UserPriceID
			LEFT JOIN inv.tblStoreKeepersDtl SK ON SK.StoreKeeperID =SS.StoreKeeperID AND SK.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblGoodsReciverDtl GR on GR.ReciverID=H.GoodsReciverID and GR.LanguageID=' + LTrim(RTrim(@LanguageID)) + '
			OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
			OUTER APPLY acc.funGetCodeInfo(H.VisitorAcntCode) VF
			OUTER APPLY acc.funGetCodeInfo(H.VisitorAcntCode2) VF2
			LEFT JOIN pub.tblLocationsDtl Q ON Q.LocationID=F.LocationID AND Q.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN pub.tblLocations R ON R.LocationID=Q.LocationID 
			LEFT JOIN pub.tblLocationsDtl L2 ON L2.LocationID=H.LocationID AND L2.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			' + @UserSign2 + @UserInvoiceSign2 + '
			LEFT JOIN inv.tblGoods S ON S.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND S.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			LEFT JOIN inv.tblGoods	  G  ON G.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ' 
			LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ' AND GD.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblUnitsDtl T ON T.UnitID=S.UnitID AND T.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblUnitsDtl U ON U.UnitID=D.SubUnitID AND U.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblGoodsStatusDtl SG ON SG.StoreID=H.StoreID  and  S.GoodsID=SG.GoodsID
			LEFT JOIN inv.tblGoodsPlaceDtl GP ON GP.GoodsPlaceID = SG.GoodsPlaceID AND GP.LanguageID=1
			--LEFT JOIN inv.tblSubUnitsDtl V ON V.GoodsID=D.GoodsID AND V.ShowInInvoice = 1
			LEFT JOIN (Select Distinct GoodsID, SubUnitID, isnull(MainUnitValue,1)MainUnitValue, isnull(UnitValue,1)UnitValue, ShowInInvoice 
					   From inv.tblSubUnitsDtl) V ON V.GoodsID = D.GoodsID AND V.ShowInInvoice = 1
			LEFT JOIN inv.tblUnitsDtl W ON W.UnitID=V.SubUnitID AND W.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			left Join sal.tblDistributionsHdr DH  on H.BaseDistributionProcessID= DH.ProcessID  and H.BaseDistributionSerialNo= DH.SerialNo
			left Join sal.tblSaleOrderHdr SH  on H.BaseProcessID= SH.ProcessID   and H.BaseProcessNo= SH.ProcessNo and H.BaseFiscalYear= SH.FiscalYear and H.BaseSerialNo= SH.SerialNo 
			LEFT JOIN pub.tblDrivers DRH ON H.DriverID=DRH.DriverID 
			LEFT JOIN pub.tblDriversDtl DR ON H.DriverID=DR.DriverID AND DR.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN prs.tblPersonnels PRS1 ON H.DistributerID1=PRS1.PersonnelID 
			LEFT JOIN prs.tblPersonnels PRS2 ON H.DistributerID2=PRS2.PersonnelID 
			LEFT JOIN acc.tblSalesRoomClassDtl SRC ON SRC.SalesRoomClassID = F.SalesRoomClass  AND SRC.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN #tbl_result R2 ON R2.GoodsID = D.GoodsID And R2.SerialNo = H.SerialNo AND 
										 R2.RowNo = ' + Case When @sal_AggregateSimilarGoodsInRpt = 0 Then ' D.RowNo' Else '0 ' End +
			Case When @CountCustomerKind > 0 Then '
			LEFT JOIN sal.tbl_CDescription DS ON DS.CustomerKindID = F.CustomerKindID AND DS.GoodsID = D.GoodsID '
			Else '' End
	SET @StrFrom2 = '				
			LEFT  JOIN sal.tblPayOffTypesDtl PT ON H.PayOffTypeID = PT.PayOffTypeID AND PT.LanguageID = ' + LTrim(RTrim(@LanguageID))
		 
	--============================================						
	IF (@Grouped = 0)
	Begin
		SET @StrFields1 = @StrFields1 + '
					IsNull(PS.DocDate ,'''') PSDocDate,H.ProcessID, H.ProcessNo, H.VchDate, H.VchDate DocDate
					,'''+@TaxBranchID+''' TaxBranchID, TaxID,BaseTaxID,H.TPInp ,H.CurrencyValue,F.PersonType,Case when F.PersonType=1 then N''حقیقی'' when F.PersonType=2 then N''حقوقی''	when F.PersonType=3 then N''مشارکت مدنی''	when F.PersonType=4 then N''اتباع غیر ایرانی'' when F.PersonType=5 then N''مصرف کننده نهایی''	end PersonTypeName 
					, Case	when H.TPInp =1 then N''فروش'' when H.TPInp =2 then N''فروش ارزی'' when H.TPInp =3 then N''صورتحساب طلا، جواهر و پلاتین'' when H.TPInp =4 then N''قرارداد پیمانکاری'' when H.TPInp =5 then N''قبوض خدماتی''
							when H.TPInp =6 then N''بلیط هواپیما'' when H.TPInp =7 then N''صادرات''end TPInpName					
					,Case when F.PersonType in (2,3) then case when F.EconomicalCode<>'''' then F.EconomicalCode else F.NationalIdentity end 
							when F.PersonType in (1,4) then case when F.EconomicalCode<>'''' then F.EconomicalCode else F.NationalIDNumber end 
							when F.PersonType in (5) then '''' end PersonTypeCode
					,Case when H.TPEdited =0 then case when D.ProcessID=90 then N''فروش'' else N''برگشت'' end  else N''اصلاحی'' end TPEditedName					
					,H.TPEdited,H.TPEditedDate ,TPContractNo,PayType
					, 0 Cop,0 TaxOverWorthNew
					,  pub.funChangeDate_PersianToGergorian(H.DocDate) As GergorianDocDate,H.CashID,H.KotagNo,H.KotagDate,H.AssessmentLocation,H.PriceParvane,H.ExitLocation,' + Case When @sal_AggregateSimilarGoodsInRpt = 0 Then ' D.Price0' Else '0' End + ' Price0,H.OrderAcntCode,
					[lyl].[GetCustomerInfo](H.OrderAcntCode,' + LTrim(RTrim(@LanguageID)) + ') CustomerInfoName, 
					H.DocDate As DocDate0' + @strStoreID + ',
					D.StoreID StoreID2,''' + @BaseDate + ''' CurrDate,' + @strVirtualQuantity + ',H.TaxOverWorthCost, H.TollOverWorthCost, 
					' + @strTaxOverWorthCostDtl + ', ' + @strTollOverWorthCostDtl + ', D.GoodsID, H.TTMSPayOffTypeID,H.TaxSerialNoInvoice TaxSerialNo,
					TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal([pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LanguageID)) + '))) COLLATE Arabic_CI_AS_KS_WS GoodsName, 
					TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal([pub].[funGetGoodsName](D.GoodsID2,' + LTrim(RTrim(@LanguageID)) + '))) COLLATE Arabic_CI_AS_KS_WS GoodsName2, 
					TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal([pub].[GetGoodsNamePart](D.GoodsID3,2,' + LTrim(RTrim(@LanguageID)) + '))) COLLATE Arabic_CI_AS_KS_WS GoodsName3,
					ISNULL(GU.UserPrice,0) UserPrice,
					IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, H.TransportationCost,H.CurrencyTransportationCost,H.CurrencyTransportationIncome,H.IAToll,H.IATollCod,H.TaxCost,
					D.AcntCode,F.AcntName, [pub].[funGetCustomerKindID] (D.AcntCode) As CustomerKindID, H.PayOffTypeID, PT.PayOffTypeName,
					GoodsID3, ' + @strGoodsPrice3 + ', ' + @strGoodsQuantity3 + ', ' + @strSubUnitQuantity3 + ', SubUnitID3, ' + @strHeight + ', 
					' + @strWidth + ', ' + @strServiceAmount + @strReceiptsFields + ',
					IsNull(inv.funGetUnitName(SubUnitID3,' + LTrim(RTrim(Str(@LanguageID))) + '),'''') As UnitName3N,' + 
					Case When @CountCustomerKind > 0 Then ' IsNull(DS.CDescription, '''')' Else ' D.GoodsID' End + ' As CKDescription, 
					F.EconomicalCode,F.Address1,F.Address2,F.TableauText,' + @DisH1 + ',' + @DisH2 + ',H.DiscountTaxOverWorth,
					pub.funFarsiDateDiff(''Day'',''' + @BaseDate + ''',D.DocDate) DateDuration,IsNull(F.Tel,'''') Tel,' + @strGoodsQuantity + ',
					' + @strGoodsPrice + ',' + @strSubUnitPrice + ',D.AtomAmount OverloadAmount,H.DocDesc,H.DocDesc2,' + @DescDtl + ',H.VisitorAcntCode,
					pub.GetCodeName(H.VisitorAcntCode,' + @LangID + ') VisitorAcntName,H.VisitorAcntCode2, 
					pub.GetCodeName(H.VisitorAcntCode2,' + @LangID + ') VisitorAcntName2, H.VisitorPercent2, H.VisitorCost2, 
					H.VisitorCostAcntCode2,H.AgreeNo,D.SubUnitID,' + @strSubUnitQuantity + ',inv.UQ(D.GoodsID,D.SubUnitID) SubQuantity,
					H.OtherCostAcntCode,H.OtherIncomeAcntCode, cast(''' + @StoreVar1 + ''' as nvarchar(50)) as StoreVar1Text, 
					cast(''' + @StoreVar2 + ''' as nvarchar(50)) as StoreVar2Text,H.OtherCost,H.OtherIncome,D.OtherIncomePerentDtl,D.OtherIncomeDtl,H.TransportationIncome,
					H.TransportationIncomeAcntCode,Case When D.SaleTypeID <> '''' Then D.SaleTypeID Else H.SaleTypeID End As SaleTypeID,
					OD.SaleTypeName SaleTypeNameDtl, OH.SaleTypeName SaleTypeName,' + @db_0000 + '.[pub].[funUserName](' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo)) User_Name,
					pub.funGetLocationName(F.LocationID,1) LocationName,R.AreaCode, H.CCNo, H.CCDiscount, H.CCPrivilege,
					Case When H.CCNo = '''' Or H.CCNo Is Null Then 0 Else 
					(Select [lyl].[funCustomerDefaultPrivilege] (H.CCNo, H.DocDate)) + 
							(Select IsNull(Sum(CCPrivilege),0) From inv.tblStorageDocsHdr Where CCNo = H.CCNo And ProcessID = 90) - 
					(Select IsNull(Sum(CCPrivilege),0) From inv.tblStorageDocsHdr Where CCNo = H.CCNo And ProcessID = 100) End As SumCCPrivilege,'
					SET @StrFields2 = @StrFields2 + '												
					F.ZipCode,case when isnull(GR.StoreZipCode , '''') ='''' then  isnull(F.StoreZipCode , '''')  else isnull(GR.StoreZipCode , '''')  end ZipCode2,F.CustomerFirstName+'' ''+F.CustomerLastName CustomerName,F.CompanyRegisterNo,F.NationalIDNumber,H.PackingCost,H.OtherIncome+H.PackingCost+H.TaxCost TaxOverAfterIncomeInSalePrice,
					F.SalesRoomClass,IsNull(SRC.SalesRoomClassName,'''') SalesRoomClassName,F.OrganzationName,H.DiscountPercent,H.DiscountPercent2,H.VchNo,H.EarnestMoney,F.AccExtraField1,F.AccExtraField2,F.AccExtraField3,F.AccExtraField4,F.AccExtraField5,F.AccExtraField6,
					H.ExtraField1 ExtraField1Sale,S.GoodsCID,S.ExtraField1,S.ExtraField2,S.ExtraField3,S.ExtraField4,S.ExtraField5,
					S.TechnicalSpecifications,H.TransporterID,N.TransporterName, SK.StoreKeeperName,SS.Tel StoreTel,P.StoreName,P.Address StoreAddress,pub.UN(H.SessionNo) UserName,pub.UN(H.SessionNo) UserName1,
					pub.UN(H.SessionNo2) UserName2,pub.UN(H.SessionNo3) UserName3,pub.UN(H.SessionNo4) UserName4,pub.UN(H.SessionNo5) UserName5,
					H.DocStep,H.Amount,H.Price,F.Mobile, F.SMSMobile, T.UnitName,W.UnitName UnitName2,U.UnitName UnitName3,W.UnitName UnitNameX,' + @DisH3 + ',isnull(V.UnitValue,1) UnitValue,isnull(V.MainUnitValue,1)MainUnitValue,case when (V.MainUnitValue<>0) then V.UnitValue/V.MainUnitValue else 1 end UnitScale,
					case when H.DestinationAddress <> '''' THEN H.DestinationAddress ELSE H.Address END DestinationAddress,F.Sequence,' + @BaseProcessID + ',' + @BaseProcessNo + ',' + @BaseFiscalYear + ',' + @BaseSerialNo + ',isnull(O2.DaysNo,0) DaysNo, 
					' + @StoreVariable1 + ', ' + @StoreVariable2 + ',	H.BaseDistributionFiscalYear,H.BaseDistributionSerialNo,S.TechnicalNo,
					' + @DisD1 + ',' + @DiscountDtl + ' DiscountDtl2,S.GoodsLength,S.GoodsWidth,S.GoodsHeight,S.GoodsWeight,S.PureWeight GoodsPureWeight,' + @DisH4 + ',' + @DisH5 + ',H.OwnerDocNo,
					' + @BatchField + ',L2.LocationName LocationName2,' + @strDiscountPercentDtl + ',' + @strVisitorPercent + ',inv.UQ2(D.GoodsID,D.SubUnitID) SQ2,H.CashAmount,H.ChequeAmount,H.ComssionCostPrice,H.BasculePrice,H.LaborPrice,H.TransportPrice,
					IsNull((Select Sum(Amount) From trs.tblPayDtl Where ProcessID = 13 And DebitCode = D.AcntCode
							Group By ProcessID, DebitCode),0) As SumReceivableReturn,
					IsNull((Select Top 1 SS.ProductSerialID From inv.tblStorageDocsSerials SS 
					Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
						  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
						  SS.DocRowNo = ' + @DocRowNo + '),0) As ProductSerialID,
					IsNull((Select Top 1 SS.BatchNo From inv.tblStorageDocsSerials SS 
					Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
						  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
						  SS.DocRowNo = ' + @DocRowNo + '),'''') As PrdBatchNo,
					IsNull((Select Top 1 SS.ExpireDate From inv.tblStorageDocsSerials SS 
					Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
						  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
						  SS.DocRowNo = ' + @DocRowNo + '),'''') As PrdExpireDate,	
					Cast(' + @SettleStr + ' as bit) IsSettle,' + str(@svcCount) + ' SvcCount,
					H.TransporterID2,VF.Tel VisitorTel,VF2.Tel VisitorTel2, VF.Mobile VisitorMobile, VF2.Mobile VisitorMobile2,
					cast(' + str(@fval) + ' as float) VATPercent,
					Cast(' + Str(@IATollPercent) + ' As Float) IATollPercent,
					F.AsnafID, F.CustomerKindID CustomerKindID1, [sal].[funGetCustomerKindName](F.CustomerKindID,' + @LangID + ') CustomerKindName1, F.SaleCash,' + @CurrencyAmount + ',F.OtherTels,F.Email,F.NationalIdentity,' + @UserSign1 + @UserInvoiceSign1
					SET @StrFields3 = @StrFields3 + '												
					F.Fax, Case When IsNumeric(ConstText1) = 0 OR ConstText1 = ''0'' OR ConstText1 = '''' Then ''0'' Else ConstText1 End As ConstText1,
					' + @ConstText2 + ',' + @ConstText3 + ',' + @ConstText4 + ', H.C1, H.C2, H.C3, H.C4, H.C5, H.C6, H.C7, H.C8, H.C9, H.C10, H.C11, H.C12, H.CurrencyTypeID,
					pub.funGetCurrencyTypesName(H.CurrencyTypeID,' + @LangID + ') CurrencyTypesName , H.CurrencyRate,
					' + @Var1 + ','+ @Var2 + ','+ @Var3 + ','+ @Var4 + ', DR.DriverID, (DR.FirstName +' + '''-''' + '+ DR.LastName) As DriverName, DRH.DriverTel, DRH.DriverMobile,DRH.NationalNumber DriverNationalNumber,DRH.VehicleNo,
					H.DistributerID1, prs.funGetPersonnelName(H.DistributerID1,' + @LangID + ') DistributerName1, PRS1.Tel DistributerTel1, PRS1.Mobile DistributerMobile1,
					H.DistributerID2, prs.funGetPersonnelName(H.DistributerID2,' + @LangID + ') DistributerName2, PRS2.Tel DistributerTel2, PRS2.Mobile DistributerMobile2,
					ROUND(IsNull(' + @strTotalQuantityGoodsOty + ',0), ' + LTrim(RTrim(Str(@QuantityDecimals))) + ') RTotalQuantityGoodsOty, IsNull(R2.UnitIDGoodsOty1,'''') RUnitIDGoodsOty1, 
					IsNull(R2.UnitNameGoodsOty1,'''') RUnitNameGoodsOty1, ROUND(IsNull(' + @strTotalQuantityGoodsOty1 + ',0), ' + LTrim(RTrim(Str(@QuantityDecimals))) + ') RTotalQuantityGoodsOty1, 
					IsNull(R2.UnitIDGoodsOty2,'''') RUnitIDGoodsOty2, IsNull(R2.UnitNameGoodsOty2,'''') RUnitNameGoodsOty2, 
					ROUND(IsNull(' + @strTotalQuantityGoodsOty2 + ',0), ' + LTrim(RTrim(Str(@QuantityDecimals))) + ') RTotalQuantityGoodsOty2,	
					IsNull(R2.Weight,0) RWeight, IsNull(R2.Volume,0) RVolume, G.HasSerial,
					IsNull(R2.BarCode,'''') RBarCode, D.IsReward,H.AfterSaleDesc,[pub].[funChangeDate_PersianToGergorian](H.DocDate) LatinDate,GBarCode ,isnull(GP.GoodsPlaceID,'''') GoodsPlaceID,isnull(GP.GoodsPlaceName,'''') GoodsPlaceName,H.OrderAcntCode CustomerInfoID'
	End
	ELSE
	Begin
		SET @StrFields1 = @StrFields1 + '
					IsNull(PS.DocDate ,'''') PSDocDate, H.ProcessID, H.ProcessNo, H.VchDate, H.VchDate AS DocDate
					,'''+@TaxBranchID+''' TaxBranchID,TaxID,BaseTaxID,H.TPInp 	,H.CurrencyValue,F.PersonType,Case when F.PersonType=1 then N''حقیقی'' when F.PersonType=2 then N''حقوقی''	when F.PersonType=3 then N''مشارکت مدنی''	when F.PersonType=4 then N''اتباع غیر ایرانی'' when F.PersonType=5 then N''مصرف کننده نهایی''	end PersonTypeName 
					, Case	when H.TPInp =1 then N''فروش'' when H.TPInp =2 then N''فروش ارزی'' when H.TPInp =3 then N''صورتحساب طلا، جواهر و پلاتین'' when H.TPInp =4 then N''قرارداد پیمانکاری'' when H.TPInp =5 then N''قبوض خدماتی''
							when H.TPInp =6 then N''بلیط هواپیما'' when H.TPInp =7 then N''صادرات''end TPInpName					
					,Case when F.PersonType in (2,3) then case when F.EconomicalCode<>'''' then F.EconomicalCode else F.NationalIdentity end 
							when F.PersonType in (1,4) then case when F.EconomicalCode<>'''' then F.EconomicalCode else F.NationalIDNumber end 
							when F.PersonType in (5) then '''' end PersonTypeCode
					,Case when H.TPEdited  =0 then case when D.ProcessID=90 then N''فروش'' else N''برگشت'' end  else N''اصلاحی'' end TPEditedName					
					,H.TPEdited ,H.TPEditedDate,TPContractNo,PayType
					, CASE	WHEN  PayType=1 THEN  CAST(FLOOR(((D.GoodsPrice*SubUnitQuantity)-FLOOR(DiscountDtl)) +FLOOR(TaxOverWorthCostDtl+TollOverWorthCostDtl ))  AS DECIMAL)
						WHEN PayType=2 THEN 0
						END Cop,CAST (FLOOR(D.TaxOverWorthCostDtl+D.TollOverWorthCostDtl) AS DECIMAL )AS TaxOverWorthNew,  pub.funChangeDate_PersianToGergorian(H.DocDate) As GergorianDocDate,H.CashID,H.KotagNo,H.KotagDate,H.AssessmentLocation,H.PriceParvane,H.ExitLocation,0 Price0,H.OrderAcntCode,
					[lyl].[GetCustomerInfo](H.OrderAcntCode,' + LTrim(RTrim(@LanguageID)) + ') CustomerInfoName, 
					H.DocDate as DocDate0' + @strStoreID + ',
					D.StoreID StoreID2,''' + @BaseDate + ''' CurrDate, ' + @strVirtualQuantity + ',H.TaxOverWorthCost, H.TollOverWorthCost, ' + 
					@strTaxOverWorthCostDtl + ', ' + @strTollOverWorthCostDtl + ', D.GoodsID, H.TTMSPayOffTypeID, H.TaxSerialNoInvoice TaxSerialNo,
					TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal([pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LanguageID)) + '))) COLLATE Arabic_CI_AS_KS_WS GoodsName,
					TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal([pub].[funGetGoodsName](D.GoodsID2,' + LTrim(RTrim(@LanguageID)) + '))) COLLATE Arabic_CI_AS_KS_WS GoodsName2, 
					TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal([pub].[funGetGoodsName](D.GoodsID3,' + LTrim(RTrim(@LanguageID)) + '))) COLLATE Arabic_CI_AS_KS_WS GoodsName3, 
					GU.UserPrice,				
					IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, H.PayOffTypeID, PT.PayOffTypeName,
					H.TransportationCost,H.CurrencyTransportationCost,H.CurrencyTransportationIncome,H.IAToll,H.IATollCod, H.TaxCost,D.AcntCode,F.AcntName, [pub].[funGetCustomerKindID] (D.AcntCode) As CustomerKindID,
					GoodsID3,  ' + @strGoodsPrice3 + ', ' + @strGoodsQuantity3 + ', ' + @strSubUnitQuantity3 + ', SubUnitID3, ' + @strHeight + ', 
					' + @strWidth + ', ' + @strServiceAmount + @strReceiptsFields + ',
					IsNull(inv.funGetUnitName(SubUnitID3,' + LTrim(RTrim(Str(@LanguageID))) + '),'''') As UnitName3N,' +
					Case When @CountCustomerKind > 0 Then ' IsNull(DS.CDescription, '''')' Else ' D.GoodsID' End + ' As CKDescription, 
					F.EconomicalCode,'''' Address1, '''' Address2,F.TableauText,' + @DisH1 + ',' + @DisH2 + ',H.DiscountTaxOverWorth,
					pub.funFarsiDateDiff(''Day'',''' + @BaseDate + ''',D.DocDate) DateDuration,IsNull(F.Tel,'''') Tel,' + @strGoodsQuantity + ',
					' + @strGoodsPrice + ',' + @strSubUnitPrice + ',D.AtomAmount OverloadAmount,H.DocDesc,H.DocDesc2,'''' DescDtl,H.VisitorAcntCode,pub.GetCodeName(H.VisitorAcntCode,' + @LangID + ') VisitorAcntName,
					H.VisitorAcntCode2, pub.GetCodeName(H.VisitorAcntCode2,' + @LangID + ') VisitorAcntName2, H.VisitorPercent2, H.VisitorCost2, H.VisitorCostAcntCode2,
					H.AgreeNo,D.SubUnitID,0 SubUnitQuantity,inv.UQ(D.GoodsID,D.SubUnitID) SubQuantity,H.OtherCostAcntCode,H.OtherIncomeAcntCode, ''' + @StoreVar1 + ''' as StoreVar1Text, ''' + @StoreVar2 + ''' as StoreVar2Text,
					H.OtherCost,H.OtherIncome,D.OtherIncomePerentDtl,D.OtherIncomeDtl,H.TransportationIncome,H.TransportationIncomeAcntCode, H.CCNo, H.CCDiscount, H.CCPrivilege,
					Case When H.CCNo = '''' Or H.CCNo Is Null Then 0 Else 
					(Select [lyl].[funCustomerDefaultPrivilege] (H.CCNo, H.DocDate)) + 
							(Select IsNull(Sum(CCPrivilege),0) From inv.tblStorageDocsHdr Where CCNo = H.CCNo And ProcessID = 90) - 
					(Select IsNull(Sum(CCPrivilege),0) From inv.tblStorageDocsHdr Where CCNo = H.CCNo And ProcessID = 100) End As SumCCPrivilege,
					Case When D.SaleTypeID <> '''' Then D.SaleTypeID Else H.SaleTypeID End As SaleTypeID,
					OD.SaleTypeName SaleTypeNameDtl, OH.SaleTypeName SaleTypeName, '''' LocationName, '''' AreaCode,'
					SET @StrFields2 = @StrFields2 + '				
					F.ZipCode,case when isnull(GR.StoreZipCode , '''') ='''' then  isnull(F.StoreZipCode , '''')  else isnull(GR.StoreZipCode , '''')  end ZipCode2,F.CustomerFirstName+'' ''+F.CustomerLastName CustomerName,F.CompanyRegisterNo,F.NationalIDNumber,H.PackingCost,H.OtherIncome+H.PackingCost+H.TaxCost TaxOverAfterIncomeInSalePrice,
					F.SalesRoomClass,IsNull(SRC.SalesRoomClassName,'''') SalesRoomClassName,F.OrganzationName,H.DiscountPercent,H.DiscountPercent2,H.VchNo,H.EarnestMoney,F.AccExtraField1,F.AccExtraField2,F.AccExtraField3,F.AccExtraField4,F.AccExtraField5,F.AccExtraField6,
					H.ExtraField1 ExtraField1Sale,S.GoodsCID,S.ExtraField1,S.ExtraField2,S.ExtraField3,S.ExtraField4,
					S.ExtraField5,S.TechnicalSpecifications,H.TransporterID,N.TransporterName, SK.StoreKeeperName,SS.Tel StoreTel,P.StoreName,P.Address StoreAddress,pub.UN(H.SessionNo) UserName,
					pub.UN(H.SessionNo) UserName1,pub.UN(H.SessionNo2) UserName2,pub.UN(H.SessionNo3) UserName3,pub.UN(H.SessionNo4) UserName4,
					pub.UN(H.SessionNo5) UserName5,H.DocStep,H.Amount,H.Price,F.Mobile, F.SMSMobile, T.UnitName,W.UnitName UnitName2,U.UnitName UnitName3,
					W.UnitName UnitNameX,' + @DisH3 + ',isnull(V.UnitValue,1)UnitValue,isnull(V.MainUnitValue,1)MainUnitValue,case when(V.MainUnitValue<>0)then V.UnitValue/V.MainUnitValue else 1 end UnitScale,
					case when H.DestinationAddress <>'''' THEN H.DestinationAddress ELSE H.Address END DestinationAddress,F.Sequence,
					' + @BaseProcessID + ',' + @BaseProcessNo + ',' + @BaseFiscalYear + ',' + @BaseSerialNo + ',isnull(O2.DaysNo,0) DaysNo, ' + @StoreVariable1 + ', ' + @StoreVariable2 + ',
					H.BaseDistributionFiscalYear,H.BaseDistributionSerialNo,S.TechnicalNo,' + @DisD1 + ',' + @DiscountDtl + ' DiscountDtl2,S.GoodsLength,S.GoodsWidth,S.GoodsHeight,S.GoodsWeight,S.PureWeight GoodsPureWeight,' + @DisH4 + ',' + @DisH5 + ',H.OwnerDocNo,
					' + @BatchField + ',L2.LocationName LocationName2,' + @strDiscountPercentDtl + ',' + @strVisitorPercent + ',0 SQ2,H.CashAmount,H.ChequeAmount,H.ComssionCostPrice,
					H.BasculePrice,H.LaborPrice,H.TransportPrice,'''' User_Name,
					IsNull((Select Sum(Amount) From trs.tblPayDtl Where ProcessID = 13 And DebitCode = D.AcntCode 
							Group By ProcessID, DebitCode),0) As SumReceivableReturn,
					IsNull((Select Top 1 SS.ProductSerialID From inv.tblStorageDocsSerials SS Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
							SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
							SS.DocRowNo = ' + @DocRowNo + '),0) As ProductSerialID,
					IsNull((Select Top 1 SS.BatchNo From inv.tblStorageDocsSerials SS 
					Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
						  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
						  SS.DocRowNo = ' + @DocRowNo + '),'''') As PrdBatchNo,
					IsNull((Select Top 1 SS.ExpireDate From inv.tblStorageDocsSerials SS 
					Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
						  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
						  SS.DocRowNo = ' + @DocRowNo + '),'''') As PrdExpireDate,
					Cast(' + @SettleStr + ' as bit) IsSettle,' + str(@svcCount) + ' SvcCount,
					H.TransporterID2,VF.Tel VisitorTel,cast(' + str(@fval) + ' as float) VATPercent,
					Cast(' + Str(@IATollPercent) + ' As Float) IATollPercent,
					F.AsnafID, F.CustomerKindID CustomerKindID1, [sal].[funGetCustomerKindName](F.CustomerKindID,' + @LangID + ') CustomerKindName1, F.SaleCash,' + @CurrencyAmount + ',F.OtherTels,F.Email,F.NationalIdentity,' + @UserSign1 + @UserInvoiceSign1
					SET @StrFields3 = @StrFields3 + '
					F.Fax, D.ConstText1,' + @ConstText2 + ',' + @ConstText3 + ',' + @ConstText4 + ',H.C1,H.C2,H.C3,H.C4,H.C5,H.C6,H.C7, H.C8, H.C9, H.C10, H.C11, H.C12,H.CurrencyTypeID,pub.funGetCurrencyTypesName(H.CurrencyTypeID,' + @LangID + ') CurrencyTypesName , H.CurrencyRate,
					' + @Var1 + ','+ @Var2 + ','+ @Var3 + ','+ @Var4 + ', DR.DriverID, (DR.FirstName +' + '''-''' + '+ DR.LastName) As DriverName, DRH.DriverTel, DRH.DriverMobile,DRH.NationalNumber DriverNationalNumber,DRH.VehicleNo,
					H.DistributerID1, prs.funGetPersonnelName(H.DistributerID1,' + @LangID + ') DistributerName1, PRS1.Tel DistributerTel1, PRS1.Mobile DistributerMobile1,
					H.DistributerID2, prs.funGetPersonnelName(H.DistributerID2,' + @LangID + ') DistributerName2, PRS2.Tel DistributerTel2, PRS2.Mobile DistributerMobile2,
					ROUND(IsNull(' + @strTotalQuantityGoodsOty + ',0), ' + LTrim(RTrim(Str(@QuantityDecimals))) + ') RTotalQuantityGoodsOty, IsNull(R2.UnitIDGoodsOty1,'''') RUnitIDGoodsOty1, 
					IsNull(R2.UnitNameGoodsOty1,'''') RUnitNameGoodsOty1, ROUND(IsNull(' + @strTotalQuantityGoodsOty1 + ',0), ' + LTrim(RTrim(Str(@QuantityDecimals))) + ') RTotalQuantityGoodsOty1, 
					IsNull(R2.UnitIDGoodsOty2,'''') RUnitIDGoodsOty2, IsNull(R2.UnitNameGoodsOty2,'''') RUnitNameGoodsOty2, 
					ROUND(IsNull(' + @strTotalQuantityGoodsOty2 + ',0), ' + LTrim(RTrim(Str(@QuantityDecimals))) + ') RTotalQuantityGoodsOty2,	
					IsNull(R2.Weight,0) RWeight, IsNull(R2.Volume,0) RVolume,G.HasSerial, 
					IsNull(R2.BarCode,'''') RBarCode, D.IsReward,H.AfterSaleDesc,[pub].[funChangeDate_PersianToGergorian](H.DocDate) LatinDate,GBarCode,isnull(GP.GoodsPlaceID,'''') GoodsPlaceID,isnull(GP.GoodsPlaceName,'''') GoodsPlaceName,H.OrderAcntCode CustomerInfoID'
	End
	
	If (@ShowRemain = 1)
	Begin
		declare @CountPartRemain tinyint
		SET @CountPartRemain=0;
	
		SET @Eqal = '1=1'
		SET @EqalRet = '1=1'

		IF (@Remain1 = 1)
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@Remain2 = 1) AND @CountPartRemain = 1
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@Remain3 = 1) AND @CountPartRemain = 2
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@Remain4 = 1) AND @CountPartRemain = 3
			SET @CountPartRemain = @CountPartRemain + 1

		IF (select COUNT(*) from pub.tblCodeLayer where TableName='acc.tblAcnt' and Layer1>0) = @CountPartRemain
			BEGIN
					SET @Eqal = @Eqal + ' AND M.AcntCode=H.AcntCode'
					SET @EqalRet = @EqalRet + ' AND M.AcntCode=H.RecDebAcntCodeRet'
			END
			ELSE
			BEGIN
				IF (@Remain1 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')'
				IF (@Remain2 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')'
				IF (@Remain3 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')'
				IF (@Remain4 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')'
										
				IF (@Remain1 = 1)
					SET @EqalRet = @EqalRet + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')=Substring(H.RecDebAcntCodeRet,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')'
				IF (@Remain2 = 1)
					SET @EqalRet = @EqalRet + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')=Substring(H.RecDebAcntCodeRet,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')'
				IF (@Remain3 = 1)
					SET @EqalRet = @EqalRet + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')=Substring(H.RecDebAcntCodeRet,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')'
				IF (@Remain4 = 1)
					SET @EqalRet = @EqalRet + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')=Substring(H.RecDebAcntCodeRet,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')'
					
			END
----  برای نمایش مانده حساب ارزی بر اساس ارز
		Declare @SumDebitCredit as varchar(100)=' IsNull(Sum(Debit - Credit),0) Debit  '
		Declare @WhereCurrency  as varchar(100)='    '
		Declare @GroupbyCurrency  as varchar(100)='    '
		if @IsCurrency=1 
		begin
			set  @SumDebitCredit='  IsNull(Sum( case when Debit>0 then  CurrencyAmount else CurrencyAmount  *-1 end ),0) Debit    ' 
			set  @WhereCurrency='  M.CurrencyTypeID=H.CurrencyTypeID and'
			set  @GroupbyCurrency='  H.CurrencyTypeID , '
		end 
		IF (@CalcSalesInRemain = 0)
			Begin
				SET @StrFields3 = @StrFields3 + ', Cast(0 AS Decimal(28,'+str(@PriceDecimals)+')) DebitRemain, Cast(0 AS Decimal(28,'+str(@PriceDecimals)+')) DebitRemain2, Cast(0 AS Decimal) RecDebAcntCodeRetRemain '
				SET @StrFields4 = @StrFields4 + '
						 SELECT	 '+  @SumDebitCredit  +'-- IsNull(Sum(Debit - Credit),0) Debit 
						 FROM	acc.tblVoucherDtl M 
						 INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
						 INNER join acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(M.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode) = ' + LTrim(RTrim(STR(@Part1End))) + '
						 WHERE  '+ @WhereCurrency +' b.AcntType NOT IN (91, 92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0 AND (' + @Eqal + ') AND 
							   (M.DocDate <= H.VchDate 
							   AND Not (
										M.DocDate = H.VchDate AND 
										M.SourceProcessID  IN(90, 95) AND 
										M.SourceProcessNo  = H.ProcessNo AND 
										M.SourceFiscalYear = H.FY AND 
										M.SourceSerialNo   >= H.SN
									    )
						)'		
				SET @StrFields5 = @StrFields5 + '
						 SELECT	 '+  @SumDebitCredit  +'-- IsNull(Sum(Debit - Credit),0) Debit 
						 FROM	acc.tblVoucherDtl M 
						 INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
						 INNER join acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(M.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode) = ' + LTrim(RTrim(STR(@Part1End))) + '
						 WHERE  '+ @WhereCurrency +' b.AcntType NOT IN (91, 92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0 AND (' + @EqalRet + ') AND 
							   (M.DocDate <= H.VchDate 
							   AND Not (
										M.DocDate = H.VchDate AND 
										M.SourceProcessID  IN(90, 95) AND 
										M.SourceProcessNo  = H.ProcessNo AND 
										M.SourceFiscalYear = H.FY AND 
										M.SourceSerialNo   >= H.SN
									    )
						)'							
				--SET @StrFields4 = @StrFields4 + '
				--(SELECT	IsNull(Sum(Debit - Credit),0) Debit 
				-- FROM	acc.tblVoucherDtl M 
				-- INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
				-- INNER join acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(M.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode) = ' + LTrim(RTrim(STR(@Part1End))) + '
				-- WHERE  b.AcntType NOT IN (91,92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0 AND (' + @Eqal + ') AND 
				--	   (M.DocDate <= H.VchDate AND
				--		Not (M.DocDate = H.VchDate AND 
				--			 M.SourceProcessID  IN(90,95) AND 
				--			 M.SourceProcessNo  = H.ProcessNo AND 
				--			 M.SourceFiscalYear = H.FiscalYear AND 
				--			 M.SourceSerialNo   = H.SerialNo
				--			)
				--		)
				--) DebitRemain '
				
			End
		Else
			Begin
				SET @StrFields3 = @StrFields3 + ', Cast(0 AS Decimal(28,'+str(@PriceDecimals)+')) DebitRemain, Cast(0 AS Decimal(28,'+str(@PriceDecimals)+')) DebitRemain2 , Cast(0 AS Decimal) RecDebAcntCodeRetRemain'
				SET @StrFields4 = @StrFields4 + '
						 SELECT	'+  @SumDebitCredit  +'-- IsNull(Sum(Debit - Credit),0) Debit 
						 FROM	acc.tblVoucherDtl M 
						 INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
						 INNER JOIN acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(M.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode) = ' + LTrim(RTrim(STR(@Part1End))) + '
						 WHERE   '+ @WhereCurrency +' b.AcntType NOT IN (91,92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0 AND (' + @Eqal + ') AND 
							   (M.DocDate <= H.VchDate --AND
							 --   Not 
							 --  (M.DocDate = H.VchDate AND 
							 --   M.SourceProcessID    IN(90,95) --AND
								----M.SourceProcessNo  = H.ProcessNo AND 
								----M.SourceFiscalYear = H.FiscalYear AND
								----M.SourceSerialNo	 = H.SerialNo
								--)
						)'
						SET @StrFields5 = @StrFields5 + '
						 SELECT	'+  @SumDebitCredit  +'-- IsNull(Sum(Debit - Credit),0) Debit 
						 FROM	acc.tblVoucherDtl M 
						 INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
						 INNER JOIN acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(M.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode) = ' + LTrim(RTrim(STR(@Part1End))) + '
						 WHERE   '+ @WhereCurrency +' b.AcntType NOT IN (91,92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0 AND (' + @EqalRet + ') AND 
							   (M.DocDate <= H.VchDate --AND
							 --   Not 
							 --  (M.DocDate = H.VchDate AND 
							 --   M.SourceProcessID    IN(90,95) --AND
								----M.SourceProcessNo  = H.ProcessNo AND 
								----M.SourceFiscalYear = H.FiscalYear AND
								----M.SourceSerialNo	 = H.SerialNo
								--)
						)'					
				--SET @StrFields4 = @StrFields4 + ',
				--(SELECT	IsNull(Sum(Debit - Credit), 0) Debit 
				-- FROM	acc.tblVoucherDtl M 
				-- INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
				-- INNER JOIN acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(M.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode) = ' + LTrim(RTrim(STR(@Part1End))) + '
				-- WHERE  b.AcntType NOT IN (91,92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0 AND (' + @Eqal + ') AND 
				--	   (M.DocDate <= H.VchDate --AND
				--	 --   Not 
				--	 --  (M.DocDate = H.VchDate AND 
				--	 --   M.SourceProcessID    IN(90,95) --AND
				--		----M.SourceProcessNo  = H.ProcessNo AND 
				--		----M.SourceFiscalYear = H.FiscalYear AND
				--		----M.SourceSerialNo	 = H.SerialNo
				--		--)
				--		)
				--) DebitRemain '	
				
			End
	End
	Else
	Begin
		SET @StrFields3 = @StrFields3 + ', Cast(0 AS Decimal(28,'+str(@PriceDecimals)+')) DebitRemain, Cast(0 AS Decimal(28,'+str(@PriceDecimals)+')) DebitRemain2 , Cast(0 AS Decimal) RecDebAcntCodeRetRemain'
		SET @StrFields4 = @StrFields4 + '0'
		SET @StrFields5 = @StrFields5 + '0'
	End
	
		If (@ShowRemainAndDay=1 )
			SET @StrFields3 = @StrFields3 + ',Convert(varchar(20), sal.funGetRemainSal_InvoicesDate(H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo)) as DayRemain, 
											  sal.funGetRemainSal_InvoicesRemain(H.ProcessID ,H.ProcessNo ,H.FiscalYear ,H.SerialNo) As PayRemain'
		ELSE
			SET @StrFields3 = @StrFields3 + ',Convert(varchar(10),'''') as DayRemain ,0 as PayRemain'
		
			SET @StrFields3 = @StrFields3 + ',H.SettlementDate,'''+@CurrentUser+''' CurrentUser,DistributDate,SH.DocDate OrderDocDate,GoodsPriceWithTax,PurePrice,DistributionPercent,DistributionPrice
				,cast(Substring(H.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')  as varchar(20) ) AcntCode1
				,cast(Substring(H.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') as varchar(20) ) AcntCode2
				,cast(Substring(H.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') as varchar(20) ) AcntCode3
				,cast(Substring(H.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') as varchar(20) ) AcntCode4
				,cast(acc.funGetAcntName(	Substring(H.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ') ,	1,	' + LTrim(RTrim(@LanguageID)) + ' ) as nvarchar(50) )AcntCodeName1
				,cast(acc.funGetAcntName(	Substring(H.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') ,	2,	' + LTrim(RTrim(@LanguageID)) + ' ) as nvarchar(50) )AcntCodeName2
				,cast(acc.funGetAcntName(	Substring(H.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') ,	3,	' + LTrim(RTrim(@LanguageID)) + ' ) as nvarchar(50) )AcntCodeName3
				,cast(acc.funGetAcntName(	Substring(H.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') ,	4,	' + LTrim(RTrim(@LanguageID)) + ' ) as nvarchar(50) )AcntCodeName4
				'
	-------------------------------------------------------------------------------------------
	IF (@Grouped = 1)
	BEGIN
		
		SET @StrSelectA = N'
		--================================ Begin
		BEGIN TRY
			DROP TABLE ##tblAll
			DROP TABLE ##tblGroups
		END TRY
		BEGIN CATCH
		END CATCH
		
		SELECT IsNull((Select top 1 Sequence 
					   From sal.tblDistributionsDtl D 
					   Where  D.BaseSaleProcessID = H.ProcessID And D.BaseSaleProcessNo = H.ProcessNo And 
							  D.BaseSaleFiscalYear = H.FiscalYear And D.BaseSaleSerialNo = H.SerialNo ),0) as DSequence,
							  D.FiscalYear FY,D.SerialNo SN,' + @DocRowNo + ' RN,' + @StrFields1 
		
		SET @StrSelectB = @StrFields2
		
		SET @StrSelectC = @StrFields3 + ', H.AcntCode  RecDebAcntCodeRet
			INTO	##tblAll
			FROM	' + @StrFrom

		SET @StrSelectD = @StrFrom2 + '
		WHERE	' + @StrWhere + '
		CREATE TABLE ##tblGroups
		(
			GD_ID	VarChar(20) collate arabic_cs_as not null,
			GR_ID	VarChar(20) collate arabic_cs_as not null,
			GR_Name NVarChar(50) collate arabic_cs_as not null
		)
		INSERT INTO ##tblGroups
		SELECT	GD.GoodsID,G.GoodsGroupID,G.GoodsGroupName
		FROM	inv.tblGoodsGroupsDtl G
		INNER JOIN inv.tblGoodsGroupsGoodsListDtl GD ON G.GoodsGroupID=GD.GoodsGroupID 
		--================================ End'

		Print @StrSelectA;
		Print @StrSelectB;
		Print @StrSelectC;
		Print @StrSelectD;

		SET @StrSelectA = @StrSelectA + @StrSelectB + @StrSelectC + @StrSelectD
		--Print @StrSelectA;
		EXEC sp_executesql @StrSelectA;
		
		set @GroupbyCurrency=isnull(@GroupbyCurrency,'')

		SET @StrSelectA = N'
		UPDATE	##tblAll 
		SET		RN=0,GoodsID=
				(
					SELECT TOP 1 G.GR_ID 
					FROM ##tblGroups G
					WHERE G.GD_ID=GoodsID
					ORDER BY G.GR_ID
				),GoodsName=
				(
					SELECT	TOP 1 G.GR_Name 
					FROM	##tblGroups G
					WHERE G.GD_ID=GoodsID
					ORDER BY G.GR_ID 
				)
		WHERE	(
					SELECT	TOP 1 G.GR_ID 
					FROM	##tblGroups G
					WHERE G.GD_ID=GoodsID
					ORDER BY G.GR_ID 
				) IS NOT NULL

		SELECT *
		INTO #tblTemp
		FROM ##tblAll 

		UPDATE	##tblAll 
		SET		GoodsQuantity=T.GoodsQuantity
		FROM	##tblAll A INNER JOIN 
				(
					SELECT	FY,SN,GoodsID,GoodsPrice,Sum(GoodsQuantity) GoodsQuantity
					FROM	#tblTemp 
					GROUP BY FY,SN,GoodsID,GoodsPrice
					HAVING	COUNT(GoodsID)>=1
				) T ON  A.FY=T.FY AND A.SN=T.SN AND A.GoodsID=T.GoodsID AND A.GoodsPrice=T.GoodsPrice 

		-- dont remove DISTINCT keyword & extra fields   

		-- =========================================
		 UPDATE ##tblAll SET DebitRemain = B.DebitRemain, DebitRemain2 = B.DebitRemain 
		 FROM ##tblAll A
		 INNER JOIN 
		 (
			Select ProcessID, ProcessNo,FY FiscalYear, SN SerialNo, AcntCode,
				   (' + @StrFields4 + ') DebitRemain 
			From ##tblAll H
			Group By AcntCode, FY,SN, '+ @GroupbyCurrency +' H.VchDate' + Case When @CalcSalesInRemain = 0 Then ', ProcessID, ProcessNo, FY, SN ' Else '' End + '
		 ) B ON A.ProcessID = B.ProcessID AND A.ProcessNo = B.ProcessNo AND 
				A.FY = B.FiscalYear AND A.SN= B.SerialNo AND 
				A.AcntCode = B.AcntCode
		
		UPDATE ##tblAll SET RecDebAcntCodeRetRemain = B.DebitRemain
		 FROM ##tblAll A
		 INNER JOIN 
		 (
			Select ProcessID, ProcessNo,FY FiscalYear, SN SerialNo, RecDebAcntCodeRet,
				   (' + @StrFields5 + ') DebitRemain 
			From ##tblAll H
			Group By RecDebAcntCodeRet, FY,SN, '+ @GroupbyCurrency +' H.VchDate' + Case When @CalcSalesInRemain = 0 Then ', ProcessID, ProcessNo, FY, SN ' Else '' End + '
		 ) B ON A.ProcessID = B.ProcessID AND A.ProcessNo = B.ProcessNo AND 
				A.FY = B.FiscalYear AND A.SN = B.SerialNo AND 
				A.RecDebAcntCodeRet = B.RecDebAcntCodeRet
					 		
		--SELECT DISTINCT FY FiscalYear,SN SerialNo,0 AS DocRowNo,A.*,CC.ChequesRemainAmount
		SELECT FY FiscalYear,SN SerialNo,0 AS DocRowNo,A.*,CC.ChequesRemainAmount,
			   Cast(''0'' AS VarChar(20)) AS DebitRemainStr, Cast(''0'' AS VarChar(20)) AS DebitRemainStr2,cast ( ' + str(@TaxOverWorthBeforDiscount) +' as int) as TaxOverWorthBeforDiscount
		, (  Select count(*)  from inv.tblStorageDocsDtl b where   A.ProcessID = b.ProcessID And A.ProcessNo = b.ProcessNo And A.FY = b.FiscalYear And A.SN= b.SerialNo  and b.TaxOverWorthCostDtl>0) TaxIslineModel			   
		FROM ##tblAll A
		LEFT JOIN #tbl_Sal_Invoices_Cheques CC on CC.AcntCode=A.AcntCode

		DROP TABLE ##tblAll
		DROP TABLE ##tblGroups'

		PRINT @StrSelectA;
		EXEC sp_executesql @StrSelectA;

	END
	ELSE
	BEGIN
		-- dont remove extra fields & dont change  field's order; -- 
		-- it must be sync with select at the end of this proc    --
	--	IF (@RowsCount = 0) 	
		Begin
			SET @StrSelectA = '
			BEGIN TRY
				DROP TABLE ##tblTmpAll
			END TRY
			BEGIN CATCH
			END CATCH
					
			SELECT D.*, CC.ChequesRemainAmount --,Cast(DebitRemain AS VarChar(20)) AS DebitRemainStr, Cast(DebitRemain2 AS VarChar(20)) AS DebitRemainStr2,cast ( ' + str(@TaxOverWorthBeforDiscount) +' as int)  as TaxOverWorthBeforDiscount
			,D.AcntCode RecDebAcntCodeRet
			INTO ##tblTmpAll
			FROM
			(
				SELECT IsNull((Select Top 1 Sequence 
							   From  sal.tblDistributionsDtl D 
							   Where D.BaseSaleProcessID = H.ProcessID And D.BaseSaleProcessNo = H.ProcessNo And 
									 D.BaseSaleFiscalYear = H.FiscalYear And D.BaseSaleSerialNo = H.SerialNo ),0) As DSequence,	
					   D.FiscalYear,D.SerialNo,' + @DocRowNo + ' DocRowNo, D.FiscalYear FY,D.SerialNo SN,' + @DocRowNo + ' RN,
					   ' + @StrFields1 
				
			SET @StrSelectB = @StrFields2 
			SET @StrSelectC = @StrFields3 
			
			SET @StrSelectD = '
			FROM	' + @StrFrom 
			
			SET @StrSelectE = @StrFrom2 + '
			WHERE	' + @StrWhere + ' ' +
			@GroupBy + '
			) D 
			LEFT JOIN #tbl_Sal_Invoices_Cheques CC on CC.AcntCode=D.AcntCode
			 ' + @OrderBy
			
			PRINT '============================================================='
			PRINT @StrSelectA;
			PRINT @StrSelectB;
			PRINT @StrSelectC;
			PRINT @StrSelectD;
			PRINT @StrSelectE;
			PRINT '============================================================='
			
			SET @StrSelectA = @StrSelectA + @StrSelectB + @StrSelectC + @StrSelectD + @StrSelectE
			EXEC sp_executesql @StrSelectA;
		
			-- ===============================================================
			SET @StrSelectA = '
			 UPDATE ##tblTmpAll SET DebitRemain = B.DebitRemain, DebitRemain2 = B.DebitRemain 
			 FROM ##tblTmpAll A
			 INNER JOIN 
			 (
				Select ProcessID, ProcessNo, FiscalYear, SerialNo, AcntCode,
					   (' + @StrFields4 + ') DebitRemain 
				From ##tblTmpAll H
				Group By AcntCode,FY,SN,  '+ @GroupbyCurrency +' H.VchDate' + Case When @CalcSalesInRemain = 0 Then ', ProcessID, ProcessNo, FiscalYear, SerialNo ' Else '' End + '
			 ) B ON A.ProcessID = B.ProcessID AND A.ProcessNo = B.ProcessNo AND 
					A.FiscalYear = B.FiscalYear AND A.SerialNo = B.SerialNo AND 
					A.AcntCode = B.AcntCode'			
			
			PRINT '============================================================='
			PRINT @StrSelectA;
			PRINT '============================================================='
			
			EXEC sp_executesql @StrSelectA;
			
		if @RecDebAcntCodeRet<>''
			UPDATE ##tblTmpAll SET RecDebAcntCodeRet =  acc.funMergAcntCode(@RecDebAcntCodeRet,AcntCode)
	
	if @TaxOverWorthAfterIncomeInSale  ='False'
			 UPDATE ##tblTmpAll SET TaxOverAfterIncomeInSalePrice =  0

			-- ===============================================================
			SET @StrSelectA = '
			 UPDATE ##tblTmpAll SET RecDebAcntCodeRetRemain = B.DebitRemain
			 FROM ##tblTmpAll A
			 INNER JOIN 
			 (
				Select ProcessID, ProcessNo, FiscalYear, SerialNo, RecDebAcntCodeRet,
					   (' + @StrFields5 + ') DebitRemain 
				From ##tblTmpAll H
				Group By RecDebAcntCodeRet,FY,SN,   '+ @GroupbyCurrency +' H.VchDate' + Case When @CalcSalesInRemain = 0 Then ', ProcessID, ProcessNo, FiscalYear, SerialNo ' Else '' End + '
			 ) B ON A.ProcessID = B.ProcessID AND A.ProcessNo = B.ProcessNo AND 
					A.FiscalYear = B.FiscalYear AND A.SerialNo = B.SerialNo AND 
					A.RecDebAcntCodeRet = B.RecDebAcntCodeRet'			
			
			PRINT '============================================================='
			PRINT @StrSelectA;
			PRINT '============================================================='
			
			EXEC sp_executesql @StrSelectA;
		
		SELECT  distinct ProcessID,ProcessNo, FiscalYear ,SerialNo, 0 DocRowNo
			into #tblTemp1
		from ##tblTmpAll

		Declare @RowsCount1 as int
		Declare @RowsCount2 as int
		Declare @ProcessID2 as int
		Declare @ProcessNo2 as int
		Declare @FiscalYear2 as int
		Declare @SerialNo2 as int

		IF (@RowsCount > 0) 
		begin

			SELECT ProcessID,ProcessNo, FiscalYear ,SerialNo into #tblTemp2
			from #tblTemp1

			DECLARE csr CURSOR FOR 
			SELECT ProcessID,ProcessNo, FiscalYear ,SerialNo
			from #tblTemp2

			OPEN csr
			FETCH NEXT FROM csr INTO @ProcessID2, @ProcessNo2, @FiscalYear2,@SerialNo2

			WHILE @@Fetch_Status = 0
			BEGIN
				SELECT @RowsCount2=COUNT(*) From ##tblTmpAll where ProcessID =@ProcessID2 and ProcessNo =@ProcessNo2 and  FiscalYear=@FiscalYear2 and SerialNo=@SerialNo2

				set @RowsCount1=@RowsCount-@RowsCount2
				while @RowsCount1>0
				begin
					insert into #tblTemp1
						SELECT  distinct  ProcessID,ProcessNo,FiscalYear ,SerialNo, ( Select Count(*)   from ##tblTmpAll a Where a.SerialNo=##tblTmpAll.SerialNo and  a.FiscalYear=##tblTmpAll.FiscalYear)+ @RowsCount1 DocRowNo		
						from ##tblTmpAll where ProcessID =@ProcessID2 and ProcessNo =@ProcessNo2 and  FiscalYear=@FiscalYear2 and SerialNo=@SerialNo2
					set @RowsCount1-=1
				end 

			FETCH NEXT FROM csr INTO @ProcessID2, @ProcessNo2, @FiscalYear2,@SerialNo2
			END

			CLOSE csr
			DEALLOCATE csr

		end 

		BEGIN TRY
			DROP TABLE ##tbl_FinalResult
		END TRY
		BEGIN CATCH
		END CATCH

		DELETE FROM #tblTemp1 WHERE DocRowNo = 0
		
		IF (SELECT SUM(DocRowNo) FROM ##tblTmpAll) > 0 
		BEGIN 	
			SET @StrSelectA = '
			SELECT * 
			INTO ##tbl_FinalResult
			FROM( SELECT A.*, 
						 ISNULL (CAST (DebitRemain AS VarChar(20)), ''0'') AS DebitRemainStr, 
						 ISNULL (CAST (DebitRemain2 AS VarChar(20)), ''0'') AS DebitRemainStr2,
						 CAST (' + LTrim(RTrim(Str(@TaxOverWorthBeforDiscount))) + ' AS INT) AS TaxOverWorthBeforDiscount,
						 SumPriceDtl SumPriceDtlAllDtl,
						 SD.PurePrice PurePriceAllDtl,
						 SD.DiscountHdr DiscountHdrAllDtl,
						 SD.DiscountDtl DiscountDtlAllDtl,
						 SD.TotalDiscount TotalDiscountAllDtl,
						 TaxDtl TaxDtlAllDtl,
						 TollDtl TollDtlAllDtl,
						 SD.TaxTollDtl TaxTollDtlAllDtl,
						 (Select COUNT(*)
						  FROM inv.tblStorageDocsDtl b 
						  WHERE A.ProcessID = b.ProcessID 
						    AND A.ProcessNo = b.ProcessNo 
							AND A.FiscalYear = b.FiscalYear 
							AND A.SerialNo = b.SerialNo 
							AND b.TaxOverWorthCostDtl>0) TaxIslineModel,
						 (SELECT SUM(EnterKind * GoodsQuantity) 
						  FROM inv.tblStorageDocsDtl s 
						  WHERE s.GoodsID = A.GoodsID 
						    AND s.DocDate <= A.DocDate 
							AND s.BatchNo = A.BatchNo 
							AND s.StoreID = A.StoreID ) AS Remain 
				  From ##tblTmpAll A
				  LEFT JOIN #tblStorageDocs SD ON SD.ProcessID = A.ProcessID 
											  AND SD.ProcessNo = A.ProcessNo 
											  AND SD.FiscalYear = A.FiscalYear 
											  AND SD.SerialNo = A.SerialNo
											  AND SD.DocRowNo = A.DocRowNo 
											  AND SD.GoodsID = A.GoodsID
				  WHERE (' + LTrim(RTrim(Str(@NotShowReward))) + ' = 0 OR (' + LTrim(RTrim(Str(@NotShowReward))) + ' = 1 AND A.IsReward = 0))
					AND (' + LTrim(RTrim(Str(@OnlyShowReward))) + ' = 0 OR (' + LTrim(RTrim(Str(@OnlyShowReward))) + ' = 1 AND A.IsReward = 1))
				  UNION ALL 
				  SELECT 0, FiscalYear, SerialNo, DocRowNo, FiscalYear, SerialNo, Null, Null, ProcessID, ProcessNo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, ''0'', ''0'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				  FROM #tblTemp1 ) A
				  ORDER BY A.ProcessID, A.ProcessNo, A.FiscalYear, A.SerialNo, A.DocRowNo' 
											
		END 
		ELSE
		BEGIN
			SET @StrSelectA = '
			SELECT * 
			INTO ##tbl_FinalResult
			FROM( SELECT A.*,
						 ISNULL (CAST (DebitRemain AS VarChar(20)), ''0'') AS DebitRemainStr, 
						 ISNULL (CAST (DebitRemain2 AS VarChar(20)), ''0'') AS DebitRemainStr2,
						 CAST (' + LTrim(RTrim(Str(@TaxOverWorthBeforDiscount))) + ' AS INT) AS TaxOverWorthBeforDiscount,
						 SumPriceDtl SumPriceDtlAllDtl,
						 SD.PurePrice PurePriceAllDtl,
						 SD.DiscountHdr DiscountHdrAllDtl,
						 SD.DiscountDtl DiscountDtlAllDtl,
						 SD.TotalDiscount TotalDiscountAllDtl,
						 TaxDtl TaxDtlAllDtl,
						 TollDtl TollDtlAllDtl,
						 SD.TaxTollDtl TaxTollDtlAllDtl, 
						 (SELECT COUNT(*)
						  FROM inv.tblStorageDocsDtl b 
						  WHERE A.ProcessID = b.ProcessID 
						    AND A.ProcessNo = b.ProcessNo 
							AND A.FiscalYear = b.FiscalYear 
							AND A.SerialNo = b.SerialNo 
							AND b.TaxOverWorthCostDtl > 0) TaxIslineModel,
						 (SELECT SUM(EnterKind * GoodsQuantity) 
						  FROM inv.tblStorageDocsDtl s 
						  WHERE s.GoodsID = A.GoodsID 
						    AND s.DocDate <= A.DocDate 
							AND s.BatchNo = A.BatchNo 
							AND s.StoreID = A.StoreID ) AS Remain 
				  FROM ##tblTmpAll A
				  LEFT JOIN (SELECT ProcessID, 
									ProcessNo, 
									FiscalYear, 
									SerialNo, 
									GoodsID, 
									BatchNo, 
									SUM (SumPriceDtl) SumPriceDtl,
									SUM (PurePrice) PurePrice,
									SUM (DiscountHdr) DiscountHdr,
									SUM (DiscountDtl) DiscountDtl,
									SUM (TotalDiscount)TotalDiscount,
									SUM (TaxDtl) TaxDtl,
									SUM (TollDtl) TollDtl,
									SUM (TaxTollDtl) TaxTollDtl
							 FROM #tblStorageDocs
							 GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo, GoodsID, BatchNo) SD ON SD.ProcessID = A.ProcessID 
																									  AND SD.ProcessNo = A.ProcessNo 
																									  AND SD.FiscalYear = A.FiscalYear 
																									  AND SD.SerialNo = A.SerialNo
																									  AND SD.GoodsID = A.GoodsID 
																									  AND SD.BatchNo = A.BatchNo
				  WHERE (' + LTrim(RTrim(Str(@NotShowReward))) + ' = 0 OR (' + LTrim(RTrim(Str(@NotShowReward))) + ' = 1 AND A.IsReward = 0))
				    AND (' + LTrim(RTrim(Str(@OnlyShowReward))) + ' = 0 OR (' + LTrim(RTrim(Str(@OnlyShowReward))) + ' = 1 AND A.IsReward = 1))
				  UNION ALL 
				  SELECT 0, FiscalYear, SerialNo, DocRowNo, FiscalYear, SerialNo, NULL, NULL, ProcessID, ProcessNo, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, Null, Null, Null, Null, Null, Null, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, Null, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
						 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, Null, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, Null, Null, Null, Null,NULL,''0'', 
						 ''0'', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				  FROM #tblTemp1 ) A	 
				  ORDER BY A.ProcessID, A.ProcessNo, A.FiscalYear, A.SerialNo, A.DocRowNo, A.GoodsID, A.BatchNo'
		END 

		PRINT '============================================================='
		PRINT @StrSelectA;
		PRINT '============================================================='
		 
		EXEC sp_executesql @StrSelectA;

		SET @StrWhere = '';		
		BEGIN TRY
			DROP TABLE ##tblAcntCode
		END TRY
		BEGIN CATCH
		END CATCH

		CREATE TABLE ##tblAcntCode
		(
		AcntCode Varchar(21)collate arabic_cs_as null
		)
		Insert into ##tblAcntCode (AcntCode) SELECT Distinct AcntCode FROM inv.tblStorageDocsDtl

		IF (@UserIsAdmin = 0)
		Begin
			Exec pub.SpFilterByPermission2 '##tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
			SET @StrWhere =  ' WHERE AcntCode in (SELECT AcntCode FROM  ##tblAcntCode) '
		End

		IF (SELECT SUM(DocRowNo) FROM ##tblTmpAll) > 0 
			SET @StrSelectA = 'SELECT * FROM ##tbl_FinalResult ' + @StrWhere + ' ORDER BY ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo'
		else
			SET @StrSelectA = 'SELECT * FROM ##tbl_FinalResult ' + @StrWhere + ' ORDER BY ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID, BatchNo'

		PRINT '============================================================='
		PRINT @StrSelectA;
		PRINT '============================================================='
		 
		EXEC sp_executesql @StrSelectA;

		RETURN
 		End	
	End
END
GO
