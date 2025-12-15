USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		 Sadeghi, Hadi
-- Create date: 
-- Description:
-- ==============================================
--[pub].[spFillCodeNameEntryName] '110101' ,'AcntCode','AcntName','acc.tblAcnt1','acc.tblAcnt1Dtl',1,1,0,1,6,1
Create PROCEDURE [pub].[spCtrlCodeNameEntryName] 
(@StrCodeOrName        NVarChar(500),
 @strFieldCode		   VARCHAR(100),
 @strFieldName		   NVarChar(100),
 @strSearchableCodeField  NVarChar(100),
 @strSearchableNameField   NVarChar(100),
 @StrTableName         NVarChar(100),
 @StrDtlTableName      NVarChar(100),
 @ExtraField	       NVarChar(4000),
 @bytEndlLayerLen      Tinyint,
 @UserID               Int,
 @bolAccessAllCodes    Bit,
 @bolAccessForView     Bit,
 @bolIsCode            Bit,
 @LanguageID           Tinyint,
 @PartNumber		   Tinyint,
 @strFilter			   NVarChar(4000)='',
 @SortField	       NVarChar(4000)='' )
WITH ENCRYPTION
As 

DECLARE @SQLString NVarChar(4000);
DECLARE @ParmDefinition NVarChar(500);
DECLARE @AcntName   NVarChar(100);
DECLARE @tmpSerchFieldName   NVarChar(100);


SET @bytEndlLayerLen = 0 
SET @tmpSerchFieldName = '' 
SET @AcntName = NULL

IF @strFieldCode<>@strSearchableCodeField
	SET @tmpSerchFieldName = ',H.' + @strFieldCode

IF @StrDtlTableName<>''

BEGIN

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	SET @SQLString=
		 N'SELECT ' + @ExtraField + @strSearchableNameField + ',H.' + @strSearchableCodeField + @tmpSerchFieldName + '
		   FROM ' + @StrTableName + ' H,' + @StrTableName + 'Dtl AD 
		   WHERE H.' + @strFieldCode +'=AD.' + @strFieldCode +' AND 
				 LanguageID=' + LTRIM(STR(@LanguageID)) + ' AND H.' + @strFieldCode+ '<>'''''

	IF @PartNumber>0
	BEGIN
		SET	@SQLString= @SQLString + ' AND H.PartNumber=AD.PartNumber AND H.PartNumber=' + Ltrim(Str(@PartNumber))
	END
 
END
ELSE
BEGIN
	SET @SQLString=
		 N'SELECT ' + @strSearchableNameField + ',H.' + @strSearchableCodeField + '
		   FROM ' + @StrTableName + ' H
		   WHERE H.' + @strFieldCode+ '<>'''''
END

if @bytEndlLayerLen > 0 
    SET @SQLString = @SQLString + N' AND LEN(H.' + @strFieldCode + ') = ' + LTRIM(STR(@bytEndlLayerLen)) + ''

IF @strFilter<>''
BEGIN
	SET	@SQLString = @SQLString + N' AND ' + @strFilter
END

IF @bolIsCode = 1 
    SET @SQLString = @SQLString + N' AND H.' + @strFieldCode + ' LIKE ''' + @StrCodeOrName + '%'''
Else
    SET @SQLString = @SQLString + N' AND UPPER(' + @strSearchableNameField + ') LIKE UPPER(N''%' + @StrCodeOrName + '%'')' 

IF @bolAccessAllCodes=0 AND @bolAccessForView = 0
BEGIN
	SET @SQLString= @SQLString + 
		  N' AND ((SELECT COUNT(*) 
                   FROM ' + @StrTableName + 'Rng R
                   WHERE R.UserID =' + LTRIM(STR(@UserID)) + ' AND 
                         R.AllowCodeView=1 AND '
	IF @PartNumber>0
	BEGIN
		SET	@SQLString= @SQLString + N'  R.PartNumber=' + Ltrim(Str(@PartNumber)) + ' AND '
	END

	SET @SQLString=@SQLString + 
         N'LEFT(H.' + @strFieldCode + ',LEN(FromCode)) >= FromCode AND
           LEFT(H.' + @strFieldCode + ',LEN(ToCode)) <= ToCode) > 0) '

END

if (@SortField='' )
SET @SQLString = @SQLString + ' ORDER BY ' + @strSearchableNameField
else
SET @SQLString = @SQLString + ' ORDER BY ' + @SortField

print @SQLString
EXECUTE sp_executesql @SQLString, @ParmDefinition

GO
