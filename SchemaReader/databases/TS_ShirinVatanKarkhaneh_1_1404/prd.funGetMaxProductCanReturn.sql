USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create FUNCTION [prd].[funGetMaxProductCanReturn] 
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


	SELECT @Remain =  a.qty - ISNULL(b.qty,0)
	from 
	(
	select d.GoodsID, SUM(d.GoodsQuantity) qty
	from inv.tblStorageDocsDtl d
	inner join inv.tblStorageDocsHdr h
	on d.ProcessID=h.ProcessID and
	d.ProcessNo=h.ProcessNo and
	d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
	where h.ProcessID =80 and h.AcntCode = @ProducerAcntCode and
	 d.GoodsID=@ProductID and h.BaseSerialNo = @SerialNo
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
	where h.ProcessID =85 and h.AcntCode = @ProducerAcntCode and
	 d.GoodsID=@ProductID and h.BaseSerialNo = @SerialNo
	group by d.GoodsID
	)  b
	on a.GoodsID=b.GoodsID
	
 Return IsNull(@Remain,0)

END
GO
