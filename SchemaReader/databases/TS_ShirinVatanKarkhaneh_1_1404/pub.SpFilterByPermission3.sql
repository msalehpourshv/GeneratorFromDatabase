USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1402/09/25
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : Filter select Result By Permission
-- ===============================================
Create PROCEDURE [pub].[SpFilterByPermission3]
	@DataTableName	varchar(50),
	@DataFieldName	varchar(50),
	@CodeTableName	varchar(50),
	@PartNumber		int,
	@UserID			int
WITH ENCRYPTION	
AS
declare @StrSql		nvarchar(2000);

declare @PartStart		tinyint;
declare @PartLen		tinyint;
declare @PartFilter		varchar(50);
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

	if  (@CodeTableName = 'acc.tblVisitPath')
	begin
		select	@PartStart = 1;
		select	@PartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		from	pub.tblCodeLayer 
		where	(TableName = @CodeTableName) AND PartNumber = @PartNumber
		set @PartFilter = 'and (R.PartNumber = '+ str(@PartNumber)+')';		
	end

	-------------------------------------------------------------------------------------
	if @ExternalCall=0
	begin
	BEGIN TRY
		DROP TABLE #TempRngTable
	END TRY
	BEGIN CATCH
	END CATCH
	end

	select UserID,FromCode,ToCode,AllowCodeView,AccessAllCode,0 FromCodeLen, 0 ToCodeLen
		into #TempRngTable from acc.tblAcntRng where 1=0
 
	set @StrSql = 
		' insert into #TempRngTable
		select UserID,FromCode,ToCode,AllowCodeView,AccessAllCode,len(FromCode) FromCodeLen,len(ToCode) ToCodeLen
		from ' + @RngTableName + ' R 
		where (R.UserID=-1 or R.UserID=' + @User + ') ' + @PartFilter
	
	print @StrSql	
	exec sp_executesql @StrSql;

	set @StrSql = '
		DELETE 
		from ' + @DataTableName + ' 
		where len(' + @DataTableField + ') >= ' + Str(@PartStart) + ' 
		and 
		(
			(
				select Top 1 AllowCodeView
				from #TempRngTable R 
				where (R.AllowCodeView = 1) 
					and (R.AccessAllCode = 0) 
					and (Substring(' + @DataTableField + ', ' + Str(@PartStart) + ', R.FromCodeLen) >= R.FromCode) 
					and (Substring(' + @DataTableField + ', ' + Str(@PartStart) + ', R.ToCodeLen) <= R.ToCode)
			) is null 
			or
			(
				select Top 1 AllowCodeView
				from #TempRngTable R 
				where (R.AllowCodeView = 0) 
					and (R.AccessAllCode = 0) 
					and (Substring(' + @DataTableField + ', ' + Str(@PartStart) + ', R.FromCodeLen) >= R.FromCode) 
					and (Substring(' + @DataTableField + ', ' + Str(@PartStart) + ', R.ToCodeLen) <= R.ToCode)
			) is not null 
		)
		and (select Top 1 AccessAllCode from #TempRngTable R where AccessAllCode=1) is null'

	print @StrSql;
	exec sp_executesql @StrSql;

end
GO
