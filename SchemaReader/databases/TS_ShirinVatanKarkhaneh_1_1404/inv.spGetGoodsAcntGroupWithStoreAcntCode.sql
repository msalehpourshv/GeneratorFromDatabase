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
Create PROCEDURE [inv].[spGetGoodsAcntGroupWithStoreAcntCode]
WITH ENCRYPTION
AS
BEGIN

	SELECT a.GoodsID,c.StoreID
	,[acc].[funMerg_AcntCode](StockAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  StockAcntCode
	,[acc].[funMerg_AcntCode](InventoryModificationAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  InventoryModificationAcntCode
	,[acc].[funMerg_AcntCode](BuyReturnCostAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  BuyReturnCostAcntCode
	,[acc].[funMerg_AcntCode](GoodsInProductionAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  GoodsInProductionAcntCode
	,[acc].[funMerg_AcntCode](RewardCostAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  RewardCostAcntCode
	,[acc].[funMerg_AcntCode](SaleCostAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  SaleCostAcntCode
	,[acc].[funMerg_AcntCode](OurTrustReturnCostAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  OurTrustReturnCostAcntCode
	,[acc].[funMerg_AcntCode](OtherTrustReturnCostAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  OtherTrustReturnCostAcntCode
	,[acc].[funMerg_AcntCode](TransferStockAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  TransferStockAcntCode
	,[acc].[funMerg_AcntCode](TransferBenefitCostAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  TransferBenefitCostAcntCode
	,[acc].[funMerg_AcntCode](WageCostAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)  WageCostAcntCode
	from (
	SELECT  b.GoodsID,a.P2AcntCode,a.P3AcntCode,a.P4AcntCode 
	FROM inv.tblGoodsAcntGroup a
	INNER JOIN inv.tblGoods b
	ON a.GoodsAcntGroupID=b.GoodsAcntGroupID )a,inv.tblStores c
	union ALL
	select '',StoreID, StockAcntCode,InventoryModificationAcntCode,
	BuyReturnCostAcntCode,GoodsInProductionAcntCode,RewardCostAcntCode,
	SaleCostAcntCode,OurTrustReturnCostAcntCode,OtherTrustReturnCostAcntCode,
	TransferStockAcntCode,TransferBenefitCostAcntCode,WageCostAcntCode
	from inv.tblStores
END

--مصرف داخلی , نوع فروش و برگشت از تحویل دارایی,BranchTransferStockAcntCode وکد حسابداری واسطه انبار بین شعب در شعبه
--OverLoadAcntCode
GO
