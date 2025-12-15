USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1387/02/21
-- Viewed By	 : 
-- Last Modified : 1392/11/23
-- Last Modifier : TakroSystem\Hamid
-- Description   : <List of Product Formulas>
-- =================================================================
Create PROCEDURE [prd].[RptPrd_FormulasList]
	@SelectedGoods		Int = 0,
	@GoodsID			Varchar(20) = Null,
	@IncludeDescDtl		Bit = 0,
	@FormulaName		NVarChar(200) = Null,
	@RepOptions			NVarChar(200) = '111',
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect		NVarChar(Max)
DECLARE @StrFrom		NVarChar(Max)
DECLARE @StrWhere		NVarChar(Max)
DECLARE @StrDesc		NVarChar(Max)
DECLARE @FromDate		VarChar(10)
DECLARE @ToDate			VarChar(10)
DECLARE @FSNO			INT;
DECLARE @DefaultOnly	tinyint;
DECLARE @Accepted		Bit;
DECLARE @NoAccept		Bit;
DECLARE @Balance		Bit;
DECLARE @SimilarGoods	Bit;

DECLARE @WithoutWage		Bit;
DECLARE @WithoutOverLoad	Bit;
DECLARE @SecondaryProduct	Bit;
DECLARE @ActiveFormula		Bit;
DECLARE @DeActiveFormula	Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@RepOptions		Is Null)	SET @RepOptions = '1'
	SET @FSNO = 0
	SET @DefaultOnly		= Substring(@RepOptions, 1, 1);
	SET @Accepted			= Substring(@RepOptions, 2, 1);
	SET @NoAccept			= Substring(@RepOptions, 3, 1);
	SET @SimilarGoods		= Substring(@RepOptions, 6, 1);
	SET @WithoutWage		= Substring(@RepOptions, 7, 1);
	SET @WithoutOverLoad	= Substring(@RepOptions, 8, 1);
	SET @SecondaryProduct	= Substring(@RepOptions, 9, 1);
	SET @ActiveFormula		= Substring(@RepOptions, 10, 1);
	SET @DeActiveFormula	= Substring(@RepOptions, 11, 1);
	
	-- 4 is used
	if len(@RepOptions) > 4 
		SET @Balance = Substring(@RepOptions, 5, 1);
	else
		SET @Balance = 1
	
	SET @FromDate = ''
	SET @ToDate = ''

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @FSNO		= pub.funSplitString(@RepInfo, '@', 6);
	SET @FromDate	= pub.funSplitString(@RepInfo, '@', 7);
	SET @ToDate		= pub.funSplitString(@RepInfo, '@', 8);
	---------------------------------------------------------------------------
	create table #tbl_GoodsList
	(
		GoodsID varchar(20) collate Arabic_CS_AS not null
	);
	create table #tbl_Balance
	(
		GoodsID varchar(20) collate Arabic_CS_AS not null,
		Balance float not null
	);
	-- WHERE SECTION --------------------------------
	SET @StrWhere = '(1=1)'
	
	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.ProductID') 

	if (@GoodsID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.ProductID = ''' + @GoodsID + ''''

	if (@Accepted = 0)
		SET @StrWhere = @StrWhere + ' AND (H.AcceptFormula = 0)' 

	if (@NoAccept = 0)
		SET @StrWhere = @StrWhere + ' AND (H.AcceptFormula = 1)' 
	
	If (@FormulaName Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FormulaName LIKE N''%' + @FormulaName + '%'')' 

	if (@DefaultOnly = 1)
		SET @StrWhere = @StrWhere + ' AND (H.IsDefault = 1)' 
	
	if (@DefaultOnly = 2)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo = ' + STR(@FSNO) + ')' 

	if @FromDate <>''
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @FromDate + ''')' 

	if @ToDate <>''
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @ToDate + ''')'
		
	if (@WithoutWage = 1)
		SET @StrWhere = @StrWhere + ' AND (O.Wage1 = 0 And O.Wage2 = 0 And O.Wage3 = 0 And O.Wage4 = 0 And O.Wage5 = 0 And
										   O.Wage6 = 0 And O.Wage7 = 0 And O.Wage8 = 0 And O.Wage9 = 0 And O.Wage10 = 0)' 
		
	if (@WithoutOverLoad = 1)
		SET @StrWhere = @StrWhere + ' AND ((Select COUNT(*) From prd.tblFormulasOverLoadDtl Where ProductID = H.ProductID AND SerialNo = H.SerialNo 
									  And (OverLoadProductDtl=1 or (OverLoadProductDtl=0 and OverLoadDecompositionDtl=0))) = 0)' 				
	-------------------------------------------------
	
	if @ActiveFormula = 1 and @DeActiveFormula=0
		SET @StrWhere = @StrWhere + ' AND GP.CodeClosed =0'
	if @ActiveFormula = 0 and @DeActiveFormula=1
		SET @StrWhere = @StrWhere + ' AND GP.CodeClosed =1'
		
	-- SELECT SECTION -------------------------------
	if (@Balance = 1)
	begin
		SET @StrSelect = '
		INSERT INTO #tbl_GoodsList(GoodsID)
		SELECT	D.GoodsID
		FROM	prd.tblFormulasDtl D 
		INNER JOIN prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo 
		WHERE	' + @StrWhere
		
		Print @StrSelect;
		Exec sp_executesql @StrSelect;

		SET @StrSelect = '
		INSERT INTO #tbl_GoodsList(GoodsID)
		SELECT	D.ProductID
		FROM	prd.tblFormulasDtl D 
		INNER JOIN prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo 
		WHERE	D.ProductID not in (select GoodsID from #tbl_GoodsList) and ' + @StrWhere
		
		Print @StrSelect;
		Exec sp_executesql @StrSelect;

		insert into #tbl_Balance
		select GoodsID, isnull(sum(GoodsQuantity * EnterKind), 0) Balance
		from inv.tblStorageDocsDtl
		where (PhysicallyEffected = 1) and GoodsID in 
			(
				select GoodsID 
				from #tbl_GoodsList
			)
		group by GoodsID
	end
	
	If (@IncludeDescDtl = 1)
		SET @StrDesc = 'D.DescDtl'
	Else
		SET @StrDesc = 'Cast('''' AS NVarChar(500)) AS DescDtl'
	
	Declare @ConstPrdText1Name  nVarchar(100)
	Declare @ConstPrdText2Name  nVarchar(100)
	Declare @ConstPrdText3Name  nVarchar(100)
	Declare @ConstPrdText4Name  nVarchar(100)
	Declare @ConstPrdText5Name  nVarchar(100)
	Declare @PartNumber			int
	Set @ConstPrdText1Name = ''
	Set @ConstPrdText2Name = ''
	Set @ConstPrdText3Name = ''
	Set @ConstPrdText4Name = ''
	Set @ConstPrdText5Name = ''
		
	SELECT @ConstPrdText1Name = SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText1'
	SELECT @ConstPrdText2Name = SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText2'
	SELECT @ConstPrdText3Name = SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText3'
	SELECT @ConstPrdText4Name = SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText4'
	SELECT @ConstPrdText5Name = SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText5'
	
	SELECT @PartNumber = SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'UnitPart'
	Set @PartNumber=isnull(@PartNumber,1)
	
	if @PartNumber=0
		set @PartNumber=1

	SET @StrSelect = '
	SELECT	H.DocDate,D.ProductID, D.SerialNo, D.DocRowNo, D.GoodsID, D.GoodsQuantity,D.SubUnitQuantity, ' + @StrDesc + ', H.ProductCount,
			(SELECT Count(*) FROM prd.tblFormulasAtm A
			 WHERE D.ProductID = A.ProductID And D.SerialNo = A.SerialNo And D.DocRowNo = A.DocRowNo) As SimilarGoodsCount,
			[pub].[funGetGoodsName](D.ProductID, ' + @LangID + ') ProductName, 
			isnull(B1.Balance,0) AvailGoods, isnull(B2.Balance,0) AvailProducts,
			[pub].[funGetGoodsName](D.GoodsID, ' + @LangID + ') GoodsName, H.FormulaName,
			( SELECT UnitName FROM inv.tblUnitsDtl UD WHERE UD.UnitID = D.UnitID ) UnitName,
			( SELECT UnitName FROM inv.tblUnitsDtl UD WHERE UD.UnitID = G.UnitID) UnitNameBase,
			(Select COUNT(*) From prd.tblFormulasHdr FH
			 Where FH.ProductID = D.GoodsID) As FormulaCount, G.TechnicalSpecifications,
			O.Wage1, O.Wage2, O.Wage3, O.Wage4, O.Wage5, O.Wage6, O.Wage7, O.Wage8, O.Wage9, O.Wage10,
			D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5,
			'''+@ConstPrdText1Name +''' ConstPrdText1Name,'''+@ConstPrdText2Name +''' ConstPrdText2Name,'''+@ConstPrdText3Name +''' ConstPrdText3Name,
			'''+@ConstPrdText4Name +''' ConstPrdText4Name,'''+@ConstPrdText5Name +''' ConstPrdText5Name,
			H.DocDesc,H.ExtraF1,H.ExtraF2,H.ExtraF3,H.ExtraF4,D.DefaultStoreID DefaultStoreIDDtl, H.DefaultStoreID DefaultStoreIDHdr, H.FormulaApprovalAgent
			,H.LastUpdate , [pub].[funChangeDate_GergorianToPersian](H.LastUpdate) LastDateHdr ,convert( time (0), H.LastUpdate )LastTimeHdr
	FROM	prd.tblFormulasDtl D 
				INNER JOIN prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo 
				LEFT  JOIN prd.tblFormulasOverLoadHdr O ON H.ProductID = O.ProductID AND H.SerialNo = O.SerialNo  
								And (O.OverLoadProduct=1 or (O.OverLoadProduct=0 and O.OverLoadDecomposition=0))
				LEFT JOIN #tbl_Balance B1 on B1.GoodsID = D.GoodsID
				LEFT JOIN #tbl_Balance B2 on B2.GoodsID = D.ProductID
				LEFT JOIN inv.tblGoods G on G.GoodsID = D.GoodsID  and G.PartNumber='+str(@PartNumber)+'
				LEFT JOIN inv.tblGoods GP on GP.GoodsID = D.ProductID  and GP.PartNumber='+str(@PartNumber)+'
	WHERE	' + @StrWhere + '
	ORDER BY D.ProductID, D.SerialNo, D.DocRowNo '
	-------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
