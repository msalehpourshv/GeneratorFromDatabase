USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE inv.sp_api_TakroSystem_GetPendingReference
@ProcessID as int,
@ProcessNo as int,
@SerialNo as int,
@FiscalYear as int

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @CompanyEconimicCode NVARCHAR(MAX)
	DECLARE @CompanyNationalCode NVARCHAR(MAX)
	DECLARE @CompanyNationalIdentity NVARCHAR(MAX)
	DECLARE @CompanyPersonalityType NVARCHAR(MAX)
	DECLARE @TaxBranchId NVARCHAR(MAX)
BEGIN TRY

	SELECT ReferenceID,TaxID
	FROM  inv.tblStorageDocsHdr H
	WHERE SerialNo=@SerialNo AND ProcessID=@ProcessID AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear	

END TRY

BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
