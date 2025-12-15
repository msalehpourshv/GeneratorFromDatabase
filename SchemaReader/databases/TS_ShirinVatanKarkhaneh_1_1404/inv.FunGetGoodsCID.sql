USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[FunGetGoodsCID]
(
	@GoodsID	VarChar(20)
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS

Begin -- ====================================================

	Declare @StrResult AS NVarChar(50)
	Declare @intIsMultiGoods AS Tinyint
	
	SET @StrResult = ''
	SET @intIsMultiGoods = 0
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

IF @UnitPart IS NULL or @UnitPart = 0
	SET @UnitPart = 1
	Select @intIsMultiGoods = Layer1 
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 2 
	
	IF @intIsMultiGoods > 0 And @intIsMultiGoods < 20
		Select @StrResult = IsNull(GoodsCID, '')
		From   inv.tblGoodsBarCodeDtl
		Where  GoodsID = @GoodsID
	
	IF @StrResult = ''
		Select @StrResult = IsNull(GoodsCID, '')
		From   inv.tblGoods
		Where  GoodsID = @GoodsID AND PartNumber = @UnitPart

	Return @StrResult

END
GO
