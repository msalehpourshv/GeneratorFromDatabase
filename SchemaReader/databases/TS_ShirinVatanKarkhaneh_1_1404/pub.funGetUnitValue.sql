USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetUnitValue]
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
	FROM   (SELECT  convert(nvarchar(50),MainUnitValue)  + '$$' + convert(nvarchar(50),UnitValue) + case WHEN TolerancePercent <>0 OR ToleranceValue<> 0 THEN '$$1' ELSE '$$0' END  + '$$' +ltrim(TolerancePercent)+ '$$' +ltrim(ToleranceValue ) UnitValue  
			FROM inv.tblSubUnitsDtl 
			WHERE GoodsID=@GoodsID AND SubUnitID=@UnitID
		UNION ALL
			SELECT  convert(nvarchar(50),MainUnitValue)  + '$$' + convert(nvarchar(50),UnitValue) + case WHEN TolerancePercent <>0 OR ToleranceValue<> 0 THEN '$$1' ELSE '$$0' END  + '$$' +ltrim(TolerancePercent)+ '$$' +ltrim(ToleranceValue) UnitValue 
			FROM inv.tblSubUnitsDtl 
			WHERE GoodsID='' AND SubUnitID=@UnitID	AND (SELECT COUNT(*) FROM inv.tblSubUnitsDtl WHERE GoodsID=@GoodsID AND SubUnitID=@UnitID)=0
		UNION ALL
			SELECT '1$$1$$0$$0$$0' UnitValue
			FROM inv.tblGoods 
			WHERE GoodsID=@GoodsID AND UnitID=@UnitID
			) A
 
	Return ISNULL(@Result,'1$$1$$0$$0$$0')
End   -- === E N D ===============================================
GO
