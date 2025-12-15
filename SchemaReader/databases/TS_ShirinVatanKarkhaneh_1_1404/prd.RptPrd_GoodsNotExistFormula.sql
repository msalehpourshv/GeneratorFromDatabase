USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/02/02
-- Viewed By	 : 
-- Last Modified : 1386/08/29
-- Description	 : <Goods That Don't Have Any Formula>
-- لیست قطعاتی که در هیچ فرمولی شرکت ندارند
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_GoodsNotExistFormula]
	@GroupID	varchar(20) = Null,
	@CodeFr		varchar(20) = Null,
	@CodeTo		varchar(20) = Null,
	@CodeMask	varchar(20) = Null,
	@SortByName	bit = 0     -- مرتب بر اساس اسامی کالاها
WITH ENCRYPTION
AS

Declare @StrSelect NVarChar(2000)
DECLARE @UnitPart	TINYINT
DECLARE	@LangID	   Char(1);

Begin
	SET NOCOUNT ON;
	
	SET @LangID	= 1
	
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

	If (@GroupID Is Not Null)
		Set @StrSelect = '
		SELECT	GD.GoodsID, GD.GoodsName, [pub].[funGetGoodsUnitName] (G.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') UnitName
		FROM	inv.tblGoods G
					INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND GD.PartNumber=' + LTRIM(STR(@UnitPart)) + '
					Inner Join inv.tblGoodsGroupsGoodsListDtl GGL ON G.GoodsID = GGL.GoodsID
		WHERE	(GGL.GoodsGroupID = ''' + Ltrim(RTrim(@GroupID)) + ''') AND 
				(G.GoodsID Not In ( 
					Select	GoodsID
			        From	prd.tblFormulasDtl ))'
	Else 
		Set @StrSelect = '
		SELECT	GD.GoodsID,	GD.GoodsName, [pub].[funGetGoodsUnitName] (G.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') UnitName
		FROM	inv.tblGoods G
					INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND GD.PartNumber=' + LTRIM(STR(@UnitPart)) + '
		WHERE	G.GoodsID Not IN ( 
					SELECT	GoodsID
				    FROM	prd.tblFormulasDtl) '
  
	If (@CodeFr Is Not Null)
		Set @StrSelect = @StrSelect + ' AND (G.GoodsID >= ''' + LTrim(RTrim(@CodeFr)) + ''')'
	If (@CodeTo Is Not Null)
		Set @StrSelect = @StrSelect + ' AND (G.GoodsID <= ''' + LTrim(RTrim(@CodeTo)) + ''')'
	If (@CodeMask Is Not Null)
		Set @StrSelect = @StrSelect + ' AND (G.GoodsID LIKE ''' + RTrim(Replace(@CodeMask,' ','_')) + '%'')'

	If (@SortByName = 0)
		Set @StrSelect = @StrSelect + ' ORDER BY GD.GoodsID'
	Else
		Set @StrSelect = @StrSelect + ' ORDER BY GD.GoodsName'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
