USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [pub].[funGetCodeIfOne]

	@tableName				Varchar(100),
	@tableNameRng			Varchar(100),
	@ColumnName				Varchar(100),
	@UserID					Varchar(10),
	@bolAccessAllCodes		Varchar(10),
	@bolAccessForView		Varchar(10),
	@strFilter				NVarChar(2000)='',
	@strFilterFieldValue1	NVarChar(100)='',
	@strFilterFieldName1	NVarChar(100)='',
	@strFilterFieldValue2	NVarChar(100)='',
	@strFilterFieldName2	NVarChar(100)='',
	@strFilterFieldValue3	NVarChar(100)='',
	@strFilterFieldName3	NVarChar(100)=''
WITH ENCRYPTION
AS
BEGIN
	
	Declare @sqlWhere Nvarchar(4000) 
	Declare @sql Nvarchar(4000) 
	Declare @ParmDefinition NVarChar(200)
	
	DECLARE @Result bit
	DECLARE @CodeResault Varchar(20)

	SET @Result = 'True'
	SET @CodeResault = ''
	SET @sql = ''
	SET @sqlWhere = ''


	IF @bolAccessAllCodes=0 AND @bolAccessForView = 0
        SET  @sqlWhere =' ((SELECT COUNT(*) 
                   FROM ' + @tableNameRng + ' R 
                   WHERE R.UserID = ' + @UserID + ' AND 
                   R.AllowCodeView=1 AND 
                   LEFT(' +  @ColumnName + ',LEN(FromCode)) >= FromCode AND 
                   LEFT(' +  @ColumnName + ', LEN(ToCode)) <= ToCode) > 0) AND '

	IF @strFilter<>''
	BEGIN
		SET	@sqlWhere=@sqlWhere + @strFilter + ' AND '
	END

	IF @strFilterFieldValue1<>''
	BEGIN
		SET	@sqlWhere=@sqlWhere + @strFilterFieldName1 + ' IN (' + @strFilterFieldValue1 + ') AND '
	END

	IF @strFilterFieldValue2<>''
	BEGIN
		SET	@sqlWhere=@sqlWhere + @strFilterFieldName2 + ' IN (' + @strFilterFieldValue2 + ') AND '
	END

	IF @strFilterFieldValue3<>''
	BEGIN
		SET	@sqlWhere=@sqlWhere + @strFilterFieldName3 + ' IN (' + @strFilterFieldValue3 + ') AND '
	END

	SET @sql = 'Select top 1 @ResaultOUT=''False''
				FROM ' + @tableName + ' H 
				WHERE ' + @sqlWhere + @ColumnName + '<>''''
				Group by Len(' + @ColumnName + ')
				having Count(' + @ColumnName + ') > 1'

	SET @ParmDefinition = N'@ResaultOUT Bit OUTPUT';

	Exec sp_executesql @sql,@ParmDefinition, @ResaultOUT = @Result OUTPUT;

	IF  @Result = 'True'
		BEGIN
			SET @sql = 'select top 1 @CodeOUT=' + @ColumnName + ' 
						FROM ' + @tableName + ' 
						WHERE ' + @sqlWhere + 'Len(' + @ColumnName + ') = ( select MAX(LEN(' + @ColumnName + ')) FROM ' + @tableName + ') '
							 		
		
			SET @ParmDefinition = N'@CodeOUT Varchar(20) OUTPUT';

			Exec sp_executesql @sql,@ParmDefinition, @CodeOUT = @CodeResault OUTPUT;

		END

	SELECT @CodeResault

END
GO
