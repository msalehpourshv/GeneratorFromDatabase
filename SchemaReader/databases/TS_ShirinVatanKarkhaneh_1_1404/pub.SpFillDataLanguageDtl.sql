USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 96/05/18
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [pub].[SpFillDataLanguageDtl]
	@HdrTableFullName	varchar(50),
	@DtlTableFullName	varchar(50),
	@FieldName	varchar(50),
	@PartNumber			int,
	@LanguageID			int
	
WITH ENCRYPTION
AS

BEGIN


  	DECLARE @strSql AS NVarChar(500) 

BEGIN TRY
			DROP TABLE ##tblT
			
		END TRY
		BEGIN CATCH
		END CATCH
		
	IF @PartNumber > 0
	SET @strSql = 
'select a.* into ##tblT from '+@DtlTableFullName+' a
inner join
(
SELECT '+@FieldName+' ,PartNumber FROM '+@HdrTableFullName+' WHERE 1=1  AND PartNumber='+ STR(	@PartNumber	) +' 
EXCEPT 
SELECT '+@FieldName+'  ,PartNumber FROM '+@DtlTableFullName+' WHERE LanguageID='+ STR(	@LanguageID	) +'  AND PartNumber='+ STR(	@PartNumber	) +' 
) b
on a.'+@FieldName+' =b.'+@FieldName+'  and a.PartNumber=b.PartNumber AND 
a.LanguageID = ( SELECT MIN(LanguageID) FROM '+@DtlTableFullName+' c 
WHERE c.'+@FieldName+' =a.'+@FieldName+'  AND c.PartNumber=a.PartNumber)
'
else
	SET @strSql = 
'select a.* into ##tblT from '+@DtlTableFullName+' a
inner join
(
SELECT '+@FieldName+'  FROM '+@HdrTableFullName+' WHERE 1=1  
EXCEPT 
SELECT '+@FieldName+'   FROM '+@DtlTableFullName+' WHERE LanguageID='+ STR(	@LanguageID	) +'   
) b
on a.'+@FieldName+' =b.'+@FieldName+'  AND 
a.LanguageID = ( SELECT MIN(LanguageID) FROM '+@DtlTableFullName+' c 
WHERE c.'+@FieldName+' =a.'+@FieldName+'  )
'

print @strSql
	EXEC sp_executesql @strSql;
	
	
	
        UPDATE ##tblT SET LanguageID=@LanguageID
        set @strSql= 'INSERT INTO ' + @DtlTableFullName + ' SELECT * FROM ##tblT '


print @strSql
	EXEC sp_executesql @strSql;

	
	
END

GO
