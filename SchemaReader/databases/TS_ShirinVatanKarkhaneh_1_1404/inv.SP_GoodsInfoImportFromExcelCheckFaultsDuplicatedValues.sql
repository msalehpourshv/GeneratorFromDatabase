USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [inv].[SP_GoodsInfoImportFromExcelCheckFaultsDuplicatedValues]
 
@LanguageID tinyint= 1,
@PartNumber tinyint= 1,
@SessionNo  int= 41

WITH ENCRYPTION
 AS
BEGIN

	SELECT GoodsID,Count(*) Cnt 
	FROM (
	SELECT DISTINCT GoodsIDL1 GoodsID,0 CodeClosed,'' UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL2<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL1<>'' AND
	GoodsIDL1 not in (SELECT GoodsID FROM inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2 GoodsID,0 CodeClosed,'' UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL3<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL2<>''  AND 
	GoodsIDL1+GoodsIDL2 not in (SELECT GoodsID FROM inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3 GoodsID,0 CodeClosed,'' UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL4<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL3<>''  AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3 not in (SELECT GoodsID FROM inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4 GoodsID,0 CodeClosed,'' UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL5<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL4<>''  AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4 not in (SELECT GoodsID FROM inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5 GoodsID,0 CodeClosed,'' UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL6<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL5<>''  AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5 not in (SELECT GoodsID FROM inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6 GoodsID,0 CodeClosed,'' UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL7<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL6<>'' AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6 not in (SELECT GoodsID FROM inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7 GoodsID,0 CodeClosed,'' UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL8<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL7<>'' AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7 not in (SELECT GoodsID FROM inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8 GoodsID,0 CodeClosed,'' UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL9<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL8<>'' AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8 not in (SELECT GoodsID FROM inv.tblGoods WHERE PartNumber = @PartNumber)
	--لایه آخر در پایین است
	--UNION ALL 
	--SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 GoodsID,0 CodeClosed,'' UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL9='' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	--FROM inv.tblTempGoodsInfoFromExcel 
	--WHERE GoodsIDL9<>'' AND
	--GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 not in (SELECT GoodsID FROM inv.tblGoods WHERE PartNumber = @PartNumber)
	)a
	GROUP BY GoodsID
	HAVING COUNT(*)>1

	UNION

	SELECT GoodsID,Count(*) Cnt 
	FROM (

		SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 GoodsID,0 CodeClosed, UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL9='' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
		FROM inv.tblTempGoodsInfoFromExcel 
		WHERE GoodsIDL9<>'' AND
		GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 not in (SELECT GoodsID FROM inv.tblGoods WHERE PartNumber = @PartNumber)
	)a
	GROUP BY GoodsID
	HAVING COUNT(*)>1
END
GO
