USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1387/02/21
-- Viewed By	 : 
-- Last Modified : 1389/05/24
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : <List of Product Formulas>
-- =================================================================
Create PROCEDURE [prd].[RptPrd_FormulasTree]
	@SelectedProds	Int = 0,
	@SelectedSemis	Int = 0,
	@SelectedGoods	Int = 0,
	@SelectedStore	Int = 0,
	@SerialNo		Int = 0, -- zero => default
	@FormulaName	NVarChar(200) = Null,
	@RepOptions		NVarChar(200) = '114',
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

DECLARE @Accepted	Bit;
DECLARE @NoAccept	Bit;
DECLARE @Indent		int;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

declare @ProductID	varchar(20);
declare  @CallType int;			
DECLARE @QuantityDecimals AS Int
BEGIN
 
	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@SelectedProds	Is Null)	SET @SelectedProds = 0;
	IF (@SelectedSemis	Is Null)	SET @SelectedSemis = 0;
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0;
	IF (@RepOptions		Is Null)	SET @RepOptions = '1'

	SET @Accepted	= Substring(@RepOptions, 1, 1);
	SET @NoAccept	= Substring(@RepOptions, 2, 1);
	SET @Indent		= Substring(@RepOptions, 3, 1);
	SET @CallType		= Substring(@RepOptions, 4, 1);									 	
	
	if (@Indent = 0) set @Indent = 4;
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET		@QuantityDecimals = 3
	SELECT  @QuantityDecimals=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimals'

	---------------------------------------------------------------------------
	create table #tbl_Goods
	(
		GoodsID varchar(20) collate Arabic_CS_AS not null
	);
	create table #tbl_Semis
	(
		GoodsID varchar(20) collate Arabic_CS_AS not null
	);
	create table #tbl_Prods
	(
		GoodsID varchar(20) collate Arabic_CS_AS not null
	);
	create table #tbl_Result
	(
		MainProductID				varchar(20) collate Arabic_CS_AS null,
		ProductID					varchar(20) collate Arabic_CS_AS null,
		GoodsID						varchar(255) collate Arabic_CS_AS null,
		FormulaApprovalAgent		varchar(255) collate Arabic_CS_AS null,
		GoodsQty					float null,
		LevelStr					nvarchar(1024)
	);
	create table #tbl_Balance
	(
		GoodsID varchar(20) collate Arabic_CS_AS not null,
		Balance float not null
	);
	-- WHERE SECTION --------------------------------
	set @StrWhere = ''
		create table #tbl_Stores
	(
		StoreID varchar(20) collate Arabic_CS_AS not null
	);
	if (@SelectedStore<> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	set @StrSelect = '	
	insert into #tbl_Stores(StoreID)
	select Distinct StoreID from inv.tblStores D
	where 1 = 1 ' + @StrWhere
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrWhere = ''

	if (@Accepted = 0)
		SET @StrWhere = @StrWhere + ' AND (H.AcceptFormula = 0)' 
	if (@NoAccept = 0)
		SET @StrWhere = @StrWhere + ' AND (H.AcceptFormula = 1)' 
		
	If (@FormulaName Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FormulaName LIKE N''%' + @FormulaName + '%'')' 
		
	if (@SerialNo > 0)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo = ' + LTrim(STR(@SerialNo)) + ')' 
	else
		SET @StrWhere = @StrWhere + ' AND (H.IsDefault = 1)' 

	-- step 1 collect products -----------------------------------------------
	set @StrSelect = '	
	insert into #tbl_Prods(GoodsID)
	select distinct D.ProductID
	from prd.tblFormulasDtl D
			inner join prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo
	where 1 = 1 ' + @StrWhere
	
	if (@SelectedProds <> 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D.ProductID') 
		
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	-- step 1 end ------------------------------------------------------------
	
	-- step 2 collect semi products ------------------------------------------
	set @StrSelect = '	
	insert into #tbl_Semis(GoodsID)
	select distinct D.ProductID
	from prd.tblFormulasDtl D
			inner join prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo
	where D.ProductID in (select GoodsID from prd.tblFormulasDtl)' + @StrWhere
	
	if (@SelectedSemis <> 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSemis, 'D.ProductID') 
		
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	-- step 2 end ------------------------------------------------------------

	-- step 2 collect goods --------------------------------------------------
	set @StrSelect = '
	insert into #tbl_Goods(GoodsID)
	select distinct D.GoodsID
	from prd.tblFormulasDtl D
			inner join prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo
	where D.GoodsID not in (select ProductID from prd.tblFormulasDtl)'

	if (@SelectedGoods <> 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	-- step 2 end ------------------------------------------------------------	
	-- SELECT SECTION --------------------------------------------------------
	declare csr_P cursor for
		select GoodsID
		from #tbl_Prods
	open csr_P;
	
	fetch next from csr_P into @ProductID;
		
	while (@@FETCH_STATUS = 0)
	begin
		WITH tblTemp(ProductID, GoodsID, Quantity, LevelStr,FormulaApprovalAgent) AS
		(
			SELECT	D.ProductID, D.GoodsID, (1 / H.ProductCount) * D.GoodsQuantity As Quantity,
					CAST(Str(Row_Number() over (order by D.ProductID,D.GoodsID), @Indent) as nvarchar(50)) as LevelStr,H.FormulaApprovalAgent 
			FROM	prd.tblFormulasDtl D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID 
			WHERE  H.ProductID=@ProductID
					and ( @SelectedStore=0  or ( @SelectedStore<>0 
						and ( D.DefaultStoreID in (Select StoreID from   #tbl_Stores ) 
						   or H.DefaultStoreID in (Select StoreID from   #tbl_Stores ))))		
					and ((@SerialNo=0 and H.IsDefault=1) or (@SerialNo<>0 and H.SerialNo=@SerialNo))
					and (H.ProductID in 
						(
							select GoodsID
							from #tbl_Prods
							union
							select GoodsID
							from #tbl_Semis
						))
					and (D.GoodsID in 
						(
							select GoodsID
							from #tbl_Goods
							union
							select GoodsID
							from #tbl_Semis
						))
			UNION All
			
			SELECT	H.ProductID, D.GoodsID, (tblTemp.Quantity / H.ProductCount) * D.GoodsQuantity As Quantity,
					CAST(tblTemp.LevelStr + Str(Row_Number() over (order by D.ProductID,D.GoodsID), @Indent) as nvarchar(50)) as LevelStr, H.FormulaApprovalAgent
			FROM	prd.tblFormulasDtl D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID, tblTemp
			WHERE  (H.ProductID = tblTemp.GoodsID)
					and ((@SerialNo=0 and H.IsDefault=1) or (@SerialNo<>0 and H.SerialNo=@SerialNo)) 
					and  ( @SelectedStore=0  or ( @SelectedStore<>0 
						and ( D.DefaultStoreID in (Select StoreID from   #tbl_Stores ) 
						   or H.DefaultStoreID in (Select StoreID from   #tbl_Stores ))))		
		)
		insert into #tbl_Result(MainProductID, ProductID, GoodsID, GoodsQty, LevelStr,FormulaApprovalAgent)
		SELECT	@ProductID, T.ProductID, T.GoodsID,
				Round(IsNull(Sum(Quantity),0), @QuantityDecimals) GoodsQuantity, T.LevelStr,T.FormulaApprovalAgent 
		FROM	tblTemp T
		GROUP BY T.ProductID, T.GoodsID, T.LevelStr,T.FormulaApprovalAgent 
		ORDER BY T.LevelStr
		
		fetch next from csr_P into @ProductID;
	end

	close csr_P;
	deallocate csr_P;
	------------------------------------------------------------------------------
		
	-- balance section -----------------------------------------------------------
	set @StrWhere = ''
	
	if (@SelectedStore<> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	set @StrSelect = '	
	insert into #tbl_Balance(GoodsID, Balance)
	select D.GoodsID, isnull(sum(D.GoodsQuantity * D.EnterKind), 0) Balance
	from inv.tblStorageDocsDtl D
	where (PhysicallyEffected = 1) and GoodsID in 
		(
			select GoodsID 
			from #tbl_Prods
			union
			select GoodsID
			from #tbl_Semis
			union
			select GoodsID
			from #tbl_Goods
		) ' + @StrWhere + '
	group by D.GoodsID'
		
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
------------------------------------------------------------------------------
if @CallType=1
begin
 
 delete FROM #tbl_Result 
 where GoodsID in (select ProductID FROM #tbl_Result )
 update #tbl_Result 
 set  ProductID=MainProductID
 where ProductID<>MainProductID

end
-- final select --------------------------------------------------------------
	SELECT	R.*, [pub].[funGetGoodsName](R.GoodsID, @LangID) As GoodsName, 
			[pub].[funGetGoodsName](R.MainProductID, @LangID) As ProductName, 
			[pub].[funGetGoodsUnitName] (R.GoodsID, @LangID) As UnitName, 
			CAST(LEN(R.LevelStr)/@Indent as int) LevelNo,
			ISNULL(B.Balance, 0) Balance, Space(Len(R.LevelStr)-@Indent) + R.GoodsID GoodsIDEx,R.FormulaApprovalAgent,
			[pub].[funGetGoodsUnitName](R.MainProductID,@LangID) ProductUnitName 
	FROM #tbl_Result R
	LEFT JOIN #tbl_Balance B on B.GoodsID=R.GoodsID
	ORDER BY MainProductID, LevelStr
	------------------------------------------------------------------------------
END
GO
