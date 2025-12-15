USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE pln.SPTaskOrderStandard_2_SHV
	@SerialNoFr  Int,
	@SerialNoTo  Int,
	@CallType    Int,
	@ExtraParams NVarChar(Max) = ''
WITH ENCRYPTION
AS
SET NOCOUNT ON;

BEGIN
DECLARE @StrSelect				NVarChar(max)
DECLARE @StrSelect2				NVarChar(max)
DECLARE @StrSelect3				NVarChar(max)
DECLARE @StrSelect4				NVarChar(max)
DECLARE @StrWhere				NVarChar(max)
DECLARE @StrWhere2				NVarChar(2000)
DECLARE @StrWhere3				NVarChar(2000)
DECLARE @ProductID				NVarChar(2000)
DECLARE @ShiftTypes				NVarChar(2000)
DECLARE @ProductionLines		NVarChar(2000)
DECLARE @ShiftTypes2			NVarChar(2000)
DECLARE @ProductionLines2		NVarChar(2000)
DECLARE @QtyDecimalsToForms		int
DECLARE @TaskSerialNoFR			int
DECLARE @TaskSerialNoTO			int
DECLARE @TaskFiscalYearFR		int
DECLARE @TaskFiscalYearTO		int

DECLARE @ProduceSerialNoFR		int
DECLARE @ProduceSerialNoTO		int
DECLARE @ProduceFiscalYearFR	int
DECLARE @ProduceFiscalYearTO	int

DECLARE @SaleSerialNoFR			int
DECLARE @SaleSerialNoTO			int
DECLARE @SaleFiscalYearFR		int
DECLARE @SaleFiscalYearTO		int

DECLARE @PreSaleSerialNoFR		int
DECLARE @PreSaleSerialNoTO		int
DECLARE @PreSaleFiscalYearFR	int
DECLARE @PreSaleFiscalYearTO	int
DECLARE @Running				char(10)

DECLARE @AcntCode as varchar(20),
@GoodsID as varchar(20),
@StoreID as varchar(20),
@FromDate as varchar(10),
@ToDate as varchar(10),
@ShowOrder as integer,
@Pln_ShowPersonCount bit

select @Pln_ShowPersonCount=SettingValue from pub.tblSettings where SettingKey='Pln_InFrmProduceStepsShowPersonCount'
set @Pln_ShowPersonCount=ISNULL(@Pln_ShowPersonCount,0)

select @QtyDecimalsToForms	=SettingValue from pub.tblSettings where SettingKey='QuantityDecimalsToForms'

update pln.tblTaskOrderHdr set BaseProcessID=b.BaseProcessID  , BaseProcessNo=b.BaseProcessNo  , BaseFiscalYear=b.BaseFiscalYear  , BaseSerialNo=b.BaseSerialNo 
from pln.tblTaskOrderHdr a  
inner join pln.tblItemRelations b on a.ProcessID=b.ProcessID and  a.ProcessNo=b.ProcessNo and  a.FiscalYear=b.FiscalYear and  a.SerialNo=b.SerialNo 
where a.BaseSerialNo=0

	update pln.tblTaskOrderHdr                 
		set ProdDocRowNo=bb.BaseDocRowNo ,BaseDocRowNo=bb.DocRowNo 
    from pln.tblTaskOrderHdr a 
	inner join  pln.tblItemRelations b 
		on b.ProcessID=a.ProcessID  and b.ProcessNo=a.ProcessNo and b.FiscalYear=a.FiscalYear and b.SerialNo=a.SerialNo 
	inner join pln.tblAvailProduceOrders bb 
		on bb.ProcessID=b.BaseProcessID  and bb.ProcessNo=b.BaseProcessNo and bb.FiscalYear=b.BaseFiscalYear and bb.SerialNo=b.BaseSerialNo  and bb.DocRowNo=b.BaseDocRowNo                 
      
Declare @Part as tinyint=1
select @Part=[acc].[FunGetAcntInfoForRemain](1)

