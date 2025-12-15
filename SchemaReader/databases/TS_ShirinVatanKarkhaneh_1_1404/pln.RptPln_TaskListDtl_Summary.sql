USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/10/01
-- Viewed By	 : 
-- Last Modified : 1394/02/23
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [pln].[RptPln_TaskListDtl_Summary]
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
	@ExtraParams	NVarChar(Max) = '',
	@RepOptions		VarChar(10) = '11',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(Max)
DECLARE @StrWhereD	NVarChar(Max)
DECLARE @StrWhereH	NVarChar(Max)
DECLARE @StrFrom	NVarChar(Max)

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
DECLARE	@AllRows		bit;
DECLARE	@Serials		varchar(300);
DECLARE	@SelectedPrdrs	int;
DECLARE	@FormulaList	varchar(max);

Begin

	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '11';
	IF (@ExtraParams	Is Null)	SET @ExtraParams= '1,2,3,4,7@0@0';
	IF (@ExtraParams	= '')		SET @ExtraParams= '1,2,3,4,7@0@0';
	
	IF (@SelectedPrsns	Is Null)	SET @SelectedPrsns = 0;
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedTools	Is Null)	SET @SelectedTools = 0;
	IF (@SortFields		Is Null)	SET @SortFields = 'SerialNo, ProduceStepID';

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
	
	SET @Status			= pub.funSplitString(@ExtraParams, '@', 1);
	SET @Serials		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @SelectedPrdrs	= pub.funSplitString(@ExtraParams, '@', 3);
	SET @FormulaList	= pub.funSplitString(@ExtraParams, '@', 4);	

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @AllRows	= Substring(@RepOptions, 1, 1);
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhereH = '(H.TaskStateID in (' + @Status + '))'
	SET @StrWhereD = '(1=1)'
	
	if (@Serials is not null and @Serials <> '' and @Serials <> 'null')
		SET @StrWhereH = @StrWhereH + ' AND (H.SerialNo in (' + LTrim(@Serials) + '))' 

	IF (@TProcessSetFr Is Not Null)
		SET @StrWhereH = @StrWhereH + ' AND (H.FiscalYear > ' + LTrim(Str(@TFiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@TFiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@TSerialNoFr)) + '))' 
	IF (@TProcessSetTo Is Not Null)
		SET @StrWhereH = @StrWhereH + ' AND (H.FiscalYear < ' + LTrim(Str(@TFiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@TFiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@TSerialNoTo)) + '))' 
	IF (@TProcessSetFr Is Not Null) Or (@TProcessSetTo Is Not Null)
		If (@TProcessNo > 0)
			SET @StrWhereH = @StrWhereH + ' AND (H.ProcessNo = ' + LTrim(Str(@TProcessNo)) + ')' 

	IF (@OProcessSetFr Is Not Null)
		SET @StrWhereH = @StrWhereH + ' AND (R.BaseFiscalYear > ' + LTrim(Str(@OFiscalYearFr)) + ' OR (R.BaseFiscalYear = ' + LTrim(Str(@OFiscalYearFr)) + ' AND R.BaseSerialNo >= ' + LTrim(Str(@OSerialNoFr)) + '))' 
	IF (@OProcessSetTo Is Not Null)
		SET @StrWhereH = @StrWhereH + ' AND (R.BaseFiscalYear < ' + LTrim(Str(@OFiscalYearTo)) + ' OR (R.BaseFiscalYear = ' + LTrim(Str(@OFiscalYearTo)) + ' AND R.BaseSerialNo <= ' + LTrim(Str(@OSerialNoTo)) + '))' 
	IF (@OProcessSetFr Is Not Null) Or (@OProcessSetTo Is Not Null)
		If (@OProcessNo > 0)
			SET @StrWhereH = @StrWhereH + ' AND (R.BaseProcessNo = ' + LTrim(Str(@OProcessNo)) + ')' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhereH = @StrWhereH + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null)
		SET @StrWhereH = @StrWhereH + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	IF (@StartDateFr Is Not Null)
		SET @StrWhereH = @StrWhereH + ' AND (D.StartDate >= ''' + @StartDateFr + ''')'
	IF (@StartDateTo Is Not Null)
		SET @StrWhereH = @StrWhereH + ' AND (D.StartDate <= ''' + @StartDateTo + ''')'

	IF (@FinishDateFr Is Not Null)
		SET @StrWhereH = @StrWhereH + ' AND (D.FinishDate >= ''' + @FinishDateFr + ''')'
	IF (@FinishDateTo Is Not Null)
		SET @StrWhereH = @StrWhereH + ' AND (D.FinishDate <= ''' + @FinishDateTo + ''')'

	IF (@SelectedGoods > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.ProductID')
	IF (@SelectedDepts > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDepts, 'S.DepartmentID')
	--IF (@SelectedTools > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'D.ToolID')
	--IF (@SelectedPrsns > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrsns, 'O.OperatorID')
	if (@AllRows <> 1)
		SET @StrWhereH = @StrWhereH + ' AND (CountAccept + CountFailed > 0)'
		
	If (@SelectedPrdrs > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrdrs, 'H.ProducerAcntCode')
	if (@FormulaList is not null and @FormulaList <> '' and @FormulaList <> 'null')
		set @StrWhereH = @StrWhereH + ' AND H.FormulaNo in (' + @FormulaList + ')'
		
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	select T.*, P.FirstName + '' '' + LastName OperatorName from (
	SELECT  H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.ProduceStepSerialNo, H.DocDate, 
			H.ProductID, H.OrderCount, H.BatchNo, H.TaskStateID, R.BaseFiscalYear, R.BaseSerialNo,
			isnull(D.CountAccept, 0) CountAccept, isnull(D.CountFailed, 0) CountFailed,
			IsNull(D.UsageStoreID,'''') As UsageStoreID,IsNull(D.AcceptStoreID,'''') As AcceptStoreID, 
			PH.Title, [pub].[funGetGoodsName](H.ProductID,' + @LangID + ') AS ProductName, S.ProduceStepID, S.ProduceStepName, S.ProduceStepTime, H.FormulaNo,
			pub.funGetTypeText(4, H.TaskStateID, 1) TaskStateName, DP.DepartmentName, F.FormulaName,
			pub.GetCodeName(H.ProducerAcntCode, 1) ProducerAcntName, H.ProducerAcntCode,
			PH.BaseFiscalYear POBaseFiscalYear, PH.BaseSerialNo POBaseSerialNo, H.VchNo,
			(select top 1 StartDate from pln.tblTaskOrderDtl D where D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo) StartDate,
			(select top 1 OperatorID from pln.tblTaskOrderOperators O where O.FiscalYear=H.FiscalYear and O.SerialNo=H.SerialNo) OperatorID
	FROM	pln.tblTaskOrderHdr H 
				inner join pln.tblProduceStepDtl S ON (S.ProductID = H.ProductID) AND (S.SerialNo = H.ProduceStepSerialNo) 
				left join
				(
					SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, StartDate, ProduceStepID, UsageStoreID, AcceptStoreID,
						   ISNULL(sum(AcceptableCount), 0) CountAccept, isnull(sum(UnacceptableCount), 0) CountFailed
					FROM pln.tblTaskOrderDtl D
					WHERE ' + @StrWhereD + '
					GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo, StartDate, ProduceStepID, UsageStoreID, AcceptStoreID
					
				) D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo and D.ProduceStepID = S.ProduceStepID
				left join prs.tblDepartmentsDtl DP ON DP.DepartmentID = S.DepartmentID
				left join prd.tblFormulasHdr F ON F.ProductID = H.ProductID and F.SerialNo = H.FormulaNo
				left join pln.tblItemRelations R ON (R.ProcessID = H.ProcessID) AND (R.ProcessNo = H.ProcessNo) AND (R.FiscalYear = H.FiscalYear) AND (R.SerialNo = H.SerialNo) AND (R.BaseProcessID = 600)
				left join pln.tblProduceOrderHdr PH ON R.BaseProcessID = PH.ProcessID And R.BaseProcessNo = PH.ProcessNo AND R.BaseFiscalYear = PH.FiscalYear AND R.BaseSerialNo = PH.SerialNo
	
	WHERE ' + @StrWhereH + '
	) T	left join prs.tblPersonnelsDtl P on P.PersonnelID = T.OperatorID
	ORDER BY ' + @SortFields
   	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
