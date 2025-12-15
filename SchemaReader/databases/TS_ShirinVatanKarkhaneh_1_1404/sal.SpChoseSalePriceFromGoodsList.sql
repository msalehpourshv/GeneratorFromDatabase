USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 93/12/21
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[SpChoseSalePriceFromGoodsList]
	@ProcessID		TinyInt,
	@ProcessNo		TinyInt,
	@FiscalYear	SmallInt,
	@SerialNo		Int
	WITH ENCRYPTION
AS

BEGIN
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

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	update inv.tblGoods
	set SalePrice = s.GoodsPrice
	from inv.tblGoods g
	inner join inv.tblStorageDocsDtl s
	on g.GoodsID=SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)
	WHERE ProcessID=@ProcessID and 
		g.PartNumber=@UnitPart AND 
		  ProcessNo = @ProcessNo and 
		  FiscalYear =@FiscalYear and 
		  SerialNo=@SerialNo
END
GO
