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
CREATE PROCEDURE [cmr].[RptBuy_Doc_Ex]
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
DECLARE @StrSelectA	NVarChar(Max);
DECLARE @StrSelectB	NVarChar(Max);
DECLARE @StrSelect1	NVarChar(Max);
DECLARE @StrSelect2	NVarChar(Max);
DECLARE @StrSelect3	NVarChar(Max);
DECLARE @StrFrom	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @StrWhere1	NVarChar(Max);
DECLARE @StrWhere2	NVarChar(Max);
DECLARE @LanguageID TinyInt;
DECLARE @AcntLast	NVarChar(20);
DECLARE @BaseDate	NVarChar(10);
DECLARE @StrFields1	NVarChar(Max);
DECLARE @StrFields2	NVarChar(Max);
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
DECLARE @SessionNo  int;
DECLARE @ReportID   int;

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

Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

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

	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	SET @TransID			= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @Remain1			= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @Remain2			= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @Remain3			= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @Remain4			= LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @DistInf			= LTrim(pub.funSplitString(@ExtraParams, '@', 8));

	SET @Dist0				= LTrim(pub.funSplitString(@DistInf, '#', 1));
	SET @Dist1				= LTrim(pub.funSplitString(@DistInf, '#', 3));
	SET @Dist2				= LTrim(pub.funSplitString(@DistInf, '#', 5));
	SET @Disti0				= LTrim(pub.funSplitString(@DistInf, '#', 7));
	SET @Disti1				= LTrim(pub.funSplitString(@DistInf, '#', 10));
	SET @Disti2				= LTrim(pub.funSplitString(@DistInf, '#', 12));

	SET @SvcFY				= LTrim(pub.funSplitString(@ExtraParams, '@', 15));
	SET @SvcSN				= LTrim(pub.funSplitString(@ExtraParams, '@', 16));
	
	SET @Customer1			= LTrim(pub.funSplitString(@ExtraParams, '@', 17));
	SET @Customer2			= LTrim(pub.funSplitString(@ExtraParams, '@', 18));
	SET @Customer3			= LTrim(pub.funSplitString(@ExtraParams, '@', 19));
	SET @Customer4			= LTrim(pub.funSplitString(@ExtraParams, '@', 20));
	
	SET @SessionNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 21));
	SET @ReportID			= LTrim(pub.funSplitString(@ExtraParams, '@', 22));
	SET @IsCurrency			= LTrim(pub.funSplitString(@ExtraParams, '@', 23));
	SET @ShowRemainAndDay	= LTrim(pub.funSplitString(@ExtraParams, '@', 28));
	SET @HasSerial			= LTrim(pub.funSplitString(@ExtraParams, '@', 29));
	SET @FromExpireDate		= LTrim(pub.funSplitString(@ExtraParams, '@', 30));
	SET @ToExpireDate		= LTrim(pub.funSplitString(@ExtraParams, '@', 31));
	SET @PrdBatchNoFr		= LTrim(pub.funSplitString(@ExtraParams, '@', 32));
	SET @PrdBatchNoTo		= LTrim(pub.funSplitString(@ExtraParams, '@', 33));
	SET @PrdSerialFr		= LTrim(pub.funSplitString(@ExtraParams, '@', 34));
	SET @PrdSerialTo		= LTrim(pub.funSplitString(@ExtraParams, '@', 35));
	SET @StartTargetLayer	= LTrim(pub.funSplitString(@ExtraParams, '@', 36));
	SET @LenTargetLayer		= LTrim(pub.funSplitString(@ExtraParams, '@', 37));
	SET @IsMultiLng			= LTrim(pub.funSplitString(@ExtraParams, '@', 38));
	SET @GoodsGroup		    = LTrim(pub.funSplitString(@ExtraParams, '@', 39));
	SET @CalcSalesInRemain  = LTrim(pub.funSplitString(@ExtraParams, '@', 40));
	
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
	
	print @StrSelectA;
	exec sp_executesql @StrSelectA;
	
	if (select COUNT(*)  from sys.tables where name='tbl_CDescription')=0
	BEGIN
		EXEC [sal].[SpGetCustomreGoodsDescription]
	END

	Select @CountCustomerKind = Count(*)
	From sal.tbl_CDescription
	where CDescription<>''
	
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

	-- W H E R E ---------------------------------------------------------------------------------
	SET @StrWhere = ' D.ProcessID = 60 AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
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
			set @SD = 'inv.funStorageDtl_Group ('+ltrim(STR(@GoodsGroup))+',0)'
		end
		else
		begin
			set @SH = 'inv.tblStorageDocsHdr'
			set @SD = 'inv.tblStorageDocsDtl'		
		end
	end

	-- ##### گروه بندی کالا تا لایه انتخاب شده
	--if (@GoodsGroup > 0)
	--  begin
	--		set @SH = 'inv.vwStorageHdr_Group'
	--		set @SD = '[inv].[funStorageDtl_Group] ('+ltrim(STR(@GoodsGroup))+',0)'
	--  end
	-- ##### گروه بندی کالا تا لایه انتخاب شده
	
	SET @StrFrom = ltrim(@SD) + ' D 
		INNER JOIN ' + ltrim(@SH) + ' H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
		LEFT JOIN sal.tblTransportersDtl N ON N.TransporterID=H.TransporterID
		LEFT JOIN sal.tblSaleTypes O2 ON D.SaleTypeID=O2.SaleTypeID
		LEFT JOIN sal.tblSaleTypesDtl O ON D.SaleTypeID=O.SaleTypeID
		LEFT JOIN sal.tblSaleTypesDtl OH ON H.SaleTypeID=OH.SaleTypeID
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
		LEFT JOIN inv.tblGoods S ON S.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND S.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		LEFT JOIN inv.tblUnitsDtl T ON T.UnitID=S.UnitID
		LEFT JOIN inv.tblUnitsDtl U ON U.UnitID=D.SubUnitID
		LEFT JOIN inv.tblSubUnitsDtl V ON V.GoodsID=D.GoodsID AND V.ShowInInvoice=1
		LEFT JOIN inv.tblUnitsDtl W ON W.UnitID=V.SubUnitID
		LEFT JOIN pub.tblDriversDtl DR ON H.DriverID=DR.DriverID ' +
		Case When @CountCustomerKind > 0 Then 
		'LEFT JOIN sal.tbl_CDescription DS ON DS.CustomerKindID = [pub].[funGetCustomerKindID] (D.AcntCode) AND DS.GoodsID = D.GoodsID '
		Else '' End + '
		--LEFT JOIN inv.tblStorageDocsSerials SS ON SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
		--										  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
		--										  SS.DocRowNo = D.DocRowNo
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

	-- to allocate more than 4000 characters its required
	set @StrFields1 = ''
	set @StrFields2 = ''
	
	IF (@Grouped = 0) 
	Begin
		SET @StrFields1 = @StrFields1 + 'H.ProcessID, H.ProcessNo, H.VchDate DocDate,H.DocDate as DocDate0,D.StoreID,D.StoreID2,''' + @BaseDate + ''' CurrDate,D.VirtualQuantity,
		H.TaxOverWorthCost,H.TollOverWorthCost,D.GoodsID,[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LanguageID)) + ') GoodsName, IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, 
		H.TransportationCost,H.IAToll,H.IATollCod,H.TaxCost,D.AcntCode,F.AcntName, [pub].[funGetCustomerKindID] (D.AcntCode) As CustomerKindID,' + 
		Case When @CountCustomerKind > 0 Then ' IsNull(DS.CDescription, '''')' Else ' D.GoodsID' End + ' As CKDescription, 
		F.EconomicalCode,F.Address1,F.Address2,' + @DisH1 + ',' + @DisH2 + ',H.DiscountTaxOverWorth,
		pub.funFarsiDateDiff(''Day'',''' + @BaseDate + ''',D.DocDate) DateDuration,IsNull(F.Tel,'''') Tel,D.GoodsQuantity,D.GoodsPrice,D.SubUnitPrice,
		D.AtomAmount OverloadAmount,H.DocDesc,D.DescDtl,H.VisitorAcntCode,pub.GetCodeName(H.VisitorAcntCode,' + @LangID + ') VisitorAcntName,
		H.AgreeNo,D.SubUnitID,D.SubUnitQuantity,inv.UQ(D.GoodsID,D.SubUnitID) SubQuantity,H.OtherCostAcntCode,H.OtherIncomeAcntCode, cast(''' + @StoreVar1 + ''' as nvarchar(50)) as StoreVar1Text, cast(''' + @StoreVar2 + ''' as nvarchar(50)) as StoreVar2Text,
		H.OtherCost,H.OtherIncome,H.TransportationIncome,H.TransportationIncomeAcntCode,
		Case When D.SaleTypeID <> '''' Then D.SaleTypeID Else H.SaleTypeID End As SaleTypeID,
		Case When O.SaleTypeName <> '''' Then O.SaleTypeName Else OH.SaleTypeName End As SaleTypeName,
		pub.funGetLocationName(F.LocationID,1) LocationName,R.AreaCode, H.CCNo, H.CCDiscount, H.CCPrivilege,
		Case When H.CCNo = '''' Or H.CCNo Is Null Then 0 Else 
		(Select [lyl].[funCustomerDefaultPrivilege] (H.CCNo, H.DocDate)) + 
		        (Select IsNull(Sum(CCPrivilege),0) From inv.tblStorageDocsHdr Where CCNo = H.CCNo And ProcessID = 60) - 
        (Select IsNull(Sum(CCPrivilege),0) From inv.tblStorageDocsHdr Where CCNo = H.CCNo And ProcessID = 55) End As SumCCPrivilege,
		F.ZipCode,F.CustomerFirstName+'' ''+F.CustomerLastName CustomerName,F.CompanyRegisterNo,F.NationalIDNumber,H.PackingCost,F.OrganzationName,
		H.DiscountPercent,H.VchNo,EarnestMoney,S.ExtraField1,S.ExtraField2,S.ExtraField3,S.ExtraField4,S.ExtraField5,S.TechnicalSpecifications,H.TransporterID,N.TransporterName,P.StoreName,
		pub.UN(H.SessionNo) UserName,pub.UN(H.SessionNo) UserName1,pub.UN(H.SessionNo2) UserName2,pub.UN(H.SessionNo3) UserName3,pub.UN(H.SessionNo4) UserName4,pub.UN(H.SessionNo5) UserName5,
		H.DocStep,H.Amount,F.Mobile,T.UnitName,W.UnitName UnitName2,U.UnitName UnitName3,W.UnitName UnitNameX,' + @DisH3 + ',V.UnitValue,V.MainUnitValue,case when (V.MainUnitValue<>0) then V.UnitValue/V.MainUnitValue else 1 end UnitScale,
		case when H.DestinationAddress <> '''' THEN H.DestinationAddress ELSE H.Address END DestinationAddress,F.Sequence,D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,isnull(O2.DaysNo,0) DaysNo, D.StoreVariable1, D.StoreVariable2,
		H.BaseDistributionFiscalYear,H.BaseDistributionSerialNo,S.TechnicalNo,' + @DisD1 + ',S.GoodsLength,S.GoodsWidth,S.GoodsHeight,' + @DisH4 + ',H.OwnerDocNo,
		D.BatchNo,L2.LocationName LocationName2,D.DiscountPercentDtl,D.VisitorPercent,inv.UQ2(D.GoodsID,D.SubUnitID) SQ2,H.CashAmount,H.ChequeAmount,H.ComssionCostPrice,H.BasculePrice,H.LaborPrice,H.TransportPrice,
		IsNull((Select Sum(Amount) From trs.tblPayDtl Where ProcessID = 13 And DebitCode = D.AcntCode
				Group By ProcessID, DebitCode),0) As SumReceivableReturn,
		IsNull((Select Top 1 SS.ProductSerialID From inv.tblStorageDocsSerials SS 
		Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
			  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
			  SS.DocRowNo = D.DocRowNo),0) As ProductSerialID, '
		SET @StrFields2 = @StrFields2 + '												
		IsNull((Select Top 1 SS.BatchNo From inv.tblStorageDocsSerials SS 
		Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
			  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
			  SS.DocRowNo = D.DocRowNo),'''') As PrdBatchNo,
		IsNull((Select Top 1 SS.ExpireDate From inv.tblStorageDocsSerials SS 
		Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
			  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
			  SS.DocRowNo = D.DocRowNo),'''') As PrdExpireDate,	
		Cast(' + @SettleStr + ' as bit) IsSettle,' + str(@svcCount) + ' SvcCount,
		H.TransporterID2,VF.Tel VisitorTel,cast(' + str(@fval) + ' as float) VATPercent,
		Cast(' + Str(@IATollPercent) + ' As Float) IATollPercent,
		F.AsnafID,D.CurrencyAmount,F.OtherTels,F.NationalIdentity,
		S1.UserSign as UserSignature1, S2.UserSign as UserSignature2, S3.UserSign as UserSignature3, S4.UserSign as UserSignature4,
		S5.UserSign as UserSignature5, F.Fax,D.ConstText1,D.ConstText2,D.ConstText3,D.ConstText4,H.C1,H.C2,H.C3,H.C4,H.C5,H.C6,H.C7, H.C8, H.C9, H.C10, H.C11, H.C12,
		D.Var1,D.Var2,D.Var3,D.Var4,(DR.FirstName +' + '''-''' + '+ DR.LastName)as DriveName, 
		H.DistributerID1, H.DistributerID2,
		prs.funGetPersonnelName(H.DistributerID1,' + @LangID + ') DistributerName1,
		prs.funGetPersonnelName(H.DistributerID2,' + @LangID + ') DistributerName2
		'
	End
	ELSE
	Begin
		SET @StrFields1 = @StrFields1 + 'H.ProcessID, H.ProcessNo, H.VchDate AS DocDate,H.DocDate as DocDate0,D.StoreID,D.StoreID2,''' + @BaseDate + ''' CurrDate,D.VirtualQuantity,
		H.TaxOverWorthCost,H.TollOverWorthCost,D.GoodsID,[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LanguageID)) + ') GoodsName, IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,
		H.TransportationCost,H.IAToll,H.IATollCod, H.TaxCost,D.AcntCode,F.AcntName, 
		[pub].[funGetCustomerKindID] (D.AcntCode) As CustomerKindID,' + 
		Case When @CountCustomerKind > 0 Then ' IsNull(DS.CDescription, '''')' Else ' D.GoodsID' End + ' As CKDescription, 
		F.EconomicalCode,'''' Address1, '''' Address2,' + @DisH1 + ',' + @DisH2 + ',H.DiscountTaxOverWorth,
		pub.funFarsiDateDiff(''Day'',''' + @BaseDate + ''',D.DocDate) DateDuration,IsNull(F.Tel,'''') Tel,D.GoodsQuantity,D.GoodsPrice,D.SubUnitPrice,
		D.AtomAmount OverloadAmount,H.DocDesc,'''' DescDtl,H.VisitorAcntCode,pub.GetCodeName(H.VisitorAcntCode,' + @LangID + ') VisitorAcntName,
		H.AgreeNo,D.SubUnitID,0 SubUnitQuantity,inv.UQ(D.GoodsID,D.SubUnitID) SubQuantity,H.OtherCostAcntCode,H.OtherIncomeAcntCode, ''' + @StoreVar1 + ''' as StoreVar1Text, ''' + @StoreVar2 + ''' as StoreVar2Text,
		H.OtherCost,H.OtherIncome,H.TransportationIncome,H.TransportationIncomeAcntCode, H.CCNo, H.CCDiscount, H.CCPrivilege,
		Case When H.CCNo = '''' Or H.CCNo Is Null Then 0 Else 
		(Select [lyl].[funCustomerDefaultPrivilege] (H.CCNo, H.DocDate)) + 
		        (Select IsNull(Sum(CCPrivilege),0) From inv.tblStorageDocsHdr Where CCNo = H.CCNo And ProcessID = 60) - 
        (Select IsNull(Sum(CCPrivilege),0) From inv.tblStorageDocsHdr Where CCNo = H.CCNo And ProcessID = 55) End As SumCCPrivilege,
		Case When D.SaleTypeID <> '''' Then D.SaleTypeID Else H.SaleTypeID End As SaleTypeID,
		Case When O.SaleTypeName <> '''' Then O.SaleTypeName Else OH.SaleTypeName End As SaleTypeName,
		'''' LocationName, '''' AreaCode,
		F.ZipCode,F.CustomerFirstName+'' ''+F.CustomerLastName CustomerName,F.CompanyRegisterNo,F.NationalIDNumber,H.PackingCost,F.OrganzationName,
		H.DiscountPercent,H.VchNo,EarnestMoney,S.ExtraField1,S.ExtraField2,S.ExtraField3,S.ExtraField4,S.ExtraField5,S.TechnicalSpecifications,H.TransporterID,N.TransporterName,P.StoreName,
		pub.UN(H.SessionNo) UserName,pub.UN(H.SessionNo) UserName1,pub.UN(H.SessionNo2) UserName2,pub.UN(H.SessionNo3) UserName3,pub.UN(H.SessionNo4) UserName4,pub.UN(H.SessionNo5) UserName5,
		H.DocStep,H.Amount,F.Mobile,T.UnitName,W.UnitName UnitName2,U.UnitName UnitName3,W.UnitName UnitNameX,' + @DisH3 + ',V.UnitValue,V.MainUnitValue,case when(V.MainUnitValue<>0)then V.UnitValue/V.MainUnitValue else 1 end UnitScale,
		case when H.DestinationAddress <>'''' THEN H.DestinationAddress ELSE H.Address END DestinationAddress,F.Sequence,D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,isnull(O2.DaysNo,0) DaysNo, D.StoreVariable1, D.StoreVariable2,
		H.BaseDistributionFiscalYear,H.BaseDistributionSerialNo,S.TechnicalNo,' + @DisD1 + ',S.GoodsLength,S.GoodsWidth,S.GoodsHeight,' + @DisH4 + ',H.OwnerDocNo,
		D.BatchNo,L2.LocationName LocationName2,D.DiscountPercentDtl,D.VisitorPercent,0 SQ2,H.CashAmount,H.ChequeAmount,H.ComssionCostPrice,H.BasculePrice,H.LaborPrice,H.TransportPrice,
	    IsNull((Select Sum(Amount) From trs.tblPayDtl Where ProcessID = 13 And DebitCode = D.AcntCode 
				Group By ProcessID, DebitCode),0) As SumReceivableReturn,
		IsNull((Select Top 1 SS.ProductSerialID From inv.tblStorageDocsSerials SS Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
				SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
				SS.DocRowNo = D.DocRowNo),0) As ProductSerialID, '
		SET @StrFields2 = @StrFields2 + '				
		IsNull((Select Top 1 SS.BatchNo From inv.tblStorageDocsSerials SS 
		Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
			  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
			  SS.DocRowNo = D.DocRowNo),'''') As PrdBatchNo,
		IsNull((Select Top 1 SS.ExpireDate From inv.tblStorageDocsSerials SS 
		Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
			  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
			  SS.DocRowNo = D.DocRowNo),'''') As PrdExpireDate,	
		Cast(' + @SettleStr + ' as bit) IsSettle,' + str(@svcCount) + ' SvcCount,
		H.TransporterID2,VF.Tel VisitorTel,cast(' + str(@fval) + ' as float) VATPercent,
		Cast(' + Str(@IATollPercent) + ' As Float) IATollPercent,
		F.AsnafID,D.CurrencyAmount,F.OtherTels,F.NationalIdentity,
		S1.UserSign as UserSignature1, S2.UserSign as UserSignature2, S3.UserSign as UserSignature3, S4.UserSign as UserSignature4,
		S5.UserSign as UserSignature5, F.Fax,D.ConstText1,D.ConstText2,D.ConstText3,D.ConstText4,H.C1,H.C2,H.C3,H.C4,H.C5,H.C6,H.C7, H.C8, H.C9, H.C10, H.C11, H.C12,
		D.Var1,D.Var2,D.Var3,D.Var4,(DR.FirstName +' + '''-''' + '+ DR.LastName)as DriveName, 
		H.DistributerID1, H.DistributerID2,
		prs.funGetPersonnelName(H.DistributerID1,' + @LangID + ') DistributerName1,
		prs.funGetPersonnelName(H.DistributerID2,' + @LangID + ') DistributerName2		
       '
	End
	
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

		IF (@CalcSalesInRemain = 1)
			Begin
				SET @StrFields2 = @StrFields2 + ',
				(SELECT	IsNull(Sum(Debit-Credit),0) Debit 
				 FROM	acc.tblVoucherDtl M 
				 INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo=M.SerialNo
				 INNER join acc.tblAcnt b
				 ON b.PartNumber= 1 and SUBSTRING(M.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode)=' + LTrim(RTrim(STR(@Part1End))) + '
				 WHERE  b.AcntType NOT IN (91,92) AND M.VchKind<>0 AND VH.DocRegisterState>0 AND (' + @Eqal + ') AND 
						(M.DocDate<=H.VchDate AND
						 Not 
						(M.DocDate=H.VchDate AND M.SourceProcessID in(60)
						 AND M.SourceProcessNo=H.ProcessNo AND 
						 M.SourceFiscalYear=H.FiscalYear 
						 AND M.SourceSerialNo=H.SerialNo
						 ))
				) DebitRemain '
			End
		Else
			Begin
				SET @StrFields2 = @StrFields2 + ',
				(SELECT	IsNull(Sum(Debit-Credit),0) Debit 
				FROM	acc.tblVoucherDtl M 
				INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo=M.SerialNo
				INNER join acc.tblAcnt b
				ON b.PartNumber= 1 and SUBSTRING(M.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode)=' + LTrim(RTrim(STR(@Part1End))) + '
				WHERE  b.AcntType NOT IN (91,92) AND M.VchKind<>0 AND VH.DocRegisterState>0 AND (' + @Eqal + ') AND 
						(M.DocDate<=H.VchDate AND
						 Not 
						(M.DocDate=H.VchDate AND M.SourceProcessID in(60)
						 --AND M.SourceProcessNo=H.ProcessNo AND 
						 --M.SourceFiscalYear=H.FiscalYear 
						 --AND M.SourceSerialNo=H.SerialNo
						 ))
				) DebitRemain '	
			End
	End
	Else
		SET @StrFields2 = @StrFields2 + ',0 AS DebitRemain '
	
		if (@ShowRemainAndDay=1 )
		SET @StrFields2 = @StrFields2 + ',Convert(varchar(10),sal.funGetRemainSal_InvoicesDate(H.ProcessID ,H.ProcessNo,  	,H.FiscalYear  	,H.SerialNo)) as DayRemain
										  sal.funGetRemainSal_InvoicesRemain(H.ProcessID ,H.ProcessNo ,H.FiscalYear ,H.SerialNo) as PayRemain'
		
		ELSE
		SET @StrFields2 = @StrFields2 + ',Convert(varchar(10),'''') as DayRemain ,0 as PayRemain'
		
		SET @StrFields2 = @StrFields2 + ',SettlementDate'
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
		
		SELECT	D.FiscalYear FY,D.SerialNo SN,D.DocRowNo RN,' + @StrFields1 
		Print @StrSelectA;
		
		SET @StrSelectB = @StrFields2 + '
		INTO	##tblAll
		FROM	' + @StrFrom + '
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

		Print @StrSelectB;

		SET @StrSelectA = @StrSelectA + @StrSelectB
		--Print @StrSelectA;
		EXEC sp_executesql @StrSelectA;

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

		--SELECT DISTINCT FY FiscalYear,SN SerialNo,0 AS DocRowNo,A.*,CC.ChequesRemainAmount
		SELECT FY FiscalYear,SN SerialNo,0 AS DocRowNo,A.*,CC.ChequesRemainAmount,
			   Cast(''0'' AS VarChar(20)) AS DebitRemainStr
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
		IF (@RowsCount = 0) 
		Begin
			SET @StrSelectA = '
			SELECT D.*,Cast(DebitRemain AS VarChar(20)) AS DebitRemainStr, CC.ChequesRemainAmount
			FROM
			(
				SELECT	D.FiscalYear,D.SerialNo,D.DocRowNo,D.FiscalYear FY,D.SerialNo SN,D.DocRowNo RN,' + @StrFields1 + @StrFields2 +'
				FROM	' + @StrFrom + '
				WHERE	' + @StrWhere + '
			) D 
			LEFT JOIN #tbl_Sal_Invoices_Cheques CC on CC.AcntCode=D.AcntCode
			ORDER BY D.DocRowNo '

			PRINT @StrSelectA;
			PRINT '=========='
			PRINT @StrFrom;
			PRINT @StrWhere;
			EXEC sp_executesql @StrSelectA;
			RETURN
 		End

		-- S E L E C T ----------------------------------------------------------------------------

		CREATE TABLE #tblInvoices
		(
			FiscalYear	SmallInt,
			SerialNo	Int,
			MaxRowNo	Int
		);

		SET @StrSelectA = '
		INSERT INTO #tblInvoices(FiscalYear,SerialNo,MaxRowNo)
		SELECT D.FiscalYear,D.SerialNo,Max(D.DocRowNo)
		FROM  ' + @StrFrom + '
		WHERE ' + @StrWhere + '
		GROUP BY D.FiscalYear,D.SerialNo'

		PRINT @StrSelectA;
		EXEC sp_executesql @StrSelectA;

		CREATE TABLE #tblMy
		(
			FiscalYear	SmallInt,
			SerialNo	Int,
			DocRowNo	Int
		);

		SET @StrSelectA = '
		INSERT INTO #tblMy(FiscalYear,SerialNo,DocRowNo)
		SELECT D.FiscalYear,D.SerialNo,D.DocRowNo
		FROM ' + @StrFrom + '
		WHERE ' + @StrWhere 

		PRINT @StrSelectA;
		EXEC sp_executesql @StrSelectA;

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
		
		SET @StrSelect1 = '
		SELECT	D.FiscalYear FY,D.SerialNo SN,D.DocRowNo RN,' + @StrFields1 + @StrFields2 + '
		INTO  #tblAll ' 
		
		PRINT @StrSelect1;
		
		SET @StrSelect2 = '
		FROM  ' + @StrFrom + '
		WHERE ' + @StrWhere + ';
		
		SELECT	R.FiscalYear,R.SerialNo,R.DocRowNo,D.*,Cast(DebitRemain AS VarChar(20)) AS DebitRemainStr, CC.ChequesRemainAmount
		Into #tblAll2
		FROM	(#tblMy R LEFT JOIN #tblAll D ON (R.FiscalYear=D.FY) AND (R.SerialNo=D.SN) AND (R.DocRowNo=D.RN)) 
		Left Join #tbl_Sal_Invoices_Cheques CC on CC.AcntCode=D.AcntCode
		ORDER BY DocRowNo 
		
		Update  #tblAll2
		Set VATPercent = cast(' + str(@fval) + ' as float)
		Where VATPercent  is null
		
		Select *
		From #tblAll2 '
		PRINT @StrSelect2;

        SET @StrSelectA = @StrSelect1 + @StrSelect2
        
		--PRINT @StrSelectA;
		EXEC sp_executesql @StrSelectA;
	--------------------------------------------------------------------------------------
	END
End
GO
