USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/19
-- Viewed By	 : 
-- Last Modified : 1390/04/09
-- Last Modifier : TakroSystem\Zia
-- Description   : آمار میانگین انبار - کالاها
-- ==============================================
Create PROCEDURE [inv].[RptStore_Average_Goods]
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
	@SaleTypeID			varchar(20) = null,
	@RepOptions			VarChar(10) = '11000111111', -- bit array options
	@SortFields			NVarChar(100) = Null,   -- Order By Field List
	@RepInfo			NVarChar(100) = '1@1@1', 
	@ExtraParams		NVarChar(200) = '@0@@@-1@-1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhere2	NVarChar(max);

DECLARE @StrPrice	NVarChar(100);
DECLARE @ReturnPID	VarChar(3);

DECLARE @ShowQuantity	Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		Bit;  -- شامل ستون قیمت
DECLARE @ShowOverload	Bit;  -- شامل ستون سربار
DECLARE @ShowZeroRows	Bit; -- Not Used; Only for Sync with summary report
DECLARE @DecReturn		Bit; -- Not Used; Only for Sync with summary report
DECLARE @UseAmount		Bit; -- Use Amount Field Instead of Price?
DECLARE @GroupByAcnt	Bit; -- 0: Goods  1: Acnt -- Not Used in this report
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

DECLARE @CustKind	VarChar(20);
DECLARE @SelectedProduct	int;

DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @StartLayerAcntRemain	int;
DECLARE @LenLayerAcntRemain		int;
DECLARE @IsMultiplex			Bit;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	
	Select @StartLayerAcntRemain=acc.FunGetAcntInfoForRemain(2 )
	Select @LenLayerAcntRemain=acc.FunGetAcntInfoForRemain(3 )

	DECLARE @QuantityDecimalsToForms AS Int

	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'
	-- I N I T ------------------------------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '11000111111'
	IF (@ProcessNo  Is Null)	SET @ProcessNo = 1;
	IF (@DocStep	Is Null)	SET @DocStep = 0;
	IF (@ExtraParams	Is Null)SET @ExtraParams = '@0@@@-1@-1';

	IF (@DocDateFr	Is Null)	SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)	SET @DocDateTo = '@@@';

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0;
	IF (@SelectedStore2 Is Null)	SET @SelectedStore2 = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;
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
	SET @GroupByAcnt	= Substring(@RepOptions, 7, 1);

	SET @PID1			= Substring(@RepOptions, 9, 1)
	SET @PID2			= Substring(@RepOptions, 10, 1)
	SET @PID3			= Substring(@RepOptions, 11, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @CustKind = LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @SelectedProduct = LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @Location = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @Location2 = LTrim(pub.funSplitString(@ExtraParams, '@', 4));

	SET @CampaignID	     = pub.funSplitString(@ExtraParams,'@',14);
	SET @VisitPathID1 	 = pub.funSplitString(@ExtraParams, '@', 15);
	SET @VisitPathID2	 = pub.funSplitString(@ExtraParams, '@', 16);
	SET @VisitPathID3	 = pub.funSplitString(@ExtraParams, '@', 17);
	SET @VisitPathID4	 = pub.funSplitString(@ExtraParams, '@', 18);
	SET @SalesRoomClass	 = pub.funSplitString(@ExtraParams, '@', 19);
	SET @IsMultiplex	 = pub.funSplitString(@ExtraParams, '@', 28);


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
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '';

	IF (@DecReturn = 1) 
		SET @ReturnPID = '100'
	ELSE
		SET @ReturnPID = '0'

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

	IF @ShowPrice = 'False' AND (@ProcessID =70 OR @ProcessID = 80 )
		SET @StrWhere = '(D.ProcessID in (' + @StrPID + '))'
	else
		SET @StrWhere = '(D.' + @StrPrice + ' <> 0) AND (D.ProcessID in (' + @StrPID + '))'

	IF (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	If @SaleTypeID Is Not Null
		Set @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @SaleTypeID + ''')'

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

	if (@CustKind <> '')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'

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

	If (@SelectedProduct > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'H.ProductID') 
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
	---------------------------------------------------------------------------
	-- F R O M ----------------------------------------------------------------
	SET @StrFrom = 'inv.tblStorageDocsDtl D
		INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo'

	SET @StrFrom = 'inv.tblStorageDocsDtl D
		INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		INNER JOIN
		(
			SELECT	B.GoodsID, B.LastDate, B.LastSerialNo, D.' + @StrPrice + '
			FROM	' + @StrFrom  + ' INNER JOIN
			(
				SELECT	A.GoodsID, A.LastDate, Max(D.SerialNo) LastSerialNo--,Max(D.RowNo) LastRowNo
				FROM	' + @StrFrom  + ' INNER JOIN
				(
					SELECT	D.GoodsID, MAX(D.DocDate) LastDate
					FROM	' + @StrFrom  + '
					WHERE	' + @StrWhere + '
					GROUP BY D.GoodsID
				) A ON (D.GoodsID = A.GoodsID) AND (D.DocDate = A.LastDate)
				WHERE	' + @StrWhere + '
				GROUP BY A.GoodsID, A.LastDate
			) B ON (D.SerialNo = B.LastSerialNo) AND (D.DocDate = B.LastDate) AND (D.GoodsID = B.GoodsID)
			WHERE ' + @StrWhere + '
		) C ON D.GoodsID = C.GoodsID '

	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	DECLARE @tblSum Table(SumVal Float)
	DECLARE @SumVal Float
	
	If (@ShowOverload = 1) 
	SET @StrSelect = '
	SELECT  IsNull(Sum((D.' + @StrPrice + ' * GoodsQuantity + AtomAmount) / GoodsQuantity), 0)'
	ELSE
	SET @StrSelect = '
	SELECT  IsNull(Sum(D.' + @StrPrice + '), 0)'

	SET @StrSelect = @StrSelect + '
	FROM    ' + @StrFrom  + '
	WHERE   ' + @StrWhere 

	INSERT INTO @tblSum 
	EXEC sp_executesql @StrSelect;

	SELECT @SumVal = SumVal / 100
	FROM @tblSum
	
	IF (@ShowOverload = 1)
	SET @StrSelect = '
	SELECT	D.GoodsID, pub.GetGoodsName(D.GoodsID, ' + @LangID + ') AS GoodsName,
		CASE WHEN (ROUND(sum(CASE WHEN D.ProcessID in (' + @StrPID + ') THEN (D.GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') -
			       ROUND(sum(CASE WHEN D.ProcessID = ' + LTrim(Str(@ReturnPID)) + ' THEN (D.GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ')) > 0 
		     THEN (ROUND(Sum(CASE WHEN D.ProcessID in (' + @StrPID + ') THEN ((D.' + @StrPrice + ' * GoodsQuantity + AtomAmount) ) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') -
			       ROUND(Sum(CASE WHEN D.ProcessID = ' + LTrim(Str(@ReturnPID)) + ' THEN ((D.' + @StrPrice + ' * GoodsQuantity + AtomAmount) ) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') 
				  )/(ROUND(Sum(CASE WHEN D.ProcessID in (' + @StrPID + ') THEN (D. GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') -
			         ROUND(Sum(CASE WHEN D.ProcessID = ' + LTrim(Str(@ReturnPID)) + ' THEN (D.GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ')) 
			 ELSE 0 END  AS AvgPrice,

			ROUND(MIN(CASE WHEN D.ProcessID in (' + @StrPID + ') THEN ((D.' + @StrPrice + ' * GoodsQuantity + AtomAmount) / GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') -
			ROUND(MIN(CASE WHEN D.ProcessID = ' + LTrim(Str(@ReturnPID)) + ' THEN ((D.' + @StrPrice + ' * GoodsQuantity + AtomAmount) / GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') AS MinPrice,

			ROUND(MAX(CASE WHEN D.ProcessID in (' + @StrPID + ') THEN ((D.' + @StrPrice + ' * GoodsQuantity + AtomAmount) / GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') -
			ROUND(MAX(CASE WHEN D.ProcessID = ' + LTrim(Str(@ReturnPID)) + ' THEN ((D.' + @StrPrice + ' * GoodsQuantity + AtomAmount) / GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') AS MaxPrice,

			COUNT(*) AS [Count], C.' + @StrPrice + ' AS LastPrice, ' +
			CASE WHEN @SumVal > 0 THEN
				'ROUND(SUM((D.' + @StrPrice + ' * GoodsQuantity + AtomAmount) / GoodsQuantity), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') / ' + LTRim(Str(@SumVal)) 
			ELSE
				'0'
			END
			+ ' AS Percentage'
	ELSE	
	SET @StrSelect = '
	SELECT	D.GoodsID, pub.GetGoodsName(D.GoodsID, ' + @LangID + ') AS GoodsName, 
	CASE WHEN (ROUND(sum(CASE WHEN D.ProcessID in (' + @StrPID + ') THEN (D.GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') -
			   ROUND(sum(CASE WHEN D.ProcessID = ' + LTrim(Str(@ReturnPID)) + ' THEN (D.GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ')) > 0 
		 THEN (ROUND(sum(CASE WHEN D.ProcessID in (' + @StrPID + ') THEN (D.' + @StrPrice + '* D.GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') -
			   ROUND(sum(CASE WHEN D.ProcessID = ' + LTrim(Str(@ReturnPID)) + ' THEN (D.' + @StrPrice + '* D.GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') 
			  )/(ROUND(sum(CASE WHEN D.ProcessID in (' + @StrPID + ') THEN (D.GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') -
			     ROUND(sum(CASE WHEN D.ProcessID = ' + LTrim(Str(@ReturnPID)) + ' THEN (D.GoodsQuantity) ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ')) 
		ELSE 0 END AS AvgPrice,
			ROUND(MIN(CASE WHEN D.ProcessID in (' + @StrPID + ') THEN (D.' + @StrPrice + ') ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') -
			ROUND(MIN(CASE WHEN D.ProcessID = ' + LTrim(Str(@ReturnPID)) + ' THEN (D.' + @StrPrice + ') ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') AS MinPrice,

			ROUND(MAX(CASE WHEN D.ProcessID in (' + @StrPID + ') THEN (D.' + @StrPrice + ') ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') -
			ROUND(MAX(CASE WHEN D.ProcessID = ' + LTrim(Str(@ReturnPID)) + ' THEN (D.' + @StrPrice + ') ELSE 0 END), ' + Ltrim(Rtrim(Str(@QuantityDecimalsToForms))) + ') AS MaxPrice,

			COUNT(*) AS [Count], C.' + @StrPrice + ' AS LastPrice, ' +
			CASE WHEN @SumVal > 0 THEN
				'ROUND(SUM(D.' + @StrPrice + '), 0) / ' + LTRim(Str(@SumVal)) 
			ELSE
				'0'
			END
			+ ' AS Percentage'

	SET @StrSelect = @StrSelect + '
	FROM    ' + @StrFrom  + '
	WHERE   ' + @StrWhere + '
	GROUP BY D.GoodsID, C.' + @StrPrice
	--------------------------------------------------------------

	-- S O R T ---------------------------------------------------
	IF (@SortFields Is Not Null And @SortFields <> '')
	SET @StrSelect = @StrSelect +	' 
	ORDER BY ' + @SortFields
	--------------------------------------------------------------

	-- RUN -------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	--------------------------------------------------------------
End
GO
