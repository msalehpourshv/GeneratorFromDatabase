USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		MM
-- =============================================
CREATE PROCEDURE [pub].[spGetTableStruct]
(
	@HdrTable		VarChar(50),
	@JoinFieldName	VarChar(50)	= null
)
WITH ENCRYPTION            
AS

BEGIN
	SET NOCOUNT ON;

    --SET FMTONLY OFF;
	--SET NO_BROWSETABLE ON; 
	--SET FMTONLY ON; 

	----------------   
  
	DECLARE @strSql AS NVarChar(500) 

	IF @JoinFieldName is null
		SET @strSql = N'SELECT TOP 0 * FROM ' + @HdrTable 
	ELSE
		SET @strSql = N'SELECT TOP 0 * FROM ' + @HdrTable + ','  + @HdrTable + 'Dtl ' +
					   'WHERE ' + @HdrTable + '.' + @JoinFieldName + '=' +
								  @HdrTable + 'Dtl.' + @JoinFieldName + ';'

	EXEC sp_executesql @strSql;
	----------------   
	--SET FMTONLY OFF; 
	--SET NO_BROWSETABLE OFF;

END
GO
