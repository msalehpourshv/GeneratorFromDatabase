USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [inv].[RptStore_GetDocsByPrevYears]
	@ProcessID1	int,
	@ProcessID2	int,
	@RepOptions	varchar(10) = '',
	@RepInfo	nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare @curr_db_name	VarChar(100);
declare @prev_db_name	VarChar(100);
declare @StrSelect		NVarChar(2000);
Begin
	set nocount on;

	SET @curr_db_name = db_name();
	EXEC [pub].[SpGetPrevDBName] @curr_db_name, @prev_db_name OUTPUT
	
	select *
	into #tblStore_GetDocsByPrevYears_Result
	from inv.tblStorageDocsDtl
	where (ProcessID < 0)
	
	If (@prev_db_name <> '') 
	set @StrSelect = '
	insert into #tblStore_GetDocsByPrevYears_Result
	exec [' + @prev_db_name + '].[inv].[RptStore_GetDocsByPrevYears] ' + LTrim(Str(@ProcessID1)) + ',' + LTrim(Str(@ProcessID2)) + ',''' + LTrim(@RepOptions) + ''',''' + LTrim(@RepInfo) + ''''
	
	print @StrSelect;
	exec sp_executesql @StrSelect;

	select *
	from #tblStore_GetDocsByPrevYears_Result
	union all
	select *
	from inv.tblStorageDocsDtl
	where ProcessID in (@ProcessID1, @ProcessID2)
End
GO
