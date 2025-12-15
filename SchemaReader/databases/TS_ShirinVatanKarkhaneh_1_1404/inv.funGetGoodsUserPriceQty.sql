USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

 -- =========== TS-QC:NOTOK =====================
-- Author        : jafari
-- Create date   : 1396/05/10
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--Drop FUNCTION   inv.SpGoodsUserPriceTestQty

Create FUNCTION   inv.funGetGoodsUserPriceQty
(
	@GoodsID as varchar(20)='',
	@StoreID as varchar(20)='',
	@UserPriceID as bigint=0
	)
	
RETURNS float
WITH ENCRYPTION            
AS
BEGIN

if (select COUNT(*) from inv.tblGoods where GoodsID=@GoodsID AND IsService='True')>0
RETURN 10000000


DECLARE @Qty float

	SELECT @Qty= Sum(GoodsQuantity*EnterKind) 
	From inv.tblStorageDocsDtl  
 Where GoodsID =@GoodsID  and UserPriceID =@UserPriceID  and StoreID=@StoreID
 
 
 RETURN ISNULL(@Qty ,0)

END

GO
