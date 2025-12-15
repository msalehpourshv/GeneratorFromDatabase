USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Jafari
-- Create date   : 1404/05/13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION inv.funGetGoodsRemainInTempReceipt
	(	
		@StoreID		Varchar(20),
		@GoodsID		Varchar(20),
		@BatchNo		Varchar(20),
		@DocDate		Char(10)	
	)

RETURNS float --decimal(38,5)
WITH ENCRYPTION
AS
BEGIN
	
DECLARE @QtyRemain Decimal(28,9)
	
SET @QtyRemain =0

SET @StoreID=isnull(@StoreID,'')
SET @GoodsID=isnull(@GoodsID,'')
SET @BatchNo=isnull(@BatchNo,'')
SET @DocDate=isnull(@DocDate,'')

select  @QtyRemain =Sum( (a.Qty-isnull(b.Qty,0)))  
from (
	select BatchNo,GoodsID,SUM(GoodsQuantity) Qty , StoreID
	from inv.tblInvTempReceiptDtl
	where ProcessID=79 
	and (@StoreID='' or StoreID=@StoreID)
	and (@GoodsID='' or GoodsID=@GoodsID)
	and (@BatchNo='' or BatchNo=@BatchNo)
	and (@DocDate='' or DocDate<=@DocDate)
	group by BatchNo,GoodsID,ProcessNo, StoreID
	) a 
left join 
	(
	select BatchNo,GoodsID,SUM(GoodsQuantity) Qty, StoreID
	from inv.tblStorageDocsDtl
	where ProcessID=80 
	and (@StoreID='' or StoreID=@StoreID)
	and (@GoodsID='' or GoodsID=@GoodsID)
	and (@BatchNo='' or BatchNo=@BatchNo)
	and (@DocDate='' or DocDate<=@DocDate)
	group by BatchNo,GoodsID,ProcessNo, StoreID
	) b   
on a.BatchNo=b.BatchNo and  a.GoodsID=b.GoodsID
where a.Qty>isnull(b.Qty,0)
	
SET @QtyRemain =isnull(@QtyRemain,0)
RETURN @QtyRemain 

END
GO
