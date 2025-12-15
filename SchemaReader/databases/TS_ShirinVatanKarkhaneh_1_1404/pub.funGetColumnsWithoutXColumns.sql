USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1393/08/19
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : بازگرداندن نام فیلد های یک جدول بجز تعداد خاص نامبرده شده
-- ===============================================

CREATE PROCEDURE [pub].[funGetColumnsWithoutXColumns]

	@SchemaName AS Char(3),
	@tableName Varchar(100),
	@ColumnsName Varchar(100),
	@CompressTableName Varchar(5),
	@Result Varchar(4000) output

WITH ENCRYPTION
AS
BEGIN
	Declare @sql Nvarchar(4000) 
	
	DECLARE @Name VarChar(100)

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
			name NOT IN (''' + @ColumnsName + ''')'

	Exec sp_executesql @sql


	SET @Result = ''

	Declare cur Cursor  For 
	Select name 
	From #Columns 

	Open cur
	FETCH NEXT FROM cur INTO	@Name

	WHILE @@FETCH_STATUS = 0
		BEGIN
		if @CompressTableName<> '' 
			SET @Result = @Result + @CompressTableName + '.' + @Name + ','
			else
			SET @Result = @Result +  @Name + ','
				
			FETCH NEXT FROM cur INTO @Name
				 
		END -- WHILE 

	Close cur
	Deallocate cur
	
	DROP Table #Columns

	IF Len(@Result) > 0
		SET @Result=substring(@Result,1,Len(@Result)-1)

	--SELECT @Result
END
GO
