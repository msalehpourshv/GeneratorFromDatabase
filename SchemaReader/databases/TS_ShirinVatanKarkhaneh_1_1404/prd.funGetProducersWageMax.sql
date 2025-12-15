USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- SELECT [prd].[funGetProducersWageRemain] ('111001','0100010101001',1)
CREATE FUNCTION [prd].[funGetProducersWageMax] 
(	@ProducerAcntCode Varchar(20),
	@ProductID Varchar(20),
	@SerialNo int,
	@GoodsID Varchar(20),
	@FormulaSNo int
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN
	DECLARE @Remain  FLOAT
	
	select @Remain=ISNULL((
	select TOP 1 GoodsQuantity*[prd].[funGetProducersWageRemain] 
						(@ProducerAcntCode,@ProductID,@SerialNo) /ProductCount
	from prd.tblFormulasDtl a
	inner join  prd.tblFormulasHdr b
	on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo
	where b.ProductID=@ProductID and b.SerialNo=@FormulaSNo 
	and GoodsID=@GoodsID),0)-

	ISNULL((
	SELECT a.qty-ISNULL(b.qty,0) qty
	from 
	(select d.GoodsID,SUM(d.GoodsQuantity) qty
	from inv.tblStorageDocsDtl d
	inner join inv.tblStorageDocsHdr h
	on d.ProcessID=h.ProcessID and
	d.ProcessNo=h.ProcessNo and
	d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
	where h.ProcessID =70 and h.AcntCode = @ProducerAcntCode and
	 h.ProductID=@ProductID and h.BaseSerialNo = @SerialNo
	group by d.GoodsID) 
	a
	left join (
	select d.GoodsID,SUM(d.GoodsQuantity) qty
	from inv.tblStorageDocsDtl d
	inner join inv.tblStorageDocsHdr h
	on d.ProcessID=h.ProcessID and
	d.ProcessNo=h.ProcessNo and
	d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
	where h.ProcessID =75 and h.AcntCode = @ProducerAcntCode and
	 h.ProductID=@ProductID and h.BaseSerialNo = @SerialNo
	group by d.GoodsID)b
	on a.GoodsID=b.GoodsID
	where a.GoodsID = @GoodsID),0)
	
return @Remain

END
GO
