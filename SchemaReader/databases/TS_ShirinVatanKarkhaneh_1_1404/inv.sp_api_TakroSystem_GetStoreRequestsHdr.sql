USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/09/10
-- Viewed By     : 
-- Last Modified : mr.moayed 1403/10/11
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_TakroSystem_GetStoreRequestsHdr
    @Filter NVARCHAR(50),
    @Skip INT,
    @MaxResultCount INT,
    @AcntCode NVARCHAR(50),
    @UserID NVARCHAR(50)
WITH ENCRYPTION
AS
BEGIN
    DECLARE @StrErrorMessage NVARCHAR(MAX)
    DECLARE @strQuery NVARCHAR(MAX)
    DECLARE @strDataBase NVARCHAR(MAX)
BEGIN TRY

    -- نام پایگاه داده را تغییر می‌دهیم
    SET @strDataBase = DB_NAME();
    SET @strDataBase = SUBSTRING(@strDataBase, 1, LEN(@strDataBase) - 4) + '0000';

    -- ایجاد کوئری اصلی
    SET @strQuery = '
        WITH NumberedResults AS (
            SELECT 
                h.AcntCode,
                h.DocDate,
                h.DocDesc,
                CAST(h.FiscalYear AS INT) AS FiscalYear,
                CAST(h.ProcessNo AS INT) AS ProcessNo,
                CAST(h.ProcessID AS INT) AS ProcessID,
                h.SerialNo,
                h.DocStep,
                h.StoreID,
                ISNULL(h.StoreID2, '''') AS StoreID2,
                ISNULL(s.StoreName, '''') AS StoreName,
                ISNULL(s2.StoreName, '''') AS StoreName2,
                ROW_NUMBER() OVER (ORDER BY h.SerialNo DESC) AS RowNum
            FROM inv.tblStoresRequestsHdr h
            LEFT JOIN inv.tblStoresDtl s ON s.StoreID = h.StoreID
            LEFT JOIN inv.tblStoresDtl s2 ON s2.StoreID = h.StoreID2
            WHERE h.ProcessID = 127 
              AND h.VisitorAcntCode = ''' + @AcntCode + '''
              AND (SELECT UserID FROM ' + @strDataBase + '.pub.funGetUserInfo(h.SessionNo)) = @UserID
              AND (SELECT COUNT(*) 
                   FROM inv.tblStorageDocsDtl sd 
                   WHERE h.SerialNo = sd.BaseSerialNo 
                     AND h.ProcessID = sd.BaseProcessID 
                     AND h.ProcessNo = sd.ProcessNo 
                     AND h.FiscalYear = sd.BaseFiscalYear) = 0'

    -- افزودن فیلتر در صورت نیاز
    IF @Filter <> ''
    BEGIN
        SET @strQuery = @strQuery + ' AND h.SerialNo LIKE ''%' + @Filter + '%'''
    END

    -- افزودن Paging با استفاده از RowNum
    SET @strQuery = @strQuery + '
        )
        SELECT 
            AcntCode, 
            DocDate, 
            DocDesc, 
            FiscalYear, 
            ProcessNo, 
            ProcessID, 
            SerialNo, 
            DocStep, 
            StoreID, 
            StoreID2, 
            StoreName, 
            StoreName2
        FROM NumberedResults
        WHERE RowNum BETWEEN ' + CAST(@Skip + 1 AS NVARCHAR) + ' AND ' + CAST(@Skip + @MaxResultCount AS NVARCHAR) + '
        ORDER BY RowNum'

    -- نمایش کوئری برای دیباگ
    PRINT @strQuery

    -- اجرای کوئری
    EXEC sp_executesql @strQuery, 
        N'@UserID NVARCHAR(50)', 
        @UserID

END TRY
BEGIN CATCH
    SET @StrErrorMessage = ERROR_MESSAGE()
    RAISERROR (@StrErrorMessage, 16, 1)
END CATCH

END
GO
