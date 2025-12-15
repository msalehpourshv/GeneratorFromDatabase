USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/09/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[sp_api_TakroSystem_UpdateSaleOrderHdrPrice]
@ProcessNo as tinyint,
@FiscalYear as SMALLINT,
@SerialNo as Int,
@Price as FLOAT

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)

BEGIN TRY

	update sal.tblSaleOrderHdr
	set Price=@Price
	where
	 ProcessID=180 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo
    
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
