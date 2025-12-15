USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ===================
-- Author		 : TakroSystem\Zia
-- Create date   : 1386/01/19
-- Viewed By	 : 
-- Last Modified : 1394/09/09
-- Last Modifier : TakroSystem\Zia
-- ---------------------------------------------
-- مواد و مقدار مورد نیاز برای تولید یک محصول بدون توجه به موجودی 
-- =============================================
Create PROCEDURE [prd].[RptPrd_ProductGoods_One]
	@ProductID		VarChar(20),
    @ProductQty		float = 1,
	@SerialNo		int = 0,
	@SelectedGoods	int = 0,
	@RepOptions		VarChar(20) = '009000', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @LangID		Char(1);
DECLARE @SessionNo  varChar(10);
DECLARE @ReportID   varChar(10);

DECLARE @FirstLayer bit;
DECLARE @WithFormula bit; -- فقط کالاهائی که فرمول تولید دارند
DECLARE @IsDefault	bit;
DECLARE @MaxLevelNo	int;
DECLARE @ProdStepID	int;

DECLARE @StrSelect  nvarchar(4000);
DECLARE @StrWhere	nvarchar(2000);
DECLARE @StrLevel	nvarchar(2000);
DECLARE @QuantityDecimals	int;

DECLARE @UnitPart	TINYINT;
DECLARE @SumOfCount  Bit;
DECLARE @ProductQty2 float ;
DECLARE @ActiveFormula		Bit;
DECLARE @DeActiveFormula	Bit;

