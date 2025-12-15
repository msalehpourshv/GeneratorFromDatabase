USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetAllocateGoodsToStore2]
(	
	@FromStoreID varchar(20)
)
RETURNS TABLE 
WITH ENCRYPTION            
AS

RETURN 
(
	Select Distinct a.GoodsID 
	From inv.tblAllocateGoodsToStoreDtl a
	Where a.StoreID = SUBSTRING(@FromStoreID,1,LEN(a.StoreID))
)
GO
