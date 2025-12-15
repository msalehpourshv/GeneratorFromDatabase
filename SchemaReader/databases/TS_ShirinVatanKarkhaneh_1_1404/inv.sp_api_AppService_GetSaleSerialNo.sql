USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/10/13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE [inv].[sp_api_AppService_GetSaleSerialNo]

@TransferSerialNO As NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @strSelect  NVARCHAR(MAX)
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @SerialNo INT

BEGIN TRY

	SELECT @SerialNo=  SerialNo  from inv.tblStorageDocsHdr where TransferSerialNo=@TransferSerialNO
	if(@SerialNo>0)
		Select @SerialNo as SerialNo
	else 
		select 0 as SerialNo

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
