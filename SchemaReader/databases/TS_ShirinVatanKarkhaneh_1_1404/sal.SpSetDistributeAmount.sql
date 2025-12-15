USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
CREATE Procedure [sal].[SpSetDistributeAmount]
	@ProcessNo	        tinyint, 
	@FiscalYear         Smallint, 
	@SerialNo			int 

WITH ENCRYPTION
AS
BEGIN

	DECLARE @Price			Float;

	SELECT @Price = ROUND(((Price - (Discount+Discount2+Discount3+TotalLineDiscount))* DistributePercent)/100 ,0)
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID  = 90 AND
		  ProcessNo  = @ProcessNo AND
		  FiscalYear = @FiscalYear AND
		  SerialNo   = @SerialNo 
 
		
	UPDATE inv.tblStorageDocsHdr 
	SET DistributeAmount =@Price
	WHERE ProcessID  = 90 AND
		  ProcessNo  = @ProcessNo AND
		  FiscalYear = @FiscalYear AND
		  SerialNo   = @SerialNo 

	SELECT @Price  DistributeAmount

END
GO
