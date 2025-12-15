USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/05/02
-- Viewed By	 : 
-- Last Modified : 1394/11/18
-- Last Modifier : TakroSystem\Zia
-- Description   : <Store Statistics>
-- ----------------------------------------------
-- آمار انبار گروه بندی شده بر اساس کالا و طرف حساب یا انبار
-- ==============================================
Create PROCEDURE [inv].[RptStore_Statistics]
	@ProcessID			Int,
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@GoodsID			VarChar(20) = Null,
	@StoreID			VarChar(20) = Null,
	@AcntCode			VarChar(20) = Null,
	@SelectedGoods		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedStore2		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@DocStep			Int = 0,
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@RepOptions			VarChar(50) = '11000001110', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = '@@@1@3@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrGroupBy	NVarChar(150);
DECLARE @StrPrice	NVarChar(200);
DECLARE @StrQty		VarChar(1000);
DECLARE @StrPrc		VarChar(1000);
DECLARE @StrPID		VarChar(20);
DECLARE @StrRetPID	VarChar(3);
DECLARE @Zero		VarChar(500);

DECLARE @StrStr		VarChar(500);
DECLARE @StrAcn		VarChar(500);
DECLARE @StrOvr		VarChar(500);
DECLARE @ShowQuantity	Bit;
DECLARE @ShowPrice		Bit;
DECLARE @ShowOverload	Bit; -- شامل سربار
DECLARE @UseAmount		Bit; -- Use Amount Field Instead of Price?
DECLARE @DecReturn		Bit; -- کسر برگشتیها
DECLARE @ShowStoreID	Bit; -- شامل ستون کد انبار
DECLARE @ShowAcntCode	Bit; -- شامل ستون کد حساب
DECLARE @DecDiscounts	Bit; 
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE @PID1			bit;
DECLARE @PID2			bit;
DECLARE @PID3			bit;
DECLARE @Aggregate		bit;
DECLARE @GroupByLayer	bit;
DECLARE @LayerLen		int;
DECLARE @GoodsPart		int;
DECLARE @VATY			Bit;
DECLARE @VATN			Bit;

DECLARE @Location	VarChar(20);
DECLARE @Location2	VarChar(20);
declare @GoodsNameField	varchar(200);
DECLARE @AcntCodeField	varchar(200);
DECLARE @AcntCodeField2	varchar(200);
DECLARE @AcntNameField	varchar(200);

DECLARE @Dist0		NVarChar(20); -- DriverID
DECLARE @Dist1		NVarChar(20); -- DistributerID1
DECLARE @Dist2		NVarChar(20); -- DistributerID2
DECLARE @Dist3		NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4		NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5		NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6		NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7		NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8		NVarChar(20); -- BaseDistributionSerialNo   to
DECLARE @CustKind	VarChar(20);

DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;

DECLARE @PartStart	Int;
DECLARE @PartLen	Int;
DECLARE @PartNo		int;

DECLARE @IsCurrency	Bit;
DECLARE @SH			NVarChar(50);
DECLARE @SD			NVarChar(50);

-- ======
DECLARE @goods_id						Varchar(20);
DECLARE @store_id						Varchar(20);
DECLARE @acnt_code						Varchar(20);
DECLARE @rowno							int;
DECLARE @goods_quantity					DECIMAL(28,9);

-- ======
DECLARE @unit_name						nvarchar(200);
DECLARE @unit_id						varchar(20);
DECLARE @unit_value						float;
DECLARE @unit_value_Temp				float;
DECLARE @Mainunit_value					float;
DECLARE @Cnt							INT;

-- ======
DECLARE @unit_nameGoods1				nvarchar(200);
DECLARE @unit_idGoods1					varchar(20);
DECLARE @unit_valueGoods1				float;
DECLARE @Mainunit_valueGoods1			float;

DECLARE @unit_nameGoods2				nvarchar(200);
DECLARE @unit_idGoods2					varchar(20);
DECLARE @unit_valueGoods2				float;
DECLARE @Mainunit_valueGoods2			float;

DECLARE @MainAndSubUnit  bit;

DECLARE @LanguageID			TinyInt;

DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @StartLayerAcntRemain		int;
DECLARE @LenLayerAcntRemain		int;

