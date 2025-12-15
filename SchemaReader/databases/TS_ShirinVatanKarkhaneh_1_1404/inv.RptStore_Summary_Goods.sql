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
Create PROCEDURE [inv].[RptStore_Summary_Goods]
	@ProcessID			Int				= 90,
	@ProcessNo			Int				= Null,
	@FiscalYearFr		Int				= Null,
	@SerialNoFr			Int				= Null,
	@FiscalYearTo		Int				= Null,
	@SerialNoTo			Int				= Null,
	@DocDateFr			VarChar(60)		= Null,
	@DocDateTo			VarChar(60)		= Null,
	@VchNoFr			Int				= Null,
	@VchNoTo			Int				= Null,
	@SelectedGoods		Int				= 0, 
	@SelectedStore		Int				= 0, 
	@SelectedStore2		Int				= 0, 
	@SelectedAcnt1		Int				= 0, 
	@SelectedAcnt2		Int				= 0, 
	@SelectedAcnt3		Int				= 0, 
	@SelectedAcnt4		Int				= 0, 
	@SelectedOrders1	Int				= 0, 
	@SelectedOrders2	Int				= 0, 
	@SelectedOrders3	Int				= 0, 
	@SelectedOrders4	Int				= 0, 
	@SelectedVisitor1	Int				= 0, 
	@SelectedVisitor2	Int				= 0, 
	@SelectedVisitor3	Int				= 0, 
	@SelectedVisitor4	Int				= 0, 
	@DocStep			Int				= 0,  -- مرحله
	@DistributeInfo		NVarChar(2000)	= 'null#null#null#null#null#null#null#null#null#null#null#null#null#null#null',
	@SaleTypeID			varchar(20)		= null,
	@RepOptions			VarChar(50)		= '11000111111001', -- bit array options
	@SortFields			NVarChar(100)	= Null,   -- Order By Field List
	@RepInfo			NVarChar(100)	= '1@1@1@1@1',
	@ExtraParams		NVarChar(200)	= '@0@@@-1@-1@1@6'
WITH ENCRYPTION
AS 
	---- Declarations ---------------
DECLARE @StrSelect		NVarChar(max);
DECLARE @StrSelectDst	NVarChar(max);
DECLARE @StrFrom		NVarChar(max);
DECLARE @StrWhere		NVarChar(max);
DECLARE @StrWhereDst	NVarChar(max);
DECLARE @StrWhere2		NVarChar(max);

DECLARE @StrSelect_Rem	NVarChar(max);
DECLARE @StrWhere_Rem	NVarChar(max);

DECLARE @StrPrice		NVarChar(100);
DECLARE @ProcessNo2		NVarChar(100);

DECLARE @Code1			Int;
DECLARE @Code2			Int;
DECLARE @Code3			Int;
DECLARE @Code4			Int;

DECLARE @RetCode1		Int;
DECLARE @RetCode2		Int;
DECLARE @RetCode3		Int;
DECLARE @RetCode4		Int;
DECLARE	@PriceFr		float;
DECLARE	@PriceTo		float;
DECLARE @UnitPriceTo    float;
DECLARE @UnitPriceFr    float;
DECLARE @EP				VarChar(500);

DECLARE @ProcessID_Ret	Int;

DECLARE @ShowQuantity	Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		Bit;  -- شامل ستون قیمت
DECLARE @ShowOverload	Bit;  -- شامل ستون سربار
DECLARE @ShowDiscount	Bit;  
DECLARE @ShowZeroRows	Bit; -- Not Used; Only for Sync with summary report
DECLARE @DecReturn		Bit; -- Not Used; Only for Sync with summary report
DECLARE @UseAmount		Bit; -- Use Amount Field Instead of Price?
DECLARE @RefY			Bit;
DECLARE @RefN			Bit;
DECLARE @DecByRef		Bit;
DECLARE @ApplyDateToRet	Bit;
DECLARE @GroupByLayer	Bit;
DECLARE @VATY			Bit;
DECLARE @VATN			Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;

DECLARE @StrPID			VarChar(20);
DECLARE @Location		VarChar(20);
DECLARE @Location2		VarChar(20);
DECLARE @PID1			bit;
DECLARE @PID2			bit;
DECLARE @PID3			bit;
DECLARE @LayerLen		int;
DECLARE @GoodsPart		int;

DECLARE @Dist0				NVarChar(20); -- DriverID
DECLARE @Dist1				NVarChar(20); -- DistributerID1
DECLARE @Dist2				NVarChar(20); -- DistributerID2
DECLARE @Dist3				NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4				NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5				NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6				NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7				NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8				NVarChar(20); -- BaseDistributionSerialNo   to
DECLARE @Dist9				NVarChar(20); -- WithoutDistributer
DECLARE @Dist10				NVarChar(20); -- WithDistributer
DECLARE @Dist11				NVarChar(20); -- FromDistributDate
DECLARE @Dist12				NVarChar(20); -- ToDistributDate
DECLARE @CustKind			VarChar(20);
DECLARE @SelectedProduct	int;
DECLARE @BuyTypeID			varchar(20);
DECLARE @UnitID			varchar(20);
DECLARE @UnitName		Nvarchar(100);

declare @StrQty		nvarchar(max);
declare @StrPrc		nvarchar(max);
declare @StrAtm		nvarchar(max);
declare @StrQtyR	nvarchar(max);
declare @StrPrcR	nvarchar(max);
declare @StrAtmR	nvarchar(max);

DECLARE @IsCurrency	Bit;
DECLARE @SH			NVarChar(50);
DECLARE @SD			NVarChar(50);

DECLARE @GroupByStore	Bit;
DECLARE @StoreID1		VarChar(50);
DECLARE @StoreID2		VarChar(50);
DECLARE @StoreIDGB		VarChar(50);

