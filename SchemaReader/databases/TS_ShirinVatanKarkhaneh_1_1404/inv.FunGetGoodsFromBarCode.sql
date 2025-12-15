USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[FunGetGoodsFromBarCode]
(
	@Barcode	VarChar(20)
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS

Begin -- ====================================================

	Declare @StrResult AS NVarChar(50)
	Declare @intIsMultiGoods AS Tinyint
	Declare @StartGoodsBarcode AS Tinyint
	Declare @LenGoodsBarcode AS Tinyint
	
	SET @StrResult = ''
	SET @intIsMultiGoods = 0
	SET @StartGoodsBarcode = 0
	SET @LenGoodsBarcode = 0
	
	SELECT @StartGoodsBarcode = SettingValue from pub.tblSettings where SettingKey = 'StartGoodsBarcode'
	SELECT @LenGoodsBarcode = SettingValue from pub.tblSettings where SettingKey = 'LenGoodsBarcode'

	Select @intIsMultiGoods = Layer1 
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 2 
	
	IF @intIsMultiGoods > 0 And @intIsMultiGoods < 20
		Select @StrResult = IsNull(GoodsID, '')
		From   inv.tblGoodsBarCodeDtl
		Where  BarCode = @Barcode
	
	ELSE
		Select @StrResult = IsNull(GoodsID, '')
		From   inv.tblGoods
		Where  BarCode = @Barcode	

	IF @StrResult = '' OR @StrResult Is Null
		Select Top 1 @StrResult = IsNull(GoodsID, '') 
		From inv.tblGoodsBarcodListDtl
		Where BarCode = @Barcode

	IF (@StrResult = '' OR @StrResult Is Null) and @LenGoodsBarcode> 0
	BEGIN
		IF @intIsMultiGoods > 0 And @intIsMultiGoods < 20
			Select @StrResult = IsNull(GoodsID, '')
			From   inv.tblGoodsBarCodeDtl
			Where  BarCode = SUBSTRING(@Barcode,@StartGoodsBarcode,@LenGoodsBarcode)
	
		ELSE
			Select @StrResult = IsNull(GoodsID, '')
			From   inv.tblGoods
			Where  BarCode = SUBSTRING(@Barcode,@StartGoodsBarcode,@LenGoodsBarcode)	

		IF @StrResult = '' OR @StrResult Is Null
			Select Top 1 @StrResult = IsNull(GoodsID, '') 
			From inv.tblGoodsBarcodListDtl
			Where BarCode = SUBSTRING(@Barcode,@StartGoodsBarcode,@LenGoodsBarcode)
	END


	Return @StrResult

END
GO
