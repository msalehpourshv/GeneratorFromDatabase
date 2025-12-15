USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 99/12/23
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE pln.SPTaskOrderDaily
@CallType Int, 
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin

DECLARE @StrSelect		NVarChar(max)
DECLARE @StrWhere		NVarChar(2000)
DECLARE @StrGoods		NVarChar(2000)

DECLARE @TaskSerialNoFR			int
DECLARE @TaskSerialNoTO			int
DECLARE @TaskFiscalYearFR		int
DECLARE @TaskFiscalYearTO		int

DECLARE @ProduceSerialNoFR		int
DECLARE @ProduceSerialNoTO		int
DECLARE @ProduceFiscalYearFR	int
DECLARE @ProduceFiscalYearTO	int
Declare @FaultID varchar(20)
Declare @FaultName nvarchar(200)
Declare @ProcessID int
Declare @ProcessNo int
Declare @FiscalYear int
Declare @SerialNo int
Declare @ProduceStepID int
Declare @ProductionLineID int


DECLARE @FromDate as varchar(10),
@ToDate as varchar(10),
@QuantityDecimals int

select @QuantityDecimals=SettingValue from pub.tblSettings
where SettingKey = 'QuantityDecimals' 
set @QuantityDecimals=isnull(@QuantityDecimals,0)

