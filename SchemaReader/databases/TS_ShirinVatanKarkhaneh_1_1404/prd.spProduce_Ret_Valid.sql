USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\RNP
-- Create date   : 1394/02/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
create PROCEDURE [prd].[spProduce_Ret_Valid]
	
	  @ProducerAcntCode Varchar(20)=null,
	  @ProductID Varchar(20)=null,
	  @SerialNo int=null,
	  @FormulaSNo inT=null
	
WITH ENCRYPTION
AS 

	SELECT a.GoodsID, a.qty-ISNULL(cc.qty,0)-ISNULL(b.qty,0) qty
	from 
	(
	select d.GoodsID,SUM(d.GoodsQuantity) qty
	from inv.tblStorageDocsDtl d
	inner join inv.tblStorageDocsHdr h
	on d.ProcessID=h.ProcessID and
	d.ProcessNo=h.ProcessNo and
	d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
	where h.ProcessID =70 and h.AcntCode = @ProducerAcntCode and
	 h.ProductID=@ProductID and h.BaseSerialNo = @SerialNo
	group by d.GoodsID
	) a
	
	left join 
	(
	select d.GoodsID,SUM(d.GoodsQuantity) qty
	from inv.tblStorageDocsDtl d
	inner join inv.tblStorageDocsHdr h
	on d.ProcessID=h.ProcessID and
	d.ProcessNo=h.ProcessNo and
	d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
	where h.ProcessID =75 and h.AcntCode = @ProducerAcntCode and
	 h.ProductID=@ProductID and h.BaseSerialNo = @SerialNo
	group by d.GoodsID
	)  b
	on a.GoodsID=b.GoodsID
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
	       d.FormulaNo=@FormulaSNo AND h.AcntCode = @ProducerAcntCode and 
	       h.BaseSerialNo = @SerialNo
	),0) qty
	from prd.tblFormulasDtl a
	inner join  prd.tblFormulasHdr b
	on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo
	where b.ProductID=@ProductID and b.SerialNo=@FormulaSNo 
	
	) cc
	on cc.GoodsID=b.GoodsID
	
	
GO
