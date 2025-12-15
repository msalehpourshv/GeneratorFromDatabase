USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : mr.moayed
-- Create date   : 1403/06/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_AppService_GetGoodsDfStoreIDList

@GoodsID as NVARCHAR(4000)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery  NVARCHAR(Max)
	
BEGIN TRY

	SET @strQuery='SELECT ISNULL(DfStoreID,'''') as DfStoreID,GoodsID  FROM inv.tblGoods WHERE GoodsID IN (' + @GoodsID + ')'

PRINT @strQuery
EXEC sp_executesql @strQuery

END TRY
BEGIN CATCH
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)
END CATCH

END	
GO
