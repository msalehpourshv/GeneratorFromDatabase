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
create PROCEDURE [inv].[sp_api_TakroSystem_InsertIntoTPHistoriesFromStorageDocsHdr]

WITH ENCRYPTION
 AS
BEGIN
	DECLARE  @DBName AS VARCHAR(200)
	DECLARE  @DBName0000 AS VARCHAR(200)
	DECLARE  @StrString  AS NVARCHAR(max)
	DECLARE @StrErrorMessage AS VARCHAR(max)
	
BEGIN TRY
		
	
	
	select @DBName =db_name()

	select @DBName0000= substring (@DBName ,1,len(@DBName )-4) +'0000'

	set @StrString=N'
	
	IF (SELECT COUNT(*) FROM  ['+@DBName0000+'].[pub].tblTPHistories )<=0
	
		INSERT INTO ['+@DBName0000+'].[pub].tblTPHistories
			(ProcessID, ProcessNo, FiscalYear, SerialNo, TaxSerialNo, TaxID, BaseTaxID, SendDateTime, [Status], ReferenceNumber, TPEdited, BaseSerialNo, BaseProcessNo, BaseProcessID, BaseFiscalYear, TPCanceled)
		SELECT 
			 ProcessID, ProcessNo, FiscalYear, SerialNo ,SerialNo , TaxID,BaseTaxID,GETDATE(),SendTaxTollState,ReferenceID,TPEdited,BaseSerialNo, BaseProcessNo, BaseProcessID, BaseFiscalYear, isnull(TPCanceled,0)
		FROM ['+@DBName+'].[inv].[tblStorageDocsHdr]
		where (SendTaxTollState=3 OR SendTaxTollState=2 )and (ProcessID=100 or ProcessID=90) and NoSentSale2TTMS<>2'

	PRINT @StrString
	EXEC sp_executesql @StrString



END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
