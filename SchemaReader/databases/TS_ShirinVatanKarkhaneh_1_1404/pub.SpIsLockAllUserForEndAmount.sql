USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [pub].[SpIsLockAllUserForEndAmount] 
	@ActiveUserCount AS INTEGER
WITH ENCRYPTION            
AS
BEGIN
	Declare	@StrResult NVarChar(50)
		
	UPDATE pub.tblSettings
	SET SettingValue = 'False'
	WHERE SettingKey='LockAllUsersForEndAmount' AND @ActiveUserCount = 0
	
	SELECT ISNULL(SettingValue,'FALSE') 
	FROM pub.tblSettings 
	WHERE SettingKey='LockAllUsersForEndAmount'

    ALTER TABLE [inv].[tblStorageDocsDtl] ENABLE TRIGGER [trgStorageDocsDtlUpdate]

END
GO
