USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [pub].[spSetAccessAllCode]
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
	Declare @ParmDefinition NVarChar(200)
  	DECLARE @MaxRangeID AS INT 
	
	SET @ParmDefinition = N'@ResaultOUT INT  OUTPUT';
	
	SET @strSql = 
		'SELECT @ResaultOUT= MAX(RangeID)+ 1 FROM ' + @TableName
		
	Exec sp_executesql @strSql,@ParmDefinition, @ResaultOUT = @MaxRangeID OUTPUT;
	
	
	SET @strSql = 
	    'INSERT INTO ' + @TableName +
		' (RangeID,UserID,FromCode,ToCode,AllowCodeView,AccessAllCode'
	
	
	IF @PartNumber > 0
		SET @strSql = @strSql + ',PartNumber'

	SET @strSql = @strSql + ' ) Values (' + LTRIM(STR(@MaxRangeID)) + ',' + LTRIM(STR(@UserID))+ ','''','''',1,1'
	
	IF @PartNumber > 0
		SET @strSql = @strSql + ',' + LTRIM(STR(@PartNumber))
		

	SET @strSql = @strSql + ' )'
	EXEC sp_executesql @strSql;

END

GO
