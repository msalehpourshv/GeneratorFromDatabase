USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- SELECT [prd].[funGetProducersWageRemain] ('111001','0100010101001',1)
CREATE FUNCTION [prd].[funGetProducersWageRemain] 
(	@ProducerAcntCode Varchar(20),
	@GoodsID Varchar(20),
	@SerialNo int
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN
	DECLARE @Remain  FLOAT

	SET  @Remain = 0
	
	SELECT @Remain = d.GoodsQuantity +
		isnull((select sum(d1.GoodsQuantity*d1.EnterKind)  
		from  prd.tblProducersWageDtl d1
		inner join prd.tblProducersWageHdr h
		on h.ProducerAcntCode=d1.ProducerAcntCode
		and h.SerialNo=d1.SerialNo and h.ProcessID=d1.ProcessID AND d1.GoodsID=d.GoodsID
		where  h.BaseSerialNo= d.SerialNo and d1.ProcessID=89),0)
	FROM  prd.tblProducersWageDtl d
	WHERE d.ProcessID=79 AND 
	d.ProducerAcntCode = @ProducerAcntCode AND
	d.GoodsID = @GoodsID AND
	d.SerialNo = @SerialNo 

	return @Remain
END


GO
