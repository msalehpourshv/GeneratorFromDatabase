USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1390/05/18
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش سربرگ برگه های انبار - بهمراه وضعیت پرداختها
-- ==============================================
Create PROCEDURE [inv].[RptStore_Header2]
	@ProcessID			Int = 90,  -- default is sale
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@PriceFr			float(20)= Null,
	@PriceTo			float(20)= Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@SelectedGoods		Int = Null,
	@SelectedGoods2		Int = Null,
	@SelectedStore		Int = Null,
	@SelectedStore2		Int = Null,
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
	@SaleTypeID			VarChar(20) = Null, -- کد نوع فروش
	@CustKind			VarChar(20) = null,
	@DocDescMask		NVarChar(100) = Null, -- بخشی از شرح
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@SortFields			NVarChar(100) = Null,
	@RepOptions			VarChar(20) = '00011', 
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = '0'
WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @UseAmount		bit;
DECLARE @AddedValue		bit;
DECLARE @UseVch2		bit;
DECLARE @RemainOK		bit;
DECLARE @RemainNo		bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @Dist0		NVarChar(20); -- DriverID
DECLARE @Dist1		NVarChar(20); -- DistributerID1
DECLARE @Dist2		NVarChar(20); -- DistributerID2
DECLARE @Dist3		NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4		NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5		NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6		NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7		NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8		NVarChar(20); -- BaseDistributionSerialNo   to
DECLARE @Vch		varchar(20);

