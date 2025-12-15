USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1398/02/15
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : < انجام گروهی دستور کار>
-- ==============================================
Create PROCEDURE pln.SpDoingGroups
	@CallType			int,
	@ExtraParams		NVarChar(Max) = ''	
WITH ENCRYPTION
AS
BEGIN

declare @ProductID				varchar(20);
declare @FiscalYear				int;
declare @SerialNo				int;
declare @ProcessNo				int=0;
DECLARE @StrSelect				NVarChar(Max);
DECLARE @StrWhere 				NVarChar(Max);
DECLARE @StrNeedStep 			NVarChar(Max);
declare @NeedStep				int;
declare @IsService				bit;
declare @DocDate				char(10);
declare @ProductIDFilter		varchar(20);
declare @BatchNoFilter			varchar(20);
declare @BaseProcessID			int=0;
declare @BaseProcessNo			int=0;
declare @BaseFiscalYear			int=0;
declare @BaseSerialNo			int;
declare @BaseDocRowNo			int=0;
declare @FormulaNo				int=0;
declare @AcceptStoreID			varchar(20);
declare @LossStoreID			varchar(20);
declare @FailedStoreID			varchar(20);
declare @UsageStoreID1			varchar(20);
declare @UsageStoreID2			varchar(20);
declare @UsageStoreID3			varchar(20);
declare @UsageStoreID4			varchar(20);
declare @AcntCode				varchar(20);
declare @AcceptableCount		float=0;
declare @UnacceptableCount		float=0;
declare @RecID					int=0;
declare @SessionNo				int=0;
declare @SerialNo72				int=0;
declare @ProcessID72			int=0;
declare @SerialNo82				int=0;
declare @ProcessID				int=0;
declare @BatchNo				varchar(20);
declare @ProductQty				float=0;
declare @ProductQtyUnaccept		float=0;
declare @PrdProductManyStores	bit;
declare @DocRowNo				int=0;
declare @ProduceStepID			int=0;
declare @ProduceStepSerialNo	int=0;
declare @MinProduceStepID		int=0;
declare @RP						VarChar(20);
declare @OrderCount				VarChar(20);
Declare @Qty1					float=0;
Declare @Qty2					float=0;
Declare @StrError				Nvarchar(1024)=''
Declare @GoodsID				varchar(20)=''
Declare @StoreID				varchar(20)=''
Declare @StrErrorMessage		Nvarchar(1024)
Declare @MaxSerialNo			int;
Declare @ProcessNo1				int;
Declare @ProcessNo2				int;
declare @TaskFiscalYear			int;
declare @TaskSerialNo			int;
-----برای کالا های چند پارتی---------------------------------------------------------------
DECLARE @UnitPart				TINYINT
DECLARE @str_Goods				tinyint
DECLARE @str_GoodsSum			tinyint
DECLARE @StoreIDCount			int
Declare @prdFormulaWithAccept	bit
declare @Pln_AllocationOfGoodsByTransfer	bit;
declare @Pln_InFrmDoingGroupsProduceStore1Step2Formula	bit;

	select @Pln_InFrmDoingGroupsProduceStore1Step2Formula=SettingValue from pub.tblSettings 		where SettingKey='Pln_InFrmDoingGroupsProduceStore1Step2Formula'
	select @Pln_AllocationOfGoodsByTransfer=SettingValue from pub.tblSettings 		where SettingKey='Pln_AllocationOfGoodsByTransfer'

	SELECT @prdFormulaWithAccept = SettingValue from pub.tblSettings where SettingKey = 'prdSeparateAcceptFormulaWithNonAccept'
	set @prdFormulaWithAccept=ISNULL(@prdFormulaWithAccept,0)

	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'
	set @UnitPart=ISNULL(@UnitPart,1)
	if @UnitPart<1  
		set @UnitPart=1
	
	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

if @CallType=6
begin
	
	SET @ProductID		= pub.funSplitString(@ExtraParams, '@', 1);

	select *  from inv.tblGoods  where   SUBSTRING( @ProductID,@str_Goods+1 ,@str_GoodsSum)=GoodsID   and PartNumber =@UnitPart

	return
end 

if @CallType=5
begin	
	
	declare @RequestStep	int=0;
	declare @AcceptRun		float=0;
	declare @AcceptReq		float=0;
	declare @ExecStep		float=0;

	SET @FiscalYear			= pub.funSplitString(@ExtraParams, '@', 1);
	SET @SerialNo			= pub.funSplitString(@ExtraParams, '@', 2);
	SET @ProduceStepID		= pub.funSplitString(@ExtraParams, '@', 3);
	SET @ExecStep			= pub.funSplitString(@ExtraParams, '@', 4);
	
	select @RequestStep=isnull(RequestStep,0)
	from pln.tblTaskOrderHdr a 			
		inner join pln.tblProduceStepDtl  p1 on a.ProductID=p1.ProductID and p1.SerialNo=a.ProduceStepSerialNo		
	where a.FiscalYear=@FiscalYear and a.SerialNo=@SerialNo and  ProduceStepID=@ProduceStepID

	if @RequestStep=0
		begin
			select @RequestStep RequestStep,0 AcceptReq,0 AcceptRun,0 ExecStep
			return 
		end 
		
	select @AcceptReq =isnull(sum(AcceptableCount),0) 
	from pln.tblTaskOrderDtl
	where FiscalYear=@FiscalYear and SerialNo=@SerialNo and  ProduceStepID=@RequestStep

	select @AcceptRun =isnull(sum(AcceptableCount),0) 
	from pln.tblTaskOrderDtl
	where FiscalYear=@FiscalYear and SerialNo=@SerialNo and  ProduceStepID=@ProduceStepID and TotalTime>0
		
	select @RequestStep RequestStep,@AcceptReq AcceptReq,@AcceptRun AcceptRun,@ExecStep ExecStep
	
	return 
	
end 			
if @CallType=1  or @CallType=2 or @CallType=12
begin

	SET @BaseFiscalYear	= pub.funSplitString(@ExtraParams, '@', 1);
	SET @BaseSerialNo	= pub.funSplitString(@ExtraParams, '@', 2);
	SET @ProductID		= pub.funSplitString(@ExtraParams, '@', 3);
	SET @FiscalYear		= pub.funSplitString(@ExtraParams, '@', 4);
	SET @SerialNo		= pub.funSplitString(@ExtraParams, '@', 5);
	SET @ProcessNo		= pub.funSplitString(@ExtraParams, '@', 6);
	SET @NeedStep		= pub.funSplitString(@ExtraParams, '@', 7);
	SET @ProductIDFilter= pub.funSplitString(@ExtraParams, '@', 8);
	SET @DocDate		= pub.funSplitString(@ExtraParams, '@', 9);	
	SET @ProcessNo1		= pub.funSplitString(@ExtraParams, '@', 10);
	SET @ProcessNo2		= pub.funSplitString(@ExtraParams, '@', 11);
	SET @TaskFiscalYear	= pub.funSplitString(@ExtraParams, '@', 12);
	SET @TaskSerialNo	= pub.funSplitString(@ExtraParams, '@', 13);	
	SET @BatchNoFilter	= pub.funSplitString(@ExtraParams, '@', 14);	
	 
	select @IsService=IsService  
	from inv.tblGoods 
	where SUBSTRING( @ProductID,@str_Goods+1 ,@str_GoodsSum)=GoodsID   and PartNumber =@UnitPart
		
	SELECT  GoodsID  into #tblGoods
    FROM   prd.tblFormulasDtl FD
	where 1=0 ;
        
	if @ProductIDFilter<>''
	begin

		insert into #tblGoods 
			select @ProductIDFilter;

		WITH tblTemp(GoodsID) AS
		(
			SELECT  GoodsID 
			FROM   prd.tblFormulasDtl FD
			WHERE  FD.ProductID =@ProductIDFilter   --And NOT (FD.ProductID=@GoodsID AND SerialNo=@SerialNo AND RowNo=@RowNo)

			UNION All
		
			SELECT  FD.GoodsID
			FROM   prd.tblFormulasDtl FD CROSS JOIN tblTemp
			WHERE  (FD.ProductID = tblTemp.GoodsID) And NOT (FD.ProductID=@ProductIDFilter )--AND SerialNo=@SerialNo AND RowNo=@RowNo)
		)
		insert into #tblGoods
		SELECT  GoodsID 
		FROM   tblTemp;
		--SELECT  GoodsID FROM   #tblGoods
	end 		 

