USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION inv.funGetUnitQuantity
(
	@GoodsID as nvarchar(20), 
	@SubUnitID as nvarchar(20)
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN

declare @Unit as varchar(20)
declare @Result as varchar(20)

select @Unit =	UnitID   
from inv.tblGoods
where GoodsID = @GoodsID

If @Unit = @SubUnitID 
	set @Result = 1
Else
	select top 1 @Result = UnitValue
	from inv.tblSubUnitsDtl
	where (GoodsID = @GoodsID OR GoodsID='')  And SubUnitID = @SubUnitID
	ORDER BY GoodsID desc


return @Result

END

GO