DECLARE @SelectedGoods3	Int;
DECLARE @Prc AS VarChar(20);
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '00011';
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1;
	IF (@DocStep	Is Null)	SET @DocStep = 0;
	If (@UseAmount  Is Null)    SET @UseAmount = 0;
	If (@ExtraParams Is Null)   SET @ExtraParams = '@0@0';

	IF (@DocDateFr	Is Null)	SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)	SET @DocDateTo = '@@@';
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null';

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0
	IF (@SelectedStore2 Is Null)	SET @SelectedStore2 = 0
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0
	IF (@SelectedOrders1 Is Null)	SET @SelectedOrders1 = 0
	IF (@SelectedOrders2 Is Null)	SET @SelectedOrders2 = 0
	IF (@SelectedOrders3 Is Null)	SET @SelectedOrders3 = 0
	IF (@SelectedOrders4 Is Null)	SET @SelectedOrders4 = 0
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

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

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @UseAmount	= Substring(@RepOptions, 1, 1)
	SET @AddedValue	= Substring(@RepOptions, 2, 1)
	SET @UseVch2	= Substring(@RepOptions, 3, 1)
	SET @RemainOK	= Substring(@RepOptions, 4, 1)
	SET @RemainNo	= Substring(@RepOptions, 5, 1)

	begin try
		SET @SelectedGoods3 = cast(LTrim(pub.funSplitString(@ExtraParams, '@', 2)) as int);
	end try
	begin catch
		SET @SelectedGoods3 = 0;
	end catch

	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	SET @StrWhere = ' H.ProcessID = ' + LTrim(Str(@ProcessID))

	If (@AddedValue = 1)
		SET @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0)'

	if (@CustKind is not null) and (@CustKind <> '')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(H.AcntCode) = ''' + @CustKind + ''')'

	If (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.ProcessNo = ' + LTrim(Str(@ProcessNo))

   If (@Dist0 <> 'null')
	begin
		if (@ProcessID = 100)
			SET @StrWhere = @StrWhere + ' AND
				 (SELECT isnull(H2.DriverID,'''')DriverID2 from inv.tblStorageDocsHdr H2
							WHERE H.BaseProcessID=H2.ProcessID
							and H.BaseSerialNo=H2.SerialNo
							and H.BaseProcessNo=H2.ProcessNo
							and H.BaseFiscalYear=H2.FiscalYear) = ''' + LTrim(@Dist0) + ''''
		else
			SET @StrWhere = @StrWhere + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
	end
	
	
	If (@Dist1 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
	If (@Dist2 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''

	If (@Dist5 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	If (@Dist7 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(@Dist8)

	If (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')

	if (@UseVch2 = 1)
		set @Vch = 'H.VchNo2'
	else
		set @Vch = 'H.VchNo'

	If (@VchNoFr Is Not Null) OR (@VchNoTo Is Not Null)
		If (@VchNoFr = @VchNoTo)
			SET @StrWhere = @StrWhere + ' AND ' + @Vch + '  = ' + LTrim(Str(@VchNoFr))
		Else
		Begin
			If (@VchNoFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND ' + @Vch + ' >= ' + LTrim(Str(@VchNoFr))
			If (@VchNoTo Is Not Null)
				SET @StrWhere = @StrWhere + ' AND ' + @Vch + ' <= ' + LTrim(Str(@VchNoTo))
		End

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.ProductID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 
	If (@SelectedStore2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'H.StoreID2')

	If (@SelectedOrders1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders1, 'H.OrderAcntCode') 
	If (@SelectedOrders2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders2, 'H.OrderAcntCode') 
	If (@SelectedOrders3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders3, 'H.OrderAcntCode') 
	If (@SelectedOrders4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders4, 'H.OrderAcntCode')

	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'

	If @SaleTypeID Is Not Null
		Set @StrWhere = @StrWhere + ' AND (H.SaleTypeID = ''' + @SaleTypeID + ''')'

	If (@DocStep > 0)
		if @ProcessID = 55
			Set @StrWhere = @StrWhere + ' AND H.DocStep = ' + LTrim(Str(@DocStep))
		else
			Set @StrWhere = @StrWhere + ' AND H.DocStep >= ' + LTrim(Str(@DocStep))

	-- Acnt Filter 
	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	If (@DocDescMask Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (Replace(H.DocDesc, '' '', '''') LIKE N''%' + RTrim(Replace(@DocDescMask, ' ', '')) + '%'')'

	IF (@UseAmount = 1)
		SET @Prc = 'GoodsAmount'
	ELSE
		SET @Prc = 'GoodsPrice'
	---------------------------------------------------------

	-- FROM Clause ------------------------------------------
	Set @StrFrom = 'inv.vwStorageDocsHdr H 
		INNER JOIN	inv.tblStoresDtl S1 ON H.StoreID  = S1.StoreID 
		LEFT  JOIN	inv.tblStoresDtl S2 ON H.StoreID2 = S2.StoreID 
		LEFT  JOIN	sal.tblTransportersDtl TR ON TR.TransporterID = H.TransporterID 
		LEFT  JOIN	
		(
			SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,
					isnull(sum(D.' + @Prc + ' * D.GoodsQuantity), 0) PriceSum,
					isnull(sum(D.GoodsQuantity), 0) QuantitySum,
					isnull(sum(D.DiscountDtl), 0) DiscountDtlSum
			FROM inv.tblStorageDocsDtl D
			GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo
		) as D on D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo'

	if (@SelectedGoods3 > 0)
	Set @StrFrom = @StrFrom + '
		INNER JOIN (
			select distinct ProcessID, ProcessNo, FiscalYear, SerialNo
			from inv.tblStorageDocsDtl D2
			where ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods3, 'D2.GoodsID') + ') T1 on T1.ProcessID = H.ProcessID and T1.ProcessNo = H.ProcessNo and T1.FiscalYear = H.FiscalYear and T1.SerialNo = H.SerialNo '
	---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
	SET @StrSelect = '
	SELECT	H.*, S1.StoreName, S2.StoreName AS StoreName2, D.PriceSum, D.QuantitySum, D.DiscountDtlSum,
			pub.GetCodeName(H.VisitorAcntCode, ' + @LangID + ') AS VisitorAcntName, TR.TransporterName,
			pub.funGetSaleTypesName(H.SaleTypeID, ' + @LangID + ') as SaleTypeName,
			pub.GetGoodsName(H.ProductID, ' + @LangID + ') as ProductName,
			pub.GetCodeName(H.AcntCode, ' + @LangID + ') AS AcntName, 
			(
				select	isnull(sum(A.AtomAmount), 0)
				from	inv.tblStorageDocsAtom A
				where	A.ProcessID = H.ProcessID AND A.ProcessNo = H.ProcessNo AND A.FiscalYear = H.FiscalYear AND A.SerialNo = H.SerialNo
			) AS AtomSum, 
			(
				select	IsNull(Sum(Amount), 0) PaidAmount
				from	trs.tblPayHdr S
				inner join trs.tblPayDtl D
				on S.ProcessID=D.ProcessID and S.ProcessNo=D.ProcessNo and S.FiscalYear=D.FiscalYear AND S.SerialNo=D.SerialNo
				where	S.BaseProcessID = H.ProcessID and S.BaseProcessNo = H.ProcessNo AND S.BaseFiscalYear = H.FiscalYear and S.BaseSerialNo = H.SerialNo
			) PaidAmount
	FROM  ' + @StrFrom + '
	WHERE ' + @StrWhere

	-- outer where -----------------------

	set @StrWhere = '(1=1)'

	if (@PriceFr > -1)
		set @StrWhere = @StrWhere + 'and (PriceSum + SidePriceSum - DiscountDtlSum >= ' + LTrim(Str(@PriceFr)) + ')'

	if (@PriceTo > -1)
		set @StrWhere = @StrWhere + 'and (PriceSum + SidePriceSum - DiscountDtlSum <= ' + LTrim(Str(@PriceTo)) + ')'
		
	if (@RemainNo = 0)
		set @StrWhere = @StrWhere + 'and (PriceSum + SidePriceSum - DiscountDtlSum > PaidAmount)'

	if (@RemainOK = 0)
		set @StrWhere = @StrWhere + 'and (PriceSum + SidePriceSum - DiscountDtlSum <= PaidAmount )'

	set @StrSelect = 'select T.* from (' + @StrSelect + ') T where ' + @StrWhere 
	------------------------------------------------------------

	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
