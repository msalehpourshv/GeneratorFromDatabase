USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/05/18
-- Viewed By	 : 
-- Last Modified : 1396/10/11
-- Last Modifier : TakroSystem\Hadi sadeghi
-- Description	 : اطلاعات تاریخچه
-- ===============================================
CREATE PROCEDURE [hst].[SpUserHistoryHdr]
	@UserID			Int = Null,
	@UserName		VarChar(50) = Null,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@CodeFr			VarChar(20) = Null,
	@CodeTo			VarChar(20) = Null,
	@HistoryDateFr	Char(10) = Null,
	@HistoryDateTo	Char(10) = Null,
	@MainActionID	int = 0,
	@Process		varchar(max)
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)
DECLARE @StrWhereX	NVarChar(2000)
DECLARE @StrTbl		VarChar(100)
BEGIN

	--------------------------------------------------------------------------
	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	  Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	  Is Null)	SET @FiscalYearTo = Null;

	SET @StrTbl = db_name()
	SET @StrTbl = Substring(@StrTbl, 1, Len(@StrTbl) - 4) + '0000'

	--------------------------------------------------------------------------
	SET @StrWhere = '(1=1)'

	IF (@UserID Is Not Null) AND @UserID >-1
		SET @StrWhere = @StrWhere + ' AND (U.UserID = ' + Str(@UserID) + ')'

	If (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (HR.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (HR.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND HR.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (HR.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (HR.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND HR.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@CodeFr Is Not Null) and (@CodeFr <> '')
		SET @StrWhere = @StrWhere + ' AND (HR.Code >= ''' + @CodeFr + ''')'
	IF (@CodeTo Is Not Null) and (@CodeTo <> '')
		SET @StrWhere = @StrWhere + ' AND (HR.Code <= ''' + @CodeTo + ''')'

	IF (@HistoryDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (HR.HistoryDate >= ''' + @HistoryDateFr + ''')'
	IF (@HistoryDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (HR.HistoryDate <= ''' + @HistoryDateTo + ''')'

	IF (@Process Is Not Null) AND @Process <>'' AND LTRIM(RTRIM(@Process)) <> '()'
		SET @StrWhere = @StrWhere + ' AND ' + @Process

	--------------------------------------------------------------------------
	SET @StrWhereX = '(1=1)'

	IF (@MainActionID Is Not Null) and (@MainActionID > 0)
		SET @StrWhereX = @StrWhereX + ' AND (T.MainActionID = ' + Str(@MainActionID) + ')'

	SET @StrSelect = '
	select *
	from
	(
		SELECT DISTINCT HR.HistoryBatch, HR.ProcessID, HR.ProcessNo, HR.FiscalYear, HR.SerialNo, HR.Code,
				HR.ActionID, HR.SessionNo, HR.HistoryDate, HR.HistoryTime, P.ProcessName +''-'' + LTRIM(str(HR.ProcessNo)) ProcessName , 
				U.UserID, U.WinUserName, U.ComputerName, U.IPAddress, U.MacAddress, U.UserName
		FROM	hst.tblHistoryRecords HR
					LEFT JOIN pub.tblProcess P ON P.ProcessID = HR.ProcessID AND P.ProcessNo = HR.ProcessNo
					OUTER APPLY	' + @StrTbl + '.pub.funGetUserInfo(HR.SessionNo) U
		WHERE	DocRowNo = 0 AND ' + @StrWhere + '
	) T
	where ' + @StrWhereX + '
	ORDER BY HistoryDate, HistoryTime '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
