USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 1401/10/12
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.SPCheckProductSerialsAll
@ProcessID Int, 
@ProcessNo Int, 
@FiscalYear int , 
@SerialNo int, 
@DocDate char(10)
WITH ENCRYPTION
AS
begin


SELECT PSerialNo,  0  EnterKind ,StoreID
into #tblPSerialNo     
FROM inv.tblStorageDocsSerials     
WHERE ProcessID = @ProcessID
  AND ProcessNo =  @ProcessNo 
  AND FiscalYear =  @FiscalYear 
  AND SerialNo =  @SerialNo 
group by PSerialNo,StoreID

 update  #tblPSerialNo 
 set EnterKind=s.EnterKind
 from #tblPSerialNo p inner join (
        select isnull(Sum(EnterKind),0) EnterKind, PSerialNo,StoreID
        from (
            select d.EnterKind, s.PSerialNo,s.StoreID
            from inv.tblStorageDocsSerials s
                Left join   inv.tblStorageDocsDtl d	on s.ProcessID=d.ProcessID	and s.ProcessNo=d.ProcessNo	and s.FiscalYear=d.FiscalYear	and s.SerialNo=d.SerialNo	and s.DocRowNo=d.DocRowNo
                Left join   sal.tblSaleOrderDtl o	on s.ProcessID=o.ProcessID	and s.ProcessNo=o.ProcessNo	and s.FiscalYear=o.FiscalYear	and s.SerialNo=o.SerialNo	and s.DocRowNo=o.DocRowNo
            where PSerialNo in (  SELECT PSerialNo   from #tblPSerialNo   ) and d.DocDate <=@DocDate
        ) a 
		Group by PSerialNo,StoreID) s on p.PSerialNo=s.PSerialNo AND p.StoreID=s.StoreID

select * from 		#tblPSerialNo

end
GO
