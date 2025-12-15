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
CREATE PROCEDURE [hst].[SpUserHistoryDtl]
	@HistoryBatch	bigint = Null
WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrTbl		VarChar(100)
DECLARE @LangID		Char(1)

BEGIN

	--------------------------------------------------------------------------
	SET @LangID = pub.funGetCurrentLanguageID();

	SET @StrTbl = db_name()
	SET @StrTbl = Substring(@StrTbl, 1, Len(@StrTbl) - 4) + '0000'

	SET @StrSelect = '
	SELECT *
	FROM
	(
		SELECT	HR.*, HF.OldValue, HF.NewValue, F.FieldName, F.FieldText, P.ProcessName,
				pub.funGetTypeText(F.TypeID, HF.OldValue, ' + @LangID + ') AS OldValue2, 
				pub.funGetTypeText(F.TypeID, HF.NewValue, ' + @LangID + ') AS NewValue2,
				U.UserID, U.WinUserName, U.ComputerName, U.IPAddress, U.MacAddress, U.UserName, 
				isnull((select top 1 ActionID from hst.tblHistoryRecords HI where HI.HistoryBatch=HR.HistoryBatch and DocRowNo=0),2) MainActionID
		FROM	(SELECT * FROM hst.tblHistoryRecords WHERE HistoryBatch =' + LTRIM(RTRIM(STR(@HistoryBatch))) + ' ) HR
					LEFT  JOIN pub.tblProcess P ON P.ProcessID = HR.ProcessID AND P.ProcessNo = HR.ProcessNo
					INNER JOIN hst.tblHistoryFields HF ON HF.HistoryID = HR.HistoryID  
					INNER JOIN hst.tblFields F ON F.FieldID = HF.FieldID  
					OUTER APPLY	' + @StrTbl + '.pub.funGetUserInfo(HR.SessionNo) U
	) T
	ORDER BY HistoryDate, HistoryTime, DocRowNo, DocAtomRowNo '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

END
GO
