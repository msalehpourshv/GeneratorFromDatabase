USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Javad Bayani
-- Create date: 2008/01/12
-- Description:	Create Insert Into Script
-- =============================================
CREATE PROCEDURE [utl].[sp_Copy2DBTables] 
(	
	-- Add the parameters for the function here
	@SrcDB VarChar(50), 
	@DestDB VarChar(50)
)
WITH ENCRYPTION
AS
EXECUTE( '
		CREATE TABLE #tmpTableColumns
				(
					ParentSchema Varchar(20) ,
					ParentTable Varchar(100) ,
					PColumns VarChar(1000)	,
					ColCount Int
				)
		;INSERT INTO #tmpTableColumns
				(
					ParentSchema  ,
					ParentTable ,
					PColumns	,
					ColCount
				)
		Select S.name ,T.name ,'''',0 From ' + @SrcDB + '.sys.tables T 
		INNER JOIN ' + @SrcDB + '.sys.schemas S ON T.schema_id = S.schema_id AND S.schema_id > 4 
		Order By S.name,T.name ;
		Declare @strSchemaName VarChar(200);
		Declare @strTableName VarChar(200);
		Declare @strColumnName VarChar(1000);
		Declare @I Int;

		DECLARE curTables CURSOR FOR 
		Select S.name,T.name From ' + @SrcDB + '.sys.tables T 
		INNER JOIN ' + @SrcDB + '.sys.schemas S ON T.schema_id = S.schema_id AND S.schema_id > 4
		Order By S.name,T.name ;

		OPEN curTables;

		FETCH NEXT FROM curTables INTO @strSchemaName ,@strTableName ;
		WHILE @@FETCH_STATUS = 0 
			BEGIN
				SET @strColumnName = '''';

				Select @strColumnName = @strColumnName + C.name + '','' From ' + @SrcDB + '.sys.tables T 
				INNER JOIN ' + @SrcDB + '.sys.columns C ON C.object_id = T.object_id 
				INNER JOIN ' + @SrcDB + '.sys.schemas S ON T.schema_id = S.schema_id
				Where	S.schema_id > 4 AND S.name = @strSchemaName AND T.name = @strTableName;

				UPDATE #tmpTableColumns SET PColumns = SubString(@strColumnName,1,LEN(@strColumnName)-1)
				Where	ParentSchema = @strSchemaName AND ParentTable = @strTableName; 

				FETCH NEXT FROM curTables INTO @strSchemaName ,@strTableName;
			END

		Close curTables;
		Deallocate curTables;

		DECLARE curTables CURSOR FOR 
		Select ParentSchema ,ParentTable From #tmpTableColumns;
		OPEN curTables;
		FETCH NEXT FROM curTables INTO @strSchemaName , @strTableName;
		WHILE @@FETCH_STATUS = 0 
			BEGIN
				SET @I = 0;

				EXECUTE(''Update #tmpTableColumns SET ColCount = (Select Count(*) From ' + @SrcDB + '.'' + @strSchemaName + ''.'' + 
				@strTableName + '') Where ParentSchema = '''''' + @strSchemaName + '''''' AND ParentTable = '''''' + 
				@strTableName + '''''' '')

				FETCH NEXT FROM curTables INTO @strSchemaName ,@strTableName;
			END
		Close curTables;
		Deallocate curTables;

		Delete From #tmpTableColumns Where ColCount = 0;

		Select ''INSERT INTO ' + @DestDB + '.'' + ParentSchema + ''.'' + ParentTable + ''('' + PColumns + 
		 '') Select '' + PColumns + '' From ' + @SrcDB + '.'' + ParentSchema + ''.'' + ParentTable AS strQuery From #tmpTableColumns
	')







GO
