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
-- ----------------------------------------------
-- Description	 : < انجام گروهی دستور کار>
-- ==============================================
Create PROCEDURE pln.SpDoingGroupsInOutStore
	@CallType			int,
	@ExtraParams		NVarChar(Max) = ''	
WITH ENCRYPTION
AS
BEGIN

declare @DocDate			char(10);
declare @DocDateFr	 		char(10);
declare @DocDateTo			char(10);
declare @OrderFiscalYearFr  int;
declare @OrderSerialNoFr	int;
declare @OrderFiscalYearTo  int;
declare @OrderSerialNoTo	int;
declare @TaskFiscalYearFr   int;
declare @TaskSerialNoFr		int;
declare @TaskFiscalYearTo   int;
declare @TaskSerialNoTo		int;
declare @BatchNo			varchar(20);
declare @ProductID			varchar(20);

declare @FiscalYear			int;
declare @SerialNo			int;
DECLARE @StrSelect			NVarChar(Max);
DECLARE @StrWhere 			NVarChar(Max);
DECLARE @StrWhere2 			NVarChar(Max);
DECLARE @StrWhere3 			NVarChar(Max);

declare @DocRowNoFr			int;
declare @DocRowNoTo			int;
declare @ProduceStepIDFr	int;
declare @ProduceStepIDTo	int;
declare @FormulaNoFr		int;
declare @FormulaNoTo		int;
declare @StepNoFr			int;
declare @StepNoTo			int;
declare @ShiftTypeID		varchar(20);
declare @ProductionLineID	varchar(20);

	SET @DocDate			= pub.funSplitString(@ExtraParams, '@', 1);
	SET @OrderFiscalYearFr	= pub.funSplitString(@ExtraParams, '@', 2);
	SET @OrderSerialNoFr	= pub.funSplitString(@ExtraParams, '@', 3);
	SET @OrderFiscalYearTo	= pub.funSplitString(@ExtraParams, '@', 4);
	SET @OrderSerialNoTo	= pub.funSplitString(@ExtraParams, '@', 5);
	SET @TaskFiscalYearFr	= pub.funSplitString(@ExtraParams, '@', 6);
	SET @TaskSerialNoFr		= pub.funSplitString(@ExtraParams, '@', 7);
	SET @TaskFiscalYearTo	= pub.funSplitString(@ExtraParams, '@', 8);
	SET @TaskSerialNoTo		= pub.funSplitString(@ExtraParams, '@', 9);
	SET @BatchNo			= pub.funSplitString(@ExtraParams, '@', 10);
	SET @ProductID			= pub.funSplitString(@ExtraParams, '@', 11);
	SET @DocRowNoFr			= pub.funSplitString(@ExtraParams, '@', 12);
	SET @DocRowNoTo			= pub.funSplitString(@ExtraParams, '@', 13);
	SET @ProduceStepIDFr	= pub.funSplitString(@ExtraParams, '@', 14);
	SET @ProduceStepIDTo	= pub.funSplitString(@ExtraParams, '@', 15);	
	SET @StepNoFr			= pub.funSplitString(@ExtraParams, '@', 16);
	SET @StepNoTo			= pub.funSplitString(@ExtraParams, '@', 17);
	SET @FormulaNoFr 		= pub.funSplitString(@ExtraParams, '@', 18);
	SET @FormulaNoTo		= pub.funSplitString(@ExtraParams, '@', 19);	
	SET @ShiftTypeID		= pub.funSplitString(@ExtraParams, '@', 20);	
	SET @ProductionLineID	= pub.funSplitString(@ExtraParams, '@', 21);	
	SET @DocDateFr			= pub.funSplitString(@ExtraParams, '@', 22);	
	SET @DocDateTo			= pub.funSplitString(@ExtraParams, '@', 23);	

-----برای کالا های چند پارتی---------------------------------------------------------------
	DECLARE @UnitPart TINYINT
	DECLARE @str_Goods  tinyint
	DECLARE @str_GoodsSum tinyint
	
	Declare @prdFormulaWithAccept	bit

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

	--select @StepNoFr,@StepNoTo,@FormulaNoFr,@FormulaNoTo
	update pln.tblTaskOrderHdr 
	set BaseProcessID=b.BaseProcessID  
		, BaseProcessNo=b.BaseProcessNo  
		, BaseFiscalYear=b.BaseFiscalYear  
		, BaseSerialNo=b.BaseSerialNo 
	from pln.tblTaskOrderHdr a  
		inner join pln.tblItemRelations b 
	on a.ProcessID=b.ProcessID 
		and  a.ProcessNo=b.ProcessNo 
		and  a.FiscalYear=b.FiscalYear 
		and  a.SerialNo=b.SerialNo 
	where a.BaseSerialNo=0

