USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/01/31
-- Viewed By	 : 
-- Last Modified : 1389/04/08
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- =============================================
CREATE PROCEDURE [pln].[RptPln_TaskExecution_Faults]
	@ProcessNoList	varchar(20) = Null,
	@TaskStateList	varchar(20) = Null,
	@SerialSet1Fr	varchar(20) = Null,
	@SerialSet1To	varchar(20) = Null,
	@SerialSet2Fr	varchar(20) = Null,
	@SerialSet2To	varchar(20) = Null,
	@SerialSet3Fr	varchar(20) = Null,
	@SerialSet3To	varchar(20) = Null,
	@StartDateFr	char(10) = Null,
	@StartDateTo	char(10) = Null,
	@SelectedTools	int = Null,
	@SelectedPerns	int = Null,
	@SelectedDepts	int = Null,
	@SelectedGoods  int = Null,
	@ProduceStepID	int = Null,
	@ToolID			varchar(20) = Null,
	@PersonnelID	varchar(20) = Null,
	@DepartmentID	varchar(20) = Null,
	@GoodsID		varchar(20) = Null,
	@RepOptions		varchar(200) = '',
	@RepInfo		varchar(10) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrFrom	NVarChar(2000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

DECLARE	@FiscalYear	NVarChar(20);
DECLARE	@SerialNo	NVarChar(20);
Begin

	-- init -----------------------------------------------
	if (@RepInfo is null) set @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-------------------------------------------------------
	-- filter ---------------------------------------------
	set @StrWhere = '(FI.FaultTime > 0) and (TH.ProcessID = 610)'
	
	if (@ProcessNoList is not null)
		set @StrWhere=@StrWhere + ' and (TH.ProcessNo in (' + @ProcessNoList + '))'
	if (@TaskStateList is not null)
		set @StrWhere=@StrWhere + ' and (TH.TaskStateID in (' + @TaskStateList + '))'

	if (@SerialSet1Fr is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet1Fr, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet1Fr, '@', 2);
		set @StrWhere=@StrWhere + ' and ((TH.ProcessNo<>1) or ((TH.ProcessNo=1) and (TH.FiscalYear>' + @FiscalYear + ' or (TH.FiscalYear=' + @FiscalYear + ' AND TH.SerialNo>=' + @SerialNo + '))))' 
	end
	if (@SerialSet1To is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet1To, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet1To, '@', 2);
		set @StrWhere	= @StrWhere + ' and ((TH.ProcessNo<>1) or ((TH.ProcessNo=1) and (TH.FiscalYear<' + @FiscalYear + ' or (TH.FiscalYear=' + @FiscalYear + ' AND TH.SerialNo<=' + @SerialNo + '))))' 
	end

	if (@SerialSet2Fr is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet2Fr, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet2Fr, '@', 2);
		set @StrWhere	= @StrWhere + ' and ((TH.ProcessNo<>2) or ((TH.ProcessNo=2) and (TH.FiscalYear>' + @FiscalYear + ' or (TH.FiscalYear=' + @FiscalYear + ' AND TH.SerialNo>=' + @SerialNo + '))))' 
	end
	if (@SerialSet2To is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet2To, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet2To, '@', 2);
		set @StrWhere	= @StrWhere + ' and ((TH.ProcessNo<>2) or ((TH.ProcessNo=2) and (TH.FiscalYear<' + @FiscalYear + ' or (TH.FiscalYear=' + @FiscalYear + ' AND TH.SerialNo<=' + @SerialNo + '))))' 
	end

	if (@SerialSet3Fr is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet3Fr, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet3Fr, '@', 2);
		set @StrWhere	= @StrWhere + ' and ( (TH.ProcessNo<>3) or ( (TH.ProcessNo=3) and (TH.FiscalYear>' + @FiscalYear + ' or (TH.FiscalYear=' + @FiscalYear + ' AND TH.SerialNo>=' + @SerialNo + ')) ) )' 
	end
	if (@SerialSet3To is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet3To, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet3To, '@', 2);
		set @StrWhere	= @StrWhere + ' and ( (TH.ProcessNo<>3) or ( (TH.ProcessNo=3) and (TH.FiscalYear<' + @FiscalYear + ' or (TH.FiscalYear=' + @FiscalYear + ' AND TH.SerialNo<=' + @SerialNo + ')) ) )' 
	end

	if (@StartDateFr is not null)
		set @StrWhere = @StrWhere + ' and (TD.StartDate>=''' + @StartDateFr + ''')' 
	if (@StartDateTo is not null)
		set @StrWhere = @StrWhere + ' and (TD.StartDate<=''' + @StartDateTo + ''')' 
	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'TH.ProductID')
	if (@SelectedTools > 0)
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'TD.ToolID')
	if (@SelectedDepts > 0)
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDepts, 'DP.DepartmentID')
--	if (@SelectedPerns > 0)
--		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPerns, '')

	if (@ToolID is not null)
		set @StrWhere = @StrWhere + ' and (TD.ToolID = ''' + @ToolID + ''')' 
	if (@DepartmentID is not null)
		set @StrWhere = @StrWhere + ' and (DP.DepartmentID = ''' + @DepartmentID + ''')' 
	if (@GoodsID is not null)
		set @StrWhere = @StrWhere + ' and (TH.ProductID = ''' + @GoodsID + ''')' 
--	if (@PersonnelID is not null)
--		set @StrWhere = @StrWhere + ' and (TD.ToolID = ''' + @ToolID + ''')' 

	if (@ProduceStepID is not null)
		set @StrWhere = @StrWhere + ' and (TD.ProduceStepID = ' + LTRim(Str(@ProduceStepID)) + ')' 

	set @StrSelect = '
	SELECT	DP.DepartmentID, DP.DepartmentName, 
			TH.ProductID, [pub].[funGetGoodsName](TH.ProductID,' + @LangID + ') AS ProductName,
			ST.ProduceStepID, ST.ProduceStepName,
			FI.FaultID, FI.FaultTime, FD.FaultName,
			ST.OperatorCount, PR.ProcessName,
			pub.funGetTypeText(4, TH.TaskStateID, ' + @LangID + ') AS TaskStateName
	FROM pln.tblFaultItems FI
		INNER JOIN pln.tblTaskOrderDtl	 TD ON TD.ProcessID = FI.ProcessID AND TD.ProcessNo = FI.ProcessNo AND TD.FiscalYear = FI.FiscalYear AND TD.SerialNo = FI.SerialNo AND TD.DocRowNo = FI.DocRowNo 
		INNER JOIN pln.tblTaskOrderHdr	 TH ON TH.ProcessID = TD.ProcessID AND TH.ProcessNo = TD.ProcessNo AND TH.FiscalYear = TD.FiscalYear AND TH.SerialNo = TD.SerialNo 
		INNER JOIN pln.tblProduceStepDtl ST ON ST.ProductID = TH.ProductID AND ST.SerialNo = TD.ProduceStepSerialNo AND ST.ProduceStepID = TD.ProduceStepID 
		LEFT  JOIN prs.tblDepartmentsDtl DP ON DP.DepartmentID = ST.DepartmentID
		LEFT  JOIN pln.tblFaults		 FD ON FD.FaultID = FI.FaultID 
		LEFT  JOIN pub.tblProcess		 PR ON PR.ProcessID = TD.ProcessID AND PR.ProcessNo = TH.ProcessNo
	WHERE ' + @StrWhere + '
	ORDER BY DP.DepartmentID, TH.ProductID, ST.ProduceStepID, FI.FaultID '
	-------------------------------------------------------------------------------------
	-- run ------------------------------------------------------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
	-------------------------------------------------------------------------------------
End
GO
