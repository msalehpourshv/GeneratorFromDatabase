USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetTaxSerialNo] 
(
	@ProcessID int,
	@FiscalYear int
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

	DECLARE @TaxSerialNo  INT

	SET  @TaxSerialNo = 0

	select @TaxSerialNo=ISNULL(MAX(TaxSerialNoInvoice),0)  from inv.tblStorageDocsHdr
	where ProcessID=@ProcessID and FiscalYear=@FiscalYear AND (Export ='True' OR  TaxOverWorthCost>0 OR  HasTaxSerialNo='True')
	
	RETURN @TaxSerialNo + 1
END
GO