Declare @CustomerInfo	Int;
Declare @chkRetail		bit;
DECLARE @IsMultiplex	Bit;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--==============	
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	Select @StartLayerAcntRemain=acc.FunGetAcntInfoForRemain(2 )
	Select @LenLayerAcntRemain=acc.FunGetAcntInfoForRemain(3 )

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- Init Variables & Default Values ----------------------------------------
	IF (@ProcessNo Is Null)		SET @ProcessNo = 1
	IF (@DocStep Is Null)		SET @DocStep = 0
	IF (@RepOptions Is Null)	SET @RepOptions = '1100000111'

	IF (@DocDateFr	Is Null)	SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)	SET @DocDateTo = '@@@';

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0
	IF (@SelectedStore2 Is Null)	SET @SelectedStore2 = 0
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0

	If (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	SET @LanguageID = pub.funGetCurrentLanguageID();

	IF (@DistributeInfo <> '')
	Begin
		SET @Dist0	= pub.funSplitString(@DistributeInfo, '#', 1);
		SET @Dist1	= pub.funSplitString(@DistributeInfo, '#', 3);
		SET @Dist2	= pub.funSplitString(@DistributeInfo, '#', 5);
		SET @Dist3	= pub.funSplitString(@DistributeInfo, '#', 7);
		SET @Dist4	= pub.funSplitString(@DistributeInfo, '#', 8);
		SET @Dist5	= pub.funSplitString(@DistributeInfo, '#', 9);
		SET @Dist6	= pub.funSplitString(@DistributeInfo, '#', 10);
		SET @Dist7	= pub.funSplitString(@DistributeInfo, '#', 11);
		SET @Dist8	= pub.funSplitString(@DistributeInfo, '#', 12);
	End
	Else
	Begin
		SET @Dist0	= 'null';
		SET @Dist1	= 'null';
		SET @Dist2	= 'null';
		SET @Dist3	= 'null'; 
		SET @Dist4	= 'null';
		SET @Dist5	= 'null';
		SET @Dist6	= 'null';
		SET @Dist7	= 'null';
		SET @Dist8	= 'null';
	End

	SET @ShowQuantity	= Substring(@RepOptions, 1, 1)
	SET @ShowPrice		= Substring(@RepOptions, 2, 1)
	SET @ShowOverload	= Substring(@RepOptions, 3, 1)
	SET @UseAmount		= Substring(@RepOptions, 4, 1)
	SET @DecReturn		= Substring(@RepOptions, 5, 1)
	SET @ShowStoreID	= Substring(@RepOptions, 6, 1)
	SET @ShowAcntCode	= Substring(@RepOptions, 7, 1)
	SET @PID1			= Substring(@RepOptions, 8, 1)
	SET @PID2			= Substring(@RepOptions, 9, 1)
	SET @PID3			= Substring(@RepOptions, 10, 1)
	SET @DecDiscounts	= Substring(@RepOptions, 11, 1)
	SET @Aggregate		= Substring(@RepOptions, 12, 1)
	SET @IsCurrency		= Substring(@RepOptions, 13, 1)
	SET @VATY			= Substring(@RepOptions, 14, 1)
	SET @VATN			= Substring(@RepOptions, 15, 1)
	
	--Print @RepOptions
	--Print @VATY
	--Print @VATN
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	-- ==========
	begin try
		drop table #tbl_result
	end try
	begin catch
	end catch

	Create Table #tbl_result
	(
		AcntCode				varchar(20) collate Arabic_CS_AS null,
		StoreID					varchar(20) collate Arabic_CS_AS null,
		GoodsID					varchar(20) collate Arabic_CS_AS null,
		GoodsQuantity			DECIMAL(28,9),
		UnitNameGoods1			nvarchar(20) collate Arabic_CS_AS null,
		GoodsQuantity1			DECIMAL(28,9),
		UnitNameGoods2			nvarchar(20) collate Arabic_CS_AS null,
		GoodsQuantity2			DECIMAL(28,9)
	);
		
	Declare @tbl_units as table
	(
		unit_id					varchar(20) not null, 
		unit_name				nvarchar(200) not null, 
		unit_value				float not null,
		Mainunit_value			float not null,
		cnt						int not null
	);
	
	-- ==========
	SET @StrSelect = '';
	set @StrPID = '';

	if (@ProcessID = 90) 
		SET @StrRetPID = '100'
	else if (@ProcessID = 55) 
		SET @StrRetPID = '60'
	else
		SET @StrRetPID = '0'

	SET @CustKind		= LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @Location		= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @Location2		= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @GroupByLayer	= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @LayerLen		= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @GoodsPart		= LTrim(pub.funSplitString(@ExtraParams, '@', 6));	
	SET @MainAndSubUnit	= LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @CampaignID		= pub.funSplitString(@ExtraParams,'@',8);
	SET @VisitPathID1	= pub.funSplitString(@ExtraParams, '@', 9);
	SET @VisitPathID2	= pub.funSplitString(@ExtraParams, '@', 10);
	SET @VisitPathID3	= pub.funSplitString(@ExtraParams, '@', 11);
	SET @VisitPathID4	= pub.funSplitString(@ExtraParams, '@', 12);
	SET @SalesRoomClass	= pub.funSplitString(@ExtraParams, '@', 13);
	SET @chkRetail		= pub.funSplitString(@ExtraParams, '@', 14);
	SET @CustomerInfo	= pub.funSplitString(@ExtraParams, '@', 15);
	SET @IsMultiplex	= pub.funSplitString(@ExtraParams, '@', 16);

	If @chkRetail = 0
		set @CustomerInfo = 0;

	if (@LayerLen = 0) set @LayerLen = 20;	
	
	if (@PID1 = 0) and (@PID2 = 0) and (@PID3 = 0)
		set @PID1 = 1

	if (@ProcessID = 70) or (@ProcessID = 80)
	begin	
		set @StrPID = '0';

		if (@PID1 = 1)
			set @StrPID = @StrPID + ',' + ltrim(str(@ProcessID));

		if (@PID2 = 1)
			if (@ProcessID = 70) 
				set @StrPID = @StrPID + ',82' 
			else
				set @StrPID = @StrPID + ',72' 
			
		if (@PID3 = 1)
			if (@ProcessID = 70) 
				set @StrPID = @StrPID + ',83' 
			else
				set @StrPID = @StrPID + ',73' 
	end
	else
		set @StrPID = ltrim(str(@ProcessID))
	
	set @PartNo = 0;
	select @PartNo = SettingValue
	from pub.tblSettings
	where SettingKey = 'AcntPartNumberForRemainCalculation'

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

	if (@PartNo	= 0)
	begin
		set @PartStart = 1
		set @PartLen = 20
	end
	else if (@PartNo = 1)
	begin
		set @PartStart = @Part1Start
		set @PartLen = @Part1Len
	end
	else if (@PartNo = 2)
	begin
		set @PartStart = @Part2Start
		set @PartLen = @Part2Len
	end
	else if (@PartNo = 3)
	begin
		set @PartStart = @Part3Start
		set @PartLen = @Part3Len
	end
	else if (@PartNo = 4)
	begin
		set @PartStart = @Part4Start
		set @PartLen = @Part4Len
	end

	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	Set @StrWhere = ' (D.ProcessID in (' + @StrPID + '))'

	IF @ProcessNo Is Not Null AND @ProcessNo > 0
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	if (@CustKind <> '')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'

	if (@Location <> '')
		Set @StrWhere = @StrWhere + ' AND (Left(H.LocationID, ' + str(len(@Location)) + ') >= ''' + @Location + ''')'
	if (@Location2 <> '')
		Set @StrWhere = @StrWhere + ' AND (Left(H.LocationID, ' + str(len(@Location2)) + ') <= ''' + @Location2 + ''')'

	If (@Dist0 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
	If (@Dist1 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
	If (@Dist2 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''

	If (@Dist5 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	If (@Dist7 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(@Dist8)

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')

	IF (@CampaignID > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'CampaignID') +' ) '
	IF (@VisitPathID1 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'VisitPathID1') +' ) '
	IF (@VisitPathID2 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'VisitPathID2') +' ) '
	IF (@VisitPathID3 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'VisitPathID3') +' ) '
	IF (@VisitPathID4 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'VisitPathID4') +' ) '
	IF (@SalesRoomClass > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @SalesRoomClass, 'SalesRoomClass') +' ) '


	If (@VchNoFr Is Not Null) OR (@VchNoTo Is Not Null)
		If (@VchNoFr = @VchNoTo)
			Set @StrWhere = @StrWhere + ' AND H.VchNo  = ' + LTrim(Str(@VchNoFr))
		Else
		Begin
			If (@VchNoFr Is Not Null)
				Set @StrWhere = @StrWhere + ' AND H.VchNo >= ' + LTrim(Str(@VchNoFr))
			If (@VchNoTo Is Not Null)
				Set @StrWhere = @StrWhere + ' AND H.VchNo <= ' + LTrim(Str(@VchNoTo))
		End

	If (@GoodsID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.GoodsID = ''' + LTrim(@GoodsID) + '''' 
	If (@StoreID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.StoreID = ''' + LTrim(@StoreID) + '''' 
	If (@AcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AcntCode = ''' + LTrim(@AcntCode) + ''''
	
	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	If (@SelectedStore2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'
	IF (@CustomerInfo > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND  D.OrderAcntCode in (Select CustomerInfoID from lyl.tblCustomerInfo where 1=1 and   ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerInfo, 'CustomerInfoID') +' )'
	End
		
	if (@IsCurrency = 1)
		begin
			set @SH = 'inv.vwStorageHdr_Currency'
			set @SD = 'inv.vwStorageDtl_Currency'
		end
		else
		begin
			set @SH = 'inv.tblStorageDocsHdr'
			set @SD = 'inv.tblStorageDocsDtl'
		end
		
	IF (@VATY = 1) And (@VATN = 0)
	Begin
		Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0)'
	End
	IF (@VATN = 1) And (@VATY = 0)
	Begin
		Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost = 0)'
	End
			
	------------------------------------------------------------------
	-- Group By Clause -------------------------------------------------
	SET @StrGroupBy = 'GoodsID, StoreID, StoreID2,'
	--------------------------------------------------------------------
	-- Select Clause ---------------------------------------------------
	if (@Aggregate = 1)
	begin
		set @AcntCodeField = 'substring(D.AcntCode, ' + LTrim(Str(@PartStart)) + ', ' + LTrim(Str(@PartLen)) + ')'
		set @AcntCodeField2 = 'substring(M.AcntCode, ' + LTrim(Str(@PartStart)) + ', ' + LTrim(Str(@PartLen)) + ')'
		
		set @AcntNameField = 'acc.funGetAcntName(M.AcntCode, ' + LTrim(Str(@PartNo)) + ', 1) AcntName'
	end
	else
	begin
		set @AcntCodeField = 'D.AcntCode'
		set @AcntNameField = 'pub.GetCodeName(M.AcntCode, ' + @LangID + ') AcntName'
	end;

	SET @Zero = 'CAST(''0'' As VarChar(20))' 

	DECLARE @strGoodsAmount as varchar(200) = 'GoodsAmount'
	DECLARE @DocDate01 as VarChar(10)
	DECLARE @DocDate02 as VarChar(10)
	DECLARE @DocDate03 as VarChar(10)
	DECLARE @DocDate04 as VarChar(10)

	SELECT @DocDate01 = LTrim(pub.funSplitString(@DocDateTo, '@', 1));
	SELECT @DocDate02 = LTrim(pub.funSplitString(@DocDateTo, '@', 2));
	SELECT @DocDate03 = LTrim(pub.funSplitString(@DocDateTo, '@', 3));
	SELECT @DocDate04 = LTrim(pub.funSplitString(@DocDateTo, '@', 4));

	IF @DocDate01 IS NULL SET @DocDate01 = ''
	IF @DocDate02 IS NULL SET @DocDate02 = ''
	IF @DocDate03 IS NULL SET @DocDate03 = ''
	IF @DocDate04 IS NULL SET @DocDate04 = ''
	
	IF @DocDate01 <> ''
		SET @DocDateTo = @DocDate01

	IF @DocDate01 = '' and @DocDate02 <> ''
		SET @DocDateTo = @DocDate02

	IF @DocDate01 = '' and @DocDate02 = '' and @DocDate03 <> ''
		SET @DocDateTo = @DocDate03

	IF @DocDate01 = '' and @DocDate02 = '' and @DocDate03 = '' and @DocDate04 <> ''
		SET @DocDateTo = @DocDate04

	IF @IsMultiplex = 'False'
		Set @strGoodsAmount = 'GoodsAmount'
	ELSE
	BEGIN
		IF (@DocDateTo = '@@@') 
			SET @DocDateTo = ''

		SET @strGoodsAmount = LTRIM(RTrim((inv.funGoodsAmount(@DocDateTo))))
	END				

	IF (@UseAmount = 1)
		SET @StrPrice = @strGoodsAmount
	Else
		SET @StrPrice = 'GoodsPrice'

	IF (@DecReturn = 1)
	BEGIN
		SET @StrQty	= '(D.GoodsQuantity - 
							(
								SELECT	IsNull(SUM(GoodsQuantity), 0)
								FROM	' + @SD + ' 
								WHERE	ProcessID = ' + @StrRetPID + ' AND 
										ProcessNo = ' + Str(@ProcessNo) + ' AND 
										BaseProcessID = D.ProcessID AND 
										BaseProcessNo = D.ProcessNo AND 
										BaseFiscalYear = D.FiscalYear AND 
										BaseSerialNo = D.SerialNo AND 
										BaseDocRowNo = D.DocRowNo
							)
						)'
		SET @StrPrc	= '((D.GoodsQuantity * D.' + @StrPrice + ') - 
							(
								SELECT	IsNull(SUM(GoodsQuantity * ' + @StrPrice + '), 0)
								FROM	' + @SD + ' 
								WHERE	ProcessID = ' + @StrRetPID + ' AND 
										ProcessNo = ' + Str(@ProcessNo) + ' AND 
										BaseProcessID = D.ProcessID AND 
										BaseProcessNo = D.ProcessNo AND 
										BaseFiscalYear = D.FiscalYear AND 
										BaseSerialNo = D.SerialNo AND 
										BaseDocRowNo = D.DocRowNo
							)
						)'
	END
	ELSE
	BEGIN
		SET @StrQty	= 'D.GoodsQuantity'
		SET @StrPrc	= 'D.GoodsQuantity * D.' + @StrPrice 
	END
	
	IF (@ShowStoreID = 1)
		SET @StrStr = 'D.StoreID, D.StoreID2 ' 
	ELSE
		SET @StrStr = @Zero + ' StoreID, ' + @Zero + ' StoreID2 ' 

	IF (@ShowAcntCode = 1)
		SET @StrAcn = @AcntCodeField + ' as AcntCode ' 
	ELSE
		SET @StrAcn = @Zero + ' as AcntCode ' 

	IF (@ShowOverload = 1)
		SET @StrOvr = 'D.AtomAmount' 
	ELSE
		SET @StrOvr = '0'
		
	--if (@GroupByLayer = 1)
	--begin
		set @GoodsNameField = 'pub.funGetGoodsName(M.GoodsID, ' + @LangID + ') GoodsName'
		--set @UnitNameField = 'inv.funGetUnitNameWithGoodsID(D.GoodsID, ' + @LangID + ') UnitName'
	--end
	--else
	--begin
	--	set @GoodsNameField = 'M.GoodsName'
	--	--set @UnitNameField = 'UD.UnitName'
	--end		

	-- =======================
	begin try
		drop table ##tbl_Tmp1
	end try
	begin catch
	end catch
	
	-- =======================
if (@chkRetail = 0)
Begin
	SET @StrSelect = '
	SELECT M.*, 
			' + LTrim(RTrim(@GoodsNameField)) + ',
			' + LTrim(RTrim(@AcntNameField))  + ',
			isnull(S1.StoreName, ''-'') StoreName,
			isnull(S2.StoreName, ''-'') StoreName2
	INTO	##tbl_Tmp1
	FROM
	(
		SELECT	T.GoodsID, T.AcntCode,
				T.StoreID, T.StoreID2,
				SUM(Quantity) Quantity, 
				SUM(Price) Price, 
				SUM(Overload) Overload, 
				SUM(DiscountDtl) Discount
				,T.SubUnitID,T.SubUnitPrice,Cast('''' as varchar(100)) LYL_CustomerInfoID,'+str(@chkRetail)+' checkRetail,
				Cast('''' as varchar(100)) LYL_BirthDate,	Cast('''' as varchar(100)) LYL_RegisterDate, Cast('''' as varchar(100)) LYL_MobileNumber,
				Cast('''' as varchar(100)) LYL_PhoneNumber, Cast('''' as varchar(100)) LYL_Gender,		 Cast('''' as varchar(100)) LYL_FirstName,
				Cast('''' as varchar(100)) LYL_LastName,	Cast('''' as varchar(100)) LYL_Adress
		FROM	
		(
			SELECT	Left(D.GoodsID, ' + LTrim(RTrim(str(@LayerLen))) + ') GoodsID, D.DiscountDtl,
					' +	@StrStr + ', 
					' + @StrAcn + ',
					' + @StrQty + ' Quantity, 
					' + @StrPrc + ' Price, 
					' + @StrOvr + ' Overload
					,SubUnitID,SubUnitPrice
			FROM	' + @SD + ' D
				INNER JOIN ' + @SH + ' H ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo 
			WHERE	' + @StrWhere + '
		) T
		GROUP BY ' + @StrGroupBy + ' AcntCode,T.SubUnitID,T.SubUnitPrice
	) M
		LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID = M.GoodsID and G.PartNumber = ' + str(@GoodsPart) + ' AND G.LanguageID = ' + @LangID + '
		LEFT JOIN inv.tblStoresDtl S1 ON M.StoreID  = S1.StoreID AND S1.LanguageID = ' + @LangID + '
		LEFT JOIN inv.tblStoresDtl S2 ON M.StoreID2 = S2.StoreID AND S2.LanguageID = ' + @LangID + '
	ORDER BY ' + @StrGroupBy +'AcntCode'
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
	if (@Aggregate = 1)
		Select T.GoodsID	,T.AcntCode	,T.StoreID	,StoreID2,  Sum(Quantity)	Quantity,Sum(Price)	Price,Sum(Overload)	Overload,Sum(Discount)	Discount,T.SubUnitID	,0 SubUnitPrice	
			,GoodsName	,AcntName	,StoreName	,StoreName2	, Sum(IsNull(0,0)) RGoodsQuantity,  IsNull(Sum(Quantity)-Sum(Quantity)%1,0) GoodsQuantity1, ISNULL(U1.UnitName,'') UnitNameGoods1
			,isnull((Sum(Quantity)%1)*UnitValue/MainUnitValue,0) GoodsQuantity2, ISNULL(U2.UnitName,'') UnitNameGoods2,G.GoodsWeight,G.PureWeight,isnull(TechnicalNo, '')TechnicalNo
			, Sum(inv.funGetSubUnitFromGoodsQuantity(T.GoodsID,T.SubUnitID,T.Quantity) )SubUnitQuantity, T.LYL_CustomerInfoID, T.checkRetail, T.LYL_BirthDate, T.LYL_RegisterDate
			, T.LYL_MobileNumber, T.LYL_PhoneNumber, T.LYL_Gender, T.LYL_FirstName, T.LYL_LastName, T.LYL_Adress
		From ##tbl_Tmp1 T
		LEFT JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(T.GoodsID,@str_Goods+1, @str_GoodsSum) AND G.PartNumber= @GoodsPart 
		LEFT JOIN  inv.tblSubUnitsDtl U on U.ShowInInvoice=1 and U.GoodsID=G.GoodsID
		LEFT JOIN  inv.tblUnitsDtl U1 On U1.UnitID= G.UnitID and U1.LanguageID=1
		LEFT JOIN  inv.tblUnitsDtl U2 On U2.UnitID= U.SubUnitID and U2.LanguageID=1
		Group by T.GoodsID,T.AcntCode,T.StoreID	,StoreID2,T.SubUnitID,GoodsName,AcntName,StoreName,StoreName2
				,UnitValue,MainUnitValue,U1.UnitName,U2.UnitName ,G.GoodsWeight,G.PureWeight,TechnicalNo,LYL_CustomerInfoID, checkRetail, LYL_BirthDate, LYL_RegisterDate
			, LYL_MobileNumber, LYL_PhoneNumber, LYL_Gender, LYL_FirstName, LYL_LastName, LYL_Adress
	else
		Select T.*, 0 RGoodsQuantity, (Quantity-(Quantity%1)) GoodsQuantity1, U1.UnitName UnitNameGoods1,isnull((Quantity%1)*UnitValue/MainUnitValue,0) GoodsQuantity2
			,isnull( U2.UnitName,'')  UnitNameGoods2
			,G.GoodsWeight,G.PureWeight,TechnicalNo
			, inv.funGetSubUnitFromGoodsQuantity(T.GoodsID,T.SubUnitID,T.Quantity) SubUnitQuantity
		  --,isnull(  U.SubUnitID,'') SubUnitID,G.UnitID,isnull(MainUnitValue,0) MainUnitValue,isnull( UnitValue ,0) UnitValue	
		 From ##tbl_Tmp1 T	
		LEFT JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(T.GoodsID,@str_Goods+1, @str_GoodsSum) AND G.PartNumber= @GoodsPart 
		LEFT JOIN  inv.tblSubUnitsDtl U on U.ShowInInvoice=1 and U.GoodsID=G.GoodsID
		LEFT JOIN  inv.tblUnitsDtl U1 On U1.UnitID= G.UnitID and U1.LanguageID=1
		LEFT JOIN  inv.tblUnitsDtl U2 On U2.UnitID= U.SubUnitID and U2.LanguageID=1
End
if (@chkRetail = 1)
Begin
SET @StrSelect = '
	SELECT M.*, 
			' + LTrim(RTrim(@GoodsNameField)) + ',
			Cast('''' as varchar(100)) AcntName,
			isnull(S1.StoreName, ''-'') StoreName,
			isnull(S2.StoreName, ''-'') StoreName2
	INTO	##tbl_Tmp1
	FROM
	(
		SELECT	T.GoodsID, T.AcntCode,
				T.StoreID, T.StoreID2,
				SUM(Quantity) Quantity, 
				SUM(Price) Price, 
				SUM(Overload) Overload, 
				SUM(DiscountDtl) Discount,
				T.SubUnitID,T.SubUnitPrice,T.LYL_CustomerInfoID, T.checkRetail, T.LYL_BirthDate, T.LYL_RegisterDate,
				T.LYL_MobileNumber, T.LYL_PhoneNumber, T.LYL_Gender, T.LYL_FirstName, T.LYL_LastName, T.LYL_Adress
		FROM	
		(
			SELECT	Left(D.GoodsID, ' + LTrim(RTrim(str(@LayerLen))) + ') GoodsID, D.DiscountDtl,
					' +	@StrStr + ', 
					Cast('''' as varchar(100)) AcntCode,
					' + @StrQty + ' Quantity, 
					' + @StrPrc + ' Price, 
					' + @StrOvr + ' Overload
					,SubUnitID,SubUnitPrice,ISNULL(CI.CustomerInfoID,'''') LYL_CustomerInfoID,'+str(@chkRetail)+' checkRetail,
					ISNULL(CI.BirthDate,'''') LYL_BirthDate,ISNULL(CI.RegisterDate,'''') LYL_RegisterDate,ISNULL(CI.MobileNumber,'''') LYL_MobileNumber,
					ISNULL(CI.PhoneNumber,'''') LYL_PhoneNumber,ISNULL(CI.Gender,'''') LYL_Gender,ISNULL(CID.FirstName,'''') LYL_FirstName,ISNULL(CID.LastName,'''') LYL_LastName,
					ISNULL(CID.Adress,'''') LYL_Adress
			FROM	' + @SD + ' D
				INNER JOIN ' + @SH + ' H ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo 
				LEFT JOIN lyl.tblCustomerInfo CI ON CI.CustomerInfoID = D.OrderAcntCode		
				LEFT JOIN lyl.tblCustomerInfoDtl CID ON CID.CustomerInfoID = D.OrderAcntCode AND CID.LanguageID=' + LTrim(RTrim(STR(@LangID))) + '
			WHERE	' + @StrWhere + '
		) T
		GROUP BY ' + @StrGroupBy + ' AcntCode,T.SubUnitID,T.SubUnitPrice, LYL_CustomerInfoID, checkRetail, LYL_BirthDate, LYL_RegisterDate,
				LYL_MobileNumber, LYL_PhoneNumber, LYL_Gender, LYL_FirstName, LYL_LastName, LYL_Adress
		) M
		LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID = M.GoodsID and G.PartNumber = ' + str(@GoodsPart) + ' AND G.LanguageID = ' + @LangID + '
		LEFT JOIN inv.tblStoresDtl S1 ON M.StoreID  = S1.StoreID AND S1.LanguageID = ' + @LangID + '
		LEFT JOIN inv.tblStoresDtl S2 ON M.StoreID2 = S2.StoreID AND S2.LanguageID = ' + @LangID + '
	ORDER BY ' + @StrGroupBy +'AcntCode'
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
	if (@Aggregate = 1)
		Select T.GoodsID	,T.AcntCode	,T.StoreID	,StoreID2,  Sum(Quantity)	Quantity,Sum(Price)	Price,Sum(Overload)	Overload,Sum(Discount)	Discount,T.SubUnitID	,0 SubUnitPrice	
			,GoodsName	,AcntName	,StoreName	,StoreName2	, Sum(IsNull(0,0)) RGoodsQuantity,  IsNull(Sum(Quantity)-Sum(Quantity)%1,0) GoodsQuantity1, ISNULL(U1.UnitName,'') UnitNameGoods1
			,isnull((Sum(Quantity)%1)*UnitValue/MainUnitValue,0) GoodsQuantity2, ISNULL(U2.UnitName,'') UnitNameGoods2,G.GoodsWeight,G.PureWeight,isnull(TechnicalNo, '')TechnicalNo
			, Sum(inv.funGetSubUnitFromGoodsQuantity(T.GoodsID,T.SubUnitID,T.Quantity) )SubUnitQuantity, T.LYL_CustomerInfoID, T.checkRetail, T.LYL_BirthDate, T.LYL_RegisterDate
			, T.LYL_MobileNumber, T.LYL_PhoneNumber, T.LYL_Gender, T.LYL_FirstName, T.LYL_LastName, T.LYL_Adress
		From ##tbl_Tmp1 T
		LEFT JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(T.GoodsID,@str_Goods+1, @str_GoodsSum) AND G.PartNumber= @GoodsPart 
		LEFT JOIN  inv.tblSubUnitsDtl U on U.ShowInInvoice=1 and U.GoodsID=G.GoodsID
		LEFT JOIN  inv.tblUnitsDtl U1 On U1.UnitID= G.UnitID and U1.LanguageID=1
		LEFT JOIN  inv.tblUnitsDtl U2 On U2.UnitID= U.SubUnitID and U2.LanguageID=1
		Group by T.GoodsID,T.AcntCode,T.StoreID	,StoreID2,T.SubUnitID,GoodsName,AcntName,StoreName,StoreName2
				,UnitValue,MainUnitValue,U1.UnitName,U2.UnitName ,G.GoodsWeight,G.PureWeight,TechnicalNo, LYL_CustomerInfoID, checkRetail, LYL_BirthDate, LYL_RegisterDate
			, LYL_MobileNumber, LYL_PhoneNumber, LYL_Gender, LYL_FirstName, LYL_LastName, LYL_Adress
	else
		Select T.*, 0 RGoodsQuantity, (Quantity-(Quantity%1)) GoodsQuantity1, U1.UnitName UnitNameGoods1,isnull((Quantity%1)*UnitValue/MainUnitValue,0) GoodsQuantity2
			,isnull( U2.UnitName,'')  UnitNameGoods2
			,G.GoodsWeight,G.PureWeight,TechnicalNo
			, inv.funGetSubUnitFromGoodsQuantity(T.GoodsID,T.SubUnitID,T.Quantity) SubUnitQuantity
		  --,isnull(  U.SubUnitID,'') SubUnitID,G.UnitID,isnull(MainUnitValue,0) MainUnitValue,isnull( UnitValue ,0) UnitValue	
		 From ##tbl_Tmp1 T	
		LEFT JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(T.GoodsID,@str_Goods+1, @str_GoodsSum) AND G.PartNumber= @GoodsPart 
		LEFT JOIN  inv.tblSubUnitsDtl U on U.ShowInInvoice=1 and U.GoodsID=G.GoodsID
		LEFT JOIN  inv.tblUnitsDtl U1 On U1.UnitID= G.UnitID and U1.LanguageID=1
		LEFT JOIN  inv.tblUnitsDtl U2 On U2.UnitID= U.SubUnitID and U2.LanguageID=1	 
End	 
END
GO
