USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--[pub].[GetServerDriverSpace] 'TS_ArmanGholdasht_1_1399'
CREATE PROCEDURE [pub].[GetServerDriverSpace]
(
	@DBName varchar(300)
)
WITH ENCRYPTION            
AS

BEGIN
   SET NOCOUNT ON;

	EXEC sp_configure 'show advanced options', '1';
	RECONFIGURE WITH OVERRIDE;
	exec sp_configure 'xp_cmdshell', '1'; 
	RECONFIGURE WITH OVERRIDE;

	declare @svrName varchar(255)
	declare @sql varchar(400)
	select @svrName = CAST(SERVERPROPERTY('MACHINENAME') as varchar(255))
	set @sql = 'powershell.exe -c "Get-WmiObject -ComputerName ' + QUOTENAME(@svrName,'''') + ' -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"'

	CREATE TABLE #output
	(line varchar(255))
	--inserting disk name, total space and free space value in to temporary table
	insert #output
	EXEC xp_cmdshell @sql

	--script to retrieve the values in MB from PS Script output
	select rtrim(ltrim(SUBSTRING(line,1,CHARINDEX('|',line) -1))) as Drivename
	   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1,
	   (CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float),0) as Capacity
	   ,round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1,
	   (CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float),0) as Freespace
	INTO #FC
	from #output
	where line like '[A-Z][:]%'
	order by Drivename
	drop table #output

	SELECT * ,
			(select SUM(size)/128 
			from sys.master_files
			where physical_name like '%TS.ldf' OR physical_name like '%TS.mdf' OR 
			physical_name LIKE '%'+ @DBName + '%'  OR
			physical_name LIKE '%'+ SUBSTRING(@DBName,1,LEN(@DBName)-4) + '0000' + '%'  ) DBSize
	FROM #FC
	WHERE SUBSTRING (Drivename,1,1) IN (select top 1 SUBSTRING(physical_name,1,1) from sys.master_files where name like @DBName +'%')

	
END


GO
