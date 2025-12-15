USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--exec "TS_PayAra_1_1400"."inv"."RptStore_Detailed2";1 80, 1, 1400, 27751, 1400, 27751, '@@@', '@@@', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, N'null#null#null#null#null#null#null#null#null#null#null#null#null', '1101011000000', N' FiscalYear , SerialNo , DocRowNo ', N'1@193284@150047@0@1', N'@0@0@@@@@0@0@0@0@0@0@0@0@@@@@@'

-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/08/29
-- Viewed By	 : 
-- Last Modified : 1393/08/22
-- Last Modifier : TakroSystem\Hamid
-- Description	 : گزارش تفصیلی انبار برای یک شخص
-- ==============================================
Create PROCEDURE inv.RptStore_Detailed2
	@ProcessID			Int = 90,
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@SelectedStore		Int = Null,
	@SelectedStore2		Int = Null,
	@SelectedGoods		Int = Null, -- انتخاب کالا
	@SelectedAcnt1		Int = Null, -- انتخاب طرف حساب
	@SelectedAcnt2		Int = Null,
	@SelectedAcnt3		Int = Null,
	@SelectedAcnt4		Int = Null,
	@SelectedVisitor1	Int = Null, -- انتخاب بازاریاب
	@SelectedVisitor2	Int = Null, 
	@SelectedVisitor3	Int = Null, 
	@SelectedVisitor4	Int = Null, 
	@DocStep			Int = 0,  -- مرحله
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@RepOptions			VarChar(20) = '111011111',  -- bit array options
	@SortFields			NVarChar(100) = Null,
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = ''
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(Max);
DECLARE @StrSelect2		NVarChar(Max);
DECLARE @StrFrom		NVarChar(Max);
DECLARE @StrWhere		NVarChar(Max);
DECLARE @StrWhereT		NVarChar(4000);
DECLARE @StrWhereD		NVarChar(4000);
DECLARE @StrQty			VarChar(1000);
DECLARE @StrPrc			VarChar(1000);
DECLARE @StrPID		    VarChar(20);
DECLARE @StrRetPID		VarChar(3);
DECLARE @ExtraJoin      VarChar(250);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

DECLARE	@ShowQuantity	Bit;  -- شامل ستون موجودی
DECLARE	@ShowPrice		Bit;  -- شامل ستون قیمت
DECLARE	@ShowOverload	Bit;  -- شامل ستون سربار
DECLARE	@ShowGoodsName	Bit;  -- شامل ستون نام کالا
DECLARE	@UseAmount		Bit;  -- Use Amount Filed Instead of Price
DECLARE	@DecReturn		Bit;  -- کسر برگشتیها
DECLARE @StrPrice		NVarChar(200);
DECLARE @PID1	bit;
DECLARE @PID2	bit;
DECLARE @PID3	bit;

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

DECLARE @IsCurrency	Bit;
DECLARE @SH			NVarChar(50);
DECLARE @SD			NVarChar(50);

DECLARE @FilterByServices	Bit;
DECLARE	@HasSerial			Bit;
DECLARE	@WithVoucher    	Bit;
DECLARE	@WithoutVoucher    	Bit;

DECLARE	@FromExpireDate		Varchar(10);
DECLARE	@ToExpireDate		Varchar(10);
DECLARE @PrdBatchNoFr		NVarChar(20);
DECLARE @PrdBatchNoTo		NVarChar(20);
DECLARE @PrdSerialFr		NVarChar(20);
DECLARE @PrdSerialTo		NVarChar(20);

DECLARE @var1				FLOAT
DECLARE @var2				FLOAT
DECLARE @var3				FLOAT
DECLARE @var4				FLOAT
DECLARE @ConstText1			NVarChar(100);
DECLARE @ConstText2			NVarChar(100);
DECLARE @ConstText3			NVarChar(100);
DECLARE @ConstText4			NVarChar(100);

DECLARE @VATY	  bit;
DECLARE @VATN	  bit;

DECLARE @DtlStore bit;
DECLARE @PrdWageForOnePoduct bit;