if @CallType=1
begin

	 set @StrWhere='   a.ProcessID=610 '
	 if @DocDate<>'' 
		set @StrWhere=@StrWhere + ' and a.DocDate<= ''' + @DocDate  +''''

	 if @DocDateFr<>'' 
		set @StrWhere=@StrWhere + ' and a.DocDate>= ''' + @DocDateFr  +''''
	if @DocDateTo<>'' 
		set @StrWhere=@StrWhere + ' and a.DocDate<= ''' + @DocDateTo  +''''

	if @OrderFiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and a.BaseFiscalYear>= ' + str(@OrderFiscalYearFr)  +''
	if @OrderSerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and a.BaseSerialNo>= ' + str(@OrderSerialNoFr)  +''
	if @OrderFiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and a.BaseFiscalYear<= ' + str(@OrderFiscalYearTo)  +''
	if @OrderSerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and a.BaseSerialNo<= ' + str(@OrderSerialNoTo)  +''
			
	if @TaskFiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and a.FiscalYear>= ' + str(@TaskFiscalYearFr)  +''
	if @TaskSerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and a.SerialNo>= ' + str(@TaskSerialNoFr)  +''
	if @TaskFiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and a.FiscalYear<= ' + str(@TaskFiscalYearTo)  +''
	if @TaskSerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and a.SerialNo<= ' + str(@TaskSerialNoTo)  +''
	
	if @BatchNo<>'' 
		set @StrWhere=@StrWhere + ' and a.BatchNo= ''' + @BatchNo  +''''

	if @ProductID<>'' 
		set @StrWhere=@StrWhere + ' and a.ProductID= ''' + @ProductID  +''''
 
	if @DocRowNoFr<>0 
		set @StrWhere=@StrWhere + ' and b.DocRowNo>= ' + str(@DocRowNoFr)  +''
	if @DocRowNoTo<>0 
		set @StrWhere=@StrWhere + ' and b.DocRowNo<= ' + str(@DocRowNoTo)  +''
	if @ProduceStepIDFr<>0 
		set @StrWhere=@StrWhere + ' and b.ProduceStepID>= ' + str(@ProduceStepIDFr)  +''
	if @ProduceStepIDTo<>0 
		set @StrWhere=@StrWhere + ' and b.ProduceStepID<= ' + str(@ProduceStepIDTo)  +''

	if @FormulaNoFr<>0 
		set @StrWhere=@StrWhere + ' and bb.FormulaNo>= ' + str(@FormulaNoFr)  +''
	if @FormulaNoTo<>0 
		set @StrWhere=@StrWhere + ' and bb.FormulaNo<= ' + str(@FormulaNoTo)  +''
	if @StepNoFr<>0 
		set @StrWhere=@StrWhere + ' and bb.StepNo>= ' + str(@StepNoFr)  +''
	if @StepNoTo<>0 
		set @StrWhere=@StrWhere + ' and bb.StepNo<= ' + str(@StepNoTo)  +''	
	if @ShiftTypeID<>'' 
		set @StrWhere=@StrWhere + ' and bb.ShiftTypeID= ''' + @ShiftTypeID  +''''
	if @ProductionLineID<>'' 
		set @StrWhere=@StrWhere + ' and b.ProductionLineID= ''' + @ProductionLineID  +''''
 
	if @prdFormulaWithAccept='True'
		set @StrWhere=@StrWhere + ' and (bb.ProductID in (Select ProductID from prd.tblFormulasHdr H where bb.FormulaNo=H.SerialNo and AcceptFormula =1)) '

	select  0 BaseSerialNo,0 BaseDocRowNo,0 ProdDocRowNo,ProcessID,ProcessNo,FiscalYear,SerialNo,0 RowNo,0 DocRowNo,0 ProductCount ,ProductID,    1 CallType,GoodsName ProductName ,0 ProduceStepID ,0 HasSerial 
	,FormulaNo, FormulaNo StepNo,a.BatchNo,a.BatchNo ProductionLineID,a.BatchNo ShiftTypeID
	,cast (0.0 as float ) AcceptableCount	,cast (0.0 as float ) UnacceptableCount
			into #TaskOrder
	from pln.tblTaskOrderHdr a
	inner join   inv.tblGoodsDtl g on a.ProductID=g.GoodsID and g.LanguageID=1
	 where 1=0

-----------------------------------------------------------------------
--  برای انام هایی که مقداری از آنها در سال قبل انجام و به حواله تبدیل شده اند
	 Declare @OldDbName Varchar(50)
	 Declare @OldTask NVarChar(Max)

	 set @OldDbName=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(RIGHT(DB_NAME(),4) -1)) 
	 set @OldTask=''
	 if @OrderFiscalYearFr<>RIGHT(DB_NAME(),4) and @OrderFiscalYearFr<>0 
	 		set @OldTask=' 	except		
			select  BaseProcessID ,BaseProcessNo ,BaseFiscalYear ,BaseSerialNo ,BaseDocRowNo
				from '+ @OldDbName +'.inv.tblStorageDocsDtl 
				where BaseProcessID=610 and ProcessID in (72,82,83,73) '
-----------------------------------------------------------------------
	DECLARE @Pln_CreateProduceForUnacceptDoing Bit
	 
	SELECT @Pln_CreateProduceForUnacceptDoing = SettingValue from pub.tblSettings where SettingKey = 'Pln_CreateProduceForUnacceptDoing'
	set @Pln_CreateProduceForUnacceptDoing=ISNULL(@Pln_CreateProduceForUnacceptDoing,0)

	if @Pln_CreateProduceForUnacceptDoing='true'
		begin
			set @StrWhere2=' or UnacceptableCount<>0 '
			set @StrWhere3='  Union All 
				 select a.BaseSerialNo,a.BaseDocRowNo,a.ProdDocRowNo,b.*  ,a.ProductID	,bb.FormulaNo,bb.StepNo,a.BatchNo
					from 	pln.tblTaskOrderDtl b		
					inner join pln.tblTaskOrderHdr a on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo			   
					inner join  pln.tblProduceOrderDtl  bb on bb.ProcessID=a.BaseProcessID  and bb.ProcessNo=a.BaseProcessNo and bb.FiscalYear=a.BaseFiscalYear and bb.SerialNo=a.BaseSerialNo and bb.DocRowNo=a.ProdDocRowNo
					inner join  ( select  max(ProduceStepID) ProduceStepID ,ProductID,SerialNo from  pln.tblProduceStepDtl where  NeedStep=1 Group by ProductID,SerialNo)	p 
					On  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo and b.ProduceStepID<>p.ProduceStepID
				where  	 b.UnacceptableCount<>0 and FinishDate <>'''' and TaskStateID<>4 and NeedRepeat=0 and NeedStop=0 and '+ @StrWhere +'	 
		 '
		end 
	else
	begin
		set @StrWhere2=' '
		set @StrWhere3=' '
	end

	  ----  برای سفارشهایی که قبض صادر نشده است
	set @StrSelect=' insert into #TaskOrder 		
		select BaseSerialNo,BaseDocRowNo,ProdDocRowNo,ProcessID,	ProcessNo	,FiscalYear,	SerialNo,	RowNo,	DocRowNo,	ProductCount	,ProductID	,CallType,	ProductName	,ProduceStepID	,HasSerial	,FormulaNo,StepNo,BatchNo
		, ProductionLineID , ShiftTypeID,0,0
			from (	select  Distinct a.BaseSerialNo,a.BaseDocRowNo,a.ProdDocRowNo,a.ProduceStepSerialNo,a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,isnull(b.RowNo,0)RowNo,isnull(b.DocRowNo,0)DocRowNo,a.OrderCount ProductCount
			,a.ProductID,'+ str(@CallType)+' CallType,GoodsName ProductName
			,ProduceStepID,gg.HasSerial,bb.FormulaNo,bb.StepNo,a.BatchNo, b.ProductionLineID , bb.ShiftTypeID, AcceptCount ,UnacceptableCount
		from pln.tblTaskOrderHdr a 
		inner join  pln.tblProduceOrderDtl  bb on bb.ProcessID=a.BaseProcessID  and bb.ProcessNo=a.BaseProcessNo and bb.FiscalYear=a.BaseFiscalYear and bb.SerialNo=a.BaseSerialNo and bb.DocRowNo=a.ProdDocRowNo		 
		Left join (
			select ProcessID,ProcessNo,FiscalYear,SerialNo ,DocRowNo
				from pln.tblTaskOrderDtl ta							 
			except
			select  BaseProcessID ,BaseProcessNo ,BaseFiscalYear ,BaseSerialNo ,BaseDocRowNo
				from inv.tblStorageDocsDtl 
				where BaseProcessID=610 and ProcessID in (72,82,83,73)
			 	'+ @OldTask +'	  
			 ) aa
		on a.ProcessID=aa.ProcessID and a.ProcessNo=aa.ProcessNo and a.FiscalYear=aa.FiscalYear and a.SerialNo=aa.SerialNo			   
		Left join pln.tblTaskOrderDtl b on aa.ProcessID=b.ProcessID and aa.ProcessNo=b.ProcessNo and aa.FiscalYear=b.FiscalYear and aa.SerialNo=b.SerialNo	 and aa.DocRowNo=b.DocRowNo
		 and b.FinishDate <>'''' 
		inner join inv.tblGoodsDtl g on SUBSTRING( a.ProductID,'+str(@str_Goods+1)+' ,'+str(@str_GoodsSum)+')=g.GoodsID   and g.PartNumber ='+str(@UnitPart)+' and g.LanguageID=1
		inner join   inv.tblGoods	gg on SUBSTRING( a.ProductID,'+str(@str_Goods+1)+' ,'+str(@str_GoodsSum)+')=gg.GoodsID   and g.PartNumber ='+str(@UnitPart)+' 
		where TaskStateID<>4 and NeedRepeat=0  and NeedStop=0 and '+ @StrWhere +'	
		 ) a 
		where ProduceStepID =isnull((select max(ProduceStepID) from pln.tblProduceStepDtl  p where  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo and  NeedStep=1),0) 
		'+@StrWhere2+'
		--or ProduceStepID in (select ProduceStepID from prd.tblFormulasDtl p where  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo and ProduceStepID<>0)
		order by ProductID,FiscalYear,SerialNo  '

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;

		select 0 BaseSerialNo,0 BaseDocRowNo,0 ProdDocRowNo,*  ,ToolID ProductID , SerialNo FormulaNo, SerialNo StepNo,ToolID BatchNo 
					into  #TaskOrder2 
		from 	pln.tblTaskOrderDtl where 1=0
			  --- برای سفارشهایی که برای قسمتی از سفارش قبض صادر شده  مانند ثبت ریز مرحله نهایی در چندین سطر
		set @StrSelect=' insert into #TaskOrder2 
		 select a.BaseSerialNo,a.BaseDocRowNo,a.ProdDocRowNo,b.*  ,a.ProductID	,bb.FormulaNo,bb.StepNo,a.BatchNo
			from 	pln.tblTaskOrderDtl b		
			inner join pln.tblTaskOrderHdr a on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo			   
			inner join  pln.tblProduceOrderDtl  bb on bb.ProcessID=a.BaseProcessID  and bb.ProcessNo=a.BaseProcessNo and bb.FiscalYear=a.BaseFiscalYear and bb.SerialNo=a.BaseSerialNo and bb.DocRowNo=a.ProdDocRowNo
			inner join  ( select  max(ProduceStepID) ProduceStepID ,ProductID,SerialNo from  pln.tblProduceStepDtl where  NeedStep=1 Group by ProductID,SerialNo)	p 
			On  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo and b.ProduceStepID=p.ProduceStepID
		where  FinishDate <>'''' and TaskStateID<>4 and NeedRepeat=0  and NeedStop=0 and '+ @StrWhere +'	 '+@StrWhere3   
	
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;		
	
				 -- حذف سطرهایی که برای آنها قبض صادر شده است
		delete from #TaskOrder2 
		from  #TaskOrder2 a
		inner join  	inv.tblStorageDocsDtl  b
		on a.ProcessID = b.BaseProcessID  and a.ProcessNo =b.BaseProcessNo  
		and a.FiscalYear =b.BaseFiscalYear  and a.SerialNo=b.BaseSerialNo  
		and a.DocRowNo=b.BaseDocRowNo
		and ProductID=GoodsID
		if @OrderFiscalYearFr<>RIGHT(DB_NAME(),4) and @OrderFiscalYearFr<>0 
		begin
			set @StrSelect='	delete from #TaskOrder2 
				from  #TaskOrder2 a
				inner join  	'+ @OldDbName +'.inv.tblStorageDocsDtl  b
				on a.ProcessID = b.BaseProcessID  and a.ProcessNo =b.BaseProcessNo  
				and a.FiscalYear =b.BaseFiscalYear  and a.SerialNo=b.BaseSerialNo  
				and a.DocRowNo=b.BaseDocRowNo
				and ProductID=GoodsID'

			print   @StrSelect;             
			EXEC sp_executesql @StrSelect;				
		end 
	 
				 -- حذف سطرهایی که در جدول بالا موجود و تکراری میباشداست
		delete from #TaskOrder2 
		from  #TaskOrder2 a
		inner join  #TaskOrder b
		on a.ProcessID = b.ProcessID  and a.ProcessNo =b.ProcessNo  
		and a.FiscalYear =b.FiscalYear  and a.SerialNo=b.SerialNo  
		and a.ProductID=b.ProductID  
		 
		insert into #TaskOrder 
		(BaseSerialNo,BaseDocRowNo,ProdDocRowNo,ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo	,DocRowNo,	ProductCount,ProductID,CallType,ProductName,ProduceStepID,HasSerial,FormulaNo,StepNo,BatchNo, ProductionLineID , ShiftTypeID,AcceptableCount,UnacceptableCount)
		select BaseSerialNo,BaseDocRowNo,ProdDocRowNo,ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo	,DocRowNo,	ProductCount,ProductID,@CallType, GoodsName ProductName,ProduceStepID,HasSerial,FormulaNo,StepNo,BatchNo, ProductionLineID , ShiftTypeID,AcceptableCount,UnacceptableCount
		from #TaskOrder2 a
		inner join   inv.tblGoodsDtl g on SUBSTRING( a.ProductID,@str_Goods+1 ,@str_GoodsSum)=GoodsID   and g.PartNumber =@UnitPart and g.LanguageID=1
		inner join   inv.tblGoods gg on a.ProductID=gg.GoodsID 			 
				 
		--ProcessID,	ProcessNo	,FiscalYear,	SerialNo,	RowNo	,DocRowNo,	ProductCount,	ProductID	,CallType,	ProductName,	ProduceStepID,	HasSerial	,DocDate
		update #TaskOrder
			set AcceptableCount	=b.AcceptableCount	,UnacceptableCount=b.UnacceptableCount
		from #TaskOrder  bb
		inner join pln.tblTaskOrderDtl b 
			on bb.ProcessID=b.ProcessID and bb.ProcessNo=b.ProcessNo and bb.FiscalYear=b.FiscalYear and bb.SerialNo=b.SerialNo and bb.DocRowNo=b.DocRowNo 

		 select  a.*,b.DocDate ,Suspend --,c.DocRowNo	,c.RowNo,c.ProductCount, AcceptableCount,UnacceptableCount
				, c.FinishDate ,c.SubUnitID,c.SubUnitQuantity,inv.funGetUnitName(c.SubUnitID,1) AS SubUnitName , c.AcceptableCount+c.UnacceptableCount GoodsQuantity
				, u.UserPrice,u.UParams,b.UserPriceID
			from #TaskOrder a
		inner join pln.tblTaskOrderHdr b 	on a.ProcessID = b.ProcessID  and a.ProcessNo =b.ProcessNo  and a.FiscalYear =b.FiscalYear  and a.SerialNo=b.SerialNo 
		inner join pln.tblTaskOrderDtl c 	on a.ProcessID = c.ProcessID  and a.ProcessNo =c.ProcessNo  and a.FiscalYear =c.FiscalYear  and a.SerialNo=c.SerialNo   and a.DocRowNo=c.DocRowNo
		left join inv.tblGoodsUserPrice u on b.ProductID=u.GoodsID and b.UserPriceID=u.ID
		where c.AcceptableCount>0 or c.UnacceptableCount>0  		
end 
if @CallType=2
begin

 set @StrWhere='   a.ProcessID=610 '
	 if @DocDate<>'' 
		set @StrWhere=@StrWhere + ' and a.DocDate<= ''' + @DocDate  +''''

	if @DocDateFr<>'' 
		set @StrWhere=@StrWhere + ' and aa.DocDate>= ''' + @DocDateFr  +''''
	if @DocDateTo<>'' 
		set @StrWhere=@StrWhere + ' and aa.DocDate<= ''' + @DocDateTo  +''''
	if @OrderFiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and a.BaseFiscalYear>= ' + str(@OrderFiscalYearFr)  +''
	if @OrderSerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and a.BaseSerialNo>= ' + str(@OrderSerialNoFr)  +''
	if @OrderFiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and a.BaseFiscalYear<= ' + str(@OrderFiscalYearTo)  +''
	if @OrderSerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and a.BaseSerialNo<= ' + str(@OrderSerialNoTo)  +''			

	if @TaskFiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and a.FiscalYear>= ' + str(@TaskFiscalYearFr)  +''
	if @TaskSerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and a.SerialNo>= ' + str(@TaskSerialNoFr)  +''
	if @TaskFiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and a.FiscalYear<= ' + str(@TaskFiscalYearTo)  +''
	if @TaskSerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and a.SerialNo<= ' + str(@TaskSerialNoTo)  +''
	
	if @BatchNo<>'' 
		set @StrWhere=@StrWhere + ' and a.BatchNo= ''' + @BatchNo  +''''

	if @ProductID<>'' 
		set @StrWhere=@StrWhere + ' and a.ProductID= ''' + @ProductID  +''''
 
 	if @FormulaNoFr<>0 
		set @StrWhere=@StrWhere + ' and bb.FormulaNo>= ' + str(@FormulaNoFr)  +''
	if @FormulaNoTo<>0 
		set @StrWhere=@StrWhere + ' and bb.FormulaNo<= ' + str(@FormulaNoTo)  +''
	if @StepNoFr<>0 
		set @StrWhere=@StrWhere + ' and bb.StepNo>= ' + str(@StepNoFr)  +''
	if @StepNoTo<>0 
		set @StrWhere=@StrWhere + ' and bb.StepNo<= ' + str(@StepNoTo)  +''
	if @ShiftTypeID<>'' 
		set @StrWhere=@StrWhere + ' and bb.ShiftTypeID= ''' + @ShiftTypeID  +''''
	if @ProductionLineID<>'' 
		set @StrWhere=@StrWhere + ' and b.ProductionLineID= ''' + @ProductionLineID  +''''
 
 
	set @StrSelect='	select Distinct a.BaseSerialNo,a.BaseDocRowNo,a.ProdDocRowNo,a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo, aa.RowNo, aa.DocRowNo,a.DocDate,aa.GoodsQuantity ProductCount,1 DocStep
	,a.ProductID,'+ str(@CallType)+' CallType	,GoodsName ProductName	, aa.BaseDocRowNo TaskBaseDocRowNo,Suspend , SourceSerialNo,bb.FormulaNo,bb.StepNo,a.BatchNo,bb.ShiftTypeID,b.ProductionLineID
	, '''' FinishDate  ,b.SubUnitID,b.SubUnitQuantity,inv.funGetUnitName(b.SubUnitID,1) AS SubUnitName , b.AcceptableCount+b.UnacceptableCount GoodsQuantity
	, u.UserPrice,u.UParams, a.UserPriceID
		from inv.tblStorageDocsDtl aa
		inner join pln.tblTaskOrderHdr a on a.ProcessID=aa.BaseProcessID and a.ProcessNo=aa.BaseProcessNo and a.FiscalYear=aa.BaseFiscalYear and a.SerialNo=aa.BaseSerialNo	and a.ProductID=aa.GoodsID
		inner join pln.tblTaskOrderDtl b on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and b.DocRowNo=aa.BaseDocRowNo
		inner join pln.tblProduceOrderDtl  bb on bb.ProcessID=a.BaseProcessID  and bb.ProcessNo=a.BaseProcessNo and bb.FiscalYear=a.BaseFiscalYear and bb.SerialNo=a.BaseSerialNo and bb.DocRowNo=a.ProdDocRowNo		 
		inner join inv.tblGoodsDtl g on SUBSTRING( a.ProductID,'+str(@str_Goods+1)+' ,'+str(@str_GoodsSum)+')=g.GoodsID   and g.PartNumber ='+str(@UnitPart)+' and g.LanguageID=1
		left join inv.tblGoodsUserPrice u on a.ProductID=u.GoodsID and a.UserPriceID=u.ID
		where aa.ProcessID in (72,73)
		and '+ @StrWhere +'	
			order by a.ProductID,a.FiscalYear,a.SerialNo'
	
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;		
			
end 

if @CallType=3
begin

	 set @StrWhere='   a.ProcessID=610 '
	 if @DocDate<>'' 
		set @StrWhere=@StrWhere + ' and a.DocDate<= ''' + @DocDate  +''''
	if @DocDateFr<>'' 
		set @StrWhere=@StrWhere + ' and a.DocDate>= ''' + @DocDateFr  +''''
	if @DocDateTo<>'' 
		set @StrWhere=@StrWhere + ' and a.DocDate<= ''' + @DocDateTo  +''''
	if @OrderFiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and a.BaseFiscalYear>= ' + str(@OrderFiscalYearFr)  +''
	if @OrderSerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and a.BaseSerialNo>= ' + str(@OrderSerialNoFr)  +''
	if @OrderFiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and a.BaseFiscalYear<= ' + str(@OrderFiscalYearTo)  +''
	if @OrderSerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and a.BaseSerialNo<= ' + str(@OrderSerialNoTo)  +''
			
	if @TaskFiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and a.FiscalYear>= ' + str(@TaskFiscalYearFr)  +''
	if @TaskSerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and a.SerialNo>= ' + str(@TaskSerialNoFr)  +''
	if @TaskFiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and a.FiscalYear<= ' + str(@TaskFiscalYearTo)  +''
	if @TaskSerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and a.SerialNo<= ' + str(@TaskSerialNoTo)  +''
	
	if @BatchNo<>'' 
		set @StrWhere=@StrWhere + ' and a.BatchNo= ''' + @BatchNo  +''''

	if @ProductID<>'' 
		set @StrWhere=@StrWhere + ' and a.ProductID= ''' + @ProductID  +''''
 	
	if @DocRowNoFr<>0 
		set @StrWhere=@StrWhere + ' and b.DocRowNo>= ' + str(@DocRowNoFr)  +''
	if @DocRowNoTo<>0 
		set @StrWhere=@StrWhere + ' and b.DocRowNo<= ' + str(@DocRowNoTo)  +''
	if @ProduceStepIDFr<>0 
		set @StrWhere=@StrWhere + ' and b.ProduceStepID>= ' + str(@ProduceStepIDFr)  +''
	if @ProduceStepIDTo<>0 
		set @StrWhere=@StrWhere + ' and b.ProduceStepID<= ' + str(@ProduceStepIDTo)  +''
	
	if @FormulaNoFr<>0 
		set @StrWhere=@StrWhere + ' and bb.FormulaNo>= ' + str(@FormulaNoFr)  +''
	if @FormulaNoTo<>0 
		set @StrWhere=@StrWhere + ' and bb.FormulaNo<= ' + str(@FormulaNoTo)  +''
	if @StepNoFr<>0 
		set @StrWhere=@StrWhere + ' and bb.StepNo>= ' + str(@StepNoFr)  +''
	if @StepNoTo<>0 
		set @StrWhere=@StrWhere + ' and bb.StepNo<= ' + str(@StepNoTo)  +''
	if @ShiftTypeID<>'' 
		set @StrWhere=@StrWhere + ' and bb.ShiftTypeID= ''' + @ShiftTypeID  +''''
	if @ProductionLineID<>'' 
		set @StrWhere=@StrWhere + ' and b.ProductionLineID= ''' + @ProductionLineID  +''''
 

	select  0 BaseSerialNo,0 BaseDocRowNo,0 ProdDocRowNo,ProcessID,ProcessNo,FiscalYear,SerialNo,0 RowNo,0 DocRowNo,0 ProductCount ,ProductID,    1 CallType,GoodsName ProductName ,0 ProduceStepID ,0 HasSerial 
	,0 FormulaNo,0 StepNo ,ProductID BatchNo,ProductID ProductionLineID,ProductID ShiftTypeID
			into #TaskOrder3
	from pln.tblTaskOrderHdr a
	inner join   inv.tblGoodsDtl g on SUBSTRING( a.ProductID,@str_Goods+1 ,@str_GoodsSum)=g.GoodsID   and g.PartNumber =@UnitPart  and g.LanguageID=1
	 where 1=0
	  ----  برای سفارشهایی که قبض صادر نشده است
	set @StrSelect=' insert into #TaskOrder3
		select BaseSerialNo,BaseDocRowNo, ProdDocRowNo, ProcessID,	ProcessNo	,FiscalYear,	SerialNo,	RowNo,	DocRowNo,	ProductCount	,ProductID	,CallType,	ProductName	,ProduceStepID	,HasSerial	,FormulaNo,StepNo,BatchNo,ProductionLineID,ShiftTypeID
			from (	select  Distinct a.BaseSerialNo,a.BaseDocRowNo,a.ProdDocRowNo,a.ProduceStepSerialNo,a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,isnull(b.RowNo,0)RowNo,isnull(b.DocRowNo,0)DocRowNo,a.OrderCount ProductCount
			,a.ProductID,'+ str(@CallType)+' CallType,GoodsName ProductName
			,ProduceStepID,gg.HasSerial,bb.FormulaNo,bb.StepNo,a.BatchNo,b.ProductionLineID,bb.ShiftTypeID
		from pln.tblTaskOrderHdr a  
		inner join  pln.tblProduceOrderDtl  bb on bb.ProcessID=a.BaseProcessID  and bb.ProcessNo=a.BaseProcessNo and bb.FiscalYear=a.BaseFiscalYear and bb.SerialNo=a.BaseSerialNo and bb.DocRowNo=a.ProdDocRowNo		 
		inner join (
			select ProcessID,ProcessNo,FiscalYear,SerialNo ,DocRowNo
				from pln.tblTaskOrderDtl ta	where AcceptableCount>0 or UnacceptableCount>0						 
			except
			select  BaseProcessID ,BaseProcessNo ,BaseFiscalYear ,BaseSerialNo ,BaseDocRowNo
				from inv.tblStorageDocsDtl 
				where BaseProcessID=610 and ProcessID in (72,82,83,73)  
			 ) aa
		on a.ProcessID=aa.ProcessID and a.ProcessNo=aa.ProcessNo and a.FiscalYear=aa.FiscalYear and a.SerialNo=aa.SerialNo			   
		inner join pln.tblTaskOrderDtl b on aa.ProcessID=b.ProcessID and aa.ProcessNo=b.ProcessNo and aa.FiscalYear=b.FiscalYear and aa.SerialNo=b.SerialNo	 and aa.DocRowNo=b.DocRowNo
		inner join inv.tblGoodsDtl g on SUBSTRING( a.ProductID,'+str(@str_Goods+1)+' ,'+str(@str_GoodsSum)+')=g.GoodsID   and g.PartNumber ='+str(@UnitPart)+' and g.LanguageID=1
		inner join   inv.tblGoods	gg on SUBSTRING( a.ProductID,'+str(@str_Goods+1)+' ,'+str(@str_GoodsSum)+')=gg.GoodsID   and gg.PartNumber ='+str(@UnitPart)+' 
		where TaskStateID<>4 and NeedRepeat=0  and NeedStop=0 and '+ @StrWhere +'	
		 ) a 
		--where ProduceStepID =isnull((select max(ProduceStepID) from pln.tblProduceStepDtl  p where  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo and  NeedStep=1),0) 
		--or ProduceStepID in (select ProduceStepID from prd.tblFormulasDtl p where  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo and ProduceStepID<>0)
		order by ProductID,FiscalYear,SerialNo  '

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		 select  a.*,b.DocDate ,Suspend --,c.DocRowNo	,c.RowNo,c.ProductCount, AcceptableCount,UnacceptableCount
			, c.FinishDate  ,AcceptableCount,UnacceptableCount
			from #TaskOrder3 a
		 inner join pln.tblTaskOrderHdr b 		 on a.ProcessID = b.ProcessID  and a.ProcessNo =b.ProcessNo  and a.FiscalYear =b.FiscalYear  and a.SerialNo=b.SerialNo 
		 inner join pln.tblTaskOrderDtl c 	on a.ProcessID = c.ProcessID  and a.ProcessNo =c.ProcessNo  and a.FiscalYear =c.FiscalYear  and a.SerialNo=c.SerialNo   and a.DocRowNo=c.DocRowNo
						
end 

if @CallType=4
begin

 set @StrWhere='   a.ProcessID=610 '
	if @DocDate<>'' 
		set @StrWhere=@StrWhere + ' and a.DocDate<= ''' + @DocDate  +''''
	if @DocDateFr<>'' 
		set @StrWhere=@StrWhere + ' and a.DocDate>= ''' + @DocDateFr  +''''
	if @DocDateTo<>'' 
		set @StrWhere=@StrWhere + ' and a.DocDate<= ''' + @DocDateTo  +''''
	if @OrderFiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and a.BaseFiscalYear>= ' + str(@OrderFiscalYearFr)  +''
	if @OrderSerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and a.BaseSerialNo>= ' + str(@OrderSerialNoFr)  +''
	if @OrderFiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and a.BaseFiscalYear<= ' + str(@OrderFiscalYearTo)  +''
	if @OrderSerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and a.BaseSerialNo<= ' + str(@OrderSerialNoTo)  +''
			
	if @TaskFiscalYearFr<>0 
		set @StrWhere=@StrWhere + ' and a.FiscalYear>= ' + str(@TaskFiscalYearFr)  +''
	if @TaskSerialNoFr<>0 
		set @StrWhere=@StrWhere + ' and a.SerialNo>= ' + str(@TaskSerialNoFr)  +''
	if @TaskFiscalYearTo<>0 
		set @StrWhere=@StrWhere + ' and a.FiscalYear<= ' + str(@TaskFiscalYearTo)  +''
	if @TaskSerialNoTo<>0 
		set @StrWhere=@StrWhere + ' and a.SerialNo<= ' + str(@TaskSerialNoTo)  +''
	
	if @BatchNo<>'' 
		set @StrWhere=@StrWhere + ' and a.BatchNo= ''' + @BatchNo  +''''

	if @ProductID<>'' 
		set @StrWhere=@StrWhere + ' and a.ProductID= ''' + @ProductID  +''''
	if @DocRowNoFr<>0 
		set @StrWhere=@StrWhere + ' and b.DocRowNo>= ' + str(@DocRowNoFr)  +''
	if @DocRowNoTo<>0 
		set @StrWhere=@StrWhere + ' and b.DocRowNo<= ' + str(@DocRowNoTo)  +''
	if @ProduceStepIDFr<>0 
		set @StrWhere=@StrWhere + ' and b.ProduceStepID>= ' + str(@ProduceStepIDFr)  +''
	if @ProduceStepIDTo<>0 
		set @StrWhere=@StrWhere + ' and b.ProduceStepID<= ' + str(@ProduceStepIDTo)  +''

	if @FormulaNoFr<>0 
		set @StrWhere=@StrWhere + ' and bb.FormulaNo>= ' + str(@FormulaNoFr)  +''
	if @FormulaNoTo<>0 
		set @StrWhere=@StrWhere + ' and bb.FormulaNo<= ' + str(@FormulaNoTo)  +''
	if @StepNoFr<>0 
		set @StrWhere=@StrWhere + ' and bb.StepNo>= ' + str(@StepNoFr)  +''
	if @StepNoTo<>0 
		set @StrWhere=@StrWhere + ' and bb.StepNo<= ' + str(@StepNoTo)  +''

	select BaseFiscalYear, BaseSerialNo, OrderCount ProductCount,a.FiscalYear,a.SerialNo,ProductID,OrderCount 
	,AcceptableCount ,UnacceptableCount,AcceptableCount +UnacceptableCount SumCount,AcceptableCount QtyCount,b.ProduceStepID ,b.UsageStoreID	,b.AcceptStoreID	,b.FailedStoreID
	,0 FormulaNo,0 StepNo,ProductID BatchNo
	into #tblTask
	from pln.tblTaskOrderHdr a
	inner join pln.tblTaskOrderDtl b on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo	 
	where 1=0

	set @StrSelect=' insert into #tblTask
	select a.BaseFiscalYear, a.BaseSerialNo, OrderCount ProductCount,a.FiscalYear,a.SerialNo,a.ProductID,OrderCount 
	,sum(AcceptableCount ),sum(UnacceptableCount),sum(AcceptableCount )+sum(UnacceptableCount),sum(AcceptableCount ) QtyCount,b.ProduceStepID ,p.UsageStoreID	,p.AcceptStoreID	,p.FailedStoreID
	,bb.FormulaNo,bb.StepNo,a.BatchNo
	from pln.tblTaskOrderHdr a
	inner join  pln.tblProduceOrderDtl  bb on bb.ProcessID=a.BaseProcessID  and bb.ProcessNo=a.BaseProcessNo and bb.FiscalYear=a.BaseFiscalYear and bb.SerialNo=a.BaseSerialNo and bb.DocRowNo=a.ProdDocRowNo		 
	inner join pln.tblTaskOrderDtl b
	 on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo	 	
	inner join pln.tblProduceStepDtl  p on a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo and b.ProduceStepID=p.ProduceStepID
	where  '+ @StrWhere +'	
	Group by a.BaseFiscalYear, a.BaseSerialNo, OrderCount ,a.FiscalYear,a.SerialNo,a.ProductID,OrderCount ,p.UsageStoreID	,p.AcceptStoreID	,p.FailedStoreID,bb.FormulaNo,bb.StepNo,a.BatchNo
	,b.ProduceStepID	'
		
	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;

update #tblTask	set QtyCount=0
	
update #tblTask
	set QtyCount=b.GoodsQuantity  
	from #tblTask a 
	inner join 	
	(select sum(s.GoodsQuantity  ) GoodsQuantity,b.FiscalYear,b.SerialNo ,b.ProduceStepID 
	from 	pln.tblTaskOrderDtl b
	inner join pln.tblTaskOrderHdr a on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo	 	
	inner join inv.tblStorageDocsDtl s on 	b.ProcessID =s.BaseProcessID and b.ProcessNo =s.BaseProcessNo and b.FiscalYear =s.BaseFiscalYear and b.SerialNo  =s.BaseSerialNo and b.DocRowNo =s.BaseDocRowNo	and a.ProductID=s.GoodsID	
	where s.ProcessID in (72,73) 
	group by b.FiscalYear,b.SerialNo ,b.ProduceStepID
	) b on a.FiscalYear =b.FiscalYear and a.SerialNo =b.SerialNo and a.ProduceStepID =b.ProduceStepID 

	select  ltrim(str(BaseFiscalYear))+'/'+	ltrim(str(BaseSerialNo)) BaseSerialNo,	ProductCount,ltrim(str(FiscalYear))+'/'+	ltrim(str(SerialNo))SerialNo	,
		 ProductID	,OrderCount	,AcceptableCount	,UnacceptableCount,SumCount,	QtyCount,SumCount-	QtyCount QtyRemain,	ProduceStepID,UsageStoreID	,AcceptStoreID	,FailedStoreID
		 ,cast(( SELECT IsNull(Sum(GoodsQuantity * EnterKind),0) 
		 FROM   inv.tblStorageDocsDtl WHERE  StoreID = UsageStoreID AND GoodsID = ProductID AND DocDate <= @DocDate AND  FiscalYear=FiscalYear ) as float )	as Remain
	from #tblTask a	

end
end 
GO
