USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1386/02/19
-- Viewed By	 : 
-- Last Modified : 1391/02/04
-- Last Modifier : TakroSystem\Zia
-- Description   : گزارش سرجمع انبار برای یک کالا یا کالاها
-- ==============================================
Create PROCEDURE [inv].[RptStore_Summary_Acnt]
	@ProcessID			Int= 90,
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@SelectedGoods		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedStore2		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedOrders1	Int = 0, 
	@SelectedOrders2	Int = 0, 
	@SelectedOrders3	Int = 0, 
	@SelectedOrders4	Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@DocStep			Int = 0,  -- مرحله
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null#null',
	@SaleTypeID			varchar(20) = null,
	@RepOptions			VarChar(50) = '11000111111001', -- bit array options
	@SortFields			NVarChar(100) = Null,   -- Order By Field List
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = '@0@@@-1@-1'
WITH ENCRYPTION
AS 

---- Declarations ---------------
DECLARE @StrSelect			NVarChar(max);
DECLARE @StrFrom			NVarChar(max);
DECLARE @StrWhere			NVarChar(max);
DECLARE @StrWhere2			NVarChar(1000);
DECLARE @StrWhereRet		NVarChar(1000);
DECLARE @StrWhereDis		NVarChar(1000);
DECLARE @StrWhereRetDis		NVarChar(1000);
DECLARE @StrWhereTaxToll	NVarChar(1000);

DECLARE @StrSelect_Rem	NVarChar(max);
DECLARE @StrWhere_Rem	NVarChar(max);

DECLARE @StrPrice	NVarChar(100);
DECLARE @ProcessNo2		NVarChar(100);
DECLARE @Code1		Int;
DECLARE @Code2		Int;
DECLARE @Code3		Int;
DECLARE @Code4		Int;

DECLARE @RetCode1	Int;
DECLARE @RetCode2	Int;
DECLARE @RetCode3	Int;
DECLARE @RetCode4	Int;
DECLARE	@PriceFr	float;
DECLARE	@PriceTo	float;
DECLARE @EP			VarChar(500);
DECLARE @EP2		VarChar(500);
DECLARE @EA			VarChar(500);
DECLARE @EA2		VarChar(500);

DECLARE @ProcessID_Ret	Int;
DECLARE @GroupByLayer	Bit;

DECLARE @ShowQuantity	Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		Bit;  -- شامل ستون قیمت
DECLARE @ShowOverload	Bit;  -- شامل ستون سربار
DECLARE @ShowDiscount	Bit;  
DECLARE @ShowAfterSaleDiscount	Bit;
DECLARE @ShowRetDiscount	Bit;  
DECLARE @ShowZeroRows	Bit; -- Not Used; Only for Sync with summary report
DECLARE @DecReturn		Bit; -- Not Used; Only for Sync with summary report
DECLARE @UseAmount		Bit; -- Use Amount Field Instead of Price?
DECLARE @RefY			Bit;
DECLARE @RefN			Bit;
DECLARE @DecByRef		Bit;
DECLARE @ApplyDateToRet	Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @StrPID		VarChar(20);
DECLARE @Location	VarChar(20);
DECLARE @Location2	VarChar(20);
DECLARE @PID1	bit;
DECLARE @PID2	bit;
DECLARE @PID3	bit;

DECLARE @Dist0		NVarChar(20); -- DriverID
DECLARE @Dist1		NVarChar(20); -- DistributerID1
DECLARE @Dist2		NVarChar(20); -- DistributerID2
DECLARE @Dist3		NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4		NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5		NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6		NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7		NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8		NVarChar(20); -- BaseDistributionSerialNo   to
DECLARE @Dist9		NVarChar(20); -- WithoutDistributer
DECLARE @Dist10		NVarChar(20); -- WithDistributer
DECLARE @Dist11		NVarChar(20); -- FromDistributDate
DECLARE @Dist12		NVarChar(20); -- ToDistributDate
DECLARE @CustKind	VarChar(20);
DECLARE @SelectedProduct	int;
DECLARE @BuyTypeID	varchar(20);
DECLARE @LayerLen	int;
DECLARE @GoodsPart	int;

declare @StrQty			nvarchar(max);
declare @StrPrc			nvarchar(max);
declare @StrAmt			nvarchar(max);
declare @StrAtm			nvarchar(max);
declare @StrQtyR		nvarchar(max);
declare @StrPrcR		nvarchar(max);
declare @StrAmtR		nvarchar(max);
declare @StrAtmR		nvarchar(max);

DECLARE @IsCurrency		Bit;
DECLARE @SH				NVarChar(50);
DECLARE @SD				NVarChar(50);
	
DECLARE @WithTaxToll	Bit;
DECLARE @WithoutTaxToll	Bit;

-- ======
DECLARE @goods_id					Varchar(20);
DECLARE @acnt_code					Varchar(20);
DECLARE @sale_quantity				DECIMAL(28,9);
DECLARE @ret_quantity				DECIMAL(28,9);

-- ======
DECLARE @unit_name			nvarchar(200);
DECLARE @unit_id			varchar(20);
DECLARE @unit_value			float;
DECLARE @unit_value_Temp	float;
DECLARE @Mainunit_value		float;
DECLARE @Cnt				INT;

-- ======
DECLARE @unit_nameSale1			nvarchar(200);
DECLARE @unit_idSale1			varchar(20);
DECLARE @unit_valueSale1		float;
DECLARE @Mainunit_valueSale1	float;

DECLARE @unit_nameSale2			nvarchar(200);
DECLARE @unit_idSale2			varchar(20);
DECLARE @unit_valueSale2		float;
DECLARE @Mainunit_valueSale2	float;

-- ======
DECLARE @unit_nameRet1			nvarchar(200);
DECLARE @unit_idRet1			varchar(20);
DECLARE @unit_valueRet1			float;
DECLARE @Mainunit_valueRet1		float;

DECLARE @unit_nameRet2			nvarchar(200);
DECLARE @unit_idRet2			varchar(20);
DECLARE @unit_valueRet2			float;
DECLARE @Mainunit_valueRet2		float;

DECLARE @bolMainAndSubUnit	Bit;

DECLARE @MainAndSubUnit  bit;
Declare @GoodsReciverID as INT
Declare @NoReward as INT
Declare @OnlyReward as INT
	

DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @LayerAcntRemain		int;
DECLARE @StartLayerAcntRemain	int;
DECLARE @LenLayerAcntRemain		int;
DECLARE @SelectedVisitor21		Int ;
DECLARE @SelectedVisitor22		Int ;
DECLARE @SelectedVisitor23		Int ;
DECLARE @SelectedVisitor24		Int ;
DECLARE @UseVchBy0				Bit;  
DECLARE @UseVchBy1				Bit;  
DECLARE @IsMultiplex			Bit;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;	 

	--================================== UnitPart
	DECLARE @UnitPart	TINYINT
	SET @UnitPart  = 1
	
	Select @LayerAcntRemain=acc.FunGetAcntInfoForRemain(1 )
	Select @StartLayerAcntRemain=acc.FunGetAcntInfoForRemain(2 )
	Select @LenLayerAcntRemain=acc.FunGetAcntInfoForRemain(3 )


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
	--==================================
	
	----==================================
	--begin try
	--	drop table #tbl_Tmp
	--end try
	--begin catch
	--end catch
	
	--begin try
	--	drop table #tbl_result
	--end try
	--begin catch
	--end catch
	
	-- ==========
	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	IF @QuantityDecimalsToForms>0
		SET		@QuantityDecimalsToForms = @QuantityDecimalsToForms - 1
		
	Create Table #tbl_Tmp
	(
		AcntCode				varchar(20) collate Arabic_CS_AS null,
		GoodsID					varchar(20) collate Arabic_CS_AS null,
		SaleGoodsQuantity		DECIMAL(28,9),
		RetGoodsQuantity		DECIMAL(28,9)
	);
	
	Create Table #tbl_result
	(
		AcntCode				varchar(20) collate Arabic_CS_AS null,
		GoodsID					varchar(20) collate Arabic_CS_AS null,
		QuantitySale			DECIMAL(28,9),
		QuantityRet				DECIMAL(28,9),
		UnitNameSale1			nvarchar(20) collate Arabic_CS_AS null,
		QuantitySale1			DECIMAL(28,9),
		UnitNameSale2			nvarchar(20) collate Arabic_CS_AS null,
		QuantitySale2			DECIMAL(28,9),
		UnitNameRet1			nvarchar(20) collate Arabic_CS_AS null,
		QuantityRet1			DECIMAL(28,9),
		UnitNameRet2			nvarchar(20) collate Arabic_CS_AS null,
		QuantityRet2			DECIMAL(28,9)
	);
		
	Declare @tbl_units as table
	(
		unit_id					varchar(20) not null, 
		unit_name				nvarchar(200) not null, 
		unit_value				float not null,
		Mainunit_value			float not null,
		cnt						int not null--,
	);
	
	-- Init Variables --------
	IF (@RepOptions Is Null)	SET @RepOptions = '110001111111'
	IF (@ProcessNo  Is Null)	SET @ProcessNo = 1;
	IF (@DocStep	Is Null)	SET @DocStep = 0;
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null#null';
	IF (@ExtraParams	Is Null)SET @ExtraParams = '@0@@@-1@-1';

	IF (@DocDateFr	Is Null)	SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)	SET @DocDateTo = '@@@';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0;
	IF (@SelectedStore2 Is Null)	SET @SelectedStore2 = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;
	IF (@SelectedOrders1 Is Null)	SET @SelectedOrders1 = 0;
	IF (@SelectedOrders2 Is Null)	SET @SelectedOrders2 = 0;
	IF (@SelectedOrders3 Is Null)	SET @SelectedOrders3 = 0;
	IF (@SelectedOrders4 Is Null)	SET @SelectedOrders4 = 0;
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0;
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0;
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0;
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0;

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	set @SelectedProduct = 0;

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
		SET @Dist9	= pub.funSplitString(@DistributeInfo, '#', 13);
		SET @Dist10	= pub.funSplitString(@DistributeInfo, '#', 14);
		SET @Dist11	= pub.funSplitString(@DistributeInfo, '#', 15);
		SET @Dist12	= pub.funSplitString(@DistributeInfo, '#', 16);		
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
		SET @Dist9	= 'null';
		SET @Dist10	= 'null';
		SET @Dist11	= 'null';
		SET @Dist12	= 'null';		
	End

	SET @ShowQuantity	= Substring(@RepOptions, 1, 1);
	SET @ShowPrice		= Substring(@RepOptions, 2, 1);
	SET @ShowOverload	= Substring(@RepOptions, 3, 1);
	SET @ShowZeroRows	= Substring(@RepOptions, 4, 1);
	SET @DecReturn		= Substring(@RepOptions, 5, 1);
	SET @UseAmount		= Substring(@RepOptions, 6, 1);

	SET @PID1			= Substring(@RepOptions, 9, 1)
	SET @PID2			= Substring(@RepOptions, 10, 1)
	SET @PID3			= Substring(@RepOptions, 11, 1)
	SET @ShowDiscount	= Substring(@RepOptions, 12, 1)
	SET @RefY			= Substring(@RepOptions, 13, 1)
	SET @RefN			= Substring(@RepOptions, 14, 1)
	SET @DecByRef		= Substring(@RepOptions, 16, 1)
	SET @ApplyDateToRet = Substring(@RepOptions, 17, 1)
	SET @IsCurrency		= Substring(@RepOptions, 18, 1)
	SET @WithTaxToll	= Substring(@RepOptions, 21, 1)
	SET @WithoutTaxToll	= Substring(@RepOptions, 22, 1)
	SET @ShowAfterSaleDiscount	= Substring(@RepOptions, 24, 1)
	SET @ShowRetDiscount		= Substring(@RepOptions, 25, 1)

	SET @UseVchBy0		= Substring(@RepOptions, 26, 1)
	SET @UseVchBy1		= Substring(@RepOptions, 27, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @Code1 = 55;  -- Buy
	SET @Code2 = 70;  -- Produce
	SET @Code3 = 90;  -- Sale
	SET @Code4 = 110; -- Use

	SET @RetCode1 = 60;  -- Buy Ret
	SET @RetCode2 = 75;  -- Produce Ret
	SET @RetCode3 = 100; -- Sale Ret
	SET @RetCode4 = 115; -- Use Ret

	SET @ProcessID_Ret =
		Case @ProcessID 
			When @Code1 Then @RetCode1
			When @Code2 Then @RetCode2
			When @Code3 Then @RetCode3
			When @Code4 Then @RetCode4
			Else 0
		End

	SET @CustKind		 = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @SelectedProduct = LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @Location		 = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @Location2		 = LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @PriceFr		 = LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @PriceTo		 = LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @BuyTypeID		 = LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @GroupByLayer	 = LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @LayerLen		 = LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @GoodsPart		 = LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	SET @MainAndSubUnit	 = LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	SET @GoodsReciverID	 = LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	SET @NoReward		 = LTrim(pub.funSplitString(@ExtraParams, '@', 13));
	SET @CampaignID	     = pub.funSplitString(@ExtraParams,'@',14);
	SET @VisitPathID1 	 = pub.funSplitString(@ExtraParams, '@', 15);
	SET @VisitPathID2	 = pub.funSplitString(@ExtraParams, '@', 16);
	SET @VisitPathID3	 = pub.funSplitString(@ExtraParams, '@', 17);
	SET @VisitPathID4	 = pub.funSplitString(@ExtraParams, '@', 18);
	SET @SalesRoomClass	 = pub.funSplitString(@ExtraParams, '@', 19);
	SET @OnlyReward		 = LTrim(pub.funSplitString(@ExtraParams, '@', 20));
	SET @ProcessNo2		 = LTrim(pub.funSplitString(@ExtraParams, '@', 21));
	set @SelectedVisitor21		= LTrim(pub.funSplitString(@ExtraParams, '@', 22));
	set @SelectedVisitor22		= LTrim(pub.funSplitString(@ExtraParams, '@', 23));
	set @SelectedVisitor23		= LTrim(pub.funSplitString(@ExtraParams, '@', 24));
	set @SelectedVisitor24		= LTrim(pub.funSplitString(@ExtraParams, '@', 25));
	set @IsMultiplex			= LTrim(pub.funSplitString(@ExtraParams, '@', 28));

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
	-- --------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	SET @StrSelect_Rem	 = '';
	SET @StrWhere_Rem	 = '';
	Set @StrWhere		 = '(D.ProcessID in (' + @StrPID + '))'
	Set @StrWhereRet	 = '(D.ProcessID in (' + ltrim(str(@ProcessID_Ret)) + '))'
	Set @StrWhereDis	 = '(H.ProcessID in (' + @StrPID + '))'
	Set @StrWhereRetDis	 = '(H.ProcessID in (' + ltrim(str(@ProcessID_Ret))  + '))'
	
	Set @StrWhereTaxToll = '1 = 1'

	if not (@RefY = 1)
		set @StrWhere = @StrWhere + ' AND (D.BaseSerialNo=0)'
	if not (@RefN = 1)
		set @StrWhere = @StrWhere + ' AND (D.BaseSerialNo<>0)'

	if (@CustKind <> '')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'

	if (@Location <> '')
	begin
		Set @StrWhere = @StrWhere + ' AND (Left(H.LocationID, ' + str(len(@Location)) + ') >= ''' + @Location + ''')'
		Set @StrWhereDis = @StrWhereDis + ' AND (Left(H.LocationID, ' + str(len(@Location)) + ') >= ''' + @Location + ''')'
		Set @StrWhereRetDis = @StrWhereRetDis + ' AND (Left(H.LocationID, ' + str(len(@Location)) + ') >= ''' + @Location + ''')'
	end
	if (@Location2 <> '')
	begin
		Set @StrWhere = @StrWhere + ' AND (Left(H.LocationID, ' + str(len(@Location2)) + ') <= ''' + @Location2 + ''')'
		Set @StrWhereDis = @StrWhereDis + ' AND (Left(H.LocationID, ' + str(len(@Location2)) + ') <= ''' + @Location2 + ''')'
		Set @StrWhereRetDis = @StrWhereRetDis + ' AND (Left(H.LocationID, ' + str(len(@Location2)) + ') <= ''' + @Location2 + ''')'
	end

	If (@SaleTypeID Is Not Null)
	begin
		Set @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @SaleTypeID + ''')'
		Set @StrWhereDis = @StrWhereDis + ' AND (SaleTypeID = ''' + @SaleTypeID + ''')'
		Set @StrWhereRetDis = @StrWhereRetDis + ' AND (SaleTypeID = ''' + @SaleTypeID + ''')'
	end
	If (@BuyTypeID <> '')
	begin
		Set @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @BuyTypeID + ''')'
		Set @StrWhereDis = @StrWhereDis + ' AND (SaleTypeID = ''' + @BuyTypeID + ''')'
		Set @StrWhereRetDis = @StrWhereRetDis + ' AND (SaleTypeID = ''' + @BuyTypeID + ''')'
	end

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

	IF ((@Dist9 <> 'null') And (@Dist9 <> '0') And (@Dist10 <> '')) And ((@Dist10 = 'null') Or (@Dist10 = '0') Or (@Dist9 = ''))
		SET @StrWhere = @StrWhere + ' AND (HH.DistributerID1 = '''' AND HH.DistributerID2 = '''')'
	IF ((@Dist10 <> 'null') And (@Dist10 <> '0') And (@Dist10 <> '')) And ((@Dist9 = 'null') Or (@Dist9 = '0') Or (@Dist9 = ''))
		SET @StrWhere = @StrWhere + ' AND (HH.DistributerID1 <> '''' OR HH.DistributerID2 <> '''')'				

	IF (@Dist11 <> 'null') And (@Dist11 <> '0') And (@Dist11 <> '')
		SET @StrWhere = @StrWhere + ' AND (DH.DistributDate >= ''' + @Dist11 + ''')'
	IF (@Dist12 <> 'null') And (@Dist12 <> '0') And (@Dist12 <> '')
		SET @StrWhere = @StrWhere + ' AND (DH.DistributDate <= ''' + @Dist12 + ''')'		
		
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

	IF (@UseVchBy0 = 0)
		SET @StrWhere = @StrWhere + ' AND CASE WHEN D.BaseProcessID = 610 THEN 
										  (SELECT TOP 1 T.VchNo FROM pln.tblTaskOrderHdr T 
										   WHERE T.ProcessID = D.BaseProcessID and T.ProcessNo = D.BaseProcessNo and T.FiscalYear = D.BaseFiscalYear and T.SerialNo = D.BaseSerialNo ) 
										   ELSE H.VchNo END <> 0'
	IF (@UseVchBy1 = 0)
		SET @StrWhere = @StrWhere + ' AND CASE WHEN D.BaseProcessID = 610 THEN 
										  (SELECT TOP 1 T.VchNo FROM pln.tblTaskOrderHdr T 
										   WHERE T.ProcessID = D.BaseProcessID and T.ProcessNo = D.BaseProcessNo and T.FiscalYear = D.BaseFiscalYear and T.SerialNo = D.BaseSerialNo ) 
										   ELSE H.VchNo END = 0'
	If (@ProcessNo Is Not Null AND @ProcessNo > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo in (' + LTrim(Str(@ProcessNo)) + '))'
		SET @StrWhereRet = @StrWhereRet + ' AND (D.ProcessNo in (' + LTrim(Str(@ProcessNo)) + '))'
		SET @StrWhereDis = @StrWhereDis + ' AND (H.ProcessNo in (' + LTrim(Str(@ProcessNo)) + '))'
		SET @StrWhereRetDis = @StrWhereRetDis + ' AND (H.ProcessNo in (' + LTrim(Str(@ProcessNo)) + '))'
		
	end
	else
	begin
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo in (' + @ProcessNo2 + '))'
		SET @StrWhereRet = @StrWhereRet + ' AND (D.ProcessNo in (' + @ProcessNo2 + '))'
		SET @StrWhereDis = @StrWhereDis + ' AND (H.ProcessNo in (' + @ProcessNo2 + '))'
		SET @StrWhereRetDis = @StrWhereRetDis + ' AND (H.ProcessNo in (' + @ProcessNo2 + '))'
	end	  	
	
	If (@SerialNoFr Is Not Null)
		begin
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
		Set @StrWhereRet = @StrWhereRet + ' AND (H.BaseFiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.BaseFiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.BaseSerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
		Set @StrWhereDis = @StrWhereDis + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
		Set @StrWhereRetDis = @StrWhereRetDis + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
		end
	If (@SerialNoTo Is Not Null)
		begin
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		Set @StrWhereRet = @StrWhereRet + ' AND (D.BaseFiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.BaseFiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.BaseSerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		Set @StrWhereDis = @StrWhereDis + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		Set @StrWhereRetDis = @StrWhereRetDis + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		end

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
		begin
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
		SET @StrWhereRet = @StrWhereRet + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
		end
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
		begin
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
		SET @StrWhereRet = @StrWhereRet + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
		end
	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
		begin
		SET @StrWhereDis = @StrWhereDis + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
		SET @StrWhereRetDis = @StrWhereRetDis + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate', 'H.DocDate2', 'H.DocDate3')
		end
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
		begin
		SET @StrWhereDis = @StrWhereDis + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
		SET @StrWhereRetDis = @StrWhereRetDis + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate', 'H.DocDate2', 'H.DocDate3')
		end

	if (@ApplyDateToRet = 1)
	begin
		IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
			begin
			SET @StrWhereRet = @StrWhereRet + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'D.DocDate', 'D.DocDate', 'D.DocDate', 'D.DocDate')
			SET @StrWhereRetDis = @StrWhereRetDis + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate', 'H.DocDate', 'H.DocDate')
			end
		IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
			begin
			SET @StrWhereRet = @StrWhereRet + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'D.DocDate', 'D.DocDate', 'D.DocDate', 'D.DocDate')
			SET @StrWhereRetDis = @StrWhereRetDis + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate', 'H.DocDate', 'H.DocDate')
			end
	end

	If (@VchNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND H.VchNo >= ' + LTrim(Str(@VchNoFr))
	If (@VchNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND H.VchNo <= ' + LTrim(Str(@VchNoTo))

	If (@VchNoFr Is Not Null)
		begin
		Set @StrWhereDis = @StrWhereDis + ' AND H.VchNo >= ' + LTrim(Str(@VchNoFr))
		Set @StrWhereRetDis = @StrWhereRetDis + ' AND H.VchNo >= ' + LTrim(Str(@VchNoFr))
		end 
	If (@VchNoTo Is Not Null)
		begin
		Set @StrWhereDis = @StrWhereDis + ' AND H.VchNo <= ' + LTrim(Str(@VchNoTo))
		Set @StrWhereRetDis = @StrWhereRetDis + ' AND H.VchNo <= ' + LTrim(Str(@VchNoTo))
		end 

	If (@SelectedProduct > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'H.ProductID') 

	If (@SelectedGoods > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	end
	
	If (@SelectedStore > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhereDis = @StrWhereDis + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 
		SET @StrWhereRetDis = @StrWhereRetDis + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 
	end
	
	If (@SelectedStore2 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')
	end

	if (@GoodsReciverID > 0) 
	BEGIN
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsReciverID, 'H.GoodsReciverID')
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsReciverID, 'H.GoodsReciverID')
	END
	
	If (@NoReward > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND D.IsReward=0  AND D.IsReward0=0  ' 
		SET @StrWhereRet = @StrWhereRet + ' AND D.IsReward=0  AND D.IsReward0=0  ' 
	end

	If (@OnlyReward > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND D.IsReward=1  ' 
		SET @StrWhere2 = @StrWhere2 + ' AND D.IsReward=1  ' 
	end	

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	If (@SelectedAcnt1 > 0)
		begin
		SET @StrWhereDis = @StrWhereDis + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
		SET @StrWhereRetDis = @StrWhereRetDis + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	end	
	If (@SelectedAcnt2 > 0)
		begin
		SET @StrWhereDis = @StrWhereDis + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
		SET @StrWhereRetDis = @StrWhereRetDis + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	end	
	If (@SelectedAcnt3 > 0)
		begin
		SET @StrWhereDis = @StrWhereDis + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
		SET @StrWhereRetDis = @StrWhereRetDis + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	end	
	If (@SelectedAcnt4 > 0)
		begin
		SET @StrWhereDis = @StrWhereDis + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')
		SET @StrWhereRetDis = @StrWhereRetDis + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')
	end	

	If (@SelectedAcnt1 > 0)
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	If (@SelectedOrders1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders1, 'D.OrderAcntCode') 
	If (@SelectedOrders2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders2, 'D.OrderAcntCode') 
	If (@SelectedOrders3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders3, 'D.OrderAcntCode') 
	If (@SelectedOrders4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders4, 'D.OrderAcntCode')

	If (@SelectedVisitor1 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
		SET @StrWhereRet = @StrWhereRet + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	end
	If (@SelectedVisitor2 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
		SET @StrWhereRet = @StrWhereRet + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	end
	If (@SelectedVisitor3 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
		SET @StrWhereRet = @StrWhereRet + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	end
	If (@SelectedVisitor4 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'
		SET @StrWhereRet = @StrWhereRet + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'
	end

	If (@SelectedVisitor21 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor21, 'H.VisitorAcntCode2') + ')'
		SET @StrWhereRet = @StrWhereRet + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor21, 'H.VisitorAcntCode2') + ')'
	end
	If (@SelectedVisitor22 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor22, 'H.VisitorAcntCode2') + ')'
		SET @StrWhereRet = @StrWhereRet + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor22, 'H.VisitorAcntCode2') + ')'
	end
	If (@SelectedVisitor23 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor23, 'H.VisitorAcntCode2') + ')'
		SET @StrWhereRet = @StrWhereRet + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor23, 'H.VisitorAcntCode2') + ')'
	end
	If (@SelectedVisitor24 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor24, 'H.VisitorAcntCode2') + ')'
		SET @StrWhereRet = @StrWhereRet + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor24, 'H.VisitorAcntCode2') + ')'
	end
	IF (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep = ' + LTrim(Str(@DocStep)) + ')'
	IF (@DocStep > 0)
		begin
		SET @StrWhereDis = @StrWhereDis + ' AND (H.DocStep = ' + LTrim(Str(@DocStep)) + ')'
		SET @StrWhereRetDis = @StrWhereRetDis + ' AND (H.DocStep = ' + LTrim(Str(@DocStep)) + ')'
		end
	IF (@WithTaxToll = 1) And (@WithoutTaxToll = 0)
		SET @StrWhere = @StrWhere + ' AND ((H.TaxOverWorthCost > 0 OR H.TollOverWorthCost > 0) AND (D.TaxOverWorthCostDtl > 0 OR D.TollOverWorthCostDtl > 0))'
		--SET @StrWhereTaxToll = @StrWhereTaxToll + ' AND (M.TaxOverWorthCost > 0 OR M.TollOverWorthCost > 0)'

	IF (@WithoutTaxToll = 1) And (@WithTaxToll = 0)
		SET @StrWhere = @StrWhere + ' AND ((H.TaxOverWorthCost = 0 And H.TollOverWorthCost = 0) AND (D.TaxOverWorthCostDtl = 0 OR D.TollOverWorthCostDtl = 0))'
		--SET @StrWhereTaxToll = @StrWhereTaxToll + ' AND (M.TaxOverWorthCost <= 0 And M.TollOverWorthCost <= 0)'
 
	IF (@ShowZeroRows = '0')
		SET @StrWhereTaxToll = @StrWhereTaxToll + ' AND Quantity <> 0'
	--ELSE IF (@ShowZeroRows = '1')
	--	SET @StrWhereTaxToll = ' AND Quantity <> 0'
	
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
	--===============================================================================
	-- ******************************************************************************
	SET @StrSelect = '
	INSERT INTO  #tbl_Tmp
	Select Sale.AcntCode, Sale.GoodsID, 
		   IsNull(Sum(Sale.GoodsQuantity),0) SaleGoodsQuantity, IsNull(Sum(Ret.GoodsQuantity),0) RetGoodsQuantity
	From (
	select  H.AcntCode, D.GoodsID, SUM(D.GoodsQuantity) GoodsQuantity
	from	inv.tblStorageDocsHdr H
	Inner Join inv.tblStorageDocsDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And
										  D.SerialNo = H.SerialNo
	Left Join sal.tblDistributionsHdr DH ON DH.ProcessID = H.BaseDistributionProcessID And
										     DH.SerialNo = H.BaseDistributionSerialNo 											  
	Where  (H.ProcessID = 90) And ' + @StrWhere + '
	Group By H.AcntCode,D.GoodsID
	) Sale
	Left Join 
	( 
		select  H.AcntCode, D.GoodsID, SUM(D.GoodsQuantity) GoodsQuantity
		from	inv.tblStorageDocsHdr H
		Inner Join inv.tblStorageDocsDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And
											  D.SerialNo = H.SerialNo
		Left Join sal.tblDistributionsHdr DH ON DH.ProcessID = H.BaseDistributionProcessID And
												 DH.SerialNo = H.BaseDistributionSerialNo 											  
		where  (H.ProcessID = 100) And ' + @StrWhere + '
		group by H.AcntCode,D.GoodsID
	) Ret ON Sale.AcntCode = Ret.AcntCode And Sale.GoodsID = Ret.GoodsID
	Group By Sale.AcntCode, Sale.GoodsID'
	
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;

	-- ******************************************************************************	
	--===============================================================================
	INSERT INTO #tbl_result
	SELECT  AcntCode,
			GoodsID,
			SaleGoodsQuantity,
			RetGoodsQuantity,
			UName1,			
			FLOOR(SaleGoodsQuantity / U1) SaleQuantity1,
			UName2,
			FLOOR(CASE WHEN U2 = 0 then 0 ELSE (SaleGoodsQuantity - (FLOOR(SaleGoodsQuantity / U1) * U1))/U2 END )SaleQuantity2,
			UName1,
			FLOOR(RetGoodsQuantity / U1) RetQuantity1,
			UName2,
			FLOOR(CASE WHEN U2 = 0 then 0 ELSE (RetGoodsQuantity - (FLOOR(RetGoodsQuantity / U1) * U1))/U2 END ) RetQuantity2
	FROM (
			Select Sale.AcntCode, Sale.GoodsID, 
				   IsNull(Sum(Sale.GoodsQuantity),0) SaleGoodsQuantity, IsNull(Sum(Ret.GoodsQuantity),0) RetGoodsQuantity,
				   (
					   Select Top 1 (t.MainUnitValue/ t.UnitValue)
					   From
						   (
								select UnitID, 1 As UnitValue,1 MainUnitValue
								from inv.tblGoods
								where GoodsID = Sale.GoodsID
								union
								select SubUnitID, UnitValue,MainUnitValue
								from inv.tblSubUnitsDtl S
								where GoodsID = Sale.GoodsID And ShowInInvoice = 1
								
							) t 
						Inner Join inv.tblUnitsDtl u On u.UnitID = t.UnitID and u.LanguageID = 1
						order by (t.MainUnitValue/ t.UnitValue) desc
					) U1,
					(
					 Select top 1 u.UnitName
					 From
						(
							select UnitID, 1 As UnitValue,1 MainUnitValue
							from inv.tblGoods
							where GoodsID = Sale.GoodsID
							union
							select SubUnitID, UnitValue,MainUnitValue
							from inv.tblSubUnitsDtl S
							where GoodsID = Sale.GoodsID And ShowInInvoice = 1
							
						) t 
					 Inner Join inv.tblUnitsDtl u On u.UnitID = t.UnitID and u.LanguageID = 1
					 order by (t.MainUnitValue/ t.UnitValue) desc
					) UName1,
				   ISNULL((
	   						Select UU 
	   						From 
	   							(
	   								Select (t.MainUnitValue/ t.UnitValue) UU,ROW_NUMBER()over(order by (t.MainUnitValue/ t.UnitValue) desc) R
									From
									(
										select UnitID, 1 As UnitValue,1 MainUnitValue
										from inv.tblGoods
										where GoodsID = Sale.GoodsID
										union
										select SubUnitID, UnitValue,MainUnitValue
										from inv.tblSubUnitsDtl S
										where GoodsID = Sale.GoodsID And ShowInInvoice = 1
									) t inner join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = 1
	   							) U2 WHERE R = 2
	   						  ), 0) U2,
				   ISNULL((
							Select UnitName 
							From 
								(
									select UnitName,ROW_NUMBER()over(order by (t.MainUnitValue/ t.UnitValue) desc) R
									from
										(
											select UnitID, 1 As UnitValue,1 MainUnitValue
											from inv.tblGoods
											where GoodsID = Sale.GoodsID
											union
											select SubUnitID, UnitValue,MainUnitValue
											from inv.tblSubUnitsDtl S
											where GoodsID = Sale.GoodsID And ShowInInvoice = 1
										) t 
									Inner Join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = 1
								) U2 WHERE R = 2
							), '') UName2,
				   ISNULL((
	  						Select UU 
	  						From 
	  							(
	  								select (t.MainUnitValue/ t.UnitValue) UU,ROW_NUMBER()over(order by (t.MainUnitValue/ t.UnitValue) desc) R
									from
									(
										select UnitID, 1 As UnitValue,1 MainUnitValue
										from inv.tblGoods
										where GoodsID = Sale.GoodsID
										union
										select SubUnitID, UnitValue,MainUnitValue
										from inv.tblSubUnitsDtl S
										where GoodsID = Sale.GoodsID And ShowInInvoice = 1
									) t inner join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = 1
	  							) U3 WHERE R = 3
	  						),0) U3,
				   ISNULL((
							Select UnitName 
							From 
								(
									select UnitName ,ROW_NUMBER()over(order by (t.MainUnitValue/ t.UnitValue) desc) R
									from
									(
										select UnitID, 1 As UnitValue,1 MainUnitValue
										from inv.tblGoods
										where GoodsID = Sale.GoodsID
										union
										select SubUnitID, UnitValue,MainUnitValue
										from inv.tblSubUnitsDtl S
										where GoodsID = Sale.GoodsID And ShowInInvoice = 1
									) t inner join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = 1
								) U3 WHERE R = 3
							),'') UName3 
			From (
					select  H.AcntCode, D.GoodsID, SUM(D.GoodsQuantity) GoodsQuantity
					from	inv.tblStorageDocsHdr H
					Inner Join inv.tblStorageDocsDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And
														  D.SerialNo = H.SerialNo
					Left Join sal.tblDistributionsHdr DH ON DH.ProcessID = H.BaseDistributionProcessID And
															 DH.SerialNo = H.BaseDistributionSerialNo 											  
					Where  (H.ProcessID = 90) And (D.ProcessID in (90)) AND (D.ProcessNo in (@ProcessNo))
					Group By H.AcntCode,D.GoodsID
					) Sale
			Left Join 
				( 
					select  H.AcntCode, D.GoodsID, SUM(D.GoodsQuantity) GoodsQuantity
					from	inv.tblStorageDocsHdr H
					Inner Join inv.tblStorageDocsDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And
														  D.SerialNo = H.SerialNo
					Left Join sal.tblDistributionsHdr DH ON DH.ProcessID = H.BaseDistributionProcessID And
															 DH.SerialNo = H.BaseDistributionSerialNo 											  
					where  (H.ProcessID = 100) And (D.ProcessID in (90)) AND (D.ProcessNo in (@ProcessNo))
					group by H.AcntCode,D.GoodsID
				) Ret ON Sale.AcntCode = Ret.AcntCode And Sale.GoodsID = Ret.GoodsID
			Group By Sale.AcntCode, Sale.GoodsID
		) a
	
	--Select * From #tbl_Tmp
	--Select * From #tbl_result Order By AcntCode
	-- ******************************************************************************
	-- *********************************** Units ************************************
	-- ******************************************************************************
	--declare cur_goods cursor for
	--	select AcntCode, GoodsID, SaleGoodsQuantity, RetGoodsQuantity
	--	from #tbl_Tmp
	--open cur_goods;
		
	--fetch next from cur_goods into @acnt_code, @goods_id, @sale_quantity, @ret_quantity

	--while (@@fetch_status = 0)
	--begin
	--	-- 1- empty units table
	--	delete from @tbl_units
		
	--	-- 2- fill units of 1 goods
	--	insert into @tbl_units
	--	select top 3 t.UnitID, u.UnitName, t.UnitValue, t.MainUnitValue,
	--	(SELECT COUNT(*) 
	--	 from(
	--			select UnitID, 1 As UnitValue,1 MainUnitValue
	--			from inv.tblGoods
	--			where GoodsID = @goods_id
	--			union
	--			select SubUnitID, UnitValue,MainUnitValue
	--			from inv.tblSubUnitsDtl S
	--			where GoodsID = @goods_id And ShowInInvoice = 1) z
	--	)cnt
	--	from
	--	(
	--		select UnitID, 1 As UnitValue,1 MainUnitValue
	--		from inv.tblGoods
	--		where GoodsID = @goods_id
	--		union
	--		select SubUnitID, UnitValue,MainUnitValue
	--		from inv.tblSubUnitsDtl S
	--		where GoodsID = @goods_id And ShowInInvoice = 1
			
	--	) t inner join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = @LangID
	--	order by (t.MainUnitValue/ t.UnitValue) desc
			
	--	-- read units row by row
	--	declare cur_units cursor for
	--		select *
	--		from @tbl_units
	--	open cur_units;

	--	-- init
	--	set @unit_idSale1			 = '';
	--	set @unit_nameSale1			 = '';
	--	set @unit_valueSale1		 =  0;
	--	set @Mainunit_valueSale1	 =  0;
	--	set @unit_idSale2			 = '';
	--	set @unit_nameSale2			 = '';
	--	set @unit_valueSale2		 =  0;
	--	set @Mainunit_valueSale2	 =  0;	
		
	--	set @unit_idRet1			 = '';
	--	set @unit_nameRet1			 = '';
	--	set @unit_valueRet1			 =  0;
	--	set @Mainunit_valueRet1		 =  0;
	--	set @unit_idRet2			 = '';
	--	set @unit_nameRet2			 = '';
	--	set @unit_valueRet2			 =  0;
	--	set @Mainunit_valueRet2		 =  0;
		
	--	-- First Unit
	--	fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

	--	if (@@fetch_status = 0)
	--	begin
	--		set @unit_idSale1		= @unit_id;
	--		set @unit_nameSale1		= @unit_name;
								
	--		set @unit_idRet1		= @unit_id;
	--		set @unit_nameRet1		= @unit_name;
			
	--		if @Cnt > 1
	--		Begin
	--			set @unit_valueSale1	 = floor((@sale_quantity + 0.000000001) * @unit_value / @Mainunit_value)
	--			set @unit_valueRet1		 = floor((@ret_quantity + 0.000000001) * @unit_value / @Mainunit_value)
	--		End
	--		Else
	--		Begin
	--			set @unit_valueSale1	 = @sale_quantity * @unit_value / @Mainunit_value
	--			set @unit_valueRet1		 = @ret_quantity  * @unit_value / @Mainunit_value
	--		End
			
	--		set @sale_quantity = @sale_quantity - (@unit_valueSale1 * @Mainunit_value / @unit_value)
	--		set @ret_quantity  = @ret_quantity  - (@unit_valueRet1 * @Mainunit_value / @unit_value)

	--		-- Second Unit
	--		fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

	--		if (@@fetch_status = 0)
	--		begin
	--			set @unit_idSale2		= @unit_id;
	--			set @unit_nameSale2		= @unit_name;
				
	--			set @unit_idRet2		= @unit_id;
	--			set @unit_nameRet2		= @unit_name;
				
	--			if @Cnt > 2 
	--			Begin
	--				set @unit_valueSale2	 = floor((@sale_quantity + 0.000000001) * @unit_value / @Mainunit_value)
	--				set @unit_valueRet2		 = floor((@ret_quantity + 0.000000001)  * @unit_value / @Mainunit_value)
	--			End
	--			else	
	--			Begin
	--				set @unit_valueSale2	 = @sale_quantity * @unit_value / @Mainunit_value
	--				set @unit_valueRet2		 = @ret_quantity  * @unit_value / @Mainunit_value
	--			End
				
	--			set @sale_quantity		= @sale_quantity - (@unit_valueSale2 * @Mainunit_value / @unit_value)
	--			set @ret_quantity		= @ret_quantity  - (@unit_valueRet2  * @Mainunit_value / @unit_value)
	--		end;

	--	end;

	--	-- close units cursor
	--	close cur_units;
	--	deallocate cur_units;

	--	-- update result
	--	update #tbl_result
	--	set UnitIDSale1				= IsNull(@unit_idSale1,''),
	--		UnitNameSale1			= IsNull(@unit_nameSale1,''),
	--		QuantitySale1			= IsNull(@unit_valueSale1,0),
	--		UnitIDSale2				= IsNull(@unit_idSale2,''),
	--		UnitNameSale2			= IsNull(@unit_nameSale2,''),
	--		QuantitySale2			= IsNull(@unit_valueSale2,0),

	--		UnitIDRet1				= IsNull(@unit_idRet1,''),
	--		UnitNameRet1			= IsNull(@unit_nameRet1,''),
	--		QuantityRet1			= IsNull(@unit_valueRet1,0),
	--		UnitIDRet2				= IsNull(@unit_idRet2,''),
	--		UnitNameRet2			= IsNull(@unit_nameRet2,''),
	--		QuantityRet2			= IsNull(@unit_valueRet2,0)
	--	from inv.tblGoods G
	--	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LangID
	--	where G.GoodsID = @goods_id AND #tbl_result.GoodsID = @goods_id And #tbl_result.AcntCode = @acnt_code

	--	-- next
	--	fetch next from cur_goods into @acnt_code, @goods_id, @sale_quantity, @ret_quantity
	--end

	---- close goods cursor
	--Close cur_goods;
	--Deallocate cur_goods;
	-- ******************************************************************************
	-- ********************************** Units End *********************************
	-- ******************************************************************************
	--Select * From #tbl_Tmp
	--Select * From #tbl_result Order By AcntCode

	--Select AcntCode, SUM(QuantitySale1) QuantitySale1,SUM(QuantitySale2)QuantitySale2,
	--		 SUM(QuantityRet1) QuantityRet1,SUM(QuantityRet2)QuantityRet2
	--From #tbl_result
	--Group By AcntCode
	--Order By AcntCode
			
	---------------------------------------------------------
	-- Select Clause ----------------------------------------
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

	If (@UseAmount = 1) or (@ProcessID = 60)
		SET @StrPrice = @strGoodsAmount
	Else 
		SET @StrPrice = 'GoodsPrice'
	
	SET @StrQty	= 'D.GoodsQuantity'
	SET @StrPrc	= '(D.GoodsQuantity * D.' + @StrPrice + ')'
	Set @StrAmt = '(D.GoodsQuantity * D.GoodsAmount)'
	SET @StrAtm	= 'D.AtomAmount'
	SET @StrQtyR	= '0'
	SET @StrPrcR	= '0'
	SET @StrAmtR	= '0'
	SET @StrAtmR	= '0'

	IF (@DecReturn = 1) AND (@ProcessID_Ret <> 0) and (@DecByRef = 1)
		SET @StrWhereRet = @StrWhereRet + ' And (D.BaseSerialNo <> 0)'


	SELECT H.AcntCode,GoodsQuantity Quantity, GoodsQuantity Price,	GoodsQuantity Amount, GoodsQuantity Overload,	GoodsQuantity QuantityR
			, GoodsQuantity PriceR, GoodsQuantity AmountR, GoodsQuantity OverloadR
			, GoodsQuantity Discount,GoodsQuantity DiscountRet,GoodsQuantity AfterSaleDiscount ,
		   GoodsQuantity TaxOverWorthCost, GoodsQuantity TollOverWorthCost,
		   GoodsQuantity TaxOverWorthCostDtl, GoodsQuantity TollOverWorthCostDtl,
           H.CCNo, H.CCPrivilege, H.CCDiscount,GoodsQuantity WithoutBaseDoc_Rets
		   into #TblTemp
	FROM inv.tblStorageDocsDtl D
	inner join inv.tblStorageDocsHdr H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
	WHERE 1=0


	SET @StrSelect = ' insert into #TblTemp
	SELECT D.AcntCode,
			' + @StrQty + ' Quantity,
			' + @StrPrc + ' Price,
			' + @StrAmt + ' Amount,
			' + @StrAtm + ' Overload,
			' + @StrQtyR + ' QuantityR,
			' + @StrPrcR + ' PriceR,
			' + @StrAmtR + ' AmountR,
			' + @StrAtmR + ' OverloadR,
			D.DiscountDtl Discount, 0 DiscountRet, 0 AfterSaleDiscount,
			H.TaxOverWorthCost, H.TollOverWorthCost,
			D.TaxOverWorthCostDtl, D.TollOverWorthCostDtl,
			0 CCNo, 0 CCPrivilege, 0 CCDiscount,0 WithoutBaseDoc_Rets
	FROM ' + @SD + ' D 
			INNER JOIN ' + @SH + ' H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
			Left JOIN sal.tblDistributionsHdr DH ON DH.ProcessID = H.BaseDistributionProcessID And
													 DH.SerialNo = H.BaseDistributionSerialNo 				
	WHERE ' + @StrWhere 
	print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect = '
	 insert into #TblTemp
	SELECT H.AcntCode,0 Quantity, 0 Price, 0 Amount, 0 Overload,	0 QuantityR, 0 PriceR, 0 AmountR, 0 OverloadR, 
		   H.Discount + H.Discount2+ H.Discount3 Discount,0 DiscountRet,AfterSaleDiscount ,
		   0 TaxOverWorthCost, 0 TollOverWorthCost,
		   0 TaxOverWorthCostDtl, 0 TollOverWorthCostDtl,
           H.CCNo, H.CCPrivilege, H.CCDiscount,0 WithoutBaseDoc_Rets
	FROM ' + @SH + ' H 
	WHERE ' + @StrWhereDis +'
	and ltrim(str(ProcessID))+''@''+ltrim(str(ProcessNo))+''@''+ltrim(str(FiscalYear))+''@''+ltrim(str(SerialNo))
	in  (
	select ltrim(str(ProcessID))+''@''+ltrim(str(ProcessNo))+''@''+ltrim(str(FiscalYear))+''@''+ltrim(str(SerialNo))
	from 
	' + @SD + ' D 
	WHERE ' + @StrWhere + ')	'

	print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	IF (@DecReturn = 1) AND (@ProcessID_Ret <> 0) --AND (@DecByRef = 0)
	begin
			declare @tblWithoutBaseDoc_Rets NVARCHAR(MAX)
	SELECT @tblWithoutBaseDoc_Rets =[sal].funSaleReturn_Price2(@ProcessID, @ProcessNo, @FiscalYearFr, @SerialNoFr, 
									 @FiscalYearTo, @SerialNoTo, Null, @VchNoFr, @VchNoTo, @DocDateFr, @DocDateTo, 
									 @SaleTypeID, @SelectedGoods, @SelectedStore, @SelectedStore2, @SelectedAcnt1, @SelectedAcnt2, 
									 @SelectedAcnt3, @SelectedAcnt4, @SelectedOrders1,
									 @SelectedOrders2, @SelectedOrders3, @SelectedOrders4, @SelectedVisitor1, @SelectedVisitor2, 
									 @SelectedVisitor3, @SelectedVisitor4, @DistributeInfo, 1, 0, 0, 6, @RepInfo)		
	

		SET @StrSelect =  '
	 insert into #TblTemp
		SELECT D.AcntCode,   
				0 AS Quantity,
				0 AS Price,
				0 Amount,
				0 AS Overload,
				(' + @StrQty + ') QuantityR,
				(' + @StrPrc + ') PriceR,
				(' + @StrAmt + ') AmountR,
				(' + @StrAtm + ') OverloadR,
				0 Discount,D.DiscountDtl DiscountRet,0 AfterSaleDiscount,
				H.TaxOverWorthCost, H.TollOverWorthCost,
				D.TaxOverWorthCostDtl, D.TollOverWorthCostDtl,
				0 CCNo, 0 CCPrivilege,0 CCDiscount,isnull(WithoutBaseDoc_Rets,0) WithoutBaseDoc_Rets
		FROM ' + @SD + ' D 
			INNER JOIN ' + @SH + ' H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
			LEFT JOIN (' + @tblWithoutBaseDoc_Rets + ') WOBDR ON WOBDR.ProcessID = D.ProcessID AND WOBDR.ProcessNo = D.ProcessNo AND 
														WOBDR.FiscalYear = D.FiscalYear AND WOBDR.SerialNo = D.SerialNo 
														AND WOBDR.DocRowNo = D.DocRowNo
	
		WHERE ' + @StrWhereRet 
		
	print @StrSelect;
	Exec sp_executesql @StrSelect;

		
		SET @StrSelect =  ' 
			 insert into #TblTemp

		SELECT H.AcntCode, 0 Quantity, 0 Price, 0 Amount,0 Overload,	0 QuantityR, 0 PriceR, 0 AmountR, 0 OverloadR,0 Discount, H.Discount + H.Discount2+ H.Discount3 DiscountRet,AfterSaleDiscount,
		   0 TaxOverWorthCost, 0 TollOverWorthCost,
		   0 TaxOverWorthCostDtl, 0 TollOverWorthCostDtl,
           H.CCNo, H.CCPrivilege, H.CCDiscount, 0 WithoutBaseDoc_Rets
		FROM ' + @SH + ' H 
			--INNER JOIN ' + @SD + ' D ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
		WHERE ' + @StrWhereRetDis +'
		and ltrim(str(ProcessID))+''@''+ltrim(str(ProcessNo))+''@''+ltrim(str(FiscalYear))+''@''+ltrim(str(SerialNo))
	in  (
	select ltrim(str(ProcessID))+''@''+ltrim(str(ProcessNo))+''@''+ltrim(str(FiscalYear))+''@''+ltrim(str(SerialNo))
	from 
	' + @SD + ' D 
	WHERE ' + @StrWhereRet + ')	'
	print @StrSelect;
	Exec sp_executesql @StrSelect;


	end


	--select * from #TblTemp
	-- select @StrSelect
	-- return 

	------------------------------------------------------------
	SET @StrSelect = '
	SELECT	T.AcntCode,
			SUM(T.Quantity-T.QuantityR) Quantity,
			SUM(T.Price) SalePrice, SUM(T.PriceR) RetPrice,
			SUM(T.Price-T.PriceR) Price,
			SUM(T.Amount-T.AmountR) Amount,
			SUM(T.Overload-T.OverloadR) Overload,
			SUM(T.Discount) Discount,
			SUM(T.DiscountRet) DiscountRet,
			SUM(T.AfterSaleDiscount) AfterSaleDiscount, 
			SUM(T.CCDiscount) CCDiscount,
			SUM(T.TaxOverWorthCost) TaxOverWorthCost,
			SUM(T.TollOverWorthCost) TollOverWorthCost,
			SUM(T.TaxOverWorthCostDtl) TaxOverWorthCostDtl,
			SUM(T.TollOverWorthCostDtl) TollOverWorthCostDtl,
			ROUND(IsNull(R2.QuantitySale1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') SaleQuantity1, 
			ROUND(IsNull(R2.QuantitySale2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') SaleQuantity2,
			ROUND(IsNull(R2.QuantityRet1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RetQuantity1, 
			ROUND(IsNull(R2.QuantityRet2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RetQuantity2
			,Sum(IsNull(T.WithoutBaseDoc_Rets,0) ) WithoutBaseDoc_RetsDtl	
	FROM
	(select * from #TblTemp) T
	LEFT JOIN (Select AcntCode, SUM(QuantitySale1) QuantitySale1,SUM(QuantitySale2)QuantitySale2,
					  SUM(QuantityRet1) QuantityRet1,SUM(QuantityRet2)QuantityRet2
			   From #tbl_result
			   Group By AcntCode) R2 ON R2.AcntCode = T.AcntCode
	GROUP BY  T.AcntCode , R2.QuantitySale1, R2.QuantitySale2, R2.QuantityRet1, R2.QuantityRet2 
	'
	
	--//--------------------------------------------------------



	SET @EP	 = 'Price'
	SET @EP2 = 'Price'

	Set @EA	 = 'Amount'
	Set @EA2 = 'Amount'

	if (@ShowOverload = 1)
		set @EP2 = @EP2 + ' + Overload '
		set @EA2 = @EA2 + ' + Overload '
	if (@ShowDiscount = 1)
		set @EP2 = @EP2 + ' - Discount '
		set @EA2 = @EA2 + ' - Discount '
	if (@ShowAfterSaleDiscount = 1)
		set @EP2 = @EP2 + ' - AfterSaleDiscount '
		set @EA2 = @EA2 + ' - AfterSaleDiscount '
	if (@ShowAfterSaleDiscount = 1)
		set @EP2 = @EP2 + ' + DiscountRet '
		set @EA2 = @EA2 + ' + DiscountRet '
		
	SET @StrSelect = '
	Select M.*, ' + @EP + ' as Price2 , ' + @EP2 + ' as EffectedPrice, ' + @EA + ' as Amount2 , ' + @EA2 + ' as EffectedAmount,
	pub.GetCodeName(M.AcntCode,'+ str(@LangID) +' ) AcntName,NationalIDNumber,EconomicalCode,NationalIdentity,
	ZipCode,Mobile,SMSMobile,OtherTels,Tel,Address1,Address2
	From (' + @StrSelect + ') M
	Left join acc.tblAcnt A on A.AcntCode=substring(M.AcntCode,'+ str(@StartLayerAcntRemain)+','+ str(@LenLayerAcntRemain)+') and A.PartNumber='+ str(@LayerAcntRemain)+'
	left join acc.tblAcntDtl AD  on A.AcntCode=AD.AcntCode and  A.PartNumber=AD.PartNumber
	Where ' + @StrWhereTaxToll
	

	if (@PriceFr <> -1) Or (@PriceTo <> -1)
	begin
		set @StrWhere = '(1=1)'

		if (@PriceFr <> -1)
			Set @StrWhere = @StrWhere + ' AND (EffectedPrice >= ' + str(@PriceFr) + ')'
			Set @StrWhere = @StrWhere + ' AND (EffectedAmount >= ' + str(@PriceFr) + ')'

		if (@PriceTo <> -1)
			Set @StrWhere = @StrWhere + ' AND (EffectedPrice <= ' + str(@PriceTo) + ')'	
			Set @StrWhere = @StrWhere + ' AND (EffectedAmount <= ' + str(@PriceTo) + ')'

		SET @StrSelect = '
		select T.*
		from 
		(' + @StrSelect + '
		) T
		where ' + @StrWhere 
	end

	-- Sort Clause ---------------------------------------------
	IF @SortFields = 'Price DESC'
		SET @SortFields = 'EffectedPrice DESC'
	IF LTRIM(RTRIM(@SortFields)) = 'Price'
		SET @SortFields = 'EffectedPrice '
	
	
	If (@SortFields Is Not Null) AND (@SortFields <> '') 
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------	
END
GO
