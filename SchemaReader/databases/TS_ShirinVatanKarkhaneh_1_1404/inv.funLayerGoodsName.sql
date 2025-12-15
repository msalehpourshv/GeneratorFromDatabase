USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1389/03/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE FUNCTION [inv].[funLayerGoodsName]
(
	@FullCode	VarChar(20),
	@Layer		int
)
RETURNS NVarChar(250)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS NVarChar(250);
	DECLARE @Len	AS int;

	-------------------------------------------------------------
	if (@Layer = 1)
		SELECT	@Len = Layer1
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'inv.tblGoods') AND PartNumber=1
	if (@Layer = 2)
		SELECT	@Len = Layer1 + Layer2
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'inv.tblGoods') AND PartNumber=1
	if (@Layer = 3)
		SELECT	@Len = Layer1 + Layer2 + Layer3
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'inv.tblGoods') AND PartNumber=1
	if (@Layer = 4)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'inv.tblGoods') AND PartNumber=1
	if (@Layer = 5)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'inv.tblGoods') AND PartNumber=1
	if (@Layer = 6)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'inv.tblGoods') AND PartNumber=1
	if (@Layer = 7)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'inv.tblGoods') AND PartNumber=1
	if (@Layer = 8)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'inv.tblGoods') AND PartNumber=1
	if (@Layer = 9)
		SELECT	@Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'inv.tblGoods') AND PartNumber=1

	SELECT	@Result = GoodsName
	FROM	inv.tblGoodsDtl
	WHERE	GoodsID = Substring(@FullCode, 1, @Len) AND LanguageID = 1 and PartNumber=1

	RETURN @Result
END
GO
