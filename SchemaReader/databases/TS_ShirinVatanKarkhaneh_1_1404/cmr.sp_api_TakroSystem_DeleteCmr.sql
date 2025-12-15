USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/10/12
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE cmr.sp_api_TakroSystem_DeleteCmr
@SerialNo as nvarchar(50),
@ProcessNo as tinyint,
@FiscalYear as nvarchar(50)


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
BEGIN TRY

	IF (
	 SELECT COUNT(*) FROM cmr.tblCMRHdr
	 WHERE ProcessID='150' and ProcessNo=@ProcessNo 
	 and FiscalYear=@FiscalYear and SerialNo=@SerialNo)=0
	 BEGIN
	 	
		Set @StrErrorMessage = N'سفارش فروشی  با این اطلاعات وجود ندارد'
		raiserror (@StrErrorMessage, 16, 1)

	 END

		 
	 DELETE FROM cmr.tblCMRHdr
	 WHERE ProcessID='150' and ProcessNo=@ProcessNo 
	 and FiscalYear=@FiscalYear and SerialNo=@SerialNo
	
	 
	 DELETE FROM cmr.tblCMRDtl
	 WHERE ProcessID='150' and ProcessNo=@ProcessNo 
	 and FiscalYear=@FiscalYear and SerialNo=@SerialNo

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
