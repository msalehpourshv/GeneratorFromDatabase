USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/10/06
-- Viewed By	 : 
-- Last Modified : 1389/11/20
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [pln].[RptPln_TaskList_Grouped]
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
DECLARE	@Status			VarChar(20);
DECLARE	@Serials		varchar(300);

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
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	DECLARE @UnitPart tinyint
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '(TaskStateID in (' + @Status + '))'
	
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
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDepts, 'SD.DepartmentID')

	--IF (@SelectedTools > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'H.ToolID')
	--IF (@SelectedPrsns > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrsns, 'O.OperatorID')

	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	select H.*, [pub].[funGetGoodsName](H.ProductID,' + @LangID + ') AS ProductName, T.DepartmentID, D.DepartmentName, GH.GoodsLength, GH.GoodsWidth, GH.GoodsHeight,
		T.SumOperTime * OrderCount as SumTimeOper, T.SumStepTime * OrderCount as SumTimeStep,
		T.BaseSerialNo
	from
	(
		SELECT  H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, SD.DepartmentID,
			isnull(sum(LastProduceStepTime * OperatorCount), 0)	SumOperTime,
			isnull(sum(LastProduceStepTime), 0) SumStepTime, R.BaseSerialNo
		FROM	pln.tblTaskOrderHdr H 
				inner join pln.tblProduceStepHdr SH on (SH.ProductID = H.ProductID) and (SH.SerialNo = H.ProduceStepSerialNo)
				inner join pln.tblProduceStepDtl SD on (SD.ProductID = SH.ProductID) and (SD.SerialNo = SH.SerialNo)
				left  join pln.tblItemRelations  R  on (R.ProcessID = H.ProcessID) AND (R.ProcessNo = H.ProcessNo) AND (R.FiscalYear = H.FiscalYear) AND (R.SerialNo = H.SerialNo) AND (R.BaseProcessID = 600)
		WHERE ' + @StrWhere + '
		GROUP BY H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, SD.DepartmentID, R.BaseSerialNo
	) T 
		inner join pln.tblTaskOrderHdr H on (T.ProcessID = H.ProcessID) AND (T.ProcessNo = H.ProcessNo) AND (T.FiscalYear = H.FiscalYear) AND (T.SerialNo = H.SerialNo)
		left  join inv.tblGoods   GH ON GH.GoodsID = SUBSTRING(H.ProductID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		left  join prs.tblDepartmentsDtl D ON (D.DepartmentID = T.DepartmentID)
	ORDER BY ' + @SortFields
   	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
