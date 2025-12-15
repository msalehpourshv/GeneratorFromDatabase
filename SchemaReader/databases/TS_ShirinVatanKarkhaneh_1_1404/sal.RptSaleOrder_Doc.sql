USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : ?
-- Viewed By	 : 
-- Last Modified : 1393/07/01
-- Last Modifier : TakroSystem\Hamid
-- Description   : برگ سفارش فروش
-- =============================================
--EXEC [sal].[RptSaleOrder_Doc] 180, 1, 96, 1, 96, 5, 0, 0, '1@1@1' 
Create PROCEDURE [sal].[RptSaleOrder_Doc]
	@ProcessID		Int = 180, -- Sale Order Process ID
	@ProcessNo		Int = Null,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@ShowTrsInfo	Bit = 0,
	@DocStep		Int = 0,
	@RepInfo		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
DECLARE @StrSelect1			NVarChar(Max);
DECLARE @StrSelect2			NVarChar(Max);
DECLARE @StrWhere			NVarChar(Max);

DECLARE @LangID				Char(1);
DECLARE @SessionNo			VarChar(10);
DECLARE @ReportID			VarChar(10);
DECLARE @Db0000				VarChar(50);

DECLARE @process_id			int;
DECLARE @process_no			int;
DECLARE @fiscalyear			int;
DECLARE @serial_no			int;
DECLARE @docrow_no			int;
DECLARE @goods_id			varchar(20);
DECLARE @goods_quantity		DECIMAL(28,9);
DECLARE @goods_price		float;
DECLARE @goods_price2		float;

SELECT @Db0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

