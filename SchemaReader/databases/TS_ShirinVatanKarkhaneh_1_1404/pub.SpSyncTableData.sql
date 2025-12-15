USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--pub.SpSyncTableData 'TS_MaadsaSanat_1_1403','TS_MaadsaSanat_1_1404','tblGoods','inv','False',''

Create PROCEDURE pub.SpSyncTableData
@SourceDBName NVARCHAR(500),
@TargetDBName NVARCHAR(500),
@TableName NVARCHAR(500),
@SchemaName NVARCHAR(10), 
@UpdateCodes Bit='False',
@UpdateCodesName NVARCHAR(4000)=''
WITH ENCRYPTION
AS
BEGIN
	DECLARE @SQL NVARCHAR(MAX)
	DECLARE @SQL1 NVARCHAR(MAX)=''
	DECLARE @SQL2 NVARCHAR(MAX)=''
	DECLARE @Columns NVARCHAR(MAX) = ''
	DECLARE @UpdateColumns NVARCHAR(MAX) = ''
	DECLARE @WhereUpdateColumns NVARCHAR(MAX) = ''
	DECLARE @PrimaryKeys NVARCHAR(MAX) = ''
	DECLARE @TableObjectId INT
	DECLARE @IsImage NVARCHAR(MAX)=''

	-- Get the table object_id from the source database
	SET @SQL = 'SELECT @TableObjectId = OBJECT_ID(''' + @SourceDBName + '.' + @SchemaName + '.' + @TableName + ''')'
	EXEC sp_executesql @SQL, N'@TableObjectId INT OUTPUT', @TableObjectId OUTPUT

	--print @SQL
	-- Get the list of columns excluding computed columns
	SELECT @Columns = @Columns + COLUMN_NAME + ', '
	FROM (
	SELECT c.name AS COLUMN_NAME
	FROM sys.columns c
	JOIN sys.tables t ON c.object_id = t.object_id
	JOIN sys.schemas s ON t.schema_id = s.schema_id
	WHERE t.name = @TableName
	AND s.name = @SchemaName
	AND c.is_computed = 0
	) AS ColumnsList

	-- Remove the trailing comma
	SET @Columns = LEFT(@Columns, LEN(@Columns) - 1)

	-- Get the list of primary keys
	SELECT @PrimaryKeys = @PrimaryKeys + 'TRG.' + c.name + ' = SRC.' + c.name + ' AND '
	FROM sys.columns c
	JOIN sys.tables t ON c.object_id = t.object_id
	JOIN sys.schemas s ON t.schema_id = s.schema_id
	JOIN sys.index_columns ic ON c.object_id = ic.object_id AND c.column_id = ic.column_id
	JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
	WHERE t.name = @TableName
	AND s.name = @SchemaName
	AND i.is_primary_key = 1

	-- Remove the trailing ' AND '
	SET @PrimaryKeys = LEFT(@PrimaryKeys, LEN(@PrimaryKeys) - 4)

	-- Generate the UPDATE statement
	SELECT @UpdateColumns = @UpdateColumns + c.name + ' = SRC.' + c.name + ', ',
	       @WhereUpdateColumns = @WhereUpdateColumns + ' TRG.' + c.name + ' <> SRC.' + c.name + ' OR ',
		   @IsImage=@IsImage + CASE WHEN system_type_id=34 THEN 'True' ELSE '' END
	FROM sys.columns c
	JOIN sys.tables t ON c.object_id = t.object_id
	JOIN sys.schemas s ON t.schema_id = s.schema_id
	WHERE t.name = @TableName
	AND s.name = @SchemaName
	AND c.is_computed = 0
	AND c.name not in (@UpdateCodesName)

	-- Remove the trailing comma
	SET @UpdateColumns = LEFT(@UpdateColumns, LEN(@UpdateColumns) - 1)
	SET @WhereUpdateColumns = LEFT(@WhereUpdateColumns, LEN(@WhereUpdateColumns) - 3)

	IF @UpdateCodes = 'True'
	BEGIN
		SET @SQL = 'UPDATE ' + @TargetDBName + '.' + @SchemaName + '.' + @TableName + ' 
		            SET ' + @UpdateColumns  + '
					FROM ' + @TargetDBName + '.' + @SchemaName + '.' + @TableName + ' TRG
					INNER JOIN ' + @SourceDBName + '.' + @SchemaName + '.' + @TableName + ' AS SRC
					ON ' + @PrimaryKeys  
		IF LEN(@IsImage)=0
			SET @SQL =	@SQL+ ' WHERE ' + @WhereUpdateColumns
		print @SQL
		EXEC sp_executesql @SQL
	END

	-- Generate the MERGE statement
	SET @SQL = '
	MERGE ' + @TargetDBName + '.' + @SchemaName + '.' + @TableName + ' AS TRG
	USING ' + @SourceDBName + '.' + @SchemaName + '.' + @TableName + ' AS SRC
	ON (' + @PrimaryKeys + ') '
	--IF @UpdateCodes = 'True'
	--	SET @SQL1 ='
	--		WHEN MATCHED THEN
	--		UPDATE SET ' + @UpdateColumns 
	SET @SQL2 ='
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (' + @Columns + ') VALUES (' + @Columns + ');'

	-- Execute the generated SQL
	--print @SQL
	--print @SQL1
	--print @SQL2
	SET @SQL = @SQL +@SQL1+@SQL2
	print @SQL
	EXEC sp_executesql @SQL
END
GO
