USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		 Sadeghi, Hadi
-- Create date: 
-- Description:
-- ==============================================
Create PROCEDURE [pub].[spTestCodeNameEntryCode] 
(@StrCode				VarChar(20),
 @strFieldCode			VARCHAR(50),
 @strFieldName			NVarChar(100),
 @strField				NVarChar(100),
 @StrTableName			NVarChar(100),
 @StrDtlTableName		NVarChar(100),
 @UserID				Int,
 @bolClosedCodeIsValid	Bit,
 @bolUserIsAdmin        Bit,
 @bolAccessAllCodes		Bit,
 @bolAccessForView		Bit,
 @Acnt1CurrentLayerSum	Tinyint,
 @strFilter				NVarChar(2000)='',
 @strFilterFieldValue1  NVarChar(1000)='',
 @strFilterFieldName1   NVarChar(1000)='',
 @strFilterFieldValue2  NVarChar(1000)='',
 @strFilterFieldName2   NVarChar(1000)='',
 @strFilterFieldValue3  NVarChar(1000)='',
 @strFilterFieldName3   NVarChar(1000)='',
 @LanguageID			Tinyint=1,
 @LayerMustComplete		Bit=1,
 @PartNumber			Tinyint=1,
 @StationID				nvarchar(10)='')
--@ReturnValue
--1 موجود نیست
--2 مسدود است
--2 در حیطه کاربر نیست
WITH ENCRYPTION
As 

DECLARE @SQLString NVarChar(4000);
DECLARE @ParmDefinition NVarChar(500);
DECLARE @AcntName NVarChar(500);
DECLARE @AcntCode NVarChar(500);
DECLARE @CodeClosed bit;
DECLARE @Acnt2Force Tinyint;
DECLARE @Acnt3Force Tinyint;
DECLARE @Acnt4Force Tinyint;

IF LEN(@StrCode) < @Acnt1CurrentLayerSum
	SET @Acnt1CurrentLayerSum = LEN(@StrCode)

SET @StrCode=UPPER(@StrCode)

SET @ParmDefinition = N'@_AcntCode NVarChar(50) OUTPUT,@_AcntName NVarChar(50) OUTPUT,@_CodeClosed bit OUTPUT'

SET @AcntName = Null
SET @AcntCode = Null
IF @StrDtlTableName<>''
BEGIN

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	SET @SQLString=
		 N'SELECT @_AcntCode=H.' + @strFieldCode + ',@_AcntName=' + @strField + ',@_CodeClosed=CodeClosed
		   FROM ' + @StrTableName + ' H,' + @StrTableName + 'Dtl D 
		   WHERE H.' + @strFieldCode +'=D.' + @strFieldCode +' AND 
				 LanguageID=' + LTRIM(STR(@LanguageID)) 
				 
	IF @LayerMustComplete = 1
		BEGIN
			SET @SQLString = @SQLString + ' AND UPPER(H.' + @strFieldCode + ')=''' + @StrCode + ''''
		END
	ELSE
		BEGIN
			SET @SQLString = @SQLString + ' AND UPPER(H.' + @strFieldCode + ') LIKE''' + @StrCode + '%'''
		END	
					 
	IF @PartNumber>0
	BEGIN
		SET	@SQLString= @SQLString + ' AND H.PartNumber=D.PartNumber AND H.PartNumber=' + Ltrim(Str(@PartNumber))
	END
END
ELSE
BEGIN
	SET @SQLString=
		 N'SELECT  @_AcntCode=H.' + @strFieldCode + ',@_AcntName=' + @strField + ',@_CodeClosed=CodeClosed
		   FROM ' + @StrTableName + ' H
		   WHERE H.'+ @strFieldCode + '=''' + @StrCode + ''''
END

IF @strFilter<>''
BEGIN
	SET	@SQLString=@SQLString + N' AND ' + @strFilter
END

IF @strFilterFieldValue1<>''
BEGIN
	SET	@SQLString=@SQLString + N' AND (' + @strFilterFieldName1 + ' IN (' + @strFilterFieldValue1 + '))'
END

IF @strFilterFieldValue2<>''
BEGIN
	SET	@SQLString=@SQLString + N' AND (' + @strFilterFieldName2 + ' IN (' + @strFilterFieldValue2 + '))'
END

IF @strFilterFieldValue3<>''
BEGIN
	SET	@SQLString=@SQLString + N' AND (' + @strFilterFieldName3 + ' IN (' + @strFilterFieldValue3 + '))'
END


EXECUTE sp_executesql @SQLString, @ParmDefinition, @_AcntCode=@AcntCode OUTPUT, @_AcntName=@AcntName OUTPUT, @_CodeClosed=@CodeClosed OUTPUT;

	print @SQLString
IF @AcntName IS Null
	RETURN 1 

IF @bolClosedCodeIsValid=0 AND @CodeClosed=1
	RETURN 2


DECLARE @Counter Int