DECLARE @strQuantity		 NVarchar(100);
DECLARE @strPrice			 NVarchar(100);
DECLARE @ShowContainerAndPos bit;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;	
	
	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods		tinyint,
			@str_GoodsSum	tinyint

	Select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	From pub.tblCodeLayer 
	Where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	Select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer 
	Where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo     = '1@1@1'
	IF (@DocStep < 1)			SET @DocStep	 = Null;
	IF (@ProcessNo	  Is Null)	SET @ProcessNo   = 1;
	IF (@ShowTrsInfo  Is Null)	SET @ShowTrsInfo = 0;

	IF (@FiscalYearFr  Is Null)	SET @SerialNoFr	  = Null;
	IF (@FiscalYearTo  Is Null)	SET @SerialNoTo	  = Null;
	IF (@SerialNoFr	   Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	   Is Null)	SET @FiscalYearTo = Null;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	DECLARE @MainAndSubUnit bit 
	SET @MainAndSubUnit	= pub.funSplitString(@RepInfo, '@', 7);	

	Set @ShowContainerAndPos = pub.funSplitString(@RepInfo, '@', 9);	

	--================================
	begin try
		drop table #tbl_goods
		drop table #tbl_result
	end try
	begin catch
	end catch

	Create Table #tbl_goods
	(
		ProcessID		Int, 
		ProcessNo		Int,
		FiscalYear		Int,	
		SerialNo		Int,
		DocRowNo		Int,
		AcntCode		Varchar(20),
		DocDate			char(10),
		GoodsID			Varchar(20),
		SubUnitID		Varchar(20),
		SubUnitQuantity	float,
		GoodsQuantity	float,		
		Price			float,
		Price2			float
	);

	-- ==========
	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	IF @QuantityDecimalsToForms>0
		SET		@QuantityDecimalsToForms = @QuantityDecimalsToForms - 1

	Create Table #tbl_result
	(
		ProcessID	Int, 
		ProcessNo	Int,
		FiscalYear	Int,	
		SerialNo	int,
		DocRowNo	int,
		GoodsID		varchar(20) collate arabic_cs_as not null,
		GoodsName	nvarchar(200) collate arabic_cs_as not null,
		SubUnitID		Varchar(20),
		SubUnitQuantity	float,
		GoodsQuantity	float,
		Price		float,
		Price2		float,
		UnitID1		varchar(20) collate arabic_cs_as not null,
		UnitName1	nvarchar(20) collate arabic_cs_as not null,
		Quantity1	DECIMAL(28,9),
		UnitID2		varchar(20) collate arabic_cs_as not null,
		UnitName2	nvarchar(20) collate arabic_cs_as not null,
		Quantity2	DECIMAL(28,9),
		UnitID3		varchar(20) collate arabic_cs_as not null,
		UnitName3	nvarchar(20) collate arabic_cs_as not null,
		Quantity3	DECIMAL(28,9),
		UnitID4		varchar(20) collate arabic_cs_as not null,
		UnitName4	nvarchar(20) collate arabic_cs_as not null,
		Quantity4	DECIMAL(28,9),
		Weight		float,
		Volume		float,
		BarCode		varchar(20) collate arabic_cs_as not null,
		
	)

	
	DECLARE @tbl_units As Table
	(
		unit_id		varchar(20) not null, 
		unit_name	nvarchar(200) not null, 
		unit_value	float not null,
		Mainunit_value	float not null,
		cnt	int not null
	);
	
	--================================
	CREATE TABLE #tbl_Invoice_Signatures
	(
		UserID   Int,
		UserSign Image
	);
	
	SET @StrSelect1 = '
	INSERT INTO #tbl_Invoice_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + LTrim(RTrim(@Db0000)) + '.usr.tblUsers U '
	
	Print @StrSelect1;
	Exec sp_executesql @StrSelect1;
	
	---------------------------------------------------------------------------
	--Set @StrWhere = '(D.AutoOrder = 0) and D.ProcessID = ' + Str(@ProcessID) + ' AND D.ProcessNo = ' + Str(@ProcessNo)
	Set @StrWhere = 'D.ProcessID = ' + Str(@ProcessID) + ' AND D.ProcessNo = ' + Str(@ProcessNo)

	If (@FiscalYearFr	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@DocStep Is Not Null) 
		Set @StrWhere = @StrWhere + ' AND (D.DocStep >= ' + Str(@DocStep) + ')'

	If (@DocStep Is Not Null) And (@DocStep <> 1)
		Set @strQuantity = 'D.ConfirmQuantity'
	Else
		Set @strQuantity = 'D.GoodsQuantity'
	
	--================================
	Set @StrSelect1 = '
		Insert Into #tbl_goods
		Select D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.AcntCode, D.DocDate, D.GoodsID, D.SubUnitID, D.SubUnitQuantity ,' + @strQuantity + ', ' + @strQuantity + ' * D.GoodsPrice, 
			   D.SubUnitQuantity2 * D.SubUnitPrice2
		From sal.tblSaleOrderDtl D
		Where  ' + @StrWhere + '
		--Group By D.SerialNo, D.DocRowNo, D.GoodsID'

	Print @StrSelect1;
	Exec sp_executesql @StrSelect1;
	

	 select AcntCode,DocDate,CAST(GoodsPrice as float) DebitRemain,CAST(GoodsPrice as float) DebitRemain1,CAST(GoodsPrice as float) UnReceiptRemain,CAST(GoodsPrice  as float)ReturnedRemain 
	 into   #tblAcntCodeRemain  from  sal.tblSaleOrderDtl where 1=0

	 insert into #tblAcntCodeRemain  
	 select Distinct AcntCode,DocDate,0,0,0 ,0   from #tbl_goods
	 	 
	update #tblAcntCodeRemain
	set 	DebitRemain=acc.funAcntDebitRemainFull(AcntCode,DocDate) ,
			DebitRemain1=acc.funAcntDebitRemain(AcntCode) ,
			UnReceiptRemain=trs.funAcntUnReceiptRemain(AcntCode, 1)  ,
			ReturnedRemain=trs.funAcntReturnedRemain(AcntCode, 1) 
	
	Insert into #tbl_result
	Select ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID, '',SubUnitID,SubUnitQuantity,GoodsQuantity,  Price, Price2, '', '', 0, '', '', 0 , '', '', 0, '', '', 0, 0, 0, ''	
	From #tbl_goods
	
	update #tbl_result
		set GoodsName	= [pub].[funGetGoodsName](G.GoodsID ,@LangID)
			,Weight		= G.GoodsWeight
			,Volume		= G.GoodsLength * G.GoodsHeight * G.GoodsWidth
			,BarCode		= IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
	from inv.tblGoods G
	where #tbl_result.GoodsID = @goods_id  AND #tbl_result.SerialNo=@serial_no AND 
									#tbl_result.DocRowNo = @docrow_no
		
	update #tbl_result
	set  UnitID1	= ( select MainUnitID from inv.funGetUnitValueWithAnyValue(GoodsID,SubUnitID,SubUnitQuantity))
		,Quantity1	= ( select GoodsQuantity from inv.funGetUnitValueWithAnyValue(GoodsID,SubUnitID,SubUnitQuantity))		
		,UnitID2	= ( select SubUnitIDShowInInvoice from inv.funGetUnitValueWithAnyValue(GoodsID,SubUnitID,SubUnitQuantity))
		,Quantity2	= ( select SubUnitQuantityShowInInvoice from inv.funGetUnitValueWithAnyValue(GoodsID,SubUnitID,SubUnitQuantity))		
		,UnitID3	= ( select SubUnitIDRemain1 from inv.funGetUnitValueWithAnyValue(GoodsID,SubUnitID,SubUnitQuantity))
		,Quantity3	= ( select SubUnitQuantityRemain1 from inv.funGetUnitValueWithAnyValue(GoodsID,SubUnitID,SubUnitQuantity))		
		,UnitID4	= ( select SubUnitIDRemain2 from inv.funGetUnitValueWithAnyValue(GoodsID,SubUnitID,SubUnitQuantity))
		,Quantity4	= ( select SubUnitQuantityRemain2 from inv.funGetUnitValueWithAnyValue(GoodsID,SubUnitID,SubUnitQuantity))
	
	update #tbl_result
	set 	
		UnitName1=isnull(( select UnitName from inv.tblUnitsDtl where UnitID=UnitID1), '')
		,UnitName2=isnull(( select UnitName from inv.tblUnitsDtl where UnitID=UnitID2), '')
		,UnitName3=isnull(( select UnitName from inv.tblUnitsDtl where UnitID=UnitID3), '')
		,UnitName4=isnull(( select UnitName from inv.tblUnitsDtl where UnitID=UnitID4), '')
	 



	 --================================

	DECLARE @Remain1	Bit;
	DECLARE @Remain2	Bit;
	DECLARE @Remain3	Bit;
	DECLARE @Remain4	Bit;
	DECLARE @CountPartRemain TINYINT
	DECLARE @Part1End		 TINYINT;
	DECLARE @Part1Start	Int;
	DECLARE @Part2Start	Int;
	DECLARE @Part3Start	Int;
	DECLARE @Part4Start	Int;
	DECLARE @Part1Len	Int;
	DECLARE @Part2Len	Int;
	DECLARE @Part3Len	Int;
	DECLARE @Part4Len	Int;
	DECLARE @Eqal		NVarChar(2000);

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

	SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  TableName = 'acc.tblAcnt' AND PartNumber = 1

	SELECT  @Remain1 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain1'
	SELECT  @Remain2 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain2'
	SELECT  @Remain3 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain3'
	SELECT  @Remain4 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain4'

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

	SET @Eqal = '
		SELECT	 IsNull(Sum(Debit - Credit),0) Debit 
		FROM	acc.tblVoucherDtl M 
		INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
		INNER JOIN acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(M.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode, 1, ' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode) = ' + LTrim(RTrim(STR(@Part1End))) + '
		WHERE    b.AcntType NOT IN (91,92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0 AND (' + @Eqal + ') AND 
		(M.DocDate <= H.DocDate )'

	--================================
	----------------------------------------------------------------------------------------------
	select ProcessID	,ProcessNo	,FiscalYear	,SerialNo,RowNo	,DocRowNo	,GoodsID ,BatchNo	,
		 GoodsPrice SumPriceDtl	,AcntCode	,DocDate	, DocDate	VchDate	,  GoodsID CurrencyTypeID	, GoodsPrice CurrencyRate	
		, 1 IsReturn	,DiscountDtl	,TaxOverWorthCostDtl	,TollOverWorthCostDtl	,DiscountDtl	 Discount	, DiscountDtl Discount2	
		,CurrencyAmount	,DiscountDtl DiscountTaxOverWorth	,TaxOverWorthCostDtl TaxOverWorthCost	, TollOverWorthCostDtl TollOverWorthCost	
		, GoodsPrice SumDiscountHdr	, GoodsPrice SumPrice	, GoodsPrice SumPriceDtlWithTax	, DiscountDtl DiscountHdr	
		,TaxOverWorthCostDtl TaxDtl	,TollOverWorthCostDtl TollDtl	,GoodsPrice PurePrice	,DiscountDtl TotalDiscount	,TaxOverWorthCostDtl TaxTollDtl
	
	Into #SaleOrders  
	from sal.tblSaleOrderDtl
	where 1=0

	declare @Ext varchar(100) 
	set @Ext=str(@ProcessID)+'@'+str(@ProcessNo)+'@'+str(@FiscalYearFr)+'@'+str(@SerialNoFr)+'@'+str(@FiscalYearTo)+'@'+str(@SerialNoTo)+' '
 
	insert into #SaleOrders  
	exec sal.SpSaleOrders   @Ext


	SET @StrSelect1 = '
	SELECT	D.*, F.*, [pub].[GetStoreName](D.StoreID,' + LTrim(RTrim(@LangID)) + ') StoreName,pub.funFarsiDate(GETDATE()) PrintDate,
			H.DocDesc, H.DocDesc2, H.DocDesc3, H.VisitorAcntCode HdrVisitorAcntCode, U1.UnitName, H.CurrencyRate, H.CurrencyTypeID, 
			pub.funGetCurrencyTypesName(H.CurrencyTypeID,' + LTrim(RTrim(@LangID)) + ') CurrencyTypesName,
			U2.UnitName as SubUnitName, ISNUll(MainUnitValue,1)MainUnitValue, isnull(UnitValue,1) UnitValue, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
			(SELECT GoodsWeight FROM inv.tblGoods WHERE GoodsID = D.GoodsID) * D.GoodsQuantity GoodsWeight, H.DocTime, 
		    IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, H.PayOffTypeID, PT.PayOffTypeName,
			H.DiscountPercent As DiscountPercentHdr, H.Discount + H.Discount2 AS DiscountHdr, 
			H.TransportationCost, H.TransportationIncome, H.VisitorPercent As VisitorPercentHdr, H.VisitorCost, 
			H.VisitorAcntCode2 HdrVisitorAcntCode2, H.VisitorPercent2 As HdrVisitorPercent2, H.VisitorCost2, H.PackingCost, 
			H.TaxCost,H.DiscountTaxOverWorth, H.TaxOverWorthCost, H.TollOverWorthCost, H.OtherCost, H.OtherIncome, H.OrderName,
			pub.GetCodeName(H.VisitorAcntCode, ' + LTrim(RTrim(@LangID)) + ') VisitorAcntName, 
			pub.funGetLocationName(F.LocationID, ' + LTrim(RTrim(@LangID)) + ') LocationName,
			sal.funGetSaleTypeName(H.SaleTypeID, ' + LTrim(RTrim(@LangID)) + ') SaleTypeName,
			GRD.ReciverName,		 
			AR.DebitRemain,
			AR.DebitRemain1,
			AR.UnReceiptRemain,
			AR.ReturnedRemain,
			pub.GetUserName(H.SessionNo) AS UserName,
			pub.GetUserName(H.SessionNo2) AS UserName2,
			(SELECT UserSignature from ' + @Db0000 + '.usr.tblUsers 
			where UserID= ' + @Db0000 + '.pub.funGetUserID(H.SessionNo) ) As UserSign,
			(SELECT UserSignature from ' + @Db0000 + '.usr.tblUsers 
			where UserID= ' + @Db0000 + '.pub.funGetUserID(H.SessionNo2) ) As UserSign2,			
			inv.funSubUnit2(D.GoodsID) UnitScale,
			inv.funSubUnit2Name(D.GoodsID) UnitNameX,
			GH.TechnicalSpecifications,GH.TechnicalNo, GH.MiscSpecifications,
			pub.UN(SgnSN1) As SgnSN1, pub.UN(SgnSN2) As SgnSN2, pub.UN(SgnSN3) As SgnSN3, pub.UN(SgnSN4) As SgnSN4,
			pub.UN(SgnSN5) As SgnSN5, 
			S1.UserSign As UserSignature1,
			S2.UserSign As UserSignature2,
			S3.UserSign As Signature1,
			S4.UserSign As Signature2,
			S5.UserSign As Signature3,
			S6.UserSign As Signature4,
			S7.UserSign As Signature5,
			H.C1,H.C2,H.C3,H.C4,H.C5,H.C6,H.C7,H.C8,H.C9,H.C10,H.C11,H.C12,H.C13,H.C14,H.C15,H.B1,H.B2,H.B3,H.B4,H.B5,H.B6,H.B7,H.B8,H.B9,H.B10,H.B11,H.B12,H.B13,H.B14,H.B15,H.Reserved,
			ROUND(IsNull(R.GoodsQuantity,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RQuantity, 
			IsNull(R.Price,0) RPrice, IsNull(R.Price2,0) RPrice2,
			IsNull(R.UnitID1,'''') RUnitID1, IsNull(R.UnitName1,'''') RUnitName1, ROUND(IsNull(R.Quantity1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RQuantity1,
			IsNull(R.UnitID2,'''') RUnitID2, IsNull(R.UnitName2,'''') RUnitName2, ROUND(IsNull(R.Quantity2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RQuantity2,
			IsNull(R.UnitID3,'''') RUnitID3, IsNull(R.UnitName3,'''') RUnitName3, ROUND(IsNull(R.Quantity3,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RQuantity3,
			IsNull(R.UnitID4,'''') RUnitID4, IsNull(R.UnitName4,'''') RUnitName4, ROUND(IsNull(R.Quantity4,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RQuantity4,
			IsNull(R.Weight,0) RWeight, IsNull(R.Volume,0) RVolume, IsNull(R.BarCode,'''') RBarCode, ' + LTrim(RTrim(Str(@MainAndSubUnit))) + ' MainAndSubUnit,
			isnull((Select Count (*) from sal.tblSaleOrderParamAtom a where a.ProcessID = D.ProcessID AND a.ProcessNo = D.ProcessNo AND a.FiscalYear = D.FiscalYear AND a.SerialNo = D.SerialNo AND a.DocRowNo = D.DocRowNo),0 ) CountOrderParamAtom,
			EarnestMoneyPercent	,EarnestMoney	,EarnestMoneyAcntCode, 
			SumPriceDtl, SumDiscountHdr, SumPrice, SumPriceDtlWithTax, DiscountHdr DiscountHdr2Row, 
			TaxDtl, TollDtl, PurePrice,TotalDiscount	,TaxTollDtl, H.SettlementDate, 
			'+LTrim(RTrim(str(@ShowContainerAndPos))) +'as ShowContainerAndPos, H.SendDate, H.SendTime	'
	SET @StrSelect2 = '
	FROM	sal.tblSaleOrderDtl AS D
	INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
	INNER JOIN #SaleOrders  DD ON DD.ProcessID = D.ProcessID AND DD.ProcessNo = D.ProcessNo AND DD.FiscalYear = D.FiscalYear AND DD.SerialNo = D.SerialNo  AND DD.DocRowNo = D.DocRowNo
	LEFT  JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	LEFT  JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	LEFT  JOIN inv.tblUnitsDtl U1 ON U1.UnitID = GH.UnitID 
	LEFT  JOIN inv.tblUnitsDtl U2 ON U2.UnitID = D.SubUnitID
	LEFT  JOIN inv.tblSubUnitsDtl SU ON SU.SubUnitID = D.SubUnitID and  SU.GoodsID=D.GoodsID
	LEFT  JOIN inv.tblGoodsReciverDtl GRD  on H.GoodsReciverID=GRD.ReciverID 
	LEFT  JOIN inv.tblGoodsReciver GR ON GRD.ReciverID = GR.ReciverID
	LEFT  JOIN #tbl_Invoice_Signatures S1 ON S1.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SessionNo)
	LEFT  JOIN #tbl_Invoice_Signatures S2 ON S2.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SessionNo2)
	LEFT  JOIN #tbl_Invoice_Signatures S3 ON S3.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN1)
	LEFT  JOIN #tbl_Invoice_Signatures S4 ON S4.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN2)
	LEFT  JOIN #tbl_Invoice_Signatures S5 ON S5.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN3)
	LEFT  JOIN #tbl_Invoice_Signatures S6 ON S6.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN4)
	LEFT  JOIN #tbl_Invoice_Signatures S7 ON S7.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN5)
    LEFT  JOIN #tbl_result R ON R.GoodsID = D.GoodsID And R.DocRowNo = D.DocRowNo
							And R.ProcessID = D.ProcessID AND R.ProcessNo = D.ProcessNo AND R.FiscalYear = D.FiscalYear AND R.SerialNo = D.SerialNo 
	LEFT  JOIN sal.tblPayOffTypesDtl PT ON H.PayOffTypeID = PT.PayOffTypeID AND PT.LanguageID = ' + LTrim(RTrim(@LangID)) + '
	LEFT  JOIN #tblAcntCodeRemain AR on D.AcntCode=AR.AcntCode
	OUTER APPLY acc.funGetCodeInfo(D.AcntCode) F
	
	WHERE ' + @StrWhere + '
	ORDER BY D.FiscalYear, D.SerialNo, D.DocRowNo '

	PRINT @StrSelect1;
	PRINT @StrSelect2;
	
	SET @StrSelect1 = @StrSelect1 + @StrSelect2;
	EXEC sp_executesql @StrSelect1;
END
GO
