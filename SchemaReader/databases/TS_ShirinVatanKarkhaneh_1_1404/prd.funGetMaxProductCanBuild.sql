USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prd].[funGetMaxProductCanBuild] 
(	@ProducerAcntCode Varchar(20),
	@ProductID Varchar(20),
	@SerialNo int,
	@FormulaSNo int
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN
	DECLARE @Remain  FLOAT
	
	SELECT @Remain = MIN(ISNULL(bb.qty/aa.qty,0))
	FROM 
	((select GoodsID , (GoodsQuantity /ProductCount) qty 
	from prd.tblFormulasDtl a
	inner join  prd.tblFormulasHdr b
	on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo
	where b.ProductID=@ProductID and b.SerialNo=@FormulaSNo )
	 )aa
	 LEFT JOIN
(

	SELECT a.GoodsID, a.qty - ISNULL(cc.qty,0) - ISNULL(b.qty,0) qty
	from 
	(
	select d.GoodsID, SUM(d.GoodsQuantity) qty
	from inv.tblStorageDocsDtl d
	inner join inv.tblStorageDocsHdr h
	on d.ProcessID=h.ProcessID and
	d.ProcessNo=h.ProcessNo and
	d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
	where h.ProcessID =70 and h.AcntCode = @ProducerAcntCode and
	 h.ProductID=@ProductID and h.SerialNo = @SerialNo
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
	on cc.GoodsID=a.GoodsID
	
	) bb
	on aa.GoodsID=bb.GoodsID

	
 Return IsNull(@Remain,0)

END
GO
