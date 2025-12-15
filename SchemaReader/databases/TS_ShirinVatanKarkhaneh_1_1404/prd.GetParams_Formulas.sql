USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : H Sadeghi
-- Create date   : 1399/04/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =================================================================
--[prd].[GetParams_Formulas]'500104141001'
CREATE PROCEDURE [prd].[GetParams_Formulas]
	@ProductID		VarChar(20) = Null
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

declare  @CallType int;			
DECLARE @QuantityDecimals AS Int
BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------

	SET @Indent = 3
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
		MainProductID	varchar(20) collate Arabic_CS_AS null,
		ProductID		varchar(20) collate Arabic_CS_AS null,
		GoodsID			varchar(255) collate Arabic_CS_AS null,
		GoodsQty		float null,
		LevelStr		nvarchar(1024),
		IsCustomOrder	bit,
		CustomOrderTitle nvarchar(200)
	);
	create table #tbl_Balance
	(
		GoodsID varchar(20) collate Arabic_CS_AS not null,
		Balance float not null
	);
	-- WHERE SECTION --------------------------------
	SET @StrWhere = ''

	SET @StrWhere = @StrWhere + ' AND (H.IsDefault = 1)' 

	-- step 1 collect products -----------------------------------------------
	set @StrSelect = '	
	insert into #tbl_Prods(GoodsID)
	select distinct D.ProductID
	from prd.tblFormulasDtl D
			inner join prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo
	where H.IsDefault = 1 AND H.ProductID =''' + @ProductID + ''''
	print @StrSelect
	Exec sp_executesql @StrSelect;
	-- step 1 end ------------------------------------------------------------
	
	-- step 2 collect semi products ------------------------------------------
	set @StrSelect = '	
	insert into #tbl_Semis(GoodsID)
	select distinct D.ProductID
	from prd.tblFormulasDtl D
			inner join prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo
	where D.ProductID in (select GoodsID from prd.tblFormulasDtl) AND H.IsDefault = 1 '
		
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	-- step 2 end ------------------------------------------------------------

	-- step 2 collect goods --------------------------------------------------
	set @StrSelect = '
	insert into #tbl_Goods(GoodsID)
	select distinct D.GoodsID
	from prd.tblFormulasDtl D
			inner join prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo
	where D.GoodsID not in (select ProductID from prd.tblFormulasDtl) AND H.IsDefault = 1 '

	
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

		WITH tblTemp(ProductID, GoodsID, Quantity, LevelStr,IsCustomOrder,CustomOrderTitle) AS
		(
			SELECT	D.ProductID, D.GoodsID, (1 / H.ProductCount) * D.GoodsQuantity As Quantity,
					CAST(Str(Row_Number() over (order by D.ProductID,D.GoodsID), @Indent) as nvarchar(50)) as LevelStr,
					D.IsCustomOrder,D.CustomOrderTitle
			FROM	prd.tblFormulasDtl D
			INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID 
			WHERE  H.ProductID=@ProductID
					and ((H.IsDefault=1) )
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
					CAST(tblTemp.LevelStr + Str(Row_Number() over (order by D.ProductID,D.GoodsID), @Indent) as nvarchar(50)) as LevelStr,
					D.IsCustomOrder,D.CustomOrderTitle
			FROM	prd.tblFormulasDtl D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID, tblTemp
			WHERE  (H.ProductID = tblTemp.GoodsID)
					and ((H.IsDefault=1) ) 
		)
		insert into #tbl_Result(MainProductID, ProductID, GoodsID, GoodsQty, LevelStr,IsCustomOrder,CustomOrderTitle)
		SELECT	@ProductID, T.ProductID, T.GoodsID, 
				Round(IsNull(Sum(Quantity),0), @QuantityDecimals) GoodsQuantity, T.LevelStr
				,IsCustomOrder,CustomOrderTitle
		FROM	tblTemp T
		GROUP BY T.ProductID, T.GoodsID, T.LevelStr,IsCustomOrder,CustomOrderTitle
		ORDER BY T.LevelStr


		fetch next from csr_P into @ProductID;
	end

	close csr_P;
	deallocate csr_P;
	------------------------------------------------------------------------------

	-- final select --------------------------------------------------------------
	SELECT	R.*, [pub].[funGetGoodsName](R.GoodsID, @LangID) As GoodsName, 
			[pub].[funGetGoodsName](R.MainProductID, @LangID) As ProductName, 
			[pub].[funGetGoodsUnitName] (R.GoodsID, @LangID) As UnitName, 
			CAST(LEN(R.LevelStr)/@Indent as int) LevelNo,
			Space(Len(R.LevelStr)-@Indent) + R.GoodsID GoodsIDEx
	FROM #tbl_Result R
	where IsCustomOrder=1
	ORDER BY MainProductID, LevelStr
	------------------------------------------------------------------------------
END


--GO

--[prd].[GetParams_Formulas]'500104141001'
GO
