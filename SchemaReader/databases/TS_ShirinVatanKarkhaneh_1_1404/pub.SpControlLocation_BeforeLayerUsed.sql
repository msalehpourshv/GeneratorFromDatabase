USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--[pub].[SpControlLocation_BeforeLayerUsed] '0101',1
CREATE PROCEDURE  [pub].[SpControlLocation_BeforeLayerUsed]

	@LocationID as  varchar(20)='',
	@LngID as tinyint=1
	
WITH ENCRYPTION
AS
Begin

	DECLARE @flg tinyint
	DECLARE @RowID smallint
	DECLARE @CountResault AS INT
	DECLARE @RelatedTableNameWithSchema varchar(50)
	DECLARE @RelatedFieldName varchar(200)
	Declare @ParmDefinition NVarChar(200)
	Declare @RelatedTableName NVarChar(100)
	DECLARE @sql Nvarchar(Max)
	
	SET @flg = 0
	Declare	curLocation CURSOR For 
	SELECT	RowID,RelatedTableNameWithSchema,RelatedFieldName
	FROM pub.tblTablesRelations
	WHERE SourceTableNameWithSchema= 'pub.tblLocations'

	Open  curLocation; 

	Fetch NEXT From curLocation Into @RowID,@RelatedTableNameWithSchema,@RelatedFieldName

	While (@@Fetch_Status = 0) AND @flg = 0 
	BEGIN
		SET @CountResault = 0		
		SET @ParmDefinition = N'@CountOUT as int OUTPUT';
		SET @sql = 'SELECT @CountOUT = COUNT(*) FROM ' + @RelatedTableNameWithSchema + ' WHERE ' + @RelatedFieldName + '=''' + @LocationID + ''''
		
		Exec sp_executesql @sql,@ParmDefinition, @CountOUT = @CountResault OUTPUT;
		IF @CountResault>0
		begin
			print @RelatedTableNameWithSchema
			print @RelatedFieldName
			SELECT @RelatedTableName=RelatedTableName FROM pub.tblTablesRelationsDtl WHERE RowID = @RowID
			
			SET @flg=1
		end

		Fetch NEXT From curLocation Into @RowID,@RelatedTableNameWithSchema,@RelatedFieldName
	END
	
	Close curLocation;
	Deallocate curLocation; 

	IF @flg = 1
		SELECT 'در برگه های ' + @RelatedTableName + 'استفاده شده است. اجازه ایجاد کد را ندارید'	 Used
	ELSE	
		SELECT TOP 0 '' as Used
END
GO
