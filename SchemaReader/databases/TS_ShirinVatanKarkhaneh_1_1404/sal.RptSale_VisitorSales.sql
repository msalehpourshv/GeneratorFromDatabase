USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1388/06/04
-- Viewed By	 : 
-- Last Modified : 1388/06/28
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : گزارش لیست فروش ویزیتورها
-- ==============================================
Create PROCEDURE [sal].[RptSale_VisitorSales]
	@ProcessID			Int = 90,  -- default is sale
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SaleTypeID			VarChar(20) = Null, -- کد نوع فروش
	@DocDescMask		NVarChar(100) = Null, -- بخشی از شرح
	@DocStep			Int = 0,  -- مرحله
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
	@RepOptions			VarChar(10) = '110', -- bit array options
	@SortFields			NVarChar(100) = Null,
	@ExtraParams		NVarChar(200) = '',
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		nVarChar(max);
DECLARE @StrSelect2		nVarChar(max);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @BaseDate		NVarChar(10);
DECLARE @StrQty			VarChar(1000);
DECLARE @StrPrc			VarChar(1000);
DECLARE @StrWhereRets	NVarChar(2000);
DECLARE @ShowQuantity	Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		Bit;  -- شامل ستون قیمت
DECLARE @DecReturn		Bit;  -- کسر برگشتیها
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE @CustKind		VarChar(20);
DECLARE @WithoutVisitor	Bit; 
DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
DECLARE @StartLayerAcntRemain	int;
DECLARE @LenLayerAcntRemain		int;
DECLARE @MainAndSubUnit			int;
DECLARE @NoReward				bit
DECLARE @OnlyReward				 bit

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
		
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

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	--==============
	Declare @CustomerPartNo AS Tinyint
	SET @CustomerPartNo = 0
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'	
	
	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '110001';
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1;
	IF (@DocStep	Is Null)	SET @DocStep = 0;
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';

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

	If (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	SET @ShowQuantity	= Substring(@RepOptions, 1, 1)
	SET @ShowPrice		= Substring(@RepOptions, 2, 1)
	SET @DecReturn		= Substring(@RepOptions, 3, 1)
	SET @WithoutVisitor	= Substring(@RepOptions, 4, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	SET @CustKind = LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	---------------------------------------------------------
	SET @CampaignID	     = pub.funSplitString(@ExtraParams,'@',6);
	SET @VisitPathID1 	 = pub.funSplitString(@ExtraParams, '@', 7);
	SET @VisitPathID2	 = pub.funSplitString(@ExtraParams, '@', 8);
	SET @VisitPathID3	 = pub.funSplitString(@ExtraParams, '@', 9);
	SET @VisitPathID4	 = pub.funSplitString(@ExtraParams, '@', 10);
	SET @SalesRoomClass	 = pub.funSplitString(@ExtraParams, '@', 11);
	SET @MainAndSubUnit	 = pub.funSplitString(@ExtraParams, '@', 12);
	SET @NoReward	 = pub.funSplitString(@ExtraParams, '@', 13);
	SET @OnlyReward	 = pub.funSplitString(@ExtraParams, '@', 14);

	-- Where Clause -----------------------------------------
	--Set @StrWhere = ' D.ProcessID = ' + LTrim(Str(@ProcessID)) + ' AND (H.VisitorAcntCode Is Not Null) AND (H.VisitorAcntCode <> '''')'
	IF @WithoutVisitor = 1
	Begin
		Set @StrWhere = '(D.ProcessID=' + LTrim(Str(@ProcessID)) + ')'
		Set @StrWhereRets = '(D.ProcessID = 100)'
	End
	ELSE
	Begin
		Set @StrWhere = '(D.ProcessID=' + LTrim(Str(@ProcessID)) + ') AND (H.VisitorAcntCode Is Not Null) AND (H.VisitorAcntCode <> '''')'
		Set @StrWhereRets = '(D.ProcessID = 100) AND (D.VisitorAcntCode Is Not Null) AND (D.VisitorAcntCode <> '''')'
	End
	If (@NoReward > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND D.IsReward=0  AND D.IsReward0=0  ' 
		SET @StrWhereRets = @StrWhereRets + ' AND D.IsReward=0  AND D.IsReward0=0  ' 
	end
	
	If (@OnlyReward > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (D.IsReward=1 or D.IsReward0=1 ) ' 
		SET @StrWhereRets = @StrWhereRets + '   AND (D.IsReward=1 or D.IsReward0=1 )  ' 
	end	

	IF (@DocStep > 0)
		IF @ProcessID = 55
			SET @StrWhere = @StrWhere + ' AND D.DocStep = ' + LTrim(Str(@DocStep))
		ELSE
			SET @StrWhere = @StrWhere + ' AND D.DocStep >= ' + LTrim(Str(@DocStep))
		
	IF @ProcessNo Is Not Null
		Set @StrWhere = @StrWhere + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	IF @ProcessNo Is Not Null
		Set @StrWhereRets = @StrWhereRets + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	if (@CustKind <> '')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'
	if (@CustKind <> '')
		Set @StrWhereRets = @StrWhereRets + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'

	IF (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	IF (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			Set @StrWhere = @StrWhere + ' AND (D.DocDate  = ''' + @DocDateFr + ''')'
		Else 
		Begin
			IF (@DocDateFr Is Not Null)
				Set @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				Set @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		End
	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			Set @StrWhereRets = @StrWhereRets + ' AND (D.DocDate  = ''' + @DocDateFr + ''')'
		Else 
		Begin
			IF (@DocDateFr Is Not Null)
				Set @StrWhereRets = @StrWhereRets + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				Set @StrWhereRets = @StrWhereRets + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		End
	IF (@VchNoFr Is Not Null) OR (@VchNoTo Is Not Null)
		IF (@VchNoFr = @VchNoTo)
			Set @StrWhere = @StrWhere + ' AND H.VchNo  = ' + LTrim(Str(@VchNoFr))
		Else
		Begin
			If (@VchNoFr Is Not Null)
				Set @StrWhere = @StrWhere + ' AND H.VchNo >= ' + LTrim(Str(@VchNoFr))
			If (@VchNoTo Is Not Null)
				Set @StrWhere = @StrWhere + ' AND H.VchNo <= ' + LTrim(Str(@VchNoTo))
		End
		
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

	IF (@CampaignID > 0)
	 	    SET @StrWhereRets = @StrWhereRets + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'CampaignID') +' ) '
	IF (@VisitPathID1 > 0)
	 	    SET @StrWhereRets = @StrWhereRets + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'VisitPathID1') +' ) '
	IF (@VisitPathID2 > 0)
	 	    SET @StrWhereRets = @StrWhereRets + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'VisitPathID2') +' ) '
	IF (@VisitPathID3 > 0)
	 	    SET @StrWhereRets = @StrWhereRets + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'VisitPathID3') +' ) '
	IF (@VisitPathID4 > 0)
	 	    SET @StrWhereRets = @StrWhereRets + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'VisitPathID4') +' ) '
	IF (@SalesRoomClass > 0)
	 	    SET @StrWhereRets = @StrWhereRets + ' AND  substring(H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt where '+ pub.funGetFilterString(@SessionNo, @ReportID, @SalesRoomClass, 'SalesRoomClass') +' ) '

	If @SaleTypeID Is Not Null
		Set @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @SaleTypeID + ''')'

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	If (@SelectedStore2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')
If (@SelectedGoods > 0)
		SET @StrWhereRets = @StrWhereRets + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhereRets = @StrWhereRets + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	If (@SelectedStore2 > 0)
		SET @StrWhereRets = @StrWhereRets + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
If (@SelectedAcnt1 > 0)
		SET @StrWhereRets = @StrWhereRets + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereRets = @StrWhereRets + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereRets = @StrWhereRets + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereRets = @StrWhereRets + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

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
	If (@SelectedVisitor1 > 0)
		SET @StrWhereRets = @StrWhereRets + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhereRets = @StrWhereRets + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhereRets = @StrWhereRets + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhereRets = @StrWhereRets + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'
---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
	SET @StrQty	= 'D.GoodsQuantity'
	SET @StrPrc	= 'D.GoodsQuantity * D.GoodsPrice' 

	SET @StrSelect = '
	SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocDate, D.DocRowNo, D.BaseFiscalYear, D.BaseSerialNo,
			pub.funFarsiDateDiff(''Day'', ''' + @BaseDate + ''', D.DocDate) AS DateDuration,
			D.StoreID, D.StoreID2, S1.StoreName, S2.StoreName AS StoreName2,
			D.GoodsID, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		    IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,
			D.AcntCode, pub.GetCodeName(D.AcntCode, ' + @LangID + ') AS AcntName,
			H.DiscountPercent, H.Discount, H.Discount2+H.Discount3 Discount2, H.TaxOverWorthCost, H.TransportationIncome, 
			H.TransportationCost, H.OtherIncome, H.OtherCost, H.PackingCost, H.TaxCost,
			' + @StrQty + ' Quantity, ' + @StrPrc + ' Price, AtomAmount Overload, 
			H.ProductID, H.ProductCount, pub.GetGoodsName(H.ProductID, ' + @LangID + ') As ProductName,
			(
				SELECT	IsNull(SUM(GoodsQuantity), 0)
				FROM	inv.tblStorageDocsDtl 
				WHERE	' + @StrWhereRets+ ' AND 
						BaseProcessID = D.ProcessID AND 
						BaseProcessNo = D.ProcessNo AND 
						BaseFiscalYear = D.FiscalYear AND 
						BaseSerialNo = D.SerialNo AND 
						BaseDocRowNo = D.DocRowNo
			) ReturnQuantity,
			(
				SELECT	IsNull(SUM(GoodsQuantity * GoodsPrice), 0)
				FROM	inv.tblStorageDocsDtl 
				WHERE	' + @StrWhereRets+ '  AND 
						BaseProcessID = D.ProcessID AND 
						BaseProcessNo = D.ProcessNo AND 
						BaseFiscalYear = D.FiscalYear AND 
						BaseSerialNo = D.SerialNo AND 
						BaseDocRowNo = D.DocRowNo
			) ReturnPrice, H.VisitorAcntCode, pub.GetCodeName(H.VisitorAcntCode, ' + @LangID + ') VisitorAcntName,
			F.LocationID, pub.funGetLocationName(F.LocationID,1) LocationName, F.Address1, F.Address2, F.Tel,
			acc.funLayerAcntName(D.AcntCode, ' + LTRIM(Str(@CustomerPartNo)) + ', 1) PartAcntName1,
			acc.funLayerAcntName(D.AcntCode, ' + LTRIM(Str(@CustomerPartNo)) + ', 2) PartAcntName2,			
			acc.funLayerAcntName(D.AcntCode, ' + LTRIM(Str(@CustomerPartNo)) + ', 3) PartAcntName3,
			acc.funLayerAcntName(D.AcntCode, ' + LTRIM(Str(@CustomerPartNo)) + ', 4) PartAcntName4,
			acc.funLayerAcntName(D.AcntCode, ' + LTRIM(Str(@CustomerPartNo)) + ', 5) PartAcntName5
	FROM  inv.tblStorageDocsDtl D 
	INNER JOIN	inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
	INNER JOIN	inv.tblStoresDtl S1 ON D.StoreID  = S1.StoreID AND S1.LanguageID = ' + @LangID + '
	LEFT JOIN	inv.tblStoresDtl S2 ON D.StoreID2 = S2.StoreID AND S2.LanguageID = ' + @LangID + '
	OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
	WHERE ' + @StrWhere

	SET @StrSelect2 =''
		if @DecReturn=1
	SET @StrSelect2 = ' Union All
	SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocDate, D.DocRowNo, D.BaseFiscalYear, D.BaseSerialNo,
			pub.funFarsiDateDiff(''Day'', ''' + @BaseDate + ''', D.DocDate) AS DateDuration,
			D.StoreID, D.StoreID2, S1.StoreName, S2.StoreName AS StoreName2,
			D.GoodsID, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		    IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,
			D.AcntCode, pub.GetCodeName(D.AcntCode, ' + @LangID + ') AS AcntName,
			H.DiscountPercent, H.Discount, H.Discount2+H.Discount3 Discount2, H.TaxOverWorthCost, H.TransportationIncome, 
			H.TransportationCost, H.OtherIncome, H.OtherCost, H.PackingCost, H.TaxCost,
			' + @StrQty + ' Quantity, ' + @StrPrc + ' Price, AtomAmount Overload, 
			H.ProductID, H.ProductCount, pub.GetGoodsName(H.ProductID, ' + @LangID + ') As ProductName,
			GoodsQuantity ReturnQuantity,
			(GoodsQuantity * GoodsPrice) ReturnPrice, H.VisitorAcntCode, pub.GetCodeName(H.VisitorAcntCode, ' + @LangID + ') VisitorAcntName,
			F.LocationID, pub.funGetLocationName(F.LocationID,1) LocationName, F.Address1, F.Address2, F.Tel,
			acc.funLayerAcntName(D.AcntCode, ' + LTRIM(Str(@CustomerPartNo)) + ', 1) PartAcntName1,
			acc.funLayerAcntName(D.AcntCode, ' + LTRIM(Str(@CustomerPartNo)) + ', 2) PartAcntName2,			
			acc.funLayerAcntName(D.AcntCode, ' + LTRIM(Str(@CustomerPartNo)) + ', 3) PartAcntName3,
			acc.funLayerAcntName(D.AcntCode, ' + LTRIM(Str(@CustomerPartNo)) + ', 4) PartAcntName4,
			acc.funLayerAcntName(D.AcntCode, ' + LTRIM(Str(@CustomerPartNo)) + ', 5) PartAcntName5
	FROM  inv.tblStorageDocsDtl D 
	INNER JOIN	inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
	INNER JOIN	inv.tblStoresDtl S1 ON D.StoreID  = S1.StoreID AND S1.LanguageID = ' + @LangID + '
	LEFT JOIN	inv.tblStoresDtl S2 ON D.StoreID2 = S2.StoreID AND S2.LanguageID = ' + @LangID + '
	OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
	WHERE ' + @StrWhereRets
	------------------------------------------------------------
	
		--pub.funSplitString(@ExtraParams,'@',6)
	if @MainAndSubUnit=1 
	Set @StrSelect =  ' Select * 
	,pub.funSplitString(QtyParams,'''+'@'+''',1) Qty
	,pub.funSplitString(QtyParams,'''+'@'+''',2) SubQty
	,pub.funSplitString(QtyParams,'''+'@'+''',9) UnitName  
	,pub.funSplitString(QtyParams,'''+'@'+''',10) SubUnitName
	
	from ( Select *, [inv].[funGetMainAndSubUnitQty](GoodsID,Quantity)  QtyParams from ('+@StrSelect + +@StrSelect2 +  ' ) aaaa) aaaa '
	else
	Set @StrSelect =  ' Select * 
	,0 Qty
	,0 SubQty
	,'''' UnitName  
	,'''' SubUnitName
	,'''' QtyParams 
	from ('+@StrSelect + @StrSelect2 +  ' ) aaaa '
	Set @StrSelect = @StrSelect + ' 	ORDER BY ProcessID ' 
	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + ',' + @SortFields
	
	------------------------------------------------------------

	

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
