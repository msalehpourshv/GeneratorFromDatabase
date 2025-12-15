USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1395/08/19
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : Inv Transfer Docs
-- ----------------------------------------------
-- ==============================================
-- EXEC [inv].[SPGetGoodsWeight] '50100055012520012050'
CREATE PROCEDURE [inv].[SPGetGoodsWeight]
	@GoodsID VarChar(20)
	
WITH ENCRYPTION
AS

DECLARE @GoodsPrePartLen		Int
DECLARE @GoodsPartLen1 			Int
DECLARE @GoodsPartLen2 			Int
DECLARE @GoodsPartLen3 			Int
DECLARE @GoodsPartLen4 			Int
DECLARE @GoodsPartLen5 			Int

DECLARE @GoodsWeightPartNo		Int
DECLARE @GoodsWeightPartNoLen	Int
DECLARE @GoodsWeightField		NVarchar(100)

DECLARE @GoodsWeight			Int

BEGIN
	--========================
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  Tinyint,
			@str_GoodsSum Tinyint

	Select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	From pub.tblCodeLayer 
	Where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	Select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer 
	Where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
		
	-- ==========
	SET @GoodsWeightPartNo = 0

	-- ==========
	SELECT @GoodsWeightPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GoodsWidthPartNo'

	If @GoodsWeightPartNo = 0
		SET @GoodsWeightPartNo = 1

	Select @GoodsWeightField = SettingValue
	From pub.tblSettings
	Where SettingKey = 'GoodsWidthField'
	
	-- ==========
	Select @GoodsPrePartLen = Sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9) + 1
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber < @GoodsWeightPartNo
	
	Select @GoodsWeightPartNoLen = Sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9)
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = @GoodsWeightPartNo
		
	-- ==========
	Select @GoodsPartLen1 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 1
	
	Select @GoodsPartLen2 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 2
	
	Select @GoodsPartLen3 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 3
	
	Select @GoodsPartLen4 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 4
	
	Select @GoodsPartLen5 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 5
		
	-- ==========
	SELECT GoodsWeight
	FROM inv.tblGoods
	WHERE GoodsID = Substring(@GoodsID,@GoodsPrePartLen,@GoodsWeightPartNoLen) And PartNumber = @GoodsWeightPartNo	
	--WHERE GoodsID = SUBSTRING(@GoodsID, @str_Goods+1, @str_GoodsSum) AND PartNumber = @UnitPart

END
GO
