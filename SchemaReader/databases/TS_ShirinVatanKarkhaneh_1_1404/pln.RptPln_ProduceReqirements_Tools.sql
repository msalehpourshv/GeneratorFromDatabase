USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/01/14
-- Viewed By	 : 
-- Last Modified : 1389/04/16
-- Last Modifier : TakroSystem\Zia
-- Description	 : امکان سنجی بر اساس دستاهها
-- ==============================================
CREATE PROCEDURE [pln].[RptPln_ProduceReqirements_Tools]
	@ProcSetFr		VarChar(20) = Null,
	@ProcSetTo		VarChar(20) = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SelectedGoods	int = 0,
	@SelectedDepart	int = 0,
	@HoursPerDay	float = Null,
	@TelorancePrcnt	float = 0.0,
	@RepOptions		VarChar(10) = '1',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare @StrSelect	nvarchar(4000)
declare @StrWhere	nvarchar(4000)
declare @StrFrom	nvarchar(4000)
declare @ProcInfo	nvarchar(500)
declare @GroupInfo	nvarchar(500)

declare	@LangID		char(1);
declare	@SessionNo	Int; 
declare	@ReportID	Int; 

declare	@ProcessID		Int;
declare	@ProcessNo		Int;
declare	@FiscalYearFr	Int;
declare	@SerialNoFr		Int;
declare	@FiscalYearTo	Int;
declare	@SerialNoTo		Int;
declare	@Percentage		float;
declare	@GroupByOrder	Bit;

