USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/08/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =================================================================
CREATE PROCEDURE [pln].[RptPln_ProduceOrder_Analysis_Wages]
	@ProcSet	varchar(20),
	@RepOptions	nvarchar(200) = '111',
	@RepInfo	nvarchar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@UserID		Int; -- برای حالت کدهای انتخابی

DECLARE	@ProductID	varchar(20);
DECLARE	@FormulaNo	int;
DECLARE	@Quantity	float;

declare @ProcessID	as int;
declare @ProcessNo	as int;
declare @FiscalYear as int;
declare @SerialNo	as int;

DECLARE @current	int;
DECLARE @total		int;

BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '';

	SET @ProcessID	= pub.funSplitString(@ProcSet, '@', 1);
	SET @ProcessNo	= pub.funSplitString(@ProcSet, '@', 2);
	SET @FiscalYear	= pub.funSplitString(@ProcSet, '@', 3);
	SET @SerialNo	= pub.funSplitString(@ProcSet, '@', 4);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	create table #tblPln_ProduceOrder_Analysis_Wages_Prods
	(
		ProductID	varchar(20) collate arabic_cs_as not null,
		Quantity	float not null,
		FormulaNo	int not null
	);
	
	create table #tblPln_ProduceOrder_Analysis_Wages_Result
	(
		GoodsID		varchar(20) collate arabic_cs_as not null,
		Wage01		float not null,
		Wage02		float not null,
		Wage03		float not null,
		Wage04		float not null,
		Wage05		float not null,
		Wage06		float not null,
		Wage07		float not null,
		Wage08		float not null,
		Wage09		float not null,
		Wage10		float not null
	);

	-- enlist 1st layer products --
	 insert into #tblPln_ProduceOrder_Analysis_Wages_Prods(ProductID, Quantity, FormulaNo) 
	 select O.ProductID, O.ProductCount, O.FormulaNo 
	 from pln.tblProduceOrderDtl O
		inner join prd.tblFormulasHdr H ON H.ProductID = O.ProductID 
	 where	(O.ProcessID = @ProcessID) and (O.ProcessNo = @ProcessNo) and (O.FiscalYear = @FiscalYear) and (O.SerialNo = @SerialNo) and
			((O.FormulaNo = 0 and H.IsDefault = 1) Or (O.FormulaNo <> 0 and H.SerialNo = O.FormulaNo))

	-------------------------------------------------
	set @current = 1;
	select @total = count(*)
	from #tblPln_ProduceOrder_Analysis_Wages_Prods

	-- iterate on products
	declare csr_Products cursor scroll for
		select ProductID, Quantity, FormulaNo
		from #tblPln_ProduceOrder_Analysis_Wages_Prods
	open csr_Products;

	fetch ABSOLUTE @current from csr_Products into @ProductID, @Quantity, @FormulaNo;
	
	while (@current <= @total)
	begin
		-- 1- fill Wages
		insert into	#tblPln_ProduceOrder_Analysis_Wages_Result
		select	D.ProductID, (D.Wage1*@Quantity/H.ProductCount), (D.Wage2*@Quantity/H.ProductCount), (D.Wage3*@Quantity/H.ProductCount), (D.Wage4*@Quantity/H.ProductCount), (D.Wage5*@Quantity/H.ProductCount), (D.Wage6*@Quantity/H.ProductCount), (D.Wage7*@Quantity/H.ProductCount), (D.Wage8*@Quantity/H.ProductCount), (D.Wage9*@Quantity/H.ProductCount), (D.Wage10*@Quantity/H.ProductCount)
		from	prd.tblFormulasOverLoadHdr D
					inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo
		where	(D.ProductID = @ProductID) And (OverLoadProduct=1 or (OverLoadProduct=0 and OverLoadDecomposition=0))
				and ((@FormulaNo = 0 and H.IsDefault = 1) Or (@FormulaNo <> 0 and H.SerialNo = @FormulaNo))

		-- 2- fill unleaf goods into P table
		insert into	#tblPln_ProduceOrder_Analysis_Wages_Prods
		select	D.GoodsID, (D.GoodsQuantity * @Quantity / H.ProductCount), @FormulaNo
		from	prd.tblFormulasDtl D
					inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo
		where	(D.ProductID = @ProductID) 
				and ((@FormulaNo = 0 and H.IsDefault = 1) Or (@FormulaNo <> 0 and H.SerialNo = @FormulaNo))
				and (D.GoodsID in (select ProductID from prd.tblFormulasHdr))

		-- if cache changed then reset
		If (@@RowCount > 0)
		begin
			close csr_Products;
			open  csr_Products;

			select @total = count(*)
			from #tblPln_ProduceOrder_Analysis_Wages_Prods
		end

		set @current = @current + 1;
		fetch ABSOLUTE @current from csr_Products into @ProductID, @Quantity, @FormulaNo;
	end
	
	close csr_Products
	deallocate csr_Products

	---------------------------------------------------------------------------
	select	isnull(sum(Wage01), 0) AS Wage01,
			isnull(sum(Wage02), 0) AS Wage02,
			isnull(sum(Wage03), 0) AS Wage03,
			isnull(sum(Wage04), 0) AS Wage04,
			isnull(sum(Wage05), 0) AS Wage05,
			isnull(sum(Wage06), 0) AS Wage06,
			isnull(sum(Wage07), 0) AS Wage07,
			isnull(sum(Wage08), 0) AS Wage08,
			isnull(sum(Wage09), 0) AS Wage09,
			isnull(sum(Wage10), 0) AS Wage10
	from	#tblPln_ProduceOrder_Analysis_Wages_Result T
END
GO
