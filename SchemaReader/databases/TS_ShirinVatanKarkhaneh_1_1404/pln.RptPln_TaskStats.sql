USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1388/12/11
-- Viewed By	 : 
-- Last Modified : 1389/04/15
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
Create PROCEDURE [pln].[RptPln_TaskStats]
	@TProcessSetFr	VarChar(20)   = Null,
	@TProcessSetTo	VarChar(20)   = Null,
	@OProcessSetFr	VarChar(20)   = Null,
	@OProcessSetTo	VarChar(20)   = Null,
	@DocDateFr		Char(10) 	  = Null,
	@DocDateTo		Char(10) 	  = Null,
	@SelectedTools	Int 		  = 0,
	@SelectedPrsns	Int 		  = 0,
	@SelectedGoods	Int 		  = 0,
	@GroupField		Char(1) 	  = 'T',
	@DetailField	Char(1) 	  = 'P',
	@ExtraParams	NVarChar(100) = '1,2,3,4,7',
	@RepOptions		VarChar(10)	  = '1',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000)
DECLARE @StrWhere	NVarChar(4000)
DECLARE @StrWhereB	NVarChar(4000)
DECLARE @StrWhereStorage	NVarChar(4000)
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
DECLARE	@GroupFieldList	NVarChar(1000);
DECLARE	@SortFieldList	NVarChar(1000);
DECLARE	@Status			VarChar(20);
DECLARE	@Serials		VarChar(300);
DECLARE	@StrDB0000		VarChar(100);

DECLARE	@WSFiscalFr	Int;
DECLARE	@WSSerialFr	Int;
DECLARE	@WSFiscalTo	Int;
DECLARE	@WSSerialTo	Int;

DECLARE	@BatchLeyerNo	Int;
DECLARE	@BatchLeyerLen	Int;
DECLARE	@strBatchNo		NVarChar(500);


DECLARE	@StartTime		Char(5);
DECLARE	@FinishTime		Char(5); 	  
DECLARE	@ProcessIDProduct	Int;