if @CallType=1
	begin
		SET @StrGoods		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
		SET @TaskFiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @TaskSerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
		SET @TaskFiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
		SET @TaskSerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
		
		SET @ProduceFiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
		SET @ProduceSerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
		SET @ProduceFiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SET @ProduceSerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
		SET @FromDate		= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
		SET @ToDate		= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
		
		set @StrWhere = ' 1=1 '
		if @StrGoods<>''
			set @StrWhere =@StrWhere+ @StrGoods		
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
			set @StrWhere = @StrWhere+' AND b.StartDate	>=''' +@FromDate + ''''
		if @ToDate<>''
			set @StrWhere = @StrWhere+' AND b.StartDate	<=''' +@ToDate + ''''	 
		
	select b.ProcessID,b.ProcessNo,b.FiscalYear,b.SerialNo,StartDate,b.ProductionLineID,isnull(ProductionLineName, '')ProductionLineName,a.ProductID, GoodsName,b.ProduceStepID,ProduceStepName
	,OrderCount,AcceptableCount ,UnacceptableCount,(OrderCount-AcceptableCount  )/OrderCount Offset
	,StartTime, StartTime EndTime, convert(varchar(7), '') FaultTime,convert(varchar(200), '') FaultID,convert(nvarchar(200), '') FaultName
	into #TmpTblTask
	from pln.tblTaskOrderHdr a 
	inner join pln.tblTaskOrderDtl b on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
	inner join inv.tblGoodsDtl g on g.GoodsID=a.ProductID
	INNER JOIN pln.tblProduceStepDtl AS s ON s.ProductID = a.ProductID AND a.ProduceStepSerialNo  = s.SerialNo  and b.ProduceStepID=s.ProduceStepID  
	left JOIN pln.tblProductionLinesDtl as l on  l.ProductionLineID= b.ProductionLineID	
	where 1=0 

	set @StrSelect = ' 
	insert into #TmpTblTask
	select b.ProcessID,b.ProcessNo,b.FiscalYear,b.SerialNo,StartDate,b.ProductionLineID,isnull(ProductionLineName, '''')ProductionLineName,a.ProductID, GoodsName,b.ProduceStepID,ProduceStepName
		,OrderCount,sum(AcceptableCount ) AcceptableCount,sum(UnacceptableCount) UnacceptableCount,round((OrderCount-sum(AcceptableCount ) )/OrderCount, '+ str(@QuantityDecimals) +' )Offset
		,'''','''','''','''',''''
	from pln.tblTaskOrderHdr a 
	inner join pln.tblTaskOrderDtl b on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
	inner join inv.tblGoodsDtl g on g.GoodsID=a.ProductID
	INNER JOIN pln.tblProduceStepDtl AS s ON s.ProductID = a.ProductID AND a.ProduceStepSerialNo  = s.SerialNo  and b.ProduceStepID=s.ProduceStepID  
	left JOIN pln.tblProductionLinesDtl as l on  l.ProductionLineID= b.ProductionLineID	
	where  ' + @StrWhere +' 	
	group by StartDate,b.ProductionLineID,ProductionLineName,a.ProductID, GoodsName,b.ProduceStepID,ProduceStepName,OrderCount
	,b.ProcessID,b.ProcessNo,b.FiscalYear,b.SerialNo'

	print @StrSelect
	Exec sp_executesql @StrSelect;
	--select  * into TmpTblTask  from #TmpTblTask

	update  #TmpTblTask
	set FaultTime=prs.funGetHourMinutesStandard(b.FaultTime)
	from  #TmpTblTask a 
	inner join 
	(select sum(isnull(FaultTime,0))/60 FaultTime,   b.ProcessID,	b.ProcessNo	,b.FiscalYear	,b.SerialNo,b.ProduceStepID,b.ProductionLineID
	from pln.tblTaskOrderDtl b 
	inner  JOIN pln.tblFaultItems f on f.ProcessID=b.ProcessID and f.ProcessNo=b.ProcessNo and f.FiscalYear=b.FiscalYear and f.SerialNo=b.SerialNo and f.DocRowNo=b.DocRowNo
	inner  JOIN pln.tblFaults fn on f.FaultID=fn.FaultID
	Group by  b.ProcessID,	b.ProcessNo	,b.FiscalYear	,b.SerialNo,b.ProduceStepID,b.ProductionLineID) b 
	on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
	and a.ProduceStepID=b.ProduceStepID
	and a.ProductionLineID=b.ProductionLineID
		 
	DECLARE csr CURSOR FOR 
		select  f.FaultID,fn.FaultName,   b.ProcessID,	b.ProcessNo	,b.FiscalYear	,b.SerialNo,b.ProduceStepID,b.ProductionLineID
		from pln.tblTaskOrderDtl b 
		inner  JOIN pln.tblFaultItems f on f.ProcessID=b.ProcessID and f.ProcessNo=b.ProcessNo and f.FiscalYear=b.FiscalYear and f.SerialNo=b.SerialNo and f.DocRowNo=b.DocRowNo
		inner  JOIN pln.tblFaults fn on f.FaultID=fn.FaultID
		inner  JOIN #TmpTblTask t on t.ProcessID=b.ProcessID and t.ProcessNo=b.ProcessNo and t.FiscalYear=b.FiscalYear and t.SerialNo=b.SerialNo-- and f.DocRowNo=b.DocRowNo
	OPEN csr
		FETCH NEXT FROM csr INTO @FaultID,@FaultName,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@ProduceStepID,@ProductionLineID
	WHILE @@Fetch_Status = 0
	BEGIN
	if isnull(@FaultID,'')<>''
		update #TmpTblTask
		set FaultID= isnull(FaultID , '') +'(' + @FaultID+ ') '
			, FaultName= isnull(FaultName , '')   +N'(' + @FaultName+ N') '
		where ProcessID=@ProcessID 
		and ProcessNo=@ProcessNo 
		and FiscalYear=@FiscalYear	
		and SerialNo=@SerialNo	
		and  not FaultID like '%'+ @FaultID + '%'
	--and ProduceStepID=@ProduceStepID	
	--and ProductionLineID=@ProductionLineID
	
	FETCH NEXT FROM csr INTO @FaultID,@FaultName,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@ProduceStepID,@ProductionLineID

	END

	CLOSE csr
	DEALLOCATE csr

	select * from #TmpTblTask
end 


if @CallType=2
	begin	
		select * ,OrderCount*MainUnitValue/UnitValue	OrderCount2,AcceptableCount*MainUnitValue/UnitValue AcceptableCount2
		from 
		(
		select b.ProductionLineID,ProductionLineName,a.ProductID, 
		GoodsName--,b.ProduceStepID,ProduceStepName
		,sum(OrderCount) OrderCount,sum(AcceptableCount ) AcceptableCount,sum(UnacceptableCount) UnacceptableCount	
		,  isnull(UnitValue,1)	UnitValue,isnull(MainUnitValue,1) MainUnitValue
		from pln.tblTaskOrderHdr a 
		inner join pln.tblTaskOrderDtl b on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
		inner join inv.tblGoodsDtl g on g.GoodsID=a.ProductID
		INNER JOIN pln.tblProduceStepDtl AS s ON s.ProductID = a.ProductID AND a.ProduceStepSerialNo  = s.SerialNo  and b.ProduceStepID=s.ProduceStepID  
		INNER JOIN pln.tblProductionLinesDtl as l on  l.ProductionLineID= b.ProductionLineID
		left join inv.tblSubUnitsDtl u on a.ProductID= u.GoodsID and u.ShowInInvoice=1
		group by b.ProductionLineID,ProductionLineName,a.ProductID, GoodsName,UnitValue,MainUnitValue
		) a
	end 

end 
GO
