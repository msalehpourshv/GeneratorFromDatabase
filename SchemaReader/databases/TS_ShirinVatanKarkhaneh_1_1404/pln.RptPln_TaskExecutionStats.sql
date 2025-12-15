USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1389/01/30
-- Viewed By	 : 
-- Last Modified : 1391/01/21
-- Description	 : 
-- =============================================
Create PROCEDURE [pln].[RptPln_TaskExecutionStats]
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
	@RepOptions		varchar(200) = '1',
	@RepInfo		varchar(100)  = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrFrom	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

DECLARE	@FiscalYear	NVarChar(20);
DECLARE	@SerialNo	NVarChar(20);
DECLARE	@LastStep	bit;

Begin

	-- init -----------------------------------------------
	if (@RepInfo is null) set @RepInfo = '1@1@1';

	SET @LastStep	= Substring(@RepOptions, 1, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-------------------------------------------------------

	-- Task Executions only -------------------------------
	set @StrWhere='(TaskH.ProcessID=610)'
	
	if (@ProcessNoList is not null)
		set @StrWhere=@StrWhere + ' and (TaskH.ProcessNo in (' + @ProcessNoList + '))'
	if (@TaskStateList is not null)
		set @StrWhere=@StrWhere + ' and (TaskH.TaskStateID in (' + @TaskStateList + '))'

	if (@SerialSet1Fr is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet1Fr, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet1Fr, '@', 2);
		set @StrWhere=@StrWhere + ' and ((TaskH.ProcessNo<>1) or ((TaskH.ProcessNo=1) and (TaskH.FiscalYear>' + @FiscalYear + ' or (TaskH.FiscalYear=' + @FiscalYear + ' AND TaskH.SerialNo>=' + @SerialNo + '))))' 
	end
	if (@SerialSet1To is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet1To, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet1To, '@', 2);
		set @StrWhere	= @StrWhere + ' and ((TaskH.ProcessNo<>1) or ((TaskH.ProcessNo=1) and (TaskH.FiscalYear<' + @FiscalYear + ' or (TaskH.FiscalYear=' + @FiscalYear + ' AND TaskH.SerialNo<=' + @SerialNo + '))))' 
	end

	if (@SerialSet2Fr is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet2Fr, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet2Fr, '@', 2);
		set @StrWhere	= @StrWhere + ' and ((TaskH.ProcessNo<>2) or ((TaskH.ProcessNo=2) and (TaskH.FiscalYear>' + @FiscalYear + ' or (TaskH.FiscalYear=' + @FiscalYear + ' AND TaskH.SerialNo>=' + @SerialNo + '))))' 
	end
	if (@SerialSet2To is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet2To, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet2To, '@', 2);
		set @StrWhere	= @StrWhere + ' and ((TaskH.ProcessNo<>2) or ((TaskH.ProcessNo=2) and (TaskH.FiscalYear<' + @FiscalYear + ' or (TaskH.FiscalYear=' + @FiscalYear + ' AND TaskH.SerialNo<=' + @SerialNo + '))))' 
	end

	if (@SerialSet3Fr is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet3Fr, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet3Fr, '@', 2);
		set @StrWhere	= @StrWhere + ' and ( (TaskH.ProcessNo<>3) or ( (TaskH.ProcessNo=3) and (TaskH.FiscalYear>' + @FiscalYear + ' or (TaskH.FiscalYear=' + @FiscalYear + ' AND TaskH.SerialNo>=' + @SerialNo + ')) ) )' 
	end
	if (@SerialSet3To is not null)
	begin
		set @FiscalYear	= pub.funSplitString(@SerialSet3To, '@', 1);
		set @SerialNo	= pub.funSplitString(@SerialSet3To, '@', 2);
		set @StrWhere	= @StrWhere + ' and ( (TaskH.ProcessNo<>3) or ( (TaskH.ProcessNo=3) and (TaskH.FiscalYear<' + @FiscalYear + ' or (TaskH.FiscalYear=' + @FiscalYear + ' AND TaskH.SerialNo<=' + @SerialNo + ')) ) )' 
	end

	if (@StartDateFr is not null)
		set @StrWhere = @StrWhere + ' and (TaskD.StartDate>=''' + @StartDateFr + ''')' 
	if (@StartDateTo is not null)
		set @StrWhere = @StrWhere + ' and (TaskD.StartDate<=''' + @StartDateTo + ''')' 

	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'TaskH.ProductID')
	if (@SelectedTools > 0)
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'TaskD.ToolID')
	if (@SelectedDepts > 0)
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDepts, 'Dept.DepartmentID')
--	if (@SelectedPerns > 0)
--		set @StrWhere=@StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPerns, '')

	if (@ProduceStepID is not null)
		set @StrWhere = @StrWhere + ' and (TaskD.ProduceStepID=' + LTrim(Str(@ProduceStepID)) + ')' 
		
	select ProductID, SerialNo, MAX(ProduceStepID) ProduceStepID
	into #tbl_Pln_TaskExecutionStats_Last
	from pln.tblProduceStepDtl
	group by ProductID, SerialNo
	
	declare @StrExtra nvarchar(2000);
	
	if (@LastStep = 1)
		set @StrExtra = 'inner join #tbl_Pln_TaskExecutionStats_Last LST on LST.ProductID = TaskH.ProductID and LST.SerialNo = TaskD.ProduceStepSerialNo and LST.ProduceStepID = TaskD.ProduceStepID'
	else
		set @StrExtra = ''

	set @StrSelect='
	SELECT	Whole.DepartmentID, Whole.DepartmentName, Whole.ProductID, Whole.ProductName,
			SUM(Whole.AcceptCount_Prd)	AS AcceptCount_Prd,
			SUM(Whole.FailedCount_Prd)	AS FailedCount_Prd,
			SUM(Whole.AcceptCount_Fix)	AS AcceptCount_Fix,
			SUM(Whole.FailedCount_Fix)	AS FailedCount_Fix,
			SUM(Whole.AcceptCount_Ret)	AS AcceptCount_Ret,
			SUM(Whole.FailedCount_Ret)	AS FailedCount_Ret,
			SUM(Whole.PersOverTime)		AS PersOverTime,
			SUM(Whole.PersTotalTime)	AS PersTotalTime,
			SUM(Whole.ToolFaultTime)	AS ToolFaultTime,
			SUM(Whole.ToolTotalTime)	AS ToolTotalTime,
			SUM(Whole.FaultTotalTime)	AS FaultTotalTime,
			SUM(Whole.OperatorCount)	AS OperatorCount,
			Whole.ProductWidth ,Whole.ProductHeight ,Whole.ProductQuantity2 
	FROM
	(
		select	Dept.DepartmentID,Dept.DepartmentName,TaskH.ProductID,[pub].[funGetGoodsName](TaskH.ProductID,' + @LangID + ') AS ProductName,StepD.ProduceStepID,
		TaskH.ProductWidth ,TaskH.ProductHeight ,TaskH.ProductQuantity2  ,
				CASE WHEN TaskD.ProcessNo=1 THEN TaskD.AcceptableCount   ELSE 0 end AS AcceptCount_Prd,
				CASE WHEN TaskD.ProcessNo=1 THEN TaskD.UnacceptableCount ELSE 0 end AS FailedCount_Prd,
				CASE WHEN TaskD.ProcessNo=2 THEN TaskD.AcceptableCount   ELSE 0 end AS AcceptCount_Fix,
				CASE WHEN TaskD.ProcessNo=2 THEN TaskD.UnacceptableCount ELSE 0 end AS FailedCount_Fix,
				CASE WHEN TaskD.ProcessNo=3 THEN TaskD.AcceptableCount   ELSE 0 end AS AcceptCount_Ret,
				CASE WHEN TaskD.ProcessNo=3 THEN TaskD.UnacceptableCount ELSE 0 end AS FailedCount_Ret,
				(0) AS PersOverTime, 
				TaskD.TotalTime AS PersTotalTime,
				CASE WHEN (TaskD.ToolID<>'''') and (TaskD.ToolID is not null) THEN TaskD.TotalTime ELSE 0 end AS ToolTotalTime,
				(
					SELECT	ISNULL(SUM(Fault.FaultTime),0)
					FROM	pln.tblFaultItems Fault 
					WHERE	TaskD.ProcessID=Fault.ProcessID AND TaskD.ProcessNo=Fault.ProcessNo AND TaskD.FiscalYear=Fault.FiscalYear AND TaskD.SerialNo=Fault.SerialNo AND TaskD.DocRowNo=Fault.DocRowNo
				) AS FaultTotalTime,
				(
					SELECT	ISNULL(SUM(Fault.FaultTime),0)
					FROM	pln.tblFaultItems Fault 
					WHERE	TaskD.ProcessID=Fault.ProcessID AND TaskD.ProcessNo=Fault.ProcessNo AND TaskD.FiscalYear=Fault.FiscalYear AND TaskD.SerialNo=Fault.SerialNo AND TaskD.DocRowNo=Fault.DocRowNo AND (TaskD.ToolID <> '''') and (TaskD.ToolID is not null)
				) AS ToolFaultTime,
				StepD.OperatorCount 
		from pln.tblProduceStepDtl StepD
			LEFT OUTER JOIN prs.tblDepartmentsDtl Dept ON Dept.DepartmentID=StepD.DepartmentID		
			INNER JOIN pln.tblTaskOrderHdr TaskH ON TaskH.ProductID=StepD.ProductID AND TaskH.ProduceStepSerialNo=StepD.SerialNo  
			INNER JOIN pln.tblTaskOrderDtl TaskD ON TaskD.ProcessID=TaskH.ProcessID AND TaskD.ProcessNo=TaskH.ProcessNo AND	TaskD.FiscalYear=TaskH.FiscalYear AND TaskD.SerialNo=TaskH.SerialNo AND TaskD.ProduceStepID=StepD.ProduceStepID AND TaskD.ProduceStepSerialNo=StepD.SerialNo
			' + @StrExtra + '
		where ' + @StrWhere + '
	) AS Whole
	GROUP BY Whole.DepartmentID, Whole.DepartmentName, Whole.ProductID, Whole.ProductName ,Whole.ProductWidth ,Whole.ProductHeight ,Whole.ProductQuantity2 
	ORDER BY Whole.DepartmentID, Whole.DepartmentName, Whole.ProductID, Whole.ProductName '
	-------------------------------------------------------------------------------------
	-- run ------------------------------------------------------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
	-------------------------------------------------------------------------------------
end
GO
