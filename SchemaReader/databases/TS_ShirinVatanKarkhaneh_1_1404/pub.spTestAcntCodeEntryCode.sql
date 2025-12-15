USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		 Sadeghi, Hadi
-- Create date: 
-- Description:
-- ==============================================

CREATE PROCEDURE [pub].[spTestAcntCodeEntryCode] 
(@StrCode              VarChar(20),
 @StrTableName         NVarChar(50),
 @StrFieldName         NVarChar(50),
 @StrFieldName2         NVarChar(50),
 @UserID               Int,
 @IsForce              Bit,
 @bolClosedCodeIsValid Bit,
 @bolUserIsAdmin       Bit,
 @bolAccessAllCodes    Bit,
 @bolAccessForView     Bit,
 @Acnt1CurrentLayerSum Tinyint,
 @LanguageID           Tinyint,
 @PartNumber		   Tinyint,
 @strFilter				NVarChar(2000)='',
 @strFilterFieldValue1  NVarChar(100)='',
 @strFilterFieldName1   NVarChar(100)='',
 @strFilterFieldValue2  NVarChar(100)='',
 @strFilterFieldName2   NVarChar(100)='',
 @strFilterFieldValue3  NVarChar(100)='',
 @strFilterFieldName3   NVarChar(100)='',
 @StationID				nvarchar(10)='')
--@ReturnValue
--1 موجود نیست
--2 مسدود است
--3 در حیطه کاربر نیست
WITH ENCRYPTION
As 

DECLARE @SQLString NVarChar(4000);
DECLARE @ParmDefinition NVarChar(500);
DECLARE @StrForce NVarChar(100);
DECLARE @AcntName NVarChar(200);
DECLARE @CodeClosed bit;
DECLARE @Acnt2Force Tinyint;
DECLARE @Acnt3Force Tinyint;
DECLARE @Acnt4Force Tinyint;

IF @StrFieldName = ''
	set @StrFieldName = 'AcntCode'
	
IF @StrTableName='acc.tblAcnt' AND @IsForce=1
BEGIN

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	SET @StrForce = N',@_Acnt2Force=Acnt2Force ,@_Acnt3Force=Acnt3Force,@_Acnt4Force=Acnt4Force'
    SET @ParmDefinition = N'@_AcntName NVarChar(200) OUTPUT,@_CodeClosed bit OUTPUT,@_Acnt2Force Tinyint OUTPUT,
                            @_Acnt3Force Tinyint OUTPUT,@_Acnt4Force Tinyint OUTPUT'
END
ELSE
BEGIN
	SET @StrForce = N''
    SET @ParmDefinition = N'@_AcntName NVarChar(200) OUTPUT,@_CodeClosed bit OUTPUT'
END

SET @AcntName = Null

SET @SQLString=
     N'SELECT @_AcntName=' + @StrFieldName2 + ',@_CodeClosed=CodeClosed' + @StrForce + ' 
       FROM ' + @StrTableName + ' A,' + @StrTableName + 'Dtl AD 
       WHERE A.' + @StrFieldName + '=AD.' + @StrFieldName + ' AND 
			 A.PartNumber=AD.PartNumber AND
             LanguageID=' + LTRIM(STR(@LanguageID)) + ' AND 
             A.' + @StrFieldName + '=''' + @StrCode + ''' AND 
             A.PartNumber=' + LTRIM(STR(@PartNumber))

IF @strFilter<>''
BEGIN
	SET	@SQLString=@SQLString + N' AND ' + @strFilter
END

IF @strFilterFieldValue1<>''
BEGIN
	SET	@SQLString=@SQLString + N' AND ' + @strFilterFieldName1 + ' IN (' + @strFilterFieldValue1 + ')'
END

IF @strFilterFieldValue2<>''
BEGIN
	SET	@SQLString=@SQLString + N' AND ' + @strFilterFieldName2 + ' IN (' + @strFilterFieldValue2 + ')'
END

IF @strFilterFieldValue3<>''
BEGIN
	SET	@SQLString=@SQLString + N' AND ' + @strFilterFieldName3 + ' IN (' + @strFilterFieldValue3 + ')'
END

IF @StrTableName='acc.tblAcnt' AND @IsForce=1
BEGIN
	EXECUTE sp_executesql @SQLString, @ParmDefinition, @_AcntName=@AcntName OUTPUT, @_CodeClosed=@CodeClosed OUTPUT,
                @_Acnt2Force=@Acnt2Force OUTPUT,@_Acnt3Force=@Acnt3Force OUTPUT,@_Acnt4Force=@Acnt4Force OUTPUT;
END
ELSE
BEGIN
	EXECUTE sp_executesql @SQLString, @ParmDefinition, @_AcntName=@AcntName OUTPUT, @_CodeClosed=@CodeClosed OUTPUT;
END

IF @AcntName IS Null
	RETURN 1 -- موجود نیست

