USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [prd].[funGetProducersEditQty] 
(	@ProducerAcntCode Varchar(20),
	@SerialNo int,
	@BatchNo Varchar(20),
	@GoodsID Varchar(20)
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN
	DECLARE @Remain  FLOAT

	SELECT @Remain = ISNULL(SUM(GoodsQuantity*EnterKind),0)
	from prd.tblProducersWageDtl a
	inner join prd.tblProducersWageHdr b
	ON a.ProducerAcntCode=b.ProducerAcntCode and a.ProcessID=b.ProcessID and a.SerialNo=b.SerialNo
	WHERE a.ProcessID = 89 AND BatchNo = @BatchNo AND  a.ProducerAcntCode = @ProducerAcntCode AND b.BaseSerialNo=@SerialNo AND GoodsID = @GoodsID
	
	RETURN @Remain
END
GO
