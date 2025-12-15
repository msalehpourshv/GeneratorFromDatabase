USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1395/09/08
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[SPSaleReturn_Price2]
(
	@ProcessID			Int = 90,
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocRowNo			Int = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@SaleTypeID			VarChar(20) = Null, -- �� ��� ����
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
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null#null',
	@DeductDiscount		Bit = 0,
	@PrintStatement		Bit = 0,
	@RetType			Int,
	@RepInfo			NVarChar(100) = Null
)
WITH ENCRYPTION
AS

BEGIN

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

DECLARE @StrSelect1						NVarChar(max);
DECLARE @StrSelect2						NVarChar(max);
DECLARE @StrWhere						NVarChar(max);	
DECLARE @StrWhere2						NVarChar(max);	
DECLARE @StrWhere3						NVarChar(max);	
DECLARE @StrWhere4						NVarChar(max);	
DECLARE @StrWhereSameDateRets			NVarChar(max);	
DECLARE @StrWhereAfteSale_Rets			NVarChar(max);	
DECLARE @StrWhereAfteSale_RetsNoLimit	NVarChar(max);
	
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
	
-- =======================================================
	-- Init -------------------------------------------------
	--IF (@RepOptions Is Null)		SET @RepOptions = '110001111111110000';
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1';
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null#null';

	IF (@DocDateFr	Is Null)		SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)		SET @DocDateTo = '@@@';
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

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;
	IF (@DocRowNo	Is Null)	SET @DocRowNo = 0;

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
	End	
	
	SET @LangID			 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	 = pub.funSplitString(@RepInfo, '@', 5);	

