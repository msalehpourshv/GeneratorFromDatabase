USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1389/02/13
-- Viewed By	 : 
-- Last Modified : 1393/02/10
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : <مراحل تولید محصولات - درختی>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_ProduceStepsTree]
	@ProductID		VarChar(20) = null,
	@SelectedProds	Int = 0,
	@SelectedGoods	Int = 0,
	@RepOptions		NVarChar(100) = '3',
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)
DECLARE @StrSort	NVarChar(500)
DECLARE @SortInfo	int

DECLARE @Sort		bigint;
DECLARE @RowCount	bigint;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @SelectedProduct varchar(20);

DECLARE @UnitPart	TINYINT

BEGIN

	SET NOCOUNT ON;

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
	
	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';
	if (@SelectedProds	Is Null)	set @SelectedProds = 0;
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @SortInfo = Substring(@RepOptions, 1, 1);
	
	---------------------------------------------------------------------------
	-- where section ----------------------------------------------------------
	set @StrWhere = '(1=1)';

	if (@ProductID is not null)
		set @StrWhere = @StrWhere + ' AND ProductID = ''' + @ProductID + '''' 

	if (@SelectedProds > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'ProductID') 
		
	set @Sort = 0
	---------------------------------------------------------------------------
	-- select section ---------------------------------------------------------
	create table #tbl_RptProduceStepsTree_Products
	(
		ProductID varchar(20) collate arabic_cs_as not null 
	);

	create table #tbl_RptProduceStepsTree_Result
	(
		ProductID	varchar(20) collate arabic_cs_as not null,
		GoodsID		varchar(20) collate arabic_cs_as not null,
		Sort		bigint not null
	);
	create table #tbl_Orders
	(
		OGoodsID	varchar(20) collate Arabic_CS_AS null,
		OrderQty	float
	);

	insert #tbl_Orders(OGoodsID, OrderQty)
	SELECT	GoodsID, Sum(GoodsQuantity-CancelQuantity) - Sum(SoldQuantity-SoldRetQuantity) 
	FROM
	(
		SELECT	D.GoodsID, (D.GoodsQuantity) GoodsQuantity,
				isnull((
					SELECT	Sum(C.GoodsQuantity)
					FROM	sal.tblSaleOrderDtl C
					WHERE	(C.BaseProcessID=D.ProcessID)
						AND (C.BaseProcessNo=D.ProcessNo)
						AND (C.BaseFiscalYear=D.FiscalYear)
						AND (C.BaseSerialNo=D.SerialNo)
						AND (C.BaseDocRowNo=D.DocRowNo)
						AND (C.ProcessID=185)
				),0) CancelQuantity,
				isnull((
					SELECT	sum(GoodsQuantity) 
					FROM	inv.tblStorageDocsDtl SD
					WHERE	(SD.ProcessID=90)
						AND SD.BaseProcessID=D.ProcessID 
						AND SD.BaseProcessNo=D.ProcessNo 
						AND SD.BaseFiscalYear=D.FiscalYear 
						AND SD.BaseSerialNo=D.SerialNo 
						AND SD.BaseDocRowNo=D.DocRowNo
				),0) SoldQuantity, 0 SoldRetQuantity
		FROM    sal.tblSaleOrderDtl AS D
					INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		WHERE   (D.ProcessID=180)
	) T  
	where (GoodsQuantity-CancelQuantity)-(SoldQuantity-SoldRetQuantity) > 0
	group by GoodsID

	-- enlist products
	set @StrSelect = '
	insert into #tbl_RptProduceStepsTree_Products
	select Distinct ProductID
	from prd.tblFormulasHdr
	where ' + @StrWhere

	exec sp_executesql @StrSelect;

	-- iterate on products
	declare csr_Products cursor for
		select ProductID
		from #tbl_RptProduceStepsTree_Products
	open csr_Products;

	fetch NEXT from csr_Products into @SelectedProduct
	
	while (@@fetch_status = 0)
	begin
		set @Sort = @Sort + 1

		insert into	#tbl_RptProduceStepsTree_Result(ProductID, GoodsID, Sort)
		select	distinct @SelectedProduct, GoodsID, @Sort
		from	prd.tblFormulasDtl
		where	(ProductID = @SelectedProduct) and GoodsID in (select ProductID from prd.tblFormulasHdr)
		except
		select	ProductID, GoodsID, @Sort
		from	#tbl_RptProduceStepsTree_Result
		
		set @RowCount = @@RowCount

		-- recusrively collect products of current product
		while (@RowCount > 0)
		begin
			insert into	#tbl_RptProduceStepsTree_Result(ProductID, GoodsID, Sort)
			select	distinct @SelectedProduct, GoodsID, @Sort
			from	prd.tblFormulasDtl
			where	ProductID in (select GoodsID from #tbl_RptProduceStepsTree_Result where ProductID = @SelectedProduct) and 
					GoodsID   in (select ProductID from prd.tblFormulasHdr)
			except
			select	ProductID, GoodsID, @Sort
			from	#tbl_RptProduceStepsTree_Result
			
			set @RowCount = @@RowCount
			set @Sort = @Sort + 1
		end

		set @Sort = @Sort + 1
		fetch NEXT from csr_Products into @SelectedProduct
	end
	
	close csr_Products
	deallocate csr_Products

	---------------------------------------------------------------------------
	select total.*
	into #tblAll
	from
	(
		select	T.ProductID, G2.GoodsName AS ProductName, T.GoodsID, G1.GoodsName,
				(
					select isNull(sum(GoodsQuantity * EnterKind), 0) Balance
					from inv.tblStorageDocsDtl
					where (PhysicallyEffected = 1) and (GoodsID = T.GoodsID)
				) AS Balance,
				isNull(P.ProductCount, 0) AS Balance_Prd, Sort
		from	#tbl_RptProduceStepsTree_Result T
					INNER JOIN inv.tblGoodsDtl G1 ON G1.GoodsID = SUBSTRING(T.GoodsID, @str_Goods + 1, @str_GoodsSum) AND G1.PartNumber=@UnitPart AND G1.LanguageID = @LangID
					INNER JOIN inv.tblGoodsDtl G2 ON G2.GoodsID = SUBSTRING(T.ProductID, @str_Goods + 1, @str_GoodsSum) AND G2.PartNumber=@UnitPart AND G2.LanguageID = @LangID

					LEFT  JOIN 
					(
						-- in produce products list	
						select ProductID, sum(ProductCount) as ProductCount
						from inv.tblStorageDocsHdr H
							INNER JOIN 
							(
								select	ProcessNo, FiscalYear, SerialNo
								from	inv.tblStorageDocsHdr
								where	ProcessID = 70
								except
								select	BaseProcessNo, BaseFiscalYear, BaseSerialNo
								from	inv.tblStorageDocsHdr
								where	ProcessID = 80 
							) R ON H.ProcessNo = R.ProcessNo AND H.FiscalYear = R.FiscalYear AND H.SerialNo = R.SerialNo
						where H.ProcessID = 70 	
						group by ProductID
					) P on P.ProductID = T.GoodsID
		union all
		select	M.ProductID, G.GoodsName, M.ProductID, G.GoodsName,
				(
					select isNull(sum(GoodsQuantity * EnterKind), 0) Balance
					from inv.tblStorageDocsDtl
					where (PhysicallyEffected = 1) and (GoodsID = M.ProductID)
				) AS Balance,
				isNull(P.ProductCount, 0) AS Balance_Prd, 0
		from	#tbl_RptProduceStepsTree_Products M
					
					INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(M.ProductID, @str_Goods + 1, @str_GoodsSum) AND G.PartNumber=@UnitPart AND G.LanguageID = @LangID

					left  join 
					(
						-- in produce products list	
						select ProductID, sum(ProductCount) as ProductCount
						from inv.tblStorageDocsHdr H
							INNER JOIN 
							(
								select	ProcessNo, FiscalYear, SerialNo
								from	inv.tblStorageDocsHdr
								where	ProcessID = 70
								except
								select	BaseProcessNo, BaseFiscalYear, BaseSerialNo
								from	inv.tblStorageDocsHdr
								where	ProcessID = 80 
							) R ON H.ProcessNo = R.ProcessNo AND H.FiscalYear = R.FiscalYear AND H.SerialNo = R.SerialNo
						where H.ProcessID = 70 	
						group by ProductID
					) P on P.ProductID = M.ProductID
	) total

	-- filter by goods ---------------------------------------------------------------
	declare @whr nvarchar(1000)

	if (@SelectedGoods > 0) 
		set @whr =  pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'GoodsID')
	else
		set @whr = '(1=1)'
	---------------------------------------------------------------------------
	set @StrSort = 'A.ProductID, A.Sort desc, A.GoodsID'
	if (@SortInfo = 1)	set @StrSort = 'A.ProductID, A.GoodsID, A.Sort desc'
	if (@SortInfo = 2)	set @StrSort = 'A.ProductID, A.GoodsName, A.Sort desc'

	set @StrSelect = '
		select A.*, isnull(O.OrderQty, 0) RemainOrder
		from #tblAll A
				left join #tbl_Orders O on O.OGoodsID=A.ProductID
		where ' + @whr + '
		order by ' + @StrSort

	print @StrSelect;
	exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
