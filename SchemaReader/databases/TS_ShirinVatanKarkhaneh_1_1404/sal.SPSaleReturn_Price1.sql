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
Create PROCEDURE [sal].[SPSaleReturn_Price1]
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
	@DeductTax			Bit = 0,
	@PrintStatement		Bit = 0,
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

DECLARE @StrSelect						NVarChar(max);
DECLARE @StrSelect1						NVarChar(max);
DECLARE @StrSelect2						NVarChar(max);
DECLARE @StrSelect3						NVarChar(max);
DECLARE @StrSelect4						NVarChar(max);
DECLARE @StrSelect5						NVarChar(max);
DECLARE @StrSelect7						NVarChar(max);
DECLARE @StrSelect6						NVarChar(max);
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
	SET @StrWhere = 'SD.ProcessID = 100'

					--+ ' And 
					-- SD.FiscalYear >= ' + LTRIM(RTrim(Str(@FiscalYearFr))) + ' And SD.FiscalYear <= ' + LTRIM(RTrim(Str(@FiscalYearTo))) + 'And 
					-- SD.SerialNo >= ' + LTRIM(RTrim(Str(@SerialNoFr))) + ' And  SD.SerialNo M= ' + LTRIM(RTrim(Str(@SerialNoTo))) 
					--+ ' And SD.DocRowNo = ' + LTRIM(RTrim(Str(@DocRowNo)))
	SET @StrWhere2 = 'SD.ProcessID = 100'
	SET @StrWhere3 = 'SD.ProcessID = 90'
	SET @StrWhere4 = 'SD.ProcessID = 100'
	
	SET @StrWhereSameDateRets		  = ''					 
	SET @StrWhereAfteSale_Rets		  = ''					 
	SET @StrWhereAfteSale_RetsNoLimit = ''					 

	If (@ProcessNo Is Not Null) AND @ProcessNo >0
	Begin
		SET @StrWhere  = @StrWhere  + ' And (SD.ProcessNo In(' + LTrim(Str(@ProcessNo)) + '))'
		SET @StrWhere2 = @StrWhere2 + ' And (SD.BaseProcessNo In(' + LTrim(Str(@ProcessNo)) + '))'
		SET @StrWhere3 = @StrWhere3 + ' And (SD.ProcessNo In(' + LTrim(Str(@ProcessNo)) + ')) And SD.BaseProcessID <> 0 And SD.BaseProcessNo <> 0 And 
											 SD.BaseFiscalYear  <> 0 And SD.BaseSerialNo <> 0 And SD.BaseDocRowNo <> 0 '
		SET @StrWhere4 = @StrWhere4 + '  And (SD.ProcessNo In(' + LTrim(Str(@ProcessNo)) + ')) And ((SD.BaseProcessID  = 0 And SD.BaseProcessNo = 0 And SD.BaseFiscalYear = 0 And SD.BaseSerialNo = 0) OR   (SD.BaseFiscalYear  <SD.FiscalYear))'
	End
	ELSE
	BEGIN
		SET @StrWhere3 = @StrWhere3 + ' And SD.BaseProcessID <> 0 And SD.BaseProcessNo <> 0 And 
											 SD.BaseFiscalYear  <> 0 And SD.BaseSerialNo <> 0 And SD.BaseDocRowNo <> 0 '
		SET @StrWhere4 = @StrWhere4 + ' And ((SD.BaseProcessID  = 0 And SD.BaseProcessNo = 0 And SD.BaseFiscalYear = 0 And SD.BaseSerialNo = 0) OR   (SD.BaseFiscalYear  <SD.FiscalYear))'											 
	END


	If (@SaleTypeID Is Not Null)
	Begin   
		Set @StrWhere = @StrWhere + ' AND ((SD.SaleTypeID = ''' + @SaleTypeID + ''') OR (SD.SaleTypeID = ''' + @SaleTypeID + '''))'
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
		SET @StrWhere = @StrWhere + ' AND (SD.BaseFiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (SD.BaseFiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SD.BaseSerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
		SET @StrWhere2 = @StrWhere2 + ' AND (SD.BaseFiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (SD.BaseFiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SD.BaseSerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))'
		SET @StrWhere3 = @StrWhere3 + ' AND (SD.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (SD.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SD.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))'
		SET @StrWhere4 = @StrWhere4 + ' AND (SD.BaseFiscalYear < ' + LTrim(Str(@FiscalYearFr)) + ' OR SD.BaseFiscalYear >= ' + LTrim(Str(@FiscalYearFr)) + ')'
	end
	If (@SerialNoTo Is Not Null)
	begin
		SET @StrWhere = @StrWhere + ' AND (SD.BaseFiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (SD.BaseFiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SD.BaseSerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		SET @StrWhere2 = @StrWhere2 + ' AND (SD.BaseFiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (SD.BaseFiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SD.BaseSerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		SET @StrWhere3 = @StrWhere3 + ' AND (SD.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (SD.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		SET @StrWhere4 = @StrWhere4 + ' AND (SD.BaseFiscalYear <= ' + LTrim(Str(@FiscalYearTo)) + ')'
	end

	If (@DocRowNo Is Not Null) And (@DocRowNo <> 0)
	begin
		SET @StrWhere = @StrWhere + ' AND (SD.BaseDocRowNo = ' + LTrim(Str(@DocRowNo)) + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (SD.BaseDocRowNo = ' + LTrim(Str(@DocRowNo)) + ')'
		SET @StrWhere3 = @StrWhere3 + ' AND (SD.DocRowNo = ' + LTrim(Str(@DocRowNo)) + ')'
		SET @StrWhere4 = @StrWhere4 + ' AND (SD.DocRowNo = ' + LTrim(Str(@DocRowNo)) + ')'
	end

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@') AND (@DocDateFr <> '')
	begin
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'SH.DocDate', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + inv.funGetDateFilter(@DocDateFr, '<', 'SH.DocDate', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3')
		SET @StrWhere3 = @StrWhere3 + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'SH.DocDate', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3')
		SET @StrWhere4 = @StrWhere4 + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'SH.DocDate', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3')
	end
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@') AND (@DocDateTo <> '')
	begin
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'SH.DocDate', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3')
		--SET @StrWhere2 = @StrWhere2 + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate', 'H.DocDate2', 'H.DocDate3')
		SET @StrWhere3 = @StrWhere3 + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'SH.DocDate', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3')
		SET @StrWhere4 = @StrWhere4 + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'SH.DocDate', 'SH.DocDate', 'SH.DocDate2', 'SH.DocDate3')
		--SET @StrWhereAfteSale_Rets = ' AND (SD.DocDate <= ''' + LTRIM(RTrim(@DocDateTo)) + ''')'
		--SET @StrWhereAfteSale_RetsNoLimit = ' AND (SD.DocDate > ''' + LTRIM(RTrim(@DocDateTo)) + ''')'
	end

	If (@VchNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND SH.VchNo >= ' + LTrim(Str(@VchNoFr))
	If (@VchNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND SH.VchNo <= ' + LTrim(Str(@VchNoTo))
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
	SET @StrSelect =
   '-- ======================================================= Select
	DECLARE @Result1 AS DECIMAL(28,9)
	DECLARE @Result2 AS DECIMAL(28,9)
	DECLARE @Result3 AS DECIMAL(28,9)
	DECLARE @Result4 AS DECIMAL(28,9)
	DECLARE @Result5 AS DECIMAL(28,9)
	DECLARE @Result6 AS Float
	DECLARE @Result7 AS Float
	SET @Result1 = 0
	SET @Result2 = 0
	SET @Result3 = 0
	SET @Result4 = 0
	SET @Result5 = 0
	SET @Result6 = 0
	SET @Result7 = 0
	'

-- ********************
	SET @StrSelect1 = ' 
    -- SameDateRet
	SELECT @Result1 = ISNULL(SUM(' +
			   CASE WHEN @DeductTax = 0 And @DeductDiscount = 0 THEN 'A.SameDateRetPrice'
			        WHEN @DeductTax = 0 And @DeductDiscount = 1 THEN 'A.SameDateRetPrice - A.SameDateRetDiscountDtl'
			        WHEN @DeductTax = 1 And @DeductDiscount = 0 THEN 'A.SameDateRetPrice + A.SameDateRetTaxOverWorthCostDtl'
					ELSE 'A.SameDateRetPrice - A.SameDateRetDiscountDtl + A.SameDateRetTaxOverWorthCostDtl' END + '),0) 
	FROM(SELECT Sale.ProcessID, 
				Sale.ProcessNo, 
				Sale.FiscalYear, 
				Sale.SerialNo,
				(ISNULL(SD.GoodsQuantity,0) * ISNULL(SD.GoodsPrice,0)) SameDateRetPrice,
				ISNULL(SD.DiscountDtl,0) SameDateRetDiscountDtl, 
				(ISNULL(SD.TaxOverWorthCostDtl,0) + ISNULL(SD.TollOverWorthCostDtl,0)) SameDateRetTaxOverWorthCostDtl, 
				ISNULL(SH.TotalLineDiscount,0) SameDateRetDiscount 
		 FROM inv.tblStorageDocsDtl SD
		 INNER JOIN inv.tblStorageDocsHdr SH ON SH.ProcessID = SD.ProcessID 
											AND SH.ProcessNo = SD.ProcessNo 
											AND SH.FiscalYear = SD.FiscalYear 
											AND SH.SerialNo = SD.SerialNo 
		 INNER JOIN (SELECT SD.ProcessID, 
							SD.ProcessNo, 
							SD.FiscalYear, 
							SD.SerialNo, 
							MAX(SD.DocDate) DocDate
					 FROM inv.tblStorageDocsDtl SD
					 WHERE SD.ProcessID = ' + LTRIM(RTrim(Str(@ProcessID))) + ' 
					   AND (' + LTRIM(RTrim(Str(@ProcessNo))) + ' = 0 OR SD.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + ')
					 GROUP BY SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo) Sale ON SD.BaseProcessID = Sale.ProcessID 
																						  AND SD.BaseProcessNo = Sale.ProcessNo 
																						  AND SD.BaseFiscalYear = Sale.FiscalYear 
																						  AND SD.BaseSerialNo = Sale.SerialNo 
																						  AND SD.DocDate = Sale.DocDate
		 WHERE ' + @StrWhere + ' ) A
	-- ======================================================= '
-- ********************
	SET @StrSelect2 = '
    -- AfterSale_Ret
	SELECT @Result2 = ISNULL(SUM(' +
			   CASE WHEN @DeductTax = 0 And @DeductDiscount = 0 THEN 'A.AfterSale_RetPrice'
			        WHEN @DeductTax = 0 And @DeductDiscount = 1 THEN 'A.AfterSale_RetPrice - A.AfterSale_RetDiscountDtl'
			        WHEN @DeductTax = 1 And @DeductDiscount = 0 THEN 'A.AfterSale_RetPrice - A.AfterSale_RetTaxOverWorthCostDtl'
					ELSE 'A.AfterSale_RetPrice - A.AfterSale_RetDiscountDtl + A.AfterSale_RetTaxOverWorthCostDtl' END + '),0) 
	FROM(SELECT Sale.ProcessID, 
				Sale.ProcessNo, 
				Sale.FiscalYear, 
				Sale.SerialNo,
			    (ISNULL(SD.GoodsQuantity,0) * ISNULL(SD.GoodsPrice,0)) AfterSale_RetPrice, 
			    ISNULL(SD.DiscountDtl,0) AfterSale_RetDiscountDtl, 
			    (ISNULL(SD.TaxOverWorthCostDtl,0) + ISNULL(SD.TollOverWorthCostDtl,0)) AfterSale_RetTaxOverWorthCostDtl, 
				ISNULL(SH.TotalLineDiscount,0) AfterSale_RetDiscount
		 FROM inv.tblStorageDocsDtl SD
		 INNER JOIN inv.tblStorageDocsHdr SH ON SH.ProcessID = SD.ProcessID 
											AND SH.ProcessNo = SD.ProcessNo 
											AND SH.FiscalYear = SD.FiscalYear 
											AND SH.SerialNo = SD.SerialNo 
		 INNER JOIN (SELECT SD.ProcessID, 
							SD.ProcessNo, 
							SD.FiscalYear, 
							SD.SerialNo, 
							MAX(SD.DocDate) DocDate 
					 FROM inv.tblStorageDocsDtl SD
					 WHERE SD.ProcessID = ' + LTRIM(RTrim(Str(@ProcessID))) + ' 
					   AND (' + LTRIM(RTrim(Str(@ProcessNo))) + ' = 0 OR SD.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + ')
					 GROUP BY SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo) Sale ON SD.BaseProcessID = Sale.ProcessID 
																						  AND SD.BaseProcessNo = Sale.ProcessNo 
																						  AND SD.BaseFiscalYear = Sale.FiscalYear 
																						  AND SD.BaseSerialNo = Sale.SerialNo 
																						  AND Sale.DocDate < SD.DocDate
	WHERE ' + @StrWhere + ' ' + @StrWhereAfteSale_Rets + ' ) A
	-- ======================================================= '
-- ********************
	SET @StrSelect3 = '
    -- AfterSale_RetsNoDateLimit
	SELECT @Result3 = ISNULL(SUM(' +
			   CASE WHEN @DeductTax = 0 And @DeductDiscount = 0 THEN 'A.AfterSale_RetPrice'
			        WHEN @DeductTax = 0 And @DeductDiscount = 1 THEN 'A.AfterSale_RetPrice - A.AfterSale_RetDiscountDtl'
			        WHEN @DeductTax = 1 And @DeductDiscount = 0 THEN 'A.AfterSale_RetPrice - A.AfterSale_RetTaxOverWorthCostDtl'
					ELSE 'A.AfterSale_RetPrice - A.AfterSale_RetDiscountDtl + A.AfterSale_RetTaxOverWorthCostDtl' END + '),0) 
	FROM(SELECT Sale.ProcessID, 
				Sale.ProcessNo, 
				Sale.FiscalYear, 
				Sale.SerialNo,
				(ISNULL(SD.GoodsQuantity,0) * ISNULL(SD.GoodsPrice,0)) AfterSale_RetPrice,
				ISNULL(SD.DiscountDtl,0) AfterSale_RetDiscountDtl, 
				(ISNULL(SD.TaxOverWorthCostDtl,0) + ISNULL(SD.TollOverWorthCostDtl,0)) AfterSale_RetTaxOverWorthCostDtl, 
				ISNULL(SH.TotalLineDiscount,0) AfterSale_RetDiscount 
		 FROM inv.tblStorageDocsDtl SD
		 INNER JOIN inv.tblStorageDocsHdr SH ON SH.ProcessID = SD.ProcessID 
											   AND SH.ProcessNo = SD.ProcessNo 
											   AND SH.FiscalYear = SD.FiscalYear 
											   AND SH.SerialNo = SD.SerialNo 
		 INNER JOIN (SELECT SD.ProcessID, 
							SD.ProcessNo, 
							SD.FiscalYear, 
							SD.SerialNo, 
							MAX(SD.DocDate) DocDate
					 FROM inv.tblStorageDocsDtl SD
					 WHERE SD.ProcessID = ' + LTRIM(RTrim(Str(@ProcessID))) + ' 
					   AND (' + LTRIM(RTrim(Str(@ProcessNo))) + ' = 0 OR SD.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo))) + ')
					 GROUP BY SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo) Sale ON SD.BaseProcessID = Sale.ProcessID 
																						  AND SD.BaseProcessNo = Sale.ProcessNo 
																						  AND SD.BaseFiscalYear = Sale.FiscalYear 
																						  AND SD.BaseSerialNo = Sale.SerialNo
	WHERE ' + @StrWhere + ' ' + @StrWhereAfteSale_RetsNoLimit + ' ) A
	-- ======================================================= '
-- ********************
	SET @StrSelect4 = '
    -- WithoutBaseDoc_Rets
	SELECT @Result4 = ISNULL(SUM(' +
			   CASE WHEN @DeductTax = 0 And @DeductDiscount = 0 THEN 'A.RetPrice'
			        WHEN @DeductTax = 0 And @DeductDiscount = 1 THEN 'A.RetPrice - A.RetDiscountDtl'
			        WHEN @DeductTax = 1 And @DeductDiscount = 0 THEN 'A.RetPrice - A.RetTaxOverWorthCostDtl'
					ELSE 'A.RetPrice - A.RetDiscountDtl + A.RetTaxOverWorthCostDtl' END + '),0)
	FROM (SELECT SD.ProcessID, 
				 SD.ProcessNo, 
				 SD.FiscalYear, 
				 SD.SerialNo, 
				 SD.DocRowNo, 
				 SD.GoodsID,
				 (ISNULL(SD.GoodsQuantity,0) * ISNULL(SD.GoodsPrice,0)) RetPrice, 
				 ISNULL(SD.DiscountDtl,0) RetDiscountDtl,
				 (ISNULL(SD.TaxOverWorthCostDtl,0) + ISNULL(SD.TollOverWorthCostDtl,0)) RetTaxOverWorthCostDtl,
				 ISNULL(SH.TotalLineDiscount,0) RetDiscount
		  FROM inv.tblStorageDocsDtl SD
		  INNER JOIN inv.tblStorageDocsHdr SH ON SH.ProcessID = SD.ProcessID 
											 AND SH.ProcessNo = SD.ProcessNo 
											 AND SH.FiscalYear = SD.FiscalYear 
											 AND SH.SerialNo = SD.SerialNo 
	WHERE ' + @StrWhere4 + ' ) A
	-- ======================================================= '
-- ********************
	SET @StrSelect5 = '
    -- WithBeforeDateSale
	SELECT @Result5 = ISNULL(SUM(' +
			   CASE WHEN @DeductTax = 0 And @DeductDiscount = 0 THEN 'A.RetPrice'
			        WHEN @DeductTax = 0 And @DeductDiscount = 1 THEN 'A.RetPrice - A.RetDiscountDtl'
			        WHEN @DeductTax = 1 And @DeductDiscount = 0 THEN 'A.RetPrice - A.RetTaxOverWorthCostDtl'
					ELSE 'A.RetPrice - A.RetDiscountDtl + A.RetTaxOverWorthCostDtl' END + '),0)
	FROM (SELECT SD.ProcessID, 
				 SD.ProcessNo, 
				 SD.FiscalYear, 
				 SD.SerialNo,
				 (ISNULL(SD.GoodsQuantity,0) * ISNULL(SD.GoodsPrice,0)) RetPrice, 
				 ISNULL(SD.DiscountDtl,0) RetDiscountDtl,
				 (ISNULL(SD.TaxOverWorthCostDtl,0) + ISNULL(SD.TollOverWorthCostDtl,0)) RetTaxOverWorthCostDtl,
				 ISNULL(SH.TotalLineDiscount,0) RetDiscount 
		  FROM inv.tblStorageDocsDtl SD
		  INNER JOIN inv.tblStorageDocsHdr SH ON SH.ProcessID = SD.ProcessID 
											 AND SH.ProcessNo = SD.ProcessNo 
											 AND SH.FiscalYear = SD.FiscalYear 
											 AND SH.SerialNo = SD.SerialNo
		  INNER JOIN (SELECT SD.* 
					  FROM inv.tblStorageDocsDtl SD
					  INNER JOIN inv.tblStorageDocsHdr SH ON SH.ProcessID = SD.ProcessID 
														 AND SH.ProcessNo = SD.ProcessNo 
														 AND SH.FiscalYear = SD.FiscalYear 
														 AND SH.SerialNo = SD.SerialNo
					  WHERE ' + @StrWhere2 + ') Sale ON Sale.ProcessID = SD.BaseProcessID 
													AND Sale.ProcessNo = SD.BaseProcessNo 
													AND Sale.FiscalYear = SD.BaseFiscalYear 
													AND Sale.SerialNo = SD.BaseSerialNo
	WHERE ' + @StrWhere3 + ' ) A'
	-- =======================================================
	SET @StrSelect6 = '
    -- WithoutBaseDoc_Rets
	SELECT @Result6 = ISNULL(SUM(GoodsQuantity),0)
	FROM (SELECT SD.ProcessID, 
				 SD.ProcessNo, 
				 SD.FiscalYear, 
				 SD.SerialNo, 
				 SD.DocRowNo, 
				 SD.GoodsID,
				 ISNULL(SD.GoodsQuantity,0) GoodsQuantity 
		  FROM inv.tblStorageDocsDtl SD
		  INNER JOIN inv.tblStorageDocsHdr SH ON SH.ProcessID = SD.ProcessID 
											 AND SH.ProcessNo = SD.ProcessNo 
											 AND SH.FiscalYear = SD.FiscalYear 
											 AND SH.SerialNo = SD.SerialNo 
	WHERE ' + @StrWhere4 + ' ) A
	-- ======================================================= '
-- ********************
	SET @StrSelect7 = '
    -- WithBeforeDateSale
	SELECT @Result7= ISNULL(SUM(GoodsQuantity),0)
	FROM (SELECT Distinct SD.ProcessID, 
						  SD.ProcessNo, 
						  SD.FiscalYear, 
						  SD.SerialNo,
						  ISNULL(SD.GoodsQuantity,0) GoodsQuantity 
		  FROM inv.tblStorageDocsDtl SD
		  INNER JOIN inv.tblStorageDocsHdr SH ON SH.ProcessID = SD.ProcessID 
											 AND SH.ProcessNo = SD.ProcessNo 
											 AND SH.FiscalYear = SD.FiscalYear 
											 AND SH.SerialNo  = SD.SerialNo
		  INNER JOIN (SELECT Distinct SD.* 
					  FROM inv.tblStorageDocsDtl SD
					  INNER JOIN inv.tblStorageDocsHdr SH ON SH.ProcessID = SD.ProcessID 
														 AND SH.ProcessNo = SD.ProcessNo 
														 AND SH.FiscalYear = SD.FiscalYear 
														 AND SH.SerialNo = SD.SerialNo
					  WHERE ' + @StrWhere2 + ') Sale ON Sale.BaseProcessID = SD.ProcessID 
													AND Sale.BaseProcessNo = SD.ProcessNo 
													AND Sale.BaseFiscalYear = SD.FiscalYear 
													AND Sale.BaseSerialNo = SD.SerialNo 
	WHERE ' + @StrWhere3 + ' ) A
	-- =======================================================

	SELECT @Result1 SameDate_Rets,
		   @Result2 AfterSale_Rets, 
		   @Result3 AfterSale_RetsNoDateLimit, 
		   @Result4 WithoutBaseDoc_Rets, 
		   @Result5 WithBeforeDateSale, 
		   @Result6 QtyWithoutBase, 
		   @Result7 QtyWithBase,
		   @Result1 + @Result2 + @Result3 + @Result4 + @Result5 SaleRets_Sum'

-- =======================================================
	IF @PrintStatement = 1
	BEGIN
		PRINT @StrSelect
		PRINT @StrSelect1
		PRINT @StrSelect2
		PRINT @StrSelect3
		PRINT @StrSelect4
		PRINT @StrSelect5
		PRINT @StrSelect6
		PRINT @StrSelect7
	END		 	 

	SET @StrSelect = @StrSelect + @StrSelect1 + @StrSelect2 + @StrSelect3 + @StrSelect4 + @StrSelect5+ @StrSelect6 + @StrSelect7
	EXEC sp_executesql @StrSelect;
	
-- =======================================================
END
GO
