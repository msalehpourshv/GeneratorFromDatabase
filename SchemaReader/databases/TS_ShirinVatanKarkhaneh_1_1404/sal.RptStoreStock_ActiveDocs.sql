USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sal].[RptStoreStock_ActiveDocs]
	@StoreID	Varchar(20) = Null,
	@GoodsID	Varchar(20)	= Null
WITH ENCRYPTION
AS

BEGIN

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

SET NOCOUNT ON;

	DECLARE @StrSelect	NVarChar(Max);
	DECLARE @StrWhere	NVarChar(Max);
	
	-- ==========
	DECLARE @UserName NVarChar(4000)
	SET @UserName = ''
	SELECT @UserName = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'Pub_CurrentUserName'
		
	--==============
	SET @LangID = pub.funGetCurrentLanguageID();

	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber < @UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	-- ============================================================= Where
	SET @StrSelect = ''
	SET @StrWhere = 'SS.SubUnitQuantity = 0'
	
	IF (@StoreID <> '') And (@StoreID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND SS.StoreID Like ''%' + @StoreID + '%'''

	IF (@GoodsID <> '') And (@GoodsID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND SS.GoodsID2 = ''' + @GoodsID + ''''
			
	-- ============================================================= Select
	SET @StrSelect = '
		Select  Distinct  LTrim(Str(SS.FiscalYear)) + ''/'' + LTrim(Str(SS.SerialNo)) FiscalSerial 
		From inv.tblStorageDocsDtl SS
		Where ' + @StrWhere 
	-- =============================================================
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	-- =============================================================
		
END
GO
