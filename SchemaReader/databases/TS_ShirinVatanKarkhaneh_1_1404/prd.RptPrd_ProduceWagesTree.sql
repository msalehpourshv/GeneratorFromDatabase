USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1389/02/15
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : <لیست دستمزدهای تعریف شده برای تولید یک محصول - پیمایش درختی>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_ProduceWagesTree]
	@ProductID		VarChar(20),
	@ProductQty		float = 1,
	@RepOptions		NVarChar(100) = '1',
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @MyProductID	varchar(20);
DECLARE @MyProductQty	float;
DECLARE @current		int;
--DECLARE @scale			float;
DECLARE @total			int;
DECLARE @CalcBalance	bit;
DECLARE @FirstLayer		bit;
DECLARE @UseGoodsFilter	bit;
BEGIN

	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '1';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @CalcBalance= Substring(@RepOptions, 1, 1);
	set @UseGoodsFilter	= 0;
	set @FirstLayer	= 0;
	
	if (len(@RepOptions) > 1)
		set @UseGoodsFilter	= Substring(@RepOptions, 2, 1);
	if (len(@RepOptions) > 2)
		set @FirstLayer		= Substring(@RepOptions, 3, 1);
	
	---------------------------------------------------------------------------
	-- select section ---------------------------------------------------------
	create table #tbl_RptPrd_ProduceWagesTree_Products
	(
		ProductID	varchar(20) collate arabic_cs_as not null,
		ProductQty	float not null
	);

	create table #tbl_RptPrd_ProduceWagesTree_Result
	(
		GoodsID		varchar(20) collate arabic_cs_as not null,
		WageName	nvarchar(200) not null,
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

	-- enlist 1st layer goods
	insert into #tbl_RptPrd_ProduceWagesTree_Products
	values (@ProductID, @ProductQty)

	set @current = 1;
	select @total = count(*)
	from #tbl_RptPrd_ProduceWagesTree_Products

	-- iterate on products
	declare csr_Products cursor scroll for
		select ProductID, ProductQty
		from #tbl_RptPrd_ProduceWagesTree_Products
	open csr_Products;

	fetch ABSOLUTE @current from csr_Products into @MyProductID, @MyProductQty;
	
	while (@current <= @total)
	begin
		if (@FirstLayer = 1)
		begin
			-- 1- fill Wages
			insert into	#tbl_RptPrd_ProduceWagesTree_Result
			select	D.ProductID,D.WageName,(D.Wage1*@MyProductQty/H.ProductCount),(D.Wage2*@MyProductQty/H.ProductCount),(D.Wage3*@MyProductQty/H.ProductCount),(D.Wage4*@MyProductQty/H.ProductCount),(D.Wage5*@MyProductQty/H.ProductCount),(D.Wage6*@MyProductQty/H.ProductCount),(D.Wage7*@MyProductQty/H.ProductCount),(D.Wage8*@MyProductQty/H.ProductCount),(D.Wage9*@MyProductQty/H.ProductCount),(D.Wage10*@MyProductQty/H.ProductCount)
			from	prd.tblFormulasOverLoadHdr D
						inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo and H.IsDefault = 1
			where	(D.ProductID = @MyProductID)  And (D.OverLoadProduct=1 or (D.OverLoadProduct=0 and OverLoadDecomposition=0))
		end
		else
		begin
			-- 1- fill Wages
			insert into	#tbl_RptPrd_ProduceWagesTree_Result
			select	D.ProductID,D.WageName,(D.Wage1*@MyProductQty/H.ProductCount),(D.Wage2*@MyProductQty/H.ProductCount),(D.Wage3*@MyProductQty/H.ProductCount),(D.Wage4*@MyProductQty/H.ProductCount),(D.Wage5*@MyProductQty/H.ProductCount),(D.Wage6*@MyProductQty/H.ProductCount),(D.Wage7*@MyProductQty/H.ProductCount),(D.Wage8*@MyProductQty/H.ProductCount),(D.Wage9*@MyProductQty/H.ProductCount),(D.Wage10*@MyProductQty/H.ProductCount)
			from	prd.tblFormulasOverLoadHdr D
						inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo and H.IsDefault = 1
			where	(D.ProductID = @MyProductID)   And (D.OverLoadProduct=1 or (D.OverLoadProduct=0 and OverLoadDecomposition=0))

			-- 2- fill unleaf goods into P table
			insert into	#tbl_RptPrd_ProduceWagesTree_Products
			select	D.GoodsID, (D.GoodsQuantity * @MyProductQty / H.ProductCount)
			from	prd.tblFormulasDtl D
						inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo and H.IsDefault = 1
			where	(D.ProductID = @MyProductID) and 
					(D.GoodsID in (select ProductID from prd.tblFormulasHdr))

			-- if cache changed then reset
			If (@@RowCount > 0)
			begin
				close csr_Products;
				open  csr_Products;

				select @total = count(*)
				from #tbl_RptPrd_ProduceWagesTree_Products
			end
		end

		set @current = @current + 1;
		fetch ABSOLUTE @current from csr_Products into @MyProductID, @MyProductQty;
	end
	
	close csr_Products
	deallocate csr_Products

	declare @Sum float;
	select @Sum = isnull(sum(Wage01),0)+isnull(sum(Wage02),0)+isnull(sum(Wage03),0)+isnull(sum(Wage04),0)+isnull(sum(Wage05),0)+isnull(sum(Wage06),0)+isnull(sum(Wage07),0)+isnull(sum(Wage08),0)+isnull(sum(Wage09),0)+isnull(sum(Wage10),0)
	from #tbl_RptPrd_ProduceWagesTree_Result T

	---------------------------------------------------------------------------
	if (@Sum > 0)
	BEGIN
		UPDATE #tbl_RptPrd_ProduceWagesTree_Result
		SET WageName = GoodsID
		WHERE LTRIM(WageName)=''

		select	T.WageName ,
				isnull(sum(Wage01), 0) AS Wage01,
				isnull(sum(Wage02), 0) AS Wage02,
				isnull(sum(Wage03), 0) AS Wage03,
				isnull(sum(Wage04), 0) AS Wage04,
				isnull(sum(Wage05), 0) AS Wage05,
				isnull(sum(Wage06), 0) AS Wage06,
				isnull(sum(Wage07), 0) AS Wage07,
				isnull(sum(Wage08), 0) AS Wage08,
				isnull(sum(Wage09), 0) AS Wage09,
				isnull(sum(Wage10), 0) AS Wage10
		from	#tbl_RptPrd_ProduceWagesTree_Result T
		group by T.WageName
		order by T.WageName
	END
	else
	select	top 1 '' WageName, D.WageAmount*@ProductQty/D.GoodsQuantity AS Wage01, 0 AS Wage02, 0 AS Wage03, 0 AS Wage04,
			0 AS Wage05, 0 AS Wage06, 0 AS Wage07, 0 AS Wage08,	0 AS Wage09, 0 AS Wage10
	from prd.tblProducersWageDtl D
		inner join prd.tblProducersWageHdr H on H.ProducerAcntCode=D.ProducerAcntCode and H.SerialNo=D.SerialNo
	where D.GoodsID = @ProductID
	order by H.DateFrom desc
	
	---------------------------------------------------------------------------
END
GO
