USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : mr.moayed
-- Create date   : 1400/09/10
-- Viewed By	 : 
-- Last Modified :  
-- Description   : 
-- =============================================
Create PROCEDURE inv.sp_api_TakroSystem_DeleteStoresNumration

@SerialNo as nvarchar(50)

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

		Set @StrErrorMessage = N'برنامه برای همه کاربران قفل است و عملیات مجاز نیست.'
		raiserror (@StrErrorMessage, 16, 1)
    END;

	IF (
	 SELECT COUNT(*) FROM [inv].[tblStoresNumerationHdr]
	 WHERE SerialNo=@SerialNo)=0
	 BEGIN
	 	
		Set @StrErrorMessage = N'برگه شمارش انبار با اطلاعات وارده ، یافت نشد'
		raiserror (@StrErrorMessage, 16, 1)

	 END

		 
	 DELETE FROM [inv].[tblStoresNumerationHdr]
	 WHERE SerialNo=@SerialNo
	
	 
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
