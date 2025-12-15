USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [inv].[funGetGoodsSubQuantity]
(
	@GoodsID as nvarchar(20), 
	@SubUnitID as nvarchar(20),
	@MainValue as Decimal(28,8)
)
RETURNS Decimal(28,8)
WITH ENCRYPTION
AS
BEGIN

declare @Unit as varchar(20)
declare @Result as Decimal(28,8)

SET @Result = @MainValue

select @Unit =	UnitID   
from inv.tblGoods
where GoodsID = @GoodsID

If @Unit = @SubUnitID 
	set @Result = @MainValue
Else
	select top 1 @Result = @MainValue *  UnitValue / MainUnitValue
	from inv.tblSubUnitsDtl
	where GoodsID = @GoodsID And SubUnitID = @SubUnitID

IF @Result IS NULL
	SET @Result = @MainValue
	
	Declare @Dec int
		Select @Dec =isnull(SettingValue,3) From pub.tblSettings where  SettingKey='QuantityDecimalsToForms'
return  round( @Result,10)


END
GO
