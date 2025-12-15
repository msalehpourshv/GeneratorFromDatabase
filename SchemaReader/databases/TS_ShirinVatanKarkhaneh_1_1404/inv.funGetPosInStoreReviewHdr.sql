USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1404/02/07
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION inv.funGetPosInStoreReviewHdr
(
	@StoreID as varchar(20),
	@ContainerStoresID as varchar(20)
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	SELECT  aa.StoreID,[pub].[GetStoreName](aa.StoreID,1) StoreName
		, aa.ContainerStoresID,inv.funGetContainerStoresName(aa.ContainerStoresID,1) ContainerStoresName
		, b.CountInPos,ISNULL(SUM(Cnt),0)  CntUse
		FROM(
			SELECT  COUNT(*)  Cnt,ContainerStoresID, StoreID, ContainerID 
			FROM (
				SELECT ContainerStoresID, StoreID, ContainerID 
					FROM inv.tblStorageDocsSerials a 
					WHERE  (@StoreID = '' OR a.StoreID = @StoreID) 
					and (@ContainerStoresID = '' OR a.ContainerStoresID = @ContainerStoresID) 			
					GROUP BY ContainerStoresID, StoreID,ContainerID
					HAVING SUM(NumberPerContainer*EnterKind)>0
		) a
		GROUP BY ContainerStoresID, StoreID, ContainerID 
	) aa
	LEFT JOIN inv.tblContainerPosInStores b ON aa.ContainerStoresID = b.ContainerStoresID and aa.StoreID = b.StoreID
	GROUP BY aa.ContainerStoresID, aa.StoreID ,b.CountInPos
	HAVING  ISNULL(SUM(b.CountInPos - Cnt),0)>0

)
GO
