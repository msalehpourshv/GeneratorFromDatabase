USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/01/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : <لیست مغایرت مواد ارسالی به بچ با فرمول تولید>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_BatchProduceStats]
	@BatchNo		nvarchar(20) = null,
	@FormulaNo		int = 0,
	@SelectedGoods	int = 0,
	@SelectedStore	Int = Null,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SortFields		nvarchar(100) = Null,
	@RepOptions		varchar(10) = '',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

declare @ProductID	varchar(20);
declare @ProductQty	float;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE	@Inc		bit;
DECLARE	@Dec		bit;
DECLARE	@Eql		bit;

DECLARE @UnitPart	TINYINT
DECLARE @Unit nvarchar (50)

BEGIN

	SET NOCOUNT ON;

	--================================== UnitPart
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
	--==================================

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';
	if (@SelectedStore	Is Null)	set @SelectedStore = 0;
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;

	if (@FiscalYearFr Is Null)	set @SerialNoFr = Null;
	if (@FiscalYearTo Is Null)	set @SerialNoTo = Null;
	if (@SerialNoFr	Is Null)	set @FiscalYearFr = Null;
	if (@SerialNoTo	Is Null)	set @FiscalYearTo = Null;
	if (@SortFields	Is Null)	set @SortFields = 'GoodsID';
	if (@BatchNo	Is Null)	set @BatchNo = '';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @Inc = Substring(@RepOptions, 1, 1);
	set @Dec = Substring(@RepOptions, 2, 1);
	set @Eql = Substring(@RepOptions, 3, 1);

	set @ProductID = '-1';
	set @ProductQty = 0;
	---------------------------------------------------------------------------
	create table #tbl_Result
	(
		GoodsID	varchar(20) collate arabic_cs_as not null,
		Quantity_Formula	float not null,
		Quantity_Sent		float not null,
		Quantity_Returned	float not null
	);
	---------------------------------------------------------------------------
	-- formula --------------------------------------------------------------------
	set @ProductID = '0'
	set @ProductQty = 0

	select top 1 @ProductID = ProductID, @ProductQty = ProductCount
	from inv.tblStorageDocsHdr
	where (ProcessID in (70,82,83)) and (BatchNo = @BatchNo)
	order By SerialNo

	set @StrWhere = '(D.ProductID = ''' + @ProductID + ''')';

	if (@FormulaNo <> 0)
		set @StrWhere = @StrWhere + ' and (H.SerialNo = ' + ltrim(str(@FormulaNo)) + ')'
	else
		set @StrWhere = @StrWhere + ' and (H.IsDefault = 1)'

	set @StrSelect = '
	insert into #tbl_Result
	select	D.GoodsID, (D.GoodsQuantity * ' + ltrim(str(@ProductQty)) + ' / H.ProductCount) as Quantity_Formula, 0 as Quantity_Sent, 0 as Quantity_Returned
	from	prd.tblFormulasDtl D
				inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
	where  ' + @StrWhere

	print @StrSelect;
	exec sp_executesql @StrSelect;

	-- storage --------------------------------------------------------------------
	set @StrWhere = '(H.BatchNo = ''' + ltrim(@BatchNo) + ''')';
	--if (@ProductID Is Not Null)  	set @StrWhere = @StrWhere+ ' And (H.ProductID = ''' + @ProductID + ''')';

	if (@SerialNoFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	if (@SerialNoTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	if (@DocDateFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	if (@SelectedStore > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	set @StrSelect = '
	insert into #tbl_Result
	select D.GoodsID, 0 as Quantity_Formula, sum(D.GoodsQuantity) as Quantity_Sent, 0 as Quantity_Returned
	FROM         inv.tblStorageDocsHdr AS H INNER JOIN
                      inv.tblStorageDocsDtl AS D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
   
	where (H.ProcessID in (70,82,83)) and ' + @StrWhere + '
	group by D.GoodsID'

	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	set @StrSelect = '
	insert into #tbl_Result
	select D.GoodsID, 0 as Quantity_Formula, 0 as Quantity_Sent, sum(D.GoodsQuantity) as Quantity_Returned
	FROM         inv.tblStorageDocsHdr AS H INNER JOIN
                      inv.tblStorageDocsDtl AS D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
   where (H.ProcessID = 75) and ' + @StrWhere + '
	group by D.GoodsID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	-- final -------------------------------------------------------------------------
	set @StrWhere = '(1=1)';
	
	if (@Inc = 0)
		set @StrWhere = @StrWhere + ' AND (Quantity_Formula > Quantity_Sent - Quantity_Returned)'
	if (@Dec = 0)
		set @StrWhere = @StrWhere + ' AND (Quantity_Formula < Quantity_Sent - Quantity_Returned)'
	if (@Eql = 0)
		set @StrWhere = @StrWhere + ' AND (Quantity_Formula <> Quantity_Sent - Quantity_Returned)'

	IF @FormulaNo = 0
		set @StrWhere = @StrWhere + ' AND (H.IsDefault = 1 OR Quantity_Formula=0) '
	ELSE
		set @StrWhere = @StrWhere + ' and (H.SerialNo = ' + ltrim(str(@FormulaNo)) + ' OR Quantity_Formula=0)'

	set @StrSelect = '
	SELECT X.*,isnull(D.DocRowNo, 0 )DocRowNo
	FROM
	(
		SELECT	R.GoodsID, G.GoodsName,
				sum(Quantity_Formula)	as Quantity_Formula,
				sum(Quantity_Sent)		as Quantity_Sent,
				sum(Quantity_Returned)	as Quantity_Returned
		FROM	#tbl_Result R
		INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(R.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND G.PartNumber=' + LTRIM(STR(@UnitPart)) + '
		GROUP BY R.GoodsID, G.GoodsName  
	) X
	left JOIN prd.tblFormulasDtl D on X.GoodsID=D.GoodsID and  D.ProductID = ''' + @ProductID + '''  
	Left join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
	WHERE ' + @StrWhere +'
	order by isnull(D.DocRowNo, 0 )'

	print @StrSelect;
	exec sp_executesql @StrSelect;
END
GO
