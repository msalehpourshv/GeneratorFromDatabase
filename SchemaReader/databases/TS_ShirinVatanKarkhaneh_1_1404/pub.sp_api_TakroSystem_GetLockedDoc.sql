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
create PROCEDURE [pub].[sp_api_TakroSystem_GetLockedDoc]
@SerialNo  	 AS INT,
@ProcessId 	 AS INT,
@ProcessNo 	 AS INT,
@FiscalYear	 AS INT

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @MaxRowNo INT
BEGIN TRY
	IF( SELECT COUNT(*) 
        FROM pub.tblLockedDocs 
            WHERE TableName='inv.tblStorageDocsHdr' AND 
                   SerialNo= @SerialNo   AND 
                   ProcessID =  @ProcessId   AND 
                   ProcessNo= @ProcessNo  AND 
                   FiscalYear= @FiscalYear   AND 
                   CodeFieldValue='')=0
	BEGIN
		SELECT CAST (0 AS BIT) AS IsLock
	END
	
	ELSE
	BEGIN
		SELECT CAST(1 AS BIT) AS IsLock
	END



END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
