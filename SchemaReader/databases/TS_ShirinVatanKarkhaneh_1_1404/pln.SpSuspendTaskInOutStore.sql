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
-- Description	 : < انجام تعلیق دستور کار>
-- ==============================================
Create PROCEDURE pln.SpSuspendTaskInOutStore
	@CallType			int,
	@ExtraParams		NVarChar(Max) = ''
	
WITH ENCRYPTION
AS
BEGIN

declare @DocDate			char(10);
declare @OrderFiscalYearFr  int;
declare @OrderSerialNoFr	int;
declare @OrderFiscalYearTo  int;
declare @OrderSerialNoTo	int;
declare @TaskFiscalYearFr  int;
declare @TaskSerialNoFr	int;
declare @TaskFiscalYearTo  int;
declare @TaskSerialNoTo	int;
declare @BatchNo			varchar(20);
declare @ProductID			varchar(20);

declare @FiscalYear		int;
declare @SerialNo		int;
DECLARE @StrSelect		NVarChar(Max);
DECLARE @StrWhere 		NVarChar(Max);

	SET @DocDate			 = pub.funSplitString(@ExtraParams, '@', 1);
	SET @OrderFiscalYearFr	 = pub.funSplitString(@ExtraParams, '@', 2);
	SET @OrderSerialNoFr	 = pub.funSplitString(@ExtraParams, '@', 3);
	SET @OrderFiscalYearTo	 = pub.funSplitString(@ExtraParams, '@', 4);
	SET @OrderSerialNoTo	 = pub.funSplitString(@ExtraParams, '@', 5);
	SET @TaskFiscalYearFr	 = pub.funSplitString(@ExtraParams, '@', 6);
	SET @TaskSerialNoFr	 = pub.funSplitString(@ExtraParams, '@', 7);
	SET @TaskFiscalYearTo	 = pub.funSplitString(@ExtraParams, '@', 8);
	SET @TaskSerialNoTo	 = pub.funSplitString(@ExtraParams, '@', 9);
	SET @BatchNo			 = pub.funSplitString(@ExtraParams, '@', 10);
	SET @ProductID			 = pub.funSplitString(@ExtraParams, '@', 11);
	
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
 
	select  ProcessID,ProcessNo,FiscalYear,SerialNo,0 RowNo,0 DocRowNo,0 ProductCount ,ProductID,    1 CallType,GoodsName ProductName ,0 ProduceStepID ,0 HasSerial 
			into #TaskOrder
	from pln.tblTaskOrderHdr a
	inner join   inv.tblGoodsDtl g on a.ProductID=g.GoodsID and g.LanguageID=1
	 where 1=0
	  ----  برای سفارشهایی که قبض صادر نشده است
	set @StrSelect=' insert into #TaskOrder 		
		select ProcessID,	ProcessNo	,FiscalYear,	SerialNo,	RowNo,	DocRowNo,	ProductCount	,ProductID	,CallType,	ProductName	,ProduceStepID	,HasSerial	
			from (	select  Distinct a.ProduceStepSerialNo,a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,isnull(b.RowNo,0)RowNo,isnull(b.DocRowNo,0)DocRowNo,a.OrderCount ProductCount
			,a.ProductID,'+ str(@CallType)+' CallType,GoodsName ProductName
			,ProduceStepID,gg.HasSerial
		from pln.tblTaskOrderHdr a  
		Left join (
			select ProcessID,ProcessNo,FiscalYear,SerialNo ,DocRowNo
				from pln.tblTaskOrderDtl ta							 
			except
			select  BaseProcessID ,BaseProcessNo ,BaseFiscalYear ,BaseSerialNo ,BaseDocRowNo
				from inv.tblStorageDocsDtl 
				where BaseProcessID=610 and ProcessID in (72,82,83,73) 
			 ) aa
		on a.ProcessID=aa.ProcessID and a.ProcessNo=aa.ProcessNo and a.FiscalYear=aa.FiscalYear and a.SerialNo=aa.SerialNo			   
		Left join pln.tblTaskOrderDtl b on aa.ProcessID=b.ProcessID and aa.ProcessNo=b.ProcessNo and aa.FiscalYear=b.FiscalYear and aa.SerialNo=b.SerialNo	 and aa.DocRowNo=b.DocRowNo
		inner join inv.tblGoodsDtl g on a.ProductID=g.GoodsID and g.LanguageID=1
		inner join   inv.tblGoods	gg on a.ProductID=gg.GoodsID 
		where Suspend=1 and TaskStateID<>4 and '+ @StrWhere +'	
		 ) a 
		where ProduceStepID =isnull((select top 1 ProduceStepID from pln.tblProduceStepDtl  p where  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo order by NeedStep desc ,ProduceStepID Desc ),0)
		or ProduceStepID in (select ProduceStepID from prd.tblFormulasDtl p where  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo and ProduceStepID<>0)
		order by ProductID,FiscalYear,SerialNo  '

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;

		select *  ,ToolID ProductID 
					into  #TaskOrder2 
		from 	pln.tblTaskOrderDtl where 1=0
			  --- برای سفارشهایی که برای قسمتی از سفارش قبض صادر شده  مانند ثبت ریز مرحله نهایی در چندین سطر
		set @StrSelect=' insert into #TaskOrder2 
		 select aa.*  ,a.ProductID	
			from 	pln.tblTaskOrderDtl aa		
			inner join pln.tblTaskOrderHdr a on a.ProcessID=aa.ProcessID and a.ProcessNo=aa.ProcessNo and a.FiscalYear=aa.FiscalYear and a.SerialNo=aa.SerialNo			   
			inner join  pln.tblProduceOrderDtl  bb on bb.ProcessID=a.BaseProcessID  and bb.ProcessNo=a.BaseProcessNo and bb.FiscalYear=a.BaseFiscalYear and bb.SerialNo=a.BaseSerialNo and bb.DocRowNo=a.ProdDocRowNo
			inner join  ( select  max(ProduceStepID) ProduceStepID ,ProductID,SerialNo from  pln.tblProduceStepDtl where  NeedStep=1 Group by ProductID,SerialNo)	p 
			On  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo and aa.ProduceStepID=p.ProduceStepID
		where  Suspend=1 and TaskStateID<>4 and '+ @StrWhere +'	 '   
	
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
				 -- حذف سطرهایی که در جدول بالا موجود و تکراری میباشداست
		delete from #TaskOrder2 
		from  #TaskOrder2 a
		inner join  #TaskOrder b
		on a.ProcessID = b.ProcessID  and a.ProcessNo =b.ProcessNo  
		and a.FiscalYear =b.FiscalYear  and a.SerialNo=b.SerialNo  
		and a.ProductID=b.ProductID  

		insert into #TaskOrder 
		(ProcessID,ProcessNo,FiscalYear,SerialNo,ProductID,CallType,ProductName,ProduceStepID,HasSerial)
		select ProcessID,ProcessNo,FiscalYear,SerialNo,ProductID,@CallType, GoodsName ProductName,ProduceStepID,HasSerial
		from #TaskOrder2 a
		inner join   inv.tblGoodsDtl g on a.ProductID=g.GoodsID and g.LanguageID=1
		inner join   inv.tblGoods gg on a.ProductID=gg.GoodsID 
		
 		
		--ProcessID,	ProcessNo	,FiscalYear,	SerialNo,	RowNo	,DocRowNo,	ProductCount,	ProductID	,CallType,	ProductName,	ProduceStepID,	HasSerial	,DocDate
		 select  a.*,b.DocDate --,c.DocRowNo	,c.RowNo,c.ProductCount, AcceptableCount,UnacceptableCount
			from #TaskOrder a
		 inner join pln.tblTaskOrderHdr b 		 on a.ProcessID = b.ProcessID  and a.ProcessNo =b.ProcessNo  and a.FiscalYear =b.FiscalYear  and a.SerialNo=b.SerialNo 
					
end 
if @CallType=2
begin

 set @StrWhere='   a.ProcessID=610 '
	 if @DocDate<>'' 
		set @StrWhere=@StrWhere + ' and a.DocDate<= ''' + @DocDate  +''''
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
 

	set @StrSelect='	select Distinct a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo, RowNo, DocRowNo,a.DocDate,GoodsQuantity ProductCount,1 DocStep
	,a.ProductID,'+ str(@CallType)+' CallType	,GoodsName ProductName	, aa.BaseDocRowNo
		from inv.tblStorageDocsDtl aa
		inner join pln.tblTaskOrderHdr a on a.ProcessID=aa.BaseProcessID and a.ProcessNo=aa.BaseProcessNo and a.FiscalYear=aa.BaseFiscalYear and a.SerialNo=aa.BaseSerialNo			   		
		inner join   inv.tblGoodsDtl g on a.ProductID=g.GoodsID and g.LanguageID=1
		where Suspend=1 and aa.ProcessID in (72,73)
		and '+ @StrWhere +'	
			order by a.ProductID,a.FiscalYear,a.SerialNo'

	
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
			
			
end 
end 
GO
