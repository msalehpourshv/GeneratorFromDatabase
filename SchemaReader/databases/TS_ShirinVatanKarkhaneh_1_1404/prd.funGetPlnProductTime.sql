USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prd].[funGetPlnProductTime] 
(
	@BaseProcessID SMALLINT,
	@BaseProcessNo TINYINT,
	@BaseFiscalYear SMALLINT,
	@BaseSerialNo INT,
	@BaseDocRowNo INT,
	@ProductID VARCHAR(30)
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

	DECLARE @Remain  FLOAT

	SELECT  @Remain = SUM(ISNULL(p.ProduceStepTime,0))
	From pln.tblProduceStepDtl p
	INNER JOIN (SELECT ProduceStepSerialNo,ProduceStepID 
	            FROM  pln.tblTaskOrderDtl 
	            WHERE ProcessID = @BaseProcessID AND ProcessNo = @BaseProcessNo AND 
				      FiscalYear = @BaseFiscalYear AND SerialNo = @BaseSerialNo AND DocRowNo = @BaseDocRowNo
				)t
	ON p.ProductID=@ProductID AND p.SerialNo=t.ProduceStepSerialNo AND p.ProduceStepID=t.ProduceStepID
	
	RETURN @Remain
END
GO
