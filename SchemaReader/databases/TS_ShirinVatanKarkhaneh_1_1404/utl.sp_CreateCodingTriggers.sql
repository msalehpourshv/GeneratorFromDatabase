USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [utl].[sp_CreateCodingTriggers]
(
		@strTableName	Nvarchar(100) ,
		@strFieldName	Nvarchar(100) ,
		@strTriggerName Nvarchar(100)
)
WITH ENCRYPTION
AS
BEGIN
	Declare	@strTest	Nvarchar(4000);

	Set @strTest = N'/****** Object:  Trigger ' + @strTableName + '    Script Date: 03/12/2008 13:08:49 ******/
	
	-- =============================================
	-- Author:			Javad Bayani
	-- Create Date:		2008/01/26
	-- Modified Date:	
	-- Description:		Update All Related Tables Fields(Read From inserted & deleted Tables)
	-- =============================================
	CREATE TRIGGER ' + @strTriggerName + '
	   ON  ' + @strTableName + '
	   WITH ENCRYPTION
	   AFTER UPDATE
	AS 
	BEGIN
		SET NOCOUNT ON;

		Declare @OldValue Varchar(30)		, @NewValue Varchar(30) 
		Declare @strExecute VarChar(500)	, @StartFrom Tinyint 
		Declare @RelatedTable VarChar(50)	, @RelatedField VarChar(50)
		Declare @TableName Varchar(50)		, @FieldName Varchar(50) 

		Declare curIns' + @strTriggerName + ' CURSOR FOR
		Select	' + @strFieldName + '
		From	inserted

		Declare curDel' + @strTriggerName + ' CURSOR FOR
		Select	' + @strFieldName + '
		From	deleted

		OPEN curIns' + @strTriggerName + '
		OPEN curDel' + @strTriggerName + '

		FETCH NEXT FROM curIns' + @strTriggerName + ' INTO @NewValue
		WHILE @@FETCH_STATUS = 0
			BEGIN 
				FETCH NEXT FROM curDel' + @strTriggerName + ' INTO @OldValue

				SET	@TableName = ''' + @strTableName + ''';
				SET	@FieldName = ''' + @strFieldName + ''';

				SET @StartFrom = 1; 

				Declare	curRelTables CURSOR FOR
				Select	RelatedTableNameWithSchema ,RelatedFieldName 
				From	pub.tblTablesRelations
				Where	SourceTableNameWithSchema = @TableName AND SourceFieldName = @FieldName
				Order By RelatedTableNameWithSchema ,RelatedFieldName

				OPEN curRelTables

				FETCH NEXT FROM curRelTables INTO @RelatedTable ,@RelatedField 
				WHILE @@FETCH_STATUS = 0
					BEGIN 

						SET @strExecute =	''Update '' + @RelatedTable + '' SET '' + @RelatedField + 
									'' = ISNULL(Stuff('' + @RelatedField + '' ,'' + 
									CAST(@StartFrom AS VarChar(10)) + '' ,'' + 
									CAST(LEN(@NewValue) AS VarChar(10)) + '','''''' + 
									@NewValue + ''''''),'' + @RelatedField + '') '' + 
									''Where SubString('' + @RelatedField + '','' + 
									CAST(@StartFrom AS VarChar(10)) + '','' + 
									CAST(LEN(@NewValue) AS VarChar(10)) + '') = '''''' + 
									@OldValue + ''''''''
						EXECUTE(@strExecute)

						FETCH NEXT FROM curRelTables INTO @RelatedTable ,@RelatedField 
					END

				CLOSE curRelTables
				DEALLOCATE curRelTables

				FETCH NEXT FROM curDel' + @strTriggerName + ' INTO @OldValue
				FETCH NEXT FROM curIns' + @strTriggerName + ' INTO @NewValue
			END

		CLOSE curDel' + @strTriggerName + '
		DEALLOCATE curDel' + @strTriggerName + '

		CLOSE curIns' + @strTriggerName + '
		DEALLOCATE curIns' + @strTriggerName + '

	END
	'
	Print  @strTest 

END



GO