if @CallType=2
begin

	DECLARE @ProcessID	int
	DECLARE @ProcessNo	int
	DECLARE @FiscalYear	int
	DECLARE @SerialNo	int

	SET @ProcessID		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ProcessNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @FiscalYear		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @SerialNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 		
	
	select f.ProcessID	,f.ProcessNo	,f.FiscalYear	,f.SerialNo	,f.FaultID
		, pln.funGetFaultName (f.FaultID,1) FaultName,(FaultTime)/60 FaultTime,t.ProduceStepID,ProduceStepName,f.DescDtl
	from pln.tblFaultItems f 
		inner join pln.tblTaskOrderDtl t on f.ProcessID=t.ProcessID and f.ProcessNo=t.ProcessNo and f.FiscalYear=t.FiscalYear and f.SerialNo=t.SerialNo and f.DocRowNo=t.DocRowNo
		inner join pln.tblTaskOrderHdr a on a.ProcessID=t.ProcessID	and a.ProcessNo=t.ProcessNo	and a.FiscalYear=t.FiscalYear and a.SerialNo=t.SerialNo	
		inner join pln.tblProduceStepDtl p1 on a.ProductID=p1.ProductID and p1.SerialNo=a.ProduceStepSerialNo	 and  p1.ProduceStepID=t.ProduceStepID	
	where f.ProcessID=@ProcessID and f.ProcessNo=@ProcessNo	and f.FiscalYear=@FiscalYear	and f.SerialNo=@SerialNo	
	
	union all 
	
	select f.ProcessID	,f.ProcessNo	,f.FiscalYear	,f.SerialNo	,cast(f.IdleTimeID as varchar(20))
		, pln.funGetIdleTimes (f.IdleTimeID,1) FaultName,(IdleTimeValue)/60 FaultTime,t.ProduceStepID,ProduceStepName,IdleTimeName
	from pln.tblTaskOrderIdleTimes f 
		inner join pub.tblIdleTimes ft on f.IdleTimeID=ft.IdleTimeID 
		inner join pln.tblTaskOrderDtl t on f.ProcessID=t.ProcessID and f.ProcessNo=t.ProcessNo and f.FiscalYear=t.FiscalYear and f.SerialNo=t.SerialNo and f.RowNo=t.DocRowNo
		inner join pln.tblTaskOrderHdr a on a.ProcessID=t.ProcessID	and a.ProcessNo=t.ProcessNo	and a.FiscalYear=t.FiscalYear and a.SerialNo=t.SerialNo	
		inner join pln.tblProduceStepDtl p1 on a.ProductID=p1.ProductID and p1.SerialNo=a.ProduceStepSerialNo	 and  p1.ProduceStepID=t.ProduceStepID	
	where f.ProcessID=@ProcessID and f.ProcessNo=@ProcessNo	and f.FiscalYear=@FiscalYear	and f.SerialNo=@SerialNo	
	
