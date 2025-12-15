USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/04/22
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[sp_api_saymandigital_GetSerials]
@GoodsID AS VARCHAR(20),
@PSerialNo varchar(30),
@EnterKind smallint


WITH ENCRYPTION
 AS
BEGIN
DECLARE @ProductSerial as int
Declare @StrErrorMessage As Nvarchar(1024)
DECLARE @StoreLayer  AS INT

BEGIN TRY

	exec @ProductSerial= inv.SpSaveProductSerial @GoodsID,@PSerialNo,@EnterKind,''
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
