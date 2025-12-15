USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [inv].[funGetAllocateGoodsToStore]
(	
	@FromStoreID varchar(20),
	@ToStoreID varchar(20)
)
RETURNS TABLE 
WITH ENCRYPTION            
AS

RETURN 
(
select distinct a.GoodsID 
FROM inv.tblAllocateGoodsToStoreDtl a
inner join inv.tblAllocateGoodsToStoreDtl b
on a.GoodsID=b.GoodsID
where a.StoreID=@FromStoreID and b.StoreID = @ToStoreID
)
GO
