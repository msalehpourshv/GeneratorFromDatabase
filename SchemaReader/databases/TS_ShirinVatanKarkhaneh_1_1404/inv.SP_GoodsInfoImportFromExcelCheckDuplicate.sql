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
Create PROCEDURE [inv].[SP_GoodsInfoImportFromExcelCheckDuplicate]

WITH ENCRYPTION
 AS
BEGIN
	SELECT CONCAT(GoodsIDL1,GoodsIDL2,GoodsIDL3,GoodsIDL4,GoodsIDL5,GoodsIDL6,GoodsIDL7,GoodsIDL8,GoodsIDL9)GoodsID, Count(*) DuplicateCount
	FROM inv.tblTempGoodsInfoFromExcel 
	GROUP BY CONCAT(GoodsIDL1,GoodsIDL2,GoodsIDL3,GoodsIDL4,GoodsIDL5,GoodsIDL6,GoodsIDL7,GoodsIDL8,GoodsIDL9)
	HAVING Count(*) >1
END
GO
