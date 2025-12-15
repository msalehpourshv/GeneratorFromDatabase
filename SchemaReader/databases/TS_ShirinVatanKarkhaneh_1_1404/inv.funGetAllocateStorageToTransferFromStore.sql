USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetAllocateStorageToTransferFromStore]
(	
	@IntTrnTypID varchar(20)
)
RETURNS TABLE 
WITH ENCRYPTION            
AS

RETURN 
(
SELECT FromStoreID 
from inv.tblAllocateStorageToTransferTypeDtl  
where IntTrnTypID = @IntTrnTypID
)
GO
