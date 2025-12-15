USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		 : jafari	
-- Create date	 : 1401/06/24
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- =============================================
Create PROCEDURE pln.RptPln_OrderWork
	@FiscalYear		Int = 0,
	@SerialNo		Int = 0,
	@FiscalYearTo		Int = 0,
	@SerialNoTo		Int = 0,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect			Nvarchar(max);
DECLARE @StrSelect2			Nvarchar(max);
DECLARE @StrWhere			Nvarchar(max);
DECLARE	@LangID				NvarChar(1);
DECLARE	@SessionNo			Int;
DECLARE	@ReportID			Int;
DECLARE	@ProdFiscalYear		Int = 0;
DECLARE	@ProdSerialNo		Int = 0;
DECLARE @ProdFiscalYearTo	Int = 0;
DECLARE	@ProdSerialNoTo		Int = 0;
DECLARE	@DateFr				Char(10);
DECLARE	@DateTo				Char(10);
DECLARE	@SelectedGoodsID	Varchar(20);
Declare @IdxSerialNo		int;
Declare @IdxFiscalYear		int;
BEGIN
	SET NOCOUNT ON;

	-- ---------------------------------------------------------------------------------
	IF @RepInfo IS NULL SET @RepInfo = '1@1@1'
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ProdFiscalYear	= pub.funSplitString(@RepInfo, '@', 6);
	SET @ProdSerialNo	= pub.funSplitString(@RepInfo, '@', 7);
	SET @ProdFiscalYearTo= pub.funSplitString(@RepInfo, '@', 8);
	SET @ProdSerialNoTo	= pub.funSplitString(@RepInfo, '@', 9);
	SET @DateFr			= pub.funSplitString(@RepInfo, '@', 10);
	SET @DateTo			= pub.funSplitString(@RepInfo, '@', 11);
	SET @SelectedGoodsID= pub.funSplitString(@RepInfo, '@', 12);

	-- ---------------------------------------------------------------------------------
	select 	@FiscalYear FiscalYear, @SerialNo SerialNo,GoodsID,	pub.funGetGoodsName(GoodsID,1)GoodsName	,UnitID	 SubUnitID	, pub.funGetGoodsName(GoodsID,1) UnitName	, cast(0.0 as float ) GoodsQuantity	,cast(0.0 as float ) QtyFormula	, cast(0.0 as float )GoodsAmount	,cast(0.0 as float ) Price	
	,GoodsWeight	,PureWeight	,ExtraField1	,ExtraField2	,ExtraField3	,ExtraField4	,ExtraField5	,ExtraField6	,ExtraField7	,ExtraField8	,ExtraField9	,ExtraField10	,ExtraField11	,ExtraField12	,ExtraField13	,ExtraField14	,ExtraField15	,ExtraField16	,ExtraField17	,ExtraField18	,ExtraField19	,ExtraField20
	into #Pln_OrderWorkUseGoods
	from inv.tblGoods
	where 1=0

	select @FiscalYear FiscalYear, @SerialNo SerialNo,GoodsID,	pub.funGetGoodsName(GoodsID,1)GoodsName	,UnitID	 SubUnitID	, pub.funGetGoodsName(GoodsID,1) UnitName	, cast(0.0 as float ) GoodsQuantity	,cast(0.0 as float ) QtyFormula	
	, cast(0.0 as float )GoodsAmount	,cast(0.0 as float ) Price	,	GoodsID LoseGroupID,	pub.funGetGoodsName(GoodsID,1) LoseGroupName	
	into #Pln_OrderWorkDamage
	from inv.tblGoods
	where 1=0

	set  @IdxSerialNo  = @SerialNo
	set  @IdxFiscalYear  = @FiscalYear

	while @IdxFiscalYear<=@FiscalYearTo
	begin
		while @IdxSerialNo<=@SerialNoTo
		begin
			insert into #Pln_OrderWorkUseGoods
			exec pln.RptPln_OrderWorkUseGoods @IdxFiscalYear,@IdxSerialNo	,@IdxFiscalYear,@IdxSerialNo,	@RepInfo
		
			insert into #Pln_OrderWorkDamage
			exec pln.RptPln_OrderWorkDamage @IdxFiscalYear,@IdxSerialNo	,@IdxFiscalYear,@IdxSerialNo,	@RepInfo		
	
			set @IdxSerialNo+=1
		end 
		set @IdxFiscalYear+=1
	end 
	
	SET @StrWhere	= '(1 = 1)';
	if @SerialNo>0
		SET @StrWhere = @StrWhere + ' and  T.FiscalYear>='+str(@FiscalYear)+' and T.SerialNo>='+str(@SerialNo)+'  '
	if @SerialNoTo>0
		SET @StrWhere = @StrWhere + ' and T.FiscalYear<='+str(@FiscalYearTo)+' and T.SerialNo<='+str(@SerialNoTo )+' '

	if @ProdSerialNo>0
		SET @StrWhere = @StrWhere + ' and  bb.FiscalYear>='+str(@ProdFiscalYear)+' and bb.SerialNo>='+str(@ProdSerialNo)+'  '
	if @ProdSerialNoTo>0
		SET @StrWhere = @StrWhere + ' and bb.FiscalYear<='+str(@ProdFiscalYearTo)+' and bb.SerialNo<='+str(@ProdSerialNoTo )+' '

	IF (@SelectedGoodsID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoodsID, 'T.ProductID')

	set @StrSelect2	=''
	if @DateFr<>'' or @DateTo<>''
	begin 
	
	set @StrSelect2	=' inner join (select Distinct a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo
		 from pln.tblTaskOrderHdr a left join pln.tblTaskOrderDtl b
			on a.ProcessID=b.ProcessID And a.ProcessNo=b.ProcessNo And a.FiscalYear=b.FiscalYear And a.SerialNo=b.SerialNo 
			where  1=1 '
		if @DateFr<>'' 
			set @StrSelect2 +=' and StartDate>='''+@DateFr + ''' and FinishDate>='''+@DateFr + ''''
		if @DateTo<>'' 
			set @StrSelect2 +=' and StartDate<='''+@DateTo + '''  and FinishDate<='''+@DateTo + ''''
			
		set @StrSelect2 +=' )TT on T.ProcessID=TT.ProcessID And T.ProcessNo=TT.ProcessNo And T.FiscalYear=TT.FiscalYear And T.SerialNo=TT.SerialNo '

	end 
	
	SET @StrSelect = N'
	select * 
		,round( case when TimeCountStandardBase *ProductCountStandardBase=0 then 0 else TotalTimeMin*60/cast(TimeCountStandardBase/ProductCountStandardBase as  float )end ,0)   ProductCountStandard
		, GoodsPrice1, GoodsPrice2, GoodsPrice3, DamagePrice1, DamagePrice2, DamagePrice3
		from (
	Select	T.FiscalYear,T.SerialNo,T.DocDate,T.BaseFiscalYear,T.BaseSerialNo,bb.ProductionLineID,pln.funGetProductionLineName(bb.ProductionLineID,1)ProductionLineName
	, bb.ShiftTypeID,emp.funGetShiftTypeName(bb.ShiftTypeID,1) ShiftTypeName
	, T.ProductID,pub.funGetGoodsName(T.ProductID,1)  as ProductName			
	, G.UnitID  , inv.funGetUnitName (G.UnitID  ,1)UnitName,ProduceStepSerialNo,T.FormulaNo 
	,(Select Sum(OperatorCount) from pln.tblProduceStepDtl p2 where  T.ProductID=p2.ProductID and p2.SerialNo=T.ProduceStepSerialNo)OperatorCount
	,(Select Max(PersonCount) from pln.tblTaskOrderDtl TD where  TD.ProcessID=T.ProcessID  and TD.ProcessNo=T.ProcessNo and TD.FiscalYear=T.FiscalYear and TD.SerialNo=T.SerialNo )PersonCount
	,(Select top 1 StartDate  from pln.tblTaskOrderDtl TD where TD.ProcessID=T.ProcessID  and TD.ProcessNo=T.ProcessNo and TD.FiscalYear=T.FiscalYear and TD.SerialNo=T.SerialNo order by StartDate,StartTime )StartDate
	,(Select top 1 StartTime  from pln.tblTaskOrderDtl TD where TD.ProcessID=T.ProcessID  and TD.ProcessNo=T.ProcessNo and TD.FiscalYear=T.FiscalYear and TD.SerialNo=T.SerialNo order by StartDate,StartTime)StartTime
	,(Select top 1 FinishDate from pln.tblTaskOrderDtl TD where TD.ProcessID=T.ProcessID  and TD.ProcessNo=T.ProcessNo and TD.FiscalYear=T.FiscalYear and TD.SerialNo=T.SerialNo order by FinishDate Desc,FinishTime Desc)FinishDate
	,(Select top 1 FinishTime from pln.tblTaskOrderDtl TD where TD.ProcessID=T.ProcessID  and TD.ProcessNo=T.ProcessNo and TD.FiscalYear=T.FiscalYear and TD.SerialNo=T.SerialNo order by FinishDate Desc,FinishTime Desc)FinishTime
	,isnull((Select Sum(TotalTime ) from pln.tblTaskOrderDtl TD where  TD.ProcessID=T.ProcessID  and TD.ProcessNo=T.ProcessNo and TD.FiscalYear=T.FiscalYear and TD.SerialNo=T.SerialNo ),0)/60 TotalTimeMin
	 ,T.OrderCount
	,isnull((Select  sum(AcceptableCount+UnacceptableCount) from pln.tblTaskOrderDtl TD where  TD.ProcessID=T.ProcessID  and TD.ProcessNo=T.ProcessNo and TD.FiscalYear=T.FiscalYear and TD.SerialNo=T.SerialNo ),0) ProductCount
	,isnull((select sum( ProduceStepTime) from pln.tblProduceStepDtl aa  where aa.ProductID=T.ProductID and aa.SerialNo=bb.StepNo ),0)TimeCountStandardBase
	,isnull((select ProductCount from prd.tblFormulasHdr aa where    aa.ProductID=T.ProductID  and aa.SerialNo=T.FormulaNo), 0)   ProductCountStandardBase	
	, GoodsPrice1, GoodsPrice2, GoodsPrice3, DamagePrice1, DamagePrice2, DamagePrice3
	From	pln.tblTaskOrderHdr T
	'+ @StrSelect2 +'
	Left join pln.tblProduceOrderDtl  bb on  bb.ProcessID=T.BaseProcessID  and bb.ProcessNo=T.BaseProcessNo and bb.FiscalYear=T.BaseFiscalYear and bb.SerialNo=T.BaseSerialNo    and bb.DocRowNo=T.ProdDocRowNo  
	Left join pln.tblProduceStepHdr  p1 on T.ProductID=p1.ProductID and p1.SerialNo=T.ProduceStepSerialNo	
	left join inv.tblGoods 	G on G.GoodsID=T.ProductID 	
	left join (select isnull(Sum(Price),0) GoodsPrice1 ,isnull(Sum(QtyFormula*GoodsAmount),0)  GoodsPrice2 ,isnull(Sum(Price),0)  -isnull(Sum(QtyFormula*GoodsAmount),0) GoodsPrice3, FiscalYear,SerialNo   from #Pln_OrderWorkUseGoods group by  FiscalYear,SerialNo)  P1
		on  T.FiscalYear=P1.FiscalYear and T.SerialNo=P1.SerialNo 
	left join (select isnull(Sum(Price),0) DamagePrice1 ,isnull(Sum(QtyFormula*GoodsAmount),0)  DamagePrice2 ,isnull(Sum(Price),0)  -isnull(Sum(QtyFormula*GoodsAmount) ,0) DamagePrice3, FiscalYear,SerialNo  from #Pln_OrderWorkDamage group by  FiscalYear,SerialNo) P2
		on  T.FiscalYear=P2.FiscalYear and T.SerialNo=P2.SerialNo 	
	Where ' + @StrWhere + '	
	)a  
	Order by FiscalYear,SerialNo '

	-- ---------------------------------------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
