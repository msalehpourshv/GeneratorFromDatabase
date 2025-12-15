USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/04/13
-- Viewed By	 : 
-- Last Modified : 1389/04/15
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
Create PROCEDURE [pln].[RptPln_TaskStats_NoGroup]
	@TProcessSetFr	VarChar(20) = Null,
	@TProcessSetTo	VarChar(20) = Null,
	@OProcessSetFr	VarChar(20) = Null,
	@OProcessSetTo	VarChar(20) = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SelectedTools	Int = 0,
	@SelectedPrsns	Int = 0,
	@SelectedGoods	Int = 0,
	@DetailField	Char(1) = 'P',
	@ExtraParams	NVarChar(100) = '1,2,3,4,7',
	@RepOptions		VarChar(10) = '1',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000)
DECLARE @StrWhere	NVarChar(4000)
DECLARE @StrFrom	NVarChar(4000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

DECLARE	@TProcessID		Int;
DECLARE	@TProcessNo		Int;
DECLARE	@TFiscalYearFr	Int;
DECLARE	@TSerialNoFr	Int;
DECLARE	@TFiscalYearTo	Int;
DECLARE	@TSerialNoTo	Int;
DECLARE	@OProcessID		Int;
DECLARE	@OProcessNo		Int;
DECLARE	@OFiscalYearFr	Int;
DECLARE	@OSerialNoFr	Int;
DECLARE	@OFiscalYearTo	Int;
DECLARE	@OSerialNoTo	Int;
DECLARE	@GroupFields	NVarChar(1000);
DECLARE	@Status			VarChar(20);
DECLARE	@Serials		VarChar(100);

Begin

	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '1';
	IF (@ExtraParams	Is Null)	SET @ExtraParams= '1,2,3,4,7';
	IF (@ExtraParams	= '')		SET @ExtraParams= '1,2,3,4,7';

	IF (@SelectedPrsns	Is Null)	SET @SelectedPrsns = 0;
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedTools	Is Null)	SET @SelectedTools = 0;

	IF (@TProcessSetFr Is Not Null)
	Begin
		SET @TProcessID		= pub.funSplitString(@TProcessSetFr, '@', 1);
		SET @TProcessNo		= pub.funSplitString(@TProcessSetFr, '@', 2);
		SET @TFiscalYearFr	= pub.funSplitString(@TProcessSetFr, '@', 3);
		SET @TSerialNoFr	= pub.funSplitString(@TProcessSetFr, '@', 4);
	END

	IF (@TProcessSetTo Is Not Null)
	Begin
		SET @TProcessID		= pub.funSplitString(@TProcessSetTo, '@', 1);
		SET @TProcessNo		= pub.funSplitString(@TProcessSetTo, '@', 2);
		SET @TFiscalYearTo	= pub.funSplitString(@TProcessSetTo, '@', 3);
		SET @TSerialNoTo	= pub.funSplitString(@TProcessSetTo, '@', 4);
	END

	IF (@OProcessSetFr Is Not Null)
	Begin
		SET @OProcessID		= pub.funSplitString(@OProcessSetFr, '@', 1);
		SET @OProcessNo		= pub.funSplitString(@OProcessSetFr, '@', 2);
		SET @OFiscalYearFr	= pub.funSplitString(@OProcessSetFr, '@', 3);
		SET @OSerialNoFr	= pub.funSplitString(@OProcessSetFr, '@', 4);
	END

	IF (@OProcessSetTo Is Not Null)
	Begin
		SET @OProcessID		= pub.funSplitString(@OProcessSetTo, '@', 1);
		SET @OProcessNo		= pub.funSplitString(@OProcessSetTo, '@', 2);
		SET @OFiscalYearTo	= pub.funSplitString(@OProcessSetTo, '@', 3);
		SET @OSerialNoTo	= pub.funSplitString(@OProcessSetTo, '@', 4);
	END

	SET @Status		= pub.funSplitString(@ExtraParams, '@', 1);
	SET @Serials    = pub.funSplitString(@ExtraParams, '@', 2);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '(TaskStateID in (' + @Status + '))'

	IF (@Serials Is Not Null and @Serials <>'')
		SET @StrWhere = @StrWhere +  ' and  T.SerialNo in (' + @Serials + ')'
	IF (@TProcessSetFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (T.FiscalYear > ' + LTrim(Str(@TFiscalYearFr)) + ' OR (T.FiscalYear = ' + LTrim(Str(@TFiscalYearFr)) + ' AND T.SerialNo >= ' + LTrim(Str(@TSerialNoFr)) + '))' 
	IF (@TProcessSetTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (T.FiscalYear < ' + LTrim(Str(@TFiscalYearTo)) + ' OR (T.FiscalYear = ' + LTrim(Str(@TFiscalYearTo)) + ' AND T.SerialNo <= ' + LTrim(Str(@TSerialNoTo)) + '))' 
	IF (@TProcessSetFr Is Not Null) Or (@TProcessSetTo Is Not Null)
		If (@TProcessNo > 0)
			SET @StrWhere = @StrWhere + ' AND (T.ProcessNo = ' + LTrim(Str(@TProcessNo)) + ')' 

	IF (@OProcessSetFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (R.BaseFiscalYear > ' + LTrim(Str(@OFiscalYearFr)) + ' OR (R.BaseFiscalYear = ' + LTrim(Str(@OFiscalYearFr)) + ' AND R.BaseSerialNo >= ' + LTrim(Str(@OSerialNoFr)) + '))' 
	IF (@OProcessSetTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (R.BaseFiscalYear < ' + LTrim(Str(@OFiscalYearTo)) + ' OR (R.BaseFiscalYear = ' + LTrim(Str(@OFiscalYearTo)) + ' AND R.BaseSerialNo <= ' + LTrim(Str(@OSerialNoTo)) + '))' 
	IF (@OProcessSetFr Is Not Null) Or (@OProcessSetTo Is Not Null)
		If (@OProcessNo > 0)
			SET @StrWhere = @StrWhere + ' AND (R.BaseProcessNo = ' + LTrim(Str(@OProcessNo)) + ')' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (T.StartDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (T.FinishDate <= ''' + @DocDateTo + ''')'

	IF (@SelectedTools > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'T.ToolID')
	IF (@SelectedPrsns > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrsns, 'O.OperatorID')
	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'T.ProductID')

	---------------------------------------------------------------------------
	-- G R O U P --------------------------------------------------------------

	if (@DetailField = 'T')
		set @GroupFields = ' T.ToolID as XToolID, cast('''' as varchar(20)) as XProductID, cast('''' as varchar(20)) as XOperatorID'

	if (@DetailField = 'P')
		set @GroupFields = ' T.ToolID as XToolID, T.ProductID as XProductID, cast('''' as varchar(20)) as XOperatorID'
		--set @GroupFields = ' cast('''' as varchar(20)) as XToolID, T.ProductID as XProductID, cast('''' as varchar(20)) as XOperatorID'

	if (@DetailField = 'O')
		set @GroupFields = ' cast('''' as varchar(20)) as XToolID, cast('''' as varchar(20)) as XProductID, O.OperatorID as XOperatorID';

	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	declare @operator_join as nvarchar(500);
	declare @tool_join as nvarchar(500);

	if (@DetailField = 'O') 
		set @operator_join = 'INNER JOIN pln.tblTaskOrderOperators O ON O.ProcessID = T.ProcessID AND O.ProcessNo = T.ProcessNo AND O.FiscalYear = T.FiscalYear AND O.SerialNo = T.SerialNo AND O.RowNo = T.RowNo'
	else
		set @operator_join = 'LEFT JOIN pln.tblTaskOrderOperators O ON O.ProcessID = -1 AND O.ProcessNo = -1 AND O.FiscalYear = -1 AND O.SerialNo = -1 AND O.RowNo = -1'

	if (@DetailField = 'T') 
		set @tool_join = 'INNER JOIN pln.tblTools T ON T.ToolID = S.ToolID'
	else
		set @tool_join = 'LEFT  JOIN pln.tblTools T ON T.ToolID = S.ToolID'

	SET @StrSelect = '
	SELECT S.*, T.ToolName, P.PersonnelName AS OperatorName, [pub].[funGetGoodsName](S.ProductID,' + @LangID + ') AS ProductName
	FROM
	(
	    SELECT	XToolID as ToolID, XOperatorID as OperatorID, XProductID as ProductID,
	    T.ProductWidth,T.ProductHeight,T.ProductQuantity2 ,
				Sum(T.TotalTime)	TotalTime,
				Sum(T.ToolFixTime)	ToolFixTime,
				Sum(T.IdleTime)		IdleTime,
				Sum(T.FaultTime)	FaultTime,
				Sum(T.PrdStepTime * AcceptableCount) StandardTime,
				Sum(AcceptableCount) [Count]
		FROM	
		(
			SELECT	T.*,' + @GroupFields + '
			FROM	pln.vwTaskOrderDtl T 
					' + @operator_join + '
						LEFT JOIN pln.tblItemRelations R ON R.ProcessID = T.ProcessID AND R.ProcessNo = T.ProcessNo AND R.FiscalYear = T.FiscalYear AND R.SerialNo = T.SerialNo AND R.BaseProcessID = 600
		    WHERE ' + @StrWhere + '
		) T	
		GROUP BY XToolID, XOperatorID, XProductID,T.ProductWidth,T.ProductHeight,T.ProductQuantity2 
	) S ' + @tool_join + '
		LEFT  JOIN prs.vwPersonnelsHD P ON P.PersonnelID = S.OperatorID AND P.LanguageID = ' + @LangID + '
		ORDER BY ToolID, OperatorID, ProductID'
   	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
