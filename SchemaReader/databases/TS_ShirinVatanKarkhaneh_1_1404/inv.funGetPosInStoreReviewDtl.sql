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
Create FUNCTION inv.funGetPosInStoreReviewDtl
(
	@StoreID as varchar(20),
	@ContainerStoresID as varchar(20),
	@ContainerID as varchar(20)
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	SELECT StoreID,[pub].[GetStoreName](StoreID,1) StoreName
			, ContainerStoresID,inv.funGetContainerStoresName(ContainerStoresID,1) ContainerStoresName
			,   ContainerID ,inv.funGetContainerName(ContainerID, 1) ContainerName
			,SUM(NumberPerContainer*EnterKind) Qty
	FROM inv.tblStorageDocsSerials a 
	WHERE  (@StoreID = '' OR a.StoreID = @StoreID) 
		and (@ContainerStoresID = '' OR a.ContainerStoresID = @ContainerStoresID) 			
		and (@ContainerID = '' OR a.ContainerID = @ContainerID) 			
	GROUP BY ContainerStoresID, StoreID,ContainerID
	HAVING SUM(NumberPerContainer*EnterKind)<>0 
)
GO
