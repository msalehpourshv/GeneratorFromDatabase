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
create PROCEDURE [inv].[sp_api_AppService_GetOrdersId]

@Skip As int,
@MaxResultCount As int

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @strSelect  NVARCHAR(MAX)
	DECLARE @StrErrorMessage NVARCHAR(MAX)

BEGIN TRY

	SELECT  cast(SerialNo as nvarchar(100) ) as SerialNo,TransferSerialNo from inv.tblStorageDocsHdr where TransferSerialNo<>''
	
	ORDER BY SerialNo DESC
		OFFSET  @Skip  Rows 
		FETCH NEXT @MaxResultCount Rows ONLY

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
