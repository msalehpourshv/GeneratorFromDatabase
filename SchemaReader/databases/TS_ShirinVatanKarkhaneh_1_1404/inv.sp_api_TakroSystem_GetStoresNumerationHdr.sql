USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : mr.moayed
-- Create date   : 1403/09/10
-- Viewed By     : 
-- Last Modified : moayed 1403/10/12 
-- Description   : برگه شمارش انبار
-- =============================================
CREATE PROCEDURE inv.sp_api_TakroSystem_GetStoresNumerationHdr
    @Filter NVARCHAR(50),
    @Skip INT,
    @MaxResultCount INT,
    @UserID NVARCHAR(50)
WITH ENCRYPTION
AS
BEGIN
    DECLARE @StrErrorMessage NVARCHAR(MAX)
    DECLARE @strQuery NVARCHAR(MAX)
    DECLARE @strDataBase NVARCHAR(MAX)
BEGIN TRY

    -- استخراج نام پایگاه داده و تغییر آن
    SET @strDataBase = DB_NAME();
    SET @strDataBase = SUBSTRING(@strDataBase, 1, LEN(@strDataBase) - 4) + '0000';

    -- ایجاد کوئری اصلی
    SET @strQuery = '
        WITH NumberedResults AS (
            SELECT 
                '''' AS AcntCode,
                h.DocDate,
                h.DocDesc,
                0 AS FiscalYear,
                0 AS ProcessNo,
                145 AS ProcessID,
                h.SerialNo,
                0 AS DocStep,
                h.StoreID,
                '''' AS StoreID2,
                ISNULL(pub.GetStoreName(h.StoreID,1),'''') AS StoreName,
                '''' AS StoreName2,
                ROW_NUMBER() OVER (ORDER BY h.SerialNo DESC) AS RowNum
            FROM [inv].[tblStoresNumerationHdr] h
            WHERE (SELECT UserID FROM ' + @strDataBase + '.pub.funGetUserInfo (h.SessionNo)) = @UserID'

    -- افزودن فیلتر
    IF @Filter <> ''
    BEGIN
        SET @strQuery = @strQuery + ' AND h.SerialNo LIKE ''%' + @Filter + '%'''
    END

    -- افزودن Paging با استفاده از RowNum
    SET @strQuery = @strQuery + '
        )
        SELECT AcntCode, DocDate, DocDesc, FiscalYear, ProcessNo, ProcessID, SerialNo, 
               DocStep, StoreID, StoreID2, StoreName, StoreName2
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
