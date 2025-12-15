USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1393/02/22
-- Viewed By	 : 
-- Last Modified :  
-- Modifier		 : TakroSystem\Reza NP 
-- Description	 : چاپ پیش فاکتورهای فروش
-- ==============================================
Create PROCEDURE [sal].[RptSal_Invoices_PreSale]
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
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @LanguageID TinyInt;
DECLARE @AcntLast	NVarChar(20);
DECLARE @BaseDate	NVarChar(10);
DECLARE @StrFields 	NVarChar(4000);
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
DECLARE @SettleStr	char(1);
DECLARE @SvcFY		int;
DECLARE @SvcSN		int;
declare @SessionNo  int;
declare @ReportID   int;

DECLARE @fval float;
DECLARE @sval varchar(50);

DECLARE @StoreVar1 varchar(50);
DECLARE @StoreVar2 varchar(50);
declare @db_0000   nvarchar(50)
declare @ShowDiscount2	Bit = 0
DECLARE @TaxOverWorthBeforDiscount  bit;
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	--============== 
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

	SELECT @TaxOverWorthBeforDiscount = SettingValue from pub.tblSettings where SettingKey = 'TaxOverWorthBeforDiscount'

	-- I N I T -----------------------------------------------------------------------------------
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
	SET @LangID = LTrim(Str(@LanguageID));

	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	SET @TransID = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @Remain1 = LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @Remain2 = LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @Remain3 = LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @Remain4 = LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @DistInf = LTrim(pub.funSplitString(@ExtraParams, '@', 8));

	SET @Dist0	 = LTrim(pub.funSplitString(@DistInf, '#', 1));
	SET @Dist1	 = LTrim(pub.funSplitString(@DistInf, '#', 3));
	SET @Dist2	 = LTrim(pub.funSplitString(@DistInf, '#', 5));
	SET @Disti0	 = LTrim(pub.funSplitString(@DistInf, '#', 7));
	SET @Disti1	 = LTrim(pub.funSplitString(@DistInf, '#', 10));
	SET @Disti2	 = LTrim(pub.funSplitString(@DistInf, '#', 12));

	SET @SvcFY = LTrim(pub.funSplitString(@ExtraParams, '@', 15));
	SET @SvcSN = LTrim(pub.funSplitString(@ExtraParams, '@', 16));
	
	SET @Customer1 = LTrim(pub.funSplitString(@ExtraParams, '@', 17));
	SET @Customer2 = LTrim(pub.funSplitString(@ExtraParams, '@', 18));
	SET @Customer3 = LTrim(pub.funSplitString(@ExtraParams, '@', 19));
	SET @Customer4 = LTrim(pub.funSplitString(@ExtraParams, '@', 20));
	
	SET @SessionNo = LTrim(pub.funSplitString(@ExtraParams, '@', 21));
	SET @ReportID  = LTrim(pub.funSplitString(@ExtraParams, '@', 22));
	SET @IsCurrency= LTrim(pub.funSplitString(@ExtraParams, '@', 23));
	SET @ShowDiscount2= LTrim(pub.funSplitString(@ExtraParams, '@', 24));
	
	create table #tbl_Invoice_Signatures
	(
		UserID	int,
		UserSign	image
	);
	
	--set @StrSelect = '
	--insert into #tbl_Invoice_Signatures(UserID, UserSign)
	--select UserID, UserSignature
	--from ' + ltrim(rtrim(@db_0000)) + '.usr.tblUsers U '
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
	----------------------------------------------------------------------------------------------

	-- W H E R E ---------------------------------------------------------------------------------
	SET @StrWhere = ' D.ProcessID=240 AND D.ProcessNo=' + LTrim(Str(@ProcessNo))

	--If (@Dist0 <> 'null') and (@Dist0 <> '')
	--	SET @StrWhere = @StrWhere + ' AND H.DriverID=''' + LTrim(@Dist0) + ''''
	--If (@Dist1 <> 'null') and (@Dist1 <> '')
	--	SET @StrWhere = @StrWhere + ' AND H.DistributerID1=''' + LTrim(@Dist1) + ''''
	--If (@Dist2 <> 'null') and (@Dist2 <> '')
	--	SET @StrWhere = @StrWhere + ' AND H.DistributerID2=''' + LTrim(@Dist2) + ''''

	--If (@Disti0 <> 'null') and (@Disti0 <> '')
	--	SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID=' + LTrim(@Disti0) 
	--If (@Disti1 <> 'null') and (@Disti1 <> '')
	--	SET @StrWhere = @StrWhere + ' AND H.BaseDistributionSerialNo>=' + LTrim(@Disti1) 
	--If (@Disti2 <> 'null') and (@Disti2 <> '')
	--	SET @StrWhere = @StrWhere + ' AND H.BaseDistributionSerialNo<=' + LTrim(@Disti2) 

	IF (@Customer1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer1, 'D.AcntCode')
	IF (@Customer2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer2, 'D.AcntCode')
	IF (@Customer3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer3, 'D.AcntCode')
	IF (@Customer4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Customer4, 'D.AcntCode')

	If (@FiscalYearFrom	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear>' + LTrim(Str(@FiscalYearFrom)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalYearFrom)) + ' AND D.SerialNo>=' + LTrim(Str(@SerialNoFrom)) + ')) '
	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear<' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo<=' + LTrim(Str(@SerialNoTo)) + ')) '

	--IF (@TransID <> '0') 
	--	SET @StrWhere = @StrWhere + ' AND H.TransporterID=''' + @TransID + ''''
		
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

	--If (@SaleTypeID Is Not Null)
	--	SET @StrWhere = @StrWhere + ' AND D.SaleTypeID=''' + @SaleTypeID + ''''

	-------------------------------------------------------------------------------------------
	if (@IsCurrency = 1)
	begin
		set @SH = 'sal.vwPreSaleHdr_Currency'
		set @SD = 'sal.vwPreSaleDtl_Currency'
		
	end
	else
	begin
		set @SH = 'inv.tblPreSaleHdr'
		set @SD = 'inv.tblPreSaleDtl'
	end
	
	SET @StrFrom = ltrim(@SD) + ' D 
			INNER JOIN ' + ltrim(@SH) + ' H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
			LEFT JOIN sal.tblSaleTypes O2 ON D.SaleTypeID=O2.SaleTypeID
			LEFT JOIN sal.tblSaleTypesDtl O ON D.SaleTypeID=O.SaleTypeID
			LEFT JOIN inv.tblStoresDtl P ON P.StoreID=H.StoreID
			OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
			OUTER APPLY acc.funGetCodeInfo(H.VisitorAcntCode) VF
			LEFT JOIN pub.tblLocationsDtl Q ON Q.LocationID=F.LocationID
			LEFT JOIN pub.tblLocations R ON R.LocationID=Q.LocationID 
			INNER JOIN inv.tblGoods S ON S.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND S.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			LEFT JOIN inv.tblUnitsDtl T ON T.UnitID=S.UnitID
			LEFT JOIN inv.tblSubUnitsDtl V ON V.GoodsID=D.GoodsID AND V.ShowInInvoice=1
			LEFT JOIN inv.tblUnitsDtl W ON W.UnitID=V.SubUnitID'
				
	-------------------------------------------------------------------------------------------
	declare @svcCount int;
	set @svcCount = 0;
	
	if (@SvcSN > 0)
		select @svcCount = COUNT(*)
		from acc.tblServicesDtl
		where (FiscalYear = @SvcFY) and (SerialNo = @SvcSN)
		
	if (@ShowDiscount = 1 or @ShowDiscount2 = 1)
	begin
		set @DisH1 = 'H.Discount'
		set @DisH2 = 'H.Discount2 Discount2 '
		set @DisH3 = 'CAST(0 As Float) TotalLineDiscount'
		set @DisH4 = 'CAST(0 As Float) AfterSaleDiscount'
		set @DisD1 = 'D.Discount As DiscountDtl'
	end
	else
	begin
		set @DisH1 = 'CAST(0 As Float) Discount'
		set @DisH2 = 'CAST(0 As Float) Discount2'
		set @DisH3 = 'CAST(0 As Float) TotalLineDiscount'
		set @DisH4 = 'CAST(0 As Float) AfterSaleDiscount'
		set @DisD1 = 'CAST(0 As Float) DiscountDtl'
	end;

	IF (@Grouped = 0) 
		SET @StrFields = ' H.DocDate DocDate,H.DocDate as DocDate0,D.StoreID, H.TaxOverWorthCost,H.TollOverWorthCost,
					D.GoodsID,[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
					IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,H.TransportationCost,
					H.TaxCost,D.AcntCode,F.AcntName,F.EconomicalCode,F.Address1,F.Address2,' + @DisH1 + ',' + @DisH2 + ',
					pub.funFarsiDateDiff(''Day'',''' + @BaseDate + ''',D.DocDate) DateDuration,IsNull(F.Tel,'''') Tel,D.GoodsQuantity,D.SubUnitQuantity,' + str(@TaxOverWorthBeforDiscount) +' as TaxOverWorthBeforDiscount,D.GoodsAmount,
					H.DocDesc,D.DescDtl,H.VisitorAcntCode,pub.GetCodeName(H.VisitorAcntCode,' + @LangID + ') VisitorAcntName,
					H.OtherCostAcntCode,H.OtherIncomeAcntCode, cast(''' + @StoreVar1 + ''' as nvarchar(50)) as StoreVar1Text, cast(''' + @StoreVar2 + ''' as nvarchar(50)) as StoreVar2Text,
					H.OtherCost,H.OtherIncome,H.TransportationIncome,H.TransportationIncomeAcntCode,D.SaleTypeID,O.SaleTypeName,pub.funGetLocationName(F.LocationID,1) LocationName,R.AreaCode,
					F.ZipCode,F.CustomerFirstName+'' ''+F.CustomerLastName CustomerName,F.CompanyRegisterNo,F.NationalIDNumber,H.PackingCost,F.OrganzationName,
					H.DiscountPercent, D.DiscountPercent as DiscountPercentDtl, H.VchNo,S.ExtraField1,S.ExtraField2,S.ExtraField3,S.ExtraField4,S.ExtraField5,S.TechnicalSpecifications,P.StoreName,
					pub.UN(H.SessionNo) UserName,
					H.DocStep,F.Mobile,T.UnitName,W.UnitName UnitName2,W.UnitName UnitNameX,' + @DisH3 + ',V.UnitValue,V.MainUnitValue,case when (V.MainUnitValue<>0) then V.UnitValue/V.MainUnitValue else 1 end UnitScale,
					F.Sequence,isnull(O2.DaysNo,0) DaysNo,
					S.TechnicalNo,' + @DisD1 + ', D.Discount As DiscountDtl2,S.GoodsLength,S.GoodsWidth,S.GoodsHeight,' + @DisH4 + ', 
					Cast(' + @SettleStr + ' as bit) IsSettle,' + str(@svcCount) + ' SvcCount, VF.Tel VisitorTel,
					case when H.TaxOverWorthCost=0 then 0 else 	Cast(' + ltrim(rtrim(str(@fval))) + ' as float) end  VATPercent, F.AsnafID,
					F.OtherTels,F.NationalIdentity, F.Fax, H.DocDesc2 
					,ConstText1,ConstText2,ConstText3,ConstText4,Var1,Var2,Var3,Var4,TaxOverWorthCostDtl,TollOverWorthCostDtl
					, (  Select count(*)  from inv.tblPreSaleDtl b where   D.ProcessID = b.ProcessID And D.ProcessNo = b.ProcessNo And D.FiscalYear = b.FiscalYear And D.SerialNo = b.SerialNo and b.TaxOverWorthCostDtl>0) TaxIslineModel 
		'
	ELSE
		SET @StrFields = ' H.VchDate AS DocDate,H.DocDate as DocDate0,D.StoreID,D.StoreID2,''' + @BaseDate + ''' CurrDate,D.VirtualQuantity,
					H.TaxOverWorthCost,H.TollOverWorthCost,D.GoodsID,[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
					IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,H.TransportationCost, H.TaxCost,D.AcntCode,F.AcntName,
					F.EconomicalCode,'''' Address1, '''' Address2,' + @DisH1 + ',' + @DisH2 + ',H.DiscountTaxOverWorth,
					pub.funFarsiDateDiff(''Day'',''' + @BaseDate + ''',D.DocDate) DateDuration,IsNull(F.Tel,'''') Tel,D.GoodsQuantity,D.SubUnitQuantity,' + str(@TaxOverWorthBeforDiscount) +' as TaxOverWorthBeforDiscount,D.GoodsAmount,
					D.AtomAmount OverloadAmount,H.DocDesc,'''' DescDtl,H.VisitorAcntCode,pub.GetCodeName(H.VisitorAcntCode,' + @LangID + ') VisitorAcntName,
					H.AgreeNo,D.SubUnitID,0 SubUnitQuantity,inv.UQ(D.GoodsID,D.SubUnitID) SubQuantity,H.OtherCostAcntCode,H.OtherIncomeAcntCode, ''' + @StoreVar1 + ''' as StoreVar1Text, ''' + @StoreVar2 + ''' as StoreVar2Text,
					H.OtherCost,H.OtherIncome,H.TransportationIncome,H.TransportationIncomeAcntCode,D.SaleTypeID,O.SaleTypeName,'''' LocationName, '''' AreaCode,
					F.ZipCode,F.CustomerFirstName+'' ''+F.CustomerLastName CustomerName,F.CompanyRegisterNo,F.NationalIDNumber,H.PackingCost,F.OrganzationName,
					H.DiscountPercent,H.VchNo,EarnestMoney,S.ExtraField1,S.ExtraField2,S.ExtraField3,S.ExtraField4,S.ExtraField5,S.TechnicalSpecifications,P.StoreName,
					pub.UN(H.SessionNo) UserName,pub.UN(H.SessionNo) UserName1,pub.UN(H.SessionNo2) UserName2,pub.UN(H.SessionNo3) UserName3,pub.UN(H.SessionNo4) UserName4,pub.UN(H.SessionNo5) UserName5,
					H.DocStep,H.Amount,F.Mobile,T.UnitName,W.UnitName UnitName2,U.UnitName UnitName3,W.UnitName UnitNameX,' + @DisH3 + ',V.UnitValue,V.MainUnitValue,case when(V.MainUnitValue<>0)then V.UnitValue/V.MainUnitValue else 1 end UnitScale,
					H.DestinationAddress,F.Sequence,D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,isnull(O2.DaysNo,0) DaysNo, D.StoreVariable1, D.StoreVariable2,
					H.BaseDistributionFiscalYear,H.BaseDistributionSerialNo,S.TechnicalNo,' + @DisD1 + ',S.GoodsLength,S.GoodsWidth,S.GoodsHeight,' + @DisH4 + ',H.OwnerDocNo,
					D.BatchNo,L2.LocationName LocationName2,DiscountPercentDtl,0 SQ2,H.CashAmount,H.ChequeAmount,H.ComssionCostPrice,H.BasculePrice,H.LaborPrice,H.TransportPrice,
					cast(' + @SettleStr + ' as bit) IsSettle,' + ltrim(rtrim(str(@svcCount))) + ' SvcCount,VF.Tel VisitorTel,
					case when H.TaxOverWorthCost=0 then 0 else cast(' + ltrim(rtrim(str(@fval))) + ' as float) end VATPercent,F.AsnafID,
					F.OtherTels,F.NationalIdentity,F.Fax , H.DocDesc2
					,ConstText1,ConstText2,ConstText3,ConstText4,Var1,Var2,Var3,Var4,TaxOverWorthCostDtl,TollOverWorthCostDtl
					, (  Select count(*)  from inv.tblPreSaleDtl b where   D.ProcessID = b.ProcessID And D.ProcessNo = b.ProcessNo And D.FiscalYear = b.FiscalYear And D.SerialNo = b.SerialNo and b.TaxOverWorthCostDtl>0) TaxIslineModel 
				'

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

		SET @StrFields = @StrFields + ',
		(SELECT	IsNull(Sum(Debit-Credit),0) Debit 
		FROM	acc.tblVoucherDtl M INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo=M.SerialNo
		WHERE   M.VchKind<>0 AND VH.DocRegisterState>0 AND (' + @Eqal + ') AND 
				(M.DocDate<=H.VchDate AND Not (M.DocDate=H.VchDate AND M.SourceProcessID in(90,95) AND M.SourceProcessNo=H.ProcessNo AND M.SourceFiscalYear=H.FiscalYear AND M.SourceSerialNo>=H.SerialNo))
		) DebitRemain'
	End
	Else
		SET @StrFields = @StrFields + '			,0 AS DebitRemain '

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

		SELECT	D.FiscalYear FY,D.SerialNo SN,D.DocRowNo RN,' + @StrFields + '
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
					SELECT	FY,SN,GoodsID,GoodsAmount,Sum(GoodsQuantity) GoodsQuantity
					FROM	#tblTemp 
					GROUP BY FY,SN,GoodsID,GoodsAmount
					HAVING	COUNT(GoodsID)>=1
				) T ON  A.FY=T.FY AND A.SN=T.SN AND A.GoodsID=T.GoodsID AND A.GoodsAmount=T.GoodsAmount 

		-- dont remove DISTINCT keyword & extra fields   

		SELECT DISTINCT FY FiscalYear,SN SerialNo,0 AS DocRowNo,*
		FROM ##tblAll 

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
			SELECT D.*,Cast(DebitRemain AS VarChar(20)) AS DebitRemainStr
			FROM
			(SELECT	D.FiscalYear,D.SerialNo,D.DocRowNo,D.FiscalYear FY,D.SerialNo SN,D.DocRowNo RN,' + @StrFields + '
			FROM	' + @StrFrom + '
			WHERE	' + @StrWhere + '
			) D ORDER BY D.DocRowNo '

			PRINT @StrSelect;
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
		SELECT	D.FiscalYear FY,D.SerialNo SN,D.DocRowNo RN,' + @StrFields + '
		INTO	#tblAll
		FROM	' + @StrFrom + '
		WHERE	' + @StrWhere + ';

		SELECT	R.FiscalYear,R.SerialNo,R.DocRowNo,D.*,Cast(DebitRemain AS VarChar(20)) AS DebitRemainStr
		FROM	(#tblMy R 
				 LEFT JOIN #tblAll D ON (R.FiscalYear=D.FY) AND 
				(R.SerialNo=D.SN) AND (R.DocRowNo=D.RN)) 
				 ORDER BY DocRowNo '

		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
	--------------------------------------------------------------------------------------
	END
END
GO
