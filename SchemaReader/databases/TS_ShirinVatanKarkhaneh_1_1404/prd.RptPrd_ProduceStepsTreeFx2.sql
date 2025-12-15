USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/09/18
-- Viewed By	 : 
-- Last Modified : 1390/05/02
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_ProduceStepsTreeFx2]
	@SelectedProds	Int = 0,
	@SelectedGoods	Int = 0,
	@SelectedGroup	Int = 0,
	@SelectedStore	Int = 0,
	@GoodsCodeMask1	nvarchar(20) = null,
	@GoodsCodeMask2	nvarchar(20) = null,
	@GoodsCodeMask3	nvarchar(20) = null,
	@GoodsCodeMask4	nvarchar(20) = null,
	@GoodsNameMask1	nvarchar(30) = null,
	@GoodsNameMask2	nvarchar(30) = null,
	@GoodsNameMask3	nvarchar(30) = null,
	@GoodsNameMask4	nvarchar(30) = null,
	@ToDate	char(10) = Null,

	@RepOptions		varchar(10) = '',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarchar(200) = ''
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)
DECLARE @StrWhere1	NVarChar(2000)
DECLARE @StrWhere2	NVarChar(2000)
DECLARE @StrWhere3	NVarChar(2000)
DECLARE @StrWhere4	NVarChar(2000)
DECLARE @StrWhereG	NVarChar(2000)

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

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- where section ----------------------------------------------------------
	set @StrWhere = '(1=1)';

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

	if (@GoodsCodeMask1 is not null)
		set @StrWhere1 = @StrWhere1 + ' and (left(GoodsID, ' + Str(Len(@GoodsCodeMask1)) + ')= ''' + @GoodsCodeMask1 + ''')'
	if (@GoodsCodeMask2 is not null)
		set @StrWhere2 = @StrWhere2 + ' and (left(GoodsID, ' + Str(Len(@GoodsCodeMask2)) + ')= ''' + @GoodsCodeMask2 + ''')'
	if (@GoodsCodeMask3 is not null)
		set @StrWhere3 = @StrWhere3 + ' and (left(GoodsID, ' + Str(Len(@GoodsCodeMask3)) + ')= ''' + @GoodsCodeMask3 + ''')'
	if (@GoodsCodeMask4 is not null)
		set @StrWhere4 = @StrWhere4 + ' and (left(GoodsID, ' + Str(Len(@GoodsCodeMask4)) + ')= ''' + @GoodsCodeMask4 + ''')'

	if (@GoodsNameMask1 is not null)
		set @StrWhere1 = @StrWhere1 + ' and (left(GoodsName, ' + Str(Len(@GoodsNameMask1)) + ')= N''' + @GoodsNameMask1 + ''')'
	if (@GoodsNameMask2 is not null)
		set @StrWhere2 = @StrWhere2 + ' and (left(GoodsName, ' + Str(Len(@GoodsNameMask2)) + ')= N''' + @GoodsNameMask2 + ''')'
	if (@GoodsNameMask3 is not null)
		set @StrWhere3 = @StrWhere3 + ' and (left(GoodsName, ' + Str(Len(@GoodsNameMask3)) + ')= N''' + @GoodsNameMask3 + ''')'
	if (@GoodsNameMask4 is not null)
		set @StrWhere4 = @StrWhere4 + ' and (left(GoodsName, ' + Str(Len(@GoodsNameMask4)) + ')= N''' + @GoodsNameMask4 + ''')'
	
	---------------------------------------------------------------------------
	create table #tbl_Products
	(
		GroupID   varchar(20) collate Arabic_CS_AS null,
		ProductID varchar(20) collate Arabic_CS_AS null
	);

	create table #tbl_Goods1
	(
		GroupID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods2
	(
		GroupID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods3
	(
		GroupID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);
	create table #tbl_Goods4
	(
		GroupID	varchar(20) collate Arabic_CS_AS null,
		GoodsID	varchar(20) collate Arabic_CS_AS null
	);

	create table #tbl_Result
	(
		GroupID		varchar(20) collate Arabic_CS_AS null,
		ProductQty	float,
		GoodsQty1	float,
		GoodsQty2	float,
		GoodsQty3	float,
		GoodsQty4	float,
		SetPoint	float
	);
	-- select section ---------------------------------------------------------
	-- enlist products
	set @StrSelect = '
	insert	into #tbl_Products(GroupID, ProductID)
	select	distinct G.GoodsGroupID, P.GoodsID
	from	inv.tblGoods P
				inner join inv.tblGoodsGroupsGoodsListDtl G on P.GoodsID = G.GoodsID
	where ' + @StrWhere

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Goods1(GroupID, GoodsID)
	select distinct P.GroupID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere1 + ' and substring(G.GoodsID, 3, len(P.ProductID) - 2) = substring(P.ProductID, 3, len(P.ProductID) - 2)

	insert into #tbl_Goods2(GroupID, GoodsID)
	select distinct P.GroupID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere2 + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)

	insert into #tbl_Goods3(GroupID, GoodsID)
	select distinct P.GroupID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere3 + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)

	insert into #tbl_Goods4(GroupID, GoodsID)
	select distinct P.GroupID, G.GoodsID
	from #tbl_Products P, inv.tblGoods G
	where ' + @StrWhere4 + ' and substring(GoodsID, 3, len(ProductID) - 2) = substring(P.ProductID, 3, len(ProductID) - 2)'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	--------------------------------------------------------------
	set @StrWhere = '(D.FiscalYear=' + LTrim(RIGHT(db_name(), 4)) + ') and (D.DocDate <= ''' + @ToDate + ''')'

	if (@SelectedStore > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	set @StrSelect = '
	insert into #tbl_Result
	select GroupID, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0, IsNull(GS.SetPoint, 0) 
	from #tbl_Products P
			left join (select * from inv.tblStorageDocsDtl D where ' + @StrWhere + ') D on P.ProductID = D.GoodsID
			left join inv.tblGoodsStatusDtl GS on GS.GoodsID = P.ProductID
	--where ' + @StrWhere + '
	group by GroupID, GS.SetPoint'

	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	set @StrSelect = '
	insert into #tbl_Result
	select GroupID, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0, 0
	from #tbl_Goods1 G
			left join (select * from inv.tblStorageDocsDtl D where ' + @StrWhere + ') D on G.GoodsID = D.GoodsID
	--where ' + @StrWhere + '
	group by GroupID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select GroupID, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0, 0
	from #tbl_Goods2 G
			left join (select * from inv.tblStorageDocsDtl D where ' + @StrWhere + ') D on G.GoodsID = D.GoodsID
	--where ' + @StrWhere + '
	group by GroupID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select GroupID, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0, 0
	from #tbl_Goods3 G
			left join (select * from inv.tblStorageDocsDtl D where ' + @StrWhere + ') D on G.GoodsID = D.GoodsID
	--where ' + @StrWhere + '
	group by GroupID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Result
	select GroupID, 0, 0, 0, 0, isnull(sum(GoodsQuantity * EnterKind), 0), 0
	from #tbl_Goods4 G
			left join (select * from inv.tblStorageDocsDtl D where ' + @StrWhere + ') D on G.GoodsID = D.GoodsID
	--where ' + @StrWhere + '
	group by GroupID'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	select T.*, GoodsGroupName
	from 
	(
		select	GroupID, 
				sum(ProductQty) ProdcutQty, 
				Sum(GoodsQty1) GoodsQty1, 
				Sum(GoodsQty2) GoodsQty2, 
				Sum(GoodsQty3) GoodsQty3, 
				Sum(GoodsQty4) GoodsQty4,
				Sum(SetPoint) SetPoint
		from	#tbl_Result
		group by GroupID
	) T inner join inv.tblGoodsGroupsDtl G on G.GoodsGroupID = T.GroupID
	order by GroupID
	---------------------------------------------------------------------------
END
GO
