USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--use TS_DoostiIceCream_1_1403
-- =========== TS-QC:NOTOK ========================
-- Author        : mr.moayed
-- Create date   : 1403/09/14
-- Last Modified :
-- Description   : مدیریت وضعیت قفل کردن برگه ها و کدینگ
-- ================================================
Create PROCEDURE pub.sp_api_AppService_ManageLockedDocs
   
   @bolLockState BIT, --وضعیت قفل (1: قفل کردن، 0: حذف قفل)
   @ProcessID INT, --نوع عملیات مرتبط با فاکتور
   @ProcessNo INT, --شماره فرآیند
   @FiscalYear INT, --سال مالی فاکتور
   @SerialNo INT, --شماره برگه فاکتور مورد نظر
   @strCodeFieldValue NVARCHAR(255), -- مقدار کدینگ (کالا و مشتری و ...)
   @strTableName NVARCHAR(255), -- نام جدول مرتبط با فاکتور
   @SessionNo INT, -- شماره نشست کاربر در اینداستری
   @SessionID INT -- آیدی نشست کاربر در اینداستری

WITH ENCRYPTION
AS
BEGIN

    -- بررسی تنظیم قفل همه کاربران
    DECLARE @LockAllUsersSettingValue NVARCHAR(50);

    SELECT @LockAllUsersSettingValue = SettingValue 
    FROM pub.tblSettings 
    WHERE SettingKey = 'LockAllUsers';

    IF @LockAllUsersSettingValue = 'true'
    BEGIN
        RAISERROR (N'برنامه برای همه کاربران قفل است و عملیات مجاز نیست.', 16, 1);
        RETURN;
    END;

    -- تعریف متغیرهای لازم
    DECLARE @StrErrorMessage NVARCHAR(1024);
    DECLARE @strDataBase NVARCHAR(MAX);
    DECLARE @DynamicSQL NVARCHAR(MAX);
    DECLARE @ExistSessionNo INT;

    BEGIN TRY

	   SET @ExistSessionNo = -1
		-- بررسی وجود قفل
        SELECT @ExistSessionNo = SessionNo
        FROM pub.tblLockedDocs
        WHERE 
            ProcessID = @ProcessID AND 
            ProcessNo = @ProcessNo AND 
            FiscalYear = @FiscalYear AND 
            SerialNo = @SerialNo AND 
            CodeFieldValue = @strCodeFieldValue AND 
            TableName = @strTableName;


        -- اگر قفل باید ایجاد شود
        IF @bolLockState = 1
        BEGIN
            IF @ExistSessionNo IS NULL OR @ExistSessionNo = -1
            BEGIN

                INSERT INTO pub.tblLockedDocs 
                (ProcessID, ProcessNo, FiscalYear, SerialNo, CodeFieldValue, TableName, SessionNo)
                VALUES 
                (@ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @strCodeFieldValue, @strTableName, @SessionNo);

                PRINT 'قفل با موفقیت ایجاد شد.';
				print 'ret'


				--ایجاد سشن یا یوزر اکتیو
				SET @strDataBase = DB_NAME();
				--SET @strDataBase = CONCAT(SUBSTRING(@strDataBase, 1, LEN(@strDataBase) - 4), '0000');
				SET @strDataBase = SUBSTRING(@strDataBase, 1, LEN(@strDataBase) - 4)+ '0000';
				-- ساخت کوئری داینامیک برای اجرای UpdateActiveUsers
				SET @DynamicSQL = N'EXEC ' + @strDataBase + '.pub.UpdateActiveUsers @SessionNoParam';
				print @DynamicSQL
				
				EXEC sp_executesql 
					@DynamicSQL,
					N'@SessionNoParam INT',
					@SessionNoParam = @SessionNo;

				select 0 RetValue
            END
            ELSE
            BEGIN
				
				IF @ExistSessionNo IS NOT NULL AND @ExistSessionNo<> -1
				BEGIN
					
					SET @strDataBase = DB_NAME();
					--SET @strDataBase = CONCAT(SUBSTRING(@strDataBase, 1, LEN(@strDataBase) - 4), '0000');
					SET @strDataBase = SUBSTRING(@strDataBase, 1, LEN(@strDataBase) - 4) + '0000';

					--ایجاد سشن یا یوزر اکتیو
					SET @DynamicSQL = N'EXEC ' + @strDataBase + '.pub.UpdateActiveUsers @SessionNoParam';
					EXEC sp_executesql 
						@DynamicSQL,
						N'@SessionNoParam INT',
						@SessionNoParam = @SessionNo;

					-- در این قسمت باید سشن ها بررسی شود که در صورت مغایرت خطا بدهد
					PRINT 'قفل از قبل موجود است.';

					
					-- بررسی فعال بودن سشن
				DECLARE @IsActiveSessionOutput INT;
				If @ExistSessionNo <> 0 And @ExistSessionNo <> @SessionNo 
					BEGIN

					SET @DynamicSQL = 'declare @Active as int
					Declare @intLockerSessionID int

					SELECT @intLockerSessionID = SessionID
					FROM ' + @strDataBase + '.usr.tblSessionNumbers
					WHERE SessionNo = ' + ltrim(str(@ExistSessionNo)) + ' 

					SET @intLockerSessionID = ISNULL (@intLockerSessionID, 0)
                                                                             

					IF @intLockerSessionID = 0 OR @intLockerSessionID = ' + ltrim(str(@SessionID)) + '
	   
						SELECT @Active = 0

					ELSE

					   SELECT @Active = ISNULL (COUNT(*), 0)
					   FROM ' + @strDataBase + '.usr.tblActiveUsers 
					   WHERE SessionNo = ' + ltrim(str(@ExistSessionNo)) + ' AND 
							 DateAdd (Minute,6,RefreshDateTime) >= GetDate()

					IF @Active > 0
						SELECT ' + ltrim(str(@ExistSessionNo)) + ' RetValue
					ELSE 
						SELECT 0 RetValue '

				EXEC sp_executesql @DynamicSQL
					--print '6'

					--	-- ساخت کوئری داینامیک برای اجرای spIsActiveSessionOutPut
					--	SET @DynamicSQL = '
					--		EXEC ' + @strDataBase + '.pub.spIsActiveSessionOutPut 
					--			@LockerSessionNo, 
					--			@ActiveSessionID, 
					--			@Active OUTPUT;';
						
					--	SET @DynamicSQL = N'
					--		SELECT RetValue = @ActiveSessionID
					--	'

					--	EXEC sp_executesql 
					--		@DynamicSQL,
					--		N'@LockerSessionNo INT, @ActiveSessionID INT, @Active INT OUTPUT',
					--		@LockerSessionNo = @ExistSessionNo,       -- پارامتر صحیح برای شماره نشست
					--		@ActiveSessionID = @SessionID,            -- پارامتر صحیح برای آیدی نشست
					--		@Active = @IsActiveSessionOutput OUTPUT;

						----	@LockerSessionNo : پارامتر صحیح برای شماره نشست
						----	@ActiveSessionID : پارامتر صحیح برای آیدی نشست
						----	@Active : پارامتر برای خروجی
						
						----	if RetValue > 0 'برگه توسط کاربر دیگر قفل شده است'
						----	if RetValue = 0 'برگه آزاد هست'

						-- پرینت مقدار خروجی بعد از اجرای sp_executesql
						--PRINT 'IsActiveSessionOutput: ' + CAST(@IsActiveSessionOutput AS NVARCHAR(50));

							--If @IsActiveSessionOutput >0 
							--	BEGIN
							--		PRINT 'برگه توسط کاربر دیگر قفل شده است';
							--		print 'ret'
							--	   -- select @IsActiveSessionOutput  RetValue
							--	END
							--else 
							--	BEGIN
							--		print 'ret توسط کاربر دیگر قفل نشده'
							--		--select 0 RetValue
							--	END
					
					END
      				ELSE
					BEGIN
						print 'ret'
						select 0 RetValue
					END
					
				END
			END
		END	
		 ELSE
        BEGIN
            -- حذف قفل در صورت نیاز
            DELETE FROM pub.tblLockedDocs
            WHERE 
                TableName = @strTableName AND 
                SerialNo = @SerialNo AND 
                ProcessID = @ProcessID AND 
                ProcessNo = @ProcessNo AND 
                FiscalYear = @FiscalYear AND 
                CodeFieldValue = @strCodeFieldValue;

            PRINT 'قفل با موفقیت حذف شد.';
			print 'ret'
			select 0 RetValue
        END

    END TRY
    BEGIN CATCH
 
		SET @StrErrorMessage = ERROR_MESSAGE() 
		RAISERROR (@StrErrorMessage, 16, 1)


        -- مدیریت خطا
        --SET @StrErrorMessage = ERROR_MESSAGE(); 
        --THROW 50000, @StrErrorMessage, 1;

    END CATCH
END;
GO
