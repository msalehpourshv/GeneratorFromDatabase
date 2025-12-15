USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		jafari
-- Create date: 1396/08/08
-- Description:
-- ==============================================

--exec [pub].[spCopytblFiltersRecords] 7601,150227,150045,'acc.tblAcnt'

Create PROCEDURE [pub].[spCopytblFiltersRecords] 
(
@SessionNo	INT,
@ReportIDSur	INT,
@ReportIDTar	INT,
 @CodingTable	Varchar(100))
WITH ENCRYPTION
As 
begin

Declare @SchemaName as Varchar(10)
Declare @tableName as Varchar(30)
Declare @ColumnsName as Varchar(10)

declare @Result1 as varchar(max)
	Declare @StrSelect  nVarchar(max)
	

Set @SchemaName='rpt'
Set @tableName='tblFilters'
Set @ColumnsName='ReportID'



	SET @Result1= ''
			exec [pub].[funGetColumnsWithoutXColumns] @SchemaName=@SchemaName,@tableName=@tableName,
			@ColumnsName=@ColumnsName,@CompressTableName='H',@Result=@Result1 output

Set @StrSelect  =' Insert into rpt.tblFilters(ReportID,'+@Result1+')
			Select  '+ STR(@ReportIDTar) +','+@Result1+' From rpt.tblFilters H 
			Where 	SessionNo='+STR(@SessionNo)+ '  and ReportID =   '+ STR(@ReportIDSur) +' and CodingTable = '''+@CodingTable+'''' 
			
			print @StrSelect
			exec sp_executesql @StrSelect



--Delete from rpt.tblFilters
--select * from rpt.tblFilters

end



























GO
