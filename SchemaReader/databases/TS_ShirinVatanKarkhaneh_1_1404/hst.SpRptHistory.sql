USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hst].[SpRptHistory]
	@FromDate		VarChar(20) = '',
	@ToDate			VarChar(20) = '',
	@UserID			Int = -1,
	@DbName			VarChar(500) = ''
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
BEGIN

	IF @FromDate<>''
		SET @StrSelect	= ' AND HistoryDate>=''' + @FromDate + '''' 

	IF @ToDate<>''
		SET @StrSelect	= @StrSelect + ' AND HistoryDate<=''' + @ToDate + ''''  

	IF @UserID <>-1		
		SET @StrSelect	= @StrSelect + ' AND UserID =' + LTRIM(RTRIM(STR(@UserID)))
	
	SET @StrSelect = 'SELECT distinct UserID,p.ProcessName,FiscalYear,SerialNo,HistoryDate,
	CASE ActionID WHEN 1 THEN ''ایجاد'' WHEN 2 THEN ''ویرایش'' WHEN 3 THEN ''حذف'' END ActionName ,
	' + @DbName + '.pub.funGetUserName(h.SessionNo,'''') UserName
	FROM hst.tblHistoryRecords h
	INNER JOIN pub.tblProcess p
	ON h.ProcessID=p.ProcessID and h.ProcessNo=p.ProcessNo
	INNER JOIN ' + @DbName + '.usr.tblSessionNumbers sn
	on sn.SessionNo=h.SessionNo
	INNER JOIN ' + @DbName + '.usr.tblSessions s
	on s.SessionID=sn.SessionID
	where SerialNo<>0 ' + @StrSelect + '
	order by HistoryDate'


	PRINT @StrSelect
	EXEC sp_executesql @StrSelect;
END
GO
