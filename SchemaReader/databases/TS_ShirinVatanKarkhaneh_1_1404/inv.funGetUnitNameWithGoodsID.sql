USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetUnitNameWithGoodsID] 
(
	@GoodsID	Varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS
BEGIN

--SET @LanguageID = pub.funGetCurrentLanguageID();

	DECLARE @UnitName NVarChar(50)
	DECLARE @UnitPart TINYINT

	SET @UnitPart  = 1
	
	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'
	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @Goods  tinyint,
			@GoodsSum tinyint

	select @Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @GoodsSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2)
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	Set @UnitName = N'-'

	SELECT @UnitName = UnitName
	From inv.tblGoods G,inv.tblUnitsDtl UD
	Where G.UnitID=UD.UnitID AND LanguageID=@LanguageID AND GoodsID=SUBSTRING(@GoodsID,@Goods+1,@GoodsSum) AND G.PartNumber = @UnitPart

	-- Return the result of the function
	RETURN @UnitName 

END
GO
