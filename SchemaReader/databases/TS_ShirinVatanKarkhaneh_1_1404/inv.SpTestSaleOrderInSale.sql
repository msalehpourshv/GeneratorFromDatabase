USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\HSR
-- Create date   : 1397/03/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [inv].[SpTestSaleOrderInSale]
	@ProcessID		Int = 110,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = 96,
	@SerialNo		Int = 2381
WITH ENCRYPTION
AS
BEGIN
	SELECT top 1 GoodsID 
	FROM   inv.tblStorageDocsDtl 
	WHERE BaseDocRowNo>0 
	 AND ProcessID = @ProcessID AND ProcessNo = @ProcessNo 
	AND FiscalYear = @FiscalYear AND SerialNo = @SerialNo
	 GROUP BY BatchNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,IsReward,GoodsID,GoodsPrice 
	HAVING COUNT(*)>1
	
END
GO
