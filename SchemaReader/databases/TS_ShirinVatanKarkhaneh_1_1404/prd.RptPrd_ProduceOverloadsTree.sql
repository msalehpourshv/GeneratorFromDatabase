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
-- Description   : <لیست سربارهای تعریف شده برای تولید یک محصول - پیمایش درختی>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_ProduceOverloadsTree]
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
	create table #tbl_RptPrd_ProduceOversTree_Products
	(
		ProductID	varchar(20) collate arabic_cs_as not null,
		ProductQty	float not null
	);

	create table #tbl_RptPrd_ProduceOversTree_Result
	(
		AcntCode	varchar(20) collate arabic_cs_as not null,
		Amount		float not null
	);

	-- enlist 1st layer goods
	insert into #tbl_RptPrd_ProduceOversTree_Products
	values (@ProductID, @ProductQty)

	set @current = 1;
	select @total = count(*)
	from #tbl_RptPrd_ProduceOversTree_Products

	-- iterate on products
	declare csr_Products cursor scroll for
		select ProductID, ProductQty
		from #tbl_RptPrd_ProduceOversTree_Products
	open csr_Products;

	fetch ABSOLUTE @current from csr_Products into @MyProductID, @MyProductQty;
	
	while (@current <= @total)
	begin
		if (@FirstLayer = 1)
		begin
			-- 1- fill Overloads
			insert into	#tbl_RptPrd_ProduceOversTree_Result
			select	D.OverLoadAcntCode,(D.OverLoadAmount * @MyProductQty / H.ProductCount)
			from	prd.tblFormulasOverLoadDtl D
						inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo and H.IsDefault = 1
			where	(D.ProductID = @MyProductID) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and OverLoadDecompositionDtl=0))			
		end
		else
		begin
			-- 1- fill Overloads
			insert into	#tbl_RptPrd_ProduceOversTree_Result
			select	D.OverLoadAcntCode,(D.OverLoadAmount * @MyProductQty / H.ProductCount)
			from	prd.tblFormulasOverLoadDtl D
						inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo and H.IsDefault = 1
			where	(D.ProductID = @MyProductID) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and OverLoadDecompositionDtl=0))

			-- 2- fill unleaf goods into P table
			insert into	#tbl_RptPrd_ProduceOversTree_Products
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
				from #tbl_RptPrd_ProduceOversTree_Products
			end
		end

		set @current = @current + 1;
		fetch ABSOLUTE @current from csr_Products into @MyProductID, @MyProductQty;
	end
	
	close csr_Products
	deallocate csr_Products

	---------------------------------------------------------------------------
	select	T.AcntCode, pub.GetCodeName(T.AcntCode, 1) AS AcntName,
			isnull(sum(T.Amount), 0) As Amount
	from	#tbl_RptPrd_ProduceOversTree_Result T
	group by T.AcntCode
	order by T.AcntCode
	---------------------------------------------------------------------------
END
GO
