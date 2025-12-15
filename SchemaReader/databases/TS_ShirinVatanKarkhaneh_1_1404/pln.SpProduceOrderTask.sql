USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation Date : 1399/01/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : ایجاد سفارش کار از سفارش تولید
-- ==============================================
Create procedure pln.SpProduceOrderTask
@ProcessID	int=0 ,
@ProcessNo	int =0,
@FiscalYear int =0,
@SerialNoFR int =0,
@SerialNoTO int =0,
@DocRowNo	int =0,
@ProductID	Varchar(20),
@DocDateFR	char(10),
@DocDateTO	char(10),
@CallType int=0
WITH ENCRYPTION
as
begin

-----برای کالا های چند پارتی---------------------------------------------------------------
	DECLARE @UnitPart TINYINT
	DECLARE @str_Goods  tinyint
	DECLARE @str_GoodsSum tinyint

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
	
-----ورود اطلاعات به جدول موقت------------------------------------------------------------------------
	 select distinct  o.BatchNo,o.ProductID,pub.funGetGoodsName (o.ProductID,1)  ProductName,o.ProductCount,FormulaNo	,StepNo,g.HasBatchNo,H.*, D.ProduceStepName, o.DocRowNo, o.DescDtl  
			 into #ProduceOrder
	 from pln.tblProduceOrderHdr H 
	 inner join pln.tblProduceOrderDtl o 
			on H.ProcessID=o.ProcessID and H.ProcessNo=o.ProcessNo and H.FiscalYear=o.FiscalYear and H.SerialNo=o.SerialNo  
	 inner join inv.tblGoods g on SUBSTRING( o.ProductID,@str_Goods+1 ,@str_GoodsSum)=g.GoodsID   and PartNumber =@UnitPart
			
	 inner join pln.tblProduceOrderStepsDtl D  
			ON D.ProduceStepID = H.ProduceStepID  and D.LanguageID=1  
	 where H.IsConfirmed=1   and  H.ProcessID=@ProcessID  and  H.ProcessNo=@ProcessNo   and  H.FiscalYear=@FiscalYear
	 and (@SerialNoFR=0 or H.SerialNo>= @SerialNoFR)
	 and (@SerialNoTO=0 or H.SerialNo<= @SerialNoTO)
	 and (@DocRowNo=0 or o.DocRowNo= @DocRowNo)
	 and (@ProductID='' or SubString( o.ProductID,1,len(@ProductID))= @ProductID)
	 and (@DocDateFR=0 or H.DocDate>= @DocDateFR)
	 and (@DocDateTO=0 or H.DocDate<= @DocDateTO)
-----ورود اطلاعات تولیدی به جدول موقت------------------------------------------------------------------------

	select *, 0 Count1,0 Count2 into #AvailProduceOrders 
	from  pln.tblAvailProduceOrders H
	where  H.ProcessID=@ProcessID  
		   and  H.ProcessNo=@ProcessNo   
		   and  H.FiscalYear=@FiscalYear
-----ورود  تعداد تولیدی 1 هر سطر سفرش  به جدول موقت------------------------------------------------------------------------
	
	Update  #AvailProduceOrders	
		set Count1 = C1
	from  #AvailProduceOrders a
	inner join 
		(select count(*) C1,ProcessID,ProcessNo,FiscalYear,SerialNo,BaseDocRowNo from #AvailProduceOrders a group by ProcessID,ProcessNo,FiscalYear,SerialNo,BaseDocRowNo )b
	on a.ProcessID=b.ProcessID
		and  a.ProcessNo=b.ProcessNo
		and  a.FiscalYear=b.FiscalYear
		and  a.SerialNo=b.SerialNo
		and  a.BaseDocRowNo=b.BaseDocRowNo
-----حذف اطلاعات سفارش کار های تولید شده جدول موقت------------------------------------------------------------------------
	
	Delete  from #ProduceOrder 
	from #ProduceOrder a
	inner join pln.tblItemRelations b
		on a.ProcessID=b.BaseProcessID
		and  a.ProcessNo=b.BaseProcessNo
		and  a.FiscalYear=b.BaseFiscalYear
		and  a.SerialNo=b.BaseSerialNo
		and  a.DocRowNo=b.BaseDocRowNo
-----ورود  تعداد تولیدی 2 هر سطر سفرش  به جدول موقت------------------------------------------------------------------------

	Update  #AvailProduceOrders	
		set Count2 = C2
	from  #AvailProduceOrders a
	inner join 
		(select count(*) C2,ProcessID,ProcessNo,FiscalYear,SerialNo,BaseDocRowNo from #AvailProduceOrders a group by ProcessID,ProcessNo,FiscalYear,SerialNo,BaseDocRowNo )b
	on a.ProcessID=b.ProcessID
		and  a.ProcessNo=b.ProcessNo
		and  a.FiscalYear=b.FiscalYear
		and  a.SerialNo=b.SerialNo
		and  a.BaseDocRowNo=b.BaseDocRowNo
----- Count1وCount2 تعداد سفار شهای لازم به تولید و تولید شده برای نمایش مانده سفارش ها  ------------------------------------------------------------------------
		 
if @CallType=0
	select Distinct  a.* , pln.funGetTransferStoreSerialNo(a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo) TransferSerialNo
	from #ProduceOrder a
	inner join  #AvailProduceOrders b
	on a.ProcessID=b.ProcessID
		and  a.ProcessNo=b.ProcessNo
		and  a.FiscalYear=b.FiscalYear
		and  a.SerialNo=b.SerialNo
		and  a.DocRowNo=b.BaseDocRowNo
	where 	Count1=Count2 and IsFinished=0
	order by a.FiscalYear, a.SerialNo,a.DocRowNo
else
	select Distinct  a.* , pln.funGetTransferStoreSerialNo(a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo) TransferSerialNo
	from #ProduceOrder a
	inner join  #AvailProduceOrders b
	on a.ProcessID=b.ProcessID
		and  a.ProcessNo=b.ProcessNo
		and  a.FiscalYear=b.FiscalYear
		and  a.SerialNo=b.SerialNo
		and  a.DocRowNo=b.BaseDocRowNo
		where IsFinished=0
	order by a.FiscalYear, a.SerialNo,a.DocRowNo
End
GO
