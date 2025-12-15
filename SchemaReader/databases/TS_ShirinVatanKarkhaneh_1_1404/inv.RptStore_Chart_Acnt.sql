USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/04/02
-- Viewed By	 : 
-- Last Modified : 1392/05/22
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : نمودار اسناد انبار به تفکیک کد حسابداری
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Chart_Acnt] 
	@ProcessID		Int,
	@ProcessNo		Int = Null,
	@DocDateFr		VarChar(60) = Null,
	@DocDateTo		VarChar(60) = Null,
	@VchNoFr		Int = Null,
	@VchNoTo		Int = Null,
	@SelectedGoods	Int = 0,
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0, 
	@VisitorAcnt1	int = 0,
	@VisitorAcnt2	int = 0,
	@VisitorAcnt3	int = 0,
	@VisitorAcnt4	int = 0,
	@DistributeInfo	NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@ColCount		Int = 25, -- Records Per Page
	@RepOptions		VarChar(10) = '1001', -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1' 
 WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrSortBy	NVarChar(1000);

DECLARE @RetPID		VarChar(3);

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

DECLARE	@SortFiels	Int;

DECLARE @IsMultiplex	Bit;
DECLARE @SortByStoreID	Bit;
DECLARE @StoreIDField1	NVarChar(100);
DECLARE @StoreIDField2	NVarChar(100);

Begin --============== S T A R T  C O D E =====================================

	SET NOCOUNT ON;

	-- Init Variables & Default Values ----------------------------------------
	IF (@RepInfo	Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)		SET @RepOptions = '1001';
	IF (@ProcessNo  Is Null)		SET @ProcessNo = 1;
	IF (@DocDateFr	Is Null)		SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)		SET @DocDateTo = '@@@';
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null';

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;
	IF (@VisitorAcnt1	Is Null)	SET @VisitorAcnt1 = 0;
	IF (@VisitorAcnt2	Is Null)	SET @VisitorAcnt2 = 0;
	IF (@VisitorAcnt3	Is Null)	SET @VisitorAcnt3 = 0;
	IF (@VisitorAcnt4	Is Null)	SET @VisitorAcnt4 = 0;

	SET @StrSortBy = ''
	
	SET @ShowPrice		= Substring(@RepOptions, 1, 1);
	SET @ShowOverload	= Substring(@RepOptions, 2, 1);
	SET @DecReturn		= Substring(@RepOptions, 3, 1);
	SET @UseAmount		= Substring(@RepOptions, 4, 1);
	SET @SortFiels		= Substring(@RepOptions, 6, 1);
	SET @SortByStoreID	= Substring(@RepOptions, 7, 1);

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

	IF @SortByStoreID = 1
	Begin
		SET @StoreIDField1 = ', T.StoreID'
		SET @StoreIDField2 = ', StoreID'
	End
	Else
	Begin
		SET @StoreIDField1 = ''
		SET @StoreIDField2 = ''
	End	
	
	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @IsMultiplex	= pub.funSplitString(@RepInfo, '@', 6);
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	If (@DecReturn = 1) 
		SET @RetPID = '100'
	ELSE
		SET @RetPID = '0'

	SET @StrWhere = 'D.ProcessID = ' + LTrim(Str(@ProcessID))

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

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	IF (@VisitorAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt1, 'D.VisitorAcntCode')
	IF (@VisitorAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt2, 'D.VisitorAcntCode')
	IF (@VisitorAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt3, 'D.VisitorAcntCode')
	IF (@VisitorAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt4, 'D.VisitorAcntCode')
		
	IF @SortFiels = 0 OR @SortFiels = 1
		SET @StrSortBy = 'AcntCode'
	Else IF @SortFiels = 2
		SET @StrSortBy = 'COUNT(T.AcntCode)'
	Else IF @SortFiels = 3
		SET @StrSortBy = 'AcntCode, COUNT(T.AcntCode)'			
	
	--------------------------------------------------------------------
	-- Select Clause ---------------------------------------------------
	DECLARE @StrPrice AS NVarChar(50);
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

	If (@UseAmount = 1)
		Set @StrPrice = '(GoodsQuantity * '+ @strGoodsAmount +')'
	Else
		Set @StrPrice = '(GoodsQuantity * GoodsPrice)'

	SET @StrSelect = '
	DECLARE @MaxQty Float;
	DECLARE @MaxPrc Float;
	DECLARE @MaxOvr Float;

	Create Table #tblResult
	(
		AcntCode VarChar(20) COLLATE Arabic_CS_AS,
		Quantity Float,
		Price	 Float,
		Overload Float,
		GroupID  Int' + 
		Case When @SortByStoreID = 1 Then ',
		StoreID  Varchar(20)' Else '' End + '
	)

	INSERT	INTO #tblResult
	SELECT	T.AcntCode, Sum(Quantity) Quantity, --COUNT(T.AcntCode) RCounr, 
			--SUM(T.Quantity-T.QuantityRet) Quantity,
			SUM(T.Price-T.PriceRet) Price,
			SUM(T.Overload-T.OverloadRet) Overload,
			(Row_Number() Over (Order By ' + @StrSortBy + ')) / ' + LTrim(Str(@ColCount)) + ' GroupID' + 
			@StoreIDField1 + '
	FROM
	(
		select  D.AcntCode, D.GoodsQuantity Quantity, ' + @StrPrice + ' Price, D.AtomAmount Overload,
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
				),0) OverloadRet, D.StoreID
		from	inv.tblStorageDocsDtl D
					INNER JOIN inv.tblStorageDocsHdr H ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
		where  ' + @StrWhere + ' 
	) T
	GROUP BY ' + Case When @SortByStoreID = 0 Then 'T.AcntCode' Else 'T.StoreID, T.AcntCode' End + '
	HAVING COUNT(T.AcntCode) <> 0 OR SUM(T.Price-T.PriceRet) <> 0 

	SELECT	@MaxQty = Max(Quantity), @MaxPrc = Max(Price), @MaxOvr = Max(Overload)
	FROM	#tblResult

	INSERT	INTO #tblResult
	SELECT	CHAR(9)+''ماکزیمم'', @MaxQty, @MaxPrc, @MaxOvr, GroupID ' + @StoreIDField2 + '
	FROM	#tblResult
	GROUP BY ' + Case When @SortByStoreID = 0 Then 'GroupID' Else 'StoreID, GroupID' End + '

	SELECT	R.*, case when (R.AcntCode=CHAR(9)+''ماکزیمم'') then CHAR(9)+''ماکزیمم'' else pub.GetCodeName(R.AcntCode, 1) end AcntName
	FROM	#tblResult R '

	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