IF @bolUserIsAdmin = 0 AND @bolAccessAllCodes=0 AND @PartNumber > 0
BEGIN
	SET @SQLString= 
		  N'SELECT @_Counter=COUNT(UserID) 
			FROM ' + @StrTableName + 'Rng R
			WHERE (R.AllowCodeView = 0) AND '

    IF @PartNumber > 0
        SET @SQLString = @SQLString + N'R.PartNumber=' + Ltrim(Str(@PartNumber)) + ' AND '
			  
	SET @SQLString= @SQLString + 
	                N'(((R.UserID =-1) AND 
				   ((LEFT(''' + @StrCode + ''',LEN(ToCode)) <= UPPER(ToCode) AND 
				     LEFT(''' + @StrCode + ''',LEN(ToCode)) >= UPPER(FromCode)) OR 
				   ((LEFT(''' + @StrCode + ''',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') <= 
  					 LEFT(UPPER(ToCode), ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')) AND 
					 LEFT(''' + @StrCode + ''',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') >= 
					 LEFT(UPPER(FromCode), ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')))) OR '

	SET @SQLString= @SQLString + 
	                N'((R.UserID =' + ltrim(str(@UserID)) + ') AND 
				   ((LEFT(''' + @StrCode + ''',LEN(ToCode)) <= UPPER(ToCode) AND 
				     LEFT(''' + @StrCode + ''',LEN(ToCode)) >= UPPER(FromCode)))))
				      --OR 
				   --((LEFT(''' + @StrCode + ''',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') <= 
  					 --LEFT(UPPER(ToCode), ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')) AND 
					 --LEFT(''' + @StrCode + ''',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') >= 
					 --LEFT(UPPER(FromCode), ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')))))'
					 
	SET @ParmDefinition = N'@_Counter Int OUTPUT'

	print @SQLString
	EXECUTE sp_executesql @SQLString, @ParmDefinition, @_Counter=@Counter OUTPUT;

	IF @Counter>0 
		RETURN 3 
END

IF @bolAccessAllCodes=0 AND @bolAccessForView = 0 AND @bolUserIsAdmin=0 
BEGIN

	SET @SQLString= 
		  N'SELECT @_Counter=COUNT(UserID) 
			FROM ' + @StrTableName + 'Rng R
			WHERE (R.UserID =' + ltrim(str(@UserID)) + ') AND 
				  (R.AllowCodeView = 1) AND '

    IF @PartNumber > 0
	    SET @SQLString = @SQLString + N'R.PartNumber=' + Ltrim(Str(@PartNumber)) + ' AND '
        		  
	SET @SQLString = @SQLString + 
				   N'((LEFT(''' + @StrCode + ''',LEN(ToCode)) <= UPPER(ToCode) AND 
				     LEFT(''' + @StrCode + ''',LEN(ToCode)) >= UPPER(FromCode)) OR 
				   ((LEFT(''' + @StrCode + ''',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') <= 
  					 LEFT(UPPER(ToCode), ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')) AND 
					 LEFT(''' + @StrCode + ''',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') >= 
					 LEFT(UPPER(FromCode), ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')))'
				  
--	SET @SQLString= @SQLString + 
--		N'(LEFT(''' + @StrCode + ''',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') <= 
--		   LEFT(ToCode, ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')) AND 
--		   LEFT(' + @StrCode + ',' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ') >= 
--		   LEFT(FromCode, ' + LTRIM(STR(@Acnt1CurrentLayerSum)) + ')'

	SET @ParmDefinition = N'@_Counter Int OUTPUT'
	print @SQLString
	EXECUTE sp_executesql @SQLString, @ParmDefinition, @_Counter=@Counter OUTPUT;

	IF @Counter=0 
		RETURN 3 
END

IF @StationID <>''
BEGIN

	SET @SQLString= 
		  N'SELECT @_Counter=COUNT(UserID) 
			FROM ' + @StrTableName + 'Rng R
			WHERE (RngType>0) AND 
			      (R.UserID =' + @StationID + ') AND 
				  (R.AllowCodeView = 1) AND '

    IF @PartNumber > 0
	    SET @SQLString = @SQLString + N'R.PartNumber=' + Ltrim(Str(@PartNumber)) + ' AND '
        		  
	SET @SQLString = @SQLString + 
				   N'((AccessAllCode=1) OR (((LEFT(''' + @StrCode + ''',LEN(ToCode)) <= UPPER(ToCode) AND 
				     LEFT(''' + @StrCode + ''',LEN(ToCode)) >= UPPER(FromCode)) OR 
				   ((LEFT(''' + @StrCode + ''',' + LTRIM(STR(LEN(@StrCode))) + ') <= 
  					 LEFT(UPPER(ToCode), ' + LTRIM(STR(LEN(@StrCode))) + ')) AND 
					 LEFT(''' + @StrCode + ''',' + LTRIM(STR(LEN(@StrCode))) + ') >= 
					 LEFT(UPPER(FromCode), ' + LTRIM(STR(LEN(@StrCode))) + ')))))'
				  

	SET @ParmDefinition = N'@_Counter Int OUTPUT'
	print @SQLString
	EXECUTE sp_executesql @SQLString, @ParmDefinition, @_Counter=@Counter OUTPUT;

	IF @Counter=0 
		RETURN 4 
END

SET @ParmDefinition = N'@_AcntCode NVarChar(500),@_AcntName NVarChar(500) '
SET @SQLString = N'SELECT  @_AcntCode AS ' + @strFieldCode + ',@_AcntName AS ' + @strFieldName

print @SQLString
EXECUTE sp_executesql @SQLString,@ParmDefinition,@_AcntCode=@AcntCode ,@_AcntName=@AcntName 

--END
GO
