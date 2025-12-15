USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION inv.UQ2
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
	
	select @Unit = UnitID   
	from inv.tblGoods
	where GoodsID = @GoodsID
	
	If (@Unit = @SubUnitID)
		select @SubUnitID = SubUnitID
		from inv.tblSubUnitsDtl
		where (GoodsID = @GoodsID OR GoodsID='') And (ShowInInvoice = 1)
		ORDER BY GoodsID desc
	
	select top 1 @Result = case when (MainUnitValue<UnitValue) then 0 else MainUnitValue/UnitValue end
	from inv.tblSubUnitsDtl
	where (GoodsID = @GoodsID OR GoodsID='') And (SubUnitID = @SubUnitID)
	ORDER BY GoodsID desc

	return @Result
END
GO
