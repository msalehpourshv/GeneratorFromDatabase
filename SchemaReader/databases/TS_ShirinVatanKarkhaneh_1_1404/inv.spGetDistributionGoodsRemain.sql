USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 89/07/17
-- Viewed By	 : 
-- Last Modified : 
-- Description   : get list of Goods from Ditribution
-- =============================================
CREATE procedure [inv].[spGetDistributionGoodsRemain]
	@DistributionSerialNo as int,
	@DocDate as Varchar(10),
	@StoreID as Varchar(10)
WITH ENCRYPTION
AS
BEGIN

	SELECT GoodsID,Max(GoodsRemain) GoodsRemain
	--INTO #tblGoods 
		FROM (
			SELECT GoodsID ,[inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,VolumeRowNo,@StoreID,GoodsID,D.BatchNo,H.DocDate,D.UserPriceID) + GoodsQuantity  GoodsRemain  --[inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,VolumeRowNo,H.StoreID,GoodsID,H.DocDate) - GoodsQuantity  GoodsRemain 
			FROM inv.tblStorageDocsDtl D
			inner join inv.tblStorageDocsHdr H 
			ON H.ProcessID= D.ProcessID
				AND H.ProcessNo= D.ProcessNo
				AND H.FiscalYear= D.FiscalYear
				AND H.SerialNo= D.SerialNo
			WHERE BaseDistributionSerialNo = @DistributionSerialNo AND D.StoreID = @StoreID
		) R
		Group by GoodsID

	--insert into #tblGoods
	--	SELECT DISTINCT D.GoodsID,
	--		(SELECT SUM (ISNULL(O,0)) FROM (
	--			SELECT (SELECT  TOP 1 [inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,VolumeRowNo,@StoreID,S.GoodsID,S.BatchNo,S.DocDate,S.UserPriceID)
	--	  				FROM inv.tblStorageDocsDtl S
	--					WHERE S.GoodsID =D.GoodsID AND S.StoreID = t.StoreID AND S.StoreID = @StoreID
	--					ORDER BY DocDate DESC,VolumeRowNo  DESC
	--					) AS O
	--			FROM inv.tblStores  t  
	--			)u
	--		  ) AS GoodsRemain
	--	FROM inv.tblStorageDocsDtl D
	--	WHERE DocDate <= @DocDate AND StoreID = @StoreID AND GoodsID NOT IN (SELECT GoodsID FROM #tblGoods)

	--SELECT * FROM #tblGoods
	--UNION ALL
	--SELECT DISTINCT D.GoodsID,
	--	(SELECT SUM (ISNULL(O,0)) FROM (
	--		SELECT (SELECT  TOP 1 [inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,@StoreID,S.GoodsID,'',S.DocDate,S.UserPriceID)
	--	  			FROM sal.tblSaleOrderDtl S
	--				WHERE S.GoodsID =D.GoodsID AND S.StoreID = t.StoreID AND S.StoreID = @StoreID
	--				ORDER BY DocDate DESC
	--				) AS O
	--		FROM inv.tblStores  t  
	--			)u
	--	  ) AS GoodsRemain
	--FROM sal.tblSaleOrderDtl D
	--WHERE DocDate <= @DocDate AND StoreID = @StoreID AND GoodsID NOT IN (SELECT GoodsID FROM #tblGoods)
	
	--order by GoodsID

END
GO
