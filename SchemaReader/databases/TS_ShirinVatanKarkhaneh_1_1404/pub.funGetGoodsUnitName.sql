USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetGoodsUnitName] 
(
	@GoodsID    varChar(20) ,
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

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2)
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

			
	Set @UnitName = N'-'

    SELECT @UnitName =UnitName
    FROM inv.tblUnitsDtl
    WHERE LanguageID = @LanguageID AND 
          UnitID=(SELECT  UnitID
	              From inv.tblGoods
	              Where GoodsID = SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber = @UnitPart) 


	-- Return the result of the function
	RETURN @UnitName 

END














GO