declare @product_id		varchar(20);
declare @product_qty	float;
declare @process_id		int;
declare @process_no		int;
declare @fiscal_year	int;
declare @serial_no		int;
begin
	SET NOCOUNT ON;

	-- init -------------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '1';
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;
	if (@SelectedDepart	Is Null)	set @SelectedDepart = 0;
	if (@HoursPerDay	Is Null)	set @HoursPerDay = 8.0;
	if (@TelorancePrcnt	Is Null)	set @TelorancePrcnt = 0.0;

	if (@ProcSetFr Is Not Null)
	begin
		set @ProcessID		= pub.funSplitString(@ProcSetFr, '@', 1);
		set @ProcessNo		= pub.funSplitString(@ProcSetFr, '@', 2);
		set @FiscalYearFr	= pub.funSplitString(@ProcSetFr, '@', 3);
		set @SerialNoFr		= pub.funSplitString(@ProcSetFr, '@', 4);
	end

	if (@ProcSetTo Is Not Null)
	begin
		set @ProcessID		= pub.funSplitString(@ProcSetTo, '@', 1);
		set @ProcessNo		= pub.funSplitString(@ProcSetTo, '@', 2);
		set @FiscalYearTo	= pub.funSplitString(@ProcSetTo, '@', 3);
		set @SerialNoTo		= pub.funSplitString(@ProcSetTo, '@', 4);
	end

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @GroupByOrder = Substring(@RepOptions, 1, 1);
	set @Percentage  = (@TelorancePrcnt / 100.0) + 1.0;

	--- WHERE CLAUSE -------------------------------------------------------------------------
	set @StrWhere = '(1 = 1)'

	if (@ProcSetFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (PD.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (PD.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND PD.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	if (@ProcSetTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (PD.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (PD.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND PD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	if (@ProcSetFr Is Not Null) Or (@ProcSetTo Is Not Null)
		if (@ProcessNo > 0)
			set @StrWhere = @StrWhere + ' AND (PD.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')' 

	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'PD.ProductID')

	if (@DocDateFr Is Not Null) 
		set @StrWhere = @StrWhere + ' AND (PH.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo Is Not Null) 
		set @StrWhere = @StrWhere + ' AND (PH.DocDate <= ''' + @DocDateTo + ''')'
	------------------------------------------------------------------------------------------
	-- SELECT CLAUSE -------------------------------------------------------------------------

	-- 1- enlist products from produce orders
	create table #tbl_Products
	(
		process_id	int,
		process_no	int,
		fiscal_year	int,
		serial_no	int,
		product_id	varchar(20)  COLLATE Arabic_CS_AS,
		product_qty float
	);

	if (@GroupByOrder = 1)
	begin
		set @ProcInfo = 'PD.ProcessID, PD.ProcessNo, PD.FiscalYear, PD.SerialNo'
		set @GroupInfo = 'PD.ProcessID, PD.ProcessNo, PD.FiscalYear, PD.SerialNo, PD.ProductID'
	end
	else
	begin
		set @ProcInfo = '0 as ProcessID, 0 as ProcessNo, 0 as FiscalYear, 0 as SerialNo'
		set @GroupInfo = 'PD.ProductID'
	end

	set @StrSelect = '
		insert into #tbl_Products
	    select	' + @ProcInfo + ', PD.ProductID, Sum(PD.ProductCount) as Quantity
		from	pln.tblProduceOrderDtl PD
					inner join pln.tblProduceOrderHdr PH on PH.ProcessID = PD.ProcessID AND PH.ProcessNo = PD.ProcessNo AND PH.FiscalYear = PD.FiscalYear AND PH.SerialNo = PD.SerialNo
		where ' + @StrWhere + '
		group by ' + @GroupInfo

	print @StrSelect;
	exec sp_executesql @StrSelect;

	-- 2- find goods needed accourding to the products formula (product by product)
	create table #tbl_Result
	(
		ProcessID	int,
		ProcessNo	int,
		FiscalYear	int,
		SerialNo	int,
		ProductID	varchar(20)  COLLATE Arabic_CS_AS,
		ProductQty	float,
		GoodsID		varchar(20)  COLLATE Arabic_CS_AS,
		GoodsQty	float
	);

	declare csr_products cursor for
		select *
		from #tbl_Products

	open csr_products

	fetch NEXT from csr_products into @process_id, @process_no, @fiscal_year, @serial_no, @product_id, @product_qty

	while (@@Fetch_Status = 0)
	begin
		-- recursively gathering goods needed in whole formula tree
		with tblTemp(tmp_ProductID, tmp_GoodsID, tmp_Quantity) AS
		(
			select	FH.ProductID, FD.GoodsID, (@product_qty / FH.ProductCount) * FD.GoodsQuantity As Quantity
			from	prd.tblFormulasDtl FD INNER JOIN prd.tblFormulasHdr FH ON FD.SerialNo = FH.SerialNo AND FD.ProductID = FH.ProductID 
			where  (FH.ProductID = @product_id) AND (FH.IsDefault = 1)
			union all
			select	FH.ProductID, FD.GoodsID, (tblTemp.tmp_Quantity / FH.ProductCount) * FD.GoodsQuantity As Quantity
			from	prd.tblFormulasDtl FD INNER JOIN prd.tblFormulasHdr FH ON FD.SerialNo = FH.SerialNo AND FD.ProductID = FH.ProductID, tblTemp
			where  (FH.ProductID = tblTemp.tmp_GoodsID) AND (FH.IsDefault = 1)
		)
		insert into #tbl_Result
		select @process_id, @process_no, @fiscal_year, @serial_no, @product_id, @product_qty, tmp_GoodsID, tmp_Quantity
		from tblTemp

		fetch NEXT from csr_products into @process_id, @process_no, @fiscal_year, @serial_no, @product_id, @product_qty
	end

	close csr_products
	deallocate csr_products 

	-- also add products to goods list
	insert into #tbl_Result(ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, ProductQty, GoodsID, GoodsQty)
	select process_id, process_no, fiscal_year, serial_no, product_id, product_qty, product_id, product_qty
	from #tbl_Products
	
--	select ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, ProductQty, GoodsID, 
--			sum(GoodsQty) GoodsQty,	pub.GetGoodsName(ProductID, 1) PName, pub.GetGoodsName(GoodsID, 1) GName
--	from #tbl_Result
--	group by ProcessID, ProcessNo, FiscalYear, SerialNo, ProductID, ProductQty, GoodsID

	-- join with produce step --------------------------------------------------------------------------
	set @StrWhere = '(1=1)'

	if (@SelectedDepart > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDepart, 'SD.DepartmentID')

	set @StrSelect = '
	SELECT T.*, [pub].[funGetGoodsName](T.ProductID,' + @LangID + ') as ProductName, TL.ToolName, PI.ProcessName, PO.Title
	FROM
	(
		SELECT	M.ProcessID, M.ProcessNo, M.FiscalYear, M.SerialNo, M.ProductID, M.ProductQty, SA.ToolID,
				IsNull(Sum(SD.OperatorCount * M.GoodsQty), 0) OperatorCount,
				IsNull(Sum(SD.LastProduceStepTime * ' + LTrim(Str(@Percentage, 20, 2)) + ' * M.GoodsQty), 0) EffectiveTime
		FROM #tbl_Result M	
			inner join pln.tblProduceStepDtl  SD on SD.ProductID = M.GoodsID
			inner join pln.tblProduceStepHdr  SH on SD.ProductID = SH.ProductID AND SD.SerialNo = SH.SerialNo and SH.IsDefaultMethod = 1
			inner join pln.tblProduceStepAtom SA on SA.ProductID = SD.ProductID AND SA.SerialNo = SD.SerialNo and SA.DocRowNo = SD.DocRowNo AND SA.IsDefaultTool = 1
		WHERE ' + @StrWhere + '
		GROUP BY M.ProcessID, M.ProcessNo, M.FiscalYear, M.SerialNo, M.ProductID, M.ProductQty, SA.ToolID
	) T inner join pln.tblTools TL ON TL.ToolID = T.ToolID 
		left join pub.tblProcess PI ON PI.ProcessID = T.ProcessID AND PI.ProcessNo = T.ProcessNo
   		left join pln.tblProduceOrderHdr PO on PO.ProcessID = T.ProcessID and PO.ProcessNo = T.ProcessNo and PO.FiscalYear = T.FiscalYear and PO.SerialNo = T.SerialNo
	ORDER BY T.ProcessID, T.ProcessNo, T.FiscalYear, T.SerialNo, T.ProductID, T.ProductQty, T.ToolID, T.OperatorCount '

	-- Run ------------------------------------------------------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
end
GO
