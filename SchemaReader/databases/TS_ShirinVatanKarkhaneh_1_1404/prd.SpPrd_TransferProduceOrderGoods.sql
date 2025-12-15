USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/01/25
-- Viewed By	 : 
-- Last Modified : 1390/05/04
-- Last Modifier : TakroSystem\Zia
-- Description	 : برای تولید مواد اولیه جهت انتقال کالا
-- ==============================================
Create PROCEDURE [prd].[SpPrd_TransferProduceOrderGoods]
	@POProcessID	int = 600, 
	@POProcessNo	int = 1, 
	@POFiscalYear	int = 0, 
	@POSerialNo		int = 0, 
	@DateTo			char(10) = null,
	@StoreIDFr		varchar(20) = null,
	@StoreIDTo		varchar(20) = null,
	@RepOptions		varchar(10) = '1',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare	@LangID		char(1);
declare	@SessionNo	int; 
declare	@ReportID	int; 
declare	@UserID		int; 
declare	@ObjectID	int;
declare	@FormulaNo	int;
declare @DebugMode	bit;
declare @UseDefaultFormula	int;

declare @MyProductID	varchar(20);
declare @MyProductQty	float;

declare @StrSelect	nvarchar(max);
declare @StrWhere	nvarchar(max);
declare @BaseGoods	bit;
DECLARE @intGoods int 
DECLARE @DocRowNo int 

Begin
	set NOCOUNT ON;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	set @BaseGoods	= pub.funSplitString(@RepInfo, '@', 6);
	set @DocRowNo	= pub.funSplitString(@RepInfo, '@', 7);

	set @ObjectID	= 10;

	set @StrSelect	= '';
	set @StrWhere	= '';
	set @DebugMode  = 0;
	
	set @UseDefaultFormula = substring(@RepOptions, 1, 1);
 
	select top 1 @UseDefaultFormula = FormulaDefault
		from pln.tblProduceOrderHdr A 
		where	(A.ProcessID    = @POProcessID) 
			and (A.ProcessNo    = @POProcessNo) 
			and (A.FiscalYear   = @POFiscalYear) 
			and (A.SerialNo     = @POSerialNo)
			 
	set @UseDefaultFormula=isnull(@UseDefaultFormula,0	)

	create table #tbl_SemiProducts
	(
		GoodsID		varchar(20) collate arabic_cs_as not null,
		Quantity	float not null
	);
	create table #tbl_LeafGoods
	(
		GoodsID		varchar(20) collate arabic_cs_as not null,
		Quantity	float null,
		StoreID		varchar(20) collate arabic_cs_as not null
	);
	
	-- insert produce order products into slc table

	delete from prd.tblProductSlc where UserID=@UserID and ReportID=@ReportID and ObjectID=@ObjectID

	insert into prd.tblProductSlc(ProductID, UserID, ReportID, ObjectID, Quantity) 
    select ProductID, @UserID, @ReportID, @ObjectID, ProductCount
    from pln.tblProduceOrderDtl A 
    where	(A.ProcessID = @POProcessID) 
		and (A.ProcessNo = @POProcessNo) 
		and (A.FiscalYear = @POFiscalYear) 
		and (A.SerialNo = @POSerialNo)
		and (A.DocRowNo = @DocRowNo)
	
	if (@DebugMode = 1)
	begin
		select * from prd.tblProductSlc	
	end
	-- ==============================================================================
	
	-- produce semi constructed goods
	
	create table #tbl_TempResults
	(
		GoodsID		VarChar(20) collate arabic_cs_as not null,
		Quantity	float	not null  ,
		BaseGoods	bit	not null ,
		StoreID		VarChar(20) collate arabic_cs_as not null
	);
	create table #tbl_Balance
	(
		GoodsID		varchar(20) collate Arabic_CS_AS  Not Null, 
		Quantity	float Not Null
	);	

	declare csr_Products cursor for
		select ProductID, Quantity
		from prd.tblProductSlc
		where (UserID = @UserID) and (ReportID = @ReportID) 
	open csr_Products;

	fetch NEXT from csr_Products into @MyProductID, @MyProductQty;
	
	while (@@fetch_status = 0)
	begin

		select top 1 @FormulaNo = FormulaNo
			from pln.tblProduceOrderDtl A 
			where	(A.ProcessID    = @POProcessID) 
				and (A.ProcessNo    = @POProcessNo) 
				and (A.FiscalYear   = @POFiscalYear) 
				and (A.SerialNo     = @POSerialNo)
				and (A.ProductID    = @MyProductID)
				and (A.ProductCount = @MyProductQty)
				and (A.DocRowNo = @DocRowNo)		
