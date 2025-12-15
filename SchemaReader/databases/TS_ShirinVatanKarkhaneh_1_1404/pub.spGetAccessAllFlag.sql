USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		MM
-- =============================================
CREATE PROCEDURE [pub].[spGetAccessAllFlag]
(
	@TableName  VarChar(50),
	@UserID int,
	@PartNumber int
)
WITH ENCRYPTION            
AS

BEGIN
	SET NOCOUNT ON;

  	DECLARE @strSql AS NVarChar(500) 

	SET @strSql = 
	    'SELECT TOP 1 AccessAllCode FROM ' + @TableName +
		' WHERE UserID=' + str(@UserID)
		
	IF @PartNumber > 0
		SET @strSql = @strSql + ' AND PartNumber=' + STR(@PartNumber)

	SET @strSql = @strSql + ' order by AccessAllCode desc ' 
	EXEC sp_executesql @strSql;

END

GO
