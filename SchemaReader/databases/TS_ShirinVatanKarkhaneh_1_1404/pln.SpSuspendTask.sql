USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 98/04/11
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE pln.SpSuspendTask
@CallType Int, 
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin

DECLARE	@ProcessID		Int
DECLARE	@ProcessNo		Int
DECLARE	@FiscalYear		Int 
DECLARE	@SerialNo		Int
DECLARE @StrSelect		NVarChar(Max);
DECLARE @StrWhere 		NVarChar(Max);

if @CallType=1
begin


SET @ProcessID		= pub.funSplitString(@ExtraParams, '@', 1);
SET @ProcessNo		= pub.funSplitString(@ExtraParams, '@', 2);
SET @FiscalYear		= pub.funSplitString(@ExtraParams, '@', 3);
SET @SerialNo		= pub.funSplitString(@ExtraParams, '@', 4);

    set @StrWhere=' a.ProcessID= '+ str(@ProcessID) +' and a.ProcessNo= '+ str(@ProcessNo)
    set @StrWhere=@StrWhere + ' and a.FiscalYear= ' + str(@FiscalYear)  +''
    set @StrWhere=@StrWhere + ' and a.SerialNo= ' + str(@SerialNo)  +''
	
set @StrSelect = ' 		
 select b.ProduceStepID , sum(AcceptableCount+	UnacceptableCount) DoQty,OrderCount , OrderCount *0 StepCount
 ,Case when s.AcceptStoreID='''' then a.AcceptStoreID else s.AcceptStoreID end AcceptStoreID 
 from pln.tblTaskOrderDtl  b
 inner join  pln.tblTaskOrderHdr a
	on a.ProcessID=b.ProcessID and  a.ProcessNo=b.ProcessNo and  a.FiscalYear=b.FiscalYear and  a.SerialNo=b.SerialNo
 inner join  pln.tblProduceStepDtl s
	on a.ProductID=s.ProductID and  b.ProduceStepID=s.ProduceStepID and  a.FormulaNo=s.SerialNo 
 
 where Suspend = 0 and ' + @StrWhere +'
 and b.ProduceStepID <>isnull((select max(ProduceStepID) from pln.tblProduceStepDtl  p where  a.ProductID=p.ProductID and a.ProduceStepSerialNo=p.SerialNo and  NeedStep=1),0) 
 --  برای اینکه اگر آخرین مرحله باشد باید حواله صادر کند نه اینکه تعلیق کند
 group by b.ProduceStepID , OrderCount ,a.AcceptStoreID,s.AcceptStoreID
 		'
 print @StrSelect
		Exec sp_executesql @StrSelect;
     	 
end
if @CallType=2 or @CallType=3
begin

	declare @RecID				int=0;
	declare @SessionNo			int=0;
	declare @SerialNo72			int=0;
	declare @SerialNo82			int=0;
	declare @DocRowNo			int=0;
	declare @BaseFiscalYear		int=0;
	declare @BaseSerialNo		int=0;

SET @ProcessID		= pub.funSplitString(@ExtraParams, '@', 1);
SET @ProcessNo		= pub.funSplitString(@ExtraParams, '@', 2);
SET @FiscalYear		= pub.funSplitString(@ExtraParams, '@', 3);
SET @SerialNo		= pub.funSplitString(@ExtraParams, '@', 4);
SET @BaseFiscalYear	= pub.funSplitString(@ExtraParams, '@', 5);
SET @BaseSerialNo	= pub.funSplitString(@ExtraParams, '@', 6);
 
 ------82-------------------------------------------------------------
select * from pln.tblTaskOrderHdr  
where ProcessID=@ProcessID and ProcessNo=@ProcessNo and SerialNo=@BaseSerialNo and FiscalYear=@BaseFiscalYear
	
delete from inv.tblStorageDocsHdr
from inv.tblStorageDocsHdr a
	inner join  pln.tblTaskOrderHdr t	on a.BaseProcessID=t.ProcessID	and a.BaseProcessNo=t.ProcessNo	and a.BaseFiscalYear=t.FiscalYear and a.BaseSerialNo=t.SerialNo		
	where a.SourceProcessID=@ProcessID and a.SourceProcessNo=@ProcessNo 
	and a.SourceFiscalYear=@FiscalYear	and a.SourceSerialNo=@SerialNo
	and a.ProcessID in (72,82)
	if @CallType=3
	begin	
	
		update pln.tblTaskOrderHdr  
		Set Suspend =0
		where ProcessID=@ProcessID and ProcessNo=@ProcessNo and SerialNo=@BaseSerialNo and FiscalYear=@BaseFiscalYear
	
		return
	end

declare  csrSD Cursor for 
select DocRowNo from pln.tblSuspendTaskDtl d
		where SerialNo=@SerialNo  --and DocRowNo=3
		and (select count(*) from pln.tblSuspendTaskAtm  a where  d.SerialNo=a.SerialNo and d.DocRowNo=a.DocRowNo)	>0			
open csrSD
fetch next from csrSD into @DocRowNo
while @@Fetch_status=0
begin

	select @SerialNo82=isnull(Max(SerialNo),0)+1 from inv.tblStorageDocsHdr 
	where ProcessID=82 and ProcessNo=1 and FiscalYear=@FiscalYear
	 	
insert into inv.tblStorageDocsHdr( ProcessID,ProcessNo		,FiscalYear			,SerialNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,  SourceProcessID	,SourceProcessNo, SourceFiscalYear	,SourceSerialNo,FormulaNo ,DocDate,StoreID,AcntCode,ProductCount,ProductID,RecID,SessionNo		,DocDate2,DocDate3,DocDesc)
select distinct					  82 ProcessID,1 ProcessNo,h.BaseFiscalYear, @SerialNo82  ,@ProcessID,@ProcessNo ,@BaseFiscalYear,@BaseSerialNo  ,@ProcessID			,@ProcessNo ,@FiscalYear			,@SerialNo ,FormulaNo,h.DocDate,''		,''		,d.Qty,t.ProductID ,@RecID,@SessionNo,h.DocDate,h.DocDate,'ثبت توسط سيستم - تعلیق سفارش کار  شماره '+str(t.SerialNo) 
from pln.tblSuspendTaskHdr h
inner join 	pln.tblSuspendTaskDtl d on h.SerialNo=d.SerialNo 
inner join pln.tblTaskOrderHdr  t on t.SerialNo=h.BaseSerialNo and t.FiscalYear=h.BaseFiscalYear
where d.SerialNo=@SerialNo and d.DocRowNo=@DocRowNo  


insert into inv.tblStorageDocsDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,			BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,  SourceProcessID	,SourceProcessNo, SourceFiscalYear	,SourceSerialNo,SourceDocRowNo		,DocDate		,StoreID,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,FormulaNo)
select distinct			82 ProcessID,1 ProcessNo,h.BaseFiscalYear,@SerialNo82,a.DocAtomRowNo,a.DocAtomRowNo,a.DocAtomRowNo,	@ProcessID,@ProcessNo ,@BaseFiscalYear,@BaseSerialNo ,@DocRowNo		,@ProcessID			,@ProcessNo ,@BaseFiscalYear		,@SerialNo ,@DocRowNo	,h.DocDate ,a.UsageStoreID,-1,'',	a.GoodsID,(select UnitID from inv.tblGoods where GoodsID=a.GoodsID),GoodsQuantity,GoodsQuantity,FormulaNo
from pln.tblSuspendTaskHdr h
inner join 	pln.tblSuspendTaskDtl d on h.SerialNo=d.SerialNo 
inner join pln.tblSuspendTaskAtm a on d.SerialNo=a.SerialNo and d.DocRowNo=a.DocRowNo
inner join pln.tblTaskOrderHdr  t on t.SerialNo=h.BaseSerialNo and t.FiscalYear=h.BaseFiscalYear


where d.SerialNo=@SerialNo and d.DocRowNo=@DocRowNo  
		 

	  ------72-------------------------------------------------------------

	select @SerialNo72=isnull(Max(SerialNo),0)+1 from inv.tblStorageDocsHdr 
	where ProcessID=72 and ProcessNo=1 and FiscalYear=@FiscalYear
  
insert into inv.tblStorageDocsHdr( ProcessID,ProcessNo		,FiscalYear			,SerialNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,  SourceProcessID	,SourceProcessNo, SourceFiscalYear	,SourceSerialNo,FormulaNo ,DocDate,StoreID,AcntCode,ProductCount,ProductID,RecID,SessionNo		,DocDate2,DocDate3,DocDesc)
select top 1 					  72 ProcessID,1 ProcessNo,h.BaseFiscalYear, @SerialNo72  ,@ProcessID,@ProcessNo ,@BaseFiscalYear,@BaseSerialNo  ,@ProcessID			,@ProcessNo ,@FiscalYear			,@SerialNo ,FormulaNo,h.DocDate,''		,''		,d.Qty ,ProductID ,@RecID,@SessionNo,h.DocDate,h.DocDate,'ثبت توسط سيستم - تعلیق سفارش کار  شماره '+str(t.SerialNo) 
from pln.tblSuspendTaskHdr h
inner join 	pln.tblSuspendTaskDtl d on h.SerialNo=d.SerialNo 
inner join pln.tblTaskOrderHdr  t on t.SerialNo=h.BaseSerialNo and t.FiscalYear=h.BaseFiscalYear
where d.SerialNo=@SerialNo and d.DocRowNo=@DocRowNo  

insert into inv.tblStorageDocsDtl(ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,			BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,  SourceProcessID	,SourceProcessNo, SourceFiscalYear	,SourceSerialNo,SourceDocRowNo,DocDate,StoreID,EnterKind,AcntCode,GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,FormulaNo)
select top 1 72 ProcessID,1 ProcessNo,h.BaseFiscalYear,@SerialNo72,a.DocAtomRowNo,a.DocAtomRowNo,a.DocAtomRowNo,	@ProcessID,@ProcessNo ,@BaseFiscalYear,@BaseSerialNo ,@DocRowNo		,@ProcessID			,@ProcessNo ,@BaseFiscalYear		,@SerialNo ,@DocRowNo,	h.DocDate ,d.AcceptStoreID,1,'',	t.ProductID,(select UnitID from inv.tblGoods where GoodsID=t.ProductID),d.Qty ,d.Qty ,FormulaNo
from pln.tblSuspendTaskHdr h
inner join 	pln.tblSuspendTaskDtl d on h.SerialNo=d.SerialNo 
inner join pln.tblSuspendTaskAtm a on d.SerialNo=a.SerialNo and d.DocRowNo=a.DocRowNo
inner join pln.tblTaskOrderHdr  t on t.SerialNo=h.BaseSerialNo and t.FiscalYear=h.BaseFiscalYear
where d.SerialNo=@SerialNo and d.DocRowNo=@DocRowNo  
		 
		 
fetch next from csrSD into @DocRowNo
					
end

	CLOSE csrSD
	DEALLOCATE csrSD
	
	update pln.tblTaskOrderHdr  
	Set Suspend =1
	 where ProcessID=@ProcessID and ProcessNo=@ProcessNo and SerialNo=@BaseSerialNo and FiscalYear=@BaseFiscalYear
	
	
end
end
GO
