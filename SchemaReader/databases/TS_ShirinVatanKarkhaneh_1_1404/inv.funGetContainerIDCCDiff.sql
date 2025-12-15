USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [inv].[funGetContainerIDCCDiff] 
(
	@ContainerID Varchar(20),
	@StoreID Varchar(20)
)
RETURNS int
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @CCount Int
	SET @CCount = 0

	SELECT  @CCount = ISNULL(SUM(b.CountInPos - Cnt),0)
	FROM(
	SELECT COUNT(*) Cnt,ContainerStoresID, StoreID
	FROM (
		SELECT ContainerStoresID, StoreID, ContainerID 
			FROM inv.tblStorageDocsSerials a 
			WHERE a.ContainerStoresID = @ContainerID and a.StoreID = @StoreID
			GROUP BY ContainerStoresID, StoreID,ContainerID
			HAVING SUM(NumberPerContainer*EnterKind)>0
	) a
	GROUP BY ContainerStoresID, StoreID
	) aa
	LEFT JOIN inv.tblContainerPosInStores b ON aa.ContainerStoresID = b.ContainerStoresID and aa.StoreID = b.StoreID

	-- Return the result of the function
	RETURN @CCount 
END
GO
