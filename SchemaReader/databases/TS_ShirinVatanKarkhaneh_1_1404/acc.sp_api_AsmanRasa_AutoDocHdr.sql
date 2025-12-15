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
CREATE  PROCEDURE [acc].[sp_api_AsmanRasa_AutoDocHdr]

@DocDate AS NVARCHAR(10),
@DocDesc AS Nvarchar(200)

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @MAxSerialNo AS INT

BEGIN TRY

	SELECT @MAxSerialNo=  MAX(SerialNo) FROM [acc].[tblVoucherHdr]

	SET @MAxSerialNo=@MAxSerialNo+1;
	
	INSERT INTO acc.tblVoucherHdr
	(DocDate,SerialNo,DocDesc2,VchKind)
	
	VALUES (@DocDate ,@MAxSerialNo,@DocDesc,1)

	SELECT @MAxSerialNo AS MaxSerialNo

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
