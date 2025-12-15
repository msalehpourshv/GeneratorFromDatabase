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
Create PROCEDURE [inv].[RptStore_Summary_Acnt2]
	@ProcessID			Int= 55,
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@SelectedGoods		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedStore2		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@DocStep			Int = 0,  -- مرحله
	@SaleTypeID			varchar(20) = null,
	@RepOptions			VarChar(20) = '11000111111001', -- bit array options
	@SortFields			NVarChar(100) = Null,   -- Order By Field List
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = '@0@@@-1@-1'
WITH ENCRYPTION
AS 
	---- Declarations ---------------
DECLARE @StrSelect			NVarChar(max);
DECLARE @StrSelectRet		NVarChar(max);
DECLARE @StrFrom			NVarChar(max);
DECLARE @StrWhere			NVarChar(max);
DECLARE @StrWhereH			NVarChar(max);
DECLARE @StrWhereRet		NVarChar(2000);
DECLARE @StrWhereRetH		NVarChar(2000);
DECLARE @StrWhere2			NVarChar(1000);

DECLARE @StrPrice	NVarChar(100);
DECLARE	@PriceFr	float;
DECLARE	@PriceTo	float;

DECLARE @ProcessID_Ret	Int;
DECLARE @GroupByLayer	Bit;

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

DECLARE @StrPID		VarChar(20);
DECLARE @Location	VarChar(20);
DECLARE @Location2	VarChar(20);
DECLARE @PID1	bit;
DECLARE @PID2	bit;
DECLARE @PID3	bit;

DECLARE @CustKind	VarChar(20);
DECLARE @SelectedProduct	int;
DECLARE @BuyTypeID	varchar(20);
DECLARE @LayerLen	int;
DECLARE @GoodsPart	int;

DECLARE @StrQty			nvarchar(max);
DECLARE @StrPrc			nvarchar(max);
DECLARE @StrAtm			nvarchar(max);
DECLARE @StrQtyR		nvarchar(max);
DECLARE @StrPrcR		nvarchar(max);
DECLARE @StrAtmR		nvarchar(max);

DECLARE @Code1		Int;
DECLARE @Code2		Int;
DECLARE @Code3		Int;
DECLARE @Code4		Int;

DECLARE @RetCode1	Int;
DECLARE @RetCode2	Int;
DECLARE @RetCode3	Int;
DECLARE @RetCode4	Int;

DECLARE @IsCurrency		Bit;
DECLARE @SH				NVarChar(50);
DECLARE @SD				NVarChar(50);
	
DECLARE @WithTaxToll	Bit;
	
DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @LayerAcntRemain		int;
DECLARE @StartLayerAcntRemain		int;
DECLARE @LenLayerAcntRemain		int;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
	
	Select @LayerAcntRemain=acc.FunGetAcntInfoForRemain(1 )
	Select @StartLayerAcntRemain=acc.FunGetAcntInfoForRemain(2 )
	Select @LenLayerAcntRemain=acc.FunGetAcntInfoForRemain(3 )

	-- Init Variables --------
	IF (@RepOptions Is Null)	SET @RepOptions = '110001111111'
	IF (@ProcessNo  Is Null)	SET @ProcessNo = 1;
	IF (@DocStep	Is Null)	SET @DocStep = 0;
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

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	set @SelectedProduct = 0;

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
	SET @WithTaxToll	= Substring(@RepOptions, 20, 1)

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
	Set @StrWhere		 = '(H.ProcessID in (' + @StrPID + '))'
	Set @StrWhereRet	 = '(H.ProcessID in (' + ltrim(str(@ProcessID_Ret)) + '))'

	--if not (@RefY = 1)
	--begin
	--	set @StrWhere = @StrWhere + ' AND (D.BaseSerialNo = 0)'
	--end
	--if not (@RefN = 1)
	--begin
	--	set @StrWhere = @StrWhere + ' AND (D.BaseSerialNo <> 0)'
	--end

	if (@CustKind <> '')
	begin
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(H.AcntCode) = ''' + @CustKind + ''')'
	end

	if (@Location <> '')
	begin
		Set @StrWhere = @StrWhere + ' AND (Left(H.LocationID, ' + str(len(@Location)) + ') >= ''' + @Location + ''')'
		Set @StrWhereRet = @StrWhereRet + ' AND (Left(H.LocationID, ' + str(len(@Location)) + ') >= ''' + @Location + ''')'
	end
	if (@Location2 <> '')
	begin
		Set @StrWhere = @StrWhere + ' AND (Left(H.LocationID, ' + str(len(@Location2)) + ') <= ''' + @Location2 + ''')'
		Set @StrWhereRet = @StrWhereRet + ' AND (Left(H.LocationID, ' + str(len(@Location2)) + ') <= ''' + @Location2 + ''')'
	end

	If (@ProcessNo Is Not Null AND @ProcessNo >0 )
	begin
		SET @StrWhere = @StrWhere + ' AND (H.ProcessNo in (' + LTrim(Str(@ProcessNo)) + '))'
		SET @StrWhereRet = @StrWhereRet + ' AND (H.ProcessNo in (' + LTrim(Str(@ProcessNo)) + '))'
	end

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

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

	if (@ApplyDateToRet = 1)
	begin
		IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
			SET @StrWhereRet = @StrWhereRet + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate', 'H.DocDate', 'H.DocDate')
		IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
			SET @StrWhereRet = @StrWhereRet + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate', 'H.DocDate', 'H.DocDate')
	end

	If (@SelectedProduct > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'H.ProductID') 
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProduct, 'H.ProductID') 
	end

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	If (@SelectedAcnt1 > 0)
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	IF (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (H.DocStep = ' + LTrim(Str(@DocStep)) + ')'
	
	IF (@WithTaxToll = 1)
	begin
		SET @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0 OR H.TollOverWorthCost > 0)'
		SET @StrWhereRet = @StrWhereRet + ' AND (H.TaxOverWorthCost > 0 OR H.TollOverWorthCost > 0)'
		--SET @StrWhereRet = @StrWhereRet + ' WHERE M.TaxOverWorthCost > 0 OR M.TollOverWorthCost > 0'
	end
	
	SET @StrWhereH=	@StrWhere	
	SET @StrWhereRetH=	@StrWhereRet	
	
	If (@SaleTypeID Is Not Null)
	begin
		Set @StrWhereRet = @StrWhereRet + ' AND (D.SaleTypeID = ''' + @SaleTypeID + ''')'
		Set @StrWhereH = @StrWhereH + ' AND (H.SaleTypeID = ''' + @SaleTypeID + ''')'
		Set @StrWhereRet = @StrWhereRet + ' AND (D.SaleTypeID = ''' + @SaleTypeID + ''')'
		Set @StrWhereRetH = @StrWhereRetH + ' AND (H.SaleTypeID = ''' + @SaleTypeID + ''')'
	end
	If (@BuyTypeID <> '')
	begin
		Set @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @BuyTypeID + ''')'
		Set @StrWhereH = @StrWhereH + ' AND (D.SaleTypeID = ''' + @BuyTypeID + ''')'
		Set @StrWhereRet = @StrWhereRet + ' AND (D.SaleTypeID = ''' + @BuyTypeID + ''')'
		Set @StrWhereRetH = @StrWhereRetH + ' AND (D.SaleTypeID = ''' + @BuyTypeID + ''')'
	end

	If (@SelectedGoods > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	end
	
	If (@SelectedStore > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhereRetH = @StrWhereRetH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 
	end
	
	If (@SelectedStore2 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'H.StoreID2')
		SET @StrWhereRet = @StrWhereRet + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')
		SET @StrWhereRetH = @StrWhereRetH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'H.StoreID2')
	end


	--if (@IsCurrency = 1)
	--	begin
	--		set @SH = 'inv.vwStorageHdr_Currency'
	--		set @SD = 'inv.vwStorageDtl_Currency'
	--	end
	--	else
	--	begin
	--		set @SH = 'inv.tblStorageDocsHdr'
	--		set @SD = 'inv.tblStorageDocsDtl'
	--	end
		
	---------------------------------------------------------
	-- Select Clause ----------------------------------------
	If (@UseAmount = 1) or (@ProcessID = 60) or (@ProcessID = 55)
		SET @StrPrice = 'GoodsAmount'
	Else 
		SET @StrPrice = 'GoodsPrice'
	
	SET @StrQty	= 'D.GoodsQuantity'
	SET @StrPrc	= '(D.GoodsQuantity * D.' + @StrPrice + ')'
	SET @StrAtm	= 'D.AtomAmount'
	SET @StrQtyR	= '0'
	SET @StrPrcR	= '0'
	SET @StrAtmR	= '0'

	--IF (@DecReturn = 1) AND (@ProcessID_Ret <> 0) and (@DecByRef = 1)
		--SET @StrWhereRet = @StrWhereRet + ' And (D.BaseSerialNo <> 0)'
		SET @StrSelectRet = 
		'(Select Sum(D.GoodsQuantity * D.GoodsPrice)--, H.TaxOverWorthCost, H.TollOverWorthCost
		 From inv.tblStorageDocsDtl D
		 Inner Join inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And
											   H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
		 Where ' + @StrWhereRet + ' And (D.BaseSerialNo = 0))'

	------------------------------------------------------------
	SET @StrSelect = '
	select ISNULL(a.AcntCode,b.AcntCode) AcntCode ,pub.GetCodeName(ISNULL(a.AcntCode,b.AcntCode), ' + Str(@LangID) + ') AS AcntName,
		 ISNULL(GoodsQuantity,0) GoodsQuantity,ISNULL(GoodsPrice,0)GoodsPrice,ISNULL(TotalPrice,0)TotalPrice,ISNULL(TaxOverWorthCost,0)TaxOverWorthCost,ISNULL(TollOverWorthCost,0)TollOverWorthCost
		,ISNULL(RetGoodsQuantity,0)RetGoodsQuantity,ISNULL(RetGoodsPrice,0)RetGoodsPrice,ISNULL(RetTotalPrice,0)RetTotalPrice,ISNULL(RetTaxOverWorthCost,0)RetTaxOverWorthCost,ISNULL(RetTollOverWorthCost,0)RetTollOverWorthCost
		, ISNULL(' + @StrSelectRet + ',0) AS NoRefRets,
		NationalIDNumber,EconomicalCode,NationalIdentity,Address1,Address2,LocationID, pub.funGetLocationName(LocationID,'+ str(@LangID) +') AS LocationName	
		from 
		(SELECT a.*,TaxOverWorthCost,TollOverWorthCost 
		 FROM
		   (select H.AcntCode,SUM(GoodsQuantity) GoodsQuantity , 
			   ISNULL(Sum(GoodsPrice),0) GoodsPrice,ISNULL(Sum(D.GoodsQuantity*GoodsAmount),0) TotalPrice
			From inv.tblStorageDocsDtl D
			Inner Join inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And
												  H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
			WHERE ' + @StrWhere + '
			Group by H.AcntCode
			) a
		 INNER JOIN 
		  (
		   select AcntCode	,ISNULL(SUM(TaxOverWorthCost),0) TaxOverWorthCost,ISNULL(SUM(TollOverWorthCost),0) TollOverWorthCost
		   FROM inv.tblStorageDocsHdr H
		   WHERE ' + @StrWhereH + '
		   Group by H.AcntCode
		   )b
		 on a.AcntCode=b.AcntCode
		) a
		full JOIN (
		 SELECT a.*,RetTaxOverWorthCost,RetTollOverWorthCost 
		 FROM
		   (
			select H.AcntCode,ISNULL(SUM(GoodsQuantity),0) RetGoodsQuantity , 
				   ISNULL(Sum(GoodsPrice),0) RetGoodsPrice,ISNULL(Sum(D.GoodsQuantity*GoodsAmount),0) RetTotalPrice
			From inv.tblStorageDocsDtl D
			Inner Join inv.tblStorageDocsHdr H 
			ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And
			   H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
			WHERE ' + @StrWhereRet + '
			Group by H.AcntCode) a
		 INNER JOIN 
		  (
		   select AcntCode	,ISNULL(SUM(TaxOverWorthCost),0) RetTaxOverWorthCost,ISNULL(SUM(TollOverWorthCost),0) RetTollOverWorthCost
		   FROM inv.tblStorageDocsHdr H
		   WHERE ' + @StrWhereRetH + '
		   Group by H.AcntCode
		   )b
		 on a.AcntCode=b.AcntCode
		)b
		ON a.AcntCode=b.AcntCode
		Inner join acc.tblAcnt A ON	
		A.AcntCode = substring(ISNULL(a.AcntCode,b.AcntCode),'+ LTrim(RTrim(str(@StartLayerAcntRemain)))+','+ LTrim(RTrim(str(@LenLayerAcntRemain)))+') 
		and A.PartNumber = '+ LTrim(RTrim(str(@LayerAcntRemain)))+'
		left join acc.tblAcntDtl AD ON 
		A.AcntCode = AD.AcntCode 
		And A.PartNumber = AD.PartNumber
	'
	
	-- Sort Clause ---------------------------------------------
	If (@SortFields Is Not Null) AND (@SortFields <> '') 
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
