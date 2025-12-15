USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1391/12/23
-- Viewed By	 : 
-- Last Modified : 1391/12/23
-- Last Modifier : TakroSystem\Zia
-- Description   : گزارش سرجمع ماهانه انبار برای یک کالا یا کالاها
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Summary_Goods_Month]
	@ProcessID			Int,
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
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@RepOptions			VarChar(20) = '110001111110111', -- bit array options
	@SortFields			NVarChar(100) = Null,   -- Order By Field List
	@RepInfo			NVarChar(100) = '1@1@1@0@1',
	@ExtraParams		NVarChar(200) = '@0@@@-1@-1'
WITH ENCRYPTION
AS 
	---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhere2	NVarChar(max);

DECLARE @StrSelect_Rem	NVarChar(max);
DECLARE @StrWhere_Rem	NVarChar(max);

DECLARE @StrPrice	NVarChar(100);

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

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

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
DECLARE @CustKind	VarChar(20);
DECLARE @SelectedProduct	int;

declare @StrQty		nvarchar(max);
declare @StrPrc		nvarchar(max);
declare @StrAtm		nvarchar(max);
declare @StrQtyR	nvarchar(max);
declare @StrPrcR	nvarchar(max);
declare @StrAtmR	nvarchar(max);

DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @StartLayerAcntRemain		int;
DECLARE @LenLayerAcntRemain		int;


Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
		
	Select @StartLayerAcntRemain=acc.FunGetAcntInfoForRemain(2 )
	Select @LenLayerAcntRemain=acc.FunGetAcntInfoForRemain(3 )


	-- Init Variables --------
	IF (@RepOptions Is Null)	SET @RepOptions = '110001111111'
	IF (@ProcessNo  Is Null)	SET @ProcessNo = 1;
	IF (@DocStep	Is Null)	SET @DocStep = 0;
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null';
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

	SET @CustKind	= LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @SelectedProduct = LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @Location	= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @Location2	= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @PriceFr	= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @PriceTo	= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @CampaignID	     = pub.funSplitString(@ExtraParams,'@',14);
	SET @VisitPathID1 	 = pub.funSplitString(@ExtraParams, '@', 15);
	SET @VisitPathID2	 = pub.funSplitString(@ExtraParams, '@', 16);
	SET @VisitPathID3	 = pub.funSplitString(@ExtraParams, '@', 17);
	SET @VisitPathID4	 = pub.funSplitString(@ExtraParams, '@', 18);
	SET @SalesRoomClass	 = pub.funSplitString(@ExtraParams, '@', 19);



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
	SET @StrSelect_Rem = '';
	SET @StrWhere_Rem = '';
	Set @StrWhere = '(D.ProcessID in (' + @StrPID + '))'
	set @StrWhere2= '(D.ProcessID in (' + ltrim(str(@ProcessID_Ret)) + '))'

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

	If (@ProcessNo Is Not Null AND @ProcessNo > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'
	end

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

	If (@VchNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND H.VchNo >= ' + LTrim(Str(@VchNoFr))
	If (@VchNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND H.VchNo <= ' + LTrim(Str(@VchNoTo))

	If (@SelectedProduct > 0)
		IF (@ProcessID = 80 Or @ProcessID = 85)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'D.GoodsID') 
		Else
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'H.ProductID') 
		
	If (@SelectedGoods > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
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
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'

	IF (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep = ' + LTrim(Str(@DocStep)) + ')'
	---------------------------------------------------------
	-- Select Clause ----------------------------------------
	If (@UseAmount = 1) or (@ProcessID = 60)
		SET @StrPrice = 'GoodsAmount'
	Else 
		SET @StrPrice = 'GoodsPrice'
	
	SET @StrQty	= 'D.GoodsQuantity'
	SET @StrPrc	= '(D.GoodsQuantity * D.' + @StrPrice + ')'
	SET @StrAtm	= 'D.AtomAmount'
	SET @StrQtyR	= '0'
	SET @StrPrcR	= '0'
	SET @StrAtmR	= '0'

	IF (@DecReturn = 1) AND (@ProcessID_Ret <> 0) and (@DecByRef=1)
	BEGIN
		declare @WhrR nvarchar(max);
		set @WhrR = '(D2.ProcessID=' + str(@ProcessID_Ret) + ') AND (D2.ProcessNo=' + Str(@ProcessNo) + ') AND (D2.GoodsID=D.GoodsID) 
			AND (D2.BaseProcessID=D.ProcessID) AND (D2.BaseProcessNo=D.ProcessNo) AND (D2.BaseFiscalYear=D.FiscalYear) AND (D2.BaseSerialNo=D.SerialNo) AND (D2.BaseDocRowNo=D.DocRowNo)'
		
		if (@ApplyDateToRet = 1)
		begin
			IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
				SET @WhrR = @WhrR + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'D2.DocDate', 'D2.DocDate', 'D2.DocDate', 'D2.DocDate')
			IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
				SET @WhrR = @WhrR + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'D2.DocDate', 'D2.DocDate', 'D2.DocDate', 'D2.DocDate')
		end
	
		If (@SelectedStore > 0)
			SET @WhrR = @WhrR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D2.StoreID') 
	
		SET @StrQtyR= 'isnull((SELECT SUM(D2.GoodsQuantity)
				FROM inv.tblStorageDocsDtl D2
				WHERE ' + @WhrR + '),0)'
		SET @StrPrcR= 'isnull((SELECT SUM(D2.GoodsQuantity*D2.' + @StrPrice + ')
				FROM inv.tblStorageDocsDtl D2
				WHERE ' + @WhrR + '),0)'
		SET @StrAtmR= 'isnull((SELECT SUM(D2.AtomAmount)
				FROM inv.tblStorageDocsDtl D2
				WHERE ' + @WhrR + '),0)'
	END
	
	SET @StrSelect = '
	SELECT Substring(D.DocDate, 6, 2) MonthCode,
			D.GoodsID, 
			' + @StrQty + ' Quantity,
			' + @StrPrc + ' Price,
			' + @StrAtm + ' Overload,
			' + @StrQtyR + ' QuantityR,
			' + @StrPrcR + ' PriceR,
			' + @StrAtmR + ' OverloadR,
			D.DiscountDtl Discount
	FROM inv.tblStorageDocsDtl D 
			INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
	WHERE ' + @StrWhere
	
	IF (@DecReturn = 1) AND (@ProcessID_Ret <> 0) and (@DecByRef=0)
	begin
		SET @StrSelect = @StrSelect + '
		union all
		SELECT Substring(D.DocDate, 6, 2) MonthCode,
				D.GoodsID, 
				0 AS Quantity,
				0 AS Price,
				0 AS Overload,
				(' + @StrQty + ') QuantityR,
				(' + @StrPrc + ') PriceR,
				(' + @StrAtm + ') OverloadR,
				0 Discount
		FROM inv.tblStorageDocsDtl D 
			INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
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
		SET @StrSelect_Rem = '
		SELECT Substring(D.DocDate, 6, 2) MonthCode, GoodsID, 0 Quantity, 0 Price, 0 Overload, 0 QuantityR, 0 PriceR, 0 OverloadR, 0 Discount
		FROM inv.tblGoodsDtl GD 
		WHERE ' + @StrWhere_Rem 
		
		SET @StrSelect = '
		SELECT	T.MonthCode, T.GoodsID, 
				Sum(T.Quantity-T.QuantityR) Quantity,
				SUM(T.Price-T.PriceR) Price, 
				SUM(T.Overload-T.OverloadR) Overload, 
				SUM(T.Discount) Discount
		FROM
		(' + @StrSelect + '
			UNION ALL
		' +	@StrSelect_Rem + '
		) T
		GROUP BY T.MonthCode, T.GoodsID'
	End
	else
		SET @StrSelect = '
		select	T.MonthCode, T.GoodsID, 
				SUM(T.Quantity-T.QuantityR) Quantity,
				SUM(T.Price-T.PriceR) Price,
				SUM(T.Overload-T.OverloadR) Overload,
				SUM(T.Discount) Discount
		from
		(' 
		+ @StrSelect + '
		) T
		GROUP BY T.MonthCode, T.GoodsID '
	
	--//--------------------------------------------------------
	set @EP = 'Price'

	if (@ShowOverload = 1)
		set @EP = @EP + ' + Overload '
	if (@ShowDiscount = 1)
		set @EP = @EP + ' - Discount '

	SET @StrSelect = '
	select M.*, ' + @EP + ' EffectedPrice, GD.GoodsName, U.UnitID, U.UnitName
	into ##tbl_Store_Detailed
	from (' + @StrSelect + ') M
		left join inv.tblGoods GH on GH.GoodsID = M.GoodsID
		left join inv.tblGoodsDtl GD on GD.GoodsID = M.GoodsID
		left join inv.tblUnitsDtl U on U.UnitID = GH.UnitID'

	--if (@PriceFr <> -1) Or (@PriceTo <> -1)
	--begin
	--	set @StrWhere = '(1=1)'

	--	if (@PriceFr <> -1)
	--		Set @StrWhere = @StrWhere + ' AND (EffectedPrice >= ' + str(@PriceFr) + ')'
	--	if (@PriceTo <> -1)
	--		Set @StrWhere = @StrWhere + ' AND (EffectedPrice <= ' + str(@PriceTo) + ')'
			
	--	SET @StrSelect = '
	--	select T.*
	--	from 
	--	(' + @StrSelect + '
	--	) T
	--	where ' + @StrWhere 
	--end

	-- Sort Clause ---------------------------------------------
	If (@SortFields Is Not Null) AND (@SortFields <> '') 
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	begin try
		drop table ##tbl_Store_Detailed
	end try
	begin catch
	end catch
	
	print @StrSelect;
	Exec sp_executesql @StrSelect;

	if (@UserIsAdmin = 0)
	begin
		--exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'StoreID', 'inv.tblStores', @UserID;
		exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'GoodsID', 'inv.tblGoods', @UserID;
		--exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'AcntCode', 'acc.tblAcnt', @UserID;
	end
	
	select * 
	from ##tbl_Store_Detailed	
	------------------------------------------------------------
End
GO
