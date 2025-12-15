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
CREATE PROCEDURE [prd].[GetParams_FormulasOtherGoods]
	@PrdID		VarChar(20) = Null
WITH ENCRYPTION
AS
DECLARE @ProductID	NVarChar(20)
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
		CustomOrderTitle nvarchar(200),
		GoodsName		NVARCHAR(500)
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
	where H.IsDefault = 1 AND H.ProductID =''' + @PrdID + ''''
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
		insert into #tbl_Result(MainProductID, ProductID, GoodsID, GoodsQty, LevelStr,IsCustomOrder,CustomOrderTitle,GoodsName)
		SELECT	@ProductID, T.ProductID, T.GoodsID, 
				Round(IsNull(Sum(Quantity),0), @QuantityDecimals) GoodsQuantity, T.LevelStr
				,IsCustomOrder,CustomOrderTitle,[pub].[funGetGoodsName](T.GoodsID,1)
		FROM	tblTemp T
		GROUP BY T.ProductID, T.GoodsID, T.LevelStr,IsCustomOrder,CustomOrderTitle
		ORDER BY T.LevelStr


		fetch next from csr_P into @ProductID;
	end

	close csr_P;
	deallocate csr_P;
	------------------------------------------------------------------------------

	declare @GoodsID	VarChar(20) 
	
	Declare	CurR CURSOR For 
	SELECT DISTINCT ProductID,GoodsID FROM #tbl_Result
	where IsCustomOrder=1
	
	Open  CurR; 
	
	Fetch NEXT From CurR Into  @ProductID,@GoodsID
	While (@@Fetch_Status = 0)
	BEGIN
		insert into #tbl_Result(MainProductID, ProductID, GoodsID, GoodsQty, LevelStr,IsCustomOrder,CustomOrderTitle,GoodsName)
		SELECT	'' MainProductID, @GoodsID, A.GoodsID, 
				1 GoodsQuantity, '' LevelStr,1 IsCustomOrder,'' CustomOrderTitle,[pub].[funGetGoodsName](A.GoodsID,1)
		FROM	prd.tblFormulasAtm A 
		INNER JOIN prd.tblFormulasHdr H ON A.ProductID=H.ProductID AND A.SerialNo=H.SerialNo
		INNER JOIN prd.tblFormulasDtl D ON D.ProductID=H.ProductID AND D.SerialNo=H.SerialNo and D.DocRowNo=A.DocRowNo
		WHERE  IsDefault = 'True' and H.ProductID = @ProductID and D.GoodsID = @GoodsID
	
		Fetch NEXT From CurR Into  @ProductID,@GoodsID
	END
	
	Close CurR;
	Deallocate CurR; 
	
	Declare	CurP CURSOR For 
	SELECT DISTINCT H.GoodsParametersID 
	FROM inv.tblGoodsParameters H
	INNER JOIN inv.tblGoodsParametersDtl D
	ON H.GoodsParametersID=D.GoodsParametersID
	where ParameterType=2 AND
	H.GoodsParametersID IN (
				SELECT GoodsParametersID 
				FROM inv.tblSetParamsToGoodsDtl
				WHERE GoodsID in (
						SELECT top 1 GoodsID 
						FROM inv.tblSetParamsToGoodsDtl
						where GoodsID = SUBSTRing(@PrdID,1,LEN(GoodsID))
						order By LEN(GoodsID) desc
						          )
						   )
	
	Open  CurP; 
	
	Fetch NEXT From CurP Into  @GoodsID
	While (@@Fetch_Status = 0)
	BEGIN
		insert into #tbl_Result(MainProductID, ProductID, GoodsID, GoodsQty, LevelStr,IsCustomOrder,CustomOrderTitle,GoodsName)
		SELECT	'' MainProductID, @GoodsID, A.CustomGoodsParamID, 
				1 GoodsQuantity, '' LevelStr,1 IsCustomOrder,'' CustomOrderTitle,D.CustomGoodsParamName
		FROM	inv.tblCustomGoodsParam A 
		INNER JOIN inv.tblCustomGoodsParamDtl D ON A.CustomGoodsParamID=D.CustomGoodsParamID 
		where GoodsParametersID = @GoodsID
		
		Fetch NEXT From CurP Into  @GoodsID
	END
	
	Close CurP;
	Deallocate CurP; 
	
	SELECT *  froM #tbl_Result where IsCustomOrder=1
END


--GO

--[prd].[GetParams_FormulasOtherGoods]'500104141001'
GO
