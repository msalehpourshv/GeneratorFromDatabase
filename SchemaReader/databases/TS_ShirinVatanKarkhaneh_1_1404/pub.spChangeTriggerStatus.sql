USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [pub].[spChangeTriggerStatus] 
(
	@strTableNameWithSchema Nvarchar(100)	,
	@bolStatus				Bit				,
	@strTriggerName			Nvarchar(100) = NULL	
)
WITH ENCRYPTION
AS

BEGIN

	Declare @intTrgCnt Smallint
	Declare @strQuery Nvarchar(1000)
	Declare @strCommand Nvarchar(10)
--
--	Set @bolStatus = 1
--	Set @strTableNameWithSchema = 'prd.tblFormulasDtl'
--	Set @strTriggerName = NULL--'trgFormulasDtlDelete'

	BEGIN TRY
		IF @bolStatus = 0
			Set @strCommand = 'Disable '
		ELSE
			Set @strCommand = 'Enable '

		IF  @strTriggerName IS NULL
			Select @intTrgCnt = Count(TR.name)
			From sys.triggers TR 
			Inner Join sys.tables T ON T.object_id = TR.parent_id
			Inner Join sys.schemas S ON T.schema_id = S.schema_id
			Where S.name + '.' + T.name = @strTableNameWithSchema AND TR.is_disabled = @bolStatus
		ELSE 
			Set @intTrgCnt = 1

		While @intTrgCnt > 0
			Begin
				IF  @strTriggerName IS NULL
					Select @strQuery = @strCommand + 'Trigger '+ S.name +'.' + TR.name + ' ON ' + S.name + '.' + T.name 
					From sys.triggers TR 
					Inner Join sys.tables T ON T.object_id = TR.parent_id
					Inner Join sys.schemas S ON T.schema_id = S.schema_id
					Where S.name + '.' + T.name = @strTableNameWithSchema AND TR.is_disabled = @bolStatus
				ELSE
					Select @strQuery = @strCommand + 'Trigger '+ S.name +'.' + TR.name + ' ON ' + S.name + '.' + T.name 
					From sys.triggers TR 
					Inner Join sys.tables T ON T.object_id = TR.parent_id
					Inner Join sys.schemas S ON T.schema_id = S.schema_id
					Where	S.name + '.' + T.name = @strTableNameWithSchema AND TR.is_disabled = @bolStatus
							AND TR.name = @strTriggerName

				Execute(@strQuery)

				Set @intTrgCnt = @intTrgCnt - 1
			End

		RETURN 1
	END TRY

	BEGIN CATCH
		RETURN 0
	END CATCH

END
GO
