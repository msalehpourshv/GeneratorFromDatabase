USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetAllocateStoresFromGoods]
(	
	@GoodsID varchar(20)
)
RETURNS TABLE 
WITH ENCRYPTION            
AS

RETURN 
(
	Select Distinct a.StoreID
	From inv.tblAllocateGoodsToStoreDtl a
	Where a.GoodsID = SUBSTRING(@GoodsID,1,LEN(a.GoodsID))
)
GO
