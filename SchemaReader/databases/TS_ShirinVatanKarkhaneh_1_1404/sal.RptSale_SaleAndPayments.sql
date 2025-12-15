USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1390/12/12
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش وضعيت تسويه فاکتورها
-- ==============================================
Create PROCEDURE [sal].[RptSale_SaleAndPayments]
	@ProcessID			Int = 90,  -- default is sale
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@SelectedGoods		Int = Null,
	@SelectedStore		Int = Null,
	@SelectedStore2		Int = Null,
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@DocStep			Int = 0,  -- مرحله
	@PriceFr			bigint = -1,
	@PriceTo			bigint = -1,
	@CustKind			varchar(20) = null,
	@SaleTypeID			VarChar(20) = Null, -- کد نوع فروش
	@DocDescMask		NVarChar(100) = Null, -- بخشي از شرح
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@SortFields			NVarChar(100) = Null,
	@RepOptions			NVarChar(100) = '1000000',
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = '@0@0@0@-1@-1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- براي حالت کدهاي انتخابي
DECLARE	@ReportID		Int; -- براي حالت کدهاي انتخابي
DECLARE	@AddedValue		Bit;

DECLARE @Dist0		NVarChar(20); -- DriverID
DECLARE @Dist1		NVarChar(20); -- DistributerID1
DECLARE @Dist2		NVarChar(20); -- DistributerID2
DECLARE @Dist3		NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4		NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5		NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6		NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7		NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8		NVarChar(20); -- BaseDistributionSerialNo   to
DECLARE @UseVch2	bit;
DECLARE @FilterPrice	bit;
DECLARE @Price	Int;
DECLARE @Vch	varchar(20);

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;


	SET @FilterPrice	  = pub.funSplitString(@ExtraParams, '@', 1);	
	SET @Price  = pub.funSplitString(@ExtraParams, '@', 2);	

	
	-- Init -------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '1000000';
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1;
	IF (@DocStep	Is Null)	SET @DocStep = 0;
	If (@ExtraParams Is Null)   SET @ExtraParams = '';

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

	SET @AddedValue	= Substring(@RepOptions, 1, 1);
	SET @UseVch2	= Substring(@RepOptions, 2, 1);
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	SET @StrWhere = ' H.ProcessID = ' + LTrim(Str(@ProcessID))

	If (@AddedValue = 1)
		SET @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0)'

	if (@CustKind <> '')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(H.AcntCode) = ''' + @CustKind + ''')'

	If (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@Dist0 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
	If (@Dist1 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
	If (@Dist2 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''

	If (@Dist5 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	If (@Dist7 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(@Dist8)

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
			SET @StrWhere = @StrWhere + ' AND ' + @Vch + ' = ' + LTrim(Str(@VchNoFr))
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
	---------------------------------------------------------

	-- FROM Clause ------------------------------------------
	Set @StrFrom = 'inv.vwStorageDocsHdr H 
		INNER JOIN	inv.tblStoresDtl S1 ON H.StoreID  = S1.StoreID 
		LEFT JOIN	inv.tblStoresDtl S2 ON H.StoreID2 = S2.StoreID 
		LEFT JOIN	sal.tblTransportersDtl TR ON TR.TransporterID = H.TransporterID '
	---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
	create table #tbl_Sale_SaleAndPayments_Proc
	(
		ProcessID int not null,
		ProcessNo int not null,
		FiscalYear int not null,
		SerialNo int not null
	);
	
	SET @StrSelect = '
	insert into #tbl_Sale_SaleAndPayments_Proc(ProcessID, ProcessNo, FiscalYear, SerialNo)
	SELECT	H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo
	FROM  ' + @StrFrom + '
	WHERE ' + @StrWhere

	--if (@PriceFr <> -1) or (@PriceTo <> -1) 
	--begin
	--	set @StrWhere = '(1=1)'

	--	if (@PriceFr <> -1)
	--		set @StrWhere = @StrWhere + 'and (PriceSum + SidePriceSum >= ' + LTrim(Str(@PriceFr)) + ')'

	--	if (@PriceTo <> -1)
	--		set @StrWhere = @StrWhere + 'and (PriceSum + SidePriceSum <= ' + LTrim(Str(@PriceTo)) + ')'
		
	--	set @StrSelect = 
	--	'select T.* from (' + @StrSelect + ') T where ' + @StrWhere 
	--end

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
	Declare @trs_CalcChequeAvrageWithInvoiceDate bit;
	
	SELECT @trs_CalcChequeAvrageWithInvoiceDate=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'trs_CalcChequeAvrageWithInvoiceDate'
	
	select H.FiscalYear, H.SerialNo, H.AcntCode, H.DocDate, pub.GetCodeName(H.AcntCode,1) AcntName, H.EarnestMoney,

			(
				SELECT IsNull(SUM(D.GoodsPrice*D.GoodsQuantity), 0)
				FROM inv.tblStorageDocsDtl D
				WHERE D.ProcessID=H.ProcessID AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear AND D.SerialNo=H.SerialNo
			) - H.FixCost - H.OtherCost - H.TransportationCost - H.VisitorCost + H.OtherIncome + H.TransportationIncome + 
				H.PackingCost + H.TaxCost + H.TaxOverWorthCost + H.TollOverWorthCost- H.EarnestMoney
			AS PayablePrice,
			H.Discount,H.Discount2+H.Discount3 Discount2,H.TotalLineDiscount ,H.AfterSaleDiscount,
			IsNull((
				SELECT Sum(TD.Price)
				FROM sal.tblAfterSaleBillDtl TD
				WHERE (TD.ProcessID=212) and (TD.BaseProcessID=H.ProcessID) AND (TD.BaseProcessNo=H.ProcessNo) AND (TD.BaseFiscalYear=H.FiscalYear) AND (TD.BaseSerialNo=H.SerialNo)
			),0) as AfterSaleBillSum,
			H.Discount+H.Discount2+H.Discount3+H.AfterSaleDiscount+H.TotalLineDiscount+
			IsNull((
				SELECT SUM(TD.Price)
				FROM sal.tblAfterSaleBillDtl TD
				WHERE (TD.ProcessID=212) and (TD.BaseProcessID=H.ProcessID) AND (TD.BaseProcessNo=H.ProcessNo) AND (TD.BaseFiscalYear=H.FiscalYear) AND (TD.BaseSerialNo=H.SerialNo)
			),0) as DiscountSum,
			(
				SELECT IsNull(SUM(D.GoodsPrice*D.GoodsQuantity), 0)
				FROM inv.tblStorageDocsDtl D
				WHERE D.ProcessID=H.ProcessID AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear AND D.SerialNo=H.SerialNo
			) -H.Discount-H.Discount2-H.Discount3-H.TotalLineDiscount-H.AfterSaleDiscount-
			IsNull((
				SELECT SUM(TD.Price)
				FROM sal.tblAfterSaleBillDtl TD
				WHERE (TD.ProcessID=212) and (TD.BaseProcessID=H.ProcessID) AND (TD.BaseProcessNo=H.ProcessNo) AND (TD.BaseFiscalYear=H.FiscalYear) AND (TD.BaseSerialNo=H.SerialNo)
			),0)-H.FixCost-H.OtherCost-H.TransportationCost-H.VisitorCost+H.OtherIncome+H.TransportationIncome+H.PackingCost+H.TaxCost+H.TaxOverWorthCost+H.TollOverWorthCost- H.EarnestMoney
			AS LastPayablePrice,
		 IsNull((
				SELECT SUM(D.GoodsPrice*D.GoodsQuantity)+Sum(HH.TaxOverWorthCost)+Sum(HH.TollOverWorthCost)-
					   (Sum(HH.Discount)+Sum(HH.Discount2)+Sum(HH.Discount3)+Sum(HH.AfterSaleDiscount)+Sum(HH.TotalLineDiscount)+
						IsNull((
							SELECT SUM(TD.Price)
							FROM sal.tblAfterSaleBillDtl TD
							WHERE (TD.ProcessID=212) and (TD.BaseProcessID=H.ProcessID) AND (TD.BaseProcessNo=H.ProcessNo) AND (TD.BaseFiscalYear=H.FiscalYear) AND (TD.BaseSerialNo=H.SerialNo)
						),0))
				FROM inv.tblStorageDocsDtl D
				Inner Join inv.tblStorageDocsHdr HH ON HH.ProcessID = D.ProcessID And HH.ProcessNo = D.ProcessNo And
													  HH.FiscalYear = D.FiscalYear And HH.SerialNo = D.SerialNo
				where (D.ProcessID=100) and (D.BaseProcessID=H.ProcessID) AND (D.BaseProcessNo=H.ProcessNo) AND (D.BaseFiscalYear=H.FiscalYear) AND (D.BaseSerialNo=H.SerialNo)			
			),0) as ReturnPrice,
			IsNull((
				SELECT SUM(TD.Amount)
				FROM trs.tblPayDtl TD
						inner join trs.tblPayHdr TH on TH.ProcessID = TD.ProcessID and TD.ProcessNo = TH.ProcessNo and TD.FiscalYear = TH.FiscalYear and TD.SerialNo = TH.SerialNo
				WHERE (TH.BaseProcessID=H.ProcessID) AND (TH.BaseProcessNo=H.ProcessNo) AND (TH.BaseFiscalYear=H.FiscalYear) AND (TH.BaseSerialNo=H.SerialNo)
					and (TD.ProcessID in(1,3))
					and (TD.PayTypeID in (1,2,3,4,35))
			),0) as CashReceived,
			IsNull((
				SELECT SUM(TD.Amount)
				FROM trs.tblPayDtl TD
						inner join trs.tblPayHdr TH on TH.ProcessID = TD.ProcessID and TD.ProcessNo = TH.ProcessNo and TD.FiscalYear = TH.FiscalYear and TD.SerialNo = TH.SerialNo
				WHERE (TH.BaseProcessID=H.ProcessID) AND (TH.BaseProcessNo=H.ProcessNo) AND (TH.BaseFiscalYear=H.FiscalYear) AND (TH.BaseSerialNo=H.SerialNo)
					and (TD.ProcessID in(1,3))
					and (TD.PayTypeID in (1,2))
			),0) as CashReceived1,
			IsNull((
				SELECT SUM(TD.Amount)
				FROM trs.tblPayDtl TD
						inner join trs.tblPayHdr TH on TH.ProcessID = TD.ProcessID and TD.ProcessNo = TH.ProcessNo and TD.FiscalYear = TH.FiscalYear and TD.SerialNo = TH.SerialNo
				WHERE (TH.BaseProcessID=H.ProcessID) AND (TH.BaseProcessNo=H.ProcessNo) AND (TH.BaseFiscalYear=H.FiscalYear) AND (TH.BaseSerialNo=H.SerialNo)
					and (TD.ProcessID in(1,3))
					and (TD.PayTypeID in (3,4,35))
			),0) as CashReceived2,
			IsNull((
				SELECT SUM(TD.Amount)
				FROM trs.tblPayDtl TD
						inner join trs.tblPayHdr TH on TH.ProcessID = TD.ProcessID and TD.ProcessNo = TH.ProcessNo and TD.FiscalYear = TH.FiscalYear and TD.SerialNo = TH.SerialNo
						inner join trs.tblOurBanks O on O.BankCode = TD.DebitCode
				WHERE (TH.BaseProcessID=H.ProcessID) AND (TH.BaseProcessNo=H.ProcessNo) AND (TH.BaseFiscalYear=H.FiscalYear) AND (TH.BaseSerialNo=H.SerialNo)
					and (TD.ProcessID in(1,3))
					and (TD.PayTypeID in (1,2,3,4))
					and (O.BankState <> 3)
			),0) as CashReceivedInCash,
			IsNull((
				SELECT SUM(TD.Amount)
				FROM trs.tblPayDtl TD
						inner join trs.tblPayHdr TH on TH.ProcessID = TD.ProcessID and TD.ProcessNo = TH.ProcessNo and TD.FiscalYear = TH.FiscalYear and TD.SerialNo = TH.SerialNo
						inner join trs.tblOurBanks O on O.BankCode = TD.DebitCode
				WHERE (TH.BaseProcessID=H.ProcessID) AND (TH.BaseProcessNo=H.ProcessNo) AND (TH.BaseFiscalYear=H.FiscalYear) AND (TH.BaseSerialNo=H.SerialNo)
					and (TD.ProcessID in(1,3))
					and (TD.PayTypeID in (1,2,3,4,35))
					and (O.BankState = 3)
			),0) as CashReceivedInBank,
			IsNull((
				SELECT SUM(TD.Amount)
				FROM trs.tblPayDtl TD
						inner join trs.tblPayHdr TH on TH.ProcessID = TD.ProcessID and TD.ProcessNo = TH.ProcessNo and TD.FiscalYear = TH.FiscalYear and TD.SerialNo = TH.SerialNo
				WHERE (TH.BaseProcessID=H.ProcessID) AND (TH.BaseProcessNo=H.ProcessNo) AND (TH.BaseFiscalYear=H.FiscalYear) AND (TH.BaseSerialNo=H.SerialNo)
					and (TD.ProcessID in(1,3))
					and (TD.PayTypeID in (6,16,26))
			),0) as CheqReceived,
			IsNull((	SELECT 
			sum(DateDiff(DAY,[pub].[funChangeDate_PersianToGergorian] ( case when @trs_CalcChequeAvrageWithInvoiceDate=1 then HH.DocDate else TH.DocDate end ),[pub].[funChangeDate_PersianToGergorian] (
				case when TD.ChequeDate IS null OR  TD.ChequeDate ='' then  TD.DocDate else TD.ChequeDate end 
			))	 * TD.Amount) /sum ( TD.Amount )
				FROM trs.tblPayDtl TD
						inner join trs.tblPayHdr TH on TH.ProcessID = TD.ProcessID and TD.ProcessNo = TH.ProcessNo and TD.FiscalYear = TH.FiscalYear and TD.SerialNo = TH.SerialNo
						inner join inv.tblStorageDocsHdr HH
						On  TH.BaseProcessID = HH.ProcessID  
						and HH.ProcessNo = TH.BaseProcessNo and HH.FiscalYear = TH.BaseFiscalYear 
						and HH.SerialNo = TH.BaseSerialNo
								WHERE (TH.BaseProcessID=H.ProcessID) AND (TH.BaseProcessNo=H.ProcessNo) AND (TH.BaseFiscalYear=H.FiscalYear) AND (TH.BaseSerialNo=H.SerialNo)
					and (TD.ProcessID in(1,3))
			),0) as ChequeAvrage,
		
			IsNull((
				SELECT SUM(TD.Price)
				FROM sal.tblAfterSaleBillDtl TD
				WHERE (TD.ProcessID=211) and (TD.BaseProcessID=H.ProcessID) AND (TD.BaseProcessNo=H.ProcessNo) AND (TD.BaseFiscalYear=H.FiscalYear) AND (TD.BaseSerialNo=H.SerialNo)
			),0) as AfterSalePrice,
		
			IsNull((
				select SUM(IsNull(T.SubUnitPrice-TD.Amount,0)*(T.SubUnitQuantity-T.RetQuantity))
				from
				(
					SELECT D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.SubUnitPrice, D.SubUnitQuantity, D.DocDate, D.GoodsID, D.SubUnitID,
						0 RetQuantity
						-- *** More than 1 value error ***
						--isnull((
						--	select SUM(D.SubUnitQuantity)
						--	from inv.tblStorageDocsDtl R
						--	where (R.ProcessID=100) and (R.BaseProcessID=D.ProcessID) and (R.BaseProcessNo=D.ProcessNo) and (R.BaseFiscalYear=D.FiscalYear) and (R.BaseSerialNo=D.SerialNo) and (R.BaseDocRowNo=D.DocRowNo)
						--),0) RetQuantity
					FROM inv.tblStorageDocsDtl D
					group by D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.SubUnitPrice, D.SubUnitQuantity, D.DocDate, D.GoodsID, D.SubUnitID
				) T
					left join sal.tblGoodsPriceForCustomerKindDtl TD on TD.GoodsID = T.GoodsID and TD.SubUnitID = T.SubUnitID
					left join sal.tblGoodsPriceForCustomerKindHdr TH on TH.SerialNo = TD.SerialNo
				where (T.ProcessID=H.ProcessID) AND (T.ProcessNo=H.ProcessNo) AND (T.FiscalYear=H.FiscalYear) AND (T.SerialNo=H.SerialNo) and (T.DocDate >= TH.FromDate) and (T.DocDate <= TH.ToDate)
			),0) as DiffAmount,PR1.PersonnelName DistributerName1, DH.SerialNo as DistSerialNo,
			PR2.PersonnelName DistributerName2, H.DistributerID1, H.DistributerID2,
			DV.FirstName + ' ' + DV.LastName as DriverName, DH.DocDate as DistDate
			,
			(SELECT IsNull(Sum(Debit-Credit),0) as Remain 
			 From acc.tblVoucherDtl 
			 Where	AcntCode=H.AcntCode  AND 
					DocDate<H.DocDate) As RemainBeforFact
		  ,H.VisitorAcntCode,H.StoreID StoreIDHdr,[pub].[GetStoreName](H.StoreID,1) StoreNameHdr, 
		  	IsNull((
				SELECT SUM(TH.DiscountAmount)
				FROM trs.tblPayHdr TH 
				WHERE (TH.BaseProcessID=H.ProcessID) AND (TH.BaseProcessNo=H.ProcessNo) AND (TH.BaseFiscalYear=H.FiscalYear) AND (TH.BaseSerialNo=H.SerialNo)
			),0) as DiscountAmount
	INTO #a
	FROM inv.tblStorageDocsHdr H
	left join pub.tblDriversDtl DV on H.DriverID = DV.DriverID and LanguageID = 1
	left join prs.vwPersonnels PR1 on H.DistributerID1 = PR1.PersonnelID 
	left join prs.vwPersonnels PR2 on H.DistributerID2 = PR2.PersonnelID 
	left join sal.tblDistributionsHdr DH on DH.ProcessID = H.BaseDistributionProcessID and DH.SerialNo = H.BaseDistributionSerialNo
	left join sal.tblDistributionsDtl DD on DD.BaseSaleProcessID = H.ProcessID and DD.BaseSaleProcessNo = H.ProcessNo and DD.BaseSaleFiscalYear = H.FiscalYear and DD.BaseSaleSerialNo = H.SerialNo
	left join sal.tblSaleTypesDtl ST on ST.SaleTypeID = H.SaleTypeID
	inner join #tbl_Sale_SaleAndPayments_Proc B on B.ProcessID = H.ProcessID and B.ProcessNo = H.ProcessNo and B.FiscalYear = H.FiscalYear and B.SerialNo = H.SerialNo

DECLARE @Start	Int;
DECLARE @Len	Int;
DECLARE @PartNumber	Int;


select @PartNumber=[acc].[FunGetAcntInfoForRemain](1),@Start=[acc].[FunGetAcntInfoForRemain](2),@Len=[acc].[FunGetAcntInfoForRemain](3)
	if (@FilterPrice=0)
		select a.*,b.Tel,b.Mobile,c.Address1,c.Address2,d.LocationName,v.AcntName VisitorName from #a  a
		left join acc.tblAcnt b ON substring(a.AcntCode,@Start,@Len)=b.AcntCode	and b.PartNumber=@PartNumber
		left join acc.tblAcntDtl c ON substring(a.AcntCode,@Start,@Len)=c.AcntCode	and c.PartNumber=@PartNumber and c.LanguageID=@LangID	 	
		left join pub.tblLocationsDtl d ON b.LocationID=d.LocationID and d.LanguageID=@LangID	
		left join acc.tblAcntDtl v ON substring(a.VisitorAcntCode,@Start,@Len)=v.AcntCode	and v.PartNumber=@PartNumber and v.LanguageID=@LangID	 	
				
				
		order by a.FiscalYear,a.SerialNo
	else
		select a.*,b.Tel,b.Mobile,c.Address1,c.Address2,d.LocationName,v.AcntName VisitorName from #a a
		left join acc.tblAcnt b ON substring(a.AcntCode,@Start,@Len)=b.AcntCode	and b.PartNumber=@PartNumber
		left join acc.tblAcntDtl c ON substring(a.AcntCode,@Start,@Len)=c.AcntCode	and c.PartNumber=@PartNumber and c.LanguageID=@LangID	 	
		left join pub.tblLocationsDtl d ON b.LocationID=d.LocationID and d.LanguageID=@LangID	 	
		left join acc.tblAcntDtl v ON substring(a.VisitorAcntCode,@Start,@Len)=v.AcntCode	and v.PartNumber=@PartNumber and v.LanguageID=@LangID	 	
		where ( (a.PayablePrice - a.ReturnPrice - a.CashReceived - a.CheqReceived + a.AfterSalePrice) + a.RemainBeforFact) > @Price 
		order by a.FiscalYear,a.SerialNo

	-- SORT Clause ---------------------------------------------
--	If (@SortFields Is Not Null)
--		Set @StrSelect = @StrSelect + ' 
--	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
--	Print @StrSelect;
--	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
