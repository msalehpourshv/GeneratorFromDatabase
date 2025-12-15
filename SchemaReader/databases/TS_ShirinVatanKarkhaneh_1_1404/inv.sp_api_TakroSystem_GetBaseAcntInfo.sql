USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1402/02/19
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE inv.sp_api_TakroSystem_GetBaseAcntInfo
@ProcessId		AS INT,
@ProcessNo		AS INT,
@SerialNo		AS INT,
@FiscalYear		AS INT

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
BEGIN TRY
	
	
	SELECT 
	ISNULL(ZipCode,'') AS AcntZipCode,ISNULL(NationalIDNumber,'') AS AcntNationalNumber,ISNULL(EconomicalCode,'') AS AcntEconomicalCode 
	FROM inv.tblStorageDocsHdr
	WHERE SerialNo=@SerialNo AND FiscalYear= @FiscalYear AND ProcessID =@ProcessId AND ProcessNo=@ProcessNo

	
END TRY

BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END
GO