---------------------------------------------------------------
-- برای جلوگیری از انتخاب دوتا فرمول برای یک محصول حالت پیش فرض و شماره فرمول انتخابی
		select * into #FormulasHdr
		from prd.tblFormulasHdr
		where SerialNo = @FormulaNo

		insert  into #FormulasHdr 
		select * 
		from prd.tblFormulasHdr
		where IsDefault = 1 and ProductID not in (select ProductID from  #FormulasHdr)
---------------------------------------------------------------
		if (@UseDefaultFormula = 1) 
			set @StrWhere = '((H.IsDefault = 1) or (H.SerialNo = ' + Ltrim(STR(@FormulaNo)) + ')) '
		else if (@UseDefaultFormula = 2) 
			set  @StrWhere = '(H.SerialNo = ' + Ltrim(STR(@FormulaNo)) + ')'
		else if (@UseDefaultFormula = 3) 
			set @StrWhere = '(H.IsDefault = 1) '
		else if (@UseDefaultFormula = 4) 
			set @StrWhere = '(H.SerialNo = ' + Ltrim(STR(@FormulaNo)) + ')'
		
		if  @BaseGoods='True'				
			set @StrSelect = '
			WITH tblTemp(ProductID, GoodsID, Quantity, BaseGoods,StoreID) AS
			(
				select	H.ProductID, D.GoodsID, ((' + LTrim(Str(@MyProductQty)) + ' / H.ProductCount) * D.GoodsQuantity) As Quantity, BaseGoods, D.DefaultStoreID
				from	prd.tblFormulasDtl D
							inner join #FormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID 
				where  (H.ProductID = ''' + @MyProductID + ''') AND ' + @StrWhere + '

				union all
			
				select	H.ProductID, D.GoodsID, ((tblTemp.Quantity / H.ProductCount) * D.GoodsQuantity) As Quantity, D.BaseGoods, D.DefaultStoreID
				from	prd.tblFormulasDtl D
							inner join #FormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID, tblTemp
				where  (H.ProductID = tblTemp.GoodsID) AND ' + @StrWhere + ' and  tblTemp.BaseGoods=''True''
			)
			insert into #tbl_TempResults
			select	T.GoodsID, isnull(Sum(Quantity), 0) as Quantity,BaseGoods,StoreID
			from	tblTemp T  where  BaseGoods=1 
			group BY T.GoodsID ,BaseGoods ,StoreID'
	else		
		set @StrSelect = '
		WITH tblTemp(ProductID, GoodsID, Quantity, BaseGoods,StoreID) AS
		(
			select	H.ProductID, D.GoodsID, ((' + LTrim(Str(@MyProductQty)) + ' / H.ProductCount) * D.GoodsQuantity) As Quantity, 0, D.DefaultStoreID
			from	prd.tblFormulasDtl D
						inner join #FormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID 
			where  (H.ProductID = ''' + @MyProductID + ''') AND ' + @StrWhere + '

			union all
			
			select	H.ProductID, D.GoodsID, ((tblTemp.Quantity / H.ProductCount) * D.GoodsQuantity) As Quantity,0, D.DefaultStoreID
			from	prd.tblFormulasDtl D
						inner join #FormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID, tblTemp
			where  (H.ProductID = tblTemp.GoodsID) AND ' + @StrWhere + '
		)
		insert into #tbl_TempResults
		select	T.GoodsID, isnull(Sum(Quantity), 0) as Quantity,0,StoreID
		from	tblTemp T
		group BY T.GoodsID,StoreID '
 
		print @StrSelect
		exec sp_executesql @StrSelect;
		fetch NEXT from csr_Products into @MyProductID, @MyProductQty;
	end

	close csr_Products;
	deallocate csr_Products;	
	 
	
	if  @BaseGoods='True'	
		begin
			
			insert into #tbl_SemiProducts(GoodsID, Quantity)
			select GoodsID, SUM(Quantity)
			from #tbl_TempResults R	
			group by GoodsID
		
			insert into #tbl_LeafGoods(GoodsID, Quantity,StoreID)
			select GoodsID, SUM(Quantity),''
			from #tbl_TempResults R
			group by GoodsID
	  

			set @StrWhere = '(D.GoodsID in (select GoodsID from #tbl_TempResults))'

			if (@StoreIDFr is not null) and (@StoreIDFr <> '') and (@StoreIDFr <> '0')
				set @StrWhere = @StrWhere + ' and (D.StoreID  = ''' + @StoreIDFr + ''')'
			if (@DateTo is not null)
				set @StrWhere = @StrWhere + ' and (D.DocDate <= ''' + @DateTo    + ''')'

			set @StrSelect = '
			insert into #tbl_Balance(GoodsID, Quantity)
			select	D.GoodsID, isnull(sum(D.GoodsQuantity * D.EnterKind), 0)
			from	inv.tblStorageDocsDtl D
			where	' + @StrWhere + '
			group by D.GoodsID'

			print @StrSelect;
			exec sp_executesql @StrSelect;
	
			-- ==================================================================================
			--select * from  #tbl_SemiProducts
			--select * from  #tbl_Balance
			-- drop extra tables
			Drop Table #tbl_SemiProducts
			Drop Table #tbl_TempResults
		
			-- ==================================================================================
			
			Select @intGoods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
			From pub.tblCodeLayer 
			Where TableName='inv.tblGoods' AND PartNumber=1

			Select L.GoodsID, IsNull(L.Quantity,0) Quantity, IsNull(B.Quantity,0) Balance, [pub].[funGetGoodsName](L.GoodsID, @LangID) As GoodsName, 
				   UD.UnitID, UD.UnitName
			From #tbl_LeafGoods L
				inner join inv.tblGoods		G ON G.GoodsID	= LEFT(L.GoodsID,@intGoods)
				inner join inv.tblUnitsDtl UD ON UD.UnitID	= G.UnitID  
				left  join #tbl_Balance B on L.GoodsID = B.GoodsID		
		return
	end

	insert into #tbl_SemiProducts(GoodsID, Quantity)
	select GoodsID, SUM(Quantity)
	from #tbl_TempResults R
	where (R.GoodsID in (select ProductID from #FormulasHdr))
	group by GoodsID

	-- ==================================================================================
	
	-- fill products & semi-products into slc
	
	delete from prd.tblProductSlc 
	where (UserID = @UserID) and (ReportID = @ReportID) and (ObjectID = @ObjectID)

	insert into prd.tblProductSlc(ProductID, UserID, ReportID, ObjectID, Quantity)
	-- semi-products
	select A.GoodsID, @UserID, @ReportID, @ObjectID, A.Quantity
	from #tbl_SemiProducts A
	 union all 
	-- main products
    select A.ProductID, @UserID, @ReportID, @ObjectID, A.ProductCount
    from pln.tblProduceOrderDtl A
    where	(A.ProcessID  = @POProcessID) 
		and (A.ProcessNo  = @POProcessNo) 
		and (A.FiscalYear = @POFiscalYear) 
		and (A.SerialNo   = @POSerialNo)
		and (A.DocRowNo = @DocRowNo)

	if (@DebugMode = 1)
	begin
		select * from prd.tblProductSlc	
	end
	
	-- ==================================================================================

	-- find leaf nodes of products & semi-products (exists in slc)
	
	delete from #tbl_TempResults
	
	declare csr_Products cursor for
		select ProductID, Quantity
		from prd.tblProductSlc
		where (UserID = @UserID) and (ReportID = @ReportID) and (ObjectID = @ObjectID)
	open csr_Products;

	fetch NEXT from csr_Products into @MyProductID, @MyProductQty;
	
	while (@@fetch_status = 0)
	begin
		select top 1 @FormulaNo = FormulaNo
			from pln.tblProduceOrderDtl A 
			where	(A.ProcessID    = @POProcessID) 
				and (A.ProcessNo    = @POProcessNo) 
				and (A.FiscalYear   = @POFiscalYear) 
				and (A.SerialNo     = @POSerialNo)
				and (A.ProductID    = @MyProductID)
				and (A.ProductCount = @MyProductQty)
				and (A.DocRowNo = @DocRowNo)		

		if (@UseDefaultFormula = 1) 
			set @StrWhere = '((H.IsDefault = 1) or (H.SerialNo = ' + Ltrim(STR(@FormulaNo)) + ')) '
		else if (@UseDefaultFormula = 2) 
			set  @StrWhere = '(H.SerialNo = ' + Ltrim(STR(@FormulaNo)) + ')'
		else if (@UseDefaultFormula = 3) 
			set @StrWhere = '(H.IsDefault = 1) '
		else if (@UseDefaultFormula = 4) 
			set @StrWhere = '(H.SerialNo = ' + Ltrim(STR(@FormulaNo)) + ')'
			
		set @StrSelect = '
		insert  into #tbl_TempResults
		select	D.GoodsID, ((' + LTrim(Str(@MyProductQty)) + ' / H.ProductCount) * D.GoodsQuantity) as Quantity,BaseGoods, D.DefaultStoreID
		from	prd.tblFormulasDtl D
					inner join #FormulasHdr H on D.SerialNo = H.SerialNo and D.ProductID = H.ProductID
		where  (H.ProductID = ''' + @MyProductID + ''') and ' + @StrWhere 

		print @StrSelect
		exec sp_executesql @StrSelect;
		fetch NEXT from csr_Products into @MyProductID, @MyProductQty;
	end

	close csr_Products;
	deallocate csr_Products;	
	
	insert into #tbl_LeafGoods(GoodsID, Quantity,StoreID)
	select GoodsID, SUM(Quantity),StoreID
	from #tbl_TempResults R
	where (R.GoodsID not in (select ProductID from #FormulasHdr))
	group by GoodsID,StoreID

	-- ==================================================================================

	-- decrease amount of previous transfer
	
	update #tbl_LeafGoods
	set Quantity = Quantity -
		isnull((
			select sum(GoodsQuantity) 
			from inv.tblStorageDocsDtl 
			where   (ProcessID = 120) 
				and (BaseProcessID  = @POProcessID) 
				and (BaseProcessNo  = @POProcessNo) 
				and (BaseFiscalYear = @POFiscalYear) 
				and (BaseSerialNo   = @POSerialNo)
				and (GoodsID        = #tbl_LeafGoods.GoodsID)), 0)
				
	-- =================================================================================

	-- fault tolerance options
	
	update #tbl_LeafGoods
	set Quantity = 0
	where Quantity is null
	
	-- ==================================================================================
	
	-- calc goods balance
	
	set @StrWhere = '(D.GoodsID in (select GoodsID from #tbl_TempResults))'

	if (@StoreIDFr is not null) and (@StoreIDFr <> '') and (@StoreIDFr <> '0')
		set @StrWhere = @StrWhere + ' and (D.StoreID  = ''' + @StoreIDFr + ''')'
	if (@DateTo is not null)
		set @StrWhere = @StrWhere + ' and (D.DocDate <= ''' + @DateTo    + ''')'

	set @StrSelect = '
	insert into #tbl_Balance(GoodsID, Quantity)
	select	D.GoodsID, isnull(sum(D.GoodsQuantity * D.EnterKind), 0)
	from	inv.tblStorageDocsDtl D
	where	' + @StrWhere + '
	group by D.GoodsID'

	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	-- ==================================================================================
	-- drop extra tables
	Drop Table #tbl_SemiProducts
	Drop Table #tbl_TempResults
		
	-- ==================================================================================

	Select @intGoods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	From pub.tblCodeLayer 
	Where TableName='inv.tblGoods' AND PartNumber=1



	Select L.GoodsID, IsNull(L.Quantity,0) Quantity, IsNull(B.Quantity,0) Balance, [pub].[funGetGoodsName](L.GoodsID, @LangID) As GoodsName, 
		   UD.UnitID, UD.UnitName,StoreID
	From #tbl_LeafGoods L
		inner join inv.tblGoods		G ON G.GoodsID	= LEFT(L.GoodsID,@intGoods)
		inner join inv.tblUnitsDtl UD ON UD.UnitID	= G.UnitID  
		left  join #tbl_Balance B on L.GoodsID = B.GoodsID		
	
	-- ==================================================================================

END
GO
