USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetSaleOrderGoodsWeight]
(
	@ProcessID		Int = 180,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null
)
RETURNS FLOAT
WITH ENCRYPTION            
AS
BEGIN

 	DECLARE	@GoodsID		Varchar(20)
	DECLARE @GoodsQuantity	Float
	DECLARE @Result			Float
	Set @Result = 0
	
	DECLARE @UnitPart TINYINT
	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	SET @UnitPart  = 1
	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	SELECT	@Result=SUM(GoodsQuantity * GoodsWeight )
	FROM sal.tblSaleOrderDtl a
	inner join  inv.tblGoods b
	on SUBSTRING(a.GoodsID,@str_Goods+1,@str_GoodsSum)=b.GoodsID and b.PartNumber=@UnitPart
	WHERE ProcessID = @ProcessID And ProcessNo = @ProcessNo And FiscalYear = @FiscalYear And
		  SerialNo = @SerialNo

	RETURN ISNULL(@Result ,0)

END
GO
