USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create FUNCTION [pub].[funGetMainUnitValue]
(
	@GoodsID	Varchar(20),
	@UnitID		Varchar(20)
)
RETURNS VARCHAR(50)
WITH ENCRYPTION
AS

Begin -- === S T A R T ===========================================

	Declare @Result AS VARCHAR(50)
	
	SELECT top 1 @Result = MainUnitValue
	FROM   (SELECT GoodsID, MainUnitValue
			FROM inv.tblSubUnitsDtl 
			WHERE (GoodsID = @GoodsID OR GoodsID='') AND SubUnitID=@UnitID
		UNION ALL
			SELECT GoodsID,1 MainUnitValue
			FROM inv.tblGoods 
			WHERE GoodsID=@GoodsID AND UnitID=@UnitID
			) A
	ORDER BY GoodsID desc
 
	Return ISNULL(@Result,1)
End   -- === E N D ===============================================









GO
