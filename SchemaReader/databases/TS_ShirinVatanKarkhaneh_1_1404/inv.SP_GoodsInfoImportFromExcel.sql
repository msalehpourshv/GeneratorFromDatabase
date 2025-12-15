USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Mahdi Mostafavi
-- Create date   : 1403/07/23
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[SP_GoodsInfoImportFromExcel]
@LanguageID tinyint= 1,
@PartNumber tinyint= 1,
@SessionNo int= 1
WITH ENCRYPTION
 AS
BEGIN

	INSERT INTO [inv].[tblGoods] ([GoodsID],[CodeClosed],[UnitID],[PartNumber],[TechnicalNo],GoodsCID,SessionNo )
	SELECT DISTINCT GoodsIDL1 GoodsID,0 CodeClosed, CASE WHEN GoodsIDL2<>'' THEN '' ELSE UnitID END UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL2<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL1<>'' AND
	GoodsIDL1 not in (select GoodsID from inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2 GoodsID,0 CodeClosed, CASE WHEN GoodsIDL3<>'' THEN '' ELSE UnitID END UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL3<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL2<>''  AND 
	GoodsIDL1+GoodsIDL2 not in (select GoodsID from inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3 GoodsID,0 CodeClosed, CASE WHEN GoodsIDL4<>'' THEN '' ELSE UnitID END UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL4<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL3<>''  AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3 not in (select GoodsID from inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4 GoodsID,0 CodeClosed, CASE WHEN GoodsIDL5<>'' THEN '' ELSE UnitID END UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL5<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL4<>''  AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4 not in (select GoodsID from inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5 GoodsID,0 CodeClosed, CASE WHEN GoodsIDL6<>'' THEN '' ELSE UnitID END UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL6<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL5<>''  AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5 not in (select GoodsID from inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6 GoodsID,0 CodeClosed, CASE WHEN GoodsIDL7<>'' THEN '' ELSE UnitID END UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL7<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL6<>'' AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6 not in (select GoodsID from inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7 GoodsID,0 CodeClosed, CASE WHEN GoodsIDL8<>'' THEN '' ELSE UnitID END UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL8<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL7<>'' AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7 not in (select GoodsID from inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8 GoodsID,0 CodeClosed, CASE WHEN GoodsIDL9<>'' THEN '' ELSE UnitID END UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL9<>'' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL8<>'' AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8 not in (select GoodsID from inv.tblGoods WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 GoodsID,0 CodeClosed,UnitID,@PartNumber PartNumber,CASE WHEN GoodsIDL9='' THEN '' ELSE [TechnicalNo] END TechnicalNo,GoodsCID,@SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL9<>'' AND
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 not in (select GoodsID from inv.tblGoods WHERE PartNumber = @PartNumber)

	INSERT INTO [inv].[tblGoodsDtl] ([GoodsID],[LanguageID],[PartNumber],[GoodsName] )
	SELECT DISTINCT GoodsIDL1 GoodsID,@LanguageID LanguageID,@PartNumber PartNumber,GoodsIDN1 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL1<>'' AND 
	GoodsIDL1 not in (select GoodsID from inv.tblGoodsDtl WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2 GoodsID,@LanguageID LanguageID,@PartNumber PartNumber,GoodsIDN2
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL2<>''  AND 
	GoodsIDL1+GoodsIDL2 not in (select GoodsID from inv.tblGoodsDtl WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3 GoodsID,@LanguageID LanguageID,@PartNumber PartNumber,GoodsIDN3 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL3<>''  AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3 not in (select GoodsID from inv.tblGoodsDtl WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4 GoodsID,@LanguageID LanguageID,@PartNumber PartNumber,GoodsIDN4 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL4<>''  AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4 not in (select GoodsID from inv.tblGoodsDtl WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5 GoodsID,@LanguageID LanguageID,@PartNumber PartNumber,GoodsIDN5 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL5<>''  AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5 not in (select GoodsID from inv.tblGoodsDtl WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6 GoodsID,@LanguageID LanguageID,@PartNumber PartNumber,GoodsIDN6 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL6<>'' AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6 not in (select GoodsID from inv.tblGoodsDtl WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7 GoodsID,@LanguageID LanguageID,@PartNumber PartNumber,GoodsIDN7 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL7<>'' AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7 not in (select GoodsID from inv.tblGoodsDtl WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8 GoodsID,@LanguageID LanguageID,@PartNumber PartNumber,GoodsIDN8 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE GoodsIDL8<>'' AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8 not in (select GoodsID from inv.tblGoodsDtl WHERE PartNumber = @PartNumber)
	UNION ALL
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 GoodsID,@LanguageID LanguageID,@PartNumber PartNumber,GoodsIDN9 
	FROM inv.tblTempGoodsInfoFromExcel
	WHERE GoodsIDL9<>'' AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 not in (select GoodsID from inv.tblGoodsDtl WHERE PartNumber = @PartNumber)

	INSERT INTO [inv].[tblSubUnitsHdr] ([GoodsID],SessionNo)
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 GoodsID, @SessionNo SessionNo 
	FROM inv.tblTempGoodsInfoFromExcel 
	WHERE  UnitValue<>0 AND MainUnitValue<>0 AND GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9<>'' AND 
	GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 not in (select GoodsID from inv.tblSubUnitsHdr WHERE PartNumber = @PartNumber)

	INSERT INTO [inv].[tblSubUnitsDtl] ([GoodsID],[SubUnitID],[UnitValue],[MainUnitValue],[ShowInInvoice])
	SELECT DISTINCT GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 GoodsID,SubUnitID,UnitValue,MainUnitValue,ShowInInvoice 
	FROM inv.tblTempGoodsInfoFromExcel a
	WHERE UnitValue<>0 AND MainUnitValue<>0 AND GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9<>'' AND 
	(select COUNT(*) from inv.tblSubUnitsDtl b WHERE GoodsIDL1+GoodsIDL2+GoodsIDL3+GoodsIDL4+GoodsIDL5+GoodsIDL6+GoodsIDL7+GoodsIDL8+GoodsIDL9 =b.GoodsID and a.SubUnitID=b.SubUnitID  ) = 0

	UPDATE inv.tblGoods
	SET UnitID =UI
	FROM inv.tblGoods a
	INNER JOIN 
		(SELECT (SELECT TOp 1 UnitID 
				 FROM inv.tblGoods b 
				 WHERE a.PartNumber = b.PartNumber 
				   AND a.GoodsID=SUBSTRING(b.GoodsID,1,len(a.GoodsID)) 
				   AND b.UnitID<>'' ) UI,
				GoodsID,
				PartNumber 
		 FROM inv.tblGoods a 
		 WHERE GoodsID LIKE '2%' AND UnitID=''
		) b
	ON a.GoodsID=b.GoodsID AND a.PartNumber=b.PartNumber
END
GO
