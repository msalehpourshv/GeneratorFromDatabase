USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/12/07
-- Viewed By	 : 
-- Last Modified : 1392/12/22
-- Last Modifier : TakroSystem\ZiA
-- Description	 : Filter select Result By Permission
-- ===============================================
Create PROCEDURE [pub].[SpFilterByPermission2]
	@DataTableName	varchar(50),
	@DataFieldName	varchar(50),
	@CodeTableName	varchar(50),
	@UserID			int
WITH ENCRYPTION	
AS
declare @StrSql		nvarchar(2000);

declare @Part1Start		tinyint;
declare @Part2Start		tinyint;
declare @Part3Start		tinyint;
declare @Part4Start		tinyint;
declare @Part1Len		tinyint;
declare @Part2Len		tinyint;
declare @Part3Len		tinyint;
declare @Part4Len		tinyint;
declare @PartFilter1	varchar(50);
declare @PartFilter2	varchar(50);
declare @PartFilter3	varchar(50);
declare @PartFilter4	varchar(50);
declare @RngTableName	varchar(50);
declare @DataTableField varchar(50);
declare @User			varchar(10);
DECLARE @ExternalCall	Bit; -- is called from another sp?

begin
	
	Declare @StrParams	NVarChar(max);
	Declare @DbName_0000 as varchar(500)
	declare @bolIsAdmin Bit 

	select @DbName_0000 = LEFT(db_name(),LEN(db_name())-4) + '0000'

	SET @StrParams = N'  @bolIsAdmin2 Bit OUTPUT';

	SET @StrSql = 'SELECT @bolIsAdmin2 = ' + @DbName_0000 + '.pub.funUserIsAdmin(' + LTrim(Str(@UserID)) + ')'
	exec sp_executesql @StrSql, @StrParams, @bolIsAdmin OUTPUT;

	IF @bolIsAdmin = 1
		RETURN

	SET @ExternalCall		    = LTrim(pub.funSplitString(@DataTableName, '@', 2)); 
	SET @DataTableName			= LTrim(pub.funSplitString(@DataTableName, '@', 1)); 

	set @RngTableName = @CodeTableName + 'Rng'
	set @DataTableField = @DataTableName + '.' + @DataFieldName
	set @User = LTrim(Str(@UserID))

	select	@Part1Start = 1;
	select	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	from	pub.tblCodeLayer 
	where	(TableName = @CodeTableName) AND (PartNumber = 1)

	if (@CodeTableName = 'acc.tblAcnt')
	begin
		select	@Part2Start = @Part1Start + @Part1Len + 1;
		select	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		from	pub.tblCodeLayer 
		where	(TableName = @CodeTableName) AND (PartNumber = 2)

		select	@Part3Start = @Part2Start + @Part2Len + 1;
		select	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		from	pub.tblCodeLayer 
		where	(TableName = @CodeTableName) AND (PartNumber = 3)

		select	@Part4Start = @Part3Start + @Part3Len + 1;
		select	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		from	pub.tblCodeLayer 
		where	(TableName = @CodeTableName) AND (PartNumber = 4)

		set @PartFilter1 = 'and (R.PartNumber = 1)';
		set @PartFilter2 = 'and (R.PartNumber = 2)';
		set @PartFilter3 = 'and (R.PartNumber = 3)';
		set @PartFilter4 = 'and (R.PartNumber = 4)';
	end

	else
	begin
		set @Part2Start = 0;
		set @Part3Start = 0;
		set @Part4Start = 0;

		set @Part2Len = 0;
		set @Part3Len = 0;
		set @Part4Len = 0;

		set @PartFilter1 = '';
		set @PartFilter2 = '';
		set @PartFilter3 = '';
		set @PartFilter4 = '';
	end;
	
	-------------------------------------------------------------------------------------
	if @ExternalCall=0
	begin
	BEGIN TRY
		DROP TABLE #TempRngTable1
		DROP TABLE #TempRngTable2
		DROP TABLE #TempRngTable3
		DROP TABLE #TempRngTable4
	END TRY
	BEGIN CATCH
	END CATCH
	end
	select UserID,FromCode,ToCode,AllowCodeView,AccessAllCode,0 FromCodeLen, 0 ToCodeLen
		into #TempRngTable1 from acc.tblAcntRng where 1=0

	set @StrSql = 
	  ' insert into #TempRngTable1
		select UserID,FromCode,ToCode,AllowCodeView,AccessAllCode,len(FromCode) FromCodeLen,len(ToCode) ToCodeLen
		from ' + @RngTableName + ' R 
		where (R.UserID=-1 or R.UserID=' + @User + ') ' + @PartFilter1
	
	exec sp_executesql @StrSql;

	-------------------------------------------------------------------------------------
	 
	set @StrSql = '
		DELETE 
		from ' + @DataTableName  + ' 
		where len(' + @DataTableField + ') > 0 
		and
		(
			(
				select Top 1 AllowCodeView
				from #TempRngTable1 R 
				where (R.AllowCodeView = 1) 
					and (R.AccessAllCode = 0) 
					and (Substring(' + @DataTableField + ', 1, R.FromCodeLen) >= R.FromCode) 
					and (Substring(' + @DataTableField + ', 1, R.ToCodeLen) <= R.ToCode)
			) is null
			or
			(
				select Top 1 AllowCodeView
				from #TempRngTable1 R 
				where (R.AllowCodeView = 0) 
					and (R.AccessAllCode = 0) 
					and (Substring(' + @DataTableField + ', 1, R.FromCodeLen) >= R.FromCode) 
					and (Substring(' + @DataTableField + ', 1, R.ToCodeLen) <= R.ToCode)
			) is not null 
		)
		and (select Top 1 AccessAllCode from #TempRngTable1 R where AccessAllCode=1) is null'

	print @StrSql;
	exec sp_executesql @StrSql;

	-------------------------------------------------------------------------------------

	if (@Part2Len > 0)	
	begin

		select * into #TempRngTable2 from #TempRngTable1  where 1=0
	
		set @StrSql = 
		  ' insert into #TempRngTable2
			select UserID,FromCode,ToCode,AllowCodeView,AccessAllCode,len(FromCode) FromCodeLen,len(ToCode) ToCodeLen
			from ' + @RngTableName + ' R 
			where (R.UserID=-1 or R.UserID=' + @User + ') ' + @PartFilter2
	
		exec sp_executesql @StrSql;

		set @StrSql = '
			DELETE 
			from ' + @DataTableName + ' 
			where len(' + @DataTableField + ') > ' + Str(@Part2Start) + ' 
			and 
			(
				(
					select Top 1 AllowCodeView
					from #TempRngTable2 R 
					where (R.AllowCodeView = 1) 
						and (R.AccessAllCode = 0) 
						and (Substring(' + @DataTableField + ', ' + Str(@Part2Start) + ', R.FromCodeLen) >= R.FromCode) 
						and (Substring(' + @DataTableField + ', ' + Str(@Part2Start) + ', R.ToCodeLen) <= R.ToCode)
				) is null 
				or
				(
					select Top 1 AllowCodeView
					from #TempRngTable2 R 
					where (R.AllowCodeView = 0) 
						and (R.AccessAllCode = 0) 
						and (Substring(' + @DataTableField + ', ' + Str(@Part2Start) + ', R.FromCodeLen) >= R.FromCode) 
						and (Substring(' + @DataTableField + ', ' + Str(@Part2Start) + ', R.ToCodeLen) <= R.ToCode)
				) is not null 
			)
			and (select Top 1 AccessAllCode from #TempRngTable2 R where AccessAllCode=1) is null'

		print @StrSql;
		exec sp_executesql @StrSql;
	end

	-------------------------------------------------------------------------------------

	if (@Part3Len > 0)	
	begin

		select * into #TempRngTable3 from #TempRngTable1  where 1=0

		set @StrSql = 
		  ' insert into #TempRngTable3
			select UserID,FromCode,ToCode,AllowCodeView,AccessAllCode,len(FromCode) FromCodeLen,len(ToCode) ToCodeLen
			from ' + @RngTableName + ' R 
			where (R.UserID=-1 or R.UserID=' + @User + ') ' + @PartFilter3
	
		exec sp_executesql @StrSql;

		set @StrSql = '
			DELETE 
			from  ' + @DataTableName + '
			where len(' + @DataTableField + ') > ' + Str(@Part3Start) + ' 
			and
			(
				(
					select Top 1 AllowCodeView
					from #TempRngTable3 R 
					where (R.AllowCodeView = 1) 
						and (R.AccessAllCode = 0)
						and (Substring(' + @DataTableField + ', ' + Str(@Part3Start) + ', R.FromCodeLen) >= R.FromCode) 
						and (Substring(' + @DataTableField + ', ' + Str(@Part3Start) + ', R.ToCodeLen) <= R.ToCode)
				) is null 
				or
				(
					select Top 1 AllowCodeView
					from #TempRngTable3 R 
					where (R.AllowCodeView = 0) 
						and (R.AccessAllCode = 0)
						and (Substring(' + @DataTableField + ', ' + Str(@Part3Start) + ', R.FromCodeLen) >= R.FromCode) 
						and (Substring(' + @DataTableField + ', ' + Str(@Part3Start) + ', R.ToCodeLen) <= R.ToCode)
				) is not null 
			)
		and (select Top 1 AccessAllCode from #TempRngTable3 R where AccessAllCode=1) is null'

		print @StrSql;
		exec sp_executesql @StrSql;

	end;

	-------------------------------------------------------------------------------------

if (@Part4Len > 0)	
	begin

		select * into #TempRngTable4 from #TempRngTable1  where 1=0

		set @StrSql = 
		  ' insert into #TempRngTable4
			select UserID,FromCode,ToCode,AllowCodeView,AccessAllCode,len(FromCode) FromCodeLen,len(ToCode) ToCodeLen
			from ' + @RngTableName + ' R 
			where (R.UserID=-1 or R.UserID=' + @User + ') ' + @PartFilter4
	
		exec sp_executesql @StrSql;

		set @StrSql = '
			DELETE 
			from  ' + @DataTableName + '
			where len(' + @DataTableField + ') > ' + Str(@Part4Start) + ' 
			and
			(
				(
					select Top 1 AllowCodeView
					from #TempRngTable4 R 
					where (R.AllowCodeView = 1) 
						and (R.AccessAllCode = 0)
						and (Substring(' + @DataTableField + ', ' + Str(@Part4Start) + ', R.FromCodeLen) >= R.FromCode) 
						and (Substring(' + @DataTableField + ', ' + Str(@Part4Start) + ', R.ToCodeLen) <= R.ToCode)
				) is null 
				or
				(
					select Top 1 AllowCodeView
					from #TempRngTable4 R 
					where (R.AllowCodeView = 0) 
						and (R.AccessAllCode = 0)
						and (Substring(' + @DataTableField + ', ' + Str(@Part4Start) + ', R.FromCodeLen) >= R.FromCode) 
						and (Substring(' + @DataTableField + ', ' + Str(@Part4Start) + ', R.ToCodeLen) <= R.ToCode)
				) is not null 
			)
		and (select Top 1 AccessAllCode from #TempRngTable4 R where AccessAllCode=1) is null'

		print @StrSql;
		exec sp_executesql @StrSql;

	end;

end
GO
