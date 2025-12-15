USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetUnitCountForGoods]
(
	@GoodsID AS VarChar(20)
)
RETURNS int
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS int

	SELECT	@Result = Count(GoodsID) +
		isnull((SELECT COUNT(*) FROM  inv.tblSubUnitsDtl 
		        WHERE GoodsID='' AND UnitID in 
									 (SELECT UnitID FROM inv.tblGoods 
									  WHERE GoodsID = @GoodsID )
				),0)
	FROM	inv.tblSubUnitsDtl
	WHERE	GoodsID = @GoodsID

	RETURN @Result
END

GO