if @CallType=1
begin
	
	select Distinct bb.BaseProcessNo OrderProcessNo ,  bb.BaseSerialNo OrderSerialNo ,bb.BaseProcessNo, bb.BaseSerialNo,a.BaseDocRowNo,a.ProdDocRowNo,a.DocDesc LevelStr
			,a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,0 RowNo,0 DocRowNo,a.DocDate,a.OrderCount,cast (a.OrderCount as float) OrderCountRemain,bb.ProductCount
			,b.DocStep,a.ProductID,a.ProdDocRowNo ProduceStepID, a.DocDesc  ProduceStepName,isnull(a.BatchNo,'''') BatchNo,cast( a.SerialNo as float ) Tolerance
			,a.SerialNo  StepSerialNo,a.ProdDocRowNo RequestStep,a.ProductID ProductionLineID,bb.ShiftTypeID,DescDtl, a.DocDesc ProductName,0 TaskOrderOperatorID 
			, 0 FaultItemID,cast( a.SerialNo as float ) Tolerance2, OrderCount ToleranceCount ,OrderCount DoingCount
	into #tblDoing
	from pln.tblTaskOrderHdr a 
			inner join pln.tblProduceOrderHdr  b on b.ProcessID=a.BaseProcessID  and b.ProcessNo=a.BaseProcessNo and b.FiscalYear=a.BaseFiscalYear and b.SerialNo=a.BaseSerialNo      
			inner join pln.tblProduceOrderDtl  bb on  bb.ProcessID=a.BaseProcessID  and bb.ProcessNo=a.BaseProcessNo and bb.FiscalYear=a.BaseFiscalYear and bb.SerialNo=a.BaseSerialNo    and bb.DocRowNo=a.ProdDocRowNo  
	where 1=0

	set @StrWhere=' where   Suspend=0 and TaskStateID<>4 and a.ProcessNo='+ str(@ProcessNo)+' '

	 if @BaseSerialNo>0 and @SerialNo>0
		set @StrWhere= @StrWhere+' and  ((b.FiscalYear ='+ str(@BaseFiscalYear)+' and b.SerialNo ='+ str(@BaseSerialNo)+') 
											or (a.ProductID='''+ @ProductID +''' and a.FiscalYear='+ str(@FiscalYear)+' and a.SerialNo='+ str(@SerialNo)+'))  '	
	if @BaseSerialNo>0 and @SerialNo=0
		set @StrWhere= @StrWhere+' and  (b.FiscalYear ='+ str(@BaseFiscalYear)+' and b.SerialNo ='+ str(@BaseSerialNo)+') '

	set   @StrWhere=@StrWhere+' and a.BaseProcessNo in('+ str(@ProcessNo1)+','+ str(@ProcessNo2)+') '
	
	 if @ProductIDFilter<>''
		set @StrWhere= @StrWhere+' and (a.ProductID in ( SELECT  GoodsID FROM   #tblGoods ) OR bb.ProductID='''+ @ProductIDFilter +''') '	

	if @BatchNoFilter<>''
		set @StrWhere= @StrWhere+' and (a.BatchNo ='''+ @BatchNoFilter +''') '	
		
	if @TaskSerialNo>0
		set   @StrWhere=@StrWhere+' and  (a.FiscalYear ='+ str(@TaskFiscalYear)+' and a.SerialNo ='+ str(@TaskSerialNo)+') '
	
	set @StrNeedStep=''
	if @NeedStep<>2
		set @StrNeedStep=' and NeedStep=' +str(@NeedStep)
	  
	set @StrSelect='	
		select Distinct bb.BaseProcessNo OrderProcessNo ,  bb.BaseSerialNo OrderSerialNo, a.BaseProcessNo,  a.BaseSerialNo,a.BaseDocRowNo,a.ProdDocRowNo,LevelStr,a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,0 RowNo,0 DocRowNo,a.DocDate,a.OrderCount
			,round(Case when (select Count(*) from pln.tblProduceStepDtl   p3 where p1.ProductID=p3.ProductID and p1.SerialNo=p3.SerialNo and p3.NeedConfirm=1)<=0 then 
			cast (cast (a.OrderCount as float)
					- isnull(CAST( ( Select SUM(AcceptableCount+UnacceptableCount) from pln.tblTaskOrderDtl d 
										where   a.ProcessID=d.ProcessID   and a.ProcessNo=d.ProcessNo and a.FiscalYear=d.FiscalYear  and a.SerialNo=d.SerialNo and d.NeedStop =0
											and d.ProduceStepID =p2.ProduceStepID) as float),0.0 )as float) 
					- isnull(CAST( ( Select SUM(UnacceptableCount) from pln.tblTaskOrderDtl d 
										where   a.ProcessID=d.ProcessID   and a.ProcessNo=d.ProcessNo and a.FiscalYear=d.FiscalYear  and a.SerialNo=d.SerialNo 
											and d.ProduceStepID <p2.ProduceStepID) as float),0.0 )
					- isnull(CAST( ( Select SUM(UnacceptableCount) from pln.tblTaskOrderHdr d1 
										inner join pln.tblTaskOrderDtl d2 on d1.ProcessID=d2.ProcessID   and d1.ProcessNo=d2.ProcessNo and d1.FiscalYear=d2.FiscalYear  and d1.SerialNo=d2.SerialNo 
										where   d1.BaseProcessID=bb.ProcessID and d1.BaseProcessNo=bb.ProcessNo and d1.BaseFiscalYear=bb.FiscalYear and d1.BaseSerialNo=bb.SerialNo and d1.ProdDocRowNo=bb.DocRowNo
											and Deduct=''True'' and d2.SerialNo<>a.SerialNo ) as float),0.0 )
			else			
				cast (cast (pln.funPrevStepAcceptableCount(a.SerialNo,p2.ProduceStepID,a.FiscalYear)	 +pln.funNextStepNeedRepeat(a.SerialNo,p2.ProduceStepID) as float)
					- isnull(CAST( ( Select SUM(AcceptableCount+UnacceptableCount) from pln.tblTaskOrderDtl d 
									where   a.ProcessID=d.ProcessID   and a.ProcessNo=d.ProcessNo and a.FiscalYear=d.FiscalYear  and a.SerialNo=d.SerialNo and d.NeedStop =0
									and d.ProduceStepID =p2.ProduceStepID) as float),0.0 )
					- isnull(CAST( ( Select SUM(UnacceptableCount) from pln.tblTaskOrderHdr d1 
										inner join pln.tblTaskOrderDtl d2 on d1.ProcessID=d2.ProcessID   and d1.ProcessNo=d2.ProcessNo and d1.FiscalYear=d2.FiscalYear  and d1.SerialNo=d2.SerialNo 
										where   d1.BaseProcessID=bb.ProcessID and d1.BaseProcessNo=bb.ProcessNo and d1.BaseFiscalYear=bb.FiscalYear and d1.BaseSerialNo=bb.SerialNo and d1.ProdDocRowNo=bb.DocRowNo
											and Deduct=''True'' and d2.SerialNo<>a.SerialNo ) as float),0.0 )	
											as float)
			end ,5)OrderCountRemain	
			,bb.ProductCount,b.DocStep,a.ProductID,p2.ProduceStepID,p2.ProduceStepName,isnull(a.BatchNo,'''') BatchNo, p1.Tolerance,p1.SerialNo  StepSerialNo
			,RequestStep,a.ProductionLineIDHdr ProductionLineID,a.ShiftTypeIDHdr ShiftTypeID ,DescDtl
		from pln.tblTaskOrderHdr a 
			inner join pln.tblProduceOrderHdr b on b.ProcessID=a.BaseProcessID  and b.ProcessNo=a.BaseProcessNo and b.FiscalYear=a.BaseFiscalYear and b.SerialNo=a.BaseSerialNo      
			inner join pln.tblProduceOrderDtl bb on bb.ProcessID=a.BaseProcessID  and bb.ProcessNo=a.BaseProcessNo and bb.FiscalYear=a.BaseFiscalYear and bb.SerialNo=a.BaseSerialNo    and bb.DocRowNo=a.ProdDocRowNo  
			inner join pln.tblAvailProduceOrders ab on ab.ProcessID=a.BaseProcessID  and ab.ProcessNo=a.BaseProcessNo and ab.FiscalYear=a.BaseFiscalYear and ab.SerialNo=a.BaseSerialNo    and ab.DocRowNo=a.BaseDocRowNo  and ab.BaseDocRowNo=bb.DocRowNo  
			inner join pln.tblProduceStepHdr p1 on a.ProductID=p1.ProductID and p1.SerialNo=a.ProduceStepSerialNo
			inner join pln.tblProduceStepDtl p2 on p1.ProductID=p2.ProductID and p1.SerialNo=p2.SerialNo '+@StrNeedStep+'
		'+ @StrWhere 

	set @StrSelect='	
		insert into #tblDoing		
		select a.*, isnull(GoodsName,'''') ProductName,0 TaskOrderOperatorID , 0 FaultItemID,Tolerance, OrderCount*Tolerance/100 ToleranceCount ,0
		from ('+ @StrSelect +' ) a 
			left join   inv.tblGoodsDtl g on SUBSTRING( a.ProductID,'+str(@str_Goods+1)+' ,'+str(@str_GoodsSum)+')=g.GoodsID   and PartNumber ='+str(@UnitPart)+'
		where OrderCountRemain>0
		order by a.ProductID,a.FiscalYear,a.SerialNo,a.ProduceStepID'

	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;
		
	update #tblDoing
		set DoingCount=OrderCountRemain
	--where RequestStep=0
		
	--update #tblDoing
	--	set DoingCount=a.OrderCountRemain- b.OrderCountRemain
	--from #tblDoing a inner join (select *from #tblDoing)b
	--	on a.ProcessID=b.ProcessID and
	--	a.ProcessNo=b.ProcessNo and
	--	a.FiscalYear=b.FiscalYear and
	--	a.ProcessID=b.ProcessID and 
	--	a.RequestStep=b.ProduceStepID
	--where a.RequestStep<>0

	select  Case when BaseProcessNo=1 then ' بدون مرجع' else 'با مرجع' end BaseName, * 
	, pln.funGetProductionLineName(ProductionLineID,1)ProductionLineName,	emp.funGetShiftTypeName(ShiftTypeID,1) ShiftTypeName
 from  #tblDoing	

end

if @CallType=2 or @CallType=12 
begin
	set @StrWhere  =' and 1=1'
	if @CallType=2 
		set @StrWhere  =' and FinishDate<>'''''
	if @CallType=12 
		set @StrWhere  =' and FinishDate='''''
	if @ProductIDFilter<>''
		set @StrWhere= @StrWhere+' and a.ProductID in ( SELECT  GoodsID FROM   #tblGoods ) and bb.ProductID='''+ @ProductIDFilter +''' '	
	if @BatchNoFilter<>''
		set @StrWhere= @StrWhere+' and (a.BatchNo ='''+ @BatchNoFilter +''') '	
		
	set   @StrWhere=@StrWhere+' and a.BaseProcessNo in('+ str(@ProcessNo1)+','+ str(@ProcessNo2)+') '

	if @TaskSerialNo>0
		set   @StrWhere=@StrWhere+' and  (a.FiscalYear ='+ str(@TaskFiscalYear)+' and a.SerialNo ='+ str(@TaskSerialNo)+') '
	
	if @IsService='True'
		begin
	
		set @StrSelect='
			select 	 Distinct 0 OrderProcessNo ,0 OrderSerialNo,0 BaseProcessNo,0 BaseSerialNo,0 ProdDocRowNo,isnull(a.BatchNo,'''') BatchNo,a.ProductID,d.ProcessID
					,d.ProcessNo,d.FiscalYear,d.SerialNo,d.RowNo,d.DocRowNo,a.DocDate,StartDate,FinishDate,AcceptableCount+UnacceptableCount OrderCount,0 ProductCount,0 DocStep
					,prs.funGetHourMinutesStandard((select isnull( sum(fi.FaultTime),''0'') from  pln.tblFaultItems fi 
														where d.ProcessID=fi.ProcessID and d.ProcessNo=fi.ProcessNo and d.FiscalYear=fi.FiscalYear and d.SerialNo=fi.SerialNo and d.DocRowNo=fi.DocRowNo)/60)FaultTime
					,GoodsName ProductName,TotalTime/60 Times,StartTime,AcceptableCount,UnacceptableCount,isnull(OperatorID, '''')OperatorID,prs.funGetPersonnelName(OperatorID,1) OperatorIDName,isnull(TaskOrderOperatorID,0)TaskOrderOperatorID
					,d.ProduceStepID,p2.ProduceStepName,isnull(d.ToolID,'''')ToolID ,isnull(d.MachineryEquipmentID,'''') MachineryEquipmentID
					,isnull(d.ProductionLineID,'''')ProductionLineID ,isnull(d.ShiftTypeID,'''')ShiftTypeID ,isnull(d.RepeatCount1,0)RepeatCount1 
					,isnull(d.RepeatCount2,0)RepeatCount2 ,isnull(d.RepeatCount3,0)RepeatCount3 ,isnull(d.RepeatCount4,0)RepeatCount4 ,p2.SerialNo  StepSerialNo,d.DescDtl
					,case when ConfirmType=0 then ''انتخاب نشده'' when ConfirmType=1 then ''تایید'' when ConfirmType=2 then ''تایید مشروط'' when ConfirmType=3 then ''تایید ارفاقی'' 
						when ConfirmType=4 then ''عدم تایید'' end ConfirmTypeName,PersonelID,prs.funGetPersonnelName(PersonelID,1) PersonnelName,ConfirmType,NeedRepeat
						, pln.funGetProductionLineName(ProductionLineID,1)ProductionLineName,	emp.funGetShiftTypeName(ShiftTypeID,1) ShiftTypeName
			from pln.tblTaskOrderHdr a 
				inner join  pln.tblTaskOrderDtl d    on a.ProcessID=d.ProcessID   and a.ProcessNo=d.ProcessNo and a.FiscalYear=d.FiscalYear  and a.SerialNo=d.SerialNo 
				inner join pln.tblProduceStepDtl  p2 on a.ProductID=p2.ProductID and p2.SerialNo=a.ProduceStepSerialNo and p2.ProduceStepID=d.ProduceStepID
				left join  pln.tblTaskOrderOperators  p on d.ProcessID=p.ProcessID and d.ProcessNo=p.ProcessNo and d.FiscalYear=p.FiscalYear and d.SerialNo=p.SerialNo and d.DocRowNo=p.RowNo
				left join   inv.tblGoodsDtl g on SUBSTRING( a.ProductID,'+str(@str_Goods+1)+' ,'+str(@str_GoodsSum)+')=g.GoodsID   and PartNumber ='+str(@UnitPart)+'
				left join   inv.tblStorageDocsDtl s on  s.BaseProcessID=d.ProcessID and s.BaseProcessNo=d.ProcessNo and s.BaseFiscalYear=d.FiscalYear and s.BaseSerialNo=d.SerialNo and s.BaseDocRowNo=d.DocRowNo and s.ProcessID=72  
			where  Suspend=0 and a.ProductID='''+ @ProductID + ''' and a.DocDate='''+ @DocDate +''' and a.ProcessNo= '+ str(@ProcessNo)+@StrWhere +'
			order by a.ProductID,d.FiscalYear,d.SerialNo,d.ProduceStepID'
end
else
	set @StrSelect='
		select 	 Distinct bb.BaseProcessNo OrderProcessNo ,  bb.BaseSerialNo OrderSerialNo, a.BaseProcessNo,  a.BaseSerialNo,a.BaseDocRowNo, a.ProdDocRowNo
				,isnull(a.BatchNo,'''') BatchNo,a.ProductID,d.ProcessID,d.ProcessNo,d.FiscalYear,d.SerialNo,d.RowNo,d.DocRowNo, a.DocDate,StartDate,FinishDate, AcceptableCount+UnacceptableCount OrderCount ,bb.ProductCount,b.DocStep
				,prs.funGetHourMinutesStandard((select isnull( sum(fi.FaultTime),''0'') from  pln.tblFaultItems fi 
													where d.ProcessID=fi.ProcessID and d.ProcessNo=fi.ProcessNo and d.FiscalYear=fi.FiscalYear and d.SerialNo=fi.SerialNo and d.DocRowNo=fi.DocRowNo)/60)FaultTime
				,GoodsName ProductName,TotalTime/60 Times,StartTime,AcceptableCount,UnacceptableCount,isnull(OperatorID, '''')OperatorID,prs.funGetPersonnelName(OperatorID,1) OperatorIDName,isnull(TaskOrderOperatorID,0)TaskOrderOperatorID
				,d.ProduceStepID,p2.ProduceStepName,isnull(d.ToolID,'''')ToolID ,isnull(d.MachineryEquipmentID,'''') MachineryEquipmentID
				,isnull(d.ProductionLineID,'''')ProductionLineID ,isnull(d.ShiftTypeID,'''')ShiftTypeID ,isnull(d.RepeatCount1,0)RepeatCount1 
				,isnull(d.RepeatCount2,0)RepeatCount2 ,isnull(d.RepeatCount3,0)RepeatCount3 ,isnull(d.RepeatCount4,0)RepeatCount4 	,p2.SerialNo  StepSerialNo	,d.DescDtl
				,case when ConfirmType=0 then ''انتخاب نشده'' when ConfirmType=1 then ''تایید'' when ConfirmType=2 then ''تایید مشروط'' when ConfirmType=3 then ''تایید ارفاقی'' 
					when ConfirmType=4 then ''عدم تایید'' end ConfirmTypeName,PersonelID,prs.funGetPersonnelName(PersonelID,1) PersonnelName,ConfirmType,NeedRepeat
					, pln.funGetProductionLineName(d.ProductionLineID,1)ProductionLineName,	emp.funGetShiftTypeName(d.ShiftTypeID,1) ShiftTypeName
		from pln.tblTaskOrderHdr a 
			inner join  pln.tblTaskOrderDtl d    on a.ProcessID=d.ProcessID   and a.ProcessNo=d.ProcessNo and a.FiscalYear=d.FiscalYear  and a.SerialNo=d.SerialNo 
			inner join pln.tblProduceOrderHdr  b on b.ProcessID=a.BaseProcessID  and b.ProcessNo=a.BaseProcessNo and b.FiscalYear=a.BaseFiscalYear and b.SerialNo=a.BaseSerialNo      
			inner join pln.tblProduceOrderDtl  bb on  bb.ProcessID=a.BaseProcessID  and bb.ProcessNo=a.BaseProcessNo and bb.FiscalYear=a.BaseFiscalYear and bb.SerialNo=a.BaseSerialNo    and bb.DocRowNo=a.ProdDocRowNo  
			inner join pln.tblAvailProduceOrders  ab on  ab.ProcessID=a.BaseProcessID  and ab.ProcessNo=a.BaseProcessNo and ab.FiscalYear=a.BaseFiscalYear and ab.SerialNo=a.BaseSerialNo    and ab.DocRowNo=a.BaseDocRowNo  and ab.BaseDocRowNo=bb.DocRowNo
			inner join pln.tblProduceStepDtl  p2 on a.ProductID=p2.ProductID and p2.SerialNo=a.ProduceStepSerialNo and p2.ProduceStepID=d.ProduceStepID
			left join  pln.tblTaskOrderOperators  p on d.ProcessID=p.ProcessID and d.ProcessNo=p.ProcessNo and d.FiscalYear=p.FiscalYear and d.SerialNo=p.SerialNo and d.DocRowNo=p.RowNo
			left join   inv.tblGoodsDtl g on SUBSTRING( a.ProductID,'+str(@str_Goods+1)+' ,'+str(@str_GoodsSum)+')=g.GoodsID   and PartNumber ='+str(@UnitPart)+' 
			left join   inv.tblStorageDocsDtl s on  s.BaseProcessID=d.ProcessID and s.BaseProcessNo=d.ProcessNo and s.BaseFiscalYear=d.FiscalYear and s.BaseSerialNo=d.SerialNo and s.BaseDocRowNo=d.DocRowNo and s.ProcessID=72  
		where  Suspend=0 and  ((b.FiscalYear ='+ str(@BaseFiscalYear)+' and b.SerialNo =  '+ str(@BaseSerialNo) +') or (a.ProductID='''+ @ProductID + ''' and a.FiscalYear='+ str(@FiscalYear) +' and a.SerialNo='+ str(@SerialNo)+'))
			and a.ProcessNo= '+ str(@ProcessNo) +@StrWhere+'
		order by a.ProductID,d.FiscalYear,d.SerialNo,d.ProduceStepID'

	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;
		
end
end --@CallType
if @CallType=33 
begin
	
	SET @ProcessID				 = pub.funSplitString(@ExtraParams, '@', 1);
	SET @ProcessNo				 = pub.funSplitString(@ExtraParams, '@', 2);
	SET @FiscalYear				 = pub.funSplitString(@ExtraParams, '@', 3);
	SET @SerialNo				 = pub.funSplitString(@ExtraParams, '@', 4);
	SET @DocRowNo				 = pub.funSplitString(@ExtraParams, '@', 5);
	SET @DocDate				 = pub.funSplitString(@ExtraParams, '@', 6);
	SET @SessionNo				 = pub.funSplitString(@ExtraParams, '@', 7);	
	
	Set @BaseProcessID=@ProcessID
	Set @BaseProcessNo=@ProcessNo
	Set @BaseFiscalYear=@FiscalYear
	Set @BaseSerialNo=@SerialNo
	Set @BaseDocRowNo=@DocRowNo
	--select @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@DocRowNo,@DocDate,@SessionNo
	if @Pln_AllocationOfGoodsByTransfer='False'
	begin
	create table #tbl_UseSimilar34
			(
				ProductID		varchar(20) collate arabic_cs_as not null,
				GoodsID			varchar(20) collate arabic_cs_as not null,
				Quantity		float not null,
				SubUnitQuantity float not null,
				UnitID			varchar(20) collate arabic_cs_as not null,
				DefaultStoreID 	varchar(20) collate arabic_cs_as not null,
				ProductCount	float not null,
				DocRowNo		int not null,
				DescDtl			Nvarchar(4000),
				ExtraField1		nvarchar(200) collate arabic_cs_as not null,
				ExtraField2		nvarchar(200) collate arabic_cs_as not null,
				ExtraField3		nvarchar(200) collate arabic_cs_as not null,
				ExtraField4		nvarchar(200) collate arabic_cs_as not null,
				ExtraField5		nvarchar(200) collate arabic_cs_as not null,
				GoodsName 		nvarchar(200) collate arabic_cs_as not null,
				UnitID2			varchar(20) collate arabic_cs_as not null,
				UnitName 		nvarchar(200) collate arabic_cs_as not null,
				Balance			float not null,
				SubBalance			float not null		
			)		

	select @PrdProductManyStores=SettingValue from pub.tblSettings
		where SettingKey='PrdProductManyStores'
				
	SELECT @ProductID=ProductID,@FormulaNo=FormulaNo ,@OrderCount=OrderCount,@AcntCode=ProducerAcntCode FROM pln.tblTaskOrderHdr 
		where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear	=@FiscalYear and SerialNo	=@SerialNo	

	SELECT @ProductQty=case when AcceptableCount>0 then AcceptableCount else UnacceptableCount end ,@ProduceStepID=ProduceStepID,@ProduceStepSerialNo=ProduceStepSerialNo FROM pln.tblTaskOrderDtl
		where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear	=@FiscalYear and SerialNo=@SerialNo	and DocRowNo=@DocRowNo	

	select @AcceptStoreID=AcceptStoreID,@UsageStoreID1=UsageStoreID,@FailedStoreID=FailedStoreID,@LossStoreID=LossStoreID	from pln.tblProduceStepDtl  
		where ProductID=@ProductID	and SerialNo=@ProduceStepSerialNo	and ProduceStepID=@ProduceStepID       
	       		 
	IF @AcceptStoreID=''
		BEGIN
			Raiserror (' انبار منطبق خالی است',16,1)
			Return
		END
	IF @UsageStoreID1=''
		BEGIN
			Raiserror (' انبار مواد اولیه خالی است',16,1)
			Return
		END
			
	select @MinProduceStepID=min(ProduceStepID)	from pln.tblProduceStepDtl  
		where ProductID=@ProductID	and SerialNo=@ProduceStepSerialNo

--select  @MinProduceStepID,@ProductID,@ProductQty,@FormulaNo,@DocDate,@UsageStoreID1,@RP,N'1@1@1'
	create table #tblProductGoodsQty34
		(
			RowNumber		int,
			ProductID		varchar(20) collate arabic_cs_as not null,
			GoodsID			varchar(20) collate arabic_cs_as not null,
			Quantity		float not null,
			SubUnitQuantity float not null,
			UnitID			varchar(20) collate arabic_cs_as not null,
			ProductCount	float not null,
			DefaultStoreID 	varchar(20) collate arabic_cs_as not null,
			GoodsID2			varchar(20) collate arabic_cs_as not null,
			AcceptStoreID 	varchar(20) collate arabic_cs_as not null,
			FailedStoreID 	varchar(20) collate arabic_cs_as not null,
			UserPriceID		int
		)
		
	if @MinProduceStepID=@ProduceStepID
	begin
	if @Pln_InFrmDoingGroupsProduceStore1Step2Formula=1
		begin
		if @PrdProductManyStores= 1
			set @RP='00001'
		else
			set @RP='000011'
		end 
	else
		begin
		if @PrdProductManyStores= 1
			set @RP='00000'
		else
			set @RP='000001'
		end 
		
		
	--	select @ProductID,@ProductQty,@FormulaNo,@DocDate,@UsageStoreID1,@RP,N'1@1@1'
		
		insert into #tbl_UseSimilar34
		exec [prd].[SpPrd_ProductGoods_One_UseSimilar] @ProductID=@ProductID,@ProductQty=@ProductQty,@SerialNo=@FormulaNo
			,@DocDateTo=@DocDate,@StoreID=@UsageStoreID1,@RepOptions=@RP,@RepInfo=N'1@1@1'
		
		insert into #tblProductGoodsQty34
			select ROW_NUMBER() OVER(ORDER BY GoodsID DESC) AS RowNumber ,ProductID, GoodsID, Quantity,SubUnitQuantity,UnitID, ProductCount,DefaultStoreID,GoodsID
				,@AcceptStoreID,@FailedStoreID,0
			from #tbl_UseSimilar34	
	end
	else
	begin
		insert into #tblProductGoodsQty34
		select 1,@ProductID, @ProductID, @ProductQty,@ProductQty,(
				Select UnitID 
				from inv.tblGoods 
				where SUBSTRING( @ProductID,@str_Goods+1 ,@str_GoodsSum)=GoodsID   and PartNumber =@UnitPart)
			, @OrderCount,@UsageStoreID1,@ProductQty,@AcceptStoreID,@FailedStoreID,0
	end
	
	delete from  pln.tblProductGoodsQtyDtl
		where BaseProcessID=@ProcessID and BaseProcessNo=@ProcessNo and BaseFiscalYear=@FiscalYear and BaseSerialNo=@SerialNo and BaseDocRowNo=@DocRowNo
  	  
	if (Select Count(*) from  pln.tblProductGoodsQtyHdr where ProcessID=82 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo)<=0
		insert into pln.tblProductGoodsQtyHdr(ProcessID,ProcessNo,FiscalYear,SerialNo)									
			select  Distinct  82,@ProcessNo,@FiscalYear,@SerialNo 
	 
	insert into pln.tblProductGoodsQtyDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID
										,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo
										,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,ProductCount,BatchNo,ParamKind,UserPriceID)									
	select 82,@ProcessNo,@FiscalYear,@SerialNo ,RowNumber,RowNumber,RowNumber,@DocDate
			,DefaultStoreID ,-1	 ,@AcntCode,GoodsID,UnitID,SubUnitQuantity,Quantity
				,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@DocRowNo,@FormulaNo,ProductCount
				,isnull((case when (
					select count(*) 
					from inv.tblGoods  
					where SUBSTRING( #tblProductGoodsQty34.GoodsID,@str_Goods+1 ,@str_GoodsSum)=inv.tblGoods.GoodsID   and PartNumber =@UnitPart and inv.tblGoods.HasBatchNo=1)>0
								And (
									select count(*) 
									from prd.tblFormulasDtl  
									where ProductID=#tblProductGoodsQty34.GoodsID)>0							
				then   @BatchNo else ''   end),'') BatchNo,0,UserPriceID

	 from #tblProductGoodsQty34
	
	--select * from #tblProductGoodsQty34
	-----------------ضایعات------------------------------------------
 	select @MaxSerialNo=isnull(Max(SerialNo),0)+1 from   pln.tblSecondaryProductByFormulaTempHdr
	set @BaseSerialNo=ISNULL (@BaseSerialNo,0)

	 if (Select Count(*) from  pln.tblSecondaryProductByFormulaTempHdr 	where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo)<=0
	 	insert into pln.tblSecondaryProductByFormulaTempHdr(ProcessID,ProcessNo,FiscalYear,SerialNo,BaseProcessID	,BaseProcessNo	,BaseFiscalYear	,BaseSerialNo	, BaseDocRowNo,RecID	,SessionNo	)									
			select  Distinct  72,@ProcessNo,@BaseFiscalYear,@MaxSerialNo,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,0,0
		else
		Select @MaxSerialNo=SerialNo from  pln.tblSecondaryProductByFormulaTempHdr 	where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo

	delete from  pln.tblSecondaryProductByFormulaTempDtl
		where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo

	insert into pln.tblSecondaryProductByFormulaTempDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID
										,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo
										,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,ProductCount,BatchNo)									
	select 72,@ProcessNo,@BaseFiscalYear,@MaxSerialNo --,RowNo,DocRowNo,DocRowNo
		,DocRowNo+(select isnull(Max(DocRowNo),0) from pln.tblSecondaryProductByFormulaTempDtl a where a.ProcessID=72  and a.ProcessNo=@ProcessNo and a.FiscalYear=@BaseFiscalYear and a.SerialNo=@MaxSerialNo)
		,DocRowNo+(select isnull(Max(DocRowNo),0) from pln.tblSecondaryProductByFormulaTempDtl a where a.ProcessID=72  and a.ProcessNo=@ProcessNo and a.FiscalYear=@BaseFiscalYear and a.SerialNo=@MaxSerialNo)
		,DocRowNo+(select isnull(Max(DocRowNo),0) from pln.tblSecondaryProductByFormulaTempDtl a where a.ProcessID=72  and a.ProcessNo=@ProcessNo and a.FiscalYear=@BaseFiscalYear and a.SerialNo=@MaxSerialNo)		
	,@DocDate			,'' ,1	 ,@AcntCode,GoodsID,UnitID,GoodsQuantity,GoodsQuantity
				,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@FormulaNo,GoodsQuantity
				,isnull((case when (
						select count(*) 
						from inv.tblGoods  
						where SUBSTRING( p.ProductID,@str_Goods+1 ,@str_GoodsSum)=inv.tblGoods.GoodsID   and PartNumber =@UnitPart and inv.tblGoods.HasBatchNo=1)>0
								And (
									select count(*) 
									from prd.tblFormulasDtl  
									where ProductID= p.ProductID)>0							
						then   @BatchNo else '' end ),'') BatchNo

	from  prd.tblSecondaryProductByFormulaDtl p
	where   ProductID=@ProductID and SerialNo=@FormulaNo
	and @ProduceStepID = ( Select 	min(ProduceStepID)	from pln.tblProduceStepDtl  where ProductID=@ProductID	and SerialNo=@ProduceStepSerialNo	)
	--and @BaseDocRowNo=1  -- به خاطر اینکه ضایعات در مرحله اول تولید شود

	--select * from pln.tblSecondaryProductByFormulaTempDtl where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
	--select * from prd.tblSecondaryProductByFormulaDtl  where  ProductID=@ProductID and SerialNo=@FormulaNo

	update pln.tblSecondaryProductByFormulaTempDtl
		set GoodsQuantity=(AcceptableCount+UnacceptableCount)* s.ProductCount/  fh.ProductCount
			, SubUnitQuantity=(AcceptableCount+UnacceptableCount)* s.ProductCount/  fh.ProductCount			
	from pln.tblSecondaryProductByFormulaTempDtl s
		inner join pln.tblTaskOrderDtl td 		on s.BaseProcessID=td.ProcessID		and  s.BaseProcessNo=td.ProcessNo		and  s.BaseFiscalYear=td.FiscalYear		and  s.BaseSerialNo=td.SerialNo		and  s.BaseDocRowNo=td.DocRowNo
		inner join pln.tblTaskOrderHdr th 		on th.ProcessID=td.ProcessID		and  th.ProcessNo=td.ProcessNo		and  th.FiscalYear=td.FiscalYear		and  th.SerialNo=td.SerialNo		
		inner join prd.tblFormulasHdr fh on fh.ProductID=th.ProductID and fh.SerialNo=th.FormulaNo and (@prdFormulaWithAccept=0 or fh.AcceptFormula='True')

		-----------------------------------------------------------	
	--select c.* 
	update  pln.tblProductGoodsQtyDtl 
	set UserPriceID=c.ID
	from  pln.tblProductGoodsQtyDtl a
	inner join inv.tblGoods b on a.GoodsID=b.GoodsID and b.ActiveUserPrice =1
	inner join inv.tblGoodsUserPrice c on a.GoodsID=c.GoodsID and c.UserPrice=b.UserPrice
	where
	ProcessID=82	and  
	ProcessNo=@BaseProcessNo
	and  FiscalYear=@BaseFiscalYear
	and  SerialNo=@BaseSerialNo-----------------------------------------------------------	
	end 
	else
	begin
		delete from  pln.tblProductGoodsQtyHdr
		where ProcessID=@ProcessID and ProcessNo=@BaseProcessNo and FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo

		delete from  pln.tblProductGoodsQtyDtl
		where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo
	
		if (Select Count(*) from  pln.tblProductGoodsQtyHdr where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo)<=0
			insert into pln.tblProductGoodsQtyHdr(ProcessID,ProcessNo,FiscalYear,SerialNo)									
			select  Distinct  @ProcessID,@ProcessNo,@BaseFiscalYear,@BaseSerialNo 
		 
		  insert into pln.tblProductGoodsQtyDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID
											,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo
											,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,ProductCount,BatchNo,ParamKind,UserPriceID)									
			Select 82,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo ,RowNo,DocRowNo,VolumeRowNo,@DocDate,StoreID 
					,-1	 ,@AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity ,@BaseProcessID,@BaseProcessNo
					,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@FormulaNo,1 ProductCount,BatchNo,0,UserPriceID
			From inv.tblStorageDocsDtl b 
				where TaskSerialNo= @BaseSerialNo and TaskFiscalYear=@BaseFiscalYear and ProcessID=125			
	end
end
if @CallType=44
	begin
	 
	SET @ProcessID				 = pub.funSplitString(@ExtraParams, '@', 1);
	SET @ProcessNo				 = pub.funSplitString(@ExtraParams, '@', 2);
	SET @FiscalYear				 = pub.funSplitString(@ExtraParams, '@', 3);
	SET @SerialNo				 = pub.funSplitString(@ExtraParams, '@', 4);
	SET @DocRowNo				 = pub.funSplitString(@ExtraParams, '@', 5);
	SET @DocDate				 = pub.funSplitString(@ExtraParams, '@', 6);
	SET @SessionNo				 = pub.funSplitString(@ExtraParams, '@', 7);
	
	set @BaseProcessID=@ProcessID
	set @BaseProcessNo=@ProcessNo
	set @BaseFiscalYear=@FiscalYear
	set @BaseSerialNo=@SerialNo
	set @BaseDocRowNo=@DocRowNo
	
	select @SerialNo82=isnull(Max(SerialNo),0)+1 from inv.tblStorageDocsHdr 
		where ProcessID=82 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear
 	if (Select Count(*) from pln.tblProductGoodsQtyDtl p	
			where p.ProcessID= 82 and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@SerialNo and  p.BaseDocRowNo=@DocRowNo
			)<1
		begin
			raiserror ('مشکل خالی بودن جدول محاسبه مواد', 16, 1)
			return			
		end
 	select  ProcessID,ProcessNo,FiscalYear,@SerialNo82 SerialNo, RowNo, DocRowNo, VolumeRowNo,@DocDate DocDate
				,StoreID ,-1	 EnterKind,@AcntCode AcntCode,GoodsID,SubUnitID, SubUnitQuantity, GoodsQuantity
						,@BaseProcessID BaseProcessID,@BaseProcessNo BaseProcessNo,@BaseFiscalYear BaseFiscalYear,@BaseSerialNo BaseSerialNo
						,@BaseDocRowNo BaseDocRowNo,@FormulaNo FormulaNo,ProductCount
						,(case when BatchNo<> '' then BatchNo else case when 
							(select count(*) from inv.tblGoods  
								where SUBSTRING( p.GoodsID,@str_Goods+1 ,@str_GoodsSum)=inv.tblGoods.GoodsID   and PartNumber =@UnitPart and inv.tblGoods.HasBatchNo=1)>0
								And (
									select count(*) 
									from prd.tblFormulasDtl  
									where ProductID=p.GoodsID)>0							
							then   @BatchNo else '' end end ) BatchNo
							,cast (0 as float ) Qty, UserPriceID
	Into #tblGoodsQty44
	from pln.tblProductGoodsQtyDtl p
	where p.ProcessID= 82 and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@SerialNo 
	and  p.BaseDocRowNo=@DocRowNo
		
	--select * 	 from pln.tblProductGoodsQtyDtl p
	--	 where p.ProcessID= 82 and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@SerialNo 
	--	 and  p.BaseDocRowNo=@DocRowNo
	
	
	update #tblGoodsQty44
	Set Qty=[inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,StoreID,GoodsID,BatchNo,DocDate,0)
		, AcntCode=isnull(AcntCode,'')

	DECLARE csr CURSOR FOR 
		SELECT GoodsQuantity,Qty,GoodsID,StoreID
		FROM #tblGoodsQty44
	
	OPEN csr
	FETCH NEXT FROM csr INTO @Qty1, @Qty2,@GoodsID,@StoreID

	WHILE @@Fetch_Status = 0
	BEGIN
		if @Qty1> @Qty2
				set @StrError=@StrError +' ('+ ' مشکل موجودی کالای '+ @GoodsID +'  در انبار '+ @StoreID +' موجودی کالا '+ str(@Qty2,20,5) +'  مورد نیاز '+ str(@Qty1,20,5) +'  ) '
		FETCH NEXT FROM csr INTO @Qty1, @Qty2,@GoodsID,@StoreID
		
	END

	CLOSE csr
	DEALLOCATE csr
	
	if @StrError<>''
		begin
			raiserror (@StrError, 16, 1)
			return			
		end   	
	SELECT @ProductID=ProductID,@FormulaNo=FormulaNo ,@OrderCount=OrderCount,@AcntCode=ProducerAcntCode FROM pln.tblTaskOrderHdr 
		where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear	=@FiscalYear and SerialNo	=@SerialNo	

	SELECT @ProductQty=case when AcceptableCount>0 then AcceptableCount else UnacceptableCount end ,@ProductQtyUnaccept=UnacceptableCount,@ProduceStepID=ProduceStepID,@ProduceStepSerialNo=ProduceStepSerialNo FROM pln.tblTaskOrderDtl
		where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear	=@FiscalYear and SerialNo=@SerialNo	and DocRowNo=@DocRowNo	

	select @AcceptStoreID=AcceptStoreID,@UsageStoreID1=UsageStoreID,@FailedStoreID=FailedStoreID,@LossStoreID=LossStoreID		from pln.tblProduceStepDtl  
		where ProductID=@ProductID	and SerialNo=@ProduceStepSerialNo	and ProduceStepID=@ProduceStepID                              

	set @BatchNo=''

	if @AcceptStoreID<>''
	begin
		select @StoreIDCount=Count(*) from inv.tblStores where StoreID=@AcceptStoreID
		if @StoreIDCount=0
			set @StrError=@StrError +' ('+ ' مشکل وجود انبار  '+ @AcceptStoreID +' برای سفارش کارتولید مربوطه ) '
	end 
	if @UsageStoreID1<>''
	begin
		select @StoreIDCount=Count(*) from inv.tblStores where StoreID=@UsageStoreID1
		if @StoreIDCount=0
			set @StrError=@StrError +' ('+ ' مشکل وجود انبار  '+ @UsageStoreID1 +' برای سفارش کارتولید مربوطه ) '
	end 
	if @FailedStoreID<>''
	begin
		select @StoreIDCount=Count(*) from inv.tblStores where StoreID=@FailedStoreID
		if @StoreIDCount=0
			set @StrError=@StrError +' ('+ ' مشکل وجود انبار  '+ @FailedStoreID +' برای سفارش کارتولید مربوطه ) '
	end 
		
	if @StrError<>''
	begin
		raiserror (@StrError, 16, 1)
		return			
	end 
	 
	BEGIN TRANSACTION
	BEGIN TRY 	 	
	 
	 
 --select * from #tblGoodsQty44
  
 --select *  from pln.tblProductGoodsQtyDtl p
	--		 where p.ProcessID= 82 and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo and  p.BaseDocRowNo=@BaseDocRowNo

		delete from pln.tblProductGoodsQtyDtl where GoodsQuantity=0 or SubUnitQuantity=0
 
	  ------82-------------------------------------------------------------
		if (Select Count(*) from pln.tblProductGoodsQtyDtl p				
			 where p.ProcessID= 82 and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo and  p.BaseDocRowNo=@BaseDocRowNo
			)<1
		begin
			raiserror ('مشکل خالی بودن جدول محاسبه مواد', 16, 1)
			return			
		end
 		insert into inv.tblStorageDocsHdr( ProcessID,ProcessNo,FiscalYear,SerialNo,FormulaNo,DocDate,StoreID,AcntCode,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,DocDesc,ProductCount,ProductID,RecID,SessionNo,DocDate2,DocDate3)
		select 82,@ProcessNo,@FiscalYear,@SerialNo82,@FormulaNo,@DocDate,'',@AcntCode,@BaseProcessID,@ProcessNo,@FiscalYear,@SerialNo,'ثبت خودکار توسط سيستم - مربوط به سفارش کار توليد شماره '+str(@SerialNo) ,@ProductQty ,@ProductID,@RecID,@SessionNo,@DocDate,@DocDate

		insert into inv.tblStorageDocsDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,FormulaProductCount,BatchNo,UserPriceID)									
		select 82,@ProcessNo,@BaseFiscalYear,@SerialNo82 ,RowNo,DocRowNo,VolumeRowNo,@DocDate,StoreID ,-1	 ,@AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@FormulaNo,ProductCount,BatchNo ,UserPriceID
			 from pln.tblProductGoodsQtyDtl p
			 where p.ProcessID= 82 and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo and  p.BaseDocRowNo=@BaseDocRowNo
	 	 
	  ------72-------------------------------------------------------------
		Set @ProcessID72=case when @ProductQtyUnaccept=0 then 72 else 73 end 

		select @SerialNo72=isnull(Max(SerialNo),0)+1 from inv.tblStorageDocsHdr 
		where ProcessID=@ProcessID72 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear
  	
		insert into inv.tblStorageDocsHdr( ProcessID,ProcessNo,FiscalYear,SerialNo,FormulaNo,DocDate,StoreID,AcntCode,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,DocDesc,ProductCount,ProductID,RecID,SessionNo,DocDate2,DocDate3,BatchNo)
		select  @ProcessID72 ,@ProcessNo,@BaseFiscalYear,@SerialNo72,@FormulaNo,@DocDate,case when @ProductQtyUnaccept=0 then @AcceptStoreID else @FailedStoreID end  ,@AcntCode,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,'ثبت خودکار توسط سيستم - مربوط به سفارش کار توليد شماره '+str(@BaseSerialNo),case when @AcceptableCount>0 then @AcceptableCount else @UnacceptableCount end ,@ProductID,@RecID,@SessionNo,@DocDate,@DocDate,@BatchNo
		
		insert into inv.tblStorageDocsDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,FormulaProductCount,BatchNo,UserPriceID)									
		select  top 1 @ProcessID72 ,@ProcessNo,@BaseFiscalYear,@SerialNo72			,1,1,1001				,@DocDate,case when @ProductQtyUnaccept=0 then @AcceptStoreID else @FailedStoreID end ,1	 ,@AcntCode,@ProductID,(Select UnitID from inv.tblGoods where SUBSTRING( @ProductID,@str_Goods+1 ,@str_GoodsSum)=GoodsID   and PartNumber =@UnitPart ),@ProductQty,@ProductQty,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@FormulaNo,ProductCount, @BatchNo ,UserPriceID
			 from pln.tblProductGoodsQtyDtl p
			 where p.ProcessID= 82 and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo and  p.BaseDocRowNo=@BaseDocRowNo
	
		--delete from inv.tblStorageDocsSerials
		--	where ProcessID= 82 and ProcessNo= @ProcessNo and FiscalYear= @BaseFiscalYear and  SerialNo=@BaseSerialNo 

		--insert into inv.tblStorageDocsSerials(ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,AtomRowNo,DocAtomRowNo,ProductSerialID,EventNo,BatchNo,ExpireDate,PSerialNo,StoreID,EnterKind)
		--						select    @ProcessID-10,@ProcessNo,@BaseFiscalYear,@SerialNo72 ,1,DocRowNo,RowNo,ProductSerialID	,1,		@BatchNo,'',PSerialNo,@AcceptStoreID,1
		--	 from pln.tblProductGoodsSerialDtl p
		--	 where p.ProcessID= 82 and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo 
	  ------72-------------------------------------------------------------
	  if ( select count(*) from  pln.tblSecondaryProductByFormulaTempDtl  	where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo)>0
	 begin
	 
	 IF @LossStoreID=''
		BEGIN
			Raiserror (' انبار ضایعات خالی است',16,1)
			Return
		END

		insert into inv.tblStorageDocsDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID
											,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo
											,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,FormulaProductCount,BatchNo)									
		select  @ProcessID72,@ProcessNo,@FiscalYear,@SerialNo72 ,DocRowNo+1,DocRowNo+1,1001,@DocDate,@LossStoreID 
					,1	 ,@AcntCode,GoodsID,SubUnitID ,SubUnitQuantity,GoodsQuantity
					,@BaseProcessID,@BaseProcessNo
					,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@FormulaNo,GoodsQuantity
					,case when BatchNo <>''  then BatchNo else @BatchNo end 
			from  pln.tblSecondaryProductByFormulaTempDtl p
			where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
			and GoodsQuantity>0
			and BaseDocRowNo=1
			-- به خاطر اینکه ضایعات در مرحله اول تولید شود
	 end
		COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			Set @StrErrorMessage = ERROR_MESSAGE() 
			raiserror (@StrErrorMessage, 16, 1)
			ROLLBACK TRANSACTION
		END CATCH	 	
	-------------------------------------------------------------------
	 update pln.tblTaskOrderHdr
		set TaskStateID=4
		from  pln.tblTaskOrderHdr a
		inner join
		 (select  sum(GoodsQuantity * EnterKind) Qty, GoodsID,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo
		from inv.tblStorageDocsDtl b  
		where  ProcessID=72 and BaseProcessID = @ProcessID and BaseProcessNo =@ProcessNo 	and BaseFiscalYear= @FiscalYear and BaseSerialNo=@SerialNo		
		group by  GoodsID,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo
		)	bb
		on 	a.ProcessID = bb.BaseProcessID and a.ProcessNo =bb.BaseProcessNo 	and a.FiscalYear= bb.BaseFiscalYear and a.SerialNo=bb.BaseSerialNo 
		where a.ProcessID = @BaseProcessID and a.ProcessNo =@BaseProcessNo 	and a.FiscalYear= @BaseFiscalYear and a.SerialNo=@BaseSerialNo
		and bb.Qty =a.OrderCount* (Select COUNT(*)  from pln.tblProduceStepDtl  p2 where  a.ProductID=p2.ProductID and p2.SerialNo=a.ProduceStepSerialNo and NeedStep=1)

	-------------------------------------------------------------------
 
	end 
if @CallType=3 or  @CallType=4
begin
	
	SET @BaseProcessID				 = pub.funSplitString(@ExtraParams, '@', 1);
	SET @BaseProcessNo				 = pub.funSplitString(@ExtraParams, '@', 2);
	SET @BaseFiscalYear				 = pub.funSplitString(@ExtraParams, '@', 3);
	SET @BaseSerialNo				 = pub.funSplitString(@ExtraParams, '@', 4);
	SET @BaseDocRowNo				 = pub.funSplitString(@ExtraParams, '@', 5);
	SET @FormulaNo					 = pub.funSplitString(@ExtraParams, '@', 6);
	SET @DocDate					 = pub.funSplitString(@ExtraParams, '@', 7);
	SET @AcceptStoreID				 = pub.funSplitString(@ExtraParams, '@', 8);
	SET @FailedStoreID				 = pub.funSplitString(@ExtraParams, '@', 9);
	SET @UsageStoreID1				 = pub.funSplitString(@ExtraParams, '@', 10);
	SET @UsageStoreID3				 = pub.funSplitString(@ExtraParams, '@', 11);
	SET @UsageStoreID4				 = pub.funSplitString(@ExtraParams, '@', 12);
	SET @AcntCode					 = pub.funSplitString(@ExtraParams, '@', 13);
	SET @AcceptableCount			 = pub.funSplitString(@ExtraParams, '@', 14);
	SET @UnacceptableCount			 = pub.funSplitString(@ExtraParams, '@', 15);
	SET @ProductID					 = pub.funSplitString(@ExtraParams, '@', 16);
	SET @RecID						 = pub.funSplitString(@ExtraParams, '@', 17);
	SET @SessionNo					 = pub.funSplitString(@ExtraParams, '@', 18);
	SET @BatchNo					 = pub.funSplitString(@ExtraParams, '@', 19);
	SET @LossStoreID				 = pub.funSplitString(@ExtraParams, '@', 20);
	
		select @ProcessID=82
			set @ProcessNo=@BaseProcessNo
		delete  from   inv.tblStorageDocsHdr    -- select a.* 
		from   inv.tblStorageDocsHdr  a 
		inner join inv.tblStorageDocsDtl  b  on a.ProcessID = b.ProcessID  and a.ProcessNo =b.ProcessNo  and a.FiscalYear =b.FiscalYear  and a.SerialNo=b.SerialNo  
		where b.BaseProcessID = @BaseProcessID and b.BaseProcessNo =@BaseProcessNo 	and b.BaseFiscalYear= @BaseFiscalYear 
			and b.BaseSerialNo=@BaseSerialNo and  b.BaseDocRowNo=@BaseDocRowNo
 
		set @UsageStoreID2=@UsageStoreID1
		if @UsageStoreID2=''
			set @UsageStoreID2=@UsageStoreID3
		if @UsageStoreID2=''
			set @UsageStoreID2=@UsageStoreID4
		------------------------------------------------
		set @ProductQty=case when @AcceptableCount>0 then @AcceptableCount else @UnacceptableCount end
		------82-------------------------------------------------------------
		
	declare @FiscalYearCnn as int  
	set @FiscalYearCnn =right( DB_NAME() ,4)
		select @SerialNo82=isnull(Max(SerialNo),0)+1 from inv.tblStorageDocsHdr 
		where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYearCnn
 	
  if @CallType=3 
	begin
	
	if @Pln_AllocationOfGoodsByTransfer='False'
	begin
	 create table #tblProductGoodsQty
		(
			RowNumber		int,
			ProductID		varchar(20) collate arabic_cs_as not null,
			GoodsID			varchar(20) collate arabic_cs_as not null,
			Quantity		float not null,
			SubUnitQuantity float not null,
			UnitID			varchar(20) collate arabic_cs_as not null,
			ProductCount	float not null,
			DefaultStoreID 	varchar(20) collate arabic_cs_as not null,
			GoodsID2		varchar(20) collate arabic_cs_as not null,
			ParamKind		int,
			UserPriceID		int
		)
		select * into #tblProductGoodsQtySuspend from #tblProductGoodsQty

	    delete from  pln.tblProductGoodsQtyDtl
		where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
  	  	
		declare @Pln_SuspendTask bit=0
	
		select @Pln_SuspendTask  =SettingValue from pub.tblSettings where SettingKey='Pln_SuspendTask'  
	
		declare @Prd_FormulaExtraParams bit=0
		
		select @Prd_FormulaExtraParams =SettingValue from pub.tblSettings where SettingKey='Prd_FormulaExtraParams'  	
		
		-------فعال بودن تعلیق برای استفاده از محصولات تعلیق شده----------------------
		if @Pln_SuspendTask  ='True'  and @Prd_FormulaExtraParams='False'
		begin		
			--------دارای محصول تعلیق شده---------------------
			if (	select count(*) --BaseProcessID	,BaseProcessNo,	BaseFiscalYear	,BaseSerialNo,BaseDocRowNo,SourceProcessID	,SourceProcessNo,	SourceFiscalYear	,SourceSerialNo,SourceDocRowNo,				* 
							from inv.tblStorageDocsDtl where   1=1  and ProcessID=72 
					and 	BaseProcessID=@BaseProcessID	 and BaseProcessNo=@BaseProcessNo	 and 	BaseFiscalYear	=@BaseFiscalYear	 and BaseSerialNo=@BaseSerialNo	 and 
					SourceProcessID	=@BaseProcessID	 and SourceProcessNo=@BaseProcessNo	 and 	SourceFiscalYear	=@BaseFiscalYear	-- and SourceSerialNo=@BaseSerialNo	 
					and GoodsID=@ProductID
				)>0		
			begin	
			
				declare @QtySUS1  Float				
				declare @QtySUS2  Float				
				declare @QtySUS3  Float				
				declare @QtySUS4  Float				
				declare @QtySUS5  Float				
			 	declare @BatchNoSUS  Varchar(20)
				declare @StoreIDSUS  Varchar(20)
				declare @GoodsQuantitySUS  Float
				declare @ProcessIDSUS int
				declare @ProcessNoSUS int
				declare @FiscalYearSUS int
				declare @SerialNoSUS int
				declare @DocRowNoSUS int
			---------------پیمایش کالاهای تعلیق شده-----------------------------------
				declare curSuspend  cursor for
				select ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,GoodsQuantity,StoreID,BatchNo
							from inv.tblStorageDocsDtl where   1=1  and ProcessID=72 
					and 	BaseProcessID=@BaseProcessID	 and BaseProcessNo=@BaseProcessNo	 and 	BaseFiscalYear	=@BaseFiscalYear	 and BaseSerialNo=@BaseSerialNo	 and 
					SourceProcessID	=@BaseProcessID	 and SourceProcessNo=@BaseProcessNo	 and 	SourceFiscalYear	=@BaseFiscalYear	-- and SourceSerialNo=@BaseSerialNo	 
					and GoodsID=@ProductID
				open curSuspend  
				fetch next  from curSuspend into @ProcessIDSUS,@ProcessNoSUS,@FiscalYearSUS,@SerialNoSUS,@DocRowNoSUS,@GoodsQuantitySUS,@StoreIDSUS,@BatchNoSUS
				while @@Fetch_Status=0 and @ProductQty>0
				begin
				
					------------بدست آوردن تعداد کل تعلیق شده در انبار---
					select @QtySUS1 = Sum(isnull(GoodsQuantity,0))
					from inv.tblStorageDocsDtl where   1=1  and ProcessID=72 
					and 	BaseProcessID=@BaseProcessID	 and BaseProcessNo=@BaseProcessNo	 and 	BaseFiscalYear	=@BaseFiscalYear	 and BaseSerialNo=@BaseSerialNo	 and 
					SourceProcessID	=@BaseProcessID	 and SourceProcessNo=@BaseProcessNo	 and 	SourceFiscalYear	=@BaseFiscalYear
					and GoodsID=@ProductID

					------------بدست آوردن تعداد موجودی در انبار---
					select @QtySUS2=isnull(sum(GoodsQuantity*EnterKind),0) from inv.tblStorageDocsDtl 
					where GoodsID=@ProductID and StoreID=@StoreIDSUS and BatchNo=@BatchNoSUS

					----- تعداد حواله های استفاده شده از تعلیق
					Select  @QtySUS3 = Sum(isnull(GoodsQuantity,0))
					from inv.tblStorageDocsDtl where   ProcessID=82
					and BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo	 
					and SourceProcessID	=0	 and SourceProcessNo=0	 and 	SourceFiscalYear	=0
					and GoodsID=@ProductID					
									
					----- تعداد تعلیق های استفاده شده در جدول محاسبه مواد
					Select  @QtySUS4 = Sum(isnull(GoodsQuantity,0)) 
					from  pln.tblProductGoodsQtyDtl
					where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo 
					and GoodsID=@ProductID

					----- تعداد تعلیق های استفاده شده در جدول محاسبه تعلیقی ها					
					Select  @QtySUS5 = Sum(isnull(Quantity,0)) 
					from  #tblProductGoodsQtySuspend
					where GoodsID=@ProductID
					
					set @QtySUS1=isnull(@QtySUS1,0)
					set @QtySUS2=isnull(@QtySUS2,0)
					set @QtySUS3=isnull(@QtySUS3,0)
					set @QtySUS4=isnull(@QtySUS4,0)
					set @QtySUS5=isnull(@QtySUS5,0)
					
						--select @QtySUS1,@QtySUS2,@QtySUS3,@QtySUS4,@QtySUS5,@GoodsQuantitySUS			
			
					------مقایسه تعداد موجودی و تعداد کل تعلیقی و انتخاب مینیمم----------------------------
					if @QtySUS1>@QtySUS2
						set @QtySUS1=@QtySUS2

						---------کسرتعداد تعلیق استفاده شده برای حواله-----------------------------------------
						set @QtySUS1=@QtySUS1-@QtySUS3
						---------کسرتعداد تعلیق استفاده شده برای محاسبه های قبلی-----------------------------------------
						set @QtySUS1=@QtySUS1-@QtySUS4
						---------کسرتعداد تعلیق استفاده شده در جدول موقت-----------------------------------------
						set @QtySUS1=@QtySUS1-@QtySUS5
						
						-----انتخاب تعداد تلیق شده یا مانده آن------------
					if @QtySUS1>@GoodsQuantitySUS
						SET @QtySUS1=@GoodsQuantitySUS
					
							--	select @QtySUS1
					if @QtySUS1>0
					begin
					---------مقایسه مقدار انتخابی بالا با تعداد تولید و انتخاب عدد کوچکتر ----------------------
						if @ProductQty<@QtySUS1
							set @QtySUS1=@ProductQty
						set @ProductQty=@ProductQty-@QtySUS1
						insert into #tblProductGoodsQtySuspend(RowNumber,ProductID,GoodsID,Quantity,SubUnitQuantity ,UnitID,ProductCount,DefaultStoreID,GoodsID2)
							select (Select Count(*)+1 from #tblProductGoodsQtySuspend ),GoodsID,GoodsID,@QtySUS1,@QtySUS1 ,(( Select UnitID from inv.tblGoods where SUBSTRING( @ProductID,@str_Goods+1 ,@str_GoodsSum)=GoodsID   and PartNumber =@UnitPart )),@QtySUS1,@StoreIDSUS,GoodsID
							from inv.tblStorageDocsDtl 
							where   ProcessID= @ProcessIDSUS and ProcessNo=@ProcessNoSUS and FiscalYear=@FiscalYearSUS and SerialNo =@SerialNoSUS and DocRowNo =@DocRowNoSUS 
					end --@Qty>0

				fetch next  from curSuspend into @ProcessIDSUS,@ProcessNoSUS,@FiscalYearSUS,@SerialNoSUS,@DocRowNoSUS,@GoodsQuantitySUS,@StoreIDSUS,@BatchNoSUS
				end --while
				close curSuspend
				Deallocate curSuspend
			end --(	select count(*) --Ba
		end --@Pln_SuspendTask  ='True' 
	
		declare @Prd_UseSimilarGoodsInProduce bit=0
		
		select @Prd_UseSimilarGoodsInProduce =SettingValue from pub.tblSettings where SettingKey='Prd_UseSimilarGoodsInProduce'  
		
		if @Prd_UseSimilarGoodsInProduce ='True' and @Prd_FormulaExtraParams='False'
		begin
  
			create table #tbl_UseSimilar
			(
				ProductID		varchar(20) collate arabic_cs_as not null,
				GoodsID			varchar(20) collate arabic_cs_as not null,
				Quantity		float not null,
				SubUnitQuantity float not null,
				UnitID			varchar(20) collate arabic_cs_as not null,
				DefaultStoreID 	varchar(20) collate arabic_cs_as not null,
				ProductCount	float not null,
				DocRowNo		int not null,
				DescDtl			Nvarchar(4000),
				ExtraField1		nvarchar(200) collate arabic_cs_as not null,
				ExtraField2		nvarchar(200) collate arabic_cs_as not null,
				ExtraField3		nvarchar(200) collate arabic_cs_as not null,
				ExtraField4		nvarchar(200) collate arabic_cs_as not null,
				ExtraField5		nvarchar(200) collate arabic_cs_as not null,
				GoodsName 		nvarchar(200) collate arabic_cs_as not null,
				UnitID2			varchar(20) collate arabic_cs_as not null,
				UnitName 		nvarchar(200) collate arabic_cs_as not null,
				Balance			float not null,
				SubBalance			float not null
		
			)
			

			select @PrdProductManyStores=SettingValue from pub.tblSettings
			where SettingKey='PrdProductManyStores'
	
			if @Pln_InFrmDoingGroupsProduceStore1Step2Formula=1
				begin
				if @PrdProductManyStores= 1
					set @RP='00001'
				else
					set @RP='000011'
				end 
			else
				begin
				if @PrdProductManyStores= 1
					set @RP='00000'
				else
					set @RP='000001'
				end 	


			 --select  @ProductID,@ProductQty,@FormulaNo,@DocDate,@UsageStoreID1,@RP,N'1@1@1'
		
		insert into #tbl_UseSimilar
			exec [prd].[SpPrd_ProductGoods_One_UseSimilar] @ProductID=@ProductID,@ProductQty=@ProductQty,@SerialNo=@FormulaNo
				,@DocDateTo=@DocDate,@StoreID=@UsageStoreID1,@RepOptions=@RP,@RepInfo=N'1@1@1'

			insert into #tblProductGoodsQty
			select ROW_NUMBER() OVER(ORDER BY GoodsID DESC) AS RowNumber ,ProductID, GoodsID, Quantity,SubUnitQuantity,UnitID, ProductCount,DefaultStoreID,GoodsID,0,0
			from #tbl_UseSimilar
		end
		else
		begin	  
			declare @ProductQty2 as float
			declare @ProductQty3 as float
			
			select @ProductQty2=FmlParam1 ,@ProductQty3=ProductCount from pln.tblTaskOrderHdr a 
				inner join pln.tblProduceOrderDtl  b 
					on a.BaseProcessID=b.ProcessID and a.BaseProcessNo=b.ProcessNo and a.BaseFiscalYear=b.FiscalYear and a.BaseSerialNo=b.SerialNo and a.BaseDocRowNo=b.DocRowNo
				where a.ProcessID=@BaseProcessID and a.ProcessNo=@BaseProcessNo and a.FiscalYear=@BaseFiscalYear and a.SerialNo=@BaseSerialNo
			
			set @ProductQty2=@ProductQty2*@ProductQty/@ProductQty3
		
			insert into #tblProductGoodsQty  
			select	ROW_NUMBER() OVER(ORDER BY GoodsID DESC) AS RowNumber ,H.ProductID, D.GoodsID, 		
				round(sum((case when D.ParamKind=1 then  @ProductQty2/ H.FmlParam1 else @ProductQty / H.ProductCount end ) * D.GoodsQuantity), 5) as Quantity,
				round(sum((case when D.ParamKind=1 then  @ProductQty2/ H.FmlParam1 else @ProductQty / H.ProductCount end ) * D.SubUnitQuantity), 5) as SubUnitQuantity,UnitID, H.ProductCount
				,isnull(D.DefaultStoreID, '') DefaultStoreID, D.GoodsID,D.ParamKind,0
			from	prd.tblFormulasDtl D
					INNER JOIN prd.tblFormulasHdr H on D.SerialNo = H.SerialNo and D.ProductID = H.ProductID  and (@prdFormulaWithAccept=0 or H.AcceptFormula='True')
			where  (H.ProductID = @ProductID) and (H.SerialNo= @FormulaNo)
			group by H.ProductID, D.GoodsID,UnitID, D.DefaultStoreID, ProductCount,D.ParamKind
		end 
	
		declare @Pln_CreateProductFromSaleOrder bit=0
		
		select @Pln_CreateProductFromSaleOrder  =SettingValue from pub.tblSettings where SettingKey='Pln_CreateProductFromSaleOrder'  
		
		insert into #tblProductGoodsQty
		SELECT RowNumber+(SELECT count(*) FROM #tblProductGoodsQty)	,ProductID	,GoodsID	,Quantity	,SubUnitQuantity,	UnitID,	ProductCount	,DefaultStoreID	,GoodsID2,0,UserPriceID
				FROM #tblProductGoodsQtySuspend

		if @Pln_CreateProductFromSaleOrder  ='True' 
		begin
			declare @OrderProcessID int=610
			declare @OrderProcessNo int=1
			declare @OrderFiscalYear int=1399
			declare @OrderSerialNo int =1
 
			select 	@OrderProcessID=b.ProcessID	,@OrderProcessNo=b.ProcessNo	,@OrderFiscalYear=b.FiscalYear	,@OrderSerialNo=b.SerialNo
			from  #tblProductGoodsQty a
			inner join  sal.tblSaleOrderParamAtom b
				on a.GoodsID=MainParamID and ParentParamID=ProductID and ParamValue<>MainParamID
			inner join  pln.tblItemRelations c
				on b.ProcessID=c.BaseProcessID and b.ProcessNo=c.BaseProcessNo and b.FiscalYear=c.BaseFiscalYear and b.SerialNo=c.BaseSerialNo --and b.DocRowNo=c.BaseDocRowNo
			inner join  pln.tblItemRelations d
				on c.ProcessID=d.BaseProcessID and c.ProcessNo=d.BaseProcessNo and c.FiscalYear=d.BaseFiscalYear and c.SerialNo=d.BaseSerialNo --and c.DocRowNo=d.BaseDocRowNo
			where 
				d.ProcessID=@BaseProcessID and d.ProcessNo=@BaseProcessNo and d.FiscalYear=@BaseFiscalYear and d.SerialNo=@BaseSerialNo --and .DocRowNo=d.BaseDocRowNo

			--select 	* 
			Update #tblProductGoodsQty Set GoodsID2=ParamValue
				from  #tblProductGoodsQty a
				inner join  sal.tblSaleOrderParamAtom b
				on ParentParamID=ProductID and GoodsID=MainParamID --and ParamValue<>MainParamID
				and b.ProcessID=@OrderProcessID and b.ProcessNo=@OrderProcessNo and b.FiscalYear=@OrderFiscalYear and b.SerialNo=@OrderSerialNo --and .DocRowNo=d.BaseDocRowNo

			--select a.Quantity /c.GoodsQuantity * d.GoodsQuantity, d.*   
			update #tblProductGoodsQty 
			set Quantity =a.Quantity /c.GoodsQuantity * d.GoodsQuantity
			, SubUnitQuantity =a.Quantity /c.GoodsQuantity * d.GoodsQuantity
			,GoodsID=GoodsID2
			from #tblProductGoodsQty a 
			inner join prd.tblFormulasHdr b on a.ProductID=b.ProductID and b.IsDefault=1  and (@prdFormulaWithAccept=0 or b.AcceptFormula='True')
			inner join prd.tblFormulasDtl c on b.ProductID=c.ProductID and b.SerialNo=c.SerialNo and a.GoodsID=c.GoodsID 
			inner join prd.tblFormulasAtm d on d.ProductID=c.ProductID and d.SerialNo=c.SerialNo and d.DocRowNo=c.DocRowNo and d.GoodsID=a.GoodsID2
			where a.GoodsID<>a.GoodsID2
		
	end 
	 
	delete from  pln.tblProductGoodsSerialHdr
		where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo

	delete from  pln.tblProductGoodsSerialDtl
		where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo
  
	insert into pln.tblProductGoodsSerialHdr(ProcessID,ProcessNo,FiscalYear,SerialNo)									
		select  Distinct  @ProcessID,@ProcessNo,@BaseFiscalYear,@BaseSerialNo 
		 from #tblProductGoodsQty
		
 if (Select Count(*) from  pln.tblProductGoodsQtyHdr where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo)<=0
	insert into pln.tblProductGoodsQtyHdr(ProcessID,ProcessNo,FiscalYear,SerialNo)									
		select  Distinct  @ProcessID,@ProcessNo,@BaseFiscalYear,@BaseSerialNo 
		 from #tblProductGoodsQty   
	 
	insert into pln.tblProductGoodsQtyDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID
										,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo
										,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,ProductCount,BatchNo,ParamKind,UserPriceID)									
	select @ProcessID,@ProcessNo,@BaseFiscalYear,@BaseSerialNo ,RowNumber,RowNumber,RowNumber,@DocDate
			,case when DefaultStoreID <>'' then DefaultStoreID 
			  when @UsageStoreID1 <>'' then @UsageStoreID1 
			  when @UsageStoreID2 <>'' then @UsageStoreID2 
			  end
				,-1	 ,@AcntCode,GoodsID,UnitID,SubUnitQuantity,Quantity
				,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@FormulaNo,ProductCount
				,(case when 
							(select count(*) from inv.tblGoods  
								where SUBSTRING( #tblProductGoodsQty.GoodsID,@str_Goods+1 ,@str_GoodsSum)=inv.tblGoods.GoodsID    and PartNumber =@UnitPart 								
								and inv.tblGoods.HasBatchNo=1)>0
								And (select count(*) from prd.tblFormulasDtl  where ProductID=#tblProductGoodsQty.GoodsID)>0							
								then   @BatchNo else '' end ) BatchNo,ParamKind,UserPriceID

	 from #tblProductGoodsQty

-----------------ضایعات------------------------------------------
 	select @MaxSerialNo=isnull(Max(SerialNo),0)+1 from   pln.tblSecondaryProductByFormulaTempHdr

	 if (Select Count(*) from  pln.tblSecondaryProductByFormulaTempHdr 	where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo)<=0
	 	insert into pln.tblSecondaryProductByFormulaTempHdr(ProcessID,ProcessNo,FiscalYear,SerialNo,BaseProcessID	,BaseProcessNo	,BaseFiscalYear	,BaseSerialNo	, BaseDocRowNo,RecID	,SessionNo	)									
			select  Distinct  72,@ProcessNo,@BaseFiscalYear,@MaxSerialNo,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,0,0
		else
			Select @MaxSerialNo=SerialNo from  pln.tblSecondaryProductByFormulaTempHdr 	where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo

	delete from  pln.tblSecondaryProductByFormulaTempDtl
		where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo


 		 

	insert into pln.tblSecondaryProductByFormulaTempDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID
										,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo
										,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,ProductCount,BatchNo)									
	select 72,@ProcessNo,@BaseFiscalYear,@MaxSerialNo --,RowNo,DocRowNo,DocRowNo
		,DocRowNo+(select isnull(Max(DocRowNo),0) from pln.tblSecondaryProductByFormulaTempDtl a where a.ProcessID=72  and a.ProcessNo=@ProcessNo and a.FiscalYear=@BaseFiscalYear and a.SerialNo=@MaxSerialNo)
		,DocRowNo+(select isnull(Max(DocRowNo),0) from pln.tblSecondaryProductByFormulaTempDtl a where a.ProcessID=72  and a.ProcessNo=@ProcessNo and a.FiscalYear=@BaseFiscalYear and a.SerialNo=@MaxSerialNo)
		,DocRowNo+(select isnull(Max(DocRowNo),0) from pln.tblSecondaryProductByFormulaTempDtl a where a.ProcessID=72  and a.ProcessNo=@ProcessNo and a.FiscalYear=@BaseFiscalYear and a.SerialNo=@MaxSerialNo)		
	,@DocDate			,'' ,1	 ,@AcntCode,GoodsID,UnitID,GoodsQuantity,GoodsQuantity
				,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@FormulaNo,GoodsQuantity
				,isnull((case when 
							(select count(*) from inv.tblGoods  
								where SUBSTRING(p.ProductID,@str_Goods+1 ,@str_GoodsSum)=inv.tblGoods.GoodsID   and PartNumber =@UnitPart and inv.tblGoods.HasBatchNo=1)>0
								And (select count(*) from prd.tblFormulasDtl  where ProductID= p.ProductID)>0							
								then   @BatchNo else '' end ),'') BatchNo
	from  prd.tblSecondaryProductByFormulaDtl p
			where   ProductID=@ProductID and SerialNo=@FormulaNo

	update pln.tblSecondaryProductByFormulaTempDtl
		set GoodsQuantity=(AcceptableCount+UnacceptableCount)* s.ProductCount/  fh.ProductCount
			, SubUnitQuantity=(AcceptableCount+UnacceptableCount)* s.ProductCount/  fh.ProductCount			
	from pln.tblSecondaryProductByFormulaTempDtl s
		inner join pln.tblTaskOrderDtl td 		on s.BaseProcessID=td.ProcessID		and  s.BaseProcessNo=td.ProcessNo		and  s.BaseFiscalYear=td.FiscalYear		and  s.BaseSerialNo=td.SerialNo		and  s.BaseDocRowNo=td.DocRowNo
		inner join pln.tblTaskOrderHdr th 		on th.ProcessID=td.ProcessID		and  th.ProcessNo=td.ProcessNo		and  th.FiscalYear=td.FiscalYear		and  th.SerialNo=td.SerialNo		
		inner join prd.tblFormulasHdr fh on fh.ProductID=th.ProductID and fh.SerialNo=th.FormulaNo  and (@prdFormulaWithAccept=0 or fh.AcceptFormula='True')

		-----------------------------------------------------------	
	--select c.* 
	update  pln.tblProductGoodsQtyDtl 
	set UserPriceID=c.ID
	from  pln.tblProductGoodsQtyDtl a
	inner join inv.tblGoods b on a.GoodsID=b.GoodsID and b.ActiveUserPrice =1
	inner join inv.tblGoodsUserPrice c on a.GoodsID=c.GoodsID and c.UserPrice=b.UserPrice
	where
	ProcessID=82	and  
	ProcessNo=@BaseProcessNo
	and  FiscalYear=@BaseFiscalYear
	and  SerialNo=@BaseSerialNo
-----------------------------------------------------------	
end 
	else
	begin
	Declare @BaseTaskFiscalYear as int;
	Declare @BaseTaskSerialNo as int;
	declare @ProductIDTask	varchar(20);
	declare @ProductCNT	float;	
	
	select @ProductIDTask=ProductID , @BaseTaskSerialNo=BaseSerialNo,@BaseTaskFiscalYear=BaseFiscalYear  from pln.tblTaskOrderHdr
	where  FiscalYear=@BaseFiscalYear and SerialNo= @BaseSerialNo 
		
	select @ProductCNT=ProductCount  from pln.tblProduceOrderDtl
	where  FiscalYear=@BaseTaskFiscalYear and SerialNo= @BaseTaskSerialNo 
	and ProductID =@ProductIDTask

		delete from  pln.tblProductGoodsQtyHdr
		where ProcessID=@ProcessID and ProcessNo=@BaseProcessNo and FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo

		delete from  pln.tblProductGoodsQtyDtl
		where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo
	
		if (Select Count(*) from  pln.tblProductGoodsQtyHdr where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo)<=0
			insert into pln.tblProductGoodsQtyHdr(ProcessID,ProcessNo,FiscalYear,SerialNo)									
			select  Distinct  @ProcessID,@ProcessNo,@BaseFiscalYear,@BaseSerialNo 
		 
		select top 1 @StoreID=UsageStoreID
		from pln.tblTaskOrderHdr a 					
		where a.FiscalYear=@BaseFiscalYear and a.SerialNo=@BaseSerialNo 

	Declare @OldDbName Varchar(50)
	if (Select Count(*) From inv.tblStorageDocsDtl b 
			where ((BaseTaskFiscalYear=@BaseTaskFiscalYear and BaseTaskSerialNo= @BaseTaskSerialNo)or (TaskFiscalYear=@BaseFiscalYear and TaskSerialNo= @BaseSerialNo)) 
					and ProcessID=125 and StoreID=@StoreID
					and SerialNo =(Select top 1 SerialNo 
										From inv.tblStorageDocsDtl b 
										where ((BaseTaskFiscalYear=@BaseTaskFiscalYear and BaseTaskSerialNo= @BaseTaskSerialNo)or (TaskFiscalYear=@BaseFiscalYear and TaskSerialNo= @BaseSerialNo)) 
											and ProcessID=125 and StoreID=@UsageStoreID1
										order by DocDate, SerialNo))>0
	begin
		Set @OldDbName=DB_NAME()
	end
	else
	begin
		set @OldDbName=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(RIGHT(DB_NAME(),4) -1)) 			
		if  (SELECT Count(*) FROM sys.databases WHERE (state = 0) AND ([name] = @OldDbName))<1
			Set @OldDbName=DB_NAME()
	end -- if else

	set @StrSelect='	
		insert into pln.tblProductGoodsQtyDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID
										,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo
										,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,ProductCount,BatchNo,ParamKind,UserPriceID)									
		Select 82,'+ str(@BaseProcessNo)+' ,'+ str(@BaseFiscalYear)+','+ str(@BaseSerialNo )+'
				,ROW_NUMBER()OVER (PARTITION BY 82,'+ str(@BaseProcessNo)+','+ str(@BaseFiscalYear)+','+ str(@BaseSerialNo)+' ORDER BY SerialNo) RowNo	
				,ROW_NUMBER()OVER (PARTITION BY 82,'+ str(@BaseProcessNo)+','+ str(@BaseFiscalYear)+','+ str(@BaseSerialNo)+' ORDER BY SerialNo) DocRowNo,VolumeRowNo,'''+ @DocDate+''',StoreID 
				,-1	 ,'''+ @AcntCode +''',GoodsID,SubUnitID,SubUnitQuantity /'+ str(@ProductCNT )+'*'+ str(@ProductQty)+',GoodsQuantity /'+ str(@ProductCNT )+' *'+ str(@ProductQty)+' ,'+ str(@BaseProcessID)+','+ str(@BaseProcessNo)+'
				,'+ str(@BaseFiscalYear)+','+ str(@BaseSerialNo)+','+ str(@BaseDocRowNo)+','+ str(@FormulaNo)+',1 ProductCount,BatchNo,0,UserPriceID
		From '+@OldDbName+'.inv.tblStorageDocsDtl b 
		where ((BaseTaskFiscalYear='+ str(@BaseTaskFiscalYear)+' and BaseTaskSerialNo= '+ str(@BaseTaskSerialNo)+')or (TaskFiscalYear='+ str(@BaseFiscalYear )+' and TaskSerialNo= '+ str(@BaseSerialNo)+')) 
			and ProcessID=125 and StoreID='''+ @StoreID+'''
			and SerialNo =(Select top 1 SerialNo From '+@OldDbName+'.inv.tblStorageDocsDtl b 
							where ((BaseTaskFiscalYear='+ str(@BaseTaskFiscalYear)+' and BaseTaskSerialNo= '+ str(@BaseTaskSerialNo)+')or (TaskFiscalYear='+ str(@BaseFiscalYear)+' and TaskSerialNo= '+ str(@BaseSerialNo)+')) 
								and ProcessID=125 and StoreID='''+ @UsageStoreID1+'''
							order by DocDate, SerialNo)'

	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;
	
	end --@Pln_AllocationOfGoodsByTransfer='False'
end   -- ClType 3
 
	if @CallType=4
	begin	
	if (Select Count(*) from pln.tblProductGoodsQtyDtl p	
			 where p.ProcessID= @ProcessID and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo and  p.BaseDocRowNo=@BaseDocRowNo
			)<1
		begin
			raiserror ('مشکل خالی بودن جدول محاسبه مواد', 16, 1)
			return			
		end
	select  ProcessID,ProcessNo,@FiscalYearCnn FiscalYear,@SerialNo82 SerialNo, RowNo, DocRowNo, VolumeRowNo,@DocDate DocDate
				,case when StoreID <>'' then StoreID 
					  when @UsageStoreID1 <>'' then @UsageStoreID1 
					  when @UsageStoreID2 <>'' then @UsageStoreID2 
					  end StoreID
						,-1	 EnterKind,@AcntCode AcntCode,GoodsID,SubUnitID, SubUnitQuantity, GoodsQuantity
						,@BaseProcessID BaseProcessID,@BaseProcessNo BaseProcessNo,@BaseFiscalYear BaseFiscalYear,@BaseSerialNo BaseSerialNo
						,@BaseDocRowNo BaseDocRowNo,@FormulaNo FormulaNo,ProductCount
						,(case when BatchNo<> '' then BatchNo else
							case when 
								(select count(*) from inv.tblGoods  
									where SUBSTRING( p.GoodsID,@str_Goods+1 ,@str_GoodsSum)=inv.tblGoods.GoodsID    and PartNumber =@UnitPart and inv.tblGoods.HasBatchNo=1)>0
										And (select count(*) from prd.tblFormulasDtl  where ProductID=p.GoodsID)>0							
								then   @BatchNo else '' end end) BatchNo
								,cast (0 as float ) Qty,UserPriceID
			Into #tblGoodsQty
		 from pln.tblProductGoodsQtyDtl p
		 where p.ProcessID= @ProcessID and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo 
		 and  p.BaseDocRowNo=@BaseDocRowNo

		update #tblGoodsQty
		Set Qty=[inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,StoreID,GoodsID,BatchNo,DocDate,0)


		DECLARE csr CURSOR FOR 
			SELECT GoodsQuantity,Qty,GoodsID,StoreID
			FROM #tblGoodsQty
	
		OPEN csr
		FETCH NEXT FROM csr INTO @Qty1, @Qty2,@GoodsID,@StoreID

		WHILE @@Fetch_Status = 0
		BEGIN
			if @Qty1> @Qty2
				 set @StrError=@StrError +' ('+ ' مشکل موجودی کالای '+ @GoodsID +'  در انبار '+ @StoreID +' موجودی کالا '+ str(@Qty2,20,5) +'  مورد نیاز '+ str(@Qty1,20,5) +'  ) '
			FETCH NEXT FROM csr INTO @Qty1, @Qty2,@GoodsID,@StoreID
		
		END

		CLOSE csr
		DEALLOCATE csr
	
		if @StrError<>''
			begin
				raiserror (@StrError, 16, 1)
				return			
			end 

	
	if @AcceptStoreID<>''
	begin
		select @StoreIDCount=Count(*) from inv.tblStores where StoreID=@AcceptStoreID
		if @StoreIDCount=0
			set @StrError=@StrError +' ('+ ' مشکل وجود انبار  '+ @AcceptStoreID +' برای سفارش کارتولید مربوطه ) '
	end 
	if @UsageStoreID1<>''
	begin
		select @StoreIDCount=Count(*) from inv.tblStores where StoreID=@UsageStoreID1
		if @StoreIDCount=0
			set @StrError=@StrError +' ('+ ' مشکل وجود انبار  '+ @UsageStoreID1 +' برای سفارش کارتولید مربوطه ) '
	end 
	if @FailedStoreID<>''
	begin
		select @StoreIDCount=Count(*) from inv.tblStores where StoreID=@FailedStoreID
		if @StoreIDCount=0
			set @StrError=@StrError +' ('+ ' مشکل وجود انبار  '+ @FailedStoreID +' برای سفارش کارتولید مربوطه ) '
	end 
		
	if @StrError<>''
	begin
		raiserror (@StrError, 16, 1)
		return			
	end 
	
		BEGIN TRANSACTION
		BEGIN TRY 	 	
	 
 		insert into inv.tblStorageDocsHdr( ProcessID,ProcessNo,FiscalYear,SerialNo,FormulaNo,DocDate,StoreID,AcntCode
										,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,DocDesc,ProductCount
										,ProductID,RecID,SessionNo,DocDate2,DocDate3)
		select @ProcessID,@ProcessNo,@FiscalYearCnn,@SerialNo82,@FormulaNo,@DocDate,@UsageStoreID2,@AcntCode
										,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,'ثبت خودکار توسط سيستم - مربوط به سفارش کار توليد شماره '+str(@BaseSerialNo) 
										,@ProductQty ,@ProductID,@RecID,@SessionNo,@DocDate,@DocDate

		delete from pln.tblProductGoodsQtyDtl where GoodsQuantity=0 or SubUnitQuantity=0
		if (Select Count(*) from pln.tblProductGoodsQtyDtl p	
			 where p.ProcessID= @ProcessID and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo and  p.BaseDocRowNo=@BaseDocRowNo	
	 		)<1
		begin
			raiserror ('مشکل خالی بودن جدول محاسبه مواد', 16, 1)
			return			
		end
		insert into inv.tblStorageDocsDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID
											,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo
											,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,FormulaProductCount,BatchNo,UserPriceID)									
			select @ProcessID,@ProcessNo,@FiscalYearCnn,@SerialNo82 ,RowNo,DocRowNo,VolumeRowNo,@DocDate
			,case when StoreID <>'' then StoreID 
				  when @UsageStoreID1 <>'' then @UsageStoreID1 
				  when @UsageStoreID2 <>'' then @UsageStoreID2 
				  end
					,-1	 ,@AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity
					,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@FormulaNo,ProductCount
					,BatchNo ,UserPriceID
			 from pln.tblProductGoodsQtyDtl p
			 where p.ProcessID= @ProcessID and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo and  p.BaseDocRowNo=@BaseDocRowNo
	 	 
	  ------72-------------------------------------------------------------
	   
	SELECT @ProductQty=case when AcceptableCount>0 then AcceptableCount else UnacceptableCount end 	,@ProductQtyUnaccept=UnacceptableCount
	FROM pln.tblTaskOrderDtl
	where ProcessID=@BaseProcessID and ProcessNo=@BaseProcessNo and FiscalYear	=@BaseFiscalYear and SerialNo=@BaseSerialNo	and DocRowNo=@BaseDocRowNo	

	Set @ProcessID72=case when @ProductQtyUnaccept=0 then 72 else 73 end 

	select @SerialNo72=isnull(Max(SerialNo),0)+1 from inv.tblStorageDocsHdr 
	where ProcessID=@ProcessID72 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYearCnn
  
	  insert into inv.tblStorageDocsHdr( ProcessID,ProcessNo,FiscalYear,SerialNo,FormulaNo,DocDate,StoreID,AcntCode
										,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,DocDesc,ProductCount
										,ProductID,RecID,SessionNo,DocDate2,DocDate3,BatchNo)
		select @ProcessID72,@ProcessNo,@FiscalYearCnn,@SerialNo72,@FormulaNo,@DocDate,case when @AcceptableCount>0 then @AcceptStoreID else @FailedStoreID end    ,@AcntCode
										,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,'ثبت خودکار توسط سيستم - مربوط به سفارش کار توليد شماره '+str(@BaseSerialNo)
										,case when @AcceptableCount>0 then @AcceptableCount else @UnacceptableCount end 
										,@ProductID,@RecID,@SessionNo,@DocDate,@DocDate,@BatchNo
		Declare @GoodsQuantity as float
		Declare @SubUnitQuantity as float
		Declare @SubUnitID as varchar(20)
		set @GoodsQuantity =case when @AcceptableCount>0 then @AcceptableCount else @UnacceptableCount end

		select @SubUnitQuantity=SubUnitQuantity,@SubUnitID=SubUnitID from pln.tblTaskOrderDtl p
		where p.ProcessID= @BaseProcessID and p.ProcessNo= @BaseProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo and  p.DocRowNo=@BaseDocRowNo
 
 		insert into inv.tblStorageDocsDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID
											,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo
											,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,FormulaProductCount,BatchNo,UserPriceID)									
		select  top 1 @ProcessID72,@ProcessNo,@FiscalYearCnn,@SerialNo72 ,1,1,1001,@DocDate,case when @AcceptableCount>0 then @AcceptStoreID else @FailedStoreID end 
					,1	 ,@AcntCode,@ProductID,@SubUnitID,@SubUnitQuantity,@GoodsQuantity
					,@BaseProcessID,@BaseProcessNo
					,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@FormulaNo,ProductCount
					,@BatchNo ,t.UserPriceID
			 from pln.tblProductGoodsQtyDtl p
			 inner join pln.tblTaskOrderHdr t on  p.ProcessNo= t.ProcessNo and p.FiscalYear= t.FiscalYear and  p.SerialNo=t.SerialNo 
			 where p.ProcessID= @ProcessID and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo and  p.BaseDocRowNo=@BaseDocRowNo
			 -------ثبت ضایعات محصول-----------------------------------

	 if ( select count(*) from  pln.tblSecondaryProductByFormulaTempDtl  	where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo)>0
	 begin
	 
	 IF @LossStoreID=''
		BEGIN
			Raiserror (' انبار ضایعات خالی است',16,1)
			Return
		END

		insert into inv.tblStorageDocsDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID
											,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo
											,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,FormulaNo,FormulaProductCount,BatchNo)									
		select   @ProcessID72,@ProcessNo,@FiscalYearCnn,@SerialNo72 ,DocRowNo+1,DocRowNo+1,1001,@DocDate,@LossStoreID 
					,1	 ,@AcntCode,GoodsID,SubUnitID ,SubUnitQuantity,GoodsQuantity
					,@BaseProcessID,@BaseProcessNo
					,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@FormulaNo,GoodsQuantity
					,case when BatchNo <>''  then BatchNo else @BatchNo end 
			from  pln.tblSecondaryProductByFormulaTempDtl p
			where BaseProcessID=@BaseProcessID and BaseProcessNo=@BaseProcessNo and BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
			and GoodsQuantity>0

	 end
			 -------ثبت ضایعات محصول-----------------------------------

		delete from inv.tblStorageDocsSerials
			where ProcessID= @ProcessID and ProcessNo= @ProcessNo and FiscalYear= @FiscalYearCnn and  SerialNo=@BaseSerialNo 

		insert into inv.tblStorageDocsSerials(ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,AtomRowNo,DocAtomRowNo,ProductSerialID,EventNo,BatchNo,ExpireDate,PSerialNo,StoreID,EnterKind)
				select    @ProcessID-10,@ProcessNo,@FiscalYearCnn,@SerialNo72 ,1,DocRowNo,RowNo,ProductSerialID	,1,	@BatchNo  ,'',PSerialNo,@AcceptStoreID,1
			 from pln.tblProductGoodsSerialDtl p
			 where p.ProcessID= @ProcessID and p.ProcessNo= @ProcessNo and p.FiscalYear= @BaseFiscalYear and  p.SerialNo=@BaseSerialNo 

		COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			Set @StrErrorMessage = ERROR_MESSAGE() 
			raiserror (@StrErrorMessage, 16, 1)
			ROLLBACK TRANSACTION
		END CATCH	 	
	-------------------------------------------------------------------
	 update pln.tblTaskOrderHdr
		set TaskStateID=4
		from  pln.tblTaskOrderHdr a
		inner join (select  sum(GoodsQuantity * EnterKind) Qty, GoodsID,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
		from inv.tblStorageDocsDtl b  
		where  ProcessID=72 and BaseProcessID = @BaseProcessID and BaseProcessNo =@BaseProcessNo 	and BaseFiscalYear= @BaseFiscalYear and BaseSerialNo=@BaseSerialNo
		group by  GoodsID,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
		)	b
		on 	a.ProcessID = b.BaseProcessID and ProcessNo =b.BaseProcessNo 	and FiscalYear= b.BaseFiscalYear and SerialNo=b.BaseSerialNo
		where a.ProcessID = @BaseProcessID and a.ProcessNo =@BaseProcessNo 	and a.FiscalYear= @BaseFiscalYear and a.SerialNo=@BaseSerialNo
		and a.OrderCount=b.Qty 

	-------------------------------------------------------------------

	 select ProcessID,ProcessNo,FiscalYear,SerialNo,FormulaNo,DocDate,StoreID,AcntCode,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
	 ,DocDesc,ProductCount,ProductID,RecID,SessionNo,DocDate2,DocDate3
	 from inv.tblStorageDocsHdr b
	 where b.BaseProcessID = @BaseProcessID and b.BaseProcessNo =@BaseProcessNo 	and b.BaseFiscalYear= @BaseFiscalYear and b.BaseSerialNo=@BaseSerialNo 
 
	 select   ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,DocDate,StoreID,PhysicallyEffected,EnterKind,AcntCode,
	  GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,
	  FormulaNo,FormulaProductCount,UserPriceID
	  from inv.tblStorageDocsDtl b
	  where b.BaseProcessID = @BaseProcessID and b.BaseProcessNo =@BaseProcessNo 	
			and b.BaseFiscalYear= @BaseFiscalYear and b.BaseSerialNo=@BaseSerialNo and  b.BaseDocRowNo=@BaseDocRowNo
	end 
end 
end 
GO
