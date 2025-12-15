USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[FunGetGoodsBarCode]
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
	
	Select @intIsMultiGoods = Layer1 
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 2 
	
	IF @intIsMultiGoods > 0 And @intIsMultiGoods < 20
		Select @StrResult = IsNull(BarCode, '')
		From   inv.tblGoodsBarCodeDtl
		Where  GoodsID = @GoodsID
	
	ELSE
		Select @StrResult = IsNull(BarCode, '')
		From   inv.tblGoods
		Where  GoodsID = @GoodsID
		
	IF @StrResult = '' OR @StrResult Is Null
		Select Top 1 @StrResult = IsNull(BarCode, '') 
		From inv.tblGoodsBarcodListDtl
		Where GoodsID = @GoodsID

	Return @StrResult

END
GO
