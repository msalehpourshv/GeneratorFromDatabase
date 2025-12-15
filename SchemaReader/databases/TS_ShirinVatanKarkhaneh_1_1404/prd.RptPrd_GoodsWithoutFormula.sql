USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/02/02
-- Viewed By	 : 
-- Last Modified : 1389/12/17
-- Description	 : <Goods That Don't Have Any Formula>
--				   لیست قطعات بدون فرمول
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_GoodsWithoutFormula]
	@GroupID	varchar(20) = Null,
	@CodeFr		varchar(20) = Null,
	@CodeTo		varchar(20) = Null,
	@CodeMask	varchar(20) = Null,
	@SortByName	bit = 0   -- مرتب بر اساس اسامی کالاها
WITH ENCRYPTION
AS
Declare @StrSelect NVarChar(1000)

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
		Set @StrSelect = 
		'Select	GD.GoodsID, GD.GoodsName, [pub].[funGetGoodsUnitName] (G.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') UnitName
		 From	inv.tblGoods G
					INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND GD.PartNumber=' + LTRIM(STR(@UnitPart)) + '
					Inner Join inv.tblGoodsGroupsGoodsListDtl GGL On G.GoodsID = GGL.GoodsID
		 Where	(GGL.GoodsGroupID = ''' + LTrim(RTrim(@GroupID)) + ''') and 
				(G.GoodsID Not In (
					Select	ProductID
					From	prd.tblFormulasHdr)) '
	Else 
		Set @StrSelect = 
		'Select GD.GoodsID, GD.GoodsName, [pub].[funGetGoodsUnitName] (G.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') UnitName
		 From	inv.tblGoods G
					INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND GD.PartNumber=' + LTRIM(STR(@UnitPart)) + '
		 Where	G.GoodsID Not In (
					Select	ProductID
					From	prd.tblFormulasHdr)'

	If @CodeFr Is Not Null
		Set @StrSelect = @StrSelect + ' AND G.GoodsID >= ''' + LTrim(RTrim(@CodeFr)) + ''''
	If @CodeTo Is Not Null
		Set @StrSelect = @StrSelect + ' AND G.GoodsID <= ''' + LTrim(RTrim(@CodeTo)) + ''''
	If @CodeMask Is Not Null
		Set @StrSelect = @StrSelect + ' AND G.GoodsID Like ''' + RTrim(Replace(@CodeMask,' ','_')) + '%'''

	If @SortByName = 0
		Set @StrSelect = @StrSelect + ' Order By GD.GoodsID'
	Else
		Set @StrSelect = @StrSelect + ' Order By GD.GoodsName'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
