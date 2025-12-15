USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alianpour
-- Create date   : 1400/11/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[sp_api_AsmanRasa_IsCreateVocherHdr]

@DocDate AS NVARCHAR(10)

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)

BEGIN TRY


if(SUBSTRING(@DocDate,1,4)>='1401')
begin
	IF(SELECT COUNT(*) FROM [acc].[tblVoucherDtl] WHERE IsAutoDoc=1 and SourceCodeFieldValue<>'' and DocDate=@DocDate)>0

	BEGIN
		SELECT  Top(1) SerialNo AS HdrSerialNo FROM [acc].[tblVoucherDtl] WHERE IsAutoDoc=1 and SourceCodeFieldValue<>'' and DocDate=@DocDate
	END

	ELSE
		SELECT 0 AS HdrSerialNo
end
else
	SELECT 0 AS HdrSerialNo
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
