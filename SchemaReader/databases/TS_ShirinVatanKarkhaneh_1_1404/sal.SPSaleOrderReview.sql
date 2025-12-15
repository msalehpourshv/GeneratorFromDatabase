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
Create PROCEDURE sal.SPSaleOrderReview 
@CallType Int, 
@AcntCode as varchar(20),
@GoodsID as varchar(20),
@StoreID as varchar(20),
@FromDate as varchar(10),
@ToDate as varchar(10),
@ShowOrder as integer,
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin

DECLARE @StrSelect0		NVarChar(max)
DECLARE @StrSelect		NVarChar(max)
DECLARE @StrSelect2		NVarChar(max)
DECLARE @StrFrom		NVarChar(2000)
DECLARE @StrWhere		NVarChar(2000)
DECLARE @StrWhere2		NVarChar(2000)
DECLARE @StrGoods		NVarChar(2000)
DECLARE @FiscalYearFR	int  
DECLARE @FiscalYearTO	int 
DECLARE @SerialNoFR		int
DECLARE @SerialNoTO		int
DECLARE @ProcessID		int  
DECLARE @ProcessNo		int 
DECLARE @FiscalYear		int
DECLARE @SerialNo		int
DECLARE @DocRowNo		int  
DECLARE @Sale			int  
DECLARE @Order			int  
DECLARE @ProductOrder	int  

DECLARE @BaseFiscalYearFR	int  
DECLARE @BaseFiscalYearTO	int 
DECLARE @BaseSerialNoFR		int
DECLARE @BaseSerialNoTO		int

Declare @Part as tinyint=1
select @Part=[acc].[FunGetAcntInfoForRemain](1)
DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

