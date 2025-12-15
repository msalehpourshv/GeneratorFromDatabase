USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Javad Bayani
-- Create date: 2009/01/26
-- Description:	This Procedure search for Columns in Specified Schema And Table
--				Then Concatenate them and Return them
--		Use In this Way
--		Declare @C nVarchar(2000)
--		Exec[pub].[SpConcatSimilarCols] 'prs','tblDecr','Benef',',',@C OUTPUT
--		Select @C
-- =============================================

CREATE PROCEDURE [pub].[SpConcatSimilarCols]
(
	-- Add the parameters for the function here
	@SchemaName VarChar(100),
	@TableName VarChar(100),
	@ColumnName VarChar(100),
	@Delimiter VarChar(1),
	@strResult nVarchar(4000) OUTPUT
)
WITH ENCRYPTION
AS
BEGIN
	Declare @strSelect NVarChar(4000)

	SET @strSelect = N'
						IF (Select Count(name) From tempdb.sys.tables Where name = ''##tblColumnes'') > 0
							Begin
								DROP TABLE ##tblColumnes;
							End

						IF (Select Count(name) From tempdb.sys.tables Where name = ''##tblColumnes'') = 0
							Begin
								CREATE TABLE ##tblColumnes (C VarChar(30));
							End

						TRUNCATE TABLE ##tblColumnes

						SET NOCOUNT ON;
						INSERT INTO ##tblColumnes
						Select C.name
						From sys.schemas S INNER JOIN sys.tables T ON S.Schema_ID = T.Schema_ID 
						INNER JOIN sys.columns C ON C.Object_ID = T.Object_ID 
						Where	S.name Like ''%' + @SchemaName + '%'' AND T.name Like ''%' + @TableName + '%'' AND
								C.name Like ''%' + @ColumnName + '%''
						Order by S.name ,T.name ,C.name;
						SET NOCOUNT OFF;
					  '

	Exec sp_executesql @strSelect

	SET @strResult = N'';

	Declare curFld CURSOR FOR Select C From ##tblColumnes
	OPEN curFld

	FETCH NEXT FROM curFld INTO @ColumnName

	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @strResult = @strResult + @ColumnName

			FETCH NEXT FROM curFld INTO @ColumnName

			IF @@FETCH_STATUS = 0 SET @strResult = @strResult + @Delimiter
		END

	CLOSE curFld
	DEALLOCATE curFld

	SET @strSelect = N'IF OBJECT_ID(N''dbo.##tblColumnes'') IS NOT NULL DROP TABLE dbo.##tblColumnes';
	Exec sp_executesql @strSelect

	RETURN 0

END
GO
