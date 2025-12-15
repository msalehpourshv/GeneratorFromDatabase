USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

Create FUNCTION [prd].[funGetMaxSendGoodsID] 
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
	set @Remain  =0
	------ ججهت محاسبه تعداد کالا هایی که در دستمزد قرارداد تیک خدمات دارند  -----------------------------------------------------------------------------------------------------
	select @Remain=isnull( SUM(d.GoodsQuantity) ,0)
	from inv.tblStorageDocsDtl d
	inner join inv.tblStorageDocsHdr h
	on d.ProcessID=h.ProcessID and
	d.ProcessNo=h.ProcessNo and
	d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
	where h.ProcessID =70 and h.AcntCode = @ProducerAcntCode and
	 h.ProductID=@ProductID  and 
	 d.GoodsID=@ProductID  and ((h.SourceProcessID=79  and h.SourceSerialNo = @SerialNo )  or (h.SourceProcessID<>79  and h.BaseSerialNo = @SerialNo))
	group by d.GoodsID
	-----------------------------------------------------------------------------------------------------------
	if @Remain=0
	begin

		SELECT @Remain = min(qty) from (
		SELECT  ISNULL((aa.qty - ISNULL(b.qty,0)) /
		CASE WHEN 
		(select COUNT(*)
		 from prd.tblFormulasDtl a
		 where a.ProductID=@ProductID and a.SerialNo=@FormulaSNo AND a.GoodsID=aa.GoodsID
		) >0 THEN
		(select TOP 1 (GoodsQuantity /ProductCount) qty 
		from prd.tblFormulasDtl a
		inner join  prd.tblFormulasHdr b
		on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo
		where b.ProductID=@ProductID and b.SerialNo=@FormulaSNo AND a.GoodsID=aa.GoodsID)
		ELSE
		(select TOP 1 (GoodsQuantity /ProductCount) qty 
		from prd.tblFormulasAtm a
		inner join  prd.tblFormulasHdr b
		on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo
		where b.ProductID=@ProductID and b.SerialNo=@FormulaSNo AND a.GoodsID=aa.GoodsID)
		END,0) qty
		from 
		(
		select d.GoodsID, SUM(d.GoodsQuantity) qty
		from inv.tblStorageDocsDtl d
		inner join inv.tblStorageDocsHdr h
		on d.ProcessID=h.ProcessID and
		d.ProcessNo=h.ProcessNo and
		d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
		where h.ProcessID =70 and h.AcntCode = @ProducerAcntCode and
		 h.ProductID=@ProductID  and((h.SourceProcessID=79  and h.SourceSerialNo = @SerialNo )  or (h.SourceProcessID<>79  and h.BaseSerialNo = @SerialNo))
		group by d.GoodsID
		) aa
	
		left join 
		(
		select d.GoodsID,SUM(d.GoodsQuantity) qty
		from inv.tblStorageDocsDtl d
		inner join inv.tblStorageDocsHdr h
		on d.ProcessID=h.ProcessID and
		d.ProcessNo=h.ProcessNo and
		d.FiscalYear = h.FiscalYear and d.SerialNo=h.SerialNo
		where h.ProcessID =75 and h.AcntCode = @ProducerAcntCode and
		 h.ProductID=@ProductID  and((h.SourceProcessID=79  and h.SourceSerialNo = @SerialNo )  or (h.SourceProcessID<>79  and h.BaseSerialNo = @SerialNo))
		group by d.GoodsID
		)  b
		on aa.GoodsID=b.GoodsID
		WHERE aa.GoodsID IN (SELECT GoodsID FROM prd.tblFormulasDtl WHERE ProductID=@ProductID and SerialNo=@FormulaSNo 
							UNION ALL 
							SELECT GoodsID FROM prd.tblFormulasAtm WHERE ProductID=@ProductID and SerialNo=@FormulaSNo )
		) aaa
	end
 Return IsNull(@Remain,0)

END
GO