if @CallType=1
begin
		SET @StrGoods		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
		SET @FiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @SerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
		SET @FiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
		SET @SerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
		SET @BaseFiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
		SET @BaseSerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
		SET @BaseFiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SET @BaseSerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
		
		set @StrWhere = ' 1=1 '
		set @StrWhere2 = ' 1=1 '
		if @StrGoods<>''
			begin
				set @StrWhere =@StrWhere+ @StrGoods
				set @StrWhere2 =@StrWhere2+ @StrGoods
			end

		if @ShowOrder=1
			set @StrWhere =@StrWhere+ ' AND ProductOrder<>0'
		if @ShowOrder=2
			set @StrWhere =@StrWhere+ ' AND ProductOrder=0'
		if @AcntCode<>'' 
			set @StrWhere = @StrWhere+' AND D.AcntCode  =''' + @AcntCode + ''''
		if @FromDate<>'' 
			begin
				set @StrWhere =@StrWhere+ ' AND D.DocDate	>=''' + @FromDate + ''''
				set @StrWhere2 =@StrWhere2+ ' AND D.DocDate	>=''' + @FromDate + ''''
			end
		if @ToDate<>'' 
			begin
				set @StrWhere = @StrWhere+' AND D.DocDate	<=''' + @ToDate + ''''
				set @StrWhere2 = @StrWhere2+' AND D.DocDate	<=''' + @ToDate + ''''
			end
		if @FiscalYearFR>0
			set @StrWhere =@StrWhere+ ' AND D.FiscalYear>=' +str(@FiscalYearFR)
		if @SerialNoFR>0
			set @StrWhere = @StrWhere+' AND D.SerialNo  >=' +str(@SerialNoFR)
		if @FiscalYearTO>0
			set @StrWhere =@StrWhere+ ' AND D.FiscalYear<=' +str(@FiscalYearTO)
		if @SerialNoTO>0
			set @StrWhere = @StrWhere+' AND D.SerialNo	<=' +str(@SerialNoTO)
	
		if @BaseFiscalYearFR>0
			begin
			set @StrWhere =@StrWhere+ ' AND D.BaseFiscalYear>=' +str(@BaseFiscalYearFR)
			set @StrWhere2 =@StrWhere2+ ' AND D.FiscalYear>=' +str(@BaseFiscalYearFR)
			end
		if @BaseSerialNoFR>0
			begin
			set @StrWhere = @StrWhere+' AND D.BaseSerialNo  >=' +str(@BaseSerialNoFR)
			set @StrWhere2 = @StrWhere2+' AND D.SerialNo  >=' +str(@BaseSerialNoFR)
			end
		if @BaseFiscalYearTO>0
			begin
			set @StrWhere =@StrWhere+ ' AND D.BaseFiscalYear<=' +str(@BaseFiscalYearTO)
			set @StrWhere2 =@StrWhere2+ ' AND D.FiscalYear<=' +str(@BaseFiscalYearTO)
			end
		if @BaseSerialNoTO>0
			begin
			set @StrWhere = @StrWhere+' AND D.BaseSerialNo	<=' +str(@BaseSerialNoTO)
			set @StrWhere2 = @StrWhere2+' AND D.SerialNo	<=' +str(@BaseSerialNoTO)
			end
		
	select D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,D.BaseDocRowNo,Ex.VchNo,ConfirmState ConfirmStateBase, cast('' as Nvarchar(100)) ConfirmState	,  cast('' as Nvarchar(100))  DocStepState,D.ProcessID	,D.ProcessNo,	D.FiscalYear,Ex.DocDate BaseDocDate, H.AcntCode	,cast('' as Nvarchar(500))  AcntName,H.VisitorAcntCode,cast('' as Nvarchar(500))  VisitorAcntName
		,D.GoodsID	,cast('' as Nvarchar(500))  GoodsName, D.SubUnitID,cast('' as Nvarchar(500))	UnitName,BatchNo, Pre.GoodsQuantity BaseGoodsQuantity	,	D.SerialNo ,	D.DocRowNo	,D.DocStep
		,D.DocDate,H.DocDate2,H.AgreeNo,H.SaleTypeID ,[sal].[funGetSaleTypeName](H.SaleTypeID,1) SaleTypeName,H.DocDesc2	, H.DeliveryDate,D.GoodsQuantity GoodsRemain,D.SubUnitQuantity,D.GoodsQuantity,ISNULL((SELECT SUM(DR.GoodsQuantity) from sal.tblSaleOrderDtl DR WHERE DR.BaseProcessID=D.ProcessID AND DR.BaseProcessNo=D.ProcessNo AND DR.BaseFiscalYear=D.FiscalYear AND DR.BaseSerialNo=D.SerialNo AND DR.BaseDocRowNo=D.DocRowNo ),0)SaleOdrerRetCount
		,D.StoreID, cast('' as Nvarchar(500))	StoreName	,	D.GoodsQuantity SaleCount,	D.GoodsQuantity RemainSale		,D.GoodsQuantity ProduceCount,D.GoodsQuantity  RemainProduce 
		,H.DocDesc,cast('' as Nvarchar(500))	ParamValueName	 ,	D.SerialNo IsDefaultFormulNo,	D.SerialNo FormulNo	,D.GoodsQuantity	GoodsPricePre,cast('' as Nvarchar(500))  UserName,[sal].[funGetCustomerKindName](F.CustomerKindID ,1 )CustomerKindName 	
	into #SaleOrderReview
	from  sal.tblSaleOrderHdr H 
		inner join sal.tblSaleOrderDtl D ON  H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
		left Join  inv.tblPreSaleHdr Ex  on D.BaseProcessID=Ex.ProcessID AND D.BaseProcessNo=Ex.ProcessNo AND D.BaseFiscalYear=Ex.FiscalYear AND D.BaseSerialNo=Ex.SerialNo 
		left Join  inv.tblPreSaleDtl Pre  on D.BaseProcessID=Pre.ProcessID AND D.BaseProcessNo=Pre.ProcessNo AND D.BaseFiscalYear=Pre.FiscalYear AND D.BaseSerialNo=Pre.SerialNo  AND D.BaseDocRowNo=Pre.DocRowNo 
		left join pub.tblTypeValues  v 	On cast (subString(D.DocDate ,6,2) as int)=TypeValue and TypeID = 10 and v.LanguageID = 1
		left join inv.tblStoresDtl  s on s.StoreID=D.StoreID and s.LanguageID = 1
		OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
	where 1=0
	
	 Declare @OldDbName1 Varchar(50)
	 Declare @OldDbName2 Varchar(50)
	 Declare @OldTask NVarChar(Max)

	 set @OldDbName1=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(RIGHT(DB_NAME(),4) -1)) 
	 set @OldDbName2=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(RIGHT(DB_NAME(),4) -2)) 
	 set @OldTask=''
	 --  در سال مالی جدید  تعداد تولید و مانده تولید با نمایش بدون فیلتر نشان داده نمیشود
	--if (@BaseFiscalYearFR<>RIGHT(DB_NAME(),4)  and @BaseFiscalYearFR<>0) or (@FiscalYearFR<>RIGHT(DB_NAME(),4)  and @FiscalYearFR<>0) 
		--begin
			if (select Count(*) from sys.databases where name =@OldDbName1)>0 
				set @OldTask=' 	
					+
					isnull( (	
						select sum(s.GoodsQuantity*s.EnterKind) 
						from  '+ @OldDbName1 +'.inv.tblStorageDocsDtl s
						inner join '+ @OldDbName1 +'.pln.tblTaskOrderHdr t 
							on s.BaseProcessID=t.ProcessID and s.BaseProcessNo=t.ProcessNo and s.BaseFiscalYear=t.FiscalYear and s.BaseSerialNo=t.SerialNo and t.ProductID=s.GoodsID
						inner join  '+ @OldDbName1 +'.pln.tblProduceOrderDtl p 
							on t.BaseProcessID=p.ProcessID and t.BaseProcessNo=p.ProcessNo and t.BaseFiscalYear=p.FiscalYear and t.BaseSerialNo=p.SerialNo and t.ProdDocRowNo=p.DocRowNo and t.ProductID=p.ProductID
						where  p.BaseProcessID=D.ProcessID and p.BaseProcessNo=D.ProcessNo and p.BaseFiscalYear=D.FiscalYear and p.BaseSerialNo=D.SerialNo and p.BaseDocRowNo=D.DocRowNo  and D.GoodsID=p.ProductID										
						 ),0)'
			if (select Count(*) from sys.databases where name =@OldDbName2)>0  
				set @OldTask+=' 	
				+
				isnull( (	
					select sum(s.GoodsQuantity*s.EnterKind) 
					from  '+ @OldDbName2 +'.inv.tblStorageDocsDtl s
					inner join '+ @OldDbName2 +'.pln.tblTaskOrderHdr t 
						on s.BaseProcessID=t.ProcessID and s.BaseProcessNo=t.ProcessNo and s.BaseFiscalYear=t.FiscalYear and s.BaseSerialNo=t.SerialNo and t.ProductID=s.GoodsID
					inner join  '+ @OldDbName2 +'.pln.tblProduceOrderDtl p 
						on t.BaseProcessID=p.ProcessID and t.BaseProcessNo=p.ProcessNo and t.BaseFiscalYear=p.FiscalYear and t.BaseSerialNo=p.SerialNo and t.ProdDocRowNo=p.DocRowNo and t.ProductID=p.ProductID
					where  p.BaseProcessID=D.ProcessID and p.BaseProcessNo=D.ProcessNo and p.BaseFiscalYear=D.FiscalYear and p.BaseSerialNo=D.SerialNo and p.BaseDocRowNo=D.DocRowNo  and D.GoodsID=p.ProductID										
					 ),0)'
	--	end 
		set @StrSelect0 = ' insert into #SaleOrderReview
		 select  BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo,VchNo, ConfirmStateBase,ConfirmState	,DocStepState,ProcessID	,ProcessNo,	FiscalYear	,BaseDocDate, AcntCode	,AcntName,VisitorAcntCode, VisitorAcntName,GoodsID	,GoodsName, SubUnitID,	UnitName,BatchNo		
			,BaseGoodsQuantity	,	SerialNo ,	DocRowNo	,DocStep,DocDate,DocDate2,AgreeNo,SaleTypeID ,[sal].[funGetSaleTypeName](SaleTypeID,1) SaleTypeName,DocDesc2,	DeliveryDate,GoodsRemain,0 SubUnitQuantity,GoodsQuantity,SaleOdrerRetCount,StoreID,	StoreName	,SaleCount
			,isnull(case  when GoodsQuantity=0 then BaseGoodsQuantity-	SaleCount else GoodsQuantity-	SaleCount end ,0) RemainSale
			,ProduceCount,case when ProductOrder=0 then 0 else   GoodsQuantity-ProduceCount end RemainProduce 
			,	DocDesc,	ParamValueName,IsDefaultFormulNo,FormulNo	,	isnull(GoodsPricePre,0 ),UserName, CustomerKindName
		 from (	 select  D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,D.BaseDocRowNo,Ex.VchNo, ConfirmState  ConfirmStateBase, cast('''' as Nvarchar(100)) ConfirmState
			,case when H.DocStep=1 then ''سفارش فروش '' else ''تاييد سفارش'' end  DocStepState 
			, D.ProcessID ,D.ProcessNo,D.FiscalYear,D.SerialNo,D.DocRowNo,H.DocStep ,D.DocDate ,D.StoreID
			,Ex.DocDate BaseDocDate  ,H.AcntCode, acc.funPartAcntNameRecurcive(H.AcntCode,' + str(@Part) + ') AcntName ,H.VisitorAcntCode, acc.funPartAcntNameRecurcive(H.VisitorAcntCode,' + str(@Part) + ') VisitorAcntName
			,D.GoodsID ,pub.GetGoodsName(D.GoodsID,1) GoodsName ,D.SubUnitID ,inv.funGetUnitName(D.SubUnitID,1)  UnitName,H.DeliveryDate, (SELECT  IsNull(Sum(GoodsQuantity * EnterKind),0) FROM   inv.tblStorageDocsDtl SD WHERE  SD.GoodsID = D.GoodsID And  SD.StoreID = D.StoreID And  SD.UserPriceID = D.UserPriceID And  SD.BatchNo = D.BatchNo ) GoodsRemain
			,D.GoodsQuantity,ISNULL((SELECT SUM(DR.GoodsQuantity) from sal.tblSaleOrderDtl DR WHERE DR.BaseProcessID=D.ProcessID AND DR.BaseProcessNo=D.ProcessNo AND DR.BaseFiscalYear=D.FiscalYear AND DR.BaseSerialNo=D.SerialNo AND DR.BaseDocRowNo=D.DocRowNo ),0)SaleOdrerRetCount ,Pre.GoodsQuantity BaseGoodsQuantity,D.GoodsPrice -(D.DiscountDtl/case when D.GoodsQuantity=0 then 1 else  D.GoodsQuantity end) GoodsPrice
			,D.BatchNo ,sal.funSaleOrderParamAtom(D.ProcessID ,D.ProcessNo ,D.FiscalYear ,D.SerialNo,D.DocRowNo) ParamValueName,H.DocDesc
			,v.TypeText MonName  , isnull(s.StoreName ,'''') StoreName ,ProductOrder,H.DocDate2,H.AgreeNo,H.SaleTypeID ,[sal].[funGetSaleTypeName](H.SaleTypeID,1) SaleTypeName,H.DocDesc2
				'
		set @StrSelect = ',Cast (isnull( (select sum(s.GoodsQuantity*s.EnterKind) 
						from  inv.tblStorageDocsDtl s
						inner join pln.tblTaskOrderHdr t on s.BaseProcessID=t.ProcessID and s.BaseProcessNo=t.ProcessNo and s.BaseFiscalYear=t.FiscalYear and s.BaseSerialNo=t.SerialNo and t.ProductID=s.GoodsID
						inner join  pln.tblProduceOrderDtl p on t.BaseProcessID=p.ProcessID and t.BaseProcessNo=p.ProcessNo and t.BaseFiscalYear=p.FiscalYear and t.BaseSerialNo=p.SerialNo and t.ProdDocRowNo=p.DocRowNo and t.ProductID=p.ProductID
						where  p.BaseProcessID=D.ProcessID and p.BaseProcessNo=D.ProcessNo and p.BaseFiscalYear=D.FiscalYear and p.BaseSerialNo=D.SerialNo and p.BaseDocRowNo=D.DocRowNo  and D.GoodsID=p.ProductID	),0)
						 '+ @OldTask +' as float ) ProduceCount 
			,Cast (isnull( (select sum(s.GoodsQuantity) 
						from  inv.tblStorageDocsDtl s where s.BaseProcessID=D.ProcessID and s.BaseProcessNo=D.ProcessNo and s.BaseFiscalYear=D.FiscalYear and s.BaseSerialNo=D.SerialNo and s.BaseDocRowNo=D.DocRowNo  and D.GoodsID=s.GoodsID				
						 ),0) as float ) SaleCount 
			,isnull((select top 1 SerialNo from prd.tblFormulasHdr  a where a.ProductID=D.GoodsID and a.IsDefault=1 ), 0) IsDefaultFormulNo
			,isnull((select top 1 FormulaNo from pln.tblProduceOrderDtl p 						
							where  p.BaseProcessID=D.ProcessID and p.BaseProcessNo=D.ProcessNo and p.BaseFiscalYear=D.FiscalYear and p.BaseSerialNo=D.SerialNo and p.BaseDocRowNo=D.DocRowNo  and D.GoodsID=p.ProductID),0) FormulNo
							,isnull(Pre.GoodsAmount*Pre.SubUnitQuantity -Pre.Discount +Pre.TaxOverWorthCostDtl+Pre.TollOverWorthCostDtl ,0 )GoodsPricePre,pub.GetUserName(H.SessionNo) AS UserName, [sal].[funGetCustomerKindName](F.CustomerKindID ,1 )CustomerKindName 
		from  sal.tblSaleOrderHdr H 
		inner join sal.tblSaleOrderDtl D ON  H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
		left Join  inv.tblPreSaleHdr Ex  on D.BaseProcessID=Ex.ProcessID AND D.BaseProcessNo=Ex.ProcessNo AND D.BaseFiscalYear=Ex.FiscalYear AND D.BaseSerialNo=Ex.SerialNo 
		left Join  inv.tblPreSaleDtl Pre  on D.BaseProcessID=Pre.ProcessID AND D.BaseProcessNo=Pre.ProcessNo AND D.BaseFiscalYear=Pre.FiscalYear AND D.BaseSerialNo=Pre.SerialNo  AND D.BaseDocRowNo=Pre.DocRowNo 
		left join pub.tblTypeValues  v 	On cast (subString(D.DocDate ,6,2) as int)=TypeValue and TypeID = 10 and v.LanguageID = 1
		left join inv.tblStoresDtl  s on s.StoreID=D.StoreID and s.LanguageID = 1
		OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
		where ' + @StrWhere

		set @StrSelect2 = 	''
		if @SerialNoFR=0 and @SerialNoTO=0 
			set @StrSelect2 = 	' 
		Union All
        select   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,D.SerialNo BaseSerialNo,0 BaseDocRowNo,H.VchNo, ConfirmState ConfirmStateBase, cast('''' as Nvarchar(100)) ConfirmState
			,case when H.DocStep=1 then ''پیش فاکتور'' else ''تاييد پیش فاکتور'' end  DocStepState 
			,   D.ProcessID ,D.ProcessNo,D.FiscalYear,0 SerialNo,D.DocRowNo,H.DocStep ,'''' DocDate ,D.StoreID
			,D.DocDate  BaseDocDate ,H.AcntCode, acc.funPartAcntNameRecurcive(H.AcntCode,' + str(@Part) + ') AcntName ,H.VisitorAcntCode, acc.funPartAcntNameRecurcive(H.VisitorAcntCode,' + str(@Part) + ') VisitorAcntName
			,D.GoodsID ,pub.GetGoodsName(D.GoodsID,1) GoodsName ,D.SubUnitID ,inv.funGetUnitName(D.SubUnitID,1)  UnitName,'''' DeliveryDate, (SELECT  IsNull(Sum(GoodsQuantity * EnterKind),0) FROM   inv.tblStorageDocsDtl SD WHERE  SD.GoodsID = D.GoodsID And  SD.StoreID = D.StoreID And  SD.UserPriceID = D.UserPriceID ) GoodsRemain,0 GoodsQuantity,0 SaleOdrerRetCount, D.GoodsQuantity BaseGoodsQuantity
			,0 GoodsPrice,'''' BatchNo,'''' ParamValueName
			,H.DocDesc,v.TypeText MonName  , isnull(s.StoreName ,'''') StoreName, 0 ProductOrder,'''' DocDate2,'''' AgreeNo,'''' SaleTypeID ,'''' SaleTypeName,'''' DocDesc2, 0 ProduceCount
			,Cast (isnull( (select sum(s.GoodsQuantity) from  inv.tblStorageDocsDtl s
						where s.BaseProcessID=D.ProcessID and s.BaseProcessNo=D.ProcessNo and s.BaseFiscalYear=D.FiscalYear and s.BaseSerialNo=D.SerialNo and s.BaseDocRowNo=D.DocRowNo  and D.GoodsID=s.GoodsID				
						 ),0) as float ) SaleCount 
			 ,isnull((select SerialNo from prd.tblFormulasHdr  a where a.ProductID=D.GoodsID and a.IsDefault=1 ), 0) IsDefaultFormulNo
			,isnull((select FormulaNo from pln.tblProduceOrderDtl p 						
							where  p.BaseProcessID=D.ProcessID and p.BaseProcessNo=D.ProcessNo and p.BaseFiscalYear=D.FiscalYear and p.BaseSerialNo=D.SerialNo and p.BaseDocRowNo=D.DocRowNo  and D.GoodsID=p.ProductID),0) FormulNo		
			,D.GoodsAmount*D.SubUnitQuantity -D.Discount +D.TaxOverWorthCostDtl+D.TollOverWorthCostDtl GoodsPricePre
			,pub.GetUserName(H.SessionNo) AS UserName, [sal].[funGetCustomerKindName](F.CustomerKindID ,1 )CustomerKindName 
		from  inv.tblPreSaleHdr H 
		inner join inv.tblPreSaleDtl D ON  H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
		inner join ( select  ProcessID ,ProcessNo,FiscalYear,SerialNo,DocRowNo from  inv.tblPreSaleDtl H 
						except select  BaseProcessID ,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo 	from  sal.tblSaleOrderDtl H 
		              ) Ex on D.ProcessID=Ex.ProcessID AND D.ProcessNo=Ex.ProcessNo AND D.FiscalYear=Ex.FiscalYear AND D.SerialNo=Ex.SerialNo  AND D.DocRowNo=Ex.DocRowNo 
		left join pub.tblTypeValues  v 	On cast (subString(D.DocDate ,6,2) as int)=TypeValue and TypeID = 10 and v.LanguageID = 1
		left join inv.tblStoresDtl  s on s.StoreID=D.StoreID and s.LanguageID = 1
		OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F 
		where  ' + @StrWhere2  

	 	print @StrSelect0
	 	print @StrSelect
	 	print @StrSelect2
	 	print +') a'
	
		set @StrSelect0 =	@StrSelect0 + 	@StrSelect +@StrSelect2 +') a'

		Exec sp_executesql @StrSelect0;
		
	if (select Count(*) from sys.databases where name =@OldDbName1)>0
	begin
		set @StrSelect =  '
		update #SaleOrderReview
			set VchNo=Ex.VchNo,ConfirmStateBase=Ex.ConfirmState,BaseDocDate=Ex.DocDate
		from #SaleOrderReview D
		Inner Join  '+ @OldDbName1 +'.inv.tblPreSaleHdr Ex  on D.BaseProcessID=Ex.ProcessID AND D.BaseProcessNo=Ex.ProcessNo AND D.BaseFiscalYear=Ex.FiscalYear AND D.BaseSerialNo=Ex.SerialNo 	
		where D.VchNo=0	'	
		print @StrSelect
		Exec sp_executesql @StrSelect;
	end 
	if (select Count(*) from sys.databases where name =@OldDbName2)>0
	begin
		set @StrSelect =  '
		update #SaleOrderReview
			set VchNo=Ex.VchNo,ConfirmStateBase=Ex.ConfirmState,BaseDocDate=Ex.DocDate
		from #SaleOrderReview D
		Inner Join  '+ @OldDbName2 +'.inv.tblPreSaleHdr Ex  on D.BaseProcessID=Ex.ProcessID AND D.BaseProcessNo=Ex.ProcessNo AND D.BaseFiscalYear=Ex.FiscalYear AND D.BaseSerialNo=Ex.SerialNo 	
		where D.VchNo=0	'
		print @StrSelect
		Exec sp_executesql @StrSelect;
	end  
	
	UPDATE #SaleOrderReview
	SET ConfirmState= case when VchNo<>0 then 'تاييد' else case when ConfirmStateBase=2 or ConfirmStateBase=3  then 'ابطال' else 'عادي' end end
	   ,RemainSale = RemainSale-SaleOdrerRetCount
	   ,RemainProduce=RemainProduce-SaleOdrerRetCount
	
	UPDATE #SaleOrderReview
		set RemainProduce=0
		where RemainProduce<0 

	select b.*,ISNULL((SELECT MAX(DocDate) 
	                 from inv.tblStorageDocsDtl a 
					 where ProcessID=90 and 
						 a.BaseProcessID=b.ProcessID and 
					     a.BaseProcessNo=b.ProcessNo and 
						 a.BaseFiscalYear=b.FiscalYear and 
						 a.BaseSerialNo=b.SerialNo  ),'') MaxSaleDate , TechnicalNo
						 ,CASE WHEN (select SUM(RemainSale) FROM #SaleOrderReview bb 
						   WHERE b.ProcessID=bb.ProcessID and 
						   b.ProcessNo=bb.ProcessNo and 
						   b.FiscalYear=bb.FiscalYear and 
						   b.SerialNo=bb.SerialNo )>0 THEN 'فاکتور باز' ELSE 'خاتمه یافته' END InvoiceState
	from  #SaleOrderReview b---where ProcessID	=180
	LEFT JOIN inv.tblGoods S ON S.GoodsID=SUBSTRING(b.GoodsID,@str_Goods+1,@str_GoodsSum) AND S.PartNumber=@UnitPart
end 

if @CallType=2 or @CallType=3 or @CallType=4   or @CallType=5  or @CallType=20
	begin


	
		SET @ProcessID	= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
		SET @ProcessNo	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @FiscalYear	= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
		SET @SerialNo	= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
		SET @DocRowNo	= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 

		set @StrWhere = ' 1=1 '

		 if @ProcessID>0
			set @StrWhere =@StrWhere+ ' AND D.ProcessID =' +str(@ProcessID)
		if @ProcessNo>0
			set @StrWhere =@StrWhere+ ' AND D.ProcessNo =' +str(@ProcessNo)
		if @FiscalYear>0
			set @StrWhere =@StrWhere+ ' AND D.FiscalYear=' +str(@FiscalYear)
		if @SerialNo>0
			set @StrWhere = @StrWhere+' AND D.SerialNo  =' +str(@SerialNo)
		if @DocRowNo>0
			set @StrWhere = @StrWhere+' AND D.DocRowNo  =' +str(@DocRowNo)
 
	if @CallType=20	
	begin
		select cast(isnull(SD.GoodsQuantity,0)  as float ) SaleGoodsQuantity ,isnull(SD.ProcessID,0) SaleProcessID ,isnull(SD.ProcessNo,0) SaleProcessNo,isnull(SD.FiscalYear,0) SaleFiscalYear,isnull(SD.SerialNo,0) SaleSerialNo,isnull(SD.DocDate ,0) SaleDocDate,isnull(SD.DocStep ,0) SaleDocStep 				  
		into #tbltemp20
		from inv.tblPreSaleDtl SD
		where 1=0

		set @StrSelect = '  insert into #tbltemp20
				 select  cast(isnull(SD.GoodsQuantity,0)  as float ) SaleGoodsQuantity ,isnull(SD.ProcessID,0) SaleProcessID ,isnull(SD.ProcessNo,0) SaleProcessNo,isnull(SD.FiscalYear,0) SaleFiscalYear,isnull(SD.SerialNo,0) SaleSerialNo,isnull(SD.DocDate ,0) SaleDocDate,isnull(SD.DocStep ,0) SaleDocStep 				 
					from inv.tblPreSaleHdr H  
					inner join inv.tblPreSaleDtl  D  
						ON  H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
					left join inv.tblStorageDocsDtl SD  
						ON  SD.BaseProcessID=D.ProcessID AND SD.BaseProcessNo=D.ProcessNo AND SD.BaseFiscalYear=D.FiscalYear AND SD.BaseSerialNo=D.SerialNo  AND SD.BaseDocRowNo=D.DocRowNo 
					where ' + @StrWhere +' and SD.ProcessID=90 '
	end
	if @CallType=2
	begin
		select cast(isnull(SD.GoodsQuantity,0)  as float ) SaleGoodsQuantity ,isnull(SD.ProcessID,0) SaleProcessID ,isnull(SD.ProcessNo,0) SaleProcessNo,isnull(SD.FiscalYear,0) SaleFiscalYear,isnull(SD.SerialNo,0) SaleSerialNo,isnull(SD.DocDate ,0) SaleDocDate,isnull(SD.DocStep ,0) SaleDocStep 				  
		into #tbltemp2
		from inv.tblPreSaleDtl SD
		where 1=0

		set @StrSelect = '    insert into #tbltemp2
				 select  cast(isnull(SD.GoodsQuantity,0)  as float ) SaleGoodsQuantity ,isnull(SD.ProcessID,0) SaleProcessID ,isnull(SD.ProcessNo,0) SaleProcessNo,isnull(SD.FiscalYear,0) SaleFiscalYear,isnull(SD.SerialNo,0) SaleSerialNo,isnull(SD.DocDate ,0) SaleDocDate,isnull(SD.DocStep ,0) SaleDocStep 
					from  sal.tblSaleOrderHdr H  
					inner join sal.tblSaleOrderDtl D  
						ON  H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
					left join inv.tblStorageDocsDtl SD  
						ON  SD.BaseProcessID=D.ProcessID AND SD.BaseProcessNo=D.ProcessNo AND SD.BaseFiscalYear=D.FiscalYear AND SD.BaseSerialNo=D.SerialNo  AND SD.BaseDocRowNo=D.DocRowNo 
					where ' + @StrWhere +' and SD.ProcessID=90 '
	end
	if @CallType=3
	begin
		select GoodsQuantity ,SerialNo, SerialNo SerialNo2 ,StoreID ,DescDtl  StoreName,DocDate,GoodsID ProductID ,DescDtl ProductIDName 				
		into #tbltemp3
		from inv.tblPreSaleDtl SD
		where 1=0

		set @StrSelect = '    insert into #tbltemp3
				select cast (s.GoodsQuantity as float ) GoodsQuantity ,s.SerialNo
				,ISNull((Select top 1  SerialNo From inv.tblStorageDocsDtl s2 where s.BaseProcessID=s2.BaseProcessID and s.BaseProcessNo=s2.BaseProcessNo and s.BaseFiscalYear=s2.BaseFiscalYear and s.BaseSerialNo=s2.BaseSerialNo and ProcessID=82),0) SerialNo2
				  ,s.StoreID ,isnull(st.StoreName ,'''')  StoreName,s.DocDate,p.ProductID ,pub.GetGoodsName(p.ProductID,1) ProductIDName 
					from  sal.tblSaleOrderDtl D  
					INNER JOIN pln.tblProduceOrderDtl p  
						on  p.BaseProcessID=D.ProcessID and  p.BaseProcessNo=D.ProcessNo and  p.BaseFiscalYear=D.FiscalYear and  p.BaseSerialNo=D.SerialNo  and p.BaseDocRowNo=D.DocRowNo  and p.ProductID=D.GoodsID  
					inner join pln.tblTaskOrderHdr t  
						on t.BaseProcessID=p.ProcessID and t.BaseProcessNo=p.ProcessNo and t.BaseFiscalYear=p.FiscalYear and t.BaseSerialNo=p.SerialNo and t.ProdDocRowNo=p.DocRowNo and t.ProductID=p.ProductID  
					inner join inv.tblStorageDocsDtl s  
						on s.BaseProcessID=t.ProcessID and s.BaseProcessNo=t.ProcessNo and s.BaseFiscalYear=t.FiscalYear and s.BaseSerialNo=t.SerialNo and s.GoodsID=p.ProductID  
					left join inv.tblStoresDtl  st 
						on st.StoreID=s.StoreID and st.LanguageID = 1             
					where ' + @StrWhere 
	end
	if @CallType=4
	begin
		select SerialNo,GoodsID ProductID,DescDtl ProduceStepName,DocDate FinishDate ,SerialNo AcceptableCount,	SerialNo UnacceptableCount, SerialNo ProduceStepID
		into #tbltemp4
		from inv.tblPreSaleDtl SD
		where 1=0
			set @StrSelect = ' insert into #tbltemp4				
				select  TH.SerialNo, TH.ProductID,ISnull(ProduceStepName,'''')ProduceStepName, isnull(TD.FinishDate,'''')FinishDate ,isnull(AcceptableCount ,0)AcceptableCount,	isnull(UnacceptableCount,0)UnacceptableCount,isnull(TD.ProduceStepID,0)ProduceStepID
					from  sal.tblSaleOrderDtl D  
					INNER JOIN pln.tblProduceOrderDtl p  
						on  p.BaseProcessID=D.ProcessID and  p.BaseProcessNo=D.ProcessNo and  p.BaseFiscalYear=D.FiscalYear and  p.BaseSerialNo=D.SerialNo  and p.BaseDocRowNo=D.DocRowNo  and p.ProductID=D.GoodsID  
					INNER JOIN pln.tblTaskOrderHdr TH
						on 	TH.BaseProcessID=p.ProcessID and  TH.BaseProcessNo=p.ProcessNo and  TH.BaseFiscalYear=p.FiscalYear and  TH.BaseSerialNo=p.SerialNo  and TH.ProdDocRowNo=p.DocRowNo  and TH.ProductID=p.ProductID
					left join  pln.tblTaskOrderDtl TD  
						ON  TH.ProcessID=TD.ProcessID AND TH.ProcessNo=TD.ProcessNo AND TH.FiscalYear=TD.FiscalYear AND TH.SerialNo=TD.SerialNo 
						left join pln.tblProduceStepDtl s on  s.ProductID=TH.ProductID and s.ProduceStepID=TD.ProduceStepID and s.SerialNo=TD.ProduceStepSerialNo
					where ' + @StrWhere 
	end	

	if @CallType=5
	begin
		select SerialNo,DocDate FinishDate , DescDtl  IsFinished
		into #tbltemp5
		from inv.tblPreSaleDtl SD
		where 1=0
			set @StrSelect = ' insert into #tbltemp5
				select  TH.SerialNo, TH.DocDate, case when  IsFinished=0 then '' در جریان'' else ''خاتمه یافته'' END IsFinished
					from  pln.tblProduceOrderHdr  TH
					left join  pln.tblProduceOrderDtl  TD  
						ON  TH.ProcessID=TD.ProcessID AND TH.ProcessNo=TD.ProcessNo AND TH.FiscalYear=TD.FiscalYear AND TH.SerialNo=TD.SerialNo 
					inner join pln.tblItemRelations R
						ON  R.ProcessID=TD.ProcessID AND R.ProcessNo=TD.ProcessNo AND R.FiscalYear=TD.FiscalYear AND R.SerialNo=TD.SerialNo  AND R.DocRowNo=TD.DocRowNo
					inner join sal.tblSaleOrderDtl D  	
					ON  R.BaseProcessID=D.ProcessID AND R.BaseProcessNo=D.ProcessNo AND R.BaseFiscalYear=D.FiscalYear AND R.BaseSerialNo=D.SerialNo  AND R.BaseDocRowNo=D.DocRowNo
					where ' + @StrWhere 
	end	

	print @StrSelect
	Exec sp_executesql @StrSelect;

	if @FiscalYear<>RIGHT(DB_NAME(),4)  and @FiscalYear<>0
	begin
		
		  set @FiscalYearTO=@FiscalYear

		set @FiscalYear	 = cast(  ltrim(str(RIGHT(DB_NAME(),4)) ) as int)
		
		while @FiscalYearTO<@FiscalYear
		begin
			Declare @OldDbName11 Varchar(50)	 
			set @OldDbName11=substring (DB_NAME(),1,len(DB_NAME())-4)+ltrim(str(@FiscalYearTO))
			if (select Count(*) from sys.databases where name =@OldDbName11)>0
			begin
				declare @db Sysname =@OldDbName11
				declare  @exec Nvarchar(max)=quotename(@db)+N'.sys.sp_executesql'				 
				exec @exec @StrSelect 
			end	
			set @FiscalYearTO+=1			
		end	

	end   
	if @CallType=2
		select Distinct  * from  #tbltemp2		
	if @CallType=3
		select Distinct  * from  #tbltemp3		
	if @CallType=4
		select Distinct  * from  #tbltemp4		
	if @CallType=5
		select Distinct  * from  #tbltemp5
	if @CallType=20
		select Distinct  * from  #tbltemp20		
	end	      
end
GO
