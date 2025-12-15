USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--exec [pub].[SpFillDtlSave] 'acc.tblAcntDtl','AcntCode' ,1,1

-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 96/05/18
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [pub].[SpFillDtlSaveInMultiLanguage]
	@DtlTableFullName	varchar(50),
	@FieldName	varchar(50),
	@PartNumber			int,
	@LanguageID			int
	
WITH ENCRYPTION
AS

BEGIN

  --'AcntCode'',''LanguageID'
declare @Result1 as varchar(max)
declare @ColNames as varchar(max)
Declare @StrSelect  nVarchar(max)
Declare @SchemaName	varchar(10)
Declare @DtlTblName	varchar(50)
	
	Set @SchemaName= SUBSTRING(@DtlTableFullName,1,3)
	Set @DtlTblName= SUBSTRING(@DtlTableFullName,5, LEN(@DtlTableFullName)-4)
	
set @ColNames='' + @FieldName + ''',''LanguageID'
--	select @ColNames,@SchemaName,@DtlTblName
	SET @Result1= ''
			exec [pub].[funGetColumnsWithoutXColumns] @SchemaName=@SchemaName,@tableName=@DtlTblName,
			@ColumnsName=@ColNames,@CompressTableName='a',@Result=@Result1 output

--select @Result1


	BEGIN TRY
			DROP TABLE ##tblT
			
		END TRY
		BEGIN CATCH
		END CATCH
		
			if @Result1<>''
				SET @Result1= ','+@Result1
		
			Set @StrSelect  =' 
						Select Distinct a.'+@FieldName+',b.LanguageID '+@Result1+'  into ##tblT  FROM  '+@DtlTableFullName+' a 
			Cross Join (select distinct LanguageID from  '+@DtlTableFullName+' ) b'
			
			IF @PartNumber>0
				Set @StrSelect  = @StrSelect +  ' WHERE     PartNumber ='+ str(@PartNumber)+ ' '

			print @StrSelect
			exec sp_executesql @StrSelect
			
			Set @StrSelect  ='
			Delete from ##tblT 
			From  ##tblT a inner join 
			'+@DtlTableFullName+'  b on a.'+@FieldName+'=b.'+@FieldName+' and a.LanguageID=b.LanguageID '
			print @StrSelect
			exec sp_executesql @StrSelect
				
						
		Set @StrSelect  =' 	insert into '+@DtlTableFullName+'
			Select *  from  ##tblT
			except 
			Select * from  '+@DtlTableFullName
			
		print @StrSelect
			exec sp_executesql @StrSelect
END

GO