Begin

	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------
	Set @StrDB0000 = LEFT(db_name(), Len(db_name()) - 4) + '0000'
	IF (@RepInfo		Is Null)	SET @RepInfo	 = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	 = '1';
	IF (@ExtraParams	Is Null)	SET @ExtraParams = '1,2,3,4,7';
	IF (@ExtraParams	= '')		SET @ExtraParams = '1,2,3,4,7';

	IF (@SelectedPrsns	Is Null)	SET @SelectedPrsns = 0;
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedTools	Is Null)	SET @SelectedTools = 0;
	IF (@GroupField		Is Null)	SET @GroupField	   = 'T';
	
	IF (@TProcessSetFr Is Not Null)
	BEGIN
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

	SET @Status			= pub.funSplitString(@ExtraParams, '@', 1);
	SET @Serials		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @WSFiscalFr		= pub.funSplitString(@ExtraParams, '@', 3);
	SET @WSSerialFr		= pub.funSplitString(@ExtraParams, '@', 4);
	SET @WSFiscalTo		= pub.funSplitString(@ExtraParams, '@', 5);
	SET @WSSerialTo		= pub.funSplitString(@ExtraParams, '@', 6);	
	SET @BatchLeyerNo	= pub.funSplitString(@ExtraParams, '@', 7);	
	SET @BatchLeyerLen	= pub.funSplitString(@ExtraParams, '@', 8);	
	SET @StartTime	= pub.funSplitString(@ExtraParams, '@', 9);	
	SET @FinishTime	= pub.funSplitString(@ExtraParams, '@', 10);	
	SET @ProcessIDProduct	= pub.funSplitString(@ExtraParams, '@', 11);	
	
	--select @StartTime,@FinishTime
	
	--Print @BatchLeyerNo
	--Print @BatchLeyerLen

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '(TaskStateID in (' + @Status + '))'
	SET @StrWhereB = '1 = 1'
	SET @StrWhereStorage =''
		
	if @ProcessIDProduct=1
		SET @StrWhereStorage =' and ProcessID=72 '

	if (@Serials <> '' and @Serials <> 'null')
		SET @StrWhere = @StrWhere + ' AND (T.SerialNo in (' + LTrim(@Serials) + '))' 

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
	begin
		SET @StrWhereStorage = @StrWhereStorage+ ' AND DocDate>=''' + @DocDateFr + '''' 
		IF (@StartTime Is Not Null and ltrim(rtrim(@StartTime))<>'' )
			SET @StrWhere = @StrWhere + ' AND (( T.StartTime >= ''' + @StartTime + '''  AND T.StartDate = ''' + @DocDateFr + ''') or  (T.StartDate > ''' + @DocDateFr + ''')) '
		else
			SET @StrWhere = @StrWhere + ' AND (T.StartDate >= ''' + @DocDateFr + ''')'
	
	end
	else
		IF (@StartTime Is Not Null and ltrim(rtrim(@StartTime))<>'' )
			SET @StrWhere = @StrWhere + ' AND ( T.StartTime >= ''' + @StartTime + '''  ) '
			
	IF (@DocDateTo Is Not Null)
	begin
		SET @StrWhereStorage = @StrWhereStorage + ' AND DocDate<=''' + @DocDateTo + '''' 
		IF (@FinishTime Is Not Null  and ltrim(rtrim(@FinishTime))<>'')
			SET @StrWhere = @StrWhere + ' AND ((T.FinishTime <= ''' + @FinishTime + ''' AND T.FinishDate = ''' + @DocDateTo + ''') or (T.FinishDate < ''' + @DocDateTo + '''))'
		else
			SET @StrWhere = @StrWhere + ' AND (T.FinishDate <= ''' + @DocDateTo + ''')'
	end
	else
		IF (@FinishTime Is Not Null  and ltrim(rtrim(@FinishTime))<>'')
			SET @StrWhere = @StrWhere + ' AND (T.FinishTime <= ''' + @FinishTime + ''')'
	
	IF (@SelectedTools > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'T.ToolID')
	IF (@SelectedPrsns > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrsns, 'O.OperatorID')
	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'T.ProductID')

	IF (@WSFiscalFr Is Not Null) And (@WSFiscalFr <> '') And (@WSFiscalFr <> '0')
		SET @StrWhereB = @StrWhereB + ' AND (B.BaseFiscalYear > ' + LTrim(Str(@WSFiscalFr)) + ' OR (B.BaseFiscalYear = ' + LTrim(Str(@WSFiscalFr)) + ' AND B.BaseSerialNo >= ' + LTrim(Str(@WSSerialFr)) + '))' 
	IF (@WSFiscalTo Is Not Null) And (@WSFiscalTo <> '') And (@WSFiscalTo <> '0')
		SET @StrWhereB = @StrWhereB + ' AND (B.BaseFiscalYear < ' + LTrim(Str(@WSFiscalTo)) + ' OR (B.BaseFiscalYear = ' + LTrim(Str(@WSFiscalTo)) + ' AND B.BaseSerialNo <= ' + LTrim(Str(@WSSerialTo)) + '))' 		
	
	---------------------------------------------------------------------------
	IF @BatchLeyerLen > 0
		SET @strBatchNo = 'SubString(IsNull(SD.BatchNo,''''), 1, ' + LTrim(RTrim(Str(@BatchLeyerLen))) + ')'
	Else
		SET @strBatchNo = 'IsNull(SD.BatchNo,'''')'
	
	-- G R O U P --------------------------------------------------------------
	If (@GroupField = 'T') Or (@GroupField = 'N') -- N = NO Group
	Begin
		if (@DetailField = 'P')
		begin
			set @GroupFieldList = 'T.ToolID, T.ProductID, T.ProduceStepID,T.ProduceStepName, O.OperatorID,T.ProductWidth,T.ProductHeight,T.ProductQuantity2 ';
			set @SortFieldList	= 'ToolID, ProductID, ProduceStepID,ProduceStepName, OperatorID';
		end
		else
		begin
			set @GroupFieldList = 'T.ToolID, O.OperatorID, T.ProductID, T.ProduceStepID,T.ProduceStepName,T.ProductWidth,T.ProductHeight,T.ProductQuantity2 ';
			set @SortFieldList  = 'ToolID, OperatorID, ProductID, ProduceStepID,ProduceStepName';
		end
	End

	If (@GroupField = 'O')
	Begin
		if (@DetailField = 'P')
		begin
			SET @GroupFieldList = 'O.OperatorID, T.ProductID, T.ProduceStepID,T.ProduceStepName, T.ToolID,T.ProductWidth,T.ProductHeight,T.ProductQuantity2 ';
			SET @SortFieldList  = 'OperatorID, ProductID, ProduceStepID,ProduceStepName, ToolID';
		end
		else
		begin
			SET @GroupFieldList = 'O.OperatorID, T.ToolID, T.ProductID, T.ProduceStepID,T.ProduceStepName,T.ProductWidth,T.ProductHeight,T.ProductQuantity2 ';
			SET @SortFieldList  = 'OperatorID, ToolID, ProductID, ProduceStepID,ProduceStepName';
		end		
	End
	
	If (@GroupField = 'P')
	Begin
		if (@DetailField = 'T')
		begin
			SET @GroupFieldList = 'T.ProductID, T.ProduceStepID,T.ProduceStepName, T.ToolID, O.OperatorID,T.ProductWidth,T.ProductHeight,T.ProductQuantity2 ';
			SET @SortFieldList  = 'ProductID, ProduceStepID,ProduceStepName, ToolID, OperatorID';
		end
		else
		begin
			SET @GroupFieldList = 'T.ProductID, T.ProduceStepID,T.ProduceStepName, O.OperatorID, T.ToolID,T.ProductWidth,T.ProductHeight,T.ProductQuantity2 ';
			SET @SortFieldList  = 'ProductID, ProduceStepID,ProduceStepName, OperatorID, ToolID';
		end
	End

	If (@GroupField = 'C')
	Begin
		if (@DetailField = 'P')
		begin
			SET @GroupFieldList = ltrim(@StrDB0000) + '.[pub].[funGetUserID] (SH.SessionNo), O.OperatorID, T.ProductID, T.ProduceStepID,T.ProduceStepName, 
								  T.ToolID,T.ProductWidth,T.ProductHeight,T.ProductQuantity2 ';
			SET @SortFieldList  = 'ControlerID, ProductID, ProduceStepID,ProduceStepName, ToolID';
		end
		else
		begin
			SET @GroupFieldList = ltrim(@StrDB0000) + '.[pub].[funGetUserID] (SH.SessionNo), O.OperatorID, T.ToolID, T.ProductID, T.ProduceStepID,T.ProduceStepName,T.ProductWidth,T.ProductHeight,T.ProductQuantity2 ';
			SET @SortFieldList  = 'ControlerID, ToolID, ProductID, ProduceStepID,ProduceStepName';
		end		
	End
	
	If (@GroupField = 'B')
	Begin
		if (@DetailField = 'P')
		begin
			SET @GroupFieldList = @strBatchNo + ', O.OperatorID, T.ProductID, T.ProduceStepID,T.ProduceStepName, T.ToolID, T.ProductWidth, 
								   T.ProductHeight, T.ProductQuantity2 ';
			SET @SortFieldList  = 'ISNULL(S.BatchNo,''''), ProductID, ProduceStepID,ProduceStepName, ToolID';
		end
		else
		begin
			SET @GroupFieldList = @strBatchNo + ', O.OperatorID, T.ToolID, T.ProductID, T.ProduceStepID,T.ProduceStepName, T.ProductWidth, 
								   T.ProductHeight, T.ProductQuantity2 ';
			SET @SortFieldList  = 'ISNULL(S.BatchNo,''''), ToolID, ProductID, ProduceStepID,ProduceStepName';
		end		
	End	
		
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	declare @operator_join as nvarchar(500);
	declare @tool_join as nvarchar(500);

	if (@GroupField = 'B') OR (@GroupField = 'C') OR (@GroupField = 'O') OR (@DetailField = 'O')
		set @operator_join = 'INNER JOIN pln.tblTaskOrderOperators O ON O.ProcessID = T.ProcessID AND O.ProcessNo = T.ProcessNo AND O.FiscalYear = T.FiscalYear AND O.SerialNo = T.SerialNo AND O.RowNo = T.RowNo'
	else
		set @operator_join = 'LEFT JOIN pln.tblTaskOrderOperators O ON O.ProcessID = -1 AND O.ProcessNo = -1 AND O.FiscalYear = -1 AND O.SerialNo = -1 AND O.RowNo = -1'

	if (@GroupField = 'T') or (@DetailField = 'T') 
		set @tool_join = 'INNER JOIN pln.tblTools T ON T.ToolID = S.ToolID'
	else
		set @tool_join = 'LEFT  JOIN pln.tblTools T ON T.ToolID = S.ToolID'

	IF (@GroupField <> 'B')
		SET @StrSelect = '
		SELECT S.*, Cast('''' As NVarchar(200)) BatchName, Cast('''' As Varchar(10)) WSFiscalSerial, T.ToolName, P.PersonnelName AS OperatorName, [pub].[funGetGoodsName](S.ProductID,' + @LangID + ') AS ProductName,
				' + ltrim(@StrDB0000) + '.[pub].[funUserName](case when LEN(MobInfo )> 0 THEN pub.funSplitString(MobInfo, ''@'', 1) ELSE -1 END) UserName,
				' + ltrim(@StrDB0000) + '.[pub].[funUserFullName](case when LEN(MobInfo) > 0 THEN pub.funSplitString(MobInfo, ''@'', 1) ELSE -1 END) FullName
				,prs.funGetHourMinutesStandard(TotalTime/60) TotalTimeMinute,prs.funGetHourMinutesStandard((TotalTime-FaultTime-IdleTime) /60) TimeMinute
		FROM
		(
			SELECT	T.ToolID, O.OperatorID, T.ProductID, T.ProduceStepID, MobInfo, '''' BatchNo,
					T.ProductWidth, T.ProductHeight, T.ProductQuantity2,
					Str(' + ltrim(@StrDB0000) + '.[pub].[funGetUserID] (SH.SessionNo)) AS ControlerID, 
					[pub].[GetUserName](SH.SessionNo) AS ControlerName, 
					Sum(T.TotalTime) TotalTime,
					Sum(T.ToolFixTime) ToolFixTime,
					Sum(T.IdleTime) IdleTime,
					Sum(T.FaultTime) FaultTime,
					Sum(T.PrdStepTime * AcceptableCount) StandardTime,
					Sum(AcceptableCount) [Count],
					T.ProduceStepName
			FROM	pln.vwTaskOrderDtl T 
				LEFT JOIN (select * from inv.tblStorageDocsDtl where BaseProcessID=610  and ProcessID=72 and DocRowNo=1 ' +  @StrWhereStorage + ') SD ON T.ProcessID = SD.BaseProcessID And T.ProcessNo = SD.BaseProcessNo And 
													  T.FiscalYear = SD.BaseFiscalYear And T.SerialNo = SD.BaseSerialNo And 
													  T.DocRowNo = SD.BaseDocRowNo
				LEFT JOIN inv.tblStorageDocsHdr SH ON SD.ProcessID = SH.ProcessID And SD.ProcessNo = SH.ProcessNo And 
													   SD.FiscalYear = SH.FiscalYear And SD.SerialNo = SH.SerialNo			
					' + @operator_join + '
				LEFT JOIN pln.tblItemRelations R ON R.ProcessID = T.ProcessID AND R.ProcessNo = T.ProcessNo AND R.FiscalYear = T.FiscalYear AND R.SerialNo = T.SerialNo AND R.BaseProcessID = 600
			WHERE ' + @StrWhere + '
			GROUP BY ' + @GroupFieldList + ', MobInfo,SH.SessionNo
		) S ' + @tool_join + '
			LEFT  JOIN prs.vwPersonnelsHD P ON P.PersonnelID = S.OperatorID AND P.LanguageID = ' + @LangID + '
			ORDER BY ' + @SortFieldList
	ELSE
		SET @StrSelect = '
		SELECT   S.BatchNo, ISNULL(BD.BatchName,'''') BatchName, Cast('''' As Varchar(10)) WSFiscalSerial, S.ToolID, T.ToolName, 0 ProduceStepID,'''' ProduceStepName, ProductID, [pub].[funGetGoodsName](ProductID,' + @LangID + ') AS ProductName, 
				 ControlerID, ControlerName, OperatorID, P.PersonnelName AS OperatorName, '''' MobInfo, 0 ProductWidth, 0 ProductHeight, 
				 0 ProductQuantity2, 0 TotalTime, 0 ToolFixTime, 0 IdleTime, 0 FaultTime, 0 StandardTime, S.Count, 
				 '''' UserName, '''' FullName	,''00:00'' TotalTimeMinute,''00:00''  TimeMinute
		FROM
		(
			SELECT	' + @strBatchNo + ' BatchNo, --Str(B.BaseFiscalYear) + ''/'' + Str(B.BaseSerialNo) WSFiscalSerial, 
					O.OperatorID, T.ProductID, T.ToolID, T.ProduceStepID, '''' MobInfo,	Sum(T.ProductWidth) ProductWidth, 
					Sum(T.ProductHeight) ProductHeight, Sum(T.ProductQuantity2) ProductQuantity2,
					Str(' + ltrim(@StrDB0000) + '.[pub].[funGetUserID] (SH.SessionNo)) AS ControlerID, 
					[pub].[GetUserName](SH.SessionNo) AS ControlerName, 
					Sum(T.TotalTime) TotalTime,
					Sum(T.ToolFixTime) ToolFixTime,
					Sum(T.IdleTime) IdleTime,
					Sum(T.FaultTime) FaultTime,
					Sum(T.PrdStepTime * AcceptableCount) StandardTime,
					Sum(AcceptableCount) [Count],
					T.ProduceStepName
			FROM	pln.vwTaskOrderDtl T 
				LEFT JOIN (select * from inv.tblStorageDocsDtl where BaseProcessID=610 and ProcessID=72  and DocRowNo=1 ' +  @StrWhereStorage + ') SD ON T.ProcessID = SD.BaseProcessID And T.ProcessNo = SD.BaseProcessNo And 
													  T.FiscalYear = SD.BaseFiscalYear And T.SerialNo = SD.BaseSerialNo And 
													  T.DocRowNo = SD.BaseDocRowNo
				LEFT JOIN inv.tblStorageDocsHdr SH ON SD.ProcessID = SH.ProcessID And SD.ProcessNo = SH.ProcessNo And 
													   SD.FiscalYear = SH.FiscalYear And SD.SerialNo = SH.SerialNo			
					' + @operator_join + '
				LEFT JOIN pln.tblItemRelations R ON R.ProcessID = T.ProcessID AND R.ProcessNo = T.ProcessNo AND R.FiscalYear = T.FiscalYear AND R.SerialNo = T.SerialNo AND R.BaseProcessID = 600
			WHERE ' + @StrWhere + '
			GROUP BY ' + @GroupFieldList + ', SH.SessionNo
		) S ' + @tool_join + '
		LEFT  JOIN prs.vwPersonnelsHD P ON P.PersonnelID = S.OperatorID AND P.LanguageID = ' + @LangID + '
		LEFT JOIN inv.tblBatch    B  ON B.BatchNo = S.BatchNo
		LEFT JOIN inv.tblBatchDtl BD ON BD.BatchNo = S.BatchNo
		WHERE ' + @StrWhereB + '	
		GROUP BY S.BatchNo, BD.BatchName, S.ToolID, S.ProductID, ControlerID, ControlerName, S.OperatorID, 
				 T.ToolName, P.PersonnelName, S.Count
		ORDER BY ' + @SortFieldList
				
	---------------------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
	
END
GO