BEGIN
	SET NOCOUNT ON;

	--================================== UnitPart
	SET @SumOfCount = 0
	SET @UnitPart   = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @QuantityDecimals=SettingValue From pub.tblSettings
	where SettingKey='QuantityDecimals'


	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	--==================================
	BEGIN TRY
		DROP TABLE ##G
	END TRY
	BEGIN CATCH
	END CATCH
	-- Init ---------------------------------------------------------------------
	IF (@RepInfo Is Null)	 SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null) SET @RepOptions = '109';
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;

	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @ProductQty2	= pub.funSplitString(@RepInfo, '@', 6);

	SET @FirstLayer	= Substring(@RepOptions, 1, 1);
	SET @WithFormula= Substring(@RepOptions, 2, 1);
	SET @MaxLevelNo = Substring(@RepOptions, 3, 1);
	SET @ProdStepID = Substring(@RepOptions, 4, 2);
	SET @SumOfCount = Substring(@RepOptions, 6, 1);
    SET @ActiveFormula		= Substring(@RepOptions, 7, 1);
	SET @DeActiveFormula	= Substring(@RepOptions, 8, 1);
	if (@SerialNo <> 0) 
		set @StrWhere = '(H.SerialNo = ' + Str(@SerialNo) + ')'
	else
		set @StrWhere = '(H.IsDefault = 1)' 

	if (@SelectedGoods > 0 and @FirstLayer = 1)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	if (@WithFormula = 1)
		set @StrWhere = @StrWhere + ' AND (D.GoodsID in (select ProductID from prd.tblFormulasHdr))' 

	if (@ProdStepID <> 0) 
		set @StrWhere = @StrWhere + ' AND (D.ProduceStepID = ' + Str(@ProdStepID) + ')'

	if @ActiveFormula = 1 and @DeActiveFormula=0
		SET @StrWhere = @StrWhere + ' AND GP.CodeClosed =0'
	if @ActiveFormula = 0 and @DeActiveFormula=1
		SET @StrWhere = @StrWhere + ' AND GP.CodeClosed =1'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	set @StrLevel = '(T.Quantity > 0)'
	
	if (@MaxLevelNo > 0)
		set @StrLevel = @StrLevel + ' and Len(T.level) <= ' + ltrim(STR(@MaxLevelNo))
		
	if(@FirstLayer <> 1)
	set @StrLevel = @StrLevel + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'T.GoodsID') 
		
	Declare @ConstPrdText1Name  nVarchar(100)
	Declare @ConstPrdText2Name  nVarchar(100)
	Declare @ConstPrdText3Name  nVarchar(100)
	Declare @ConstPrdText4Name  nVarchar(100)
	Declare @ConstPrdText5Name  nVarchar(100)
	
	Set @ConstPrdText1Name = ''
	Set @ConstPrdText2Name = ''
	Set @ConstPrdText3Name = ''
	Set @ConstPrdText4Name = ''
	Set @ConstPrdText5Name = ''
	
	SELECT @ConstPrdText1Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText1'
	SELECT @ConstPrdText2Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText2'
	SELECT @ConstPrdText3Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText3'
	SELECT @ConstPrdText4Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText4'
	SELECT @ConstPrdText5Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText5'
		
	-----------------------------------------------------------------------------
	-- Select -------------------------------------------------------------------
		IF (@FirstLayer = 1)
	Begin
	set @StrSelect = '
		select T.*, [pub].[funGetGoodsName](T.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') As GoodsName, 
			   [inv].[funGetUnitName](T.UnitID, ' + Ltrim(RTrim(@LangID)) + ') As UnitName,
		isnull((
			select top 1 GoodsAmount
			from inv.tblStorageDocsDtl
			where (GoodsID=T.GoodsID) and (EnterKind=+1) and (GoodsAmount>0)
		),0) LastAmount
		,'''+@ConstPrdText1Name +''' ConstPrdText1Name,'''+@ConstPrdText2Name +''' ConstPrdText2Name,'''+@ConstPrdText3Name +''' ConstPrdText3Name,
	'''+@ConstPrdText4Name +''' ConstPrdText4Name,'''+@ConstPrdText5Name +''' ConstPrdText5Name INTO ##G
	from
		(
			select	H.ProductID, D.GoodsID,D.DefaultStoreID, cast(char(64) as varchar(50)) as level,DocRowNo L2,cast(D.GoodsID as varchar(50)) as GoodsID2
			, round(sum((case when D.ParamKind=1 then  ' + LTrim(str(@ProductQty2,20,@QuantityDecimals)) + '/ H.FmlParam1 else ' + LTrim(str(@ProductQty,20,@QuantityDecimals)) + ' / H.ProductCount end )* D.SubUnitQuantity), 3) as Quantity
				, round(sum((case when D.ParamKind=1 then  ' + LTrim(str(@ProductQty2,20,@QuantityDecimals)) + '/ H.FmlParam1 else ' + LTrim(str(@ProductQty,20,@QuantityDecimals)) + ' / H.ProductCount end )
				 * D.SubUnitQuantity), 10) as SubUnitQuantity,D.UnitID
				,D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5  ,D.ParamKind
		from	prd.tblFormulasDtl D
						INNER JOIN prd.tblFormulasHdr H on D.SerialNo = H.SerialNo and D.ProductID = H.ProductID
						INNER JOIN inv.tblGoods GP on GP.GoodsID =  SUBSTRING(D.ProductID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') 
													 AND GP.PartNumber=' + LTRIM(STR(@UnitPart)) + '
			where  (H.ProductID = ''' + @ProductID + ''') and ' + @StrWhere + '
			group by D.ParamKind, H.ProductID,DocRowNo, D.GoodsID,D.DefaultStoreID,D.UnitID, cast(D.GoodsID as varchar(50)) ,D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5
				)T
		where T.Quantity > 0
		order by GoodsID '		
	END
	ELSE
	BEGIN
	
	DECLARE @strSelectFielsds AS NVARCHAR(MAX)
	DECLARE @strGroup AS NVARCHAR(MAX)
	DECLARE @strOrder AS NVARCHAR(MAX)
	 
	IF (@SumOfCount=0)
	BEGIN 
	
	SET @strSelectFielsds = 'SELECT	T.ProductID, T.GoodsID,T.DefaultStoreID, T.level,L2, space(Len(T.level) * 3) + T.GoodsID as GoodsID2, 
				round(isnull(Sum(Quantity),10), '+ LTRIM(RTRIM(STR(@QuantityDecimals)))+') as Quantity, GD.GoodsName, T.UnitID, UD.UnitName,
				isnull((
					select top 1 GoodsAmount
					from inv.tblStorageDocsDtl
					where (GoodsID=T.GoodsID) and (EnterKind=+1) and (GoodsAmount>0)
				),0) LastAmount
				,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
		,'''+@ConstPrdText1Name +''' ConstPrdText1Name,'''+@ConstPrdText2Name +''' ConstPrdText2Name,'''+@ConstPrdText3Name +''' ConstPrdText3Name,
	'''+@ConstPrdText4Name +''' ConstPrdText4Name,'''+@ConstPrdText5Name +''' ConstPrdText5Name INTO ##G
	FROM	tblTemp T '
	   
	   
	   SET @strGroup= ' T.ProductID, T.GoodsID,T.DefaultStoreID, GoodsName, T.UnitID,UnitName, T.level, T.L2	,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5'
	   
	   SET @strOrder =' T.L2 '
	END
	ELSE IF (@SumOfCount=1)
	BEGIN 
	
		SET @strSelectFielsds = 'SELECT	'''' ProductID, T.GoodsID, '''' level,'''' L2, T.GoodsID as GoodsID2, 
					round(isnull(Sum(Quantity),10), '+ LTRIM(RTRIM(STR(@QuantityDecimals)))+') as Quantity, GD.GoodsName, T.UnitID, UD.UnitName,
					isnull((
						select top 1 GoodsAmount
						from inv.tblStorageDocsDtl
						where (GoodsID=T.GoodsID) and (EnterKind=+1) and (GoodsAmount>0)
					),0) LastAmount
					,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5, 
					''' + @ConstPrdText1Name + ''' ConstPrdText1Name,'''+@ConstPrdText2Name + ''' ConstPrdText2Name,''' + 
					@ConstPrdText3Name + ''' ConstPrdText3Name,
		''' + @ConstPrdText4Name + ''' ConstPrdText4Name,''' + @ConstPrdText5Name + ''' ConstPrdText5Name INTO ##G
		FROM	tblTemp T '
		   
		   
		   SET @strGroup= '  T.GoodsID, GoodsName, T.UnitID, UnitName, ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5'
		   
		   
		   SET @strOrder =' T.GoodsID'
		END


		-- ===========================================================
		SET @StrSelect = '
		WITH tblTemp(ProductID, GoodsID,DefaultStoreID, [level], MQuantity, Quantity, UnitID, L2,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5) AS
		(
			SELECT	H.ProductID, D.GoodsID, D.DefaultStoreID,
				cast(nchar(Row_Number() over (order by D.GoodsID)+64) as varchar(50)) as [level], 
				(case when D.ParamKind=1 then  ' + LTrim(str(@ProductQty2,20,@QuantityDecimals)) + '/ H.FmlParam1 else ' + LTrim(str(@ProductQty,20,@QuantityDecimals)) + ' / H.ProductCount end ) * D.GoodsQuantity As MQuantity,
				(case when D.ParamKind=1 then  ' + LTrim(str(@ProductQty2,20,@QuantityDecimals)) + '/ H.FmlParam1 else ' + LTrim(str(@ProductQty,20,@QuantityDecimals)) + ' / H.ProductCount end ) * D.SubUnitQuantity As Quantity,
				D.UnitID,
				cast(100+(Row_Number() over (order by D.DocRowNo)) as varchar(100)) as L2
			,D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5
			FROM	prd.tblFormulasDtl D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID 
						INNER JOIN inv.tblGoods GP on GP.GoodsID = SUBSTRING(D.ProductID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') 
													 AND GP.PartNumber=' + LTRIM(STR(@UnitPart)) + '
			WHERE  (H.ProductID = ''' + @ProductID + ''') AND ' + @StrWhere + '

			UNION All
			
			SELECT	H.ProductID, D.GoodsID, D.DefaultStoreID,
				cast(tblTemp.level + char(Row_Number() over (order by H.ProductID,D.GoodsID)+64) as varchar(50)) as [level], 
				(tblTemp.MQuantity / H.ProductCount) * D.GoodsQuantity As MQuantity,
				(tblTemp.MQuantity / H.ProductCount) * D.SubUnitQuantity As Quantity,
				D.UnitID,
				cast( ltrim(tblTemp.L2)+''-''+ cast(100+(Row_Number() over (order by H.ProductID,D.DocRowNo)) as char(3)) as varchar(100)) as L2
			,D.ConstPrdText1,D.ConstPrdText2,D.ConstPrdText3,D.ConstPrdText4,D.ConstPrdText5
			FROM	prd.tblFormulasDtl D
						INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID
						INNER JOIN inv.tblGoods GP on GP.GoodsID = SUBSTRING(D.ProductID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') 
													 AND GP.PartNumber=' + LTRIM(STR(@UnitPart)) + ', tblTemp
			WHERE  (H.ProductID = tblTemp.GoodsID) AND ' + @StrWhere + '
		)
		' + @strSelectFielsds +'
		
		LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(T.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') 
													 AND GD.PartNumber=' + LTRIM(STR(@UnitPart)) + ' 
													 AND GD.LanguageID = ' + @LangID + '
		LEFT JOIN inv.tblGoods G	 ON G.GoodsID  = SUBSTRING(T.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') 
													 AND GD.PartNumber=' + LTRIM(STR(@UnitPart)) + '
		LEFT JOIN inv.tblUnitsDtl UD ON UD.UnitID  = T.UnitID and UD.LanguageID = ' + @LangID + '		

		WHERE ' + @StrLevel + '
		GROUP BY '+ @strGroup  + '
		ORDER BY '+ @strOrder 
	End
	-----------------------------------------------------------------------------	 
	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	IF (@SumOfCount=0)

		SELECT G.*,I.GoodsImage 
		FROM ##G G 
		LEFT JOIN inv.tblGoodsImages I 
		ON I.GoodsID = G.GoodsID
		order by G.L2
	else
		SELECT G.*,I.GoodsImage 
		FROM ##G G 
		LEFT JOIN inv.tblGoodsImages I 
		ON I.GoodsID = G.GoodsID
		order by G.GoodsID
END
GO