DECLARE @StrUserPrice		NVarChar(1000);
DECLARE @StrUserPriceGrp	NVarChar(1000);
DECLARE	@GoodsID			Varchar(20);
DECLARE	@AcntCode			Varchar(20);
DECLARE @intPartNo          int;
DECLARE @IsMultiplex		Bit;


Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--========================
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
	
	-- ===============================================
	Declare @sal_AggregateSimilarGoodsInRpt Bit;
	SET @sal_AggregateSimilarGoodsInRpt = 0

	SELECT @sal_AggregateSimilarGoodsInRpt = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsInRpt'

	-- ==========
	Declare @sal_AggregateSimilarGoodsUPI Bit;
	SET @sal_AggregateSimilarGoodsUPI = 0

	SELECT @sal_AggregateSimilarGoodsUPI = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsUPI'

	-- ==========
	Declare @sal_AggregateSimilarGoodsByPrice Bit;
	SET @sal_AggregateSimilarGoodsByPrice = 0

	SELECT @sal_AggregateSimilarGoodsByPrice = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsByPrice'
			
	-- Init -------------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1
	IF (@RepOptions	Is Null)	SET @RepOptions = '110011111'
	IF (@DocStep	Is Null)	SET @DocStep = 0
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null';

	IF (@DocDateFr	Is Null)	SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)	SET @DocDateTo = '@@@';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0
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

	SET @ShowQuantity	  = Substring(@RepOptions, 1, 1)
	SET @ShowPrice		  = Substring(@RepOptions, 2, 1)
	SET @ShowOverload	  = Substring(@RepOptions, 3, 1)
	SET @ShowGoodsName	  = Substring(@RepOptions, 4, 1)
	SET @DecReturn		  = Substring(@RepOptions, 5, 1)
	SET @UseAmount		  = Substring(@RepOptions, 6, 1)
	SET @PID1			  = Substring(@RepOptions, 7, 1)
	SET @PID2			  = Substring(@RepOptions, 8, 1)
	SET @PID3		  	  = Substring(@RepOptions, 9, 1)
	SET @IsCurrency		  = Substring(@RepOptions, 10, 1)
	SET @VATY			  = Substring(@RepOptions, 11, 1)
	SET @VATN			  = Substring(@RepOptions, 12, 1)
	SET @FilterByServices = Substring(@RepOptions, 13, 1)
	SET @WithVoucher      = Substring(@RepOptions, 14, 1)
	SET @WithoutVoucher   = Substring(@RepOptions, 15, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

	SET @StrRetPID = '100'
	
	SET @CustKind		 = LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @HasSerial		 = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @FromExpireDate	 = LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @ToExpireDate	 = LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @PrdBatchNoFr	 = LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @PrdBatchNoTo	 = LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @PrdSerialFr	 = LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @PrdSerialTo	 = LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @sal_AggregateSimilarGoodsInRpt	 = LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	SET @sal_AggregateSimilarGoodsUPI	 = LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	SET @var1	 = LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	SET @var2	 = LTrim(pub.funSplitString(@ExtraParams, '@', 13));
	SET @var3	 = LTrim(pub.funSplitString(@ExtraParams, '@', 14));
	SET @var4	 = LTrim(pub.funSplitString(@ExtraParams, '@', 15));
	SET @ConstText1	 = LTrim(pub.funSplitString(@ExtraParams, '@', 16));
	SET @ConstText2	 = LTrim(pub.funSplitString(@ExtraParams, '@', 17));
	SET @ConstText3	 = LTrim(pub.funSplitString(@ExtraParams, '@', 18));
	SET @ConstText4	 = LTrim(pub.funSplitString(@ExtraParams, '@', 19));
	SET @GoodsID	 = LTrim(pub.funSplitString(@ExtraParams, '@', 20));
	SET @AcntCode	 = LTrim(pub.funSplitString(@ExtraParams, '@', 21));
	SET @intPartNo   = LTrim(pub.funSplitString(@ExtraParams, '@', 22));
	SET @IsMultiplex = LTrim(pub.funSplitString(@ExtraParams, '@', 23));
	SET @PrdWageForOnePoduct = 'False'	

	SELECT @DtlStore = SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Sal_StoreDtl'
	SELECT @PrdWageForOnePoduct = SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'PrdWageForOnePoduct'
	
	
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
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	Set @StrWhere = ' (D.ProcessID in (' + @StrPID + '))'
	Set @StrWhereT = '1 = 1'
	Set @StrWhereD = ' (ProcessID in (' + @StrPID + '))'

	If (@GoodsID<> '')
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID =''' + LTrim(@GoodsID) + ''')'
	If (@AcntCode<> '')
		SET @StrWhere = @StrWhere + ' AND (SubString(D.AcntCode , acc.FunGetAcntInfoForRemain(2),acc.FunGetAcntInfoForRemain(3))=''' + LTrim(@AcntCode) + ''')'
		
	If (@var1 Is Not Null) AND @var1>0
	Begin
		SET @StrWhere = @StrWhere + ' AND D.Var1 = ' + LTrim(Str(@var1))
		SET @StrWhereD = @StrWhereD + ' AND Var1 = ' + LTrim(Str(@var1))
	End
	
	If (@var2 Is Not Null) AND @var2>0
	Begin
		SET @StrWhere = @StrWhere + ' AND D.Var2 = ' + LTrim(Str(@var2))
		SET @StrWhereD = @StrWhereD + ' AND Var2 = ' + LTrim(Str(@var2))
	End

	If (@var3 Is Not Null) AND @var3>0
	Begin
		SET @StrWhere = @StrWhere + ' AND D.Var3 = ' + LTrim(Str(@var3))
		SET @StrWhereD = @StrWhereD + ' AND Var3 = ' + LTrim(Str(@var3))
	End

	If (@var4 Is Not Null) AND @var4>0
	Begin
		SET @StrWhere = @StrWhere + ' AND D.Var4 = ' + LTrim(Str(@var4))
		SET @StrWhereD = @StrWhereD + ' AND Var4 = ' + LTrim(Str(@var4))
	End

	If (@ConstText1 Is Not Null) AND @ConstText1<>''
	Begin
		SET @StrWhere = @StrWhere + ' AND D.ConstText1 LIKE ''%' + @ConstText1 + '%'''
		SET @StrWhereD = @StrWhereD + ' AND ConstText1 LIKE ''%' + @ConstText1 + '%'''
	End

	If (@ConstText2 Is Not Null) AND @ConstText2<>''
	Begin
		SET @StrWhere = @StrWhere + ' AND D.ConstText2 LIKE ''%' + @ConstText2 + '%'''
		SET @StrWhereD = @StrWhereD + ' AND ConstText2 LIKE ''%' + @ConstText2 + '%'''
	End

	If (@ConstText3 Is Not Null) AND @ConstText3<>''
	Begin
		SET @StrWhere = @StrWhere + ' AND D.ConstText3 LIKE ''%' + @ConstText3 + '%'''
		SET @StrWhereD = @StrWhereD + ' AND ConstText3 LIKE ''%' + @ConstText3 + '%'''
	End

	If (@ConstText4 Is Not Null) AND @ConstText4<>''
	Begin
		SET @StrWhere = @StrWhere + ' AND D.ConstText4 LIKE ''%' + @ConstText4 + '%'''
		SET @StrWhereD = @StrWhereD + ' AND ConstText4 LIKE ''%' + @ConstText4 + '%'''
	End

	If (@ProcessNo Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
		SET @StrWhereD = @StrWhereD + ' AND ProcessNo = ' + LTrim(Str(@ProcessNo))
	End

	if (@CustKind <> '')
	Begin
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'
		Set @StrWhereD = @StrWhereD + ' AND (pub.funGetCustomerKindID(AcntCode) = ''' + @CustKind + ''')'
	End

	If (@Dist0 <> 'null')
	Begin
		SET @StrWhere = @StrWhere + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
		SET @StrWhereD = @StrWhereD + ' AND DriverID = ''' + LTrim(@Dist0) + ''''
	End
	If (@Dist1 <> 'null')
	Begin
		SET @StrWhere = @StrWhere + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
		SET @StrWhereD = @StrWhereD + ' AND DistributerID1 = ''' + LTrim(@Dist1) + ''''
	End
	If (@Dist2 <> 'null')
	Begin
		SET @StrWhere = @StrWhere + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''
		SET @StrWhereD = @StrWhereD + ' AND DistributerID2 = ''' + LTrim(@Dist2) + ''''
	End

	If (@Dist5 <> 'null')
	Begin
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
		SET @StrWhereD = @StrWhereD + ' AND BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	End
	If (@Dist7 <> 'null')
	Begin
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(@Dist8)
		SET @StrWhereD = @StrWhereD + ' AND BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND BaseDistributionSerialNo <= ' + LTrim(@Dist8)
	End

	IF (@SerialNoFr Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
		SET @StrWhereD = @StrWhereD + ' AND (FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	End
	IF (@SerialNoTo Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		SET @StrWhereD = @StrWhereD + ' AND (FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	End

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
		SET @StrWhereD = @StrWhereD + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'DocDate', 'DocDate2', 'DocDate3', 'DocDate4')
		SET @StrWhereT = @StrWhereT + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'DocDate', 'DocDate', 'DocDate', 'DocDate')
	End
	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
		SET @StrWhereD = @StrWhereD + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'DocDate', 'DocDate2', 'DocDate3', 'DocDate4')
		SET @StrWhereT = @StrWhereT + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'DocDate', 'DocDate', 'DocDate', 'DocDate')
	End
	
	IF (@SelectedGoods > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		--SET @StrWhereT = @StrWhereT + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'GoodsID') 
	End
	
	IF (@SelectedStore > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'StoreID') 
		SET @StrWhereT = @StrWhereT + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'StoreID') 
	End
		
	IF (@SelectedStore2 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'StoreID2')
		SET @StrWhereT = @StrWhereT + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'StoreID2')
	End

	IF (@SelectedAcnt1 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'AcntCode')
	End
	IF (@SelectedAcnt2 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'AcntCode')
	End
	IF (@SelectedAcnt3 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'AcntCode')
	End
	IF (@SelectedAcnt4 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'AcntCode')
	End

	IF (@SelectedVisitor1 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
		SET @StrWhereD = @StrWhereD + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'VisitorAcntCode') + ')'
	End
	IF (@SelectedVisitor2 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
		SET @StrWhereD = @StrWhereD + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'VisitorAcntCode') + ')'
	End
	IF (@SelectedVisitor3 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
		SET @StrWhereD = @StrWhereD + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'VisitorAcntCode') + ')'
	End
	IF (@SelectedVisitor4 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'
		SET @StrWhereD = @StrWhereD + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'VisitorAcntCode') + ')'
	End

	IF (@DocStep > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.DocStep = ' + LTrim(Str(@DocStep)) + ')'
		SET @StrWhereD = @StrWhereD + ' AND (DocStep = ' + LTrim(Str(@DocStep)) + ')'
	End	
	IF NOT((@VATY = 1)AND (@VATN = 1))
	BEGIN
		IF (@VATY = 1)
			SET @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0)'
			--SET @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost > 0 OR H.TollOverWorthCost > 0)'
		
		IF (@VATN = 1)
			SET @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost = 0)'
			--SET @StrWhere = @StrWhere + ' AND (H.TaxOverWorthCost = 0 And H.TollOverWorthCost = 0)'
	END
			
	IF (@IsCurrency = 1)
		begin
			set @SH = 'inv.vwStorageHdr_Currency'
			set @SD = 'inv.vwStorageDtl_Currency'
		end
		else
		begin
			set @SH = 'inv.tblStorageDocsHdr'
			set @SD = 'inv.tblStorageDocsDtl'
		end

	IF (@FilterByServices = 1)
		Set @StrWhere = @StrWhere + ' And G.IsService = 1 '

	Set @ExtraJoin= ''
    IF (@WithVoucher = 1) and (@WithoutVoucher = 0)
	Begin 
	    Set @StrWhere = @StrWhere + '  And (Select Count(*) from  acc.tblVoucherDtl V  where V.SourceSerialNo=D.SerialNo and V.SourceFiscalYear=D.FiscalYear and V.SourceProcessID=D.ProcessID AND V.SourceProcessNo = D.ProcessNo)>0 '
	    Set @ExtraJoin = ''-- Inner Join  acc.tblVoucherDtl V  On  V.SourceSerialNo=D.SerialNo and V.SourceFiscalYear=D.FiscalYear and V.SourceProcessID=D.ProcessID AND V.SourceProcessNo = D.ProcessNo '
	End
	IF (@WithoutVoucher = 1) and  (@WithVoucher = 0)
	Begin 
	    Set @StrWhere = @StrWhere + '  And V.DocRowNo is null '
	    Set @ExtraJoin = ' Left Join  acc.tblVoucherDtl V  On  V.SourceSerialNo=D.SerialNo and V.SourceFiscalYear=D.FiscalYear and V.SourceProcessID=D.ProcessID AND V.SourceProcessNo = D.ProcessNo '
	End   
    
	-- ==============================================
	--SET @sal_AggregateSimilarGoodsInRpt = 1
	--SET @sal_AggregateSimilarGoodsUPI = 1
		
	IF @sal_AggregateSimilarGoodsUPI = 1
	Begin
		SET	@StrUserPrice    = 'ISNULL(UPI.UParams,'''') UserPrice'				
		SET	@StrUserPriceGrp = ', UPI.UParams'				
	End	
	Else
	Begin
		SET	@StrUserPrice    = '0 UserPrice'				
		SET	@StrUserPriceGrp = ''				
	End	
		

	-- Select Clause -------------------------------------------

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
		SET @StrPrice = @strGoodsAmount
	Else
		SET @StrPrice = 'GoodsPrice'
	If (@ProcessID= 80)
	BEGIN
	IF @PrdWageForOnePoduct = 'True'
		SET @StrPrice = 'Wage'
	ELSe
		SET @StrPrice = 'Wage/Case when FormulaProductCount =0 then 1 else FormulaProductCount end  '

	END	
	IF (@DecReturn = 1 And @sal_AggregateSimilarGoodsInRpt = 0)
	BEGIN
		SET @StrQty	= '(D.GoodsQuantity - 
							(
								SELECT	IsNull(SUM(GoodsQuantity), 0)
								FROM	' + @SD + ' 
								WHERE	ProcessID = ' + @StrRetPID + ' AND 
										ProcessNo = ' + Str(@ProcessNo) + ' AND 
										BaseProcessID = D.ProcessID AND 
										BaseProcessNo = D.ProcessNo AND 
										BaseFiscalYear = D.FiscalYear AND 
										BaseSerialNo = D.SerialNo AND 
										BaseDocRowNo = D.DocRowNo
							)
						)'
		SET @StrPrc	= '((D.GoodsQuantity * D.' + @StrPrice + ') - 
							(
								SELECT	IsNull(SUM(GoodsQuantity * ' + @StrPrice + '), 0)
								FROM	' + @SD + ' 
								WHERE	ProcessID = ' + @StrRetPID + ' AND 
										ProcessNo = ' + Str(@ProcessNo) + ' AND 
										BaseProcessID = D.ProcessID AND 
										BaseProcessNo = D.ProcessNo AND 
										BaseFiscalYear = D.FiscalYear AND 
										BaseSerialNo = D.SerialNo AND 
										BaseDocRowNo = D.DocRowNo
							)
						)'
	END
	ELSE
	BEGIN
		SET @StrQty	= 'D.GoodsQuantity'
		SET @StrPrc	= 'D.GoodsQuantity * D.' + @StrPrice 
	END

	-- ===========================================================
	IF @sal_AggregateSimilarGoodsInRpt = 0
	BEGIN
		SET @StrSelect = '
		SELECT *
		into ##tbl_Store_Detailed
		FROM
		(
			SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, VH.OldSerialNo, D.DocRowNo, D.DescDtl, H.DocDesc,H.TransporterID2,  D.DocDate, H.TransportationCost,H.TransportationIncome,
					D.StoreID, D.DiscountDtl,D.DiscountPercentDtl, H.DiscountPercent As HdrDiscountPercent, H.Discount As HdrDiscount, H.Discount2+H.Discount3 Discount2,SD.StoreName,H.PackingCost,
					(Select SUM(DiscountPercent) From inv.tblStorageDocsHdr Where ProcessID = D.ProcessID AND ProcessNo = D.ProcessNo AND 
					 FiscalYear = D.FiscalYear And AcntCode = D.AcntCode And ' + @StrWhereD + ') As SumDiscountPercent,
				     
					 (Select SUM(Discount) From inv.tblStorageDocsHdr Where ProcessID = D.ProcessID AND ProcessNo = D.ProcessNo AND 
					 FiscalYear = D.FiscalYear And AcntCode = D.AcntCode And ' + @StrWhereD + ') As SumDiscount,
				     
					 (Select SUM(Discount2)+SUM(Discount3) From inv.tblStorageDocsHdr Where ProcessID = D.ProcessID AND ProcessNo = D.ProcessNo AND 
					 FiscalYear = D.FiscalYear And AcntCode = D.AcntCode And ' + @StrWhereD + ') As SumDiscount2,
					 H.AgreeNo, H.TaxOverWorthCost, H.TollOverWorthCost, D.TaxOverWorthCostDtl, D.TollOverWorthCostDtl,
				     
					IsNull((Select SUM(TaxOverWorthCost) From inv.tblStorageDocsHdr 
					 Where ProcessID = D.ProcessID And ProcessNo = D.ProcessNo And 
						   FiscalYear = D.FiscalYear And AcntCode = D.AcntCode And ' + @StrWhereT + '),'''') As SumTaxOverWorthCost,

					IsNull((Select SUM(TollOverWorthCost) From inv.tblStorageDocsHdr 
					 Where ProcessID = D.ProcessID And ProcessNo = D.ProcessNo And 
						   FiscalYear = D.FiscalYear And AcntCode = D.AcntCode And ' + @StrWhereT + '),'''') As SumTollOverWorthCost,					

					CASE WHEN (D.StoreID2 = '''') THEN Cast(''-'' AS NVarchar(50)) ELSE D.StoreID2 END StoreID2, '
		SET @StrSelect2 = '
					O.FiscalYear OrderFiscalYear,O.SerialNo OrderSerialNo, D.AcntCode, pub.GetCodeName(D.AcntCode, ' + @LangID + ') AcntName, 
					H.VisitorAcntCode, pub.GetCodeName(H.VisitorAcntCode, ' + @LangID + ') VisitorName, 
					' + @StrQty + ' Quantity, ' + @StrPrc + ' AS Price, ISNULL(UPI.UParams,'''') UserPrice, ' +
					CASE WHEN (@ShowOverload = 1) THEN 'AtomAmount' ELSE '0' END + ' AS Overload, D.GoodsID, ' +
					CASE WHEN (@ShowGoodsName = 1) THEN 'pub.funGetGoodsName(D.GoodsID, ' + @LangID + ')' ELSE 'Cast('''' AS NVarChar(50))' END + ' AS GoodsName,
					D.SubUnitID, U.UnitName, IsNull(GS.SetPoint,0) As SetPoint, IsNull(GS.FitPoint,0) As FitPoint,inv.GetGoodsPlaceNameFromStore(GS.StoreID,GS.DocRowNo,1) As RecDesc,
					D.StoreVariable1, D.StoreVariable2, D.Var1, D.Var2, D.Var3, D.Var4,ConstText1,ConstText2,ConstText3,ConstText4,D.BatchNo,isnull(B.BatchName,'''') BatchName, isnull(DR.FirstName + '' '' + DR.LastName ,'''') As DriverName,
					acc.funGetAcntName(D.CustomerCode, ' + ltrim(rtrim(Str(@intPartNo))) + ' , ' + @LangID + ') AS CustomerName,SubUnitPrice,D.SubUnitQuantity
			FROM	' + @SD + ' D
						INNER JOIN ' + @SH + ' H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND 
											   H.SerialNo = D.SerialNo
						Inner Join inv.tblStoresDtl SD On SD.StoreID=D.StoreID '
						+ @ExtraJoin +						
						'LEFT JOIN  cmr.tblOrderDtl O on O.FiscalYear=D.BaseFiscalYear and O.SerialNo=D.BaseSerialNo and O.ProcessID=D.BaseProcessID and O.ProcessNo=D.BaseProcessNo and O.DocRowNo=D.BaseDocRowNo 
						LEFT JOIN inv.tblGoods G ON G.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
						LEFT JOIN inv.tblGoodsStatusDtl GS ON GS.StoreID = D.StoreID And GS.GoodsID = D.GoodsID
						LEFT JOIN inv.tblUnitsDtl U ON D.SubUnitID = U.UnitID
						LEFT JOIN inv.tblGoodsUserPrice UPI ON UPI.GoodsID = D.GoodsID And D.UserPriceID = UPI.ID
						LEFT JOIN pub.tblDriversDtl DR ON DR.DriverID=H.DriverID
						LEFT JOIN acc.tblVoucherHdr VH ON H.VchNo = VH.SerialNo
						LEFT JOIN inv.tblBatchDtl B ON B.BatchNo = D.BatchNo And B.LanguageID = '+ @LangID +'
			WHERE	' + @StrWhere + '
		) T '
	END
	ELSE
	BEGIN
		SET @StrSelect = '
		SELECT *
		into ##tbl_Store_Detailed
		FROM
		(
			SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, VH.OldSerialNo, 0 DocRowNo, D.DescDtl, H.DocDesc, D.DocDate, H.TransportationCost,H.TransportationIncome,
					D.StoreID, Sum(D.DiscountDtl) DiscountDtl,Sum(D.DiscountPercentDtl) DiscountPercentDtl,H.DiscountPercent As HdrDiscountPercent, H.Discount As HdrDiscount,
					H.Discount2+H.Discount3 Discount2,SD.StoreName,H.PackingCost,
					(Select SUM(DiscountPercent) From inv.tblStorageDocsHdr Where ProcessID = D.ProcessID AND ProcessNo = D.ProcessNo AND 
					 FiscalYear = D.FiscalYear And AcntCode = D.AcntCode And ' + @StrWhereD + ') As SumDiscountPercent,
				     
					(Select SUM(Discount) From inv.tblStorageDocsHdr Where ProcessID = D.ProcessID AND ProcessNo = D.ProcessNo AND 
					 FiscalYear = D.FiscalYear And AcntCode = D.AcntCode And ' + @StrWhereD + ') As SumDiscount,
				     
					(Select SUM(Discount2)+SUM(Discount3) From inv.tblStorageDocsHdr Where ProcessID = D.ProcessID AND ProcessNo = D.ProcessNo AND 
					 FiscalYear = D.FiscalYear And AcntCode = D.AcntCode And ' + @StrWhereD + ') As SumDiscount2,
					 H.AgreeNo, H.TaxOverWorthCost, H.TollOverWorthCost, Sum(D.TaxOverWorthCostDtl) TaxOverWorthCostDtl, 
					 Sum(D.TollOverWorthCostDtl) TollOverWorthCostDtl,
					 IsNull((Select SUM(TaxOverWorthCost) From inv.tblStorageDocsHdr 
					 Where ProcessID = D.ProcessID And ProcessNo = D.ProcessNo And 
						   FiscalYear = D.FiscalYear And AcntCode = D.AcntCode And ' + @StrWhereT + '),'''') As SumTaxOverWorthCost,
					 IsNull((Select SUM(TollOverWorthCost) From inv.tblStorageDocsHdr 
					 Where ProcessID = D.ProcessID And ProcessNo = D.ProcessNo And 
						   FiscalYear = D.FiscalYear And AcntCode = D.AcntCode And ' + @StrWhereT + '),'''') As SumTollOverWorthCost,					

					CASE WHEN (D.StoreID2 = '''') THEN Cast(''-'' AS NVarchar(50)) ELSE D.StoreID2 END StoreID2, '
		SET @StrSelect2 = '
					O.FiscalYear OrderFiscalYear,O.SerialNo OrderSerialNo, D.AcntCode, pub.GetCodeName(D.AcntCode, ' + @LangID + ') AcntName, 
					H.VisitorAcntCode, pub.GetCodeName(H.VisitorAcntCode, ' + @LangID + ') VisitorName, 
					Sum(' + @StrQty + ') Quantity, Sum(' + @StrPrc + ') AS Price, ' + @StrUserPrice + ', ' +
					CASE WHEN (@ShowOverload = 1) THEN 'Sum(AtomAmount)' ELSE '0' END + ' AS Overload, D.GoodsID, ' +
					CASE WHEN (@ShowGoodsName = 1) THEN 'pub.funGetGoodsName(D.GoodsID, ' + @LangID + ')' ELSE 'Cast('''' AS NVarChar(50))' END + ' AS GoodsName,
					D.SubUnitID, U.UnitName, IsNull(GS.SetPoint,0) As SetPoint, IsNull(GS.FitPoint,0) As FitPoint, inv.GetGoodsPlaceNameFromStore(GS.StoreID,GS.DocRowNo,1) RecDesc,
					0 StoreVariable1, 0 StoreVariable2, 0 Var1, 0 Var2, 0 Var3, 0 Var4,0 ConstText1,0 ConstText2,0 ConstText3,0 ConstText4,D.BatchNo,isnull(B.BatchName,'''') BatchName, isnull(DR.FirstName + '' '' + DR.LastName ,'''') As DriverName,
					acc.funGetAcntName(D.CustomerCode, ' + ltrim(rtrim(Str(@intPartNo))) + ' , ' + @LangID + ') AS CustomerName,SubUnitPrice,D.SubUnitQuantity
			FROM	' + @SD + ' D
						INNER JOIN ' + @SH + ' H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND 
											   H.SerialNo = D.SerialNo
                        INNER JOIN inv.tblStoresDtl SD On SD.StoreID=D.StoreID '
						+ @ExtraJoin +	
					   'LEFT JOIN  cmr.tblOrderDtl O on O.FiscalYear=D.BaseFiscalYear and O.SerialNo=D.BaseSerialNo and O.ProcessID=D.BaseProcessID and O.ProcessNo=D.BaseProcessNo and O.DocRowNo=D.BaseDocRowNo 
						LEFT JOIN inv.tblGoods G ON G.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
						LEFT JOIN inv.tblGoodsStatusDtl GS ON GS.StoreID = D.StoreID And GS.GoodsID = D.GoodsID
						LEFT JOIN inv.tblUnitsDtl U ON D.SubUnitID = U.UnitID
						LEFT JOIN inv.tblGoodsUserPrice UPI ON UPI.GoodsID = D.GoodsID And D.UserPriceID = UPI.ID
						LEFT JOIN pub.tblDriversDtl DR ON DR.DriverID=H.DriverID
						LEFT JOIN acc.tblVoucherHdr VH ON H.VchNo = VH.SerialNo
						LEFT JOIN inv.tblBatchDtl B ON B.BatchNo = D.BatchNo And B.LanguageID = '+ @LangID +'
			WHERE	' + @StrWhere + '
			Group By D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, VH.OldSerialNo, D.DescDtl, H.DocDesc, D.DocDate, D.StoreID,H.TransportationCost,H.TransportationIncome,
					 H.DiscountPercent,H.PackingCost, H.Discount, H.Discount2,H.Discount3 , D.AcntCode,H.VisitorAcntCode, H.AgreeNo, H.TaxOverWorthCost, H.TollOverWorthCost,
					 D.StoreID2, D.GoodsID, D.SubUnitID, U.UnitName, GS.SetPoint, GS.FitPoint, GS.GoodsPlaceID' + @StrUserPriceGrp + '
					 ,D.BatchNo,B.BatchName,SD.StoreName,O.FiscalYear,O.SerialNo,GS.StoreID,GS.DocRowNo,DR.FirstName,DR.LastName,D.CustomerCode,SubUnitPrice,D.SubUnitQuantity
		) T '	
	END
	
	------------------------------------------------------------
	-- Sort Clause ---------------------------------------------
	If @SortFields Is Not Null
	SET @StrSelect2 = @StrSelect2 + ' 
		ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	begin try
		drop table ##tbl_Store_Detailed
	end try
	begin catch
	end catch
	
	Print @StrSelect;
	Print @StrSelect2;
	
	SET @StrSelect = @StrSelect + @StrSelect2;
	Exec sp_executesql @StrSelect;
	
	if (@UserIsAdmin = 0)
	begin
		exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'StoreID', 'inv.tblStores', @UserID;
		--exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'GoodsID', 'inv.tblGoods', @UserID;
		--exec pub.SpFilterByPermission2 '##tbl_Store_Detailed', 'AcntCode', 'acc.tblAcnt', @UserID;
	end
	
	SET @StrSelect = 'select * 	from ##tbl_Store_Detailed'

	If @SortFields Is Not Null
		SET @StrSelect = @StrSelect + ' 
			ORDER BY ' + @SortFields

	Exec sp_executesql @StrSelect;

	------------------------------------------------------------
END
GO
