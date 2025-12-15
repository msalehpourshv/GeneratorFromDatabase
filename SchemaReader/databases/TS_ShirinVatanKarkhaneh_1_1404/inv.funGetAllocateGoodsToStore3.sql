USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetAllocateGoodsToStore3]
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
	Where SUBSTRING(a.StoreID ,1,LEN(@FromStoreID)) = @FromStoreID
)
GO
