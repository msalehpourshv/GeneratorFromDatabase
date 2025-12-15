USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prd].[funGetProductTime] 
(
	@ProductID Varchar(20),
	@FormulaNo INT
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

	DECLARE @Remain  FLOAT

	
	SELECT  @Remain = ISNULL(pub.funSplitString(Duration,':',1) * 3600 + pub.funSplitString(Duration,':',2) * 60 + pub.funSplitString(Duration,':',3),0)/ ProductCount
	From prd.tblFormulasHdr
	Where ProductID = @ProductID  AND 
		  SerialNo = @FormulaNo 
	
	RETURN @Remain
END
GO
