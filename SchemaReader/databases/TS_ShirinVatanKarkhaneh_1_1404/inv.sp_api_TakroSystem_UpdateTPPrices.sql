USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : E.Alian Pour
-- Create date   : 1404-04-27
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_TakroSystem_UpdateTPPrices
@ProcessId AS int,
@ProcessNo AS int,
@SerialNo AS int,
@FiscalYear AS int,
@TPPriceBeforDiscount AS Float,
@TPPriceAfterDiscount AS Float


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
BEGIN TRY

	UPDATE inv.tblStorageDocsHdr
		SET TPPriceAfterDiscount=@TPPriceAfterDiscount,TPPriceBeforDiscount=@TPPriceBeforDiscount 
	WHERE ProcessID=@ProcessId AND SerialNo=@SerialNo  AND FiscalYear=@FiscalYear AND ProcessNo=@ProcessNo  

	
END TRY

BEGIN CATCH
	
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH
END
GO
