USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/09/15
-- Viewed By	 : 
-- Last Modified : 1389/09/17
-- Last Modifier : Soltani
-- Description   : <مراحل تولید محصولات - درختی 2>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_ProduceStepsTreeEx]
	@SelectedProds	Int = 0,
	@SelectedGoods	Int = 0,
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

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- where section ----------------------------------------------------------
	set @StrWhere = '(1=1)';

	if (@ToDate is null) or (@ToDate = '')
		set @ToDate = '9999/99/99'

	if (@SelectedProds > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'ProductID') 

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
		ProductID varchar(20) collate Arabic_CS_AS null 
	);

	create table #tbl_Goods
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID		varchar(20) collate Arabic_CS_AS null,
		GoodsName	nvarchar(50) 
	);

	create table #tbl_Result
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		GoodsID1	varchar(20) collate Arabic_CS_AS null,
		GoodsID2	varchar(20) collate Arabic_CS_AS null,
		GoodsID3	varchar(20) collate Arabic_CS_AS null,
		GoodsID4	varchar(20) collate Arabic_CS_AS null 
	);
	-- select section ---------------------------------------------------------
	-- enlist products
	set @StrSelect = '
	insert into #tbl_Products
	select Distinct ProductID
	from prd.tblFormulasHdr
	where ' + @StrWhere

	print @StrSelect;
	exec sp_executesql @StrSelect;

	-- iterate on products
	declare csr_Products cursor for
		select ProductID
		from #tbl_Products
	open csr_Products;

	fetch NEXT from csr_Products into @SelectedProduct
	
	while (@@fetch_status = 0)
	begin
		insert into	#tbl_Goods
		select	distinct @SelectedProduct, F.GoodsID, (select GoodsName from inv.tblGoodsDtl G where G.GoodsID = F.GoodsID)
		from	prd.tblFormulasDtl F
		where	(ProductID = @SelectedProduct) and F.GoodsID in (select ProductID from prd.tblFormulasHdr)
		except
		select	ProductID, GoodsID, GoodsName
		from	#tbl_Goods

		-- recursively collect products of current product
		while (@@RowCount > 0)
		begin
			insert into	#tbl_Goods
			select	distinct @SelectedProduct, GoodsID, (select GoodsName from inv.tblGoodsDtl G where G.GoodsID = F.GoodsID)
			from	prd.tblFormulasDtl F
			where	ProductID in (select GoodsID from #tbl_Goods where ProductID = @SelectedProduct) and 
					GoodsID   in (select ProductID from prd.tblFormulasHdr)
			except
			select	ProductID, GoodsID, GoodsName
			from	#tbl_Goods
		end

		fetch NEXT from csr_Products into @SelectedProduct
	end
	
	close csr_Products
	deallocate csr_Products

	-- select 4 goods per product
	set @StrSelect = '
	insert into #tbl_Result
	select distinct ProductID, 
		(	
			select Top 1 GoodsID 
			from #tbl_Goods G1 
			where (G1.ProductID = P.ProductID) and ' + @StrWhere1 + '
		) GoodsID1,
		(
			select Top 1 GoodsID 
			from #tbl_Goods G2 
			where (G2.ProductID = P.ProductID) and ' + @StrWhere2 + '
		) GoodsID2,
		(
			select Top 1 GoodsID 
			from #tbl_Goods G3 
			where (G3.ProductID = P.ProductID) and ' + @StrWhere3 + '
		) GoodsID3,
		(
			select Top 1 GoodsID 
			from #tbl_Goods G4 
			where (G4.ProductID = P.ProductID) and ' + @StrWhere4 + '
		) GoodsID4
	from #tbl_Goods P '

	print @StrSelect;
	exec sp_executesql @StrSelect;

	-- calc balances
	select GoodsID, isnull(sum(GoodsQuantity * EnterKind), 0) Balance
	into #tbl_Balances
	from inv.tblStorageDocsDtl
	where (PhysicallyEffected = 1) and (DocDate <= @ToDate) and GoodsID in 
		(
			select distinct GoodsID 
			from #tbl_Result 
			union 
			select 
			distinct ProductID 
			from #tbl_Result
		)
	group by GoodsID 

	-- join result with balance table
	select A.*, [pub].[funGetGoodsName](A.ProductID, @LangID) As ProductName, IsNull(GS.SetPoint, 0) AS SetPoint,
			isnull(B0.Balance, 0) Balance, 
			isnull(B1.Balance, 0) Balance1, 
			isnull(B2.Balance, 0) Balance2, 
			isnull(B3.Balance, 0) Balance3, 
			isnull(B4.Balance, 0) Balance4
	from #tbl_Result A
		left join #tbl_Balances B0 on B0.GoodsID = A.ProductID
		left join #tbl_Balances B1 on B1.GoodsID = A.GoodsID1
		left join #tbl_Balances B2 on B2.GoodsID = A.GoodsID2
		left join #tbl_Balances B3 on B3.GoodsID = A.GoodsID3
		left join #tbl_Balances B4 on B4.GoodsID = A.GoodsID4
		left join inv.tblGoodsStatusDtl GS on GS.GoodsID = A.ProductID
	order by ProductID, GoodsID1, GoodsID2, GoodsID3, GoodsID4
	---------------------------------------------------------------------------
END
GO
