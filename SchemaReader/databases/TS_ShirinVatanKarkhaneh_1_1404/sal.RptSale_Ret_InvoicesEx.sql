USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/12/18
-- Viewed By	 : 
-- Last Modified : 1393/07/01
-- Modifier		 : TakroSystem\Hamid
-- Description	 : چاپ فاکتورهای فروش
-- ==============================================
Create PROCEDURE [sal].[RptSale_Ret_InvoicesEx]
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
	@RowsCount		TinyInt = 3, -- if 0 then no empty rows
	@Grouped		Bit = 0,
	@SaleTypeID		VarChar(20) = Null,
	@ExtraParams	NVarChar(500) = Null

WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrSelect1	NVarChar(Max);
DECLARE @StrSelect2	NVarChar(Max);
DECLARE @StrSelect3	NVarChar(Max);
DECLARE @StrFrom	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @StrWhere1	NVarChar(Max);
DECLARE @LanguageID TinyInt;
DECLARE @AcntLast	NVarChar(20);
DECLARE @BaseDate	NVarChar(10);
DECLARE @StrFields 	NVarChar(Max);
DECLARE @StrFields2	NVarChar(Max);
DECLARE @StrFields3	NVarChar(Max);
DECLARE @Row		Int;
DECLARE @MaxRowNo	Int;
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
DECLARE @DisD1		VarChar(50);
DECLARE @Eqal		NVarChar(2000);
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
declare @SessionNo  int;
declare @ReportID   int;

DECLARE @fval float;
DECLARE @sval varchar(50);

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

-- ======
DECLARE @goods_id					Varchar(20);
DECLARE @process_id					int;
DECLARE @process_no					int;
DECLARE @fiscal_year				int;
DECLARE @serial_no					int;
DECLARE @rowNo_no					int;
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

