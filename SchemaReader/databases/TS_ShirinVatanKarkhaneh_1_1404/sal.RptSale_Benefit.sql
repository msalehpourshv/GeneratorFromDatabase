USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED =====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1386/04/08
-- Viewed By	 : 
-- Last Modified : 1392/01/24
-- Last Modifier : TakroSystem\Zia
-- Description	 : گزارش سود فروش
-- ==============================================
Create PROCEDURE [sal].[RptSale_Benefit]
	@ProcessID			Int = 90, -- 90
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = NULL,
	@SerialNoFr			Int = NULL,
	@FiscalYearTo		Int = NULL,
	@SerialNoTo			Int = NULL,
	@DocDateFr			Char(10) = NULL,
	@DocDateTo			Char(10) = NULL,
	@SelectedGoods		Int = NULL,
	@SelectedStore		Int = NULL,
	@SelectedAcnt1		Int = Null, 
	@SelectedAcnt2		Int = Null,
	@SelectedAcnt3		Int = Null,
	@SelectedAcnt4		Int = Null,
	@SelectedVisitor1	Int = NULL,
	@SelectedVisitor2	Int = NULL,
	@SelectedVisitor3	Int = NULL,
	@SelectedVisitor4	Int = NULL,
	@GroupByAcnt		Bit = 0,
	@SortField			NVarChar(100) = 'Code',
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = ''
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect		NVarChar(max);
Declare @StrFrom		NVarChar(max);
Declare @StrWhereD		NVarChar(max);
Declare @StrWhereH		NVarChar(max);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	Int;
DECLARE @ReportID	Int;

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
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
	IF (@DocDateTo Is Null)		SET @DocDateTo  = '9999/12/99';
	-- Init Variables --------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0
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

	SET @CustKind = LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	-- --------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	set @StrWhereD = ' (1=1)'
	set @StrWhereH = ' (1=1)'

	If (@ProcessNo Is Not Null) and @ProcessNo <> 0
		SET @StrWhereD = @StrWhereD + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	if (@CustKind <> '')
		Set @StrWhereD = @StrWhereD + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'

	If (@Dist0 <> 'null')
		SET @StrWhereH = @StrWhereH + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
	If (@Dist1 <> 'null')
		SET @StrWhereH = @StrWhereH + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
	If (@Dist2 <> 'null')
		SET @StrWhereH = @StrWhereH + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''

	If (@Dist5 <> 'null')
		SET @StrWhereH = @StrWhereH + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	If (@Dist7 <> 'null')
		SET @StrWhereH = @StrWhereH + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(@Dist8)

	IF (@SerialNoFr Is Not Null)
		SET @StrWhereD = @StrWhereD + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhereD = @StrWhereD + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhereD = @StrWhereD + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhereD = @StrWhereD + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	IF (@SelectedGoods > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	IF (@SelectedStore > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	IF (@SelectedAcnt1 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	IF (@SelectedVisitor1 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor2 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor3 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor4 > 0)
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'
	------------------------------------------------------------
	-- Select Clause -------------------------------------------
	declare @code nvarchar(100)
	declare @name nvarchar(200)

	If (@GroupByAcnt = 1)
	begin
		set @code = 'D.AcntCode'
		set @name = ''''' BarCode, pub.GetCodeName(T.Code, ' + @LangID + ')'
	end
	else
	begin
		set @code = 'D.GoodsID'
		set @name = 'IsNull([inv].[FunGetGoodsBarCode] (T.Code), '''') BarCode, 
					 [pub].[funGetGoodsName](T.Code,' + LTrim(RTrim(@LangID)) + ')'
	end
	
	SET @StrSelect = '
	select	D.Code, D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,D.Serials,
			Sum(D.Price) Price, 
			Sum(D.Amount) Amount, 
			Sum(D.Quantity) Quantity,
			Sum(D.DiscountDtl) DiscountDtl,
			Sum(D.PriceRet) PriceRet, 
			Sum(D.AmountRet) AmountRet, 
			Sum(D.QuantityRet) QuantityRet,
			Sum(D.DiscountDtlRet) DiscountDtlRet,
			case when (H.ProcessID = 90 ) then 1 else 0 end Invoice,
			case when (H.ProcessID = 90 ) then H.Discount + H.Discount2 + H.Discount3 else 0 end DiscountHdr,
			case when (H.ProcessID = 100) then H.Discount + H.Discount2 + H.Discount3 else 0 end DiscountHdrRet
	from
	(
		select	' + @code + ' Code, D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,  (select   stuff((
			select '','' , convert(varchar(20), S.PSerialNo)
			from inv.tblStorageDocsSerials S
			where S.ProcessID=D.ProcessID and S.ProcessNo=D.ProcessNo and S.DocRowNo=D.DocRowNo and S.SerialNo=D.SerialNo and S.FiscalYear=D.FiscalYear
			for xml path('''')
		),1,1,''''))  Serials ,
				D.GoodsQuantity Quantity, 
				D.DiscountDtl DiscountDtl, 
				(D.GoodsQuantity * D.GoodsPrice) Price, 
				(D.GoodsQuantity * D.' + LTRIM(inv.funGoodsAmount(@DocDateTo)) + ') Amount,
				0 QuantityRet, 0 DiscountDtlRet, 0 PriceRet, 0 AmountRet
		from	inv.tblStorageDocsDtl D 
		where	D.ProcessID = 90 and ' + @StrWhereD + '
		union all
		select	' + @code + ' Code, D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,  (select   stuff((
			select '','' , convert(varchar(20), S.PSerialNo)
			from inv.tblStorageDocsSerials S
			where S.ProcessID=D.ProcessID and S.ProcessNo=D.ProcessNo and S.DocRowNo=D.DocRowNo and S.SerialNo=D.SerialNo and S.FiscalYear=D.FiscalYear
			for xml path('''')
		),1,1,''''))  Serials ,
				0 Quantity, 0 DiscountDtl, 0 Price, 0 Amount,
				D.GoodsQuantity QuantityRet,
				D.DiscountDtl DiscountDtlRet,
				(D.GoodsQuantity * D.GoodsPrice) PriceRet,
				(D.GoodsQuantity * D.' + LTRIM(inv.funGoodsAmount(@DocDateTo)) + ') AmountRet
		from	inv.tblStorageDocsDtl D 
		where	D.ProcessID = 100 and ' + @StrWhereD + '
	) D inner join inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
	where ' + @StrWhereH + '
	group by D.Code, D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, H.ProcessID, H.TotalLineDiscount, H.Discount, H.Discount2 , H.Discount3 , D.Serials'

	------------------------------------------------------------
	-- Bind with Hdr -------------------------------------------
	SET @StrSelect = '
	SELECT	T.Code, ' + @name + ' AS [Name], ISNULL(T.Serials,'''') as Serials,
			sum(T.Invoice) InvoiceCount,
			Sum(T.Price) TotalPrice,
			Sum(T.Amount) TotalAmount,
			Sum(T.Quantity) TotalQuantity,
			Sum(T.DiscountDtl) TotalDiscountDtl, 
			Sum(T.DiscountHdr) TotalDiscountHdr, 
			Sum(T.PriceRet) TotalPriceRet,
			Sum(T.AmountRet) TotalAmountRet,
			Sum(T.QuantityRet) TotalQuantityRet,
			Sum(T.DiscountDtlRet) TotalDiscountDtlRet,
			Sum(T.DiscountHdrRet) TotalDiscountHdrRet,
			Sum(T.Quantity) - Sum(T.QuantityRet) As SaleCount,
			(Sum(T.Price)-	Sum(T.PriceRet))-(	Sum(T.Amount)-	Sum(T.AmountRet))-
			(Sum(T.DiscountHdr)-	Sum(T.DiscountHdrRet) +Sum(T.DiscountDtl)-Sum(T.DiscountDtlRet))
			as TotalBenefit
			
	FROM
	( 
	' + @StrSelect + '
	) T	
	GROUP BY T.Code,T.Serials '
	
	------------------------------------------------------------
	-- Sort Clause ---------------------------------------------
	If (@SortField Is Not Null) AND (@SortField <> '') 
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortField
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	--select @StrSelect
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
