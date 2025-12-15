USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1404/07/13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : مرور برنامه ریزی تولید
-- =============================================
Create PROCEDURE pln.spPLNReview
	@CallType			int,
	@ExtraParams		NVarChar(Max) = ''	
WITH ENCRYPTION
AS
begin

	DECLARE @StrSelect			NVarChar(Max);
	DECLARE @StrWhere			NVarChar(Max);
	DECLARE @ProductID			Varchar(20);
	DECLARE @BatchNo			Varchar(20);
	DECLARE @prdDateFr			Char(10);
	DECLARE @prdDateTo			Char(10);
	DECLARE @tskDateFr			Char(10);
	DECLARE @tskDateTo			Char(10);
	DECLARE @prdFiscalYearFr	int;
	DECLARE @prdSerialNoFr		int;
	DECLARE @prdFiscalYearTo	int;
	DECLARE @prdSerialNoTo		int;
	DECLARE @tskFiscalYearFr	int;
	DECLARE @tskSerialNoFr		int;
	DECLARE @tskFiscalYearTo	int;
	DECLARE @tskSerialNoTo		int;
	DECLARE @EndProduce			bit;
	DECLARE @EndtaskOrder		bit;
	
	DECLARE @Stert			int=0
	DECLARE @Count			int=0

	SET @Stert			= pub.funSplitString(@ExtraParams, '@', 1); 
	SET @Count			= pub.funSplitString(@ExtraParams, '@', 2); 
	SET @prdDateFr		= pub.funSplitString(@ExtraParams, '@', 3);
	SET @prdDateTo		= pub.funSplitString(@ExtraParams, '@', 4);
	SET @prdFiscalYearFr= pub.funSplitString(@ExtraParams, '@', 5);
	SET @prdSerialNoFr	= pub.funSplitString(@ExtraParams, '@', 6);
	SET @prdFiscalYearTo= pub.funSplitString(@ExtraParams, '@', 7);
	SET @prdSerialNoTo	= pub.funSplitString(@ExtraParams, '@', 8);	
	SET @tskDateFr		= pub.funSplitString(@ExtraParams, '@', 9);
	SET @tskDateTo		= pub.funSplitString(@ExtraParams, '@', 10);
	SET @tskFiscalYearFr= pub.funSplitString(@ExtraParams, '@', 11);
	SET @tskSerialNoFr	= pub.funSplitString(@ExtraParams, '@', 12);
	SET @tskFiscalYearTo= pub.funSplitString(@ExtraParams, '@', 13);
	SET @tskSerialNoTo	= pub.funSplitString(@ExtraParams, '@', 14);
	SET @ProductID		= pub.funSplitString(@ExtraParams, '@', 15);
	SET @BatchNo		= pub.funSplitString(@ExtraParams, '@', 16);	
	SET @EndProduce		= pub.funSplitString(@ExtraParams, '@', 17);	
	SET @EndtaskOrder	= pub.funSplitString(@ExtraParams, '@', 18);	
	 
	set @StrWhere=' 1=1'
	if @prdDateFr<>''
		set @StrWhere=@StrWhere+'	And c.DocDate>='''+ @prdDateFr +''''
	if @prdDateTo<>''
		set @StrWhere=@StrWhere+'	And c.DocDate<='''+ @prdDateTo +''''
	if @tskDateFr<>''
		set @StrWhere=@StrWhere+'	And a.DocDate>='''+ @tskDateFr +''''
	if @tskDateTo<>''
		set @StrWhere=@StrWhere+'	And a.DocDate<='''+ @tskDateTo +''''

	if Isnull(@prdFiscalYearFr,0)<>0
		set @StrWhere=@StrWhere+'	And b.FiscalYear>='+Str(@prdFiscalYearFr)+''
	if Isnull(@prdSerialNoFr,0)<>0
		set @StrWhere=@StrWhere+'	And b.SerialNo>='+Str(@prdSerialNoFr)+''
	if Isnull(@prdFiscalYearTo,0)<>0
		set @StrWhere=@StrWhere+'	And b.FiscalYear<='+Str(@prdFiscalYearTo)+''
	if Isnull(@prdSerialNoTo,0)<>0
		set @StrWhere=@StrWhere+'	And b.SerialNo<='+Str(@prdSerialNoTo)+''
	
	if Isnull(@tskFiscalYearFr,0)<>0
		set @StrWhere=@StrWhere+'	And a.FiscalYear>='+Str(@tskFiscalYearFr)+''
	if Isnull(@tskSerialNoFr,0)<>0
		set @StrWhere=@StrWhere+'	And a.SerialNo>='+Str(@tskSerialNoFr)+''
	if Isnull(@tskFiscalYearTo,0)<>0
		set @StrWhere=@StrWhere+'	And a.FiscalYear<='+Str(@tskFiscalYearTo)+''
	if Isnull(@tskSerialNoTo,0)<>0
		set @StrWhere=@StrWhere+'	And a.SerialNo<='+Str(@tskSerialNoTo)+''

	if Isnull(@ProductID,'')<>''
		set @StrWhere=@StrWhere+'	And (SubString(b.ProductID,1,len('''+ (@ProductID)+''' ))='''+ @ProductID+''' or SubString(a.ProductID,1,len('''+ (@ProductID)+''' ))='''+ @ProductID +''') '

	if Isnull(@BatchNo,'')<>''
		set @StrWhere=@StrWhere+'	And (SubString(b.BatchNo,1,len('''+ (@BatchNo)+''' )) ='''+ @BatchNo+''' or SubString(a.BatchNo,1,len('''+ (@BatchNo)+''' )) ='''+ @BatchNo+''') '

	if @EndProduce='False'
		set @StrWhere=@StrWhere+'	And c.IsFinished=0'
		
if @CallType=1
begin	
	set @StrSelect ='
	select  Count(*)
	from pln.tblProduceOrderDtl b 
	inner join pln.tblProduceOrderHdr c on b.ProcessID=c.ProcessID  and b.ProcessNo=c.ProcessNo and b.FiscalYear=c.FiscalYear and b.SerialNo=c.SerialNo 
	left join pln.tblTaskOrderHdr a on b.ProcessID=a.BaseProcessID  and b.ProcessNo=a.BaseProcessNo and b.FiscalYear=a.BaseFiscalYear and b.SerialNo=a.BaseSerialNo and b.DocRowNo=a.ProdDocRowNo 
'
if @EndtaskOrder='False'
	set @StrSelect=@StrSelect+'	And a.TaskStateID<>4 '

set @StrSelect=@StrSelect+'	
	left join pln.tblTaskOrderDtl d on a.ProcessID=d.ProcessID  and a.ProcessNo=d.ProcessNo and a.FiscalYear=d.FiscalYear and a.SerialNo=d.SerialNo 
	left join pln.tblProduceStepDtl sd on sd.SerialNo=b.StepNo  and sd.ProductID=b.ProductID and sd.ProduceStepID=d.ProduceStepSerialNo 
	WHERE 	'+@StrWhere+' 
	'
	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;

end	
if @CallType=0
begin
	declare @StrStorage as 	NVarChar(1000);
	set @StrStorage='(select top 1  s.BatchNo from  inv.tblStorageDocsDtl s where s.BaseProcessID=d.ProcessID and s.BaseProcessNo=d.ProcessNo	and s.BaseFiscalYear=d.FiscalYear and s.BaseSerialNo=d.SerialNo	and s.BaseDocRowNo=d.DocRowNo and (s.GoodsID=a.ProductID or s.DocRowNo=1))'
	set @StrSelect ='  
	select b.ProcessNo ,c.DocDate DocDatePrd, b.FiscalYear FiscalYearPrd,b.SerialNo SerialNoPrd,b.DocRowNo,b.ProductID ProductIDPrd,pub.GetGoodsName(b.ProductID,1) ProductNamePrd,
			b.ProductCount,ltrim(rtrim(str(b.FormulaNo )))+''-''+prd.funGetFormulaName(b.ProductID,b.FormulaNo)FormulaNoPrd
			,ltrim(rtrim(str(b.StepNo )))+''-''+  isnull(ProduceStepName, ''-'') StepNoPrd ,b.DescDtl,b.BatchNo BatchNoPrd,b.ShiftTypeID, emp.funGetShiftTypeName(b.ShiftTypeID,1)ShiftTypeName,
			b.ProductionLineID,pln.funGetProductionLineName(b.ProductionLineID,1)ProductionLineName,b.SubUnitID,inv.funGetUnitName (b.SubUnitID,1)SubUnitName,
			isnull(a.DocDate,'''') DocDateTsk,isnull(a.FiscalYear ,0)FiscalYearTsk ,isnull(a.SerialNo ,0)SerialNoTsk,isnull(a.ProductID ,'''')ProductIDTsk
			,pub.GetGoodsName(isnull(a.ProductID,''''),1) ProductNameTsk,isnull(OrderCount,0) OrderCount,isnull(a.BatchNo ,'''')BatchNoTsk,
			isnull(a.ProduceStepSerialNo,0) ProduceStepSerialNo,isnull(a.FormulaNo,0) FormulaNoTsk,isnull(a.BaseFiscalYear,0) BaseFiscalYear,isnull(a.BaseSerialNo,0)BaseSerialNo,isnull(a.ProdDocRowNo ,0)BaseDocRowNo
			,isnull(ProductionLineIDHdr,'''') ProductionLineIDHdr,pln.funGetProductionLineName(isnull(ProductionLineIDHdr,''''),1)ProductionLineNameHdr,isnull(ShiftTypeIDHdr,'''') ShiftTypeIDHdr
			,emp.funGetShiftTypeName(isnull(ShiftTypeIDHdr,''''),1)ShiftTypeNameHdr			
			,isnull(d.DocRowNo,0) DocRowNoTdtl	,isnull(StartTime,'''')	StartTime,isnull(FinishTime,'''')FinishTime,isnull(TotalTime,'''')	TotalTime
			,isnull(AcceptableCount,0)	AcceptableCount,isnull(UnacceptableCount,0)	UnacceptableCount
			,isnull(StartDate,'''')	StartDate,isnull(FinishDate,'''')	FinishDate,isnull(d.ProduceStepSerialNo,0) ProduceStepSerialNoTdtl
			,isnull(d.ProductionLineID,'''')	ProductionLineIDTdtl,pln.funGetProductionLineName(isnull(d.ProductionLineID,''''),1)ProductionLineNameTdtl
			,isnull(d.ShiftTypeID,'''')	ShiftTypeIDTdtl,emp.funGetShiftTypeName(isnull(d.ShiftTypeID,''''),1)ShiftTypeNameTdtl,isnull(d.DescDtl,'''') DescDtlTdtl	
			,isnull(d.SubUnitID,'''')	SubUnitIDTdtl,inv.funGetUnitName (d.SubUnitID,1)SubUnitNameTdtl,isnull(d.SubUnitQuantity,'''')	SubUnitQuantityTdtl
			,case when isnull('+@StrStorage+','''')='''' then isnull(a.BatchNo ,'''') else isnull('+@StrStorage+','''') end  BatchNoTdtl
	from pln.tblProduceOrderDtl b 
	inner join pln.tblProduceOrderHdr c on b.ProcessID=c.ProcessID  and b.ProcessNo=c.ProcessNo and b.FiscalYear=c.FiscalYear and b.SerialNo=c.SerialNo 
	left join pln.tblTaskOrderHdr a on b.ProcessID=a.BaseProcessID  and b.ProcessNo=a.BaseProcessNo and b.FiscalYear=a.BaseFiscalYear and b.SerialNo=a.BaseSerialNo and b.DocRowNo=a.ProdDocRowNo  
	'
if @EndtaskOrder='False'
	set @StrSelect=@StrSelect+'	And a.TaskStateID<>4 '

set @StrSelect=@StrSelect+'	
	left join pln.tblTaskOrderDtl d on a.ProcessID=d.ProcessID  and a.ProcessNo=d.ProcessNo and a.FiscalYear=d.FiscalYear and a.SerialNo=d.SerialNo 
	left join pln.tblProduceStepDtl sd on sd.SerialNo=b.StepNo  and sd.ProductID=b.ProductID  and sd.ProduceStepID=d.ProduceStepSerialNo
	WHERE 	'+@StrWhere+' 
	ORDER BY  b.FiscalYear,b.SerialNo,b.ProcessID,b.ProcessNo
	Offset '+str(@Stert)+' Rows Fetch Next '+str(@Count)+' Rows only '
  
	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;

end

end

GO
