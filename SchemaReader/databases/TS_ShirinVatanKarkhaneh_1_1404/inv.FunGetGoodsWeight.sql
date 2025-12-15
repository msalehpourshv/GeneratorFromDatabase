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
-- SELECT [inv].[FunGetGoodsWeight] ('50100055012520012050')
CREATE FUNCTION [inv].[FunGetGoodsWeight] 
(
	@GoodsID VarChar(20)
)

RETURNS FLOAT
WITH ENCRYPTION
AS
BEGIN
	DECLARE @GoodsPrePartLen		Int
	DECLARE @UnitPart		Int
	DECLARE @GoodsWeightPartNoLen	Int
	DECLARE @GoodsWeight			FLOAT

	-- ==========
	SET @UnitPart = 0

	-- ==========
	SELECT @UnitPart = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'UnitPart'

	If @UnitPart = 0
		SET @UnitPart = 1

	
	-- ==========
	Select @GoodsPrePartLen = IsNull(Sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9), 0) + 1
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber < @UnitPart
	
	Select @GoodsWeightPartNoLen = IsNull(Sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9), 0)
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = @UnitPart
		
	-- ==========
	
	SELECT @GoodsWeight = GoodsWeight
	FROM inv.tblGoods
	WHERE GoodsID = Substring(@GoodsID, @GoodsPrePartLen, @GoodsWeightPartNoLen) 

	Return IsNull(@GoodsWeight, 0)

END
GO
