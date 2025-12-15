USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        :Jafari
-- Create date   : 1399/04/08
-- Viewed By	 : 
-- Last Modified : 
-- Description   : ایجاد سفارش تولید از سفارش فروش
-- =============================================
Create PROCEDURE pln.SpCreateProductFromOrder
	@ProcessID		SmallInt,
	@ProcessNo		TinyInt,
	@FiscalYear		SmallInt,
	@SerialNo		Int,
	@DocRowNo		Int,
	@ExtraParams		NVarChar(Max) 
	WITH ENCRYPTION
AS

BEGIN

Declare @ProduceStepID		Varchar(20)
Declare @strMsgText			NVarChar(2044)
Declare	@UserPersonnelID	Varchar(20)
Declare @ProductID			Varchar(20)
declare @FormulaNo			int 
declare @StepNo				int 
declare @RowNo				int 
declare @SessionNo			int 
declare @CountTask			int 
declare @CallType			int 
declare @ItemRelationID		int

SET @UserPersonnelID		    = LTrim(pub.funSplitString(@ExtraParams, '@', 1));
SET @CallType				    = LTrim(pub.funSplitString(@ExtraParams, '@', 2));

	select @CountTask=count(*) 
	from pln.tblTaskOrderHdr  t
	inner join  pln.tblProduceOrderDtl p
		on t.BaseProcessID=p.ProcessID and t.BaseProcessNo=p.ProcessNo and t.BaseFiscalYear=p.FiscalYear and t.BaseSerialNo=p.SerialNo and t.ProdDocRowNo =p.DocRowNo 
	inner join sal.tblSaleOrderDtl o
		on p.BaseProcessID=o.ProcessID and p.BaseProcessNo=o.ProcessNo and p.BaseFiscalYear=o.FiscalYear and p.BaseSerialNo=o.SerialNo and p.BaseDocRowNo =o.DocRowNo 
	where o.ProcessID=@ProcessID
		and o.ProcessNo=@ProcessNo
		and o.FiscalYear=@FiscalYear
		and o.SerialNo=@SerialNo
		and (@DocRowNo=0 or o.DocRowNo=@DocRowNo)

   if @CountTask>0
 	BEGIN
		SET @strMsgText=' برای این سفارش سطر '+ str(@DocRowNo) +'   قبلا سفارش دستور انجام کار ثبت شده است '
		Raiserror (@strMsgText,16,1)
		Return
	END	
	 
	delete from pln.tblProduceOrderDtl 
	where ProcessID=600 and ProcessNo=2 and FiscalYear=@FiscalYear and SerialNo=@SerialNo   and   (@DocRowNo=0 or BaseDocRowNo=@DocRowNo)

	delete from pln.tblAvailProduceOrders
	from pln.tblAvailProduceOrders a
		inner join pln.tblProduceOrderDtl b
			on a.ProcessID=b.ProcessID
			and a.ProcessNo =b.ProcessNo
			and a.FiscalYear =b.FiscalYear
			and a.SerialNo =b.SerialNo
			and a.BaseDocRowNo=b.DocRowNo
		where b.ProcessID=600 and b.ProcessNo=2 and b.FiscalYear=@FiscalYear and b.SerialNo=@SerialNo   and  (@DocRowNo=0 or b.BaseDocRowNo=@DocRowNo)

	delete from pln.tblItemRelations
	where ProcessID=600 and ProcessNo=2 and FiscalYear=@FiscalYear and SerialNo=@SerialNo and   (@DocRowNo=0 or BaseDocRowNo=@DocRowNo)
	
	delete from pln.tblProduceOrderHdr 
	where ProcessID=600 and ProcessNo=2 and FiscalYear=@FiscalYear and SerialNo=@SerialNo
	and (select count(*) from pln.tblProduceOrderDtl where ProcessID=600 and ProcessNo=2 and FiscalYear=@FiscalYear and SerialNo=@SerialNo  )=0
	
	---  فقط فراخوانی جهت حذف
	if @CallType=2
		return

if ( select count(*) from sal.tblSaleOrderDtl where  ProductOrder=1 and ProcessID=@ProcessID  and FiscalYear=@FiscalYear and SerialNo=@SerialNo and ProcessNo<>@ProcessNo )>0
	BEGIN
	declare @frmName as varchar(50)
	declare @frmName1 as varchar(50)
	declare @frmName2 as varchar(50)
	set @frmName1=' برگ سفارش فروش ' 
	set @frmName2=' برگ سفارش فروش ' 

	select  @frmName = SettingValue from pub.tblSettings where SettingKey='TitleSale'+ LTRIM(rtrim(str(@ProcessNo)))
	set @frmName1+= @frmName 

	select top 1 @ProcessNo=ProcessNo from sal.tblSaleOrderDtl where  ProductOrder=1 and ProcessID=@ProcessID  and FiscalYear=@FiscalYear and SerialNo=@SerialNo and ProcessNo<>@ProcessNo 
	select  @frmName = SettingValue from pub.tblSettings where SettingKey='TitleSale'+ LTRIM(rtrim(str(@ProcessNo)))
	set @frmName2+= @frmName 

		SET @strMsgText=' از '+ @frmName2 +' برگه '+ LTRIM(rtrim(str(@SerialNo))) +' قبلا سفارش تولید ایجاد شده است و امکان ایجاد سفارش تولیداز '+ @frmName1 +' وجود ندارد '
		Raiserror (@strMsgText,16,1)
		Return
	END	
