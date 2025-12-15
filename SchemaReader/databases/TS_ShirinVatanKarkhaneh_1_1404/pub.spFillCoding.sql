USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		 Sadeghi, Hadi
-- Create date: 
-- Description:
-- ==============================================
--[pub].[spFillCoding] 'AcntCode','TS_0_0_1386.acc.tblAcnt1','lkj','*','','','','',''
CREATE PROCEDURE [pub].[spFillCoding] 
(@strFieldCode			NVarChar(50),
 @StrTableName			NVarChar(100),
 @StrDtlTableName		NVarChar(100),
 @strSelectGridField	NVarChar(500),
 @strFilter				NVarChar(500),
 @strFilterFieldValue	NVarChar(100)='',
 @strFilterFieldName	NVarChar(100)='',
 @strParentCode			NVarChar(80),
 @strCodeValue			NVarChar(20),
 @strSearchField		NVarChar(20),
 @UserID				Int,
 @bolAccessAllCodes		Bit,
 @flgFilterMode			Bit,
 @BolEndLayrMustComplete Bit,
 @IsSearchFieldReverse	Bit,
 @AcntNumber			Tinyint,
 @FirstLayerLen			Tinyint,
 @CurrentLayerSum		Tinyint,
 @BeforeLayerSum		Tinyint,
 @bytCurrentLayer		Tinyint,
 @bytEndLayer			Tinyint,
 @LanguageID			Tinyint)
WITH ENCRYPTION
As 

DECLARE @SQLString NVarChar(4000);
DECLARE @ParmDefinition NVarChar(500);
DECLARE @AcntName NVarChar(50);
DECLARE @CodeClosed bit;
DECLARE @Acnt2Force Tinyint;
DECLARE @Acnt3Force Tinyint;
DECLARE @Acnt4Force Tinyint;

--	SET @LanguageID = pub.funGetCurrentLanguageID();

If @StrDtlTableName<>''
	SET  @SQLString =
     N'SELECT  * 
      FROM ' + @StrTableName + 'Dtl 
      WHERE LanguageID=' + LTRIM(STR(@LanguageID))

