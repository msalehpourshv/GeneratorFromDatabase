USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\ZiA
-- Create date   : 1392/04/02
-- Viewed By	 : 
-- Last Modified : 1392/04/02
-- Last Modifier : TakroSystem\ZiA
-- Description	 : نمودار اسناد انبار به تفکیک ماه
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Chart_Month]
	@GoodsID		VarChar(20),
	@ProcessID		Int = 90,
	@ProcessNo		Int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@SelectedStore	Int = 0,
	@SelectedAcnt1	Int = 0,
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@SelectedAcnt4	Int = 0,
	@SelectedVist1	Int = 0,
	@SelectedVist2	Int = 0,
	@SelectedVist3	Int = 0,
	@SelectedVist4	Int = 0,
	@DistributeInfo	NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@RepOptions		VarChar(10) = '1001', -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE @RetPID		VarChar(3);
Declare @GoodsAmount varchar(20)

DECLARE @ShowPrice		Bit; 
DECLARE @ShowOverload	Bit; 
DECLARE @DecReturn		Bit; 
DECLARE @UseAmount		Bit; -- Use Amount Field Instead of Price?
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
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables & Default Values ----------------------------------------
	IF (@ProcessNo  Is Null)		SET @ProcessNo = 1;
	IF (@RepOptions Is Null)		SET @RepOptions = '1001';
	If (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	If (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	If (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null';

	SET @ShowPrice		= Substring(@RepOptions, 1, 1);
	SET @ShowOverload	= Substring(@RepOptions, 2, 1);
	SET @DecReturn		= Substring(@RepOptions, 3, 1);
	SET @UseAmount		= Substring(@RepOptions, 4, 1);

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
	
	set @GoodsAmount = LTRIM(inv.funGoodsAmount(@DocDateTo))
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	If (@DecReturn = 1) 
		SET @RetPID = '100'
	ELSE
		SET @RetPID = '0'

	Set @StrWhere = '(D.GoodsID=''' + @GoodsID + ''') 
			and (D.ProcessID=' + LTrim(Str(@ProcessID)) + ')'

	If (@ProcessNo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

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

	If (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	--------------------------------------------------------------------
	
	-- Select Clause ---------------------------------------------------
	DECLARE @StrPrice AS NVarChar(50);

	If (@UseAmount = 1)
		Set @StrPrice = '(GoodsQuantity * ' + @GoodsAmount + ')'
	Else
		Set @StrPrice = '(GoodsQuantity * GoodsPrice)'

	CREATE TABLE #tblResult
	(
		MonthCode	Char(2) COLLATE Arabic_CS_AS,
		Quantity	float,
		Price		float,
		Overload	float
	);

	declare @idx int;
	declare @sdx char(2);
	set @idx = 1;
	
	while (@idx < 12)
	begin
		set @sdx = @idx;
		
		if (@idx < 10)
		 set @sdx = '0' + @sdx;
	
		insert into #tblResult(MonthCode, Price, Quantity, Overload)
		values(@sdx, 0, 0, 0)
		
		set @idx = @idx + 1
	end

	Set @StrSelect = '
	INSERT	INTO #tblResult(MonthCode, Price, Quantity, Overload)
	SELECT	Substring(T.DocDate, 6, 2), 
			(T.Price-T.PriceRet) Price,
			(T.Quantity-T.QuantityRet) Quantity, 
			(T.Overload-T.OverloadRet) Overload
	FROM
	(
		select  D.DocDate, D.GoodsQuantity Quantity, 
				' + @StrPrice + ' Price, D.AtomAmount Overload,
				isnull((
					select sum(D2.GoodsQuantity)
					from inv.tblStorageDocsDtl D2
					where D2.ProcessID=' + @RetPID + ' 
						and D2.BaseProcessID=D.ProcessID 
						and D2.BaseProcessNo=D.ProcessNo 
						and D2.BaseFiscalYear=D.FiscalYear 
						and D2.BaseSerialNo=D.SerialNo 
						and D2.BaseDocRowNo=D.DocRowNo
				),0) QuantityRet,
				isnull((
					select sum(' + @StrPrice + ')
					from inv.tblStorageDocsDtl D2
					where D2.ProcessID=' + @RetPID + ' 
						and D2.BaseProcessID=D.ProcessID 
						and D2.BaseProcessNo=D.ProcessNo 
						and D2.BaseFiscalYear=D.FiscalYear 
						and D2.BaseSerialNo=D.SerialNo 
						and D2.BaseDocRowNo=D.DocRowNo
				),0) PriceRet,
				isnull((
					select sum(D2.AtomAmount)
					from inv.tblStorageDocsDtl D2
					where D2.ProcessID=' + @RetPID + ' 
						and D2.BaseProcessID=D.ProcessID 
						and D2.BaseProcessNo=D.ProcessNo 
						and D2.BaseFiscalYear=D.FiscalYear 
						and D2.BaseSerialNo=D.SerialNo 
						and D2.BaseDocRowNo=D.DocRowNo
				),0) OverloadRet
		from	inv.tblStorageDocsDtl D
					INNER JOIN inv.tblStorageDocsHdr H ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
		where  ' + @StrWhere + ' 
	) T
	
	select MonthCode, SUM(Price) Price, SUM(Quantity) Quantity, SUM(Overload) Overload
	from #tblResult
	group by MonthCode
	order by MonthCode '
	
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
