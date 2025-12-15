USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/10/12
-- Viewed By	 : 
-- Last Modified : mr.moayed 1403/06/05
-- Description   : 
-- =============================================
Create PROCEDURE inv.sp_api_TakroSystem_DeleteStoreRequests
@SerialNo as nvarchar(50),
@ProcessNo as tinyint,
@FiscalYear as nvarchar(50)


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
BEGIN TRY

	DECLARE @LockAllUsersSettingValue NVARCHAR(50);

    SELECT @LockAllUsersSettingValue = SettingValue 
    FROM pub.tblSettings 
    WHERE SettingKey = 'LockAllUsers';

    IF @LockAllUsersSettingValue = 'true'
    BEGIN
        RAISERROR (N'برنامه برای همه کاربران قفل است و عملیات مجاز نیست.', 16, 1);
        RETURN;
    END;
	
	IF (
	 SELECT COUNT(*) FROM inv.tblStoresRequestsHdr 
	 WHERE ProcessID='127' and ProcessNo=@ProcessNo 
	 and FiscalYear=@FiscalYear and SerialNo=@SerialNo)=0
	 BEGIN
	 	
		Set @StrErrorMessage = N'برگه درخواست انتقال با اطلاعات وارده ، یافت نشد'
		raiserror (@StrErrorMessage, 16, 1)

	 END

		 
	 DELETE FROM inv.tblStoresRequestsHdr 
	 WHERE ProcessID='127' and ProcessNo=@ProcessNo 
	 and FiscalYear=@FiscalYear and SerialNo=@SerialNo
	

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
