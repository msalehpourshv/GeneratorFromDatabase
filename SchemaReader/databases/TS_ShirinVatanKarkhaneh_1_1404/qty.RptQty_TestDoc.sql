USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/11/19
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : برگ آزمون کنترل کیفی
-- =============================================
Create PROCEDURE [qty].[RptQty_TestDoc]
	@ProcessID	  Int = 720,
	@ProcessNo	  Int = 1,
	@FiscalYear	  Int = Null,
	@SerialNo	  Int = Null,
	@FiscalYearTo Int = Null,
	@SerialNoTo	  Int = NULL

WITH ENCRYPTION

AS
Begin

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE @SelectedPrd   NVarChar(Max)
DECLARE @SelectedTest  NVarChar(Max)
DECLARE @DocDateFrom   VarChar(10)
DECLARE @DocDateTo	   VarChar(10)
DECLARE @StrSelect	   NVarChar(Max)
DECLARE @StrWhere	   NVarChar(Max) = ''
DECLARE @ExtraParams   NVarChar(Max)

SELECT @ExtraParams = Params FROM rpt.tblRptParams WHERE SessionNo = @FiscalYearTo

SET @LangID			= pub.funSplitString(@ExtraParams, '@', 1);
SET @SessionNo		= pub.funSplitString(@ExtraParams, '@', 2);
SET @ReportID		= pub.funSplitString(@ExtraParams, '@', 3);
SET @SelectedPrd	= pub.funSplitString(@ExtraParams, '@', 6);
SET @SelectedTest	= pub.funSplitString(@ExtraParams, '@', 7);
SET @DocDateFrom	= pub.funSplitString(@ExtraParams, '@', 8);
SET @DocDateTo		= pub.funSplitString(@ExtraParams, '@', 9);
SET @FiscalYearTo	= pub.funSplitString(@ExtraParams, '@', 10);

IF (@ProcessNo Is Null)		SET @ProcessNo = 1;
IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;

IF (@SelectedPrd > 0)
	SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrd, 'H.GoodsID')

IF (@SelectedTest > 0)
	SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTest, 'H.TestGroupID')

IF (@DocDateFrom Is Not Null AND @DocDateFrom <> '')
	SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFrom + ''')'
IF (@DocDateTo Is Not Null AND @DocDateTo <> '')
	SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

SET @StrSelect = '
SELECT H.*, 
	   D.RowNo, 
	   D.TestID, 
	   D.TestDate, 
	   D.TestTimeStart, 
	   D.TestTimeFinish, 
	   D.TestValue,
	   D.RowDesc,
	   G.GoodsName,
	   TG.TestGroupName,
	   [inv].[funGetBatchName](H.BatchNo, '+ @LangID +') BatchName,
	   T.TestName,
	   U.UnitName,
	   V.ValueName,
	   P1.FirstName + '' '' + P1.LastName as Signer1Name,
	   P2.FirstName + '' '' + P2.LastName as Signer2Name,
	   GD.TechnicalNo,
	   P.ProcessName,
	   TV.TextValue,
	   T.TextDefaultValue
FROM qty.tblQCTestDocsDtl D
INNER JOIN qty.tblQCTestDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
INNER JOIN qty.tblQCTests T ON T.TestID = D.TestID
INNER JOIN qty.tblQCTestValues TV on TV.TestID = D.TestID and TV.TestGroupID = H.TestGroupID
LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID = H.GoodsID
LEFT JOIN inv.tblGoods GD ON  GD.GoodsID = H.GoodsID
LEFT JOIN qty.tblQCTestGroups TG ON TG.TestGroupID = H.TestGroupID
LEFT JOIN prs.tblPersonnelsDtl P1 ON P1.PersonnelID = H.Signer1ID 
LEFT JOIN prs.tblPersonnelsDtl P2 ON P2.PersonnelID = H.Signer2ID 
LEFT JOIN qty.tblQCValues V ON V.ValueGroupID = T.ValueGroupID and V.ValueID = D.TestValue
LEFT JOIN pub.tblProcess P ON P.ProcessID = H.SourceProcessID AND P.ProcessNo = H.SourceProcessNo
LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = T.UnitID
WHERE D.ProcessID = ' + LTRIM(RTRIM(STR(@ProcessID))) + '
  And D.ProcessNo = ' + LTRIM(RTRIM(STR(@ProcessNo))) + '
  And D.FiscalYear >= ' + LTRIM(RTRIM(STR(@FiscalYear))) + ' 
  And D.SerialNo >= ' + LTRIM(RTRIM(STR(@SerialNo))) + '
  And D.FiscalYear <= ' + LTRIM(RTRIM(STR(@FiscalYearTo))) + ' 
  And D.SerialNo <= ' + LTRIM(RTRIM(STR(@SerialNoTo))) + @StrWhere

Print @StrSelect;    
Exec sp_executesql @StrSelect;
End
GO