IF @flgFilterMode=1
BEGIN
	IF @StrDtlTableName=''
		SET @SQLString = 
			N'SELECT ' + @strSelectGridField + ' 
              FROM ' + @StrTableName + ' H WHERE '
    Else
		SET @SQLString = 
			N'SELECT ' + @strSelectGridField + '
              FROM ' + @StrTableName + ' H 
              INNER JOIN (' + @SQLString + ') AS D 
              ON  D.' + @strFieldCode + '=H.' + @strFieldCode + '
              WHERE '

	SET @SQLString = @SQLString + @strFilter

	IF @strFilterFieldValue<>''
		SET @SQLString = @SQLString + N' AND ' + @strFilterFieldName + ' IN (' + @strFilterFieldValue + ')'

	IF @bolAccessAllCodes =0
		SET @SQLString = @SQLString + 
			N'AND ((SELECT COUNT(*) 
              FROM ' + @StrTableName + 'Rng R
              WHERE R.UserID =' + ltrim(str(@UserID)) + ' AND 
                    R.AllowCodeView=1 AND 
                    LEFT(H.' + @strFieldCode + ',LEN(FromCode)) >= FromCode AND
                    LEFT(H.' + @strFieldCode + ', LEN(ToCode)) <= ToCode) > 0)'

	IF @strParentCode<>''
		SET @SQLString = @SQLString + 
            N' AND ((SELECT COUNT(*) 
              FROM ' + pub.funYearsDBName() + '.acc.tblAcntRelation 
              WHERE (LEFT(H.AcntCode, ' + LTRIM(STR(@CurrentLayerSum)) + ') IN
                    (SELECT AcntXCode
                     FROM ' + pub.funYearsDBName() + '.acc.tblAcntRelation
                     WHERE acc.tblAcntRelation.Acnt1Code = LEFT(''' + @strParentCode + ''' , len(tblAcntRelation.Acnt1Code)) AND
                       "(tblAcntRelation.AcntNumber = ''' + LTRIM(STR(@AcntNumber)) + ''')))) > 0)'

END
ELSE IF @bytCurrentLayer=1
BEGIN
	IF @StrDtlTableName=''
		SET @SQLString =
			N'SELECT ' + @strSelectGridField + '
              FROM ' + @StrTableName + ' H '

	Else
		SET @SQLString =
			N'SELECT ' + @strSelectGridField + '
              FROM ' + @StrTableName + ' H
              INNER JOIN (' + @SQLString + ') AS D
              ON  D.' + @strFieldCode + '=H.' + @strFieldCode 

 	IF @BolEndLayrMustComplete=0 AND @bytCurrentLayer=@bytEndLayer
		SET @SQLString = @SQLString  +
			N' WHERE LEN(H.' + @strFieldCode + ') <=' + LTRIM(STR(@FirstLayerLen)) + ' AND
                    LEN(H.' + @strFieldCode + ') >=1 '
    ELSE
		SET @SQLString = @SQLString  +
			N' WHERE LEN(H.' + @strFieldCode + ') =''' + LTRIM(STR(@FirstLayerLen)) + ''''


	IF @strFilterFieldValue<>''
		SET @SQLString = @SQLString + N' AND ' + @strFilterFieldName + ' IN (' + @strFilterFieldValue + ')'

	IF @bolAccessAllCodes =0
		SET @SQLString = @SQLString + 
			N'AND ((SELECT COUNT(*) 
              FROM ' + @StrTableName + 'Rng R
              WHERE R.UserID =' + ltrim(str(@UserID)) + ' AND 
                    R.AllowCodeView=1 AND 
                    LEFT(H.' + @strFieldCode + ',' + LTRIM(STR(@FirstLayerLen)) + ') <= LEFT(R.ToCode, ' + LTRIM(STR(@FirstLayerLen)) + ' ) AND 
                    LEFT(H.' + @strFieldCode + ', ' + LTRIM(STR(@FirstLayerLen)) + ') >= LEFT(R.FromCode,' + LTRIM(STR(@FirstLayerLen)) + ')) > 0)'
 
	IF @strParentCode<>''
		SET @SQLString = @SQLString + 
            N' AND ((SELECT COUNT(*) 
              FROM ' + pub.funYearsDBName() + '.acc.tblAcntRelation 
              WHERE (LEFT(H.AcntCode, ' + LTRIM(STR(@CurrentLayerSum)) + ') IN
                    (SELECT AcntXCode
                     FROM ' + pub.funYearsDBName() + '.acc.tblAcntRelation
                     WHERE acc.tblAcntRelation.Acnt1Code = LEFT(''' + @strParentCode + ''' , len(tblAcntRelation.Acnt1Code)) AND
                       "(tblAcntRelation.AcntNumber = ''' + LTRIM(STR(@AcntNumber)) + ''')))) > 0)'

END
ELSE IF @bytCurrentLayer>1
BEGIN
	IF @StrDtlTableName=''
		SET @SQLString =
			N'SELECT ' + @strSelectGridField + '
              FROM ' + @StrTableName + ' H 
              WHERE LEFT(H.' +  @strFieldCode + ',' + @BeforeLayerSum + ')=Left(' + @strCodeValue + ',' + @BeforeLayerSum +') AND '

	Else
		SET @SQLString =
			N'SELECT ' + @strSelectGridField + '
              FROM ' + @StrTableName + ' H
              INNER JOIN (' + @SQLString + ') AS D
              ON  D.' + @strFieldCode + '=H.' + @strFieldCode + '
              WHERE LEFT(H.' + @strFieldCode + ',' + @BeforeLayerSum + ')=Left(' + @strCodeValue + ',' + @BeforeLayerSum +') AND '

	IF @BolEndLayrMustComplete=0 AND @bytCurrentLayer=@bytEndLayer
		SET @SQLString = @SQLString  +
			N' WHERE LEN(H.' + @strFieldCode + ') <=' + @CurrentLayerSum + ' AND
                    LEN(H.' + @strFieldCode + ') >=' + @BeforeLayerSum
    ELSE
		SET @SQLString = @SQLString  +
			N' WHERE LEN(H.' + @strFieldCode + ') =' + @CurrentLayerSum 

	IF @strFilterFieldValue<>''
		SET @SQLString = @SQLString + N' AND ' + @strFilterFieldName + ' IN (' + @strFilterFieldValue + ')'

	IF @bolAccessAllCodes =0
		SET @SQLString = @SQLString + 
			N' AND ((SELECT COUNT(*) 
              FROM ' + @StrTableName + 'Rng R
              WHERE R.UserID =' + ltrim(str(@UserID)) + ' AND 
                    R.AllowCodeView=1 AND 
                    LEFT(H.' + @strFieldCode + ',' + LTRIM(STR(@CurrentLayerSum)) + ') >= LEFT(R.FromCode, ' + LTRIM(STR(@CurrentLayerSum)) + ' ) AND 
                    LEFT(H.' + @strFieldCode + ', LEN(R.ToCode)) <= R.ToCode) > 0)'

	IF @strParentCode<>''
		SET @SQLString = @SQLString + 
            N' AND ((SELECT COUNT(*) 
              FROM ' + pub.funYearsDBName() + '.acc.tblAcntRelation 
			  WHERE (Acnt1Code = LEFT(''' +  @strParentCode + ''',LEN(Acnt1Code))) AND 
                    (AcntNumber = ' + LTRIM(STR(@AcntNumber)) + ')) > 0)'

END

IF @IsSearchFieldReverse=1
	SET @SQLString = @SQLString +  'ORDER BY ' + SUBSTRING(@strSearchField, 4, LEN(@strSearchField)-4)
ELSE
BEGIN
	IF	@strSearchField=@strFieldCode
		SET @SQLString = @SQLString +  'ORDER BY ' + @strSearchField
	ELSE
		SET @SQLString = @SQLString +  'ORDER BY H.' + @strSearchField
END

print @SQLString

EXECUTE sp_executesql @SQLString

--END



























GO
