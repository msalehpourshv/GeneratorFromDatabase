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
CREATE PROCEDURE [hst].[RptUserHistoryDtl]
	@UserID			Int			= 0,
	@UserName		VarChar(50) = Null,
	@FiscalYearFr	Int 		= 96,
	@SerialNoFr		Int 		= 1,
	@FiscalYearTo	Int 		= 96,
	@SerialNoTo		Int 		= 10,
	@CodeFr			VarChar(20) = Null,
	@CodeTo			VarChar(20) = Null,
	@HistoryDateFr	Char(10) 	= Null,
	@HistoryDateTo	Char(10) 	= Null,
	@MainActionID	int			= 0,
	@HistoryBatch	Bigint		= 1
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)
DECLARE @StrWhereX	NVarChar(2000)
DECLARE @StrTbl		VarChar(100)
DECLARE @LangID		Char(1)
BEGIN
	-- ===========================================================
	SET @LangID = pub.funGetCurrentLanguageID();

	SET @StrTbl = db_name()
	SET @StrTbl = Substring(@StrTbl, 1, Len(@StrTbl) - 4) + '0000'

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	  Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	  Is Null)	SET @FiscalYearTo = Null;
	
	-- ===========================================================
	SET @StrWhere = '1 = 1'
	SET @StrWhereX = '1 = 1'

	IF (@UserID Is Not Null) AND @UserID > -1
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
	--------------------------------------------------------------------------

	IF (@MainActionID Is Not Null) and (@MainActionID > 0)
		SET @StrWhereX = @StrWhereX + ' AND (T.MainActionID = ' + Str(@MainActionID) + ')'
	
	-- ===========================================================
	SET @StrSelect = '
	select *
	from
	(
		SELECT	HR.*, HF.OldValue, HF.NewValue, F.FieldName, F.FieldText, P.ProcessName,
				pub.funGetTypeText(F.TypeID, HF.OldValue, ' + @LangID + ') AS OldValue2, 
				pub.funGetTypeText(F.TypeID, HF.NewValue, ' + @LangID + ') AS NewValue2,
				U.UserID, U.WinUserName, U.ComputerName, U.IPAddress, U.MacAddress, U.UserName, 
				isnull((select top 1 ActionID from hst.tblHistoryRecords HI where HI.HistoryBatch=HR.HistoryBatch and DocRowNo=0),2) MainActionID
		FROM	(SELECT * FROM hst.tblHistoryRecords) HR
					LEFT  JOIN pub.tblProcess P ON P.ProcessID = HR.ProcessID AND P.ProcessNo = HR.ProcessNo
					INNER JOIN hst.tblHistoryFields HF ON HF.HistoryID = HR.HistoryID  
					INNER JOIN hst.tblFields F ON F.FieldID = HF.FieldID  
					OUTER APPLY	' + @StrTbl + '.pub.funGetUserInfo(HR.SessionNo) U
		WHERE	' + @StrWhere + '
	) T
	WHERE ' + @StrWhereX + '
	ORDER BY HistoryDate, HistoryTime, DocRowNo, DocAtomRowNo '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
