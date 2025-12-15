USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/04/17
-- Viewed By	 : 
-- Last Modified : 1389/04/20
-- Last Modifier : TakroSystem\Zia
-- Description	 : نمایش درختی مانده سفارشات
-- ==============================================
Create PROCEDURE [pln].[RptPln_ProduceOrderRemainTree]
	@ProcSetFr		VarChar(20) = Null,
	@ProcSetTo		VarChar(20) = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SelectedProds	int = 0,
	@RepOptions		VarChar(10) = '1',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare @StrSelect	nvarchar(4000)
declare @StrWhere	nvarchar(4000)
declare @StrFrom	nvarchar(4000)

declare	@ProcessID		Int;
declare	@ProcessNo		Int;
declare	@FiscalYearFr	Int;
declare	@SerialNoFr		Int;
declare	@FiscalYearTo	Int;
declare	@SerialNoTo		Int;

declare	@LangID		char(1);
declare	@SessionNo	Int; 
declare	@ReportID	Int; 
declare	@FirstStep	varchar(20); 
declare	@LastStep	varchar(20); 
declare	@IsFinished bit; 

begin
	SET NOCOUNT ON;

	-- init --------------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '1';

	If (@FiscalYearFr Is Null)	SET @SerialNoFr = 0;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo = 0;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = 0;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = 0;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @IsFinished	=substring(@RepOptions,1,1);

	if (@ProcSetFr Is Not Null)
	begin
		set @ProcessID		= pub.funSplitString(@ProcSetFr, '@', 1);
		set @ProcessNo		= pub.funSplitString(@ProcSetFr, '@', 2);
		set @FiscalYearFr	= pub.funSplitString(@ProcSetFr, '@', 3);
		set @SerialNoFr		= pub.funSplitString(@ProcSetFr, '@', 4);
	end

	if (@ProcSetTo Is Not Null)
	begin
		set @ProcessID		= pub.funSplitString(@ProcSetTo, '@', 1);
		set @ProcessNo		= pub.funSplitString(@ProcSetTo, '@', 2);
		set @FiscalYearTo	= pub.funSplitString(@ProcSetTo, '@', 3);
		set @SerialNoTo		= pub.funSplitString(@ProcSetTo, '@', 4);
	end
	----------------------------------------------------------------------------
	-- where -------------------------------------------------------------------
	select @FirstStep = IsNull(Min(ProduceStepID), 0)
	from pln.tblProduceOrderSteps
	where (ProduceStepID <> '')

	select @LastStep = IsNull(ProduceStepID, 0)
	from pln.tblProduceOrderSteps
	where (ProduceStepID <> '') and (IsFinalStep = 1)

	SET @StrWhere = '(H.ProcessID = 600) and (H.ProduceStepID = ''' + @FirstStep + ''' or (H.ProduceStepID <> ''' + @FirstStep + ''' and H.BaseSerialNo > 0))'

	if (@ProcSetFr Is Not Null) and @SerialNoFr>0
		set @StrWhere = @StrWhere + ' and (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' and D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	if (@ProcSetTo Is Not Null) and @SerialNoTo>0
		set @StrWhere = @StrWhere + ' and (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' and D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	if (@ProcSetFr Is Not Null) Or (@ProcSetTo Is Not Null)
		if (@ProcessNo > 0)
			set @StrWhere = @StrWhere + ' and (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')' 

	if (@SelectedProds > 0)
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D.ProductID')
	
	if (@DocDateFr Is Not Null) 
		set @StrWhere = @StrWhere + ' and (H.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo Is Not Null) 
		set @StrWhere = @StrWhere + ' and (H.DocDate <= ''' + @DocDateTo + ''')'
	
	if (@IsFinished =0) 
		set @StrWhere = @StrWhere + ' and H.IsFinished =0'
			
	----------------------------------------------------------------------------
	-- select ------------------------------------------------------------------
	set @StrSelect = '
	select D.ProcessNo, PI.ProcessName, H.ProduceStepID, B.ProduceStepID as BaseProduceStepID, H.Title, B.Title as BaseTitle, D.ProductID, D.ProductCount, 
		D.ProductCount -isnull(GoodsQuantity,0)  Remain, [pub].[funGetGoodsName](D.ProductID,' + @LangID + ') as ProductName,
		LTrim(Str(D.ProcessNo)) + ''_'' + D.ProductID + ''_'' + H.ProduceStepID + ''_'' + H.Title as NodeID,
		LTrim(Str(D.ProcessNo)) + ''_'' + D.ProductID + ''_'' + B.ProduceStepID + ''_'' + B.Title as Parent
	from pln.tblProduceOrderDtl D
			inner join pln.tblProduceOrderHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
			left  join pln.tblProduceOrderHdr B on B.ProcessID = H.BaseProcessID and B.ProcessNo = H.BaseProcessNo and B.FiscalYear = H.BaseFiscalYear and B.SerialNo = H.BaseSerialNo
			left  join pub.tblProcess PI ON PI.ProcessID = H.ProcessID and PI.ProcessNo = H.ProcessNo
			left join pln.tblTaskOrderHdr  t on  t.BaseProcessID=D.ProcessID and t.BaseProcessNo=D.ProcessNo and t.BaseFiscalYear=D.FiscalYear and t.BaseSerialNo=D.SerialNo  and t.BaseDocRowNo=D.DocRowNo and t.ProductID=D.ProductID 
			left join ( select Sum(GoodsQuantity)GoodsQuantity ,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,GoodsID from inv.tblStorageDocsDtl where ProcessID=72 group by BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID ) s on  s.BaseProcessID=t.ProcessID and s.BaseProcessNo=t.ProcessNo and s.BaseFiscalYear=t.FiscalYear and s.BaseSerialNo=t.SerialNo and s.GoodsID=t.ProductID
	where ' + @StrWhere + '
	order by D.ProcessNo, D.ProductID, D.FiscalYear, D.SerialNo, H.ProduceStepID '

    print @StrSelect;
	exec sp_executesql @StrSelect;
	----------------------------------------------------------------------------
End
GO
