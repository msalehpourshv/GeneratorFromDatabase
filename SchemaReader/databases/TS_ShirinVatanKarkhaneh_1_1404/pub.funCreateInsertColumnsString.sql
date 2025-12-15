USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

--EXEC [pub].[funCreateInsertColumnsString] 
--					@SchemaName='inv',
--					@tableName='tblGoods',
--					@ColumnsName=''

CREATE PROCEDURE [pub].[funCreateInsertColumnsString]
	@SchemaName AS Char(3),
	@tableName Varchar(300),
	@ColumnsName Varchar(4000)

WITH ENCRYPTION
AS
BEGIN
	Declare @sql Nvarchar(4000) 
	
	DECLARE @Name VarChar(100)
	DECLARE @Result NVarChar(max)

	CREATE TABLE #Columns (name varchar(100))

	SET @sql = 'INSERT INTO #Columns
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
					 ) AND 
			name NOT IN (''' + @ColumnsName + ''')  and is_computed=0 '

	Exec sp_executesql @sql

	SET @Result = ''

	Declare cur Cursor  For 
	Select name 
	From #Columns 

	Open cur
	FETCH NEXT FROM cur INTO	@Name

	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @Result = @Result + @Name + ','
				
			FETCH NEXT FROM cur INTO @Name
				 
		END -- WHILE 

	Close cur
	Deallocate cur
	
	DROP Table #Columns

	IF Len(@Result) > 0
		SET @Result=substring(@Result,1,Len(@Result)-1)

	SELECT @Result Columns
END
GO
