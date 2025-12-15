USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/05/16
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : نمودار اسناد انبار به تفکیک کد بازاریاب
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Chart_Visitor]
	@ProcessID		Int,
	@ProcessNo		Int = Null,
	@DocDateFr		VarChar(60) = Null,
	@DocDateTo		VarChar(60) = Null,
	@VchNoFr		Int = Null,
	@VchNoTo		Int = Null,
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0, 
	@DistributeInfo	NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@ColCount		Int = 25, -- Records Per Page
	@SaleTypeID		VarChar(20) = Null,
	@RepOptions		VarChar(10) = '1001', -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1' 
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE @RetPID		VarChar(3);

DECLARE @ShowPrice		Bit; 
DECLARE @ShowOverload	Bit; 
DECLARE @DecReturn		Bit; 
DECLARE @UseAmount		Bit; -- Use Amount Field Instead of Price?

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @Dist0		NVarChar(20); -- DriverID
DECLARE @Dist1		NVarChar(20); -- DistributerID1
DECLARE @Dist2		NVarChar(20); -- DistributerID2
DECLARE @Dist3		NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4		NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5		NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6		NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7		NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8		NVarChar(20); -- BaseDistributionSerialNo   to

Begin --============== S T A R T  C O D E =====================================

	SET NOCOUNT ON;

	-- Init Variables & Default Values ----------------------------------------
	IF (@RepInfo	Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)		SET @RepOptions = '1001';
	IF (@ProcessNo  Is Null)		SET @ProcessNo = 1;
	IF (@DocDateFr	Is Null)		SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)		SET @DocDateTo = '@@@';
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null';

	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

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
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	If (@DecReturn = 1) 
		SET @RetPID = '100'
	ELSE
		SET @RetPID = '0'

	SET @StrWhere = '(D.VisitorAcntCode <> '''') and D.ProcessID = ' + LTrim(Str(@ProcessID))

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

	If @ProcessNo Is Not Null
		SET @StrWhere = @StrWhere + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')

	If (@VchNoFr Is Not Null) OR (@VchNoTo Is Not Null)
		If (@VchNoFr = @VchNoTo)
			SET @StrWhere = @StrWhere + ' AND H.VchNo  = ' + LTrim(Str(@VchNoFr))
		Else
		Begin
			If (@VchNoFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND H.VchNo >= ' + LTrim(Str(@VchNoFr))
			If (@VchNoTo Is Not Null)
				SET @StrWhere = @StrWhere + ' AND H.VchNo <= ' + LTrim(Str(@VchNoTo))
		End

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.VisitorAcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.VisitorAcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.VisitorAcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.VisitorAcntCode')
		
	if (@SaleTypeID is not null)
		SET @StrWhere = @StrWhere + ' AND (D.SaleTypeID=''' + @SaleTypeID + ''')'
	--------------------------------------------------------------------
	-- Select Clause ---------------------------------------------------
	DECLARE @StrPrice AS NVarChar(50);

	If (@UseAmount = 1)
		Set @StrPrice = '(GoodsQuantity * GoodsAmount)'
	Else
		Set @StrPrice = '(GoodsQuantity * GoodsPrice)'

	SET @StrSelect = '
	DECLARE @MaxQty Float;
	DECLARE @MaxPrc Float;
	DECLARE @MaxOvr Float;

	Create Table #tblResult
	(
		VisitorAcntCode VarChar(20) COLLATE Arabic_CS_AS,
		VisitorName		NVarChar(200) COLLATE Arabic_CS_AS,
		Quantity Float,
		Price	 Float,
		Overload Float,
		GroupID  Int
	)

	INSERT	INTO #tblResult
	SELECT	T.VisitorAcntCode, pub.GetCodeName(T.VisitorAcntCode,1) AS VisitorName, COUNT(T.VisitorAcntCode) Quantity, 
			--SUM(T.Quantity-T.QuantityRet) Quantity,
			SUM(T.Price-T.PriceRet) Price,
			SUM(T.Overload-T.OverloadRet) Overload,
			(Row_Number() Over ( Order By T.VisitorAcntCode)) / ' + LTrim(Str(@ColCount)) + ' GroupID
	FROM
	(
		select  D.VisitorAcntCode, D.GoodsQuantity Quantity, ' + @StrPrice + ' Price, D.AtomAmount Overload,
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
	GROUP BY T.VisitorAcntCode
	HAVING COUNT(T.VisitorAcntCode) <> 0 OR SUM(T.Price-T.PriceRet) <> 0 

	SELECT	@MaxQty = Max(Quantity), @MaxPrc = Max(Price), @MaxOvr = Max(Overload)
	FROM	#tblResult

	INSERT	INTO #tblResult
	SELECT	CHAR(254), CHAR(1000), @MaxQty, @MaxPrc, @MaxOvr, GroupID
	FROM	#tblResult
	GROUP BY GroupID

	SELECT	* 
	FROM	#tblResult
	ORDER BY GroupID, VisitorAcntCode '
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