-- ======================================================= Where
	SET @StrSelect1 = ''	
	SET @StrSelect2 = ''	
	
	SET @StrWhere = 'SD.ProcessID = ' + LTRIM(RTrim(Str(@ProcessID)))
					--+ ' And 
					-- SD.FiscalYear >= ' + LTRIM(RTrim(Str(@FiscalYearFr))) + ' And SD.FiscalYear <= ' + LTRIM(RTrim(Str(@FiscalYearTo))) + 'And 
					-- SD.SerialNo >= ' + LTRIM(RTrim(Str(@SerialNoFr))) + ' And  SD.SerialNo M= ' + LTRIM(RTrim(Str(@SerialNoTo))) 
					 --+ ' And SD.DocRowNo = ' + LTRIM(RTrim(Str(@DocRowNo)))
	SET @StrWhere2 = 'SD.ProcessID = ' + LTRIM(RTrim(Str(@ProcessID))) 
	SET @StrWhere3 = 'SD.ProcessID = 100'
	SET @StrWhere4 = 'SD.ProcessID = 100'
	
	SET @StrWhereSameDateRets		  = ''					 
	SET @StrWhereAfteSale_Rets		  = ''					 
	SET @StrWhereAfteSale_RetsNoLimit = ''					 

	If (@ProcessNo Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (SD.ProcessNo in(' + LTrim(Str(@ProcessNo)) + '))'
		SET @StrWhere2 = @StrWhere2 + ' AND (SD.ProcessNo in(' + LTrim(Str(@ProcessNo)) + '))'
		SET @StrWhere3 = @StrWhere3 + ' AND (SD.ProcessNo in(' + LTrim(Str(@ProcessNo)) + ')) And SD.BaseProcessID <> 0 And SD.BaseProcessNo <> 0 And 
											 SD.BaseFiscalYear  <> 0 And SD.BaseSerialNo <> 0 And SD.BaseDocRowNo <> 0 '
		SET @StrWhere4 = @StrWhere4 + '  And (SD.ProcessNo in(' + LTrim(Str(@ProcessNo)) + ')) And ((SD.BaseProcessID  = 0 And SD.BaseProcessNo = 0 And SD.BaseFiscalYear = 0 And SD.BaseSerialNo = 0) OR 
													 (SD.BaseProcessID  = 0 And SD.BaseProcessNo = 0 AND SD.BaseDocRowNo = 0))'
	End

	If (@SaleTypeID Is Not Null)
	Begin
		Set @StrWhere = @StrWhere + ' AND ((SD.SaleTypeID = ''' + @SaleTypeID + ''') OR (SH.SaleTypeID = ''' + @SaleTypeID + '''))'
		Set @StrWhere2 = @StrWhere2 + ' AND ((SD.SaleTypeID = ''' + @SaleTypeID + ''') OR (SH.SaleTypeID = ''' + @SaleTypeID + '''))'
		Set @StrWhere3 = @StrWhere3 + ' AND ((SD.SaleTypeID = ''' + @SaleTypeID + ''') OR (SH.SaleTypeID = ''' + @SaleTypeID + '''))'
		Set @StrWhere4 = @StrWhere4 + ' AND ((SD.SaleTypeID = ''' + @SaleTypeID + ''') OR (SH.SaleTypeID = ''' + @SaleTypeID + '''))'
		--Set @StrWhere3 = @StrWhere3 + ' AND ((SD.SaleTypeID = ''' + @SaleTypeID + ''') OR (SH.SaleTypeID = ''' + @SaleTypeID + '''))'
		--Set @StrWhereSameDateRets = @StrWhereSameDateRets + ' AND (Ret1.SaleTypeID >= ''' + LTRIM(RTrim(@DocDateFr)) + ''')'
		--Set @StrWhereAfteSale_Rets = @StrWhereAfteSale_Rets + ' AND (Ret2.SaleTypeID >= ''' + LTRIM(RTrim(@DocDateFr)) + ''')'
		--Set @StrWhereAfteSale_RetsNoLimit = @StrWhereAfteSale_RetsNoLimit + ' AND (Ret3.SaleTypeID >= ''' + LTRIM(RTrim(@DocDateFr)) + ''')'
	End		

	If (@Dist0 <> 'null')
	Begin
		SET @StrWhere = @StrWhere + ' AND SH.DriverID = ''' + LTrim(@Dist0) + ''''
		SET @StrWhere2 = @StrWhere2 + ' AND SH.DriverID = ''' + LTrim(@Dist0) + ''''
		SET @StrWhere3 = @StrWhere3 + ' AND SH.DriverID = ''' + LTrim(@Dist0) + ''''
		SET @StrWhere4 = @StrWhere4 + ' AND SH.DriverID = ''' + LTrim(@Dist0) + ''''
	End		
	If (@Dist1 <> 'null')
	Begin
		SET @StrWhere = @StrWhere + ' AND SH.DistributerID1 = ''' + LTrim(@Dist1) + ''''
		SET @StrWhere2 = @StrWhere2 + ' AND SH.DistributerID1 = ''' + LTrim(@Dist1) + ''''
		SET @StrWhere3 = @StrWhere3 + ' AND SH.DistributerID1 = ''' + LTrim(@Dist1) + ''''
		SET @StrWhere4 = @StrWhere4 + ' AND SH.DistributerID1 = ''' + LTrim(@Dist1) + ''''
	End		
	If (@Dist2 <> 'null')
	Begin
		SET @StrWhere = @StrWhere + ' AND SH.DistributerID2 = ''' + LTrim(@Dist2) + ''''
		SET @StrWhere2 = @StrWhere2 + ' AND SH.DistributerID2 = ''' + LTrim(@Dist2) + ''''
		SET @StrWhere3 = @StrWhere3 + ' AND SH.DistributerID2 = ''' + LTrim(@Dist2) + ''''
		SET @StrWhere4 = @StrWhere4 + ' AND SH.DistributerID2 = ''' + LTrim(@Dist2) + ''''
	End		

	If (@Dist5 <> 'null')
	Begin
		SET @StrWhere = @StrWhere + ' AND SH.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND SH.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND SH.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND SH.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
		SET @StrWhere2 = @StrWhere2 + ' AND SH.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND SH.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND SH.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND SH.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
		SET @StrWhere3 = @StrWhere3 + ' AND SH.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND SH.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND SH.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND SH.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
		SET @StrWhere4 = @StrWhere4 + ' AND SH.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND SH.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND SH.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND SH.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	End		
	If (@Dist7 <> 'null')
	Begin
		SET @StrWhere = @StrWhere + ' AND SH.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND SH.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND SH.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND SH.BaseDistributionSerialNo <= ' + LTrim(@Dist8)
		SET @StrWhere2 = @StrWhere2 + ' AND SH.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND SH.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND SH.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND SH.BaseDistributionSerialNo <= ' + LTrim(@Dist8)
		SET @StrWhere3 = @StrWhere3 + ' AND SH.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND SH.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND SH.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND SH.BaseDistributionSerialNo <= ' + LTrim(@Dist8)
		SET @StrWhere4 = @StrWhere4 + ' AND SH.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND SH.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND SH.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND SH.BaseDistributionSerialNo <= ' + LTrim(@Dist8)
	End		

	If (@SerialNoFr Is Not Null)
	begin
		SET @StrWhere = @StrWhere + ' AND (SD.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (SD.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SD.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
		SET @StrWhere2 = @StrWhere2 + ' AND (SD.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (SD.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SD.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))'
		SET @StrWhere3 = @StrWhere3 + ' AND (SD.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (SD.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SD.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))'
		SET @StrWhere4 = @StrWhere4 + ' AND (SD.BaseFiscalYear < ' + LTrim(Str(@FiscalYearFr)) + ' OR SD.BaseFiscalYear >= ' + LTrim(Str(@FiscalYearFr)) + ')'
	end
	If (@SerialNoTo Is Not Null)
	begin
		SET @StrWhere = @StrWhere + ' AND (SD.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (SD.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		SET @StrWhere2 = @StrWhere2 + ' AND (SD.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (SD.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		SET @StrWhere3 = @StrWhere3 + ' AND (SD.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (SD.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		SET @StrWhere4 = @StrWhere4 + ' AND (SD.BaseFiscalYear <= ' + LTrim(Str(@FiscalYearTo)) + ')'
	end

	If (@DocRowNo Is Not Null) And (@DocRowNo <> 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (SD.DocRowNo = ' + LTrim(Str(@DocRowNo)) + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (SD.DocRowNo = ' + LTrim(Str(@DocRowNo)) + ')'
		SET @StrWhere3 = @StrWhere3 + ' AND (SD.DocRowNo = ' + LTrim(Str(@DocRowNo)) + ')'
		SET @StrWhere4 = @StrWhere4 + ' AND (SD.DocRowNo = ' + LTrim(Str(@DocRowNo)) + ')'
	end

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@') AND (@DocDateFr <> '')
	begin
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3', 'SH.DocDate4')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + inv.funGetDateFilter(@DocDateFr, '<', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3', 'SH.DocDate4')
		SET @StrWhere3 = @StrWhere3 + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3', 'SH.DocDate4')
		SET @StrWhere4 = @StrWhere4 + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3', 'SH.DocDate4')
	end
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@') AND (@DocDateTo <> '')
	begin
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3', 'SH.DocDate4')
		--SET @StrWhere2 = @StrWhere2 + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
		SET @StrWhere3 = @StrWhere3 + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3', 'SH.DocDate4')
		SET @StrWhere4 = @StrWhere4 + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3', 'SH.DocDate4')
		SET @StrWhereAfteSale_Rets = ' AND (Ret2.DocDate <= ''' + LTRIM(RTrim(@DocDateTo)) + ''')'
		SET @StrWhereAfteSale_RetsNoLimit = ' AND (Ret2.DocDate > ''' + LTRIM(RTrim(@DocDateTo)) + ''')'
	end

	If (@VchNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND H.VchNo >= ' + LTrim(Str(@VchNoFr))
	If (@VchNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND H.VchNo <= ' + LTrim(Str(@VchNoTo))

	If (@SelectedGoods > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'SD.GoodsID') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'SD.GoodsID') 
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'SD.GoodsID') 
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'SD.GoodsID') 
	end
	
	If (@SelectedStore > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'SD.StoreID') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'SD.StoreID') 
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'SD.StoreID') 
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'SD.StoreID') 
	end
	
	If (@SelectedStore2 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'SD.StoreID2')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'SD.StoreID2')
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'SD.StoreID2')
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'SD.StoreID2')
	end

	If (@SelectedAcnt1 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'SD.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'SD.AcntCode')
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'SD.AcntCode')
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'SD.AcntCode')
	end
	If (@SelectedAcnt2 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'SD.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'SD.AcntCode')
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'SD.AcntCode')
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'SD.AcntCode')
	end
	If (@SelectedAcnt3 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'SD.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'SD.AcntCode')
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'SD.AcntCode')
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'SD.AcntCode')
	end
	If (@SelectedAcnt4 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'SD.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'SD.AcntCode')
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'SD.AcntCode')
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'SD.AcntCode')
	end

	If (@SelectedOrders1 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders1, 'SD.OrderAcntCode') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders1, 'SD.OrderAcntCode') 
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders1, 'SD.OrderAcntCode') 
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders1, 'SD.OrderAcntCode') 
	end
	If (@SelectedOrders2 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders2, 'SD.OrderAcntCode') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders2, 'SD.OrderAcntCode') 
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders2, 'SD.OrderAcntCode') 
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders2, 'SD.OrderAcntCode') 
	end
	If (@SelectedOrders3 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders3, 'SD.OrderAcntCode') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders3, 'SD.OrderAcntCode') 
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders3, 'SD.OrderAcntCode') 
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders3, 'SD.OrderAcntCode') 
	end
	If (@SelectedOrders4 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders4, 'SD.OrderAcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders4, 'SD.OrderAcntCode')
		SET @StrWhere3 = @StrWhere3 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders4, 'SD.OrderAcntCode')
		SET @StrWhere4 = @StrWhere4 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders4, 'SD.OrderAcntCode')
	end

	If (@SelectedVisitor1 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere3 = @StrWhere3 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere4 = @StrWhere4 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'SH.VisitorAcntCode') + ')'
	end
	If (@SelectedVisitor2 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere3 = @StrWhere3 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere4 = @StrWhere4 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'SH.VisitorAcntCode') + ')'
	end
	If (@SelectedVisitor3 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere3 = @StrWhere3 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere4 = @StrWhere4 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'SH.VisitorAcntCode') + ')'
	end
	If (@SelectedVisitor4 > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere3 = @StrWhere3 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'SH.VisitorAcntCode') + ')'
		SET @StrWhere4 = @StrWhere4 + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'SH.VisitorAcntCode') + ')'
	end
	
-- ======================================================= Select
-- ******************** Typ-1
	IF @RetType = 1
	BEGIN
		SET @StrSelect1 =
	   '-- ======================================================= Select
		SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID,' + 
			   Case When @DeductDiscount = 0 Then 'Sum(A.SalePrice - A.SameDateRetPrice - A.AfterSale_RetPrice - A.AfterSale_RetPrice2) '
			   Else 'Sum(A.SalePrice - A.SameDateRetPrice - A.AfterSale_RetPrice - A.AfterSale_RetPrice2) - Sum(A.SaleDiscountDtl) ' End + '
		FROM(
			Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID, 
				   (IsNull(SD.GoodsQuantity,0)   * IsNull(SD.GoodsPrice,0)) SalePrice, IsNull(SD.DiscountDtl,0) SaleDiscountDtl, IsNull(SH.TotalLineDiscount,0) SaleDiscount,
				   (IsNull(Ret1.GoodsQuantity,0) * IsNull(Ret1.GoodsPrice,0)) SameDateRetPrice, IsNull(Ret1.DiscountDtl,0) SameDateRetDiscountDtl, IsNull(Ret1.TotalLineDiscount,0) SameDateRetDiscount, 
				   (IsNull(Ret2.GoodsQuantity,0) * IsNull(Ret2.GoodsPrice,0)) AfterSale_RetPrice, IsNull(Ret2.DiscountDtl,0) AfterSale_RetDiscountDtl, IsNull(Ret2.TotalLineDiscount,0) AfterSale_RetDiscount,
				   (IsNull(Ret3.GoodsQuantity,0) * IsNull(Ret3.GoodsPrice,0)) AfterSale_RetPrice2, IsNull(Ret3.DiscountDtl,0) AfterSale_RetDiscountDtl2, IsNull(Ret3.TotalLineDiscount,0) AfterSale_RetDiscount2,
				   (IsNull(SD.GoodsQuantity,0)   - IsNull(Ret1.GoodsQuantity,0) - IsNull(Ret2.GoodsQuantity,0)) NetSaleQty
				   	   
			From inv.tblStorageDocsDtl SD
			Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
												   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 
			-- SameDateRets
			Left Join
			(
			 Select RD1.*, RH1.TotalLineDiscount 
			 From inv.tblStorageDocsDtl RD1 
			 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
													 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
			 Where RD1.ProcessID = 100 And RD1.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + '
			) Ret1 ON	Ret1.BaseProcessID  = SD.ProcessID  And Ret1.BaseProcessNo = SD.ProcessNo And
						Ret1.BaseFiscalYear = SD.FiscalYear And Ret1.BaseSerialNo  = SD.SerialNo And 
						Ret1.BaseDocRowNo   = SD.DocRowNo   And Ret1.DocDate = SD.DocDate
			-- AfteSale_Rets
			Left Join
			(
			 Select RD1.*, RH1.TotalLineDiscount 
			 From inv.tblStorageDocsDtl RD1 
			 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
													 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
			 Where RD1.ProcessID = 100 And RD1.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + '
			) Ret2 ON	Ret2.BaseProcessID  = SD.ProcessID  And Ret2.BaseProcessNo = SD.ProcessNo And
						Ret2.BaseFiscalYear = SD.FiscalYear And Ret2.BaseSerialNo  = SD.SerialNo And 
						Ret2.BaseDocRowNo   = SD.DocRowNo   And Ret2.DocDate > SD.DocDate ' + @StrWhereAfteSale_Rets
		SET @StrSelect2 =
		   '-- AfteSale_Rets No Limit
			Left Join
			(
			 Select RD1.*, RH1.TotalLineDiscount 
			 From inv.tblStorageDocsDtl RD1 
			 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
													 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
			 Where RD1.ProcessID = 100 And RD1.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + '
			) Ret3 ON	Ret3.BaseProcessID  = SD.ProcessID  And Ret3.BaseProcessNo = SD.ProcessNo And
						Ret3.BaseFiscalYear = SD.FiscalYear And Ret3.BaseSerialNo  = SD.SerialNo And 
						Ret3.BaseDocRowNo   = SD.DocRowNo   ' + @StrWhereAfteSale_RetsNoLimit + '				
			Where ' + @StrWhere + '
		) A
		Group By ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID	
		-- ======================================================= '
	END
	
-- ******************** Typ-2
	IF @RetType = 2
	BEGIN
		SET @StrSelect1 =  
'		-- SameDateRet_Dtl
		SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID,
			   ISNULL(SUM(' + Case When @DeductDiscount = 0 Then 'A.SameDateRetPrice' Else 
			   'A.SameDateRetPrice - A.SameDateRetDiscountDtl' End + '),0) 
		FROM(
			Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID,
				  (IsNull(Ret1.GoodsQuantity,0) * IsNull(Ret1.GoodsPrice,0)) SameDateRetPrice,
				   IsNull(Ret1.DiscountDtl,0) SameDateRetDiscountDtl, 
				   IsNull(Ret1.TotalLineDiscount,0) SameDateRetDiscount
				   	   
			From inv.tblStorageDocsDtl SD
			Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
												   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 
			-- SameDateRets
			Left Join
			(
			 Select RD1.*, RH1.TotalLineDiscount 
			 From inv.tblStorageDocsDtl RD1 
			 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
													 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
			 Where RD1.ProcessID = 100 And RD1.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + '
			) Ret1 ON	Ret1.BaseProcessID  = SD.ProcessID  And Ret1.BaseProcessNo = SD.ProcessNo And
						Ret1.BaseFiscalYear = SD.FiscalYear And Ret1.BaseSerialNo  = SD.SerialNo And 
						Ret1.BaseDocRowNo   = SD.DocRowNo   And Ret1.DocDate = SD.DocDate

			Where ' + @StrWhere + '
		) A
		Group By ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID	
		-- ======================================================= '
	END
		
-- ******************** Typ-3
	IF @RetType = 3
	BEGIN
		SET @StrSelect1 = 
'		-- AfterSale_Ret_Dtl
		SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID, 
			   ISNULL(SUM(' + Case When @DeductDiscount = 0 Then 'A.AfterSale_RetPrice' 
							  Else 'A.AfterSale_RetPrice - A.AfterSale_RetDiscountDtl ' End + '),0) 
		FROM(
			Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID, 
				   (IsNull(SD.GoodsQuantity,0) * IsNull(SD.GoodsPrice,0)) SalePrice, IsNull(SD.DiscountDtl,0) SaleDiscountDtl, IsNull(SH.TotalLineDiscount,0) SaleDiscount,
				   (IsNull(Ret2.GoodsQuantity,0) * IsNull(Ret2.GoodsPrice,0)) AfterSale_RetPrice, IsNull(Ret2.DiscountDtl,0) AfterSale_RetDiscountDtl, IsNull(Ret2.TotalLineDiscount,0) AfterSale_RetDiscount
				   	   
			From inv.tblStorageDocsDtl SD
			Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
												   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 
			-- AfteSale_Rets
			Left Join
			(
			 Select RD1.*, RH1.TotalLineDiscount 
			 From inv.tblStorageDocsDtl RD1 
			 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
													 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
			 Where RD1.ProcessID = 100 And RD1.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + '
			) Ret2 ON	Ret2.BaseProcessID  = SD.ProcessID  And Ret2.BaseProcessNo = SD.ProcessNo And
						Ret2.BaseFiscalYear = SD.FiscalYear And Ret2.BaseSerialNo  = SD.SerialNo And 
						Ret2.BaseDocRowNo   = SD.DocRowNo   And Ret2.DocDate > SD.DocDate ' + @StrWhereAfteSale_Rets + '
						
			Where ' + @StrWhere + '
		) A
		Group By ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID	
		-- ======================================================= '
	END
		
-- ******************** Typ-4
	IF @RetType = 4
	BEGIN
		SET @StrSelect1 = 
'		-- AfterSale_Ret_NoLimit_Dtl
		SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID, 
			   ISNULL(SUM(' + Case When @DeductDiscount = 0 Then 'A.AfterSale_RetPrice' 
							  Else 'A.AfterSale_RetPrice - A.AfterSale_RetDiscountDtl ' End + '),0) 
		FROM(
			Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID, 
				   (IsNull(SD.GoodsQuantity,0) * IsNull(SD.GoodsPrice,0)) SalePrice, IsNull(SD.DiscountDtl,0) SaleDiscountDtl, IsNull(SH.TotalLineDiscount,0) SaleDiscount,
				   (IsNull(Ret2.GoodsQuantity,0) * IsNull(Ret2.GoodsPrice,0)) AfterSale_RetPrice, IsNull(Ret2.DiscountDtl,0) AfterSale_RetDiscountDtl, IsNull(Ret2.TotalLineDiscount,0) AfterSale_RetDiscount
				   	   
			From inv.tblStorageDocsDtl SD
			Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
												   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 
			Left Join
			(
			 Select RD1.*, RH1.TotalLineDiscount 
			 From inv.tblStorageDocsDtl RD1 
			 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
													 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
			 Where RD1.ProcessID = 100 And RD1.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + '  
			) Ret2 ON	Ret2.BaseProcessID  = SD.ProcessID  And Ret2.BaseProcessNo = SD.ProcessNo And
						Ret2.BaseFiscalYear = SD.FiscalYear And Ret2.BaseSerialNo  = SD.SerialNo And 
						Ret2.BaseDocRowNo   = SD.DocRowNo   ' + @StrWhereAfteSale_RetsNoLimit + '
						
			Where ' + @StrWhere + '
		) A
		Group By ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID
		-- ======================================================= '
	END
		
-- ******************** Typ-5
	IF @RetType = 5
	BEGIN
		SET @StrSelect1 = '
		SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID, 
			   ISNULL(SUM(' + Case When @DeductDiscount = 0 Then 'A.SameDateRetPrice + A.AfterSale_RetPrice' 
							  Else '(A.AfterSale_RetPrice - A.AfterSale_RetDiscountDtl) + (A.SameDateRetPrice - A.SameDateRetDiscountDtl) +
									(A.AfterSale_RetPrice2 - A.AfterSale_RetDiscountDtl2) '
							  End + '),0)
		FROM(
			Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID, 
				   (IsNull(SD.GoodsQuantity,0) * IsNull(SD.GoodsPrice,0)) SalePrice, IsNull(SD.DiscountDtl,0) SaleDiscountDtl, IsNull(SH.TotalLineDiscount,0) SaleDiscount,
				   (IsNull(Ret1.GoodsQuantity,0) * IsNull(Ret1.GoodsPrice,0)) SameDateRetPrice, IsNull(Ret1.DiscountDtl,0) SameDateRetDiscountDtl, IsNull(Ret1.TotalLineDiscount,0) SameDateRetDiscount, 
				   (IsNull(Ret2.GoodsQuantity,0) * IsNull(Ret2.GoodsPrice,0)) AfterSale_RetPrice, IsNull(Ret2.DiscountDtl,0) AfterSale_RetDiscountDtl, IsNull(Ret2.TotalLineDiscount,0) AfterSale_RetDiscount,
				   (IsNull(Ret3.GoodsQuantity,0) * IsNull(Ret3.GoodsPrice,0)) AfterSale_RetPrice2, IsNull(Ret3.DiscountDtl,0) AfterSale_RetDiscountDtl2, IsNull(Ret3.TotalLineDiscount,0) AfterSale_RetDiscount2,
				   (IsNull(SD.GoodsQuantity,0)  - IsNull(Ret1.GoodsQuantity,0) - IsNull(Ret2.GoodsQuantity,0)) NetSaleQty
				   	   
			From inv.tblStorageDocsDtl SD
			Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
												   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 
			-- SameDateRets
			Left Join
			(
			 Select RD1.*, RH1.TotalLineDiscount 
			 From inv.tblStorageDocsDtl RD1 
			 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
													 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
			 Where RD1.ProcessID = 100 And RD1.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + '  
			) Ret1 ON	Ret1.BaseProcessID  = SD.ProcessID  And Ret1.BaseProcessNo = SD.ProcessNo And
						Ret1.BaseFiscalYear = SD.FiscalYear And Ret1.BaseSerialNo  = SD.SerialNo And 
						Ret1.BaseDocRowNo   = SD.DocRowNo And Ret1.DocDate = SD.DocDate
			-- AfteSale_Rets
			Left Join
			(
			 Select RD1.*, RH1.TotalLineDiscount 
			 From inv.tblStorageDocsDtl RD1 
			 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
													 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
			 Where RD1.ProcessID = 100 And RD1.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + '  
			) Ret2 ON	Ret2.BaseProcessID  = SD.ProcessID  And Ret2.BaseProcessNo = SD.ProcessNo And
						Ret2.BaseFiscalYear = SD.FiscalYear And Ret2.BaseSerialNo  = SD.SerialNo And 
						Ret2.BaseDocRowNo   = SD.DocRowNo   And Ret2.DocDate > SD.DocDate ' + @StrWhereAfteSale_Rets + '
			-- AfteSale_Rets No Limit
			Left Join
			(
			 Select RD1.*, RH1.TotalLineDiscount 
			 From inv.tblStorageDocsDtl RD1 
			 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
													 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
			 Where RD1.ProcessID = 100 And RD1.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + '  
			) Ret3 ON	Ret3.BaseProcessID  = SD.ProcessID  And Ret3.BaseProcessNo = SD.ProcessNo And
						Ret3.BaseFiscalYear = SD.FiscalYear And Ret3.BaseSerialNo  = SD.SerialNo And 
						Ret3.BaseDocRowNo   = SD.DocRowNo   ' + @StrWhereAfteSale_RetsNoLimit + '
						
			-- NoBaseDoc_Rets
			--Left Join inv.tblStorageDocsDtl Ret3 ON Ret3.GoodsID = SD.GoodsID
			Where ' + @StrWhere + '
		) A
		Group By ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID
		-- ======================================================= '
	END
	
-- ******************** Typ-6
	IF @RetType = 6
	BEGIN
		SET @StrSelect1 = 
'		-- WithoutBaseDoc_Rets_Dtl
		SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID, 
			   ISNULL(SUM(' + Case When @DeductDiscount = 0 Then 'A.RetPrice' 
							  Else 'A.RetPrice - A.RetDiscountDtl' End + '),0)
		FROM
		(
			Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID,
				   (IsNull(SD.GoodsQuantity,0) * IsNull(SD.GoodsPrice,0)) RetPrice, IsNull(SD.DiscountDtl,0) RetDiscountDtl, 
					IsNull(SH.TotalLineDiscount,0) RetDiscount
				   
			From inv.tblStorageDocsDtl SD
			Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
												   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 	
												   
			Where ' + @StrWhere4 + '
		) A
		Group By ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID
		-- ======================================================= '
	END
	
-- ******************** Typ-7
	IF @RetType = 7
	BEGIN
		SET @StrSelect1 = 
'		-- WithBeforeDateSale_Dtl
		SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID,
				ISNULL(SUM(' + Case When @DeductDiscount = 0 Then 'A.RetPrice' 
								Else 'A.RetPrice - A.RetDiscountDtl' End + '),0)
		FROM
		(
			Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID, SD.BaseDocDate,
					(IsNull(SD.GoodsQuantity,0) * IsNull(SD.GoodsPrice,0)) RetPrice, IsNull(SD.DiscountDtl,0) RetDiscountDtl, 
					IsNull(SH.TotalLineDiscount,0) RetDiscount
					   
			From inv.tblStorageDocsDtl SD
			Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
													SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo
				
			Inner Join 
			(Select SD.* From inv.tblStorageDocsDtl SD
				Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
													SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo
				Where ' + @StrWhere2 + '
			) Sale ON Sale.ProcessID = SD.BaseProcessID And Sale.ProcessNo = SD.BaseProcessNo And
						Sale.FiscalYear = SD.BaseFiscalYear And Sale.SerialNo = SD.BaseSerialNo
													   
			Where ' + @StrWhere3 + '			 
		) A
		Group By ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, GoodsID
		-- ======================================================='
	END
	
	--Select @Result1 NetSales, @Result2 SameDate_Rets, @Result3 AfterSale_Rets, @Result4 AfterSale_RetsNoDateLimit, 
	--	     @Result6 WithoutBaseDoc_Rets, @Result7 WithBeforeDateSale, 
	--	     @Result2 + @Result3 + @Result4 + @Result6 + @Result7 SaleRets_Sum'

-- =======================================================
	IF @PrintStatement = 1
	Begin
		Print @StrSelect1
		Print @StrSelect2
	End
	
	SET @StrSelect1 = @StrSelect1 + @StrSelect2
	Exec sp_executesql @StrSelect1;
	
-- =======================================================

END
GO
