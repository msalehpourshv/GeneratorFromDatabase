USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jafari
-- Create date: 1396/08/03
-- Description:	لیست جداول دسترسی 
-- =============================================
CREATE PROCEDURE [pub].[spRngTables] 
( @ExtraParams		NVarChar(Max) = '',@Type int )
WITH ENCRYPTION
AS
BEGIN
	if @Type=1
	begin
	
		select b.name+'.'+a.Name TableEN,'  '  TableFA		 from sys.objects a inner join  sys.schemas b on a.schema_id=b.schema_id
		where a.name like '%Rng%' and type ='U'

	end 


	if @Type=2
	begin
		declare @Result1 as varchar(max)
			Declare @StrSelect  nVarchar(max)
	
		Declare @FromDB as Varchar(200)
		Declare @ToDB as Varchar(200)
		Declare @SchemaName as Varchar(10)
		Declare @tableName as Varchar(50)
		Declare @ColumnsName as Varchar(10)
		Declare @UserID1 as int
		Declare @UserID2 as int
		Declare @RangeID as int
		Declare @DeleteOld as int
		Declare @TestCopy as int


		set @SchemaName = subString(pub.funSplitString(@ExtraParams, '@', 1),1,3);
		set @tableName = pub.funSplitString(@ExtraParams, '@', 1);
		set @tableName =SUBSTRING(@tableName ,5,len(@tableName))
		set @UserID1 = pub.funSplitString(@ExtraParams, '@', 2);
		set @UserID2 = pub.funSplitString(@ExtraParams, '@', 3);
		set @DeleteOld = pub.funSplitString(@ExtraParams, '@', 4);
		set @TestCopy = pub.funSplitString(@ExtraParams, '@', 5);
		set @FromDB = pub.funSplitString(@ExtraParams, '@', 6);
		set @ToDB = pub.funSplitString(@ExtraParams, '@', 7);
		 BEGIN TRY
		
			BEGIN TRAN

			if (@DeleteOld=1)
			BEGIN
			Set @StrSelect  =' Delete From  ' + @ToDB + '.'+@SchemaName+'.'+@tableName+' where UserID='+ STR(@UserID2)
						print @StrSelect
						exec sp_executesql @StrSelect
			END 


			SET @Result1= ''
					exec [pub].[funGetColumnsWithoutXColumns] @SchemaName=@SchemaName,@tableName=@tableName,
					@ColumnsName='RangeID'',''UserID',@CompressTableName='H',@Result=@Result1 output

			if (@TestCopy<>1)
			BEGIN
				if exists (select 1 where @Result1 like '%PartNumber%')				
					Set @StrSelect  =
						'DELETE FROM ' + @ToDB + '.'+@SchemaName+'.'+@tableName+'
						from ' + @ToDB + '.'+@SchemaName+'.'+@tableName+' a
						INNER JOIN
						(SELECT PartNumber,FromCode,ToCode FROM ' + @ToDB + '.'+@SchemaName+'.'+@tableName+' WHERE  UserID='+STR(@UserID2) + '
						 INTERSECT	
						 SELECT PartNumber,FromCode,ToCode FROM ' + @FromDB + '.'+@SchemaName+'.'+@tableName+' WHERE  UserID='+STR(@UserID1) + '
						) b ON a.PartNumber=b.PartNumber and a.FromCode=b.FromCode and a.ToCode=b.ToCode'
				ELSE
					Set @StrSelect  =
						'DELETE FROM ' + @ToDB + '.'+@SchemaName+'.'+@tableName+'
						from ' + @ToDB + '.'+@SchemaName+'.'+@tableName+' a
						INNER JOIN
						(SELECT FromCode,ToCode FROM ' + @ToDB + '.'+@SchemaName+'.'+@tableName+' WHERE  UserID='+STR(@UserID2) + '
						 INTERSECT	
						 SELECT FromCode,ToCode FROM ' + @FromDB + '.'+@SchemaName+'.'+@tableName+' WHERE  UserID='+STR(@UserID1) + '
						) b ON a.FromCode=b.FromCode and a.ToCode=b.ToCode'
		
				Set @StrSelect  = @StrSelect + ' WHERE a.UserID='+STR(@UserID2)
				print @StrSelect
				exec sp_executesql @StrSelect
			END

			Set @StrSelect  =' Insert into ' + @ToDB + '.'+@SchemaName+'.'+@tableName+'(RangeID,UserID,'+@Result1+')
						Select  (Select isnull(Max(RangeID),0) From ' + @ToDB + '.'+@SchemaName+'.'+@tableName+' )+ ROW_NUMBER()over(order by RangeID) , '+STR(@UserID2) +' UserID,'+@Result1+' 
						FROM   ' + @FromDB + '.'+@SchemaName+'.'+@tableName+' H 
						Where 	UserID='+STR(@UserID1)

			if (@TestCopy=1)
			BEGIN
			Set @StrSelect  = @StrSelect +  ' and ( Select Count( * ) From ' + @ToDB + '.'+@SchemaName+'.'+@tableName+'  Where UserID='+ STR(@UserID2)+' )<=0'
			END 

			print @StrSelect
			exec sp_executesql @StrSelect
				COMMIT TRAN
	
			END TRY
			BEGIN CATCH
				ROLLBACK TRAN
				Declare @StrErrorMessage As Nvarchar(1024)
				Set @StrErrorMessage = ERROR_MESSAGE() 
				raiserror (@StrErrorMessage, 16, 1)
			END CATCH

	end 
end 
GO
