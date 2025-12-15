USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/09/30
-- Viewed By	 : 
-- Last Modified : 1389/10/05
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [pln].[RptPln_TaskList]
	@TProcessSetFr	VarChar(20) = Null,
	@TProcessSetTo	VarChar(20) = Null,
	@OProcessSetFr	VarChar(20) = Null,
	@OProcessSetTo	VarChar(20) = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SelectedTools	Int = 0,
	@SelectedPrsns	Int = 0,
	@SelectedGoods	Int = 0,
	@SelectedDepts	Int = 0,
	@SortFields		NVarChar(100) = Null,
	@ExtraParams	NVarChar(100) = '1,2,3,4,7',
	@RepOptions		VarChar(10) = '1',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect					NVarChar(4000)
DECLARE @StrWhere					NVarChar(4000)
DECLARE @StrFrom					NVarChar(4000)
DECLARE @StrWhereD					NVarChar(4000)

DECLARE	@LangID						Char(1);
DECLARE	@SessionNo					Int; 
DECLARE	@ReportID					Int; 

DECLARE	@TProcessID					Int;
DECLARE	@TProcessNo					Int;
DECLARE	@TFiscalYearFr				Int;
DECLARE	@TSerialNoFr				Int;
DECLARE	@TFiscalYearTo				Int;
DECLARE	@TSerialNoTo				Int;
DECLARE	@OProcessID					Int;
DECLARE	@OProcessNo					Int;
DECLARE	@OFiscalYearFr				Int;
DECLARE	@OSerialNoFr				Int;
DECLARE	@OFiscalYearTo				Int;
DECLARE	@OSerialNoTo				Int;
DECLARE	@Status						VarChar(100);
DECLARE	@Serials					varchar(300);

DECLARE @ShowFinishedDeliveryDate	BIT;
DECLARE	@CurrentDate				Char(10);

Begin

	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '1';
	IF (@ExtraParams	Is Null)	SET @ExtraParams= '1,2,3,4,7';
	IF (@ExtraParams	= '')		SET @ExtraParams= '1,2,3,4,7';

	SET @ShowFinishedDeliveryDate	= Substring(@RepOptions, 1, 1);

	IF (@SelectedPrsns	Is Null)	SET @SelectedPrsns = 0;
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedTools	Is Null)	SET @SelectedTools = 0;
	IF (@SortFields		Is Null)	SET @SortFields = 'H.SerialNo';

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
	SET @CurrentDate= pub.funSplitString(@ExtraParams, '@', 3);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '(TaskStateID in (' + @Status + '))'
	SET @StrWhereD = '(DP.ProductID = H.ProductID)'

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

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.ProductID')
	IF (@SelectedDepts > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDepts, 'DP.DepartmentID')

	IF (@SelectedDepts > 0)
		SET @StrWhere = @StrWhere + ' AND ((select count(*) from pln.tblProduceStepDtl DP where ' + @StrWhereD + ') > 0)'

	IF @ShowFinishedDeliveryDate = 1 
		SET @StrWhere = @StrWhere + ' AND (H.DeliverDate <> '''' And H.DeliverDate < ''' + LTrim(RTrim(@CurrentDate)) + ''')' 

	--IF (@SelectedTools > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'H.ToolID')
	--IF (@SelectedPrsns > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrsns, 'O.OperatorID')

	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	SELECT  H.*, [pub].[funGetGoodsName](H.ProductID,' + @LangID + ') as ProductName, P.ProcessName,
			R.BaseProcessID, R.BaseProcessNo, R.BaseFiscalYear, R.BaseSerialNo As ProduceOrderSerialNo,
			isnull((
				select sum(LastProduceStepTime * OperatorCount)
				from pln.tblProduceStepDtl SD
						inner join pln.tblProduceStepHdr SH on (SH.ProductID = SD.ProductID) and (SH.SerialNo = SD.SerialNo) and (SH.IsDefaultMethod = 1)
				where SD.ProductID = H.ProductID 
			), 0) * OrderCount SumOperTime,
			isnull((
				select sum(LastProduceStepTime)
				from pln.tblProduceStepDtl SD
						inner join pln.tblProduceStepHdr SH on (SH.ProductID = SD.ProductID) and (SH.SerialNo = SD.SerialNo) and (SH.IsDefaultMethod = 1)
				where SD.ProductID = H.ProductID 
			), 0) * OrderCount SumTime
	FROM	pln.tblTaskOrderHdr H 
				left join pln.tblItemRelations R ON (R.ProcessID = H.ProcessID) AND (R.ProcessNo = H.ProcessNo) AND (R.FiscalYear = H.FiscalYear) AND (R.SerialNo = H.SerialNo) AND (R.BaseProcessID = 600)
				left join pub.tblProcess P on P.ProcessID=H.ProcessID and P.ProcessNo=H.ProcessNo
	WHERE ' + @StrWhere + '
	ORDER BY ' + @SortFields
   	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
