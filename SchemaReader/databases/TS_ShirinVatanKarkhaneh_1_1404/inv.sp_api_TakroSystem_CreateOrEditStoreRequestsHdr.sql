USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : mr.moayed
-- Create date   : 1403/06/06
-- Viewed By	 : 
-- Last Modified : 1403/09/29
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[sp_api_TakroSystem_CreateOrEditStoreRequestsHdr]
@ProcessNo as Int,
@FiscalYear as Int,
@SerialNo as Int,
@DocDate as CHAR(10),
@StoreID AS VARCHAR(20),
@DocDesc as NVARCHAR(500),
@SessionNo as int,
@StoreID2 as VARCHAR(20),
@TransferSerialNo as nvarchar(50),
@VisitorAcntCode as VARCHAR(20)

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
		where StoreID in (@StoreID ,@StoreID2 ) ) < 2
	BEGIN
		Set @StrErrorMessage = N'کد انبار نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	
	if(@SerialNo=0)
		
		BEGIN
		
			IF (SELECT Count(*) FROM inv.tblStoresRequestsHdr
			where TransferSerialNo=@TransferSerialNo) > 0
				BEGIN
					set @IsExist=1
					select @maxSerialNo=SerialNo,@FiscalYear=FiscalYear,@TransferSerialNo=TransferSerialNo 
					FROM inv.tblStoresRequestsHdr where TransferSerialNo=@TransferSerialNo

				END	
			ELSE
				BEGIN

					-- بررسی BaseSerialNo
					IF (SELECT BaseSerialNo 
						FROM inv.tblStoresRequestsHdr
						WHERE ProcessID = 127 AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND SerialNo = @SerialNo) > 0
					BEGIN
						SET @StrErrorMessage = N'این برگه تبدیل شده است و قابلیت تغییر ندارد';
						RAISERROR (@StrErrorMessage, 16, 1);
					END;

					SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
					FROM inv.tblStoresRequestsHdr
					WHERE ProcessID=127
					 AND ProcessNo=@ProcessNo
					 AND FiscalYear=@FiscalYear
			 
					SET @maxSerialNo = @maxSerialNo + 1

					INSERT INTO inv.tblStoresRequestsHdr
					(ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,StoreID,DocDesc,SessionNo,StoreID2,TransferSerialNo,AutoOrder,VisitorAcntCode)
					VALUES(127, @ProcessNo, @FiscalYear, @maxSerialNo, @DocDate, @StoreID,@DocDesc,@SessionNo,@StoreID2,@TransferSerialNo,'True',@VisitorAcntCode)
				END
	    END

	ELSE 

		BEGIN

			SET @maxSerialNo = @SerialNo
			
			print 'update'
			update inv.tblStoresRequestsHdr
			set DocDesc=@DocDesc
			where ProcessID=127 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo 

		END
			
	
	SELECT 127 as 'ProcessID', @ProcessNo as 'ProcessNo', @FiscalYear as 'FiscalYear', @maxSerialNo as 'SerialNo', @DocDate, @StoreID, @DocDesc, @SessionNo, @StoreID2, @TransferSerialNo as 'TransferSerialNo','True', @VisitorAcntCode,@IsExist as 'IsExist'

END TRY

BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
