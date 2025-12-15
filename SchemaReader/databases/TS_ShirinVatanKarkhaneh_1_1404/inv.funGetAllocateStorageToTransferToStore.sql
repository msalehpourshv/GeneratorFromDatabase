USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetAllocateStorageToTransferToStore]
(	
	@IntTrnTypID varchar(20),
	@StoreID varchar(20)
)
RETURNS TABLE 
WITH ENCRYPTION            
AS

RETURN 
(
SELECT ToStoreID 
from inv.tblAllocateStorageToTransferTypeDtl  
where IntTrnTypID = @IntTrnTypID AND FromStoreID = @StoreID
)
GO
