USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : mr.moayed
-- Create date   : 1403/09/10
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE inv.sp_api_TakroSystem_CreateOrEditStoresNumerationHdr

@SerialNo as Int,
@DocDate as CHAR(10),
@StoreID AS VARCHAR(20),
@DocDesc as NVARCHAR(500),
@SessionNo as int,
@TransferSerialNo as nvarchar(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @maxSerialNo INT
	DECLARE @IsExist INT=0

	Declare @StrErrorMessage As Nvarchar(1024)
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
	
	IF (SELECT Count(*) FROM inv.tblStores
		where StoreID in (@StoreID ) ) < 1
	BEGIN
		Set @StrErrorMessage = N'کد انبار نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	
	if(@SerialNo=0)
		
		BEGIN
		
			IF (SELECT Count(*) FROM inv.tblStoresNumerationHdr
			where TransferSerialNo=@TransferSerialNo) > 0
				BEGIN

					set @IsExist=1
					select @maxSerialNo=SerialNo,@TransferSerialNo=TransferSerialNo 
					FROM inv.tblStoresNumerationHdr where TransferSerialNo=@TransferSerialNo
										
					print 'IsExist'
				END	
			ELSE
				BEGIN

					SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
					FROM inv.tblStoresNumerationHdr

					SET @maxSerialNo = @maxSerialNo + 1
					
					print @maxSerialNo
					print 'INSERT'
			 
					INSERT INTO [inv].[tblStoresNumerationHdr]
					   ([SerialNo],[DocDate],[StoreID],[DocDesc],[SessionNo],[TransferSerialNo],[IsAutoDoc])
						VALUES(@maxSerialNo,@DocDate,@StoreID,@DocDesc,@SessionNo,@TransferSerialNo,'True')
				END
	    END

	ELSE 

		BEGIN

			SET @maxSerialNo = @SerialNo
			
			print 'update'
			update [inv].[tblStoresNumerationHdr]
			set DocDesc=@DocDesc
			where SerialNo=@SerialNo 

		END
			
	
	SELECT 145 as 'ProcessID', 0 as 'ProcessNo', 0 as 'FiscalYear', @maxSerialNo as 'SerialNo', @DocDate, @StoreID, @DocDesc, @SessionNo,  @TransferSerialNo as 'TransferSerialNo','True',@IsExist as 'IsExist'

END TRY

BEGIN CATCH

print 'error'
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
