USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1389/10/27
-- Viewed By	 : 
-- Last Modified : 1389/11/19
-- Last Modifier : TakroSystem\Zia
-- Description   : گزارش سرجمع فروش و برگشتی
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_Summary]
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			char(10) = Null,
	@DocDateTo			char(10) = Null,
	@SelectedGoods		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@SortFields			NVarChar(100) = Null,   -- Order By Field List
	@ExtraParams		NVarChar(200) = '0@0',
	@RepOptions			VarChar(10) = '1', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
	---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrWhereG	NVarChar(1000);

DECLARE @GroupFr	NVarChar(10);
DECLARE @GroupTo	NVarChar(10);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@SumAmount1	decimal(20,5);
DECLARE	@SumAmount2	decimal(20,5);

DECLARE @ShowPrice	bit;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

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
	
	-- Init Variables --------
	IF (@RepOptions Is Null)	SET @RepOptions = '1100011'

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0;
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0;
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0;
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0;

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @GroupFr	= pub.funSplitString(@ExtraParams, '@', 1);
	SET @GroupTo	= pub.funSplitString(@ExtraParams, '@', 2);

	SET @ShowPrice	= Substring(@RepOptions, 1, 1);

	-- --------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	SET @StrWhere = 'D.ProcessID in(90, 100)'

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	-- group --
	SET @StrWhereG = ''

	if (@GroupFr <> '') and (@GroupFr <> '0')
		set @StrWhereG = @StrWhereG + '(GoodsGroupID >= ''' + @GroupFr + ''')'
	if (@GroupTo <> '') and (@GroupTo <> '0')
	begin
		if (@StrWhereG <> '') set @StrWhereG = @StrWhereG + ' and '
		set @StrWhereG = @StrWhereG + '(GoodsGroupID <= ''' + @GroupTo + ''')'
	end

	if ((@GroupTo <> '') and (@GroupTo <> '0')) or ((@GroupTo <> '') and (@GroupTo <> '0'))
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID IN 
		(
			SELECT	DISTINCT G.GoodsID
			FROM	inv.tblGoodsGroupsGoodsListDtl G
			WHERE	' + @StrWhereG + '
		))'
	-- ----------

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
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

	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'VisitorAcntCode') + ')'
	---------------------------------------------------------
	-- Select Clause ----------------------------------------
	create table #tbl_Stats
	(
		SumQty float,
		SumPrc float
	);

	SET @StrSelect = '
		insert into #tbl_Stats
		select	SUM(CASE WHEN D.ProcessID = 90 THEN 1 ELSE -1 END * D.GoodsQuantity) AS SumQty,
				SUM(CASE WHEN D.ProcessID = 90 THEN 1 ELSE -1 END * D.GoodsQuantity * D.GoodsPrice) AS SumPrc
		from    inv.tblStorageDocsDtl D 
		where   ' + @StrWhere 
	print @StrSelect;
	Exec sp_executesql @StrSelect;

	select @SumAmount1 = isnull(SumQty, 0)
	from #tbl_Stats

	select @SumAmount2 = isnull(SumPrc, 0)
	from #tbl_Stats
		
	if (@SumAmount1 = 0)
		set @SumAmount1 = 1;
	if (@SumAmount2 = 0)
		set @SumAmount2 = 1;

	SET @StrSelect = '
	SELECT T.*, [pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode,
		   ((T.QuantityS - T.QuantityR) / ' + LTrim(Str(@SumAmount1, 20, 5)) + ' * 100) as PercentQ,
		   ((T.PriceS - T.PriceR) / ' + LTrim(Str(@SumAmount2, 20, 5)) + ' * 100) as PercentP,
			GH.ExtraField1, GH.ExtraField2, GH.ExtraField3, GH.ExtraField4, GH.ExtraField5
	FROM
	(
		SELECT	D.GoodsID, 
				SUM(CASE WHEN D.ProcessID = 90  THEN D.GoodsQuantity ELSE 0 END) AS QuantityS,
				SUM(CASE WHEN D.ProcessID = 100 THEN D.GoodsQuantity ELSE 0 END) AS QuantityR,
				SUM(CASE WHEN D.ProcessID = 90  THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END) AS PriceS,
				SUM(CASE WHEN D.ProcessID = 100 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END) AS PriceR,
				SUM(CASE WHEN D.ProcessID = 90 THEN D.DiscountDtl ELSE 0 END) AS DiscountS,
				SUM(CASE WHEN D.ProcessID = 100 THEN D.DiscountDtl ELSE 0 END) AS DiscountR
		FROM    inv.tblStorageDocsDtl D 
		WHERE   ' + @StrWhere + '
		GROUP BY D.GoodsID 
	) T 
	INNER JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(T.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ''

	------------------------------------------------------------
	-- Sort Clause ---------------------------------------------
	If (@SortFields Is Not Null) AND (@SortFields <> '')
	Begin
		SET @StrSelect = @StrSelect + ' 
		ORDER BY ' + @SortFields
	End
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