DECLARE @MainAndSubUnit					bit;
DECLARE @CalcLineTaxAndTollInRptInvoice bit;
DECLARE @TaxOverWorthBeforDiscount		bit;
DECLARE @sal_AggregateSimilarGoodsInRpt	Bit;
DECLARE @sal_AggregateGoodsPrices		Bit;
declare @WithBatch						bit;
DECLARE @NotShowReward					bit
DECLARE @OnlyShowReward					bit
declare @CurrentUser					VarChar(30);
DECLARE @IsMultiLng						bit;
DECLARE @GoodsGroup						int;
declare @TaxBranchID					VarChar(50);
declare @AvragePricesGroup				Int;

Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'
	SELECT @TaxOverWorthBeforDiscount = SettingValue from pub.tblSettings where SettingKey = 'TaxOverWorthBeforDiscount'
	select @TaxBranchID=SettingValue  from pub.tblSettings where SettingKey='TaxBranchID'

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
	
	-- I N I T -----------------------------------------------------------------------------------
	set @ShowRemainAndDay = 0;
	set @Customer1 = 0;
	set @Customer2 = 0;
	set @Customer3 = 0;
	set @Customer4 = 0;
	
	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	select @IsSettle = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'InvHasSettlementKind'
	
	set @fval = 0;
	
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

	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	SET @TransID		  = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @Remain1		  = LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @Remain2		  = LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @Remain3		  = LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @Remain4		  = LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @DistInf		  = LTrim(pub.funSplitString(@ExtraParams, '@', 8));

	SET @Dist0			  = LTrim(pub.funSplitString(@DistInf, '#', 1));
	SET @Dist1			  = LTrim(pub.funSplitString(@DistInf, '#', 3));
	SET @Dist2			  = LTrim(pub.funSplitString(@DistInf, '#', 5));
	SET @Disti0			  = LTrim(pub.funSplitString(@DistInf, '#', 7));
	SET @Disti1			  = LTrim(pub.funSplitString(@DistInf, '#', 10));
	SET @Disti2			  = LTrim(pub.funSplitString(@DistInf, '#', 12));

	SET @SvcFY			  = LTrim(pub.funSplitString(@ExtraParams, '@', 15));
	SET @SvcSN			  = LTrim(pub.funSplitString(@ExtraParams, '@', 16));
	
	SET @Customer1		  = LTrim(pub.funSplitString(@ExtraParams, '@', 17));
	SET @Customer2		  = LTrim(pub.funSplitString(@ExtraParams, '@', 18));
	SET @Customer3		  = LTrim(pub.funSplitString(@ExtraParams, '@', 19));
	SET @Customer4		  = LTrim(pub.funSplitString(@ExtraParams, '@', 20));
	
	SET @SessionNo		  					= LTrim(pub.funSplitString(@ExtraParams, '@', 21));
	SET @ReportID		  					= LTrim(pub.funSplitString(@ExtraParams, '@', 22));
	SET @IsCurrency		  					= LTrim(pub.funSplitString(@ExtraParams, '@', 23));
	SET @CurrentUser						= LTrim(pub.funSplitString(@ExtraParams, '@', 27));
	SET @ShowRemainAndDay 					= LTrim(pub.funSplitString(@ExtraParams, '@', 28));
	SET @HasSerial		  					= LTrim(pub.funSplitString(@ExtraParams, '@', 29));
	SET @FromExpireDate	  					= LTrim(pub.funSplitString(@ExtraParams, '@', 30));
	SET @ToExpireDate	  					= LTrim(pub.funSplitString(@ExtraParams, '@', 31));
	SET @PrdBatchNoFr	  					= LTrim(pub.funSplitString(@ExtraParams, '@', 32));
	SET @PrdBatchNoTo	  					= LTrim(pub.funSplitString(@ExtraParams, '@', 33));
	SET @PrdSerialFr	  					= LTrim(pub.funSplitString(@ExtraParams, '@', 34));
	SET @PrdSerialTo	  					= LTrim(pub.funSplitString(@ExtraParams, '@', 35));
	SET @MainAndSubUnit	  					= LTrim(pub.funSplitString(@ExtraParams, '@', 36));
	SET @CalcLineTaxAndTollInRptInvoice		= LTrim(pub.funSplitString(@ExtraParams, '@', 37));
	SET @sal_AggregateSimilarGoodsInRpt		= LTrim(pub.funSplitString(@ExtraParams, '@', 44));
	SET @sal_AggregateGoodsPrices			= LTrim(pub.funSplitString(@ExtraParams, '@', 45));
	SET @WithBatch							= LTrim(pub.funSplitString(@ExtraParams, '@', 46));
	SET @NotShowReward						= LTrim(pub.funSplitString(@ExtraParams, '@', 47));
	SET @OnlyShowReward						= LTrim(pub.funSplitString(@ExtraParams, '@', 48));
	SET @IsMultiLng 						= LTrim(pub.funSplitString(@ExtraParams, '@', 49));
	SET @GoodsGroup							= LTrim(pub.funSplitString(@ExtraParams, '@', 50));
	SET @AvragePricesGroup					= LTrim(pub.funSplitString(@ExtraParams, '@', 56));
	
	create table #tbl_Invoice_Signatures
	(
		UserID	int,
		UserSign	image
	);
	
	set @StrSelect = '
	insert into #tbl_Invoice_Signatures(UserID, UserSign)
	select UserID, UserSignature
	from ' + ltrim(rtrim(@db_0000)) + '.usr.tblUsers U '
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	-- ==========
	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	IF @QuantityDecimalsToForms>0
		SET		@QuantityDecimalsToForms = @QuantityDecimalsToForms - 1

	-- ==========
	Create Table #tbl_result
	(
		ProcessID					Int, 
		ProcessNo					Int,
		FiscalYear					Int,
		SerialNo					Int,
		RowNo						Int,	
		GoodsID						varchar(20) collate Arabic_CS_AS null,
		GoodsName					nvarchar(200) collate Arabic_CS_AS null,
		TotalQuantityGoodsOty		DECIMAL(28,9),
		UnitIDGoodsOty1				varchar(20) collate Arabic_CS_AS null,
		UnitNameGoodsOty1			nvarchar(20) collate Arabic_CS_AS null,
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
	create table #tbl_Sal_Invoices_Cheques
	(
		AcntCode varchar(20) collate arabic_cs_as not null,
		ChequesRemainAmount float not null
	)
	
	declare @Today char(10);
	set @Today = left(pub.funFarsiDate(GetDate()), 10);
	
	insert into #tbl_Sal_Invoices_Cheques(AcntCode, ChequesRemainAmount) 
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
select ProcessID	,ProcessNo	,FiscalYear	,SerialNo	,RowNo,DocRowNo	,GoodsID	,BatchNo ,
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

--select * from #tblStorageDocs
	-- W H E R E ---------------------------------------------------------------------------------
	SET @StrWhere = ' D.ProcessID = 100 AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
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

	IF (@TransID <> '0') 
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
	
	If @NotShowReward ='True'
		SET @StrWhere = @StrWhere + ' and D.IsReward=0'
		
	If @OnlyShowReward ='True'
		SET @StrWhere = @StrWhere + ' and D.IsReward=1'

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

	-- ===========================================================
	-- ===========================================================
	-- ===========================================================

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
	
	-- ==========
	SET @StrSelect1 = 'insert into #tbl_TmpQty
					   select D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo, D.GoodsID, D.GoodsQuantity
					   from ' + @SD + ' D
					   inner join ' + @SH + ' H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND 
												   H.SerialNo=D.SerialNo 
					   where ' + @StrWhere
	--print @StrSelect1;
	Exec sp_executesql @StrSelect1;		
	
	-- ==========
	SET @StrSelect1 = 'insert into #tbl_result
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
			  #tbl_result.ProcessNo = @process_no And #tbl_result.FiscalYear = @fiscal_year And #tbl_result.SerialNo = @serial_no AND #tbl_result.RowNo=@rowNo_no

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

	SET @StrFrom = ltrim(@SD) + ' D 
		INNER JOIN ' + ltrim(@SH) + ' H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
		LEFT JOIN sal.tblTransportersDtl N ON N.TransporterID=H.TransporterID
		LEFT JOIN sal.tblSaleTypes O2 ON D.SaleTypeID=O2.SaleTypeID
		LEFT JOIN sal.tblSaleTypesDtl O ON D.SaleTypeID=O.SaleTypeID
		LEFT JOIN inv.tblStoresDtl P ON P.StoreID=H.StoreID
		OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
		OUTER APPLY acc.funGetCodeInfo(H.VisitorAcntCode) VF
		LEFT JOIN pub.tblLocationsDtl Q ON Q.LocationID=F.LocationID
		LEFT JOIN pub.tblLocations R ON R.LocationID=Q.LocationID 
		LEFT JOIN pub.tblLocationsDtl L2 ON L2.LocationID=H.LocationID
		left join #tbl_Invoice_Signatures S1 on S1.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo)
		left join #tbl_Invoice_Signatures S2 on S2.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo2)
		left join #tbl_Invoice_Signatures S3 on S3.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo3)
		left join #tbl_Invoice_Signatures S4 on S4.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo4)
		left join #tbl_Invoice_Signatures S5 on S5.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo5)
		INNER JOIN inv.tblGoods S ON S.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND S.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		LEFT JOIN inv.tblUnitsDtl T ON T.UnitID=S.UnitID
		LEFT JOIN inv.tblUnitsDtl U ON U.UnitID=D.SubUnitID
		LEFT JOIN inv.tblSubUnitsDtl V ON V.GoodsID=D.GoodsID AND V.ShowInInvoice=1
		LEFT JOIN inv.tblUnitsDtl W ON W.UnitID=V.SubUnitID
	    LEFT JOIN #tbl_result R2 on R2.GoodsID = D.GoodsID And R2.SerialNo = H.SerialNo AND R2.RowNo = D.RowNo
		LEFT JOIN  inv.tblStorageDocsHdr BH on H.BaseProcessID= BH.ProcessID and H.BaseProcessNo= BH.ProcessNo and H.BaseFiscalYear= BH.FiscalYear and H.BaseSerialNo= BH.SerialNo 
		LEFT JOIN sal.tblSaleOrderHdr SH on BH.BaseProcessID= SH.ProcessID and BH.BaseProcessNo= SH.ProcessNo and BH.BaseFiscalYear= SH.FiscalYear and BH.BaseSerialNo= SH.SerialNo 
		LEFT JOIN sal.tblDistributionsHdr DH  on BH.BaseDistributionProcessID= DH.ProcessID  and BH.BaseDistributionSerialNo= DH.SerialNo
		LEFT JOIN pub.tblDriversDtl DR ON BH.DriverID=DR.DriverID AND DR.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
		LEFT JOIN prs.tblPersonnels PRS1 ON BH.DistributerID1=PRS1.PersonnelID 
		LEFT JOIN prs.tblPersonnels PRS2 ON BH.DistributerID2=PRS2.PersonnelID 
	
		
		'
			
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
		set @DisD1 = 'D.DiscountDtl'
	end
	else
	begin
		set @DisH1 = 'cast(0 as float) Discount'
		set @DisH2 = 'cast(0 as float) Discount2'
		set @DisH3 = 'cast(0 as float) TotalLineDiscount'
		set @DisH4 = 'cast(0 as float) AfterSaleDiscount'
		set @DisD1 = 'cast(0 as float) DiscountDtl'
	end;

	IF (@Grouped = 0) 
	BEGIN
		SET @StrFields = 'H.ProcessID, H.ProcessNo, H.VchDate DocDate,H.DocDate as DocDate0
		,'''+@TaxBranchID+''' TaxBranchID, H.TaxID,H.BaseTaxID,H.TPInp ,H.CurrencyRate,H.CurrencyDiscount,H.CurrencyTypeID,H.CurrencyValue,
		F.PersonType,Case when F.PersonType=1 then ''حقیقی'' when F.PersonType=2 then ''حقوقی''	when F.PersonType=3 then ''مشارکت مدنی''	when F.PersonType=4 then ''اتباع غیر ایرانی'' when F.PersonType=5 then ''مصرف کننده نهایی''	end PersonTypeName 
					, Case	when H.TPInp=1 then ''فروش/برگشت'' when H.TPInp=2 then ''ارزی'' when H.TPInp=3 then ''طلا و جواهر'' when H.TPInp=4 then ''قرار داد پیمانکاری'' when H.TPInp=5 then ''قبوض خدماتی''
							when H.TPInp=6 then ''بلیط هواپیما'' when H.TPInp=7 then ''صادرات''end TPInpName					
					,Case when F.PersonType in (2,3) then case when F.EconomicalCode<>'''' then F.EconomicalCode else F.NationalIdentity end 
							when F.PersonType in (1,4) then case when F.EconomicalCode<>'''' then F.EconomicalCode else F.NationalIDNumber end 
							when F.PersonType in (5) then '''' end PersonTypeCode
					,Case when H.TPEdited =0 then case when D.ProcessID=90 then ''فروش'' else ''برگشت'' end  else ''اصلاحی'' end TPEditedName	,
		H.TPEdited,H.TPContractNo,H.PayType
					, CASE	WHEN  H.PayType=1 THEN  CAST(FLOOR(((D.GoodsPrice*SubUnitQuantity)-FLOOR(DiscountDtl)) +FLOOR(TaxOverWorthCostDtl+TollOverWorthCostDtl ))  AS DECIMAL)
						WHEN H.PayType=2 THEN 0
						END Cop,CAST (FLOOR(D.TaxOverWorthCostDtl+D.TollOverWorthCostDtl) AS DECIMAL )AS TaxOverWorthNew
					,D.StoreID,D.StoreID2,''' + @BaseDate + ''' CurrDate,D.VirtualQuantity,
		H.TaxOverWorthCost,H.TollOverWorthCost,D.GoodsID,[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,H.TransportationCost,H.IAToll,H.IATollCod, H.TTMSPayOffTypeID,
		H.TaxCost,D.AcntCode,F.AcntName,F.EconomicalCode,F.Address1,F.Address2,' + @DisH1 + ',' + @DisH2 + ',H.DiscountTaxOverWorth,
		pub.funFarsiDateDiff(''Day'',''' + @BaseDate + ''',D.DocDate) DateDuration,IsNull(F.Tel,'''') Tel,D.GoodsQuantity,D.GoodsPrice,D.SubUnitPrice,
		D.AtomAmount OverloadAmount,H.DocDesc,D.DescDtl,H.VisitorAcntCode,pub.GetCodeName(H.VisitorAcntCode,' + @LangID + ') VisitorAcntName,
		H.AgreeNo,D.SubUnitID,D.SubUnitQuantity,inv.UQ(D.GoodsID,D.SubUnitID) SubQuantity,H.OtherCostAcntCode,H.OtherIncomeAcntCode, cast(''' + @StoreVar1 + ''' as nvarchar(50)) as StoreVar1Text, cast(''' + @StoreVar2 + ''' as nvarchar(50)) as StoreVar2Text,
		H.OtherCost,H.OtherIncome,H.TransportationIncome,H.TransportationIncomeAcntCode,D.SaleTypeID,O.SaleTypeName,pub.funGetLocationName(F.LocationID,1) LocationName,R.AreaCode,
		F.ZipCode,F.CustomerFirstName+'' ''+F.CustomerLastName CustomerName,F.CompanyRegisterNo,F.NationalIDNumber,H.PackingCost,F.OrganzationName,
		H.DiscountPercent,H.VchNo,H.EarnestMoney,S.GoodsCID,S.ExtraField1,S.ExtraField2,S.ExtraField3,S.ExtraField4,S.ExtraField5,S.TechnicalSpecifications,H.TransporterID,N.TransporterName,P.StoreName,
		pub.UN(H.SessionNo) UserName,pub.UN(H.SessionNo) UserName1,pub.UN(H.SessionNo2) UserName2,pub.UN(H.SessionNo3) UserName3,pub.UN(H.SessionNo4) UserName4,pub.UN(H.SessionNo5) UserName5,
		H.DocStep,H.Amount,F.Mobile,T.UnitName,W.UnitName UnitName2,U.UnitName UnitName3,W.UnitName UnitNameX,' + @DisH3 + ',V.UnitValue,V.MainUnitValue,case when (V.MainUnitValue<>0) then V.UnitValue/V.MainUnitValue else 1 end UnitScale,
		case when H.DestinationAddress <>'''' THEN H.DestinationAddress ELSE H.Address END DestinationAddress,F.Sequence,D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,isnull(O2.DaysNo,0) DaysNo, D.StoreVariable1, D.StoreVariable2,
		H.BaseDistributionFiscalYear,H.BaseDistributionSerialNo,S.TechnicalNo,' + @DisD1 + ',S.GoodsLength,S.GoodsWidth,S.GoodsHeight,' + @DisH4 + ',H.OwnerDocNo,
		D.BatchNo,L2.LocationName LocationName2,D.DiscountPercentDtl,D.VisitorPercent,inv.UQ2(D.GoodsID,D.SubUnitID) SQ2,H.CashAmount,H.ChequeAmount,H.ComssionCostPrice,H.BasculePrice,H.LaborPrice,H.TransportPrice,
	    ' 
		SET @StrFields2 = '				IsNull(
		(
 		 Select Sum(Amount) 
		 From trs.tblPayDtl
		 Where ProcessID = 13 And DebitCode = D.AcntCode
		 Group By ProcessID, DebitCode
		 ),0) As SumReceivableReturn,
		 
		 IsNull((Select Top 1 SS.ProductSerialID From inv.tblStorageDocsSerials SS 
		  Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
				SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
				SS.DocRowNo = D.DocRowNo),0) As ProductSerialID,
		 IsNull((Select Top 1 SS.BatchNo From inv.tblStorageDocsSerials SS 
		  Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
				SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
				SS.DocRowNo = D.DocRowNo),'''') As PrdBatchNo,
		 IsNull((Select Top 1 SS.ExpireDate From inv.tblStorageDocsSerials SS 
		  Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
				SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
				SS.DocRowNo = D.DocRowNo),'''') As PrdExpireDate,	
								   
		Cast(' + @SettleStr + ' as bit) IsSettle,' + str(@svcCount) + ' SvcCount,H.TransporterID2,VF.Tel VisitorTel,cast(' + str(@fval) + ' as float) VATPercent,F.AsnafID,D.CurrencyAmount,F.OtherTels,F.NationalIdentity,
		S1.UserSign as UserSignature1, S2.UserSign as UserSignature2, S3.UserSign as UserSignature3, S4.UserSign as UserSignature4, S5.UserSign as UserSignature5,
		F.Fax,D.ConstText1,D.ConstText2,D.ConstText3,D.ConstText4,H.C1,H.C2,H.C3,H.C4,H.C5,H.C6,H.C7, H.C8, H.C9, H.C10, H.C11, H.C12,D.Var1,D.Var2,D.Var3,D.Var4,
		ROUND(IsNull(R2.TotalQuantityGoodsOty,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityGoodsOty, IsNull(R2.UnitIDGoodsOty1,'''') RUnitIDGoodsOty1, 
		IsNull(R2.UnitNameGoodsOty1,'''') RUnitNameGoodsOty1, ROUND(IsNull(R2.TotalQuantityGoodsOty1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityGoodsOty1, 
		IsNull(R2.UnitIDGoodsOty2,'''') RUnitIDGoodsOty2, IsNull(R2.UnitNameGoodsOty2,'''') RUnitNameGoodsOty2, 
		ROUND(IsNull(R2.TotalQuantityGoodsOty2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityGoodsOty2,	
		IsNull(R2.Weight,0) RWeight, IsNull(R2.Volume,0) RVolume, 
		IsNull(R2.BarCode,'''') RBarCode '
	END
	ELSE
	BEGIN
		SET @StrFields = 'H.ProcessID, H.ProcessNo, H.VchDate AS DocDate,H.DocDate as DocDate0
		,'''+@TaxBranchID+''' TaxBranchID, H.TaxID,H.BaseTaxID,H.TPInp  ,H.CurrencyRate,H.CurrencyDiscount,H.CurrencyTypeID,H.CurrencyValue,
		F.PersonType,Case when F.PersonType=1 then ''حقیقی'' when F.PersonType=2 then ''حقوقی''	when F.PersonType=3 then ''مشارکت مدنی''	when F.PersonType=4 then ''اتباع غیر ایرانی'' when F.PersonType=5 then ''مصرف کننده نهایی''	end PersonTypeName 
					, Case	when H.TPInp=1 then ''فروش/برگشت'' when H.TPInp=2 then ''ارزی'' when H.TPInp=3 then ''طلا و جواهر'' when H.TPInp=4 then ''قرار داد پیمانکاری'' when H.TPInp=5 then ''قبوض خدماتی''
							when H.TPInp=6 then ''بلیط هواپیما'' when H.TPInp=7 then ''صادرات''end TPInpName					
					,Case when F.PersonType in (2,3) then case when F.EconomicalCode<>'''' then F.EconomicalCode else F.NationalIdentity end 
							when F.PersonType in (1,4) then case when F.EconomicalCode<>'''' then F.EconomicalCode else F.NationalIDNumber end 
							when F.PersonType in (5) then '''' end PersonTypeCode
					,Case when H.TPEdited  =0 then case when D.ProcessID=90 then ''فروش'' else ''برگشت'' end  else ''اصلاحی'' end TPEditedName,
					H.TPEdited,H.TPContractNo,H.PayType
					, CASE	WHEN  H.PayType=1 THEN  CAST(FLOOR(((D.GoodsPrice*SubUnitQuantity)-FLOOR(DiscountDtl)) +FLOOR(TaxOverWorthCostDtl+TollOverWorthCostDtl ))  AS DECIMAL)
						WHEN H.PayType=2 THEN 0
						END Cop,CAST (FLOOR(D.TaxOverWorthCostDtl+D.TollOverWorthCostDtl) AS DECIMAL )AS TaxOverWorthNew
					,D.StoreID,D.StoreID2,''' + @BaseDate + ''' CurrDate,D.VirtualQuantity,
		H.TaxOverWorthCost,H.TollOverWorthCost,D.GoodsID,[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,H.TransportationCost,H.IAToll,H.IATollCod, H.TTMSPayOffTypeID,
		H.TaxCost,D.AcntCode,F.AcntName,F.EconomicalCode,'''' Address1, '''' Address2,' + @DisH1 + ',' + @DisH2 + ',H.DiscountTaxOverWorth,
		pub.funFarsiDateDiff(''Day'',''' + @BaseDate + ''',D.DocDate) DateDuration,IsNull(F.Tel,'''') Tel,D.GoodsQuantity,D.GoodsPrice,D.SubUnitPrice,
		D.AtomAmount OverloadAmount,H.DocDesc,'''' DescDtl,H.VisitorAcntCode,pub.GetCodeName(H.VisitorAcntCode,' + @LangID + ') VisitorAcntName,
		H.AgreeNo,D.SubUnitID,0 SubUnitQuantity,inv.UQ(D.GoodsID,D.SubUnitID) SubQuantity,H.OtherCostAcntCode,H.OtherIncomeAcntCode, ''' + @StoreVar1 + ''' as StoreVar1Text, ''' + @StoreVar2 + ''' as StoreVar2Text,
		H.OtherCost,H.OtherIncome,H.TransportationIncome,H.TransportationIncomeAcntCode,D.SaleTypeID,O.SaleTypeName,'''' LocationName, '''' AreaCode,
		F.ZipCode,F.CustomerFirstName+'' ''+F.CustomerLastName CustomerName,F.CompanyRegisterNo,F.NationalIDNumber,H.PackingCost,F.OrganzationName,
		H.DiscountPercent,H.VchNo,EarnestMoney,S.GoodsCID,S.ExtraField1,S.ExtraField2,S.ExtraField3,S.ExtraField4,S.ExtraField5,S.TechnicalSpecifications,H.TransporterID,N.TransporterName,P.StoreName,
		pub.UN(H.SessionNo) UserName,pub.UN(H.SessionNo) UserName1,pub.UN(H.SessionNo2) UserName2,pub.UN(H.SessionNo3) UserName3,pub.UN(H.SessionNo4) UserName4,pub.UN(H.SessionNo5) UserName5,
		H.DocStep,H.Amount,F.Mobile,T.UnitName,W.UnitName UnitName2,U.UnitName UnitName3,W.UnitName UnitNameX,' + @DisH3 + ',V.UnitValue,V.MainUnitValue,case when(V.MainUnitValue<>0)then V.UnitValue/V.MainUnitValue else 1 end UnitScale,
		case when H.DestinationAddress <>'''' THEN H.DestinationAddress ELSE H.Address END DestinationAddress,F.Sequence,D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,isnull(O2.DaysNo,0) DaysNo, D.StoreVariable1, D.StoreVariable2,
		H.BaseDistributionFiscalYear,H.BaseDistributionSerialNo,S.TechnicalNo,' + @DisD1 + ',S.GoodsLength,S.GoodsWidth,S.GoodsHeight,' + @DisH4 + ',H.OwnerDocNo,
		D.BatchNo,L2.LocationName LocationName2,D.DiscountPercentDtl,D.VisitorPercent,0 SQ2,H.CashAmount,H.ChequeAmount,H.ComssionCostPrice,H.BasculePrice,H.LaborPrice,H.TransportPrice,
	   '
		SET @StrFields2 = '				 IsNull(
		(
 		 Select Sum(Amount) 
		 From trs.tblPayDtl
		 Where ProcessID = 13 And DebitCode = D.AcntCode
		 Group By ProcessID, DebitCode
		 ),0) As SumReceivableReturn,
		 
		 IsNull((Select Top 1 SS.ProductSerialID From inv.tblStorageDocsSerials SS 
		  Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
				SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
				SS.DocRowNo = D.DocRowNo),0) As ProductSerialID,
		 IsNull((Select Top 1 SS.BatchNo From inv.tblStorageDocsSerials SS 
		  Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
				SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
				SS.DocRowNo = D.DocRowNo),'''') As PrdBatchNo,
		 IsNull((Select Top 1 SS.ExpireDate From inv.tblStorageDocsSerials SS 
		  Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
				SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
				SS.DocRowNo = D.DocRowNo),'''') As PrdExpireDate,	
				
		Cast(' + @SettleStr + ' as bit) IsSettle,' + str(@svcCount) + ' SvcCount,H.TransporterID2,VF.Tel VisitorTel,cast(' + str(@fval) + ' as float) VATPercent,F.AsnafID,D.CurrencyAmount,F.OtherTels,F.NationalIdentity,
		S1.UserSign as UserSignature1, S2.UserSign as UserSignature2, S3.UserSign as UserSignature3, S4.UserSign as UserSignature4, S5.UserSign as UserSignature5,
		F.Fax,D.ConstText1,D.ConstText2,D.ConstText3,D.ConstText4,H.C1,H.C2,H.C3,H.C4,H.C5,H.C6,H.C7, H.C8, H.C9, H.C10, H.C11, H.C12,D.Var1,D.Var2,D.Var3,D.Var4,
		ROUND(IsNull(R2.TotalQuantityGoodsOty,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityGoodsOty, IsNull(R2.UnitIDGoodsOty1,'''') RUnitIDGoodsOty1, 
		IsNull(R2.UnitNameGoodsOty1,'''') RUnitNameGoodsOty1, ROUND(IsNull(R2.TotalQuantityGoodsOty1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityGoodsOty1, 
		IsNull(R2.UnitIDGoodsOty2,'''') RUnitIDGoodsOty2, IsNull(R2.UnitNameGoodsOty2,'''') RUnitNameGoodsOty2, 
		ROUND(IsNull(R2.TotalQuantityGoodsOty2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityGoodsOty2,	
		IsNull(R2.Weight,0) RWeight, IsNull(R2.Volume,0) RVolume, 
		IsNull(R2.BarCode,'''') RBarCode '
	END

	If (@ShowRemain = 1)
	Begin
		declare @CountPartRemain tinyint
		SET @CountPartRemain=0;
	
		SET @Eqal = '1=1'

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
			END
		if @IsCurrency = 1
				SET @StrFields2 = @StrFields2 + ',  CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * '
			else
				SET @StrFields2 = @StrFields2 + ',' 

		SET @StrFields2 = @StrFields2 + '
		(SELECT	IsNull(Sum(Debit-Credit),0) Debit 
		FROM	acc.tblVoucherDtl M INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo=M.SerialNo
		WHERE   M.VchKind<>0 AND VH.DocRegisterState>0 AND (' + @Eqal + ') AND 
				(M.DocDate<=H.VchDate AND Not (M.DocDate=H.VchDate AND M.SourceProcessID in(100) AND M.SourceProcessNo=H.ProcessNo AND M.SourceFiscalYear=H.FiscalYear AND M.SourceSerialNo>=H.SerialNo))
		) DebitRemain
	'
	End
	Else
	
		SET @StrFields2 = @StrFields2 + ',0 AS DebitRemain '
	
		if (@ShowRemainAndDay=1 )
		SET @StrFields2 = @StrFields2 + ',convert(varchar(10),sal.funGetRemainSal_InvoicesDate(H.ProcessID 	,H.ProcessNo  	,H.FiscalYear  	,H.SerialNo)) as DayRemain
		,sal.funGetRemainSal_InvoicesRemain(H.ProcessID 	,H.ProcessNo  	,H.FiscalYear  	,H.SerialNo) as PayRemain
		'
			else
		SET @StrFields2 = @StrFields2 + '	,convert(varchar(10),'''') as DayRemain	,0 as PayRemain
		'
		
		SET @StrFields2 = @StrFields2 + '	,H.SettlementDate,PurePrice,	DistributionPercent,	DistributionPrice,	GoodsPriceWithTax 
											,Substring(H.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ') AcntCode1
											,Substring(H.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') AcntCode2
											,Substring(H.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') AcntCode3
											,Substring(H.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') AcntCode4
											,IsNull((Select top 1 Sequence From sal.tblDistributionsDtl D Where  D.BaseSaleProcessID = H.ProcessID And D.BaseSaleProcessNo = H.ProcessNo And D.BaseSaleFiscalYear = H.FiscalYear And D.BaseSaleSerialNo = H.SerialNo ),0) as DSequence						  
											,pub.funGetCustomerKindID(H.AcntCode) CustomerKindID,'''+@CurrentUser+''' CurrentUser					
											,[sal].[funGetCustomerKindName](pub.funGetCustomerKindID(H.AcntCode),' + LTrim(RTrim(@LangID)) + ' )CustomerKindName
											,D.OtherIncomePerentDtl,D.OtherIncomeDtl , DR.DriverID, (DR.FirstName +' + '''-''' + '+ DR.LastName) As DriverName											
											,DistributDate,SH.DocDate OrderDocDate,H.TaxSerialNoInvoice TaxSerialNo
											,H.DistributerID1, prs.funGetPersonnelName(H.DistributerID1,' + @LangID + ') DistributerName1, PRS1.Tel DistributerTel1, PRS1.Mobile DistributerMobile1
											,H.DistributerID2, prs.funGetPersonnelName(H.DistributerID2,' + @LangID + ') DistributerName2, PRS2.Tel DistributerTel2, PRS2.Mobile DistributerMobile2
											'

	-------------------------------------------------------------------------------------------
	IF (@Grouped = 1)
	BEGIN
		SET @StrSelect = N'
		BEGIN TRY
			DROP TABLE ##tblAll
			DROP TABLE ##tblGroups
		END TRY
		BEGIN CATCH
		END CATCH

		SELECT	D.FiscalYear FY,D.SerialNo SN,D.DocRowNo RN,' + @StrFields 
		
		SET @StrSelect2 = @StrFields2 + N'
		
		INTO	##tblAll
		FROM	' + @StrFrom + '
		WHERE	' + @StrWhere + '

		CREATE TABLE ##tblGroups
		(
			GD_ID	VarChar(20),
			GR_ID	VarChar(20),
			GR_Name NVarChar(50)
		)
		
		INSERT INTO ##tblGroups
		SELECT	GD.GoodsID,G.GoodsGroupID,G.GoodsGroupName
		FROM	inv.tblGoodsGroupsDtl G
					INNER JOIN inv.tblGoodsGroupsGoodsListDtl GD ON G.GoodsGroupID=GD.GoodsGroupID '

		Print @StrSelect;
		Print @StrSelect2;
		
		SET @StrSelect = @StrSelect + @StrSelect2
		EXEC sp_executesql @StrSelect;

		SET @StrSelect = N'
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

		SELECT DISTINCT FY FiscalYear,SN SerialNo,0 AS DocRowNo,A.*,CC.ChequesRemainAmount,' + str(@TaxOverWorthBeforDiscount) +' as TaxOverWorthBeforDiscount
		, (  Select count(*)  from inv.tblStorageDocsDtl b where   A.ProcessID = b.ProcessID And A.ProcessNo = b.ProcessNo And A.FiscalYear = b.FiscalYear And A.SerialNo = b.SerialNo and b.TaxOverWorthCostDtl>0) TaxIslineModel	   
		FROM ##tblAll A
			left join #tbl_Sal_Invoices_Cheques CC on CC.AcntCode=D.AcntCode

		DROP TABLE ##tblAll
		DROP TABLE ##tblGroups'

		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
	END
	ELSE
	BEGIN
		-- dont remove extra fields & dont change  field's order; -- 
		-- it must be sync with select at the end of this proc    --
	
		IF (@RowsCount = 0) 
		Begin
			SET @StrSelect = '
			SELECT D.*,Cast(DebitRemain AS VarChar(20)) AS DebitRemainStr, CC.ChequesRemainAmount,' + str(@TaxOverWorthBeforDiscount) +' as TaxOverWorthBeforDiscount
			,SumPriceDtl  SumPriceDtlAllDtl ,SD.PurePrice PurePriceAllDtl,SD.DiscountHdr  DiscountHdrAllDtl ,SD.DiscountDtl DiscountDtlAllDtl
			,SD.TotalDiscount	TotalDiscountAllDtl	,TaxDtl TaxDtlAllDtl ,TollDtl TollDtlAllDtl,SD.TaxTollDtl TaxTollDtlAllDtl			
			, (  Select count(*)  from inv.tblStorageDocsDtl b where   D.ProcessID = b.ProcessID And D.ProcessNo = b.ProcessNo And D.FiscalYear = b.FiscalYear And D.SerialNo = b.SerialNo and b.TaxOverWorthCostDtl>0) TaxIslineModel	   			
			FROM
			(
				SELECT	D.FiscalYear,D.SerialNo,D.DocRowNo,D.FiscalYear FY,D.SerialNo SN,D.DocRowNo RN,D.TaxOverWorthCostDtl,D.TollOverWorthCostDtl,' + @StrFields 
			
			SET @StrSelect2 = @StrFields2 + N'
				FROM	' + @StrFrom + '
				WHERE	' + @StrWhere + '
			) D 
				left join #tbl_Sal_Invoices_Cheques CC on CC.AcntCode=D.AcntCode
				left join #tblStorageDocs SD on 
				 SD.ProcessID=D.ProcessID AND SD.ProcessNo=D.ProcessNo AND SD.FiscalYear=D.FiscalYear AND SD.SerialNo=D.SerialNo AND SD.DocRowNo=D.DocRowNo 
			ORDER BY D.DocRowNo '

			Print @StrSelect;
			Print @StrSelect2;			
			SET @StrSelect = @StrSelect + @StrSelect2
			EXEC sp_executesql @StrSelect;
			RETURN

 		End
		-- S E L E C T ----------------------------------------------------------------------------
		CREATE TABLE #tblInvoices
		(
			FiscalYear	SmallInt,
			SerialNo	Int,
			MaxRowNo	Int
		);

		SET @StrSelect = '
		INSERT INTO #tblInvoices(FiscalYear,SerialNo,MaxRowNo)
		SELECT D.FiscalYear,D.SerialNo,Max(D.DocRowNo)
		FROM  ' + @StrFrom + '
		WHERE ' + @StrWhere + '
		GROUP BY D.FiscalYear,D.SerialNo'

		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;

		CREATE TABLE #tblMy
		(
			FiscalYear	SmallInt,
			SerialNo	Int,
			DocRowNo	Int
		);

		SET @StrSelect = '
		INSERT INTO #tblMy(FiscalYear,SerialNo,DocRowNo)
		SELECT D.FiscalYear,D.SerialNo,D.DocRowNo
		FROM ' + @StrFrom + '
		WHERE ' + @StrWhere 

		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;

		DECLARE My_Cursor CURSOR FOR
			SELECT *
			FROM #tblInvoices
		
		OPEN My_Cursor
		FETCH NEXT FROM My_Cursor INTO @FiscalYear, @SerialNo, @MaxRowNo

		WHILE @@Fetch_Status = 0 
		Begin
			If @RowsCount > @MaxRowNo 
			Begin
				
				SET @MinRowNo = @MaxRowNo
				SET @MaxRowNo = @RowsCount
				
				WHILE @MinRowNo < @MaxRowNo
				Begin
					SET @MinRowNo = @MinRowNo + 1

					INSERT INTO #tblMy
					VALUES(@FiscalYear, @SerialNo, @MinRowNo)
				End
			End

			FETCH NEXT FROM My_Cursor INTO @FiscalYear, @SerialNo, @MaxRowNo
		End;

		CLOSE My_Cursor
		DEALLOCATE My_Cursor

		SET @StrSelect = '
			SELECT D.*,Cast(DebitRemain AS VarChar(20)) AS DebitRemainStr, CC.ChequesRemainAmount,' + str(@TaxOverWorthBeforDiscount) +' as TaxOverWorthBeforDiscount
			, (  Select count(*)  from inv.tblStorageDocsDtl b where   D.ProcessID = b.ProcessID And D.ProcessNo = b.ProcessNo And D.FiscalYear = b.FiscalYear And D.SerialNo = b.SerialNo and b.TaxOverWorthCostDtl>0) TaxIslineModel	   			
			into  #tblAll
			FROM
			(
				SELECT	D.FiscalYear,D.SerialNo,D.DocRowNo,D.FiscalYear FY,D.SerialNo SN,D.DocRowNo RN,D.TaxOverWorthCostDtl,D.TollOverWorthCostDtl,' + @StrFields 
			
		SET @StrSelect2 = @StrFields2 + N'
				FROM	' + @StrFrom + '
				WHERE	' + @StrWhere + '
			) D 
				left join #tbl_Sal_Invoices_Cheques CC on CC.AcntCode=D.AcntCode
			ORDER BY D.DocRowNo;			
			select  R.FiscalYear,R.SerialNo,R.DocRowNo,D.*
			,SumPriceDtl  SumPriceDtlAllDtl ,SD.PurePrice PurePriceAllDtl,SD.DiscountHdr  DiscountHdrAllDtl ,SD.DiscountDtl DiscountDtlAllDtl
			,SD.TotalDiscount	TotalDiscountAllDtl	,TaxDtl TaxDtlAllDtl ,TollDtl TollDtlAllDtl,SD.TaxTollDtl TaxTollDtlAllDtl
			FROM	#tblMy R LEFT JOIN #tblAll D ON (R.FiscalYear=D.FY) AND (R.SerialNo=D.SN) AND (R.DocRowNo=D.RN) 
					left join #tblStorageDocs SD on 
				 SD.ProcessID=D.ProcessID AND SD.ProcessNo=D.ProcessNo AND SD.FiscalYear=D.FiscalYear AND SD.SerialNo=D.SerialNo AND SD.DocRowNo=D.DocRowNo 		 
			'
		Print @StrSelect;
		Print @StrSelect2;

		SET @StrSelect = @StrSelect + @StrSelect2
		EXEC sp_executesql @StrSelect;
	
	--------------------------------------------------------------------------------------
	END

END
GO
