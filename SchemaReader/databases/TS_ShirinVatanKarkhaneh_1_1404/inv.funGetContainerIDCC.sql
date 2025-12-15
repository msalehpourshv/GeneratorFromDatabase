USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [inv].[funGetContainerIDCC] 
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

	SELECT @CCount = ISNULL(COUNT(*),0)
	FROM (
		SELECT ContainerID, SUM(1*EnterKind) CID
		FROM inv.tblStorageDocsSerials a 
		WHERE ContainerStoresID = @ContainerID and StoreID = @StoreID
		GROUP BY ContainerID
		HAVING SUM(1*EnterKind)>0
	) a

	-- Return the result of the function
	RETURN @CCount 
END
GO
