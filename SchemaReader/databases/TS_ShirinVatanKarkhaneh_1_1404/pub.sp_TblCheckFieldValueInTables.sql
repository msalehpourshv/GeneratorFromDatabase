USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		Bayani, Javad
-- Create date: 
-- Description:
-- ==============================================

CREATE PROCEDURE [pub].[sp_TblCheckFieldValueInTables] 
	-- Add the parameters for the stored procedure here
	@TableName NVarChar(100), 
	@FieldName NVarChar(100), 
	@Value NVarChar(4000)
WITH ENCRYPTION
AS

BEGIN

	SET NOCOUNT ON;

	Declare @TblName NVarChar(100) -- Used in Cursor
	Declare @TblList NVarChar(4000) -- Used in Cursor
	Declare @SQL NVarChar(4000) -- Used in Cursor
	Declare @Parameters NVarChar(4000) -- Used in Cursor
	Declare @fldCnt Int -- Used in Cursor

	-- Save List Of Tables That Field is beeing Used in them
	Set @TblList = ''

	Declare curTables Cursor FORWARD_ONLY READ_ONLY For
	Select Schemas.name + '.' + AllObjs.name AS FullName From sys.all_columns AllCols 
			Inner Join sys.all_objects AllObjs ON AllCols.object_id = AllObjs.object_id 
			Inner Join sys.schemas Schemas ON AllObjs.schema_id = Schemas.schema_id
	Where   AllCols.name = @FieldName AND AllObjs.type = 'U' AND Schemas.name + '.' + AllObjs.name <> @TableName 
			AND Schemas.name + '.' + AllObjs.name <> @TableName + 'Dtl'

	Open curTables

	Fetch Next From curTables Into @TblName

	While @@Fetch_Status = 0
		Begin

			Set @SQL = N'Select @Cnt = Count(' + @FieldName + N') From ' + @TblName + N' Where ' + 
						@FieldName + N' = ''' + @Value + N''''

			Set @Parameters = N'@Cnt Int OUTPUT'
			Exec sp_executesql @SQL ,@Parameters,@Cnt = @fldCnt OUTPUT;
			
			If @fldCnt > 0 
				Begin
					If Len(@TblList) > 0 Set @TblList = @TblList + ','
					Set @TblList = @TblList + @TblName
				End
			Fetch Next From curTables Into @TblName
		End

	Close curTables

	Deallocate curTables

	If @FieldName = N'LocationID'
		Begin
			if (Select Count(*) From Users.tblUsers Where BirthPlace = @Value OR IssuancePlace = @Value) > 0 
				Set @TblList = @TblList + N',Users.tblUsers'
		End

	-- Fill the table variable with the rows for your result set
	Select Case When Len(@TblList) > 0 Then @TblList Else 'Empty' End AS TableList 

END























GO
