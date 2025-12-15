USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\H.Sadeghi
-- Create date   : 1400/08/06
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ----------------------------------------------
-- ==============================================
-- SELECT [inv].[FunGetGoodsVolume] ('50100055012520012050')
CREATE FUNCTION [inv].[FunGetGoodsVolume]
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
	DECLARE @GoodsVolume			FLOAT

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
	
	SELECT @GoodsVolume = GoodsLength*GoodsWidth*GoodsHeight
	FROM inv.tblGoods
	WHERE GoodsID = Substring(@GoodsID, @GoodsPrePartLen, @GoodsWeightPartNoLen) 

	Return IsNull(@GoodsVolume, 0)

END
GO
