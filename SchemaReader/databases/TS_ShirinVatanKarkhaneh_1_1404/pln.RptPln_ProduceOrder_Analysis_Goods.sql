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
CREATE PROCEDURE [pln].[RptPln_ProduceOrder_Analysis_Goods]
	@ProcSet	varchar(20),
	@ToDate		varchar(10) = null,
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

declare @ProcessID as int;
declare @ProcessNo as int;
declare @FiscalYear as int;
declare @SerialNo as int;

DECLARE @current	int;
DECLARE @total		int;
BEGIN
	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions = '';
	IF (@ToDate			Is Null)	SET @ToDate = '9999/99/9';

	SET @ProcessID	= pub.funSplitString(@ProcSet, '@', 1);
	SET @ProcessNo	= pub.funSplitString(@ProcSet, '@', 2);
	SET @FiscalYear	= pub.funSplitString(@ProcSet, '@', 3);
	SET @SerialNo	= pub.funSplitString(@ProcSet, '@', 4);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	create table #tblPln_ProduceOrder_Analysis_Goods_Products
	(
		ProductID	varchar(20) collate arabic_cs_as not null,
		Quantity	float not null,
		FormulaNo	int not null
	);

	create table #tblPln_ProduceOrder_Analysis_Goods_Goods
	(
		GoodsID		varchar(20) collate arabic_cs_as not null,
		Quantity	float
	);

	create table #tblPln_ProduceOrder_Analysis_Goods_Prices
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		Amount	float not null
	);

	-- enlist 1st layer products --
	 insert into #tblPln_ProduceOrder_Analysis_Goods_Products(ProductID, Quantity, FormulaNo) 
	 select O.ProductID, O.ProductCount, O.FormulaNo 
	 from pln.tblProduceOrderDtl O
		inner join prd.tblFormulasHdr H ON H.ProductID = O.ProductID 
	 where	(O.ProcessID = @ProcessID) and (O.ProcessNo = @ProcessNo) and (O.FiscalYear = @FiscalYear) and (O.SerialNo = @SerialNo) and
			((O.FormulaNo = 0 and H.IsDefault = 1) Or (O.FormulaNo <> 0 and H.SerialNo = O.FormulaNo))

	-------------------------------------------------
	set @current = 1;
	select @total = count(*)
	from #tblPln_ProduceOrder_Analysis_Goods_Products

	-- iterate on products
	declare csr_Products cursor scroll for
		select ProductID, Quantity, FormulaNo
		from #tblPln_ProduceOrder_Analysis_Goods_Products
	open csr_Products;

	fetch ABSOLUTE @current from csr_Products into @ProductID, @Quantity, @FormulaNo;


	while (@current <= @total)
	begin
		-- 1- fill leaf goods into G table
		insert into	#tblPln_ProduceOrder_Analysis_Goods_Goods
		select	D.GoodsID, (D.GoodsQuantity * @Quantity / H.ProductCount)
		from	prd.tblFormulasDtl D
					inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo
		where	(D.ProductID = @ProductID) 
				and ((@FormulaNo = 0 and H.IsDefault = 1) Or (@FormulaNo <> 0 and H.SerialNo = @FormulaNo))
				and (D.GoodsID not in (select ProductID from prd.tblFormulasHdr))

		-- 2- fill unleaf goods into P table
		insert into	#tblPln_ProduceOrder_Analysis_Goods_Products
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
			from #tblPln_ProduceOrder_Analysis_Goods_Products
			--select @total, @ProductID, @Quantity 
		end

		set @current = @current + 1;
		fetch ABSOLUTE @current from csr_Products into @ProductID, @Quantity, @FormulaNo;
	end
	
	close csr_Products
	deallocate csr_Products

	-- calc prices --
	insert into #tblPln_ProduceOrder_Analysis_Goods_Prices
	select *
	from 
	(
		select distinct M.GoodsID, 
			(
				select top 1 GoodsAmount 
				from inv.tblStorageDocsDtl D 
				where (D.GoodsID = M.GoodsID) and (D.GoodsAmount <> 0) and (D.ProcessID in (50, 55)) and (DocDate < @ToDate)
				order by DocDate DESC, VolumeRowNo DESC
			) GoodsAmount
		from #tblPln_ProduceOrder_Analysis_Goods_Goods M
	) T 
	where GoodsAmount is not null
		
	-- SELECT SECTION -------------------------------
	select T.GoodsID,  [pub].[funGetGoodsName](T.GoodsID,1) GoodsName, UD.UnitName, 
			T.Quantity,	isnull(P.Amount, 0) LastAmount,
			isnull((
				select sum(GoodsQuantity*EnterKind)
				from inv.tblStorageDocsDtl
				where (DocDate <= @ToDate)
			), 0) Balance
	from
	(
		select	D.GoodsID, sum(D.Quantity) Quantity
		from	#tblPln_ProduceOrder_Analysis_Goods_Goods D
		group by D.GoodsID
	) T inner join inv.tblGoods    GH on GH.GoodsID =SUBSTRING(T.GoodsID,@str_Goods+1,@str_GoodsSum) AND GH.PartNumber=@UnitPart
		inner join inv.tblUnitsDtl UD on UD.UnitID = GH.UnitID
		left  join #tblPln_ProduceOrder_Analysis_Goods_Prices P on P.GoodsID = T.GoodsID 
	-------------------------------------------------
END
GO
