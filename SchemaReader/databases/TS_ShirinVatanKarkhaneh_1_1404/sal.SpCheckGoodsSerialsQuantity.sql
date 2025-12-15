USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1396/03/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : تست موجودی منفی کالاهای بچ دار بدون سریال
-- =============================================

CREATE PROCEDURE [sal].[SpCheckGoodsSerialsQuantity]
(
@ProcessID	int=0,
@ProcessNo	int=0,
@FiscalYear	int=0,
@SerialNo	int=0
)
WITH ENCRYPTION
AS
BEGIN

	Select * from (
Select GoodsID,d.StoreID,ISNULL( s.BatchNo,'')BatchNo
,ISNULL( (Select SUM(GoodsQuantity*a.EnterKind) Quantity 
  from inv.tblStorageDocsDtl a 
	inner join 
   inv.tblStorageDocsSerials b ON a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo 
   and    a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and    a.DocRowNo=b.DocRowNo
   where  
   a.GoodsID=d.GoodsID and a.StoreID=d.StoreID and b.BatchNo=s.BatchNo
   ),0) Quantity
 from inv.tblStorageDocsDtl d 
 left Join  inv.tblStorageDocsSerials s
 ON s.ProcessID=d.ProcessID and s.ProcessNo=d.ProcessNo 
   and    s.FiscalYear=d.FiscalYear and s.SerialNo=d.SerialNo and    s.DocRowNo=d.DocRowNo 
where d.ProcessID=@ProcessID and d.ProcessNo=@ProcessNo and d.FiscalYear=@FiscalYear and d.SerialNo=@SerialNo
and d.GoodsID in ( Select GoodsID  From inv.tblGoods where HasSerial=0 and HasBatchNo=1)
)a where a.Quantity<0


--Select * From inv.tblGoods
--where GoodsID in('220101007','220101006')
--and  HasSerial=0 and HasBatchNo=1

END
GO
