USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Hadi Sadeghi
-- Create date   : 1403/10/29
-- Viewed By	 : 
-- Last Modified :
-- Last Modifier : 
-- ==============================================
Create PROCEDURE [inv].[spGetGoodsAcntGroupWithSaleTypesAcntCode]
WITH ENCRYPTION
AS
BEGIN
	SELECT a.GoodsID,c.SaleTypeID
	,[acc].[funMerg_AcntCode](SaleCostAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  SaleCostAcntCode
	,[acc].[funMerg_AcntCode](RewardCostAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  RewardCostAcntCode
	,GetAcntCodeFromStore
	from (
	SELECT  b.GoodsID,a.P2AcntCode,a.P3AcntCode,a.P4AcntCode 
	FROM inv.tblGoodsAcntGroup a
	INNER JOIN inv.tblGoods b
	ON a.GoodsAcntGroupID=b.GoodsAcntGroupID )a,sal.tblSaleTypes c
	union ALL
	SELECT '',SaleTypeID,SaleCostAcntCode,RewardCostAcntCode,GetAcntCodeFromStore 
    FROM sal.tblSaleTypes

END
GO
