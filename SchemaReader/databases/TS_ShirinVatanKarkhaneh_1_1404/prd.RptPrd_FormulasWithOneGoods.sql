USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1386/02/02
-- Viewed By	 : 
-- Last Modified : 1389/12/17
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Formulas that Include One Goods>
-- لیست فرمولهای تولید شامل یک قطعه             --
-- ==============================================
--[prd].[RptPrd_FormulasWithOneGoods] '4190610251'
Create PROCEDURE [prd].[RptPrd_FormulasWithOneGoods] 
	@GoodsID	VarChar(22)
WITH ENCRYPTION
AS

DECLARE	@LangID	Char(1);
DECLARE	@FormulasWithOneGoods_Similar	Char(1);
Declare @FormulaState		char(1);
Declare @ProductIDRule		char(1);
Declare @PartNumber	int;
Declare @strWhere	VarChar(500);
Declare @strSelect	NVarChar(max);

set @strWhere = ''

SELECT @PartNumber = SettingValue 	
FROM pub.tblSettings 	
WHERE SettingKey = 'UnitPart'

Set @PartNumber=isnull(@PartNumber,1)
	if @PartNumber=0
		set @PartNumber=1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint	

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@PartNumber

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@PartNumber

	Set @ProductIDRule	  = Substring(@GoodsID, len(@GoodsID), 1) ;
	Set @FormulaState	  = Substring(@GoodsID, len(@GoodsID)-1, 1);
	set @GoodsID  = Substring(@GoodsID, 1, len(@GoodsID)-2);
	
	--select  @GoodsID =  SUBSTRING(@GoodsID,@str_Goods+ 1, @str_GoodsSum)

	if (@FormulaState = 1)
		SET @strWhere = @strWhere + ' AND FH.IsDefault in (0,1) '
	
	if (@FormulaState = 2)
		SET @strWhere = @strWhere + ' AND (FH.IsDefault = 1)' 

	if (@ProductIDRule = 1)
		SET @strWhere = @strWhere + ' AND (G.CodeClosed = 0)' 

	if (@ProductIDRule = 2)
		SET @strWhere = @strWhere + ' AND (G.CodeClosed = 1)' 

	if (@ProductIDRule = 3)
		SET @strWhere = @strWhere

BEGIN
	SET NOCOUNT ON;
	SET @LangID	= 1

	Set @strSelect = '
	SELECT FH.FormulaName, FH.SerialNo, FH.ProductID, FH.ProductCount As ProductQty, 
		   pub.funGetGoodsName(FH.ProductID, '+@LangID+') As GoodsName, 
		   FD.GoodsQuantity, FD.DocRowNo RowNo, 0 IsSimilar 
	FROM prd.tblFormulasHdr FH
	LEFT JOIN prd.tblFormulasDtl FD ON FH.ProductID = FD.ProductID AND FH.SerialNo = FD.SerialNo
	LEFT JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(FD.ProductID,' + LTrim(RTrim(STR(@str_Goods+1))) + ',' + LTrim(RTrim(STR(@str_GoodsSum))) + ') AND G.PartNumber='+str(LTrim(RTrim(@PartNumber)))+'
	WHERE FD.GoodsID = '''+LTrim(RTrim(@GoodsID))+ ''' ' + @strWhere +'

	UNION

	SELECT FH.FormulaName, FH.SerialNo, FH.ProductID, FH.ProductCount As ProductQty, 
		   pub.funGetGoodsName(FH.ProductID, '+@LangID+') As GoodsName, 
		   FA.GoodsQuantity, FA.DocRowNo RowNo, 1 IsSimilar 
	FROM prd.tblFormulasHdr FH
	LEFT JOIN prd.tblFormulasAtm FA ON FH.ProductID = FA.ProductID AND FH.SerialNo = FA.SerialNo
	LEFT JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(FA.ProductID,' + LTrim(RTrim(STR(@str_Goods+1))) + ',' + LTrim(RTrim(STR(@str_GoodsSum))) + ') AND G.PartNumber='+str(LTrim(RTrim(@PartNumber)))+'
	WHERE FA.GoodsID = '''+LTrim(RTrim(@GoodsID))+ ''' ' + @strWhere +'

	ORDER BY ProductID'
	Print @strSelect;
	Exec sp_executesql @strSelect;
END
GO
