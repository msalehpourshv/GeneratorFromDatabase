USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1389/02/14
-- Viewed By	 : 
-- Last Modified : 1390/09/26
-- Last Modifier : TakroSystem\Zia
-- Description   : <لیست مواد اولیه تعریف شده برای تولید یک محصول - فقط برگها>
-- =================================================================
Create PROCEDURE [prd].[RptPrd_ProduceGoods_Leafs]
	@ProductID		VarChar(20),
	@ProductQty		float = 1,
	@RepOptions		NVarChar(100) = '100',
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
DECLARE @FmlParam1		float;
DECLARE @current		int;
DECLARE @total			int;
DECLARE @CalcBalance	bit;
DECLARE @FirstLayer		bit;
DECLARE @UseGoodsFilter	bit;

DECLARE @UnitPart	TINYINT

BEGIN

	SET NOCOUNT ON;
	SET @FmlParam1 = 0
	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '10';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @FmlParam1	= pub.funSplitString(@RepInfo, '@', 4);

	set @CalcBalance= Substring(@RepOptions, 1, 1);
	set @UseGoodsFilter	= 0;
	set @FirstLayer	= 0;
	
	if (len(@RepOptions) > 1)
		set @UseGoodsFilter	= Substring(@RepOptions, 2, 1);
	if (len(@RepOptions) > 2)
		set @FirstLayer		= Substring(@RepOptions, 3, 1);
		
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
			
	---------------------------------------------------------------------------
	-- select section ---------------------------------------------------------
	create table #tbl_RptPrd_ProduceGoods_Leafs_Products
	(
		ProductID	varchar(20) collate arabic_cs_as not null,
		ProductQty	float not null
	);

	create table #tbl_RptPrd_ProduceGoods_Leafs_Goods
	(
		GoodsID		varchar(20) collate arabic_cs_as not null,
		GoodsQty	float not null
	);

	-- enlist 1st layer goods
	insert into #tbl_RptPrd_ProduceGoods_Leafs_Products
	values (@ProductID, @ProductQty)

	set @current = 1;
	select @total = count(*)
	from #tbl_RptPrd_ProduceGoods_Leafs_Products

	-- iterate on products
	declare csr_Products cursor scroll for
		select ProductID, ProductQty
		from #tbl_RptPrd_ProduceGoods_Leafs_Products
	open csr_Products;

	fetch ABSOLUTE @current from csr_Products into @MyProductID, @MyProductQty;
	
	while (@current <= @total)
	begin
		if (@FirstLayer = 1)
		begin
		
			-- 1- fill goods into G table
			insert into	#tbl_RptPrd_ProduceGoods_Leafs_Goods
			select	D.GoodsID, (case when D.ParamKind=0 OR @FmlParam1 = 0 THEN @MyProductQty ELSE @FmlParam1 END  / case when D.ParamKind=0 OR @FmlParam1 = 0 THEN H.ProductCount ELSE H.FmlParam1 END) * D.GoodsQuantity 
			from	prd.tblFormulasDtl D
						inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo and H.IsDefault = 1
			where	(D.ProductID = @MyProductID) 
		end
		else
		begin
			-- 1- fill leaf goods into G table
			insert into	#tbl_RptPrd_ProduceGoods_Leafs_Goods
			select	D.GoodsID, (case when D.ParamKind=0 OR @FmlParam1 = 0 THEN @MyProductQty ELSE @FmlParam1 END  / case when D.ParamKind=0 OR @FmlParam1 = 0 THEN H.ProductCount ELSE H.FmlParam1 END) * D.GoodsQuantity 
			from	prd.tblFormulasDtl D
						inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo and H.IsDefault = 1
			where	(D.ProductID = @MyProductID) and 
					(D.GoodsID not in (select ProductID from prd.tblFormulasHdr))

			-- 2- fill unleaf goods into P table
			insert into	#tbl_RptPrd_ProduceGoods_Leafs_Products
			select	D.GoodsID, (case when D.ParamKind=0 OR @FmlParam1 = 0 THEN @MyProductQty ELSE @FmlParam1 END  / case when D.ParamKind=0 OR @FmlParam1 = 0 THEN H.ProductCount ELSE H.FmlParam1 END) * D.GoodsQuantity 
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
				from #tbl_RptPrd_ProduceGoods_Leafs_Products
			end
		end
		
		set @current = @current + 1;
		fetch ABSOLUTE @current from csr_Products into @MyProductID, @MyProductQty;
	end
	
	close csr_Products
	deallocate csr_Products

	---------------------------------------------------------------------------
	set @StrWhere = '(1=1)'
	
	if (@UseGoodsFilter = 1)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, 1, 'T.GoodsID') 
		
	declare @blc varchar(1500)
	
	if (@CalcBalance = 1) 
		set @blc = '
		(
			select isNull(sum(GoodsQuantity * EnterKind), 0) Balance
			from inv.tblStorageDocsDtl
			where (GoodsID = T.GoodsID)
		) '
	else
		set @blc = '0'
	
	set @StrSelect = '
		select	T.GoodsID, [pub].[funGetGoodsName](T.GoodsID, 1) As GoodsName, isnull(sum(T.GoodsQty), 0) AS GoodsQuantity, 
		' + @blc + ' AS Balance	,UnitName 	
		from	#tbl_RptPrd_ProduceGoods_Leafs_Goods T
		
		INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(T.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND G.PartNumber=' + LTRIM(STR(@UnitPart)) + '
		inner join inv.tblGoods gg on G.GoodsID=gg.GoodsID 		
		inner join inv.tblUnitsDtl u on u.UnitID=gg.UnitID and u.LanguageID=1

		where ' + @StrWhere + '
		group by T.GoodsID, G.GoodsName,UnitName
		order by T.GoodsID, G.GoodsName'
		
	print @StrSelect;
	exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
