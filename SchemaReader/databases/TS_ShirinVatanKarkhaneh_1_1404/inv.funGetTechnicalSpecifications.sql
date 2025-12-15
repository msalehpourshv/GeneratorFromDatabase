USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetTechnicalSpecifications] 
(
	@GoodsID Varchar(20)
)
RETURNS NVarChar(500)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @TechnicalSpecifications NVarChar(50)
	DECLARE @UnitPart TINYINT

	Set @TechnicalSpecifications = N'-'
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

	SELECT @TechnicalSpecifications = TechnicalSpecifications
	From inv.tblGoods
	Where GoodsID=SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber = @UnitPart

	-- Return the result of the function
	RETURN @TechnicalSpecifications

END









GO
