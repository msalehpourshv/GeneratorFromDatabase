USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hadi SAdeghi
-- Create date   : 1401/09/09
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE [prd].[spProduceWithBatch_Ret_Valid]
	
	  @ProducerAcntCode Varchar(20)=null,
	  @ProductID Varchar(20)=null,
	  @BatchNo   Varchar(20)=null,
	  @DocDate   varchar(10)
	
WITH ENCRYPTION
AS 
	DECLARE @FormulaNo int = 0
	IF @ProductID=''
		SELECT top 1 @ProductID = ProductID
		from inv.tblStorageDocsHdr
		where ProcessID = 70 and 
			  AcntCode = @ProducerAcntCode AND 
			  BatchNo = @BatchNo AND 
			  DocDate<=@DocDate
		ORDER BY DocDate DESC,SerialNo DESC	   

	SELECT top 1 @FormulaNo = FormulaNo
	from inv.tblStorageDocsHdr
	where ProcessID = 70 and 
	      AcntCode = @ProducerAcntCode AND 
		  BatchNo = @BatchNo AND 
		  ProductID=@ProductID AND 
		  DocDate<=@DocDate
	ORDER BY DocDate DESC,SerialNo DESC	   

	SELECT a.GoodsID,a.BatchNo, a.qty-ISNULL(cc.qty,0)-ISNULL(b.qty,0) qty
	from 
	(
	select d.GoodsID,d.BatchNo,SUM(d.GoodsQuantity) qty
	from inv.tblStorageDocsDtl d
	inner join inv.tblStorageDocsHdr h
	on d.ProcessID=h.ProcessID and
	d.ProcessNo=h.ProcessNo and
	d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
	where h.ProcessID =70 and h.AcntCode = @ProducerAcntCode and
	 h.ProductID=@ProductID and h.BatchNo = @BatchNo and h.DocDate<=@DocDate
	group by d.GoodsID,d.BatchNo
	) a
	left join 
	(
	select d.GoodsID,d.BatchNo,SUM(d.GoodsQuantity) qty
	from inv.tblStorageDocsDtl d
	inner join inv.tblStorageDocsHdr h
	on d.ProcessID=h.ProcessID and
	d.ProcessNo=h.ProcessNo and
	d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
	where h.ProcessID =75 and h.AcntCode = @ProducerAcntCode and
	 h.ProductID=@ProductID and h.BatchNo = @BatchNo
	group by d.GoodsID,d.BatchNo
	)  b
	on a.GoodsID=b.GoodsID and a.BatchNo=b.BatchNo
	LEFT JOIN 
	(
	select GoodsID , (GoodsQuantity /ProductCount)*
	ISNULL((SELECT SUM(GoodsQuantity) 
	 from inv.tblStorageDocsDtl  d
	 inner join inv.tblStorageDocsHdr h
	 on d.ProcessID=h.ProcessID and
		d.ProcessNo=h.ProcessNo and
		d.FiscalYear = h.FiscalYear and 
		d.SerialNo=h.SerialNo
	 where h.ProcessID = 80 AND  d.GoodsID=@ProductID and 
	       d.FormulaNo=@FormulaNo AND h.AcntCode = @ProducerAcntCode and 
	       h.BatchNo = @BatchNo
	),0) qty
	from prd.tblFormulasDtl a
	inner join  prd.tblFormulasHdr b
	on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo
	where b.ProductID=@ProductID and b.SerialNo=@FormulaNo 
	
	) cc
	on cc.GoodsID=a.GoodsID
	
	
GO
