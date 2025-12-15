USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Mahdi Mostafavi
-- Create date   : 1403/07/30
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[SP_GoodsInfoImportFromExcelCheckFaults]
@PartNumber tinyint= 1
WITH ENCRYPTION
 AS
BEGIN
	SELECT GoodsIDL1 FROM inv.tblTempGoodsInfoFromExcel WHERE GoodsIDL1 <> '' AND LEN(GoodsIDL1) <> (SELECT [Layer1] FROM [pub].[tblCodeLayer] WHERE [TableName] = 'inv.tblGoods' and PartNumber = @PartNumber)
	UNION ALL		                                                                                                                                                                         
 	SELECT GoodsIDL2 FROM inv.tblTempGoodsInfoFromExcel WHERE GoodsIDL2 <> '' AND LEN(GoodsIDL2) <> (SELECT [Layer2] FROM [pub].[tblCodeLayer] WHERE [TableName] = 'inv.tblGoods' and PartNumber = @PartNumber)
	UNION ALL		                                                                                                                                                                          
 	SELECT GoodsIDL3 FROM inv.tblTempGoodsInfoFromExcel WHERE GoodsIDL3 <> '' AND LEN(GoodsIDL3) <> (SELECT [Layer3] FROM [pub].[tblCodeLayer] WHERE [TableName] = 'inv.tblGoods' and PartNumber = @PartNumber)
	UNION ALL		                                                                                                                                                                           
 	SELECT GoodsIDL4 FROM inv.tblTempGoodsInfoFromExcel WHERE GoodsIDL4 <> '' AND LEN(GoodsIDL4) <> (SELECT [Layer4] FROM [pub].[tblCodeLayer] WHERE [TableName] = 'inv.tblGoods' and PartNumber = @PartNumber)
	UNION ALL		                                                                                                                                                                           
 	SELECT GoodsIDL5 FROM inv.tblTempGoodsInfoFromExcel WHERE GoodsIDL5 <> '' AND LEN(GoodsIDL5) <> (SELECT [Layer5] FROM [pub].[tblCodeLayer] WHERE [TableName] = 'inv.tblGoods' and PartNumber = @PartNumber)
	UNION ALL		                                                                                                                                                                           
 	SELECT GoodsIDL6 FROM inv.tblTempGoodsInfoFromExcel WHERE GoodsIDL6 <> '' AND LEN(GoodsIDL6) <> (SELECT [Layer6] FROM [pub].[tblCodeLayer] WHERE [TableName] = 'inv.tblGoods' and PartNumber = @PartNumber)
	UNION ALL		                                                                                                                                                                           
 	SELECT GoodsIDL7 FROM inv.tblTempGoodsInfoFromExcel WHERE GoodsIDL7 <> '' AND LEN(GoodsIDL7) <> (SELECT [Layer7] FROM [pub].[tblCodeLayer] WHERE [TableName] = 'inv.tblGoods' and PartNumber = @PartNumber)
	UNION ALL		                                                                                                                                                                           
 	SELECT GoodsIDL8 FROM inv.tblTempGoodsInfoFromExcel WHERE GoodsIDL8 <> '' AND LEN(GoodsIDL8) <> (SELECT [Layer8] FROM [pub].[tblCodeLayer] WHERE [TableName] = 'inv.tblGoods' and PartNumber = @PartNumber)
	UNION ALL		                                                                                                                                                                           
 	SELECT GoodsIDL9 FROM inv.tblTempGoodsInfoFromExcel WHERE GoodsIDL9 <> '' AND LEN(GoodsIDL9) <> (SELECT [Layer9] FROM [pub].[tblCodeLayer] WHERE [TableName] = 'inv.tblGoods' and PartNumber = @PartNumber)
END
GO