-- ======
DECLARE @goods_id						Varchar(20);
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

DECLARE @MainAndSubUnit			bit;
DECLARE @SubUnitQty				bit;
DECLARE @AfterSaleDiscount		bit;
DECLARE @RetDiscount			bit;
DECLARE @VchNDPrice				bit;
DECLARE @VchDPrice				bit;
DECLARE @IsMultiplex			Bit;

DECLARE @LanguageID			TinyInt;

Declare @GoodsReciverID as INT
Declare @NoReward as INT
Declare @OnlyReward as INT

DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @StartLayerAcntRemain	int;
DECLARE @LenLayerAcntRemain		int;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	SET @LanguageID = pub.funGetCurrentLanguageID();

	Select @StartLayerAcntRemain=acc.FunGetAcntInfoForRemain(2 )
	Select @LenLayerAcntRemain=acc.FunGetAcntInfoForRemain(3 )

	--==============	
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

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
	
	-- Init Variables --------
	IF (@RepOptions Is Null)		SET @RepOptions = '110001111111'
	IF (@ProcessNo  Is Null)		SET @ProcessNo = 1;
	IF (@DocStep	Is Null)		SET @DocStep = 0;
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null#null#null#null';
	IF (@ExtraParams	Is Null)	SET @ExtraParams = '@0@@@-1@-1';

	IF (@DocDateFr	Is Null)		SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)		SET @DocDateTo = '@@@';

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
	SET @GroupByStore	= Substring(@RepOptions, 19, 1)
	SET @VATY			= Substring(@RepOptions, 21, 1)
	SET @VATN			= Substring(@RepOptions, 22, 1)
	SET @SubUnitQty		= Substring(@RepOptions, 23, 1)
	SET @AfterSaleDiscount		= Substring(@RepOptions, 24, 1)
	SET @RetDiscount			= Substring(@RepOptions, 25, 1)
	SET @VchNDPrice				= Substring(@RepOptions, 26, 1)
	SET @VchDPrice				= Substring(@RepOptions, 27, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

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
	SET @BuyTypeID  	 = LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @GroupByLayer	 = LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @LayerLen		 = LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @GoodsPart		 = LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	SET @MainAndSubUnit	 = LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	SET @GoodsReciverID	 = LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	SET @NoReward		 = LTrim(pub.funSplitString(@ExtraParams, '@', 13));
	SET @CampaignID	     = LTrim(pub.funSplitString(@ExtraParams, '@', 14));
	SET @VisitPathID1 	 = LTrim(pub.funSplitString(@ExtraParams, '@', 15));
	SET @VisitPathID2	 = LTrim(pub.funSplitString(@ExtraParams, '@', 16));
	SET @VisitPathID3	 = LTrim(pub.funSplitString(@ExtraParams, '@', 17));
	SET @VisitPathID4	 = LTrim(pub.funSplitString(@ExtraParams, '@', 18));
	SET @SalesRoomClass	 = LTrim(pub.funSplitString(@ExtraParams, '@', 19));
	SET @OnlyReward		 = LTrim(pub.funSplitString(@ExtraParams, '@', 20));
	SET @ProcessNo2		 = LTrim(pub.funSplitString(@ExtraParams, '@', 21));

	SET @UnitPriceFr	 = LTrim(pub.funSplitString(@ExtraParams, '@', 26));
	SET @UnitPriceTo	 = LTrim(pub.funSplitString(@ExtraParams, '@', 27));
	SET @IsMultiplex	 = LTrim(pub.funSplitString(@ExtraParams, '@', 28));

	
	-- ==========
	Declare @QtyStr nvarchar(2000)

	IF @SubUnitQty = 'False'
	BEGIN	
		set @QtyStr = 'D.SubUnitQuantity '
	end
	else
	begin
		set @QtyStr = 'ISNULL(case when (D.SubUnitID = SUD.SubUnitID) then D.SubUnitQuantity else D.GoodsQuantity * (SUD.UnitValue / SUD.MainUnitValue) end,0) '
	end	
	-- ==========
	begin try
		drop table ##tbl_Store_Detailed
	end try
	begin catch
	end catch
		
	begin try
		drop table #tbl_result
	end try
	begin catch
	end catch

	Create Table #tbl_result
	(
		StoreID					varchar(20) collate Arabic_CS_AS null,
		GoodsID					varchar(20) collate Arabic_CS_AS null,
		GoodsName				nvarchar(200) collate Arabic_CS_AS null,
		GoodsQuantity			DECIMAL(28,9),
		UnitIDGoods1			varchar(20) collate Arabic_CS_AS null,
		UnitNameGoods1			nvarchar(20) collate Arabic_CS_AS null,
		GoodsQuantity1			DECIMAL(28,9),
		UnitIDGoods2			varchar(20) collate Arabic_CS_AS null,
		UnitNameGoods2			nvarchar(20) collate Arabic_CS_AS null,
		GoodsQuantity2			DECIMAL(28,9),
		Weight					float,
		Volume					float,
		BarCode					varchar(20) collate Arabic_CS_AS null
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
		
	-- --------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	SET @StrSelect = '';
	SET @StrSelectDst = '';
	SET @StrSelect_Rem = '';
	SET @StrWhere_Rem = '';
	SET @StrWhere = '(D.ProcessID in (' + @StrPID + '))'
	SET @StrWhere2= '(D.ProcessID in (' + ltrim(str(@ProcessID_Ret)) + '))'
	SET @StrWhereDst = 'HH.ProcessID = ' + @StrPID + ' And HH.ProcessNo = 10 '--AND HH.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND HH.BaseDistributionProcessNo = ' + LTrim(@Dist4)		
	
	if not (@RefY = 1)
		set @StrWhere = @StrWhere + ' AND (D.BaseSerialNo=0)'
	if not (@RefN = 1)
		set @StrWhere = @StrWhere + ' AND (D.BaseSerialNo<>0)'

	if (@CustKind <> '')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'

	if (@Location <> '')
		Set @StrWhere = @StrWhere + ' AND (Left(H.LocationID, ' + str(len(@Location)) + ') >= ''' + @Location + ''')'
	if (@Location2 <> '')
		Set @StrWhere = @StrWhere + ' AND (Left(H.LocationID, ' + str(len(@Location2)) + ') <= ''' + @Location2 + ''')'
	IF (@CampaignID > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,' + LTrim(str(@StartLayerAcntRemain)) + ',' + LTrim(str(@LenLayerAcntRemain)) + ') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'CampaignID') +' ) '
	IF (@VisitPathID1 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,' + LTrim(str(@StartLayerAcntRemain)) + ',' + LTrim(str(@LenLayerAcntRemain)) + ') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'VisitPathID1') +' ) '
	IF (@VisitPathID2 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,' + LTrim(str(@StartLayerAcntRemain)) + ',' + LTrim(str(@LenLayerAcntRemain)) + ') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'VisitPathID2') +' ) '
	IF (@VisitPathID3 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,' + LTrim(str(@StartLayerAcntRemain)) + ',' + LTrim(str(@LenLayerAcntRemain)) + ') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'VisitPathID3') +' ) '
	IF (@VisitPathID4 > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,' + LTrim(str(@StartLayerAcntRemain)) + ',' + LTrim(str(@LenLayerAcntRemain)) + ') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'VisitPathID4') +' ) '
	IF (@SalesRoomClass > 0)
	 	    SET @StrWhere = @StrWhere + ' AND  substring(H.AcntCode,' + LTrim(str(@StartLayerAcntRemain)) + ',' + LTrim(str(@LenLayerAcntRemain)) + ') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @SalesRoomClass, 'SalesRoomClass') +' ) '

	If (@SaleTypeID Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @SaleTypeID + ''')'
	If (@BuyTypeID <> '')
		Set @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @BuyTypeID + ''')'

	if @ProcessNo=10
		begin
			If (@Dist0 is not NULL and @Dist0 <> 'null')
				SET @StrWhereDst = @StrWhereDst + ' AND HH.DriverID = ''' + LTrim(@Dist0) + ''''
			If (@Dist1 is not NULL and  @Dist1 <> 'null')
				SET @StrWhereDst = @StrWhereDst + ' AND HH.DistributerID1 = ''' + LTrim(@Dist1) + ''''
			If (@Dist2 is not NULL and  @Dist2 <> 'null')
				SET @StrWhereDst = @StrWhereDst + ' AND HH.DistributerID2 = ''' + LTrim(@Dist2) + ''''
			If (@Dist5 <> 'null')
				SET @StrWhereDst = @StrWhereDst + ' AND HH.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND HH.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
			If (@Dist7 <> 'null')
				SET @StrWhereDst = @StrWhereDst + ' AND HH.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND HH.BaseDistributionSerialNo <= ' + LTrim(@Dist8)
			IF ((@Dist9 <> 'null') And (@Dist9 <> '0') And (@Dist10 <> '')) And ((@Dist10 = 'null') Or (@Dist10 = '0') Or (@Dist9 = ''))
				SET @StrWhereDst = @StrWhereDst + ' AND (HH.DistributerID1 = '''' AND HH.DistributerID2 = '''')'
			IF ((@Dist10 <> 'null') And (@Dist10 <> '0') And (@Dist10 <> '')) And ((@Dist9 = 'null') Or (@Dist9 = '0') Or (@Dist9 = ''))
				SET @StrWhereDst = @StrWhereDst + ' AND (HH.DistributerID1 <> '''' OR HH.DistributerID2 <> '''')'				
			IF (@Dist11 <> 'null') And (@Dist11 <> '0') And (@Dist11 <> '')
				SET @StrWhereDst = @StrWhereDst + ' AND (DH.DistributDate >= ''' + @Dist11 + ''')'
			IF (@Dist12 <> 'null') And (@Dist12 <> '0') And (@Dist12 <> '')
				SET @StrWhereDst = @StrWhereDst + ' AND (DH.DistributDate <= ''' + @Dist12 + ''')'		
		end
	else
		begin
		--@Dist0,@Dist1@Dist2,@Dist9,@Dist10  فیلتر هایی که برای فروش معمولی از پخش استفاده میشود مانند راننده مامور پخش 1 و 2 و برگه های بدون و با مامور
		
			If (@Dist0 <> 'null')
				SET @StrWhere = @StrWhere + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
			If (@Dist1 <> 'null')
				SET @StrWhere = @StrWhere + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
			If (@Dist2 <> 'null')
				SET @StrWhere = @StrWhere + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''
			IF ((@Dist9 <> 'null') And (@Dist9 <> '0') And (@Dist10 <> '')) And ((@Dist10 = 'null') Or (@Dist10 = '0') Or (@Dist9 = ''))
				SET @StrWhere = @StrWhere + ' AND (H.DistributerID1 = '''' AND H.DistributerID2 = '''')'
			IF ((@Dist10 <> 'null') And (@Dist10 <> '0') And (@Dist10 <> '')) And ((@Dist9 = 'null') Or (@Dist9 = '0') Or (@Dist9 = ''))
				SET @StrWhere = @StrWhere + ' AND (H.DistributerID1 <> '''' OR H.DistributerID2 <> '''')'				
			end
		
   If (@ProcessNo Is Not Null AND @ProcessNo > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo in(' + LTrim(Str(@ProcessNo)) + '))'
		SET @StrWhere2 = @StrWhere2 + ' AND (D.ProcessNo in (' + LTrim(Str(@ProcessNo)) + '))'
	end
	else 
	begin
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo in(' + @ProcessNo2 + '))'
		SET @StrWhere2 = @StrWhere2 + ' AND (D.ProcessNo in (' + @ProcessNo2 + '))'
	end	    

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')

	if (@ApplyDateToRet = 1)
	begin
		IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
			SET @StrWhere2 = @StrWhere2 + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'D.DocDate', 'D.DocDate', 'D.DocDate', 'D.DocDate')
		IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
			SET @StrWhere2 = @StrWhere2 + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'D.DocDate', 'D.DocDate', 'D.DocDate', 'D.DocDate')
	end

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

	If (@VchNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND H.VchNo >= ' + LTrim(Str(@VchNoFr))
	If (@VchNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND H.VchNo <= ' + LTrim(Str(@VchNoTo))

		If (@UseAmount = 1) or (@ProcessID = 60)
		  begin 
		     If (@UnitPriceFr <>-1)
			   begin
	         	 Set @StrWhere = @StrWhere + ' AND D.'+ @strGoodsAmount +' >= ' + LTrim(Str(@UnitPriceFr,12))
				 Set @StrWhere2 = @StrWhere2 + ' AND D.'+ @strGoodsAmount +' >= ' + LTrim(Str(@UnitPriceFr,12))	
			   end
	         If (@UnitPriceTo <>-1)
			   begin
		        Set @StrWhere = @StrWhere + ' AND D.'+ @strGoodsAmount +' <= ' + LTrim(Str(@UnitPriceTo,12))
				Set @StrWhere2 = @StrWhere2 + ' AND D.'+ @strGoodsAmount +' <= ' + LTrim(Str(@UnitPriceTo,12))
			   end
		  end
	    Else
		   begin 
		     If (@UnitPriceFr <>-1)
			     begin
	             	Set @StrWhere = @StrWhere + ' AND D.GoodsPrice >= ' + LTrim(Str(@UnitPriceFr,12))
				    Set @StrWhere2 = @StrWhere2 + ' AND D.GoodsPrice >= ' + LTrim(Str(@UnitPriceFr,12))	
				 end
	         If (@UnitPriceTo <>-1)
			     begin
		           Set @StrWhere = @StrWhere + ' AND D.GoodsPrice <= ' + LTrim(Str(@UnitPriceTo,12))
			       Set @StrWhere2 = @StrWhere2 + ' AND D.GoodsPrice <= ' + LTrim(Str(@UnitPriceTo,12))
				 end
		   end 
	
	If (@SelectedProduct > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'H.ProductID') 
		
	If (@SelectedGoods > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	end
	
	If (@NoReward > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND D.IsReward=0  AND D.IsReward0=0  ' 
		SET @StrWhere2 = @StrWhere2 + ' AND D.IsReward=0  AND D.IsReward0=0  ' 
	end
	
	If (@OnlyReward > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND D.IsReward=1  ' 
		SET @StrWhere2 = @StrWhere2 + ' AND D.IsReward=1  ' 
	end	

	If (@SelectedStore > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	end
	
	If (@SelectedStore2 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')
	end

	if (@GoodsReciverID > 0) 
	BEGIN
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsReciverID, 'H.GoodsReciverID')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsReciverID, 'H.GoodsReciverID')
	END

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	If (@SelectedAcnt1 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

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
		SET @StrWhere2 = @StrWhere2 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	end
	If (@SelectedVisitor2 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	end
	If (@SelectedVisitor3 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	end
	If (@SelectedVisitor4 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'
	end
	
	IF (@VATY = 1) And (@VATN = 0)
	Begin
		Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0 OR H.TollOverWorthCost > 0)'
		Set @StrWhere2 = @StrWhere2 + ' AND (H.TaxOverWorthCost > 0 OR H.TollOverWorthCost > 0)'
	End
	IF (@VATN = 1) And (@VATY = 0)
	Begin
		Set @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost <= 0 And H.TollOverWorthCost <= 0)'
		Set @StrWhere2 = @StrWhere2 + ' AND (H.TaxOverWorthCost <= 0 And H.TollOverWorthCost <= 0)'
	End
			
	IF (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep = ' + LTrim(Str(@DocStep)) + ')'
		
	IF (@DecReturn = 1) AND (@ProcessID_Ret <> 0) and (@DecByRef = 1)
		SET @StrWhere2 = @StrWhere2 + ' And (D.BaseSerialNo <> 0)'			
			
	IF (@IsCurrency = 1)
		begin
			set @SH = 'inv.vwStorageHdr_Currency'
			set @SD = 'inv.vwStorageDtl_Currency'
		end
		else
		begin
			set @SH = 'inv.tblStorageDocsHdr'
			set @SD = 'inv.tblStorageDocsDtl'
		end
		
	IF (@GroupByStore = 1)
		Begin
			SET @StoreID1 = 'D.StoreID'
			SET @StoreID2 = 'T.StoreID, T.GoodsID'
			SET @StoreIDGB = 'T.StoreID, T.GoodsID '
		End
	Else
		Begin
			SET @StoreID1 = 'Cast('''' As VarChar(50))'
			SET @StoreID2 = 'T.GoodsID, T.StoreID'
			SET @StoreIDGB = 'T.GoodsID, T.StoreID'
		End
			
	If @ProcessNo=10
	Begin  	   
		SET @StrSelectDst = '
			INNER JOIN 
			(
			 Select Distinct HH.ProcessID, HH.ProcessNo, HH.FiscalYear,HH.SerialNo,DD.RowNo, DD.GoodsID, DD.GoodsQuantity, DD.SubUnitQuantity, DD.GoodsPrice, DD.SubUnitPrice
			 From inv.tblStorageDocsHdr HH
			 Inner Join inv.tblStorageDocsDtl DD ON HH.ProcessID = DD.ProcessID And HH.ProcessNo = DD.ProcessNo And
													HH.FiscalYear = DD.FiscalYear And HH.SerialNo = DD.SerialNo
			 Inner Join sal.tblDistributionsHdr DH ON DH.ProcessID = HH.BaseDistributionProcessID And
													  DH.SerialNo = HH.BaseDistributionSerialNo 													 
			 Where ' + @StrWhereDst + ') HH 
			 ON HH.ProcessID = H.ProcessID And HH.ProcessNo = H.ProcessNo And 
				HH.FiscalYear = H.FiscalYear And HH.SerialNo = H.SerialNo AND HH.RowNo=D.RowNo '

	End				

	if @ProcessID = 60 or @ProcessID = 90
	Begin
	If (@VchDPrice = 1 And @VchNDPrice = 0)
		SET @StrWhere = @StrWhere + ' AND ((D.DocStep >= 3) or (D.DocStep = 0))'
	If (@VchDPrice = 0 And @VchNDPrice = 1)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep <> 3)'
	end

	if @ProcessID = 55 or @ProcessID = 100
	Begin
	If (@VchDPrice = 1 And @VchNDPrice = 0)
		SET @StrWhere = @StrWhere + ' AND ((D.DocStep = 2) or (D.DocStep = 0))'
	If (@VchDPrice = 0 And @VchNDPrice = 1)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep <> 2)'
	end

	if (@VchDPrice = 1 And @VchNDPrice = 1)
		SET @StrWhere = @StrWhere + ''
	If (@VchDPrice = 0 And @VchNDPrice = 0)
		SET @StrWhere = @StrWhere + ''

	---------------------------------------------------------
	-- Select Clause ----------------------------------------
	If (@UseAmount = 1) or (@ProcessID = 60)
		SET @StrPrice = @strGoodsAmount
	Else 
		SET @StrPrice = 'GoodsPrice'
	
	SET @StrQty	= 'D.GoodsQuantity'
	SET @StrPrc	= '(D.GoodsQuantity * D.' + @StrPrice + ')'
	SET @StrAtm	= 'D.AtomAmount'
	SET @StrQtyR	= '0'
	SET @StrPrcR	= '0'
	SET @StrAtmR	= '0'

	--IF (@DecReturn = 1) AND (@ProcessID_Ret <> 0) and (@DecByRef=1)
	--BEGIN
	--	declare @WhrR nvarchar(max);
	--	set @WhrR = '(D2.ProcessID=' + str(@ProcessID_Ret) + ') AND (D2.ProcessNo=' + Str(@ProcessNo) + ') AND (D2.GoodsID=D.GoodsID) 
	--		AND (D2.BaseProcessID=D.ProcessID) AND (D2.BaseProcessNo=D.ProcessNo) AND (D2.BaseFiscalYear=D.FiscalYear) AND (D2.BaseSerialNo=D.SerialNo) AND (D2.BaseDocRowNo=D.DocRowNo)'
		
	--	if (@ApplyDateToRet = 1)
	--	begin
	--		IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
	--			SET @WhrR = @WhrR + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'D2.DocDate', 'D2.DocDate', 'D2.DocDate', 'D2.DocDate')
	--		IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
	--			SET @WhrR = @WhrR + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'D2.DocDate', 'D2.DocDate', 'D2.DocDate', 'D2.DocDate')
	--	end
	
	--	If (@SelectedStore > 0)
	--		SET @WhrR = @WhrR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D2.StoreID') 
	
	--	SET @StrQtyR= 'isnull((SELECT SUM(D2.GoodsQuantity)
	--			FROM ' + @SD + ' D2
	--			WHERE ' + @WhrR + '),0)'
	--	SET @StrPrcR= 'isnull((SELECT SUM(D2.GoodsQuantity*D2.' + @StrPrice + ')
	--			FROM ' + @SD + ' D2
	--			WHERE ' + @WhrR + '),0)'
	--	SET @StrAtmR= 'isnull((SELECT SUM(D2.AtomAmount)
	--			FROM ' + @SD + ' D2
	--			WHERE ' + @WhrR + '),0)'
	--END
	
	SET @StrSelect = '
	SELECT Left(D.GoodsID, ' + str(@LayerLen) + ') GoodsID, ' + @StoreID1 + ' StoreID,
			' + @StrQty + ' Quantity,
			' + @QtyStr + ' SubQuantity,
			' + @StrPrc + ' Price,
			' + @StrAtm + ' Overload,
			' + @StrQtyR + ' QuantityR,
			0 SubQuantityR,
			' + @StrPrcR + ' PriceR,
			' + @StrAtmR + ' OverloadR,
			D.VisitorPercent, D.VisitorPercent2,
			D.Var1,
			D.Var2,
			D.Var3,
			D.Var4,
			D.DiscountDtl Discount,
			H.CCNo, H.CCPrivilege, H.CCDiscount,
			D.UserGoodsAmount

	FROM ' + @SD + ' D 
	INNER JOIN ' + @SH + ' H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
	LEFT  JOIN sal.tblDistributionsHdr DH ON DH.ProcessID = H.BaseDistributionProcessID And DH.SerialNo = H.BaseDistributionSerialNo 
	LEFT  JOIN inv.tblSubUnitsDtl SUD on D.GoodsID= SUD.GoodsID and SUD.ShowInInvoice = 1
			' + 
			@StrSelectDst + '
	WHERE ' + @StrWhere

		------------------------------------------------------------	
	IF (@DecReturn = 1) AND (@ProcessID_Ret <> 0) --AND (@DecByRef = 0)
	begin
		SET @StrSelect = @StrSelect + '
		union all
		SELECT Left(D.GoodsID, ' + str(@LayerLen) + ') GoodsID, ' + @StoreID1 + ' StoreID,
				0 AS Quantity,
				0 AS SubQuantity,
				0 AS Price,
				0 AS Overload,
				(' + @StrQty + ') QuantityR,
				 ' + @QtyStr + ' SubQuantityR,
				(' + @StrPrc + ') PriceR,
				(' + @StrAtm + ') OverloadR,
				0 VisitorPercent,0 VisitorPercent2,
				D.Var1,D.Var2,D.Var3,D.Var4,			
				0 Discount,
				H.CCNo, H.CCPrivilege, H.CCDiscount,
			    D.UserGoodsAmount
		FROM ' + @SD + ' D 
		INNER JOIN ' + @SH + ' H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
		LEFT  JOIN sal.tblDistributionsHdr DH ON DH.ProcessID = H.BaseDistributionProcessID And DH.SerialNo = H.BaseDistributionSerialNo 
		LEFT  JOIN inv.tblSubUnitsDtl SUD on D.GoodsID= SUD.GoodsID and SUD.ShowInInvoice = 1
		WHERE ' + @StrWhere2
	end
	------------------------------------------------------------
		
	--// UNION Clause (This Section Occures Only in Goods State not Acnt) 
	If (@ShowZeroRows = 1)
	Begin
		-- UNION Where Clause --------------------------------------
		SET @StrWhere_Rem = '(1=1)'

		If (@SelectedGoods > 0)
			SET @StrWhere_Rem = @StrWhere_Rem + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'GD.GoodsID') 
		------------------------------------------------------------

		-- UNION Select Clause -------------------------------------
		if (select count(*) from inv.tblGoods)>15000
		begin
			SET @StrSelect_Rem = '
			SELECT Left(GoodsID, ' + str(@LayerLen) + ') GoodsID, '''' StoreID, 0 Quantity, 0 SubQuantity, 0 Price, 0 Overload, 
				  0 QuantityR, 0 SubQuantityR, 0 PriceR, 0 OverloadR,0 VisitorPercent,0 VisitorPercent2,0 Var1,0 Var2,0 Var3,0 Var4, 0 Discount, 0 CCNo, 0 CCPrivilege, 0 CCDiscount,
				  0 UserGoodsAmount
			FROM inv.tblGoodsDtl GD 
			WHERE ' + @StrWhere_Rem 
		end

		else
			begin
	
				DECLARE @Result as int
				DECLARE @l1 as int
				DECLARE @l2 as int
				DECLARE @l3 as int
				DECLARE @l4 as int
				DECLARE @l5 as int
				DECLARE @l6 as int
				DECLARE @l7 as int
				DECLARE @l8 as int
				DECLARE @l9 as int

				SELECT 
					@l1 = sum(Layer1) ,
					@l2 = sum(Layer1+Layer2) ,
					@l3 = sum(Layer1+Layer2+Layer3) ,
					@l4 = sum(Layer1+Layer2+Layer3+Layer4) ,
					@l5 = sum(Layer1+Layer2+Layer3+Layer4+Layer5) ,
					@l6 = sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6) ,
					@l7 = sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7) ,
					@l8 = sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8),
					@l9 = sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9) 
				FROM pub.tblCodeLayer where PartNumber = 1 AND TableName = 'inv.tblGoods'

			--	select @l1,@l2,@l3,@l4,@l5,@l6,@l7,@l8,@l9		
				IF @l8 < @l9
					SET @Result = @l8
				else IF @l7 < @l8
					SET @Result = @l7
				else IF @l6 < @l7
					SET @Result = @l6
				else IF @l5 < @l6
					SET @Result = @l5
				else IF @l4 < @l5
					SET @Result = @l4
				else IF @l3 < @l4
					SET @Result = @l3
				else IF @l2 < @l3
					SET @Result = @l2
				else IF @l1 < @l2
					SET @Result = @l1
	
				SET @StrSelect_Rem = '
				SELECT Left(GoodsID, ' + str(@LayerLen) + ') GoodsID, '''' StoreID, 0 Quantity, 0 SubQuantity, 0 Price, 0 Overload, 
						0 QuantityR, 0 SubQuantityR, 0 PriceR, 0 OverloadR,0 VisitorPercent,0 VisitorPercent2,0 Var1,0 Var2,0 Var3,0 Var4, 0 Discount, 0 CCNo, 0 CCPrivilege, 0 CCDiscount,
						0 UserGoodsAmount
				FROM inv.tblGoodsDtl GD 
				WHERE (
						GoodsID in(SELECT  GoodsID		FROM inv.tblGoods where len(GoodsID	)>'+ str(@Result)+')
						or 
						GoodsID in(SELECT  a.GoodsID FROM inv.tblGoods a
									inner join inv.tblGoods b on a.GoodsID =SUBSTRING(b.GoodsID,1,len(a.GoodsID)) and len(a.GoodsID)<='+ str(@Result)+'
									group by a.GoodsID
									having Count(*)=1)
						)
				and ' + @StrWhere_Rem 
		end
		SET @StrSelect = '
		SELECT	' + @StoreID2 + ',
				Sum(T.Quantity-ISNULL(T.QuantityR,0)) Quantity,
				Sum(T.SubQuantity-ISNULL(T.SubQuantityR,0)) SubQuantity,
				SUM(T.Price-T.PriceR) Price, 
				SUM(T.Overload-T.OverloadR) Overload, 
				SUM(T.Discount) Discount, SUM(T.CCDiscount) CCDiscount,
				SUM(T.VisitorPercent) VisitorPercent,
				SUM(T.VisitorPercent2) VisitorPercent2,
				SUM(T.Var1) Var1,
				SUM(T.Var2) Var2,
				SUM(T.Var3) Var3,
				SUM(T.Var4) Var4,
				CASE WHEN SUM(T.Quantity)>0 THEN  
					 SUM(T.Quantity*UserGoodsAmount)/SUM(T.Quantity) 
				ELSE CASE When SUM(T.SubQuantityR) > 0 THEN 
					 SUM(T.SubQuantityR*UserGoodsAmount)/SUM(T.SubQuantityR)
				ELSE 0 END END  UserGoodsAmount
		FROM
		(' + @StrSelect + '
			UNION ALL
		' +	@StrSelect_Rem + '
		) T
		GROUP BY ' + @StoreIDGB --+ ' HAVING SUM(T.Quantity)>0 '
		
		print @StrSelect
	End
	else
		SET @StrSelect = '
		select	' + @StoreID2 + ',
				SUM(T.Quantity-ISNULL(T.QuantityR,0)) Quantity,
				SUM(T.SubQuantity-ISNULL(T.SubQuantityR,0)) SubQuantity,
				SUM(T.Price-T.PriceR) Price,
				SUM(T.Overload-T.OverloadR) Overload,
				SUM(T.Discount) Discount, SUM(T.CCDiscount) CCDiscount,
				SUM(T.VisitorPercent) VisitorPercent,
				SUM(T.VisitorPercent2) VisitorPercent2,
				SUM(T.Var1) Var1,
				SUM(T.Var2) Var2,
				SUM(T.Var3) Var3,
				SUM(T.Var4) Var4,
				CASE WHEN SUM(T.Quantity)>0 THEN  
					 SUM(T.Quantity*UserGoodsAmount)/SUM(T.Quantity) 
				ELSE CASE When SUM(T.SubQuantityR) > 0 THEN 
					 SUM(T.SubQuantityR*UserGoodsAmount)/SUM(T.SubQuantityR)
				ELSE 0 END END  UserGoodsAmount
		from
		(' 
		+ @StrSelect + '
		) T
		GROUP BY ' + @StoreIDGB --+ ' HAVING SUM(T.Quantity)>0 '
		
	--//--------------------------------------------------------
	set @EP = 'Price'

	if (@ShowOverload = 1)
		set @EP = @EP + ' + Overload '
	if (@ShowDiscount = 1)
		set @EP = @EP + ' - Discount '
	
		if (@GroupByLayer = 1)
		SET @StrSelect = '
		select M.*, ' + @EP + ' as EffectedPrice, 
			pub.funGetGoodsName(M.GoodsID, ' + @LangID + ') GoodsName, 
			GH.UnitID, [inv].[funGetUnitNameWithGoodsID](M.GoodsID, ' + @LangID + ') UnitName
		into ##tbl_Store_Detailed
		from (' + @StrSelect + ') M
		left join inv.tblGoods GH on GH.GoodsID = M.GoodsID and GH.PartNumber = ' + Ltrim(str(@GoodsPart)) + ' Where 1 = 1 '
	else
		SET @StrSelect = '
		select M.*, ' + @EP + ' as EffectedPrice, GD.GoodsName, U.UnitID, U.UnitName
		into ##tbl_Store_Detailed
		from (' + @StrSelect + ') M
		left join inv.tblGoods GH on GH.GoodsID = M.GoodsID
		left join inv.tblGoodsDtl GD on GD.GoodsID = M.GoodsID
		left join inv.tblUnitsDtl U on U.UnitID = GH.UnitID Where 1=1 '
		
	--if (@PriceFr <> -1) Or (@PriceTo <> -1)
	--begin
	--	set @StrWhere = '(1=1)'

		if (@PriceFr <> -1)
			Set @StrSelect = @StrSelect + ' AND (' + @EP + ' >= ' + str(@PriceFr) + ')'
		if (@PriceTo <> -1)
			Set @StrSelect = @StrSelect + ' AND (' + @EP + ' <= ' + str(@PriceTo) + ')'
		
	--	SET @StrSelect = '
	--	select T.*
	--	from 
	--	(' + @StrSelect + '
	--	) T
	--	where ' + @StrWhere 
	--end

	-- Sort Clause ---------------------------------------------
	IF (@SortFields Is Not Null) AND (@SortFields <> '') 
		SET @StrSelect = @StrSelect + ' 
		ORDER BY ' + @SortFields
	
	Print @StrSelect;
	Print @StrWhere;
	Exec sp_executesql @StrSelect;
		
	-- Run -----------------------------------------------------
	-- =========================================================
	SET @StrSelect = '
	INSERT INTO #tbl_result
	Select StoreID, S.GoodsID, '''', Quantity, UnitID , UnitName , 0, '''', '''', 0, 0, 0, ''''
	From ##tbl_Store_Detailed S 
	-- ==========================='
	
	Print @StrSelect;
	Print @StrWhere;
	Exec sp_executesql @StrSelect;
	
	--Select * From #tbl_result	
	-- ******************************************************************************
	-- *********************************** Units ************************************
	-- ******************************************************************************
	declare cur_goods cursor for
		select GoodsID, GoodsQuantity,UnitIDGoods1,UnitNameGoods1
		from #tbl_result
	open cur_goods;
		
	fetch next from cur_goods into @goods_id, @goods_quantity,@UnitID,@UnitName
	while (@@fetch_status = 0)
	begin
		if @SubUnitQty = 'False'
		BEGIN
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
					select SubUnitID, UnitValue, MainUnitValue
					from inv.tblSubUnitsDtl S
					where GoodsID = @goods_id And ShowInInvoice = 1
					
				) t inner join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = @LanguageID
				order by (t.MainUnitValue/ t.UnitValue ) desc
					
				-- read units row by row
				declare cur_units cursor for
					select * from @tbl_units
				open cur_units;
					
				--select * from @tbl_units

				-- init
				set @unit_idGoods1			 = '';
				set @unit_nameGoods1		 = '';
				set @unit_valueGoods1		 =  0;
				set @Mainunit_valueGoods1	 =  0;
				
				set @unit_idGoods2			 = '';
				set @unit_nameGoods2		 = '';
				set @unit_valueGoods2		 =  0;
				set @Mainunit_valueGoods2	 =  0;
				
				--select * from @tbl_units
				
				-- First Unit
				fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

				if (@@fetch_status = 0)
				begin
					set @unit_idGoods1		= @unit_id;
					set @unit_nameGoods1	= @unit_name;
					
					if @Cnt > 1
					Begin
						set @unit_valueGoods1	 = floor((@goods_quantity + 0.000000001) * @unit_value / @Mainunit_value)
					End
					Else
					Begin
						set @unit_valueGoods1	 = @goods_quantity * @unit_value / @Mainunit_value
					End
					
					set @goods_quantity = @goods_quantity - (@unit_valueGoods1 * @Mainunit_value / @unit_value)

					-- Second Unit
					fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

					if (@@fetch_status = 0)
					begin
						set @unit_idGoods2		= @unit_id;
						set @unit_nameGoods2	= @unit_name;
						
						if @Cnt > 2 
						Begin
							set @unit_valueGoods2	 = floor((@goods_quantity + 0.000000001) * @unit_value / @Mainunit_value)
						End
						else	
						Begin
							set @unit_valueGoods2	 = @goods_quantity * @unit_value / @Mainunit_value
						End
						
						set @goods_quantity	= @goods_quantity - (@unit_valueGoods2 * @Mainunit_value / @unit_value)
					end;

				end;
				-- close units cursor
				close cur_units;
				deallocate cur_units;
			END
			ELSE
			BEGIN
				SET @unit_idGoods1 = @UnitID
				SET @unit_nameGoods1 = @UnitName
				SET @unit_valueGoods1 = @goods_quantity
				
				select  @unit_idGoods2=t.SubUnitID, @unit_nameGoods2 = u.UnitName,@unit_valueGoods2 =  @goods_quantity * t.UnitValue / t.MainUnitValue  
				from inv.tblSubUnitsDtl t
				inner join inv.tblUnitsDtl u on u.UnitID = t.SubUnitID and u.LanguageID = @LanguageID
				where GoodsID = @goods_id And ShowInInvoice = 1

			END
		-- update result
		update #tbl_result
		set GoodsName				= IsNull([pub].[funGetGoodsName](G.GoodsID, @LanguageID), ''),
			UnitIDGoods1			= IsNull(@unit_idGoods1,''),
			UnitNameGoods1			= IsNull(@unit_nameGoods1,''),
			GoodsQuantity1			= IsNull(@unit_valueGoods1,0),
			
			UnitIDGoods2			= IsNull(@unit_idGoods2,''),
			UnitNameGoods2			= IsNull(@unit_nameGoods2,''),
			GoodsQuantity2			= IsNull(@unit_valueGoods2,0),
			
			Weight					= IsNull(G.GoodsWeight,0),
			Volume					= IsNull(G.GoodsLength * G.GoodsHeight * G.GoodsWidth,0),
			BarCode					= IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
			
		from inv.tblGoods G
		INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LanguageID
		where G.GoodsID = @goods_id AND #tbl_result.GoodsID = @goods_id
		
		-- next
		fetch next from cur_goods into @goods_id, @goods_quantity,@UnitID,@UnitName
	end

	-- close goods cursor
	Close cur_goods;
	Deallocate cur_goods;
	-- ******************************************************************************
	-- ********************************** Units End *********************************
	-- ******************************************************************************
	--Select * From #tbl_result
	
	if (@UserIsAdmin = 0)
	begin
		--exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'StoreID', 'inv.tblStores', @UserID;
		exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'GoodsID', 'inv.tblGoods', @UserID;
		--exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'AcntCode', 'acc.tblAcnt', @UserID;
	end
	
	-- ===========================
	SELECT T.*, IsNull(R.GoodsQuantity,0) RGoodsQuantity,
		   IsNull(R.GoodsQuantity1,0) GoodsQuantity1, ISNULL(R.UnitIDGoods1,'') UnitIDGoods1, ISNULL(R.UnitNameGoods1,'') UnitNameGoods1,
		   IsNull(R.GoodsQuantity2,0) GoodsQuantity2, ISNULL(R.UnitIDGoods2,'') UnitIDGoods2, ISNULL(R.UnitNameGoods2,'') UnitNameGoods2,
		   ISNULL(R.Weight,0) RWeight, ISNULL(R.Volume,0) RVolume, ISNULL(R.BarCode,0) RBarCode,isnull(TechnicalNo, '')TechnicalNo
	FROM ##tbl_Store_Detailed T
	LEFT JOIN #tbl_result R ON R.GoodsID = T.GoodsID and  R.StoreID = T.StoreID 
	LEFT JOIN inv.tblGoods g ON g.GoodsID = SUBSTRING(R.GoodsID,@str_Goods+1, @str_GoodsSum) AND g.PartNumber= @UnitPart
	
	-- ===========================
END
GO
