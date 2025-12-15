USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create FUNCTION [pub].[funGetSubUnitValue]
(
	@GoodsID	Varchar(20),
	@UnitID		Varchar(20)
)
RETURNS VARCHAR(50)
WITH ENCRYPTION
AS

Begin -- === S T A R T ===========================================

	Declare @Result AS VARCHAR(50)
	
	SELECT @Result = UnitValue
	FROM   (SELECT TOP 1 UnitValue
			FROM inv.tblSubUnitsDtl 
			WHERE (GoodsID = @GoodsID OR GoodsID='') AND SubUnitID=@UnitID
			ORDER BY GoodsID desc

		UNION ALL
			SELECT 1 UnitValue
			FROM inv.tblGoods 
			WHERE GoodsID=@GoodsID AND UnitID=@UnitID
			) A
 
	Return ISNULL(@Result,1)
End   -- === E N D ===============================================









GO
