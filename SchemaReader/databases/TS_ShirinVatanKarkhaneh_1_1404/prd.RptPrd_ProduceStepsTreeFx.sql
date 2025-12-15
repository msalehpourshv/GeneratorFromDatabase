USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/09/18
-- Viewed By	 : 
-- Last Modified : 1390/04/30
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_ProduceStepsTreeFx]
	@SelectedProds	Int = 0,
	@SelectedGoods	Int = 0,
	@SelectedGroup	Int = 0,
	@SelectedStore	Int = 0,
	@GoodsCodeMask1	nvarchar(20) = null,
	@GoodsCodeMask2	nvarchar(20) = null,
	@GoodsCodeMask3	nvarchar(20) = null,
	@GoodsCodeMask4	nvarchar(20) = null,
	@GoodsCodeMask5	nvarchar(20) = null,
	@GoodsCodeMask6	nvarchar(20) = null,
	@GoodsCodeMask7	nvarchar(20) = null,
	@GoodsCodeMask8	nvarchar(20) = null,
	@GoodsCodeMask9	nvarchar(20) = null,
	@GoodsCodeMaskA	nvarchar(20) = null,
	@ToDate			char(10) = Null,
	@DiffFr			float = Null,
	@DiffTo			float = Null,
	@RepOptions		varchar(10) = '',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarchar(200) = ''
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @StrWhere1	NVarChar(max)
DECLARE @StrWhere2	NVarChar(max)
DECLARE @StrWhere3	NVarChar(max)
DECLARE @StrWhere4	NVarChar(max)
DECLARE @StrWhere5	NVarChar(max)
DECLARE @StrWhere6	NVarChar(max)
DECLARE @StrWhere7	NVarChar(max)
DECLARE @StrWhere8	NVarChar(max)
DECLARE @StrWhere9	NVarChar(max)
DECLARE @StrWhereA	NVarChar(max)
DECLARE @StrWhereG	NVarChar(max)
DECLARE @StrWhereS	NVarChar(max)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @SelectedProduct varchar(20);
BEGIN

	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';
	if (@SelectedProds	Is Null)	set @SelectedProds = 0;
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;
	if (@SelectedStore	Is Null)	set @SelectedStore = 0;
	if (@GoodsCodeMask1	= '')	set @GoodsCodeMask1 = '##';
	if (@GoodsCodeMask2	= '')	set @GoodsCodeMask2 = '##';
	if (@GoodsCodeMask3	= '')	set @GoodsCodeMask3 = '##';
	if (@GoodsCodeMask4	= '')	set @GoodsCodeMask4 = '##';
	if (@GoodsCodeMask5	= '')	set @GoodsCodeMask5 = '##';
	if (@GoodsCodeMask6	= '')	set @GoodsCodeMask6 = '##';
	if (@GoodsCodeMask7	= '')	set @GoodsCodeMask7 = '##';
	if (@GoodsCodeMask8	= '')	set @GoodsCodeMask8 = '##';
	if (@GoodsCodeMask9	= '')	set @GoodsCodeMask9 = '##';
	if (@GoodsCodeMaskA	= '')	set @GoodsCodeMaskA = '##';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- where section ----------------------------------------------------------
	set @StrWhere = '(1=1)';
	set @StrWhereS = '(1=1)';

	if (@ToDate is null) or (@ToDate = '')
		set @ToDate = '9999/99/99'

	if (@SelectedProds > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'P.GoodsID') 

	if (@SelectedGroup > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGroup, 'G.GoodsGroupID') 

	if (@SelectedGoods > 0) 
		set @StrWhere1 =  pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'GoodsID')
	else
		set @StrWhere1 = '(1=1)'

	set @StrWhere2 = @StrWhere1
	set @StrWhere3 = @StrWhere1
	set @StrWhere4 = @StrWhere1
	set @StrWhere5 = @StrWhere1
	set @StrWhere6 = @StrWhere1
	set @StrWhere7 = @StrWhere1
	set @StrWhere8 = @StrWhere1
	set @StrWhere9 = @StrWhere1
	set @StrWhereA = @StrWhere1

	if (@GoodsCodeMask1 is not null) 
		set @StrWhere1 = @StrWhere1 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask1))) + ')= ''' + @GoodsCodeMask1 + ''')'
	if (@GoodsCodeMask2 is not null) 
		set @StrWhere2 = @StrWhere2 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask2))) + ')= ''' + @GoodsCodeMask2 + ''')'
	if (@GoodsCodeMask3 is not null) 
		set @StrWhere3 = @StrWhere3 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask3))) + ')= ''' + @GoodsCodeMask3 + ''')'
	if (@GoodsCodeMask4 is not null) 
		set @StrWhere4 = @StrWhere4 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask4))) + ')= ''' + @GoodsCodeMask4 + ''')'
	if (@GoodsCodeMask5 is not null) 
		set @StrWhere5 = @StrWhere5 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask5))) + ')= ''' + @GoodsCodeMask5 + ''')'
	if (@GoodsCodeMask6 is not null) 
		set @StrWhere6 = @StrWhere6 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask6))) + ')= ''' + @GoodsCodeMask6 + ''')'
	if (@GoodsCodeMask7 is not null) 
		set @StrWhere7 = @StrWhere7 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask7))) + ')= ''' + @GoodsCodeMask7 + ''')'
	if (@GoodsCodeMask8 is not null) 
		set @StrWhere8 = @StrWhere8 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask8))) + ')= ''' + @GoodsCodeMask8 + ''')'
	if (@GoodsCodeMask9 is not null) 
		set @StrWhere9 = @StrWhere9 + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMask9))) + ')= ''' + @GoodsCodeMask9 + ''')'
	if (@GoodsCodeMaskA is not null) 
		set @StrWhereA = @StrWhereA + ' and (left(GoodsID, ' + LTrim(Str(Len(@GoodsCodeMaskA))) + ')= ''' + @GoodsCodeMaskA + ''')'

	---------------------------------------------------------------------------
	create table #tbl_Products
	(
		ProductID varchar(20) collate Arabic_CS_AS null
	);

	create table #tbl_Goods1
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods2
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods3
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods4
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods5
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods6
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods7
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods8
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods9
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_GoodsA
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);

	create table #tbl_Result
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		ProductQty	float,
		GoodsQty1	float,
		GoodsQty2	float,
		GoodsQty3	float,
		GoodsQty4	float,
		GoodsQty5	float,
		GoodsQty6	float,
		GoodsQty7	float,
		GoodsQty8	float,
		GoodsQty9	float,
		GoodsQtyA	float
	);
	-- select section ---------------------------------------------------------
	-- enlist products
	if (@SelectedGroup > 0) 
		set @StrSelect = '
		insert	into #tbl_Products(ProductID)
		select	distinct P.GoodsID
		from	inv.tblGoods P
					left join inv.tblGoodsGroupsGoodsListDtl G on P.GoodsID = G.GoodsID
		where ' + @StrWhere
	else
		set @StrSelect = '
		insert	into #tbl_Products(ProductID)
		select	distinct P.GoodsID
		from	inv.tblGoods P
		where ' + @StrWhere

	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	set @StrSelect = '
	insert into #tbl_Goods1(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere1 + ' and substring(G.GoodsID, 3, len(P.ProductID) - 2) = substring(P.ProductID, 3, len(P.ProductID) - 2)

	insert into #tbl_Goods2(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere2 + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)

	insert into #tbl_Goods3(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere3 + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)

	insert into #tbl_Goods4(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere4 + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)

	insert into #tbl_Goods5(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere5 + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)

	insert into #tbl_Goods6(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere6 + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)

	insert into #tbl_Goods7(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere7 + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)

	insert into #tbl_Goods8(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere8 + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)

	insert into #tbl_Goods9(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere9 + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)

	insert into #tbl_GoodsA(ProductID, GoodsID)
	select distinct P.ProductID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhereA + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	--------------------------------------------------------------
	set @StrWhere = '(D.FiscalYear=' + LTrim(RIGHT(db_name(), 4)) + ') and (D.DocDate <= ''' + @ToDate + ''')'

	if (@SelectedStore > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	set @StrSelect = '
	insert into #tbl_Result
	select ProductID, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	from #tbl_Products P
			inner join inv.tblStorageDocsDtl D on P.ProductID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	set @StrSelect = '
	insert into #tbl_Result
	select ProductID, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0, 0, 0, 0, 0
	from #tbl_Goods1 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select ProductID, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0, 0, 0, 0
	from #tbl_Goods2 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select ProductID, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0, 0, 0
	from #tbl_Goods3 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select ProductID, 0, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0, 0
	from #tbl_Goods4 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select ProductID, 0, 0, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, 0
	from #tbl_Goods5 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select ProductID, 0, 0, 0, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0
	from #tbl_Goods6 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select ProductID, 0, 0, 0, 0, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0
	from #tbl_Goods7 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select ProductID, 0, 0, 0, 0, 0, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0
	from #tbl_Goods8 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select ProductID, 0, 0, 0, 0, 0, 0, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0
	from #tbl_Goods9 G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select ProductID, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0)
	from #tbl_GoodsA G
			inner join inv.tblStorageDocsDtl D on G.GoodsID = D.GoodsID
	where ' + @StrWhere + '
	group by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	if (@SelectedStore > 0)
		set @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	set @StrSelect = '
	select T.*, [pub].[funGetGoodsName](T.ProductID, ' + Ltrim(RTrim(@LangID)) + ') As GoodsName, IsNull(GS.SetPoint, 0) AS SetPoint
	from 
	(
		select	ProductID, 
				sum(ProductQty) ProdcutQty, 
				Sum(GoodsQty1) GoodsQty1, 
				Sum(GoodsQty2) GoodsQty2, 
				Sum(GoodsQty3) GoodsQty3, 
				Sum(GoodsQty4) GoodsQty4, 
				Sum(GoodsQty5) GoodsQty5, 
				Sum(GoodsQty6) GoodsQty6, 
				Sum(GoodsQty7) GoodsQty7, 
				Sum(GoodsQty8) GoodsQty8, 
				Sum(GoodsQty9) GoodsQty9, 
				Sum(GoodsQtyA) GoodsQtyA
		from	#tbl_Result
		group by ProductID
	) T 
	--inner join inv.tblGoodsDtl G on G.GoodsID = T.ProductID
		left  join 
		(
			select D.GoodsID, SUM(D.SetPoint) SetPoint 
			from inv.tblGoodsStatusDtl D
			where ' + @StrWhereS + '
			group by D.GoodsID
		) GS on GS.GoodsID = T.ProductID 
	'

	set @StrWhere = '(1=1)'
	
	if (@DiffFr	is not null)
		set @StrWhere = @StrWhere + ' and (ProdcutQty+GoodsQty1+GoodsQty2+GoodsQty3+GoodsQty4+GoodsQty5+GoodsQty6+GoodsQty7+GoodsQty8+GoodsQty9+GoodsQtyA-SetPoint >= ' + str(@DiffFr) + ')'
	if (@DiffTo	is not null)
		set @StrWhere = @StrWhere + ' and (ProdcutQty+GoodsQty1+GoodsQty2+GoodsQty3+GoodsQty4+GoodsQty5+GoodsQty6+GoodsQty7+GoodsQty8+GoodsQty9+GoodsQtyA-SetPoint <= ' + str(@DiffTo) + ')'

	set @StrSelect = '
	select *
	from (' + @StrSelect + ') X
	where ' + @StrWhere + '
	order by ProductID'

	print @StrSelect;
	exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
