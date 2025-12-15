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
CREATE PROCEDURE inv.sp_api_TakroSystem_GetSettingInfo

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @TPStartDate NVARCHAR(MAX)
	DECLARE @PrivateKey NVARCHAR(MAX)
	DECLARE @Url NVARCHAR(MAX)
	DECLARE @TaxMemory NVARCHAR(MAX)
	DECLARE @SalPos bit


BEGIN TRY
	
	-----------------------------Tins--------------------------------------------

		SELECT @SalPos=RTRIM(lTRIM(SettingValue)) FROM pub.tblSettings
		WHERE SettingKey =  'Sal_SaleProcessForTaxTollSenderPos'

		SELECT @TaxMemory=RTRIM(lTRIM(SettingValue)) FROM pub.tblSettings
		WHERE SettingKey =  'TPMemoryTax'

		SELECT @TPStartDate=RTRIM(lTRIM(SettingValue)) FROM pub.tblSettings
		WHERE SettingKey =  'TPStartDate'


		SELECT @PrivateKey=RTRIM(lTRIM(SettingValue)) FROM pub.tblSettings
		WHERE SettingKey =  'TPPrivateKey'

		SELECT  @Url =RTRIM(lTRIM(SettingValue)) FROM pub.tblSettings
		WHERE SettingKey =  'TPURL'

		IF(ISNULL(@TaxMemory,'')='')
		BEGIN
			Set @StrErrorMessage = N'لطفا شناسه حافظه مالیاتی را مقداردهی کنید'
			raiserror (@StrErrorMessage, 16, 1)
		END

		IF(ISNULL(@PrivateKey,'')='')
		BEGIN
			Set @StrErrorMessage = N'لطفا کلید خصوصی گواهی امضا الکترونیکی را مقداردهی کنید'
			raiserror (@StrErrorMessage, 16, 1)
		END

		--IF(ISNULL(@Url,'')='')
		--BEGIN
		--	Set @StrErrorMessage = N'لطفا لینک اتصال به سامانه مالی را مقداردهی کنید'
		--	raiserror (@StrErrorMessage, 16, 1)
		--END

		SELECT  @TPStartDate AS StartDate,@TaxMemory AS TaxMemory,@PrivateKey AS PrivateKey,@Url AS Url,isnull(@SalPos,0) as SalePos

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