if (	select count(*) from sal.tblSaleOrderDtl 	where ProcessID=@ProcessID 
		and ProcessNo=@ProcessNo 
		and FiscalYear=@FiscalYear 
		and SerialNo=@SerialNo
		and DocRowNo=@DocRowNo
		and ProductOrder='True' )<=0 

		return
	
	select @SessionNo=SessionNo from sal.tblSaleOrderHdr where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo 

	 SELECT  top 1 @ProduceStepID=isnull(H.ProduceStepID,'') 
     FROM pln.tblProduceOrderSteps H 
		INNER JOIN pln.tblProduceOrderStepsDtl D ON D.ProduceStepID = H.ProduceStepID 
     WHERE IsFinalStep = 1
   
   set @ProduceStepID=isnull(@ProduceStepID,'')
   if @ProduceStepID=''
 	BEGIN
		SET @strMsgText=' مراحل زمانی سفارش تولید خالی است'
		Raiserror (@strMsgText,16,1)
		Return
	END	

	if (select count(*) from pln.tblProduceOrderHdr where ProcessID=600 and ProcessNo=2 and FiscalYear=@FiscalYear and SerialNo=@SerialNo  )=0

	insert into pln.tblProduceOrderHdr (ProcessID	,ProcessNo,	FiscalYear	,SerialNo	,DocDate ,DocStep	,ProduceStepID ,RecID	,SessionNo,	StepDefault	,FormulaDefault,ConfirmDate	,ConfirmerAcntCode,IsConfirmed,DocDesc)            
		Select 600,2,	FiscalYear	,SerialNo	,DocDate ,DocStep	,@ProduceStepID ,RecID	,SessionNo,	1,1,DocDate,@UserPersonnelID,1,'ایجاد سفارش تولید از سفارش کار'
		from sal.tblSaleOrderHdr where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo 

		select @ProductID=GoodsID from sal.tblSaleOrderDtl 
		where ProcessID=@ProcessID 
		and ProcessNo=@ProcessNo 
		and FiscalYear=@FiscalYear 
		and SerialNo=@SerialNo
		and DocRowNo=@DocRowNo
		and ProductOrder='True'   

		select @RowNo=@DocRowNo

		SELECT @FormulaNo=isnull(SerialNo,0) FROM prd.tblFormulasHdr where ProductID=@ProductID And IsDefault=1
		
		if @FormulaNo=0 or @FormulaNo is Null
 		BEGIN
			SET @strMsgText=' برای محصول ' + @ProductID + ' فرمول تولید پیش فرض وجود ندارد'
			Raiserror (@strMsgText,16,1)
			Return
		END	
	
		SELECT @StepNo=isnull(SerialNo,0) FROM pln.tblProduceStepHdr where ProductID=@ProductID And IsDefaultMethod=1
		
		if @StepNo=0 or @StepNo is Null
 		BEGIN
			SET @strMsgText=' برای محصول ' + @ProductID + ' مراحل تولید پیش فرض وجود ندارد'
			Raiserror (@strMsgText,16,1)
			Return
		END	
		
		insert into pln.tblProduceOrderDtl (ProcessID	,ProcessNo,	FiscalYear	,SerialNo	,RowNo	,DocRowNo	,ProductID	,ProductCount	,FormulaNo	,StepNo	,DescDtl		
		,BaseProcessID	,BaseProcessNo,	BaseFiscalYear	,BaseSerialNo	,BaseDocRowNo,BatchNo	)            
			Select 600,2,	FiscalYear	,SerialNo	,@RowNo	,@RowNo	,GoodsID	,GoodsQuantity,@FormulaNo,@StepNo,'ایجاد سفارش تولید از سفارش فروش'
			,ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,BatchNo
			from sal.tblSaleOrderDtl where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo and DocRowNo=@DocRowNo 

	  IF @@ERROR <>0
		  BEGIN
			 SET @strMsgText= '   مشکل ثبت سفارش تولید'
				Raiserror (@strMsgText,16,1)
			 RETURN
		  END
		select @ItemRelationID =isnull(Max(ItemRelationID),0)+1 from pln.tblItemRelations
		insert into pln.tblItemRelations(ItemRelationID,ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ProductCount)
			Select @ItemRelationID,600,2		,FiscalYear,SerialNo,@RowNo,ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,GoodsQuantity
			from sal.tblSaleOrderDtl where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo and DocRowNo=@DocRowNo 

	Declare @ProcSet			NVarChar(100)=N'600@2@' + str(@FiscalYear)+ '@'+ str(@SerialNo)+ '@@0'
	Declare @RepOptions			NVarChar(100)=N''
	Declare @RepInfo			NVarChar(100)=N'1@' + str(@SessionNo) + '@1@3@3'

	select @ProcSet=REPLACE(@ProcSet, ' ','')
	select @RepOptions=REPLACE(@RepOptions, ' ','')
	select @RepInfo=REPLACE(@RepInfo, ' ','')

	update  pln.tblProduceOrderDtl
	set SubUnitQuantity =ProductCount , SubUnitID=UnitID 
	from pln.tblProduceOrderDtl a
	inner join 	inv.tblGoods  g on g.GoodsID=  a.ProductID
	where SubUnitQuantity=0

	exec [pln].[SpPln_GenerateAvailOrders] @ProcSet,@RepOptions,@RepInfo

END
GO
