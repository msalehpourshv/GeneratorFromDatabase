USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		 Sadeghi, Hadi
-- Create date: 
-- Description:
-- ==============================================
CREATE PROCEDURE [pub].[spGetOtherAcntPartsRelationAry]
	@TableName varchar(250),
	@PartNumber Char(1),
	@CodeName VarChar(20),
	@CodeValue VarChar(20)
WITH ENCRYPTION
As 
BEGIN

  	DECLARE @strSql AS NVarChar(500) 

	SET @strSql = 
	    'SELECT TOP 1 HasDetail FROM ' + @TableName +
		' WHERE PartNumber = ' + @PartNumber + ' AND ' + @CodeName + '=''' + @CodeValue + ''''
		
	EXEC sp_executesql @strSql;
	
END
GO
