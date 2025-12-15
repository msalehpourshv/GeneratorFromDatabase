USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/12/12
-- Viewed By	 : 
-- Last Modified : 1391/12/19
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [pln].[RptPln_TaskListDtl_Detailed]
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
	@SelectedTools	Int = 0,
	@SelectedPrsns	Int = 0,
	@SelectedGoods	Int = 0,
	@SelectedDepts	Int = 0,
	@SortFields		NVarChar(100) = Null,
	@ExtraParams	NVarChar(100) = '1,2,3,4,7',
	@RepOptions		VarChar(10) = '11',  -- bit array options
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
DECLARE	@Status			VarChar(20);
DECLARE	@Grouped		bit;
DECLARE	@Serials		varchar(300);
Begin

	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '11';
	IF (@ExtraParams	Is Null)	SET @ExtraParams= '1,2,3,4,7';
	IF (@ExtraParams	= '')		SET @ExtraParams= '1,2,3,4,7';

	IF (@SelectedPrsns	Is Null)	SET @SelectedPrsns = 0;
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedTools	Is Null)	SET @SelectedTools = 0;
	IF (@SortFields		Is Null)	SET @SortFields = 'D.StartDate, D.SerialNo, D.ProduceStepID, D.DocRowNo';

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
	SET @Serials	= pub.funSplitString(@ExtraParams, '@', 2);
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @Grouped	= Substring(@RepOptions, 1, 1);
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '(H.TaskStateID in (' + @Status + '))'

	if (@Serials <> '' and @Serials <> 'null')
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo in (' + LTrim(@Serials) + '))' 

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
	IF (@SelectedDepts > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDepts, 'S.DepartmentID')
	--IF (@SelectedTools > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'D.ToolID')
	--IF (@SelectedPrsns > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrsns, 'O.OperatorID')
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	SELECT  H.*, R.BaseFiscalYear, R.BaseSerialNo,  [pub].[funGetGoodsName](H.ProductID,' + @LangID + ') ProductName, D.ProduceStepID, 
			S.ProduceStepName, D.StartDate, D.FinishDate,D.StartTime, D.FinishTime, D.TotalTime SpentTimeSeconds, 
			[pln].[funGetOpratorName] (D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo) As OperatorName,
			isnull(D.AcceptableCount, 0) CountAccept, isnull(D.UnacceptableCount, 0) CountFailed, 
			pub.funGetTypeText(4, H.TaskStateID, 1) TaskStateName,
			isnull((
				select SUM(FaultTime)
				from pln.tblFaultItems F
				where F.ProcessID=D.ProcessID and F.ProcessNo=D.ProcessNo and F.FiscalYear=D.FiscalYear and F.SerialNo=D.SerialNo and F.DocRowNo=D.DocRowNo
			),0) FaultSecondsVar,
			isnull((
				select SUM(T.IdleTimeValue)
				from pln.tblTaskOrderIdleTimes I
					inner join pub.tblIdleTimes T on T.IdleTimeID = I.IdleTimeID
				where I.ProcessID=D.ProcessID and I.ProcessNo=D.ProcessNo and I.FiscalYear=D.FiscalYear and I.SerialNo=D.SerialNo and I.RowNo=D.DocRowNo
			),0) FaultSecondsFix,
			isnull((
				select top 1 LastProduceStepTime
				from pln.tblProduceStepDtl S
				where S.ProductID=H.ProductID and S.SerialNo=H.ProduceStepSerialNo and S.ProduceStepID = D.ProduceStepID
			),0) StepTimeSeconds, I.FiscalYear InvFiscalYear, I.SerialNo InvSerialNo
	FROM	pln.tblTaskOrderDtl D
				inner join pln.tblTaskOrderHdr H on H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				inner join pln.tblProduceStepDtl S ON (S.ProductID = H.ProductID) AND (S.SerialNo = H.ProduceStepSerialNo) and (S.ProduceStepID = D.ProduceStepID)
				left  join pln.tblItemRelations R ON (R.ProcessID = H.ProcessID) AND (R.ProcessNo = H.ProcessNo) AND (R.FiscalYear = H.FiscalYear) AND (R.SerialNo = H.SerialNo) AND (R.BaseProcessID = 600)
				left  join inv.tblStorageDocsDtl I on I.BaseProcessID=D.ProcessID and I.BaseProcessNo=D.ProcessNo and I.BaseFiscalYear=D.FiscalYear and I.BaseSerialNo=D.SerialNo and I.BaseDocRowNo=D.DocRowNo and I.ProcessID=72
				and H.ProductID=I.GoodsID
	WHERE ' + @StrWhere + '
	ORDER BY ' + @SortFields
   	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