IF @bolClosedCodeIsValid=0 AND @CodeClosed=1
	RETURN 2 -- مسدود است


DECLARE @Counter Int

IF @StrTableName='acc.tblAcnt' AND @bolUserIsAdmin=0 AND @bolAccessAllCodes=0
BEGIN
	SET @SQLString=
		  N'SELECT @_Counter=COUNT(UserID) 
			FROM ' + @StrTableName + 'Rng R
			WHERE (AllowCodeView = 0) AND 
				  (R.PartNumber=' + LTRIM(STR(@PartNumber)) + ') AND 	
			      (((UserID =-1) AND 
				  (( LEN(''' + @StrCode + ''')>=LEN(ToCode) AND LEFT(''' + @StrCode + ''',LEN(ToCode)) <= ToCode AND 
				  LEFT(''' + @StrCode + ''',LEN(ToCode)) >= FromCode) OR 
				  ( LEN(''' + @StrCode + ''')>=LEN(ToCode) AND (LEFT(''' + @StrCode + ''',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') <= 
				  LEFT(ToCode, ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')) AND 
				  LEFT(''' + @StrCode + ''',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') >= 
				  LEFT(FromCode, ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')))) OR 
				  ((UserID =' + ltrim(str(@UserID)) + ') AND 
				  ((LEFT(''' + @StrCode + ''',LEN(ToCode)) <= ToCode AND 
				  LEFT(''' + @StrCode + ''',LEN(ToCode)) >= FromCode) OR 
				  ((''' + @StrCode + ''' <= ToCode) AND 
				    ''' + @StrCode + ''' >= FromCode)))) '

	SET @ParmDefinition = N'@_Counter Int OUTPUT'
	print @SQLString
	EXECUTE sp_executesql @SQLString, @ParmDefinition, @_Counter=@Counter OUTPUT;

	IF @Counter>0 
		RETURN 3 -- در حیطه کاربر نیست

END

IF @bolAccessAllCodes=0 AND @bolAccessForView = 0
BEGIN
	SET @SQLString=
		  N'SELECT @_Counter=COUNT(UserID) 
			FROM ' + @StrTableName + 'Rng R
			WHERE (UserID =' + ltrim(str(@UserID)) + ') AND 
				  (AllowCodeView = 1) AND 
				  (R.PartNumber=' + LTRIM(STR(@PartNumber)) + ') AND 	
				  ((LEFT(''' + @StrCode + ''',LEN(ToCode)) <= ToCode AND 
				  LEFT(''' + @StrCode + ''',LEN(ToCode)) >= FromCode) OR 
				  ((LEFT(''' + @StrCode + ''',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') <= 
				  LEFT(ToCode, ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')) AND 
				  LEFT(''' + @StrCode + ''',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') >= 
				  LEFT(FromCode, ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')))'

	SET @ParmDefinition = N'@_Counter Int OUTPUT'
	print @SQLString
	EXECUTE sp_executesql @SQLString, @ParmDefinition, @_Counter=@Counter OUTPUT;

	IF @Counter=0 
		RETURN 3 -- در حیطه کاربر نیست

END

IF @StationID <>''
BEGIN
	SET @SQLString=
		  N'SELECT @_Counter=COUNT(UserID) 
			FROM ' + @StrTableName + 'Rng R
			WHERE (RngType>0) AND 
			      (UserID =' + @StationID + ') AND 
				  ((AccessAllCode=1) OR ((AllowCodeView = 1) AND 
				  (R.PartNumber=' + LTRIM(STR(@PartNumber)) + ') AND 	
				  ((LEFT(''' + @StrCode + ''',LEN(ToCode)) <= ToCode AND 
				  LEFT(''' + @StrCode + ''',LEN(ToCode)) >= FromCode) OR 
				  ((LEFT(''' + @StrCode + ''',' + LTRIM(STR(LEN(@StrCode))) + ') <= 
				  LEFT(ToCode, ' + LTRIM(STR(LEN(@StrCode))) + ')) AND 
				  LEFT(''' + @StrCode + ''',' + LTRIM(STR(LEN(@StrCode))) + ') >= 
				  LEFT(FromCode, ' + LTRIM(STR(LEN(@StrCode))) + ')))))'

	SET @ParmDefinition = N'@_Counter Int OUTPUT'
	print @SQLString
	EXECUTE sp_executesql @SQLString, @ParmDefinition, @_Counter=@Counter OUTPUT;

	IF @Counter=0 
		RETURN 4 -- در حیطه کاربر نیست

END

IF @StrTableName='acc.tblAcnt' AND @IsForce=1
	SELECT @AcntName AS AcntName, @Acnt2Force AS Acnt2Force, @Acnt3Force AS Acnt3Force, @Acnt4Force AS Acnt4Force
ELSE
	SELECT @AcntName AS AcntName
GO
