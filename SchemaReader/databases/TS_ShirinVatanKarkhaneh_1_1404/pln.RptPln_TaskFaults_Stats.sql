USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1392/08/16
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE [pln].[RptPln_TaskFaults_Stats]
	@TProcessSetFr	VarChar(20) = Null,
	@TProcessSetTo	VarChar(20) = Null,
	@OProcessSetFr	VarChar(20) = Null,
	@OProcessSetTo	VarChar(20) = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@StartDateFr	Char(10) = Null,
	@StartDateTo	Char(10) = Null,
	@FinishDateFr	Char(10) = Null,
	@FinishDateTo	Char(10) = Null,
	@SelectedTools	Int = 0, -- dont use it
	@SelectedPrsns	Int = 0, -- dont use it
	@SelectedGoods	Int = 0,
	@SelectedDepts	Int = 0,
	@TaskStatus		VarChar(20) = '1,2,3,4,7',
	@SortFields		NVarChar(100) = Null,
	@ExtraParams	NVarChar(100) = '',
	@RepOptions		VarChar(10) = '',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)

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
Begin

	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '11';

	IF (@SelectedPrsns	Is Null)	SET @SelectedPrsns = 0;
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedTools	Is Null)	SET @SelectedTools = 0;
	IF (@SortFields		Is Null)	SET @SortFields = 'ProductID, StartDate, SerialNo, ProduceStepID, DocRowNo';

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

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '(H.TaskStateID in (' + @TaskStatus + '))'

	IF (@TProcessSetFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@TFiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@TFiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@TSerialNoFr)) + '))' 
	IF (@TProcessSetTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@TFiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@TFiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@TSerialNoTo)) + '))' 
	IF (@TProcessSetFr Is Not Null) Or (@TProcessSetTo Is Not Null)
		If (@TProcessNo > 0)
			SET @StrWhere = @StrWhere + ' AND (H.ProcessNo = ' + LTrim(Str(@TProcessNo)) + ')' 

	IF (@OProcessSetFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (R.BaseFiscalYear > ' + LTrim(Str(@OFiscalYearFr)) + ' OR (R.BaseFiscalYear = ' + LTrim(Str(@OFiscalYearFr)) + ' AND R.BaseSerialNo >= ' + LTrim(Str(@OSerialNoFr)) + '))' 
	IF (@OProcessSetTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (R.BaseFiscalYear < ' + LTrim(Str(@OFiscalYearTo)) + ' OR (R.BaseFiscalYear = ' + LTrim(Str(@OFiscalYearTo)) + ' AND R.BaseSerialNo <= ' + LTrim(Str(@OSerialNoTo)) + '))' 
	IF (@OProcessSetFr Is Not Null) Or (@OProcessSetTo Is Not Null)
		If (@OProcessNo > 0)
			SET @StrWhere = @StrWhere + ' AND (R.BaseProcessNo = ' + LTrim(Str(@OProcessNo)) + ')' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	IF (@StartDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.StartDate >= ''' + @StartDateFr + ''')'
	IF (@StartDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.StartDate <= ''' + @StartDateTo + ''')'

	IF (@FinishDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FinishDate >= ''' + @FinishDateFr + ''')'
	IF (@FinishDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FinishDate <= ''' + @FinishDateTo + ''')'

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.ProductID')
	--IF (@SelectedDepts > 0)
	--	SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDepts, 'SD.DepartmentID')
	--IF (@SelectedTools > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'D.ToolID')
	--IF (@SelectedPrsns > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrsns, 'O.OperatorID')
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	select T.ProductID, T.FiscalYear, T.SerialNo, T.ProduceStepID, T.StartDate, T.TotalTime, 
			T.ProductCount, P.GoodsName ProductName, SD.LastProduceStepTime StandardTime, 
			SH.ProduceMethodName, T.ExecCount, SD.ProduceStepName
	from
	(
		select  H.ProductID, H.FiscalYear, H.SerialNo, D.ProduceStepID, D.ProduceStepSerialNo,
				D.StartDate,  D.TotalTime, isnull((I.GoodsQuantity), 0) ProductCount, 
				isnull(D.AcceptableCount+D.UnacceptableCount,0) ExecCount
		from	pln.tblTaskOrderDtl D
					inner join pln.tblTaskOrderHdr H on H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					left  join pln.tblItemRelations R ON (R.ProcessID = H.ProcessID) AND (R.ProcessNo = H.ProcessNo) AND (R.FiscalYear = H.FiscalYear) AND (R.SerialNo = H.SerialNo) AND (R.BaseProcessID = 600)
					left  join inv.tblStorageDocsDtl I on I.BaseProcessID=D.ProcessID and I.BaseProcessNo=D.ProcessNo and I.BaseFiscalYear=D.FiscalYear and I.BaseSerialNo=D.SerialNo and I.BaseDocRowNo=D.DocRowNo and I.ProcessID=72
		where ' + @StrWhere + '
		--group by H.ProductID, H.FiscalYear, H.SerialNo, D.ProduceStepID, D.ProduceStepSerialNo, D.StartDate, D.TotalTime,D.AcceptableCount,D.UnacceptableCount
	) T 
	  left  join inv.tblGoodsDtl P ON P.GoodsID = T.ProductID
	  inner join pln.tblProduceStepDtl SD ON (SD.ProductID = T.ProductID) AND (SD.SerialNo = T.ProduceStepSerialNo) and (SD.ProduceStepID = T.ProduceStepID)
  	  inner join pln.tblProduceStepHdr SH ON (SH.ProductID = T.ProductID) AND (SH.SerialNo = T.ProduceStepSerialNo) 
	order by ' + @SortFields
   	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
