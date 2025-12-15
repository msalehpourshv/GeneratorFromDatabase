USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Hadi Sadei
-- Create date   : 1394/05/01
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================

Create PROCEDURE [prd].[SpGetMaxProductCanBuild]
@AcntCode varchar(30),
@ProductID varchar(30),
@BatchNo varchar(30),
@FormulaNo int,
@BaseSerialNo int,
@ReciveSerialNo int,
@CallType		int
WITH ENCRYPTION
AS

BEGIN 

declare	@qty float,@CanBuild  float,@GoodsID varchar(30)	  
	
Declare	curMax CURSOR For 
SELECT a.AcntCode,a.ProductID,a.BaseSerialNo,a.GoodsID,a.FormulaNo,a.BatchNo,
a.qty  - ISNULL(b.qty,0) qty
from 
(
select h.AcntCode,h.ProductID,h.BaseSerialNo,d.GoodsID,h.FormulaNo,h.BatchNo, SUM(d.GoodsQuantity) qty
from inv.tblStorageDocsDtl d
inner join inv.tblStorageDocsHdr h
on d.ProcessID=h.ProcessID and
d.ProcessNo=h.ProcessNo and
d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
where h.ProcessID =70 and h.AcntCode = @AcntCode and h.BatchNo = @BatchNo AND 
  h.FormulaNo =@FormulaNo and
  h.ProductID=@ProductID and ( (@CallType=0 and  h.BaseSerialNo = @BaseSerialNo) or (@CallType=1 and  h.SourceSerialNo = @BaseSerialNo))
group by h.AcntCode,h.ProductID,h.BaseSerialNo,d.GoodsID,h.FormulaNo,h.BatchNo
) a

left join 
(
select h.AcntCode,h.ProductID,h.BaseSerialNo,d.GoodsID,h.FormulaNo,h.BatchNo,SUM(d.GoodsQuantity) qty
from inv.tblStorageDocsDtl d
inner join inv.tblStorageDocsHdr h
on d.ProcessID=h.ProcessID and
d.ProcessNo=h.ProcessNo and
d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
where h.ProcessID =75 and h.BatchNo = @BatchNo AND h.AcntCode = @AcntCode and
h.ProductID=@ProductID and ( (@CallType=0 and  h.BaseSerialNo = @BaseSerialNo) or (@CallType=1 and  h.SourceSerialNo = @BaseSerialNo))
group by h.AcntCode,h.ProductID,h.BaseSerialNo,d.GoodsID,h.FormulaNo,h.BatchNo
)  b
on a.GoodsID=b.GoodsID

SELECT a.ProductID,a.SerialNo,GoodsID,GoodsQuantity/ProductCount Qty,CAST(0.0 as  FLOAT) CanBuild into #tmp 
FROM prd.tblFormulasDtl a
inner join  prd.tblFormulasHdr b
on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo
where a.ProductID=@ProductID and a.SerialNo = @FormulaNo


Open  curMax; 

Fetch NEXT From curMax Into @AcntCode,@ProductID,@BaseSerialNo,@GoodsID,@FormulaNo,@BatchNo,@qty
While (@@Fetch_Status = 0)
BEGIN
	IF (SELECT COUNT(*) from #tmp
		where ProductID = @ProductID and SerialNo = @FormulaNo AND GoodsID=@GoodsID )=1
		
		UPDATE #tmp
		SET CanBuild = CanBuild + @qty / (SELECT TOP 1 Qty from #tmp
										  where ProductID = @ProductID and 
										        SerialNo = @FormulaNo AND 
										        GoodsID=@GoodsID )
		WHERE ProductID = @ProductID and SerialNo = @FormulaNo AND GoodsID=@GoodsID
	ELSE
		BEGIN
			IF 	(SELECT COUNT(*) from prd.tblFormulasAtm 
			     WHERE ProductID = @ProductID and SerialNo = @FormulaNo AND GoodsID = @GoodsID) > 0
	
				UPDATE #tmp
				SET CanBuild = CanBuild + (@qty / (d.GoodsQuantity/b.ProductCount))
				FROM #tmp c
				inner join  prd.tblFormulasDtl a
				on a.ProductID=c.ProductID and a.SerialNo=c.SerialNo
				inner join  prd.tblFormulasHdr b
				on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo
				inner join prd.tblFormulasAtm d
				on d.ProductID=b.ProductID and d.SerialNo=b.SerialNo 
				AND d.GoodsID = @GoodsID
				where a.ProductID=@ProductID and a.SerialNo = @FormulaNo 
			     
		END
			
	
	Fetch NEXT From curMax Into @AcntCode,@ProductID,@BaseSerialNo,@GoodsID,@FormulaNo,@BatchNo,@qty
	
END

Close curMax;
DEALLOCATE curMax;

SELECT MIN(CanBuild) 
- 
ISNULL((SELECT SUM(GoodsQuantity) 
 from inv.tblStorageDocsDtl  d
 inner join inv.tblStorageDocsHdr h
 on d.ProcessID=h.ProcessID and
	d.ProcessNo=h.ProcessNo and
	d.FiscalYear = h.FiscalYear and 
	d.SerialNo=h.SerialNo
 where h.ProcessID = 80 AND  d.GoodsID=@ProductID and 
       d.FormulaNo=@FormulaNo AND h.AcntCode = @AcntCode and 
       ( (@CallType=0 and  h.BaseSerialNo = @BaseSerialNo) or (@CallType=1 and  h.SourceSerialNo = @BaseSerialNo)) AND h.BatchNo = @BatchNo AND d.SerialNo <> @ReciveSerialNo
),0)

 FROM #tmp

END
GO
