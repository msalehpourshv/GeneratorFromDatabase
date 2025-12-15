USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [pub].[funCreateFilterString]
	@SchemaName AS Char(3),
	@tableName Varchar(100),
	@CompressTableName Varchar(5),
	@Value NVarchar(1000)

WITH ENCRYPTION
AS
BEGIN
	Declare @Result NVarchar(MAX) 
	Declare @sql Nvarchar(MAX) 
	
	DECLARE @Name VarChar(100)

	CREATE TABLE #Columns (name varchar(100))

	SET @sql = N'INSERT INTO #Columns
	SELECT name 
	From sys.columns 
	Where object_id = (
						Select object_id 
						From sys.tables 
						Where name =''' + @tableName + ''' AND 
							  schema_id = (
											Select schema_id 
											From sys.schemas 
											Where Name =''' + @SchemaName + '''
										   )
					 ) '

	Exec sp_executesql @sql

	SELECT @Value = replace(@Value,' ','%')

	SET @Result = '('

	Declare cur Cursor  For 
	Select name 
	From #Columns 

	Open cur
	FETCH NEXT FROM cur INTO	@Name

	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @Result = @Result + @CompressTableName + '.' + @Name + ' like N''%' + @Value + '%'' OR '
				
			FETCH NEXT FROM cur INTO @Name
				 
		END -- WHILE 

	Close cur
	Deallocate cur
	
	DROP Table #Columns

	IF Len(@Result) > 0
		SET @Result=substring(@Result,1,Len(@Result)-3) + ')'
	SELECT @Result
END
GO
