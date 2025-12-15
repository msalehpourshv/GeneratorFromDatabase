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
create PROCEDURE inv.sp_api_TakroSystem_GetPreviousRetSale
@ProcessNo		AS INT,
@SerialNo		AS INT,
@BaseSerialNo	AS nvarchar(50),
@BaseProcessID	AS INT,
@BaseProcessNo	AS INT,
@BaseFiscalYear AS INT

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @StrErrorMessageTax NVARCHAR(MAX)

BEGIN TRY

	IF(
		SELECT COUNT(*) FROM inv.tblStorageDocsHdr
		WHERE BaseSerialNo=@BaseSerialNo AND BaseFiscalYear=@BaseFiscalYear AND BaseProcessID=@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND  SerialNo<@SerialNo AND  ProcessID=100
	     AND  ProcessNo=@ProcessNo  AND  SendTaxTollState<>3)>0
	BEGIN

		SET @StrErrorMessage = N'برگشت از فروش قبلی این فاکتور ارسال نشده است و با توجه به محاسبه برگشت از فروش لطفا ابتدا آن را ارسال کنید'
		RAISERROR (@StrErrorMessage, 16, 1)
	END


	
END TRY

BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	RAISERROR (@StrErrorMessage, 16, 1)

END CATCH

END
GO