end 
if @CallType=1
	begin
		SET @ProductID				= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
		SET @ShiftTypes				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @ShiftTypes2			= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
		SET @ProductionLines		= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
		SET @ProductionLines2		= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 

		SET @TaskFiscalYearFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
		SET @TaskSerialNoFR			= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
		SET @TaskFiscalYearTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SET @TaskSerialNoTO			= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
		
		SET @ProduceFiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
		SET @ProduceSerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
		SET @ProduceFiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
		SET @ProduceSerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 

		SET @FromDate				= LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 
		SET @ToDate					= LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 
		SET @Running				= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 

		set @StrWhere  = ' 1 = 1 '
		set @StrWhere2 = ' 1 = 1 '
		set @StrWhere3  = ''

		if @ProductID<>''
				set @StrWhere =@StrWhere+ @ProductID
		if @ProductionLines<>''
			begin
				set @StrWhere =@StrWhere+ @ProductionLines
				set @StrWhere2 =@StrWhere2+ @ProductionLines2
			end 
			if @ShiftTypes<>''
			begin
				set @StrWhere =@StrWhere+ @ShiftTypes
				set @StrWhere2 = @StrWhere2+@ShiftTypes2
			end 
		if @AcntCode<>'' 
			set @StrWhere = @StrWhere+' AND D.AcntCode  =''' + @AcntCode + ''''		
		if @TaskFiscalYearFR=0 and @TaskFiscalYearTO=0 and @ProduceFiscalYearFR=0 and @ProduceFiscalYearTO=0 and @SaleFiscalYearFR=0 and @SaleFiscalYearTO=0 and @PreSaleFiscalYearFR=0 and @PreSaleFiscalYearTO=0
			set @StrWhere =@StrWhere+ ' AND a.BaseFiscalYear=' +  right (db_name(),4)

		if @TaskFiscalYearFR>0
			set @StrWhere =@StrWhere+ ' AND a.FiscalYear>=' +str(@TaskFiscalYearFR)
		if @TaskSerialNoFR>0
			set @StrWhere = @StrWhere+' AND a.SerialNo  >=' +str(@TaskSerialNoFR)
		if @TaskFiscalYearTO>0
			set @StrWhere =@StrWhere+ ' AND a.FiscalYear<=' +str(@TaskFiscalYearTO)
		if @TaskSerialNoTO>0
			set @StrWhere = @StrWhere+' AND a.SerialNo	<=' +str(@TaskSerialNoTO)
	
		if @ProduceFiscalYearFR>0
			set @StrWhere =@StrWhere+ ' AND a.BaseFiscalYear>=' +str(@ProduceFiscalYearFR)
		if @ProduceSerialNoFR>0
			set @StrWhere = @StrWhere+' AND a.BaseSerialNo  >=' +str(@ProduceSerialNoFR)
		if @ProduceFiscalYearTO>0
			set @StrWhere =@StrWhere+ ' AND a.BaseFiscalYear<=' +str(@ProduceFiscalYearTO)
		if @ProduceSerialNoTO>0
			set @StrWhere = @StrWhere+' AND a.BaseSerialNo	<=' +str(@ProduceSerialNoTO)

		if @FromDate<>''
			begin
				set @StrWhere = @StrWhere+' AND b.StartDate2	>=''' +@FromDate + ''''
				set @StrWhere2 = @StrWhere2+' AND bb.StartDate2	>=''' +@FromDate + ''''
			end 
		if @ToDate<>''
			begin
				set @StrWhere = @StrWhere+' AND b.StartDate2	<=''' +@ToDate + ''''	 
				set @StrWhere2 = @StrWhere2+' AND bb.StartDate2	<=''' +@ToDate + ''''
			end 
		if @Running='1'
			set @StrWhere =@StrWhere+ ' AND a.TaskStateID<>4 '

---------Create Temptable ---------------------------------------------------------------------------------	
	select pub.GetGoodsName (a.ProductID,1) GoodsName, a.DocDate TaskDate,emp.funGetShiftTypeName(b.ShiftTypeID,1) ShiftTypeName,pln.funGetProductionLineName(b.ProductionLineID,1) ProductionLineName
		, c.ProductCount PureWeight, 0 GoodsWeight,c.ProductCount ProductCountStandard,c.ProductCount OperatorCountStandard, c.ProductCount TimeCountStandard, 0 OperatorCountStandard_SHV, 0 TimeCountStandard_SHV
		, c.ProductCount  ProductCount, c.ProductCount OperatorCount, c.ProductCount TimeCount, a.DocDate StartDateMin, a.DocDate FinishDateMax, a.DocDate FinishDate2Max
		, c.ProductCount FaultTime,c.ProductCount IdleTimeValue,a.* 
	into #tblTempStansard 
	from pln.tblTaskOrderHdr  a
		inner join pln.tblTaskOrderDtl b 
			on a.ProcessID=b.ProcessID And a.ProcessNo=b.ProcessNo And a.FiscalYear=b.FiscalYear And a.SerialNo=b.SerialNo
		inner join pln.tblProduceOrderDtl c 
			on a.BaseProcessID=c.ProcessID And a.BaseProcessNo=c.ProcessNo And a.BaseFiscalYear=c.FiscalYear And a.BaseSerialNo=c.SerialNo And a.ProdDocRowNo=c.DocRowNo
	where 1=0 
	select Distinct ProductID ,GoodsName, tbl.DocDate TaskDate	,ShiftTypeName	,ProductionLineName	,PureWeight, 0 GoodsWeight	,ProductCountStandard,ProductCount,OperatorCountStandard,PureWeight ExitCountStandard
		,ProductCount ExitCount,OperatorCount,cast(1 as float) OperatorCountShift ,PureWeight OperatorCountUse	,ProductID + '--'+ StartDateMin  Startdate,ProductID + '--'+ FinishDateMax FinishDate,ProductID + '--'+ FinishDate2Max FinishDate2,TimeCount TimeCountMin
		,PureWeight ProductEffect,PureWeight  ProductEffect2,PureWeight  ProductEffect4, PureWeight ProductEffect3,FaultTime StopTime ,ProcessID,ProcessNo,FiscalYear,SerialNo ,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo , OrderCount,
		1 SalaryDiff,1 OverHeadDiff,1 SalaryOverHeadDiff,1 TotalPaidSalaryOverHead,1 SalaryOverHeadStandard_Pack,1 SalaryOverHeadReal_Pack,1 SalaryOverHeadDiff_Pack, 0 OperatorCountStandard_SHV, 0 TimeCountStandard_SHV
		into #tblTempStansard2
	from  #tblTempStansard  tbl		
	where 1=0 
		select Distinct ProductID ,GoodsName, tbl.DocDate TaskDate	,ShiftTypeName	,ProductionLineName	,PureWeight, 0 GoodsWeight	,ProductCountStandard,ProductCount,OperatorCountStandard,PureWeight ExitCountStandard
		,ProductCount ExitCount,OperatorCount,cast(1 as float) OperatorCountShift ,PureWeight HeadProduct,PureWeight OperatorCountUse	,ProductID + '--'+ StartDateMin  Startdate,ProductID + '--'+ FinishDateMax FinishDate,ProductID + '--'+ FinishDate2Max FinishDate2,TimeCount TimeCountMin
		,PureWeight ProductEffect,PureWeight  ProductEffect2,PureWeight  ProductEffect4, PureWeight ProductEffect3,FaultTime StopTime ,ProcessID,ProcessNo,FiscalYear,SerialNo ,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo , OrderCount,
		cast(1 as bigint) SalaryDiff,cast(1 as bigint) OverHeadDiff,cast(1 as bigint) SalaryOverHeadDiff,cast(1 as bigint) TotalPaidSalaryOverHead,cast(1 as bigint) SalaryOverHeadStandard_Pack,cast(1 as bigint) SalaryOverHeadReal_Pack,
		cast(1 as bigint) SalaryOverHeadDiff_Pack, 0 OperatorCountStandard_SHV, 0 TimeCountStandard_SHV
		into #tblTempStansard3
	from  #tblTempStansard  tbl		
	where 1=0 

------------------------------------------------------------------------------------------	
	set @StrSelect3 = ' (select a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,isnull(b.RowNo,0)RowNo,isnull(b.DocRowNo,0)DocRowNo,isnull(b.ProduceStepID,0)ProduceStepID
			,isnull(b.ProduceStepTime,0)ProduceStepTime,isnull(b.ToolID,'''')ToolID,isnull(b.ToolFixTime,0)ToolFixTime,isnull(b.StartTime,'''')StartTime,isnull(b.FinishTime,'''')FinishTime
			,isnull(b.TotalTime,0)TotalTime,isnull(b.AcceptableCount,0)AcceptableCount,isnull(b.UnacceptableCount,0)UnacceptableCount,isnull(b.OverProduct,0)OverProduct,isnull(b.ProductDeduction,0)ProductDeduction
			,isnull(b.StartDate,'''')StartDate,isnull(b.FinishDate,'''')FinishDate,isnull(b.ProductCostAmount,0)ProductCostAmount,isnull(b.ProduceStepSerialNo,0)ProduceStepSerialNo,isnull(b.StepToolTime,0)StepToolTime	
			,isnull(b.DoingFiscalYear,0)DoingFiscalYear,isnull(b.AcceptStoreID,'''')AcceptStoreID,isnull(b.FailedStoreID,'''')FailedStoreID,isnull(b.UsageStoreID,'''')UsageStoreID,isnull(b.LossStoreID,'''')LossStoreID
			,isnull(b.MobInfo,'''')MobInfo,isnull(b.UserPriceID,0)UserPriceID,isnull(b.ProductCount,0)ProductCount
			, Case when  '+ str(@Pln_ShowPersonCount) +'=1 then ( Select count(Distinct OperatorID) from pln.tblTaskOrderOperators  o where a.ProcessID=o.ProcessID And a.ProcessNo=o.ProcessNo And a.FiscalYear=o.FiscalYear And a.SerialNo=o.SerialNo  ) else isnull(b.PersonCount,0) end  PersonCount
			,isnull(b.ProductionLineID,'''')ProductionLineID,isnull(b.ShiftTypeID,'''')ShiftTypeID,isnull(b.MachineryEquipmentID,'''')MachineryEquipmentID,isnull(b.RepeatCount1,0)RepeatCount1,isnull(b.RepeatCount2,0)RepeatCount2,isnull(b.RepeatCount3,0)RepeatCount3	
			,isnull(b.RepeatCount4,0)RepeatCount4	,isnull( b.DescDtl, '''') DescDtl, isnull( b.Deduct, 0) Deduct,isnull(  b.SubUnitID, '''') SubUnitID, isnull( b.SubUnitQuantity, 0) SubUnitQuantity
            ,'''' PersonelID, 0 ConfirmType, 0 NeedRepeat, 0 NeedStop, 0 DamageAll
			, Case  when ISNull(StartDate,'''') ='''' then   a.DocDate  else (select Min(StartDate) from pln.tblTaskOrderDtl a where  a.ProcessID=b.ProcessID And a.ProcessNo=b.ProcessNo And a.FiscalYear=b.FiscalYear And a.SerialNo=b.SerialNo) end StartDate2
			,isnull(b.FinishTime,'''')FinishTime2,isnull(b.TotalTime,0)TotalTime2,isnull(b.FinishDate,'''')FinishDate2			
		from pln.tblTaskOrderHdr a left join pln.tblTaskOrderDtl b
	  on a.ProcessID=b.ProcessID And a.ProcessNo=b.ProcessNo And a.FiscalYear=b.FiscalYear And a.SerialNo=b.SerialNo ) '
	
	BEGIN TRY
		DROP TABLE #tblTaskOrderDtl
	END TRY
	BEGIN CATCH
	END CATCH 

	select *,StartDate StartDate2 ,FinishTime	FinishTime2	,TotalTime TotalTime2,FinishDate FinishDate2 
	INTO #tblTaskOrderDtl  
	from pln.tblTaskOrderDtl  		
	where 1=0 

	set @StrSelect = ' 
	insert into #tblTaskOrderDtl  
	select b.*
		from pln.tblTaskOrderHdr  a
			left join '+@StrSelect3+' b 
				on a.ProcessID=b.ProcessID And a.ProcessNo=b.ProcessNo And a.FiscalYear=b.FiscalYear And a.SerialNo=b.SerialNo
			inner join pln.tblProduceOrderDtl c 
				on a.BaseProcessID=c.ProcessID And a.BaseProcessNo=c.ProcessNo And a.BaseFiscalYear=c.FiscalYear And a.BaseSerialNo=c.SerialNo And a.ProdDocRowNo=c.DocRowNo
			left join  pln.tblProduceStepHdr s on s.ProductID=c.ProductID and s.SerialNo=c.StepNo
		 		where  ' + @StrWhere +'  and isnull(b.ProcessID,0) <> 0 '
	
	--Print @StrSelect	 
	EXEC sp_executesql @StrSelect;

	if @Running='1'
	begin
		update #tblTaskOrderDtl  
		set TotalTime =isnull(pln.funGetTotalTimeNew(StartDate ,StartTime ,0 ),0)
	
		update #tblTaskOrderDtl  
		set FinishDate =pub.funChangeDate_GergorianToPersian(Getdate())

	
		update #tblTaskOrderDtl  
		set FinishTime =convert (char (5),GETDATE(), 108)
	end 
	
	--select * from #tblTaskOrderDtl 

	set @StrSelect3 = '  #tblTaskOrderDtl '

	set @StrSelect = '
		insert into #tblTempStansard 
		select pub.GetGoodsName (a.ProductID,1) GoodsName, a.DocDate TaskDate,emp.funGetShiftTypeName(c.ShiftTypeID,1) ShiftTypeName
			,pln.funGetProductionLineName(s.ProductionLineID,1) ProductionLineName, (select top 1 PureWeight from inv.tblGoods g where g.GoodsID=a.ProductID) PureWeight, (select top 1 GoodsWeight  from inv.tblGoods g where g.GoodsID=a.ProductID) GoodsWeight
			--,(select top 1 GoodsWeight from inv.tblGoods g where g.GoodsID=a.ProductID) GoodsWeight
			,isnull((select ProductCount from prd.tblFormulasHdr aa where    aa.ProductID=a.ProductID  and aa.SerialNo=a.FormulaNo), 0)                   ProductCountStandard
			
			,isnull((select sum(OperatorCount)   from pln.tblProduceStepDtl aa where aa.ProductID=c.ProductID and aa.SerialNo=c.StepNo), 0)              OperatorCountStandard		
			,isnull((select sum(ProduceStepTime) from pln.tblProduceStepDtl aa where aa.ProductID=a.ProductID and aa.SerialNo=c.StepNo), 0)              TimeCountStandard

			,isnull((select sum(OperatorCount)   from pln.tblProduceStepDtl aa where aa.ProductID=c.ProductID and aa.SerialNo=a.ProduceStepSerialNo), 0) OperatorCountStandard_SHV
			,isnull((select sum(ProduceStepTime) from pln.tblProduceStepDtl aa where aa.ProductID=a.ProductID and aa.SerialNo=a.ProduceStepSerialNo), 0) TimeCountStandard_SHV

			,isnull((select sum(AcceptableCount+UnacceptableCount) from '+@StrSelect3+'  bb where '+@StrWhere2+' and a.ProcessID=bb.ProcessID And a.ProcessNo=bb.ProcessNo And a.FiscalYear=bb.FiscalYear And a.SerialNo=bb.SerialNo),0)ProductCount
			,isnull((select Max(PersonCount)	from '+@StrSelect3+' bb where '+@StrWhere2+' and  a.ProcessID=bb.ProcessID And a.ProcessNo=bb.ProcessNo And a.FiscalYear=bb.FiscalYear And a.SerialNo=bb.SerialNo),0) OperatorCount'
	if @Running = '1'
		set @StrSelect += '	,isnull((select Max(TotalTime) from '+@StrSelect3+' bb where '+@StrWhere2+' and a.ProcessID=bb.ProcessID And a.ProcessNo=bb.ProcessNo And a.FiscalYear=bb.FiscalYear And a.SerialNo=bb.SerialNo),0)TimeCount'
	else
		set @StrSelect += '	,isnull((select Sum(TotalTime) from '+@StrSelect3+' bb where '+@StrWhere2+' and a.ProcessID=bb.ProcessID And a.ProcessNo=bb.ProcessNo And a.FiscalYear=bb.FiscalYear And a.SerialNo=bb.SerialNo),0)TimeCount'

	set @StrSelect += '	
            ,isnull((select min(StartDate) from '+@StrSelect3+'  bb where '+@StrWhere2+' and a.ProcessID=bb.ProcessID And a.ProcessNo=bb.ProcessNo And a.FiscalYear=bb.FiscalYear And a.SerialNo=bb.SerialNo),0)StartDateMin
			,isnull((select max(FinishDate) from '+@StrSelect3+' bb where '+@StrWhere2+' and a.ProcessID=bb.ProcessID And a.ProcessNo=bb.ProcessNo And a.FiscalYear=bb.FiscalYear And a.SerialNo=bb.SerialNo),0)FinishDateMax
			,isnull((select max(FinishDate2) from '+@StrSelect3+' bb where '+@StrWhere2+' and a.ProcessID=bb.ProcessID And a.ProcessNo=bb.ProcessNo And a.FiscalYear=bb.FiscalYear And a.SerialNo=bb.SerialNo),0)FinishDate2Max
			,isnull((select Sum(FaultTime) FROM pln.tblFaultItems bb where  a.ProcessID=bb.ProcessID And a.ProcessNo=bb.ProcessNo And a.FiscalYear=bb.FiscalYear And a.SerialNo=bb.SerialNo),0)FaultTime
			,isnull((select Sum(IdleTimeValue) FROM  pln.tblTaskOrderIdleTimes bb inner join pub.tblIdleTimes aa on aa.IdleTimeID=bb.IdleTimeID where  a.ProcessID=bb.ProcessID And a.ProcessNo=bb.ProcessNo And a.FiscalYear=bb.FiscalYear And a.SerialNo=bb.SerialNo),0)IdleTimeValue	,a.* 
		from pln.tblTaskOrderHdr a
			left join '+@StrSelect3+' b 
				on a.ProcessID=b.ProcessID And a.ProcessNo=b.ProcessNo And a.FiscalYear=b.FiscalYear And a.SerialNo=b.SerialNo
			inner join pln.tblProduceOrderDtl c 
				on a.BaseProcessID=c.ProcessID And a.BaseProcessNo=c.ProcessNo And a.BaseFiscalYear=c.FiscalYear And a.BaseSerialNo=c.SerialNo And a.ProdDocRowNo=c.DocRowNo
			left join  pln.tblProduceStepHdr s 
			on s.ProductID=c.ProductID and s.SerialNo=c.StepNo
		where  ' + @StrWhere 

	--Print @StrSelect	 
	EXEC sp_executesql @StrSelect;

	--select * from  #tblTempStansard 
	
	set @StrSelect = ' insert into #tblTempStansard2
		select --OperatorCountStandard,TimeCountStandard,ProductCountStandard,OperatorCount,TimeCount,ProductCount
			Distinct ProductID, GoodsName, tbl.DocDate TaskDate	,ShiftTypeName	,ProductionLineName	,PureWeight, GoodsWeight
			,case when TimeCountStandard*ProductCountStandard=0 then 0 else TimeCount/cast(TimeCountStandard/ProductCountStandard as  float )end  ProductCountStandard
			,ProductCount,OperatorCountStandard
			,case when TimeCountStandard *ProductCountStandard=0  then 0 else PureWeight*(TimeCount/ TimeCountStandard *ProductCountStandard)/1000 end ExitCountStandard
			,ProductCount*PureWeight/1000  ExitCount,OperatorCount
			,Case when (TimeCount*OperatorCount) =0 then 0 else 
			OperatorCount * ( (TimeCount/60)/720 ) end OperatorCountShift
			, Case when (ProductCount* TimeCountStandard*ProductCountStandard*OperatorCount*OperatorCountStandard) =0 then 0 else 
			OperatorCount-(((ProductCount/OperatorCount)/(TimeCount/Cast(TimeCountStandard/ProductCountStandard as float)/OperatorCountStandard))*OperatorCount) end OperatorCountUse
			-- TimeCount/ProductCount/TimeCountStandard*ProductCountStandard*OperatorCount-OperatorCountStandard end OperatorCountUse
			,isnull((select min(StartTime) from '+@StrSelect3+'  bb where '+@StrWhere2+' and bb.StartDate =tbl.StartDateMin and tbl.ProcessID=bb.ProcessID And tbl.ProcessNo=bb.ProcessNo And tbl.FiscalYear=bb.FiscalYear And tbl.SerialNo=bb.SerialNo),0) + ''--''+ StartDateMin  Startdate
			,isnull((select Max(FinishTime) from '+@StrSelect3+' bb where '+@StrWhere2+' and bb.FinishDate =tbl.FinishDateMax and tbl.ProcessID=bb.ProcessID And tbl.ProcessNo=bb.ProcessNo And tbl.FiscalYear=bb.FiscalYear And tbl.SerialNo=bb.SerialNo),0)+ ''--''+ FinishDateMax  FinishDate
			,isnull((select Max(FinishTime2) from '+@StrSelect3+' bb where '+@StrWhere2+' and bb.FinishDate2 =tbl.FinishDate2Max and tbl.ProcessID=bb.ProcessID And tbl.ProcessNo=bb.ProcessNo And tbl.FiscalYear=bb.FiscalYear And tbl.SerialNo=bb.SerialNo),0)+ ''--''+ FinishDate2Max  FinishDate2
			,TimeCount/60 TimeCountMin
			, case when (OperatorCountStandard* TimeCountStandard) =0 or (TimeCount*OperatorCount*ProductCountStandard)=0 then 0 else ProductCount/((TimeCount*OperatorCount*ProductCountStandard)/(OperatorCountStandard * TimeCountStandard)) end ProductEffect
			, case when ProductCountStandard * TimeCountStandard * TimeCount = 0 then 0 else ProductCount/(TimeCount/cast(TimeCountStandard/ProductCountStandard as  float )) end ProductEffect2
			--, ProductCount/OrderCount ProductEffect4
			, case when ProductCountStandard * TimeCountStandard*TimeCount =0 then 0 else ProductCount/OrderCount end ProductEffect4
			, case when (OperatorCountStandard* TimeCountStandard) = 0 or ((TimeCount-(FaultTime+IdleTimeValue))*OperatorCount*ProductCountStandard)=0 then 0 else ProductCount /(((TimeCount-(FaultTime+IdleTimeValue))*OperatorCount*ProductCountStandard)/(OperatorCountStandard*TimeCountStandard)) end ProductEffect3
			,(FaultTime+IdleTimeValue)/60 StopTime ,ProcessID,ProcessNo,FiscalYear,SerialNo ,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,OrderCount
			,1 SalaryDiff
			,1 OverHeadDiff
			,1 SalaryOverHeadDiff
			,1 TotalPaidSalaryOverHead
			,1 SalaryOverHeadStandard_Pack
			,1 SalaryOverHeadReal_Pack
			,1 SalaryOverHeadDiff_Pack
			,OperatorCountStandard_SHV, TimeCountStandard_SHV
		from  #tblTempStansard  tbl	'

	--Print @StrSelect
	EXEC sp_executesql @StrSelect; 

	--select * from  #tblTempStansard2 

	set @StrSelect = ' 
		 insert into #tblTempStansard3 
		 select
			Distinct ProductID, GoodsName, TaskDate, ShiftTypeName, ProductionLineName,
			cast(round(GoodsWeight,'+str(@QtyDecimalsToForms)+') as float )GoodsWeight,
			cast(round(PureWeight,'+str(@QtyDecimalsToForms)+') as float) PureWeight,
			cast(round(ProductCountStandard,0) as float ) ProductCountStandard,
			cast(round(ProductCount,'+str(@QtyDecimalsToForms)+') as float) ProductCount,
			cast(round(OperatorCountStandard,'+str(@QtyDecimalsToForms)+') as float ) OperatorCountStandard,
			cast(round(ExitCountStandard,'+str(@QtyDecimalsToForms)+') as float) ExitCountStandard,
			cast(round(ExitCount,'+str(@QtyDecimalsToForms)+') as float) ExitCount,
			cast(round(OperatorCount,'+str(@QtyDecimalsToForms)+') as float) OperatorCount,
			cast(round(OperatorCountShift,'+str(@QtyDecimalsToForms)+') as float) OperatorCountShift,
			cast(round(ExitCount/case when OperatorCount=0 then 1 else OperatorCount end ,'+str(@QtyDecimalsToForms)+') as float) HeadProduct,
			cast(round(OperatorCountUse,'+str(@QtyDecimalsToForms)+') as float) OperatorCountUse,
			Startdate,FinishDate,FinishDate2,
			cast(round(TimeCountMin,'+str(@QtyDecimalsToForms)+') as float)   TimeCountMin,
			cast(round(ProductEffect,'+str(@QtyDecimalsToForms)+') as float)  ProductEffect,
			cast(round(ProductEffect2,'+str(@QtyDecimalsToForms)+') as float) ProductEffect2,
			cast(round(ProductEffect4,'+str(@QtyDecimalsToForms)+') as float) ProductEffect4,
			cast(round(ProductEffect3,'+str(@QtyDecimalsToForms)+') as float) ProductEffect3,
			cast(round(StopTime,'+str(@QtyDecimalsToForms)+') as float) StopTime,
			ProcessID,ProcessNo,FiscalYear,SerialNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,OrderCount,
            ((5150000/720)*TimeCountMin)*(OperatorCountUse * -1) SalaryDiff,
            ((5150000/720)*TimeCountMin)*(OperatorCountUse * -1) * 1.3 OverHeadDiff,
            ((5150000/720)*TimeCountMin)*(OperatorCountUse * -1) * 2.3 SalaryOverHeadDiff,
            ((5150000/720)*TimeCountMin)*(OperatorCount) * 2.3 TotalPaidSalaryOverHead,
            Case when (ProductCountStandard) =0 then 0 else  ((OperatorCountStandard * (5150000/720) * TimeCountMin) / ProductCountStandard ) * 2.3 end SalaryOverHeadStandard_Pack,
            Case when (ProductCountStandard) =0 then 0 else  ((OperatorCount * (5150000/720) * TimeCountMin) / ProductCount ) * 2.3 end SalaryOverHeadReal_Pack,
            Case when (ProductCountStandard) =0 then 0 else  (((OperatorCountStandard * (5150000/720) * TimeCountMin) / ProductCountStandard) * 2.3) - (((OperatorCount * (5150000/720) * TimeCountMin) / ProductCount ) * 2.3) end  SalaryOverHeadDiff_Pack,
			OperatorCountStandard_SHV, TimeCountStandard_SHV
		from  #tblTempStansard2  tbl '

	--Print @StrSelect
	EXEC sp_executesql @StrSelect; 
		  
	--select  * into tblTempStansard3 from #tblTempStansard3
	--select 12,* from  #tblTempStansard3

  declare @LoseGroupID Varchar(50)
  declare @LoseGroupName nVarchar(50)
  declare @Colname Varchar(2000)
  declare @Colname2 Varchar(2000)
  set @Colname=''
  set @Colname2=''
	DECLARE csr CURSOR FOR 
		select LoseGroupID ,LoseGroupName from pln.tblLoseGroupDtl
		where LoseGroupID<>''
	OPEN csr
	FETCH NEXT FROM csr INTO @LoseGroupID,@LoseGroupName

	WHILE @@Fetch_Status = 0
	BEGIN
		set @Colname=@Colname+ ', ['+@LoseGroupID+']'
		set @Colname2=@Colname2+ ', Cast (IsNull(['+@LoseGroupID+'],0) As Float) As ['+@LoseGroupName+']'
		FETCH NEXT FROM csr INTO @LoseGroupID,@LoseGroupName
	END

	CLOSE csr
	DEALLOCATE csr

	-- =======================================================================
	-- ======================================================================= WHERE 3
	-- =======================================================================
	IF @SerialNoFr <> 0 And @SerialNoFr Is Not Null
       SET @StrWhere3 = @StrWhere3 + ' And SerialNo >= ' + LTrim(RTrim(Str(@SerialNoFr)))

	IF @SerialNoTo <> 0 And @SerialNoTo Is Not Null
       SET @StrWhere3 = @StrWhere3 + ' And SerialNo <= ' + LTrim(RTrim(Str(@SerialNoTo)))

	-- =======================================================================
	-- ======================================================================= Last SELECT Init
	-- =======================================================================
	SET @StrSelect = 
	'
		GoodsName ProductName, ProductID, SerialNo, DocDate, ShiftTypeName, ProductionLineName, PureWeight, OrderCount, ExitCountStandard, ExitCount, 
		ProductCountStandard, ProductCount, OperatorCountStandard_SHV OperatorCountStandard, OperatorCount, OperatorCountShift, OperatorCountUse, SalaryDiff, OverHeadDiff, 
		SalaryOverHeadDiff, TotalPaidSalaryOverHead, SalaryOverHeadStandard_Pack, SalaryOverHeadReal_Pack, SalaryOverHeadDiff_Pack ,HeadProduct, 
		TimeCountMin, (ProductCount / Case When ProductCountStandard > 0 Then ProductCountStandard Else 1 End) * 100 ProductEffect4, StopTime'

	SET @StrSelect2 = '
		--ExitCount, ((ExitCount / Case When ExitCountStandard > 0 Then ExitCountStandard Else 1 End) * 100) HHHHHHHHHHHHHHHH,

		Case When ExitCount > 0 And ((ExitCount / Case When ExitCountStandard > 0 Then ExitCountStandard Else 1 End) * 100) > 90 Then
			(((ProductCount / Case When ProductCountStandard > 0 Then ProductCountStandard Else 1 End) * 100) - 90 ) * ((TimeCountMin / 720) * 62500) * OperatorCount
		Else
			0
		End Machinery_Bonus_Per_Line,

		Case When ExitCount > 0 And ((ExitCount / Case When ExitCountStandard > 0 Then ExitCountStandard Else 1 End) * 100) > 90 Then
			(((ProductCount / Case When ProductCountStandard > 0 Then ProductCountStandard Else 1 End) * 100) - 90 ) * ((TimeCountMin / 720) * 62500)
		Else
			0
		End Machinery_Bonus_Per_Person,

		Case When ExitCount > 0 And ((ExitCount / Case When ExitCountStandard > 0 Then ExitCountStandard Else 1 End) * 100) > 90 And
		          OperatorCount < OperatorCountStandard Then
			(7500000 * 0.4) * (TimeCountMin / 720) * ABS(OperatorCount - OperatorCountStandard)
		Else
			0
		End Man_Reserve_Bonus_Line,

		Case When ExitCount > 0 And ((ExitCount / Case When ExitCountStandard > 0 Then ExitCountStandard Else 1 End) * 100) > 90 And
		          OperatorCount < OperatorCountStandard Then
			((7500000 * 0.4) * (TimeCountMin / 720) * ABS(OperatorCount - OperatorCountStandard)) / Case When OperatorCount > 0 Then OperatorCount Else 1 End
		Else
			0
		End Man_Reserve_Bonus_Person,

		Case When ExitCount > 0 And ((ExitCount / Case When ExitCountStandard > 0 Then ExitCountStandard Else 1 End) * 100) > 90 Then
			((((ProductCount / Case When ProductCountStandard > 0 Then ProductCountStandard Else 1 End) * 100) - 90 ) * ((TimeCountMin / 720) * 62500) * OperatorCount) + ((7500000 * 0.4) * (TimeCountMin / 720) * ABS(OperatorCount - OperatorCountStandard))
		Else
			0
		End Total_Lines_Bonus,

		Case When ExitCount > 0 And ((ExitCount / Case When ExitCountStandard > 0 Then ExitCountStandard Else 1 End) * 100) > 90 Then
			((((ProductCount / Case When ProductCountStandard > 0 Then ProductCountStandard Else 1 End) * 100) - 90 ) * ((TimeCountMin / 720) * 62500)) + ((((7500000 * 0.4) * (TimeCountMin / 720) * ABS(OperatorCount - OperatorCountStandard)) / Case When OperatorCount > 0 Then OperatorCount Else 1 End))
		Else
			0
		End Total_Person_Bonus
	'
	-- =======================================================================
	-- ======================================================================= Last SELECT Init
	-- =======================================================================

	-- Select * From #tblTempStansard3

	if len(@Colname) > 0  
	begin
		Select @Colname  = SUBSTRING(@Colname, 2, len(@Colname) - 1)
		Select @Colname2 = SUBSTRING(@Colname2, 2, len(@Colname2) - 1)

	    -- =======================================================================
	    -- ======================================================================= Last SELECT Init
	    -- =======================================================================
        Set @StrSelect = '
    SELECT ' + @StrSelect + ',' + @Colname2 + ',' + @StrSelect2 + '
    FROM 
		(
            SELECT t.*, c.DocDate, LoseGroupID, GoodsQuantity
            FROM  #tblTempStansard3 t
            inner join pln.tblProduceOrderHdr c on t.BaseProcessID=c.ProcessID And t.BaseProcessNo=c.ProcessNo And t.BaseFiscalYear=c.FiscalYear And t.BaseSerialNo=c.SerialNo 
            Left join  inv.tblStorageDocsDtl d on d.BaseProcessID=t.ProcessID and  d.BaseProcessNo=t.ProcessNo and  d.BaseFiscalYear=t.FiscalYear and  d.BaseSerialNo=t.SerialNo						
        ) T2					
        PIVOT 
            (
                SUM(T2.GoodsQuantity )
                    For T2.LoseGroupID In ('+ @Colname +')
            ) AS PVT
    WHERE ExitCount > 0 ' + @StrWhere3 + '
    ORDER BY DocDate, ShiftTypeName, ProductionLineName
	'

        --Print @StrSelect
        EXEC sp_executesql @StrSelect; 

	end 
	else
	begin
		set @StrSelect = '
            SELECT  ' + @StrSelect + '
            FROM 
               (
                 SELECT t.*, c.DocDate, LoseGroupID, GoodsQuantity
                 FROM #tblTempStansard3 t
                 inner join pln.tblProduceOrderHdr c on t.BaseProcessID=c.ProcessID And t.BaseProcessNo=c.ProcessNo And t.BaseFiscalYear=c.FiscalYear And t.BaseSerialNo=c.SerialNo 
                 Left join  inv.tblStorageDocsDtl d on d.BaseProcessID=t.ProcessID and d.BaseProcessNo=t.ProcessNo and d.BaseFiscalYear=t.FiscalYear and d.BaseSerialNo=t.SerialNo						
                ) T2'
					
		--Print @StrSelect
		EXEC sp_executesql @StrSelect; 
	end 

end 
END 

GO
