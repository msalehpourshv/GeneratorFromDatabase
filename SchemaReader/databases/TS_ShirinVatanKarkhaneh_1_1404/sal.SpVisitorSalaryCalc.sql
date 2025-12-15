USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1400/09/03
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < محاسبه درصد بازاریاب >
-- ==============================================
Create PROCEDURE sal.SpVisitorSalaryCalc
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	
WITH ENCRYPTION
AS
BEGIN
	DECLARE @StrSelect		NVarChar(Max);
	Declare @StrWhere1		NVarChar(Max);
	Declare @StrWhere2 		NVarChar(Max);

	DECLARE	@LangID			Char(1);
	DECLARE	@SessionNo		Int; 
	DECLARE	@ReportID		Int;
	DECLARE	@UserID			Int;
	DECLARE	@UserIsAdmin	bit;
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);
	
	
	Declare @StartLayer		TINYINT;
	Declare @LayerLen		TINYINT;
	Declare @PartNumber		TINYINT;
	declare @CallType			Int;
	declare @FiscalYear			Int;
	declare @RetType			Int;
	declare @MonthCode			varchar(2);
	declare @VisitorAcntCode	varchar(20);
	declare @VisitPathID		varchar(20);	
	 
	declare @FromAmount float;
	declare @ToAmount	float;
	declare @FromQty	float;
	declare @ToQty		float;
	DECLARE	@InvoiceTargetInHdr	bit;
	DECLARE	@CustTargetInHdr	bit;
	DECLARE	@PackTargetInHdr	bit;
	
	declare @DBName0000		VARCHAR(500)	
	set @DBName0000 =Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

	SET @CallType		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @MonthCode		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 		
	SET @FiscalYear		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 		
	SET @VisitPathID	= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 		
	SET @VisitorAcntCode= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 		
	SET @RetType		= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 			
 
	SELECT @PartNumber = SettingValue FROM pub.tblSettings WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	SELECT @InvoiceTargetInHdr = SettingValue FROM pub.tblSettings WHERE SettingKey = 'Sal_ShowInvoiceTargetInHdrfrmVisitorTarget'
	SELECT @CustTargetInHdr = SettingValue FROM pub.tblSettings WHERE SettingKey = 'Sal_ShowCustTargetInHdrfrmVisitorTarget'
	SELECT @PackTargetInHdr = SettingValue FROM pub.tblSettings WHERE SettingKey = 'Sal_ShowPackTargetInHdrfrmVisitorTarget'
	
	select @StartLayer=acc.funGetAcntLayerStartandLen(@PartNumber,1)
	select @LayerLen=acc.funGetAcntLayerStartandLen(@PartNumber,2)
	
	set @StrWhere1=''
	set @StrWhere2=''

	if isnull(@VisitorAcntCode,'')<>''
		set @StrWhere1=' and D.VisitorAcntCode ='''+ @VisitorAcntCode +''''
	if isnull(@VisitPathID,'')<>''
		set @StrWhere2=' and b.VisitPathID ='''+ @VisitPathID +''''
	

if @CallType=1
begin

	declare @FrDate char(10);
	declare @ToDate char(10);

	set @FrDate=ltrim(rtrim(str(@FiscalYear)))+case when @MonthCode<10 then  '/0' else '/' end + ltrim(rtrim(str(@MonthCode)))+'/01'
	set @ToDate=case when @MonthCode=12 then   ltrim(rtrim(str(@FiscalYear+1))) else  ltrim(rtrim(str(@FiscalYear))) end+case when @MonthCode+1<10 then  '/0' else '/' end  
				+case when @MonthCode=12 then  	'01' else 	 ltrim(rtrim(str(@MonthCode+1))) end+'/01'

--set @FrDate='1403/05/01'
--set @ToDate='1403/05/03'

---ایجاد جدول temp------------------------------------------------------------------------------------

		
	select ProcessID,ProcessNo,FiscalYear,SerialNo,AcntCode SerialNoPNO,AcntCode,StoreID,DocDate,VisitorAcntCode,DriverID,DistributerID1,DistributerID2,AfterSaleDiscount,Discount,Discount2 ,Discount3,OtherCost,DescRetSaleID,SaleTypeID,CurrencyTypeID,LocationID,AcntCode AcntCode1,AcntCode AcntCode2,AcntCode AcntCode3,AcntCode AcntCode4
	,Price,TotalLineDiscount,CurrencyRate, case when Price>0 then (Discount+Discount2+Discount3+OtherCost+AfterSaleDiscount+TotalLineDiscount)*100/Price else 0 end as TotalPercentage,BaseDistributionSerialNo	,cast( 0 as float ) DiscountHdr, PayOffTypeID
	into #tblStorageDocsHdr
	from inv.tblStorageDocsHdr
	where 1=0
			
	select EnterKind,ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,AcntCode SerialNoPNO,GoodsID,GoodsQuantity, SubUnitQuantity,GoodsPrice,DiscountDtl,DiscountDtl DiscountDtl2,AcntCode,DocDate,VisitorAcntCode
	,cast( 0 as float ) as GoodsPriceHdr,cast( 0 as float ) as GoodsPriceAfterSaleDiscount,cast( 0 as float ) AfterSaleDiscount, cast( 0 as float ) as GoodsPriceDtl,cast( 0 as float ) Balance	
	,cast( 0 as float ) GoodsWeight,cast( 0 as float ) PureWeight,cast( 0 as float ) DiscountHdr,cast( 0 as float ) DiscountPercentHdr
	, BaseProcessID	, BaseProcessNo	, BaseFiscalYear	, BaseSerialNo	, BaseDocRowNo,AcntCode AcntVisitPathID
	into #tblStorageDocsDtl
	from inv.tblStorageDocsDtl
	where 1=0

		select AcntCode VisitPathID ,GoodsID,VisitorAcntCode , GoodsQuantity,SubUnitQuantity,GoodsPrice,
			GoodsPrice TargetCount	,GoodsPrice TargetPrice, GoodsPrice  PercentOK
			,GoodsPrice PackTarget,GoodsPrice InvoiceTarget	,GoodsPrice KindTarget	,GoodsPrice CustTarget	,GoodsPrice ConditionCount1	,GoodsPrice ConditionPercent1	,GoodsPrice ConditionCount2	,GoodsPrice ConditionPercent2		
			,AcntCode AcntVisitPathID
			,cast(0 as int) ConditionISOK1,cast(0 as int) ConditionISOK2
			,cast(0 as int) PackISOK,cast(0 as int) InvoiceISOK,cast(0 as int) KindISOK,cast(0 as int) CustISOK
			
	into #VisitorSalaryCalc	
	from inv.tblStorageDocsDtl a
	where 1=0

---پرکردن جدول temp  با اطلاعات فروش بر اساس ماه مربوطه------------------------------------------------------------------------------------


		 set @StrSelect = 
		' Insert into #tblStorageDocsHdr  
		 Select ProcessID,ProcessNo,FiscalYear,SerialNo,ltrim(rtrim(str(SerialNo)))+''@''+ltrim(rtrim(str(ProcessNo))) SerialNoPNO,AcntCode,StoreID,DocDate,VisitorAcntCode,DriverID,DistributerID1,DistributerID2,AfterSaleDiscount,Discount,Discount2,Discount3,OtherCost,DescRetSaleID,SaleTypeID,CurrencyTypeID ,LocationID,'''','''','''','''' 
				,Price,TotalLineDiscount,CurrencyRate, case when Price>0 then (Discount+Discount2+Discount3+OtherCost+AfterSaleDiscount+TotalLineDiscount)*100/Price else 0 end as TotalPercentage,BaseDistributionSerialNo
				,AfterSaleDiscount+Discount+Discount2+Discount3+OtherCost,PayOffTypeID
		 from inv.tblStorageDocsHdr H 
		 where H.ProcessID in(90,100)  and   H.DocDate>='''+@FrDate+''' and H.DocDate<'''+@ToDate+''' '
	
	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;
	 
		set @StrSelect = 
			' Insert into #tblStorageDocsDtl  
			Select D.EnterKind,D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.DocRowNo,ltrim(rtrim(str(D.SerialNo)))+''@''+ltrim(rtrim(str(D.ProcessNo))) SerialNoPNO
			,D.GoodsID,D.GoodsQuantity,0 ,D.GoodsPrice,D.DiscountDtl,CASE WHEN (IsReward=0 and IsReward0=0) THEN 0 ELSE D.DiscountDtl END   DiscountDtl2,D.AcntCode,D.DocDate,D.VisitorAcntCode
				,0 as GoodsPriceHdr,0 as GoodsPriceAfterSaleDiscount,AfterSaleDiscount,	
				ISNULL(  D.GoodsPrice*D.GoodsQuantity- DiscountDtl , 0) as GoodsPriceDtl, Price-TotalLineDiscount Balance
				,GoodsWeight,PureWeight
				,case when Price=0 then 0 else (D.GoodsPrice*GoodsQuantity-DiscountDtl) * (DiscountHdr)/Price end 
				,case when Price=0 then 0 else ((D.GoodsPrice*GoodsQuantity-DiscountDtl) * (DiscountHdr)/Price) /Price*100 end
				, BaseProcessID	, BaseProcessNo	, BaseFiscalYear	, BaseSerialNo	, BaseDocRowNo
				,acc.funGetAcntVisitPathID1(D.AcntCode,'+str(@StartLayer)+','+str(@LayerLen)+','+str(@PartNumber)+') AcntVisitPathID 	  
			from inv.tblStorageDocsDtl D 
			inner join #tblStorageDocsHdr H 
				On H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
				inner join inv.tblGoods G on G.GoodsID=D.GoodsID
			where D.ProcessID in(90,100)  and   D.DocDate>='''+@FrDate+''' and D.DocDate<'''+@ToDate+''' '+@StrWhere1+'
			
			--and SUBSTRING(D.GoodsID,1,4)=''5002''


			'

	print   @StrSelect;             
	EXEC sp_executesql @StrSelect; 

	update #tblStorageDocsDtl  
		set SubUnitQuantity= [inv].[funGetSubUnitFromGoodsQuantity] (a.GoodsID, isnull(u.SubUnitID, g.UnitID) , GoodsQuantity)  
	from #tblStorageDocsDtl   a
	inner join inv.tblGoods g  on a.GoodsID =g.GoodsID
	left join inv.tblSubUnitsDtl  u on g.GoodsID=u.GoodsID and u.ShowInInvoice=1


	delete from  #tblStorageDocsHdr 
	from #tblStorageDocsHdr H
	inner join  
	(select  ProcessID,ProcessNo,FiscalYear,SerialNo  from #tblStorageDocsHdr   
		except
	select  ProcessID,ProcessNo,FiscalYear,SerialNo from #tblStorageDocsDtl
	) D	On H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo  
	--------------------------------------------------------------------------------------------------
	
	Update   #tblStorageDocsDtl 
		set GoodsPriceHdr=GoodsPriceDtl
	Update  #tblStorageDocsDtl
		set GoodsPriceAfterSaleDiscount= ISNULL(GoodsPriceHdr - GoodsPriceHdr *(DiscountHdr+AfterSaleDiscount)/Balance , 0) 
	where Balance>0
	------------------------
	---------------------------------------------------------------------------------------------------
	-- در مقایسه آماری آیتم
	--AcntVisitPathID
	-- حذف و یا بررسی شود چون ممکن است بعضی از مشتریان گزینه مورد نظر پر نشود
	---------------------------------------------------------------------------------------------------
	delete from #tblStorageDocsDtl
	where AcntVisitPathID 	  ='' or 	VisitorAcntCode=''
	   
	set @StrSelect='
	insert   into #VisitorSalaryCalc
	select *		,cast(0 as int) ConditionISOK1		,cast(0 as int) ConditionISOK2
		,cast(0 as int) PackISOK	,cast(0 as int) InvoiceISOK	,cast(0 as int) KindISOK	,cast(0 as int) CustISOK
	from (
		select b.VisitPathID ,b.GoodsID,b.VisitorAcntCode 
		, Sum (GoodsQuantity*EnterKind*-1)GoodsQuantity		
		, Sum (SubUnitQuantity*EnterKind*-1)SubUnitQuantity		
		,Sum( GoodsPrice * GoodsQuantity *EnterKind*-1) -Sum(DiscountDtl*EnterKind*-1 ) -Sum(DiscountHdr*EnterKind*-1 ) GoodsPrice
		,TargetCount	,TargetPrice
		,Case when TargetPrice=0 then 0 else  (Sum( GoodsPrice * GoodsQuantity *EnterKind*-1) -Sum(DiscountDtl*EnterKind*-1 ) -Sum(DiscountHdr*EnterKind*-1 )) / TargetPrice*100 end PercentOK
				,case when '+ str(@PackTargetInHdr) +'= 1 then  C.PackTarget else b.PackTarget end PackTarget
				,case when '+ str(@InvoiceTargetInHdr) +'= 1 then  C.InvoiceTarget else b.InvoiceTarget end InvoiceTarget,KindTarget	
				,case when '+ str(@CustTargetInHdr) +'= 1 then  C.CustTarget else b.CustTarget end CustTarget,ConditionCount1	
				,ConditionPercent1	,ConditionCount2	,ConditionPercent2,AcntVisitPathID		 
		from #tblStorageDocsDtl a
		inner join '+@DBName0000+'.sal.tblVisitorTargetDtl b
			on a.VisitorAcntCode=b.VisitorAcntCode and SUBSTRING(a.GoodsID,1,len(b.GoodsID))=b.GoodsID
		inner join '+@DBName0000+'.sal.tblVisitorTarget C
			on  C.VisitPathID=b.VisitPathID and C.VisitorAcntCode=b.VisitorAcntCode and C.SerialNo=b.SerialNo 		
		where '+str(@MonthCode)+' >=C.MonthFr and '+str(@MonthCode)+' <=C.MonthTo '+@StrWhere2+'
		
		Group by   a.AcntVisitPathID,b.VisitPathID ,b.GoodsID,b.VisitorAcntCode,TargetCount	,TargetPrice	
		,case when '+ str(@PackTargetInHdr) +'= 1 then  C.PackTarget else b.PackTarget end
		,case when '+ str(@InvoiceTargetInHdr) +'= 1 then  C.InvoiceTarget else b.InvoiceTarget end
		,KindTarget	,case when '+ str(@CustTargetInHdr) +'= 1 then  C.CustTarget else b.CustTarget end 	
		,ConditionCount1	,ConditionPercent1	,ConditionCount2	,ConditionPercent2
		)a where  AcntVisitPathID=VisitPathID'

		print @StrSelect
	EXEC sp_executesql @StrSelect;

---محاسبه و بروز رسانی فبلد های شرایط ورود به محاسبه------------------------------------------------------------------------------------

	set @StrSelect='update #VisitorSalaryCalc
	set ConditionISOK1=b.ConditionISOK11,ConditionISOK2=b.ConditionISOK21
	from #VisitorSalaryCalc a
	inner join (
	select sum(cast( Case when PercentOK>=ConditionPercent1 then 1 else 0 end  as int))  ConditionISOK11
	 ,sum(cast( Case when PercentOK>=ConditionPercent2 then 1 else 0 end  as int))   ConditionISOK21
	 ,VisitPathID ,VisitorAcntCode 
	   from  #VisitorSalaryCalc
	   group by VisitPathID ,VisitorAcntCode  
	   ) b on a.VisitPathID=b.VisitPathID and a.VisitorAcntCode=b.VisitorAcntCode'

		print @StrSelect
	EXEC sp_executesql @StrSelect;
 
 	DECLARE	@Sal_CalcTargetWithSubUnitQuantity	bit;
	SELECT @Sal_CalcTargetWithSubUnitQuantity = SettingValue FROM pub.tblSettings WHERE SettingKey = 'Sal_CalcTargetWithSubUnitQuantity'	
	Select  @Sal_CalcTargetWithSubUnitQuantity=isnull(@Sal_CalcTargetWithSubUnitQuantity,'false')

 if @PackTargetInHdr=1
 begin
---بروز رسانی تعداد   واحد کالا ------------------------------------------------------------------------------------

	if @Sal_CalcTargetWithSubUnitQuantity=0
		set @StrSelect='update  #VisitorSalaryCalc
		 set PackISOK =PackISOK1
		 from #VisitorSalaryCalc a
		 inner join (Select Sum(GoodsQuantity) PackISOK1, VisitorAcntCode, VisitPathID  from  #VisitorSalaryCalc 
		 group by VisitorAcntCode, VisitPathID) b 
		 on a.VisitorAcntCode=b.VisitorAcntCode
		 and a.VisitPathID=b.VisitPathID '
	else
		set @StrSelect='update  #VisitorSalaryCalc
		 set PackISOK =PackISOK1
		 from #VisitorSalaryCalc a
		 inner join (Select Sum(SubUnitQuantity) PackISOK1, VisitorAcntCode, VisitPathID from  #VisitorSalaryCalc 
		 group by VisitorAcntCode, VisitPathID ) b 
		 on a.VisitorAcntCode=b.VisitorAcntCode
		 and a.VisitPathID=b.VisitPathID '
end
else
begin
---بروز رسانی تعداد   واحد کالا ------------------------------------------------------------------------------------

	if @Sal_CalcTargetWithSubUnitQuantity=0
		set @StrSelect='update  #VisitorSalaryCalc
		 set PackISOK =PackISOK1
		 from #VisitorSalaryCalc a
		 inner join (Select Sum(GoodsQuantity) PackISOK1, VisitorAcntCode, VisitPathID,GoodsID  from  #VisitorSalaryCalc 
		 group by VisitorAcntCode, VisitPathID,GoodsID ) b 
		 on a.VisitorAcntCode=b.VisitorAcntCode
		 and a.VisitPathID=b.VisitPathID
		  and a.GoodsID=b.GoodsID '
	else
		set @StrSelect='update  #VisitorSalaryCalc
		 set PackISOK =PackISOK1
		 from #VisitorSalaryCalc a
		 inner join (Select Sum(SubUnitQuantity) PackISOK1, VisitorAcntCode, VisitPathID,GoodsID from  #VisitorSalaryCalc 
		 group by VisitorAcntCode, VisitPathID,GoodsID ) b 
		 on a.VisitorAcntCode=b.VisitorAcntCode
		 and a.VisitPathID=b.VisitPathID
		 and a.GoodsID=b.GoodsID '
	end
	print @StrSelect
	EXEC sp_executesql @StrSelect;
 
---بروز رسانی تعداد های  مشتری ------------------------------------------------------------------------------------	 
	
if @CustTargetInHdr=1
	set @StrSelect=' 
	update  #VisitorSalaryCalc
	 set CustISOK =AcntCodeISOK 
	 from #VisitorSalaryCalc a
	 inner join (
			select AcntVisitPathID ,VisitorAcntCode , Count(*)  AcntCodeISOK 
			from (
					select   Distinct a.AcntVisitPathID ,a.VisitorAcntCode , a.AcntCode  from #tblStorageDocsDtl a  
					inner join  #VisitorSalaryCalc v  
						on a.VisitorAcntCode=v.VisitorAcntCode and a.AcntVisitPathID=v.VisitPathID and substring(a.GoodsID,1,len(v.GoodsID))=v.GoodsID
					left join inv.tblStorageDocsDtl b
						on a.ProcessID=b.BaseProcessID and a.ProcessNo=b.BaseProcessNo and a.FiscalYear=b.BaseFiscalYear and a.SerialNo=b.BaseSerialNo and a.DocRowNo=b.BaseDocRowNo
					where a.GoodsQuantity-isnull(b.GoodsQuantity,0)>0 and a.ProcessID=90
				) a
				group by AcntVisitPathID ,VisitorAcntCode 
			) b on a.VisitorAcntCode=b.VisitorAcntCode and a.VisitPathID=b.AcntVisitPathID '
else

	set @StrSelect=' 
	update  #VisitorSalaryCalc
	 set CustISOK =AcntCodeISOK 
	 from #VisitorSalaryCalc a
	 inner join (
			select AcntVisitPathID ,VisitorAcntCode , Count(*)  AcntCodeISOK ,GoodsID
			from (
					select   Distinct a.AcntVisitPathID ,a.VisitorAcntCode , a.AcntCode ,v.GoodsID from #tblStorageDocsDtl a  
					inner join  #VisitorSalaryCalc v  
						on a.VisitorAcntCode=v.VisitorAcntCode and a.AcntVisitPathID=v.VisitPathID and substring(a.GoodsID,1,len(v.GoodsID))=v.GoodsID
					left join inv.tblStorageDocsDtl b
						on a.ProcessID=b.BaseProcessID and a.ProcessNo=b.BaseProcessNo and a.FiscalYear=b.BaseFiscalYear and a.SerialNo=b.BaseSerialNo and a.DocRowNo=b.BaseDocRowNo
					where a.GoodsQuantity-isnull(b.GoodsQuantity,0)>0 and a.ProcessID=90
				) a
				group by AcntVisitPathID ,VisitorAcntCode ,GoodsID
			) b on a.VisitorAcntCode=b.VisitorAcntCode and a.VisitPathID=b.AcntVisitPathID and a.GoodsID=b.GoodsID '
	print @StrSelect
	EXEC sp_executesql @StrSelect;
---بروز رسانی تعداد   فاکتور - ------------------------------------------------------------------------------------	
	if @InvoiceTargetInHdr=1
		set @StrSelect=' 
		update  #VisitorSalaryCalc
		set InvoiceISOK =SerialNoISOK 
		from #VisitorSalaryCalc a
		inner join (
			select AcntVisitPathID ,VisitorAcntCode , Count(*)  SerialNoISOK 
			from (
					select   Distinct a.AcntVisitPathID ,a.VisitorAcntCode , a.SerialNo  from #tblStorageDocsDtl a  
					inner join  #VisitorSalaryCalc v  
						on a.VisitorAcntCode=v.VisitorAcntCode and a.AcntVisitPathID=v.VisitPathID and substring(a.GoodsID,1,len(v.GoodsID))=v.GoodsID
					left join inv.tblStorageDocsDtl b
						on a.ProcessID=b.BaseProcessID and a.ProcessNo=b.BaseProcessNo and a.FiscalYear=b.BaseFiscalYear and a.SerialNo=b.BaseSerialNo and a.DocRowNo=b.BaseDocRowNo
					where a.GoodsQuantity-isnull(b.GoodsQuantity,0)>0 and a.ProcessID=90
				) a
				group by AcntVisitPathID ,VisitorAcntCode 
		) b on a.VisitorAcntCode=b.VisitorAcntCode and a.VisitPathID=b.AcntVisitPathID'
	else

		set @StrSelect=' 
		update  #VisitorSalaryCalc
		set InvoiceISOK =SerialNoISOK 
		from #VisitorSalaryCalc a
		inner join (
			select AcntVisitPathID ,VisitorAcntCode , Count(*)  SerialNoISOK ,GoodsID
			from (
					select   Distinct a.AcntVisitPathID ,a.VisitorAcntCode , a.SerialNo,v.GoodsID  from #tblStorageDocsDtl a  
					inner join  #VisitorSalaryCalc v  
						on a.VisitorAcntCode=v.VisitorAcntCode and a.AcntVisitPathID=v.VisitPathID and substring(a.GoodsID,1,len(v.GoodsID))=v.GoodsID
					left join inv.tblStorageDocsDtl b
						on a.ProcessID=b.BaseProcessID and a.ProcessNo=b.BaseProcessNo and a.FiscalYear=b.BaseFiscalYear and a.SerialNo=b.BaseSerialNo and a.DocRowNo=b.BaseDocRowNo
					where a.GoodsQuantity-isnull(b.GoodsQuantity,0)>0 and a.ProcessID=90
				) a
				group by AcntVisitPathID ,VisitorAcntCode ,GoodsID
		) b on a.VisitorAcntCode=b.VisitorAcntCode and a.VisitPathID=b.AcntVisitPathID and a.GoodsID=b.GoodsID
		'
	print @StrSelect
	EXEC sp_executesql @StrSelect;
	
---بروز رسانی تعداد   فروش جور - ------------------------------------------------------------------------------------

	update  #VisitorSalaryCalc	 set KindISOK=ConditionISOK1	

---حذف اطلاعات ویزیتور هایی که به شرایط محاسبه ورود نکرده اند------------------------------------------------------------------------------------
--	 delete  from  #VisitorSalaryCalc
--	 where ConditionISOK1<ConditionCount1
--	 or ConditionISOK2<ConditionCount2

-----حذف اطلاعات ویزیتور هایی که گروه کالایی به حداقل محاسبه نرسیده است------------------------------------------------------------------------------------

--	 delete  from  #VisitorSalaryCalc 	 where PercentOK<ConditionPercent1	 
---ایجاد جدول temp  جهت محاسبه ها------------------------------------------------------------------------------------

		select  VisitPathID	,TargetCount SerialNo	,TargetCount ProcessID	,TargetCount RowNo	,TargetCount DocRowNo	,TargetCount FiscalYear
		,TargetCount ProcessNo	,TargetCount FrDegree	,TargetCount ToDegree	,TargetCount V1Percent	,TargetCount V1Price	,TargetCount V2Percent	
		,TargetCount V2Price	,TargetCount V3Percent	,TargetCount V3Price	,TargetCount V4Percent	,TargetCount V4Price	,TargetCount V5Percent	
		,TargetCount V5Price	, TargetCount MonthFr	,TargetCount MonthTo
		into #tblVisitorPcntPrc
		from  #VisitorSalaryCalc
		where 1=0
		
		select  1151 ProcessID, VisitPathID GoodsID ,PercentOK  PercentOK,PercentOK PriceISOk,PercentOK PriceISOk2,PercentOK Target	
			, PercentOK V1Prc	, PercentOK V2Prc	,PercentOK V3Prc	,PercentOK V4Prc	,PercentOK V5Prc	,VisitPathID,VisitorAcntCode			
			,ConditionISOK1,ConditionCount1,ConditionISOK2,ConditionCount2
		into #tblVisitorPcntPrc1150
		from  #VisitorSalaryCalc
		where 1=0

	set @StrSelect='
	insert into #tblVisitorPcntPrc
		select  b.VisitPathID,b.SerialNo,b.ProcessID,b.RowNo,b.DocRowNo ,b.FiscalYear,b.ProcessNo,b.FrDegree,b.ToDegree
				,b.V1Percent,b.V1Price,b.V2Percent ,b.V2Price,b.V3Percent,b.V3Price,b.V4Percent,b.V4Price,b.V5Percent,b.V5Price, MonthFr,MonthTo 				
		from '+@DBName0000+'.sal.tblVisitorPercentPrice a 
			inner join '+@DBName0000+'.sal.tblVisitorPercentPriceDtl  b
			on a.VisitPathID=b.VisitPathID and a.ProcessID=b.ProcessID  and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo 
		where '+str(@MonthCode)+' >=MonthFr and '+str(@MonthCode)+' <=MonthTo  '

		print @StrSelect
	EXEC sp_executesql @StrSelect;
		
------ salVisitorPercentPriceSale = 1151-------------------------------------------------------------------------------------		
	insert into #tblVisitorPcntPrc1150 
	select  1151 ProcessID,GoodsID, PercentOK PercentOK,GoodsPrice  PriceISOk,GoodsPrice  PriceISOk2,TargetPrice  Target
			, 0 V1Prc,0 V2Prc,0 V3Prc,0 V4Prc,0 V5Prc,a.VisitPathID,VisitorAcntCode
			,ConditionISOK1,ConditionCount1,ConditionISOK2,ConditionCount2
	from  #VisitorSalaryCalc a
	order by VisitorAcntCode ,GoodsID

--salVisitorPercentPriceInvoiceCount = 1152------------------------------------------------------------------------------------		

	insert into #tblVisitorPcntPrc1150 
	select Distinct 1152 ProcessID, case when @InvoiceTargetInHdr = 1 then  '' else GoodsID end
	,case when InvoiceTarget=0 then 0 else  InvoiceISOK/InvoiceTarget *100 end InvoicePercent,InvoiceISOK ,InvoiceISOK PriceISOk2,InvoiceTarget
	, 0 V1Prc,0 V2Prc,0 V3Prc,0 V4Prc,0 V5Prc,a.VisitPathID,VisitorAcntCode
	,ConditionISOK1,ConditionCount1,ConditionISOK2,ConditionCount2
	from  #VisitorSalaryCalc a
	order by VisitorAcntCode ,a.VisitPathID

--salVisitorPercentPriceCustCount = 1153------------------------------------------------------------------------------------		

	insert into #tblVisitorPcntPrc1150 
	select Distinct 1153 ProcessID, case when @CustTargetInHdr  = 1 then  '' else GoodsID end
	,case when CustTarget=0 then 0 else CustISOK/CustTarget *100 end CustPercent,CustISOK ,CustISOK PriceISOk2,CustTarget
	, 0 V1Prc,0 V2Prc,0 V3Prc,0 V4Prc,0 V5Prc,a.VisitPathID,VisitorAcntCode
	,ConditionISOK1,ConditionCount1,ConditionISOK2,ConditionCount2
	from  #VisitorSalaryCalc a
	order by VisitorAcntCode ,a.VisitPathID

--salVisitorPercentPricePackCount = 1154-------------------------------------------------------------------------------------		

	insert into #tblVisitorPcntPrc1150 
	select Distinct 1154 ProcessID, case when @PackTargetInHdr  = 1 then  '' else GoodsID end
	,case when PackTarget=0 then 0 else PackISOK/PackTarget *100 end PackPercent,PackISOK ,PackISOK PriceISOk2,PackTarget
	, 0 V1Prc,0 V2Prc,0 V3Prc,0 V4Prc,0 V5Prc,a.VisitPathID,VisitorAcntCode
	,ConditionISOK1,ConditionCount1,ConditionISOK2,ConditionCount2
	from  #VisitorSalaryCalc a
	order by VisitorAcntCode ,a.VisitPathID

--salVisitorPercentPriceMatchSale = 1155----------------------------------------------------------------------------------				

	insert into #tblVisitorPcntPrc1150 
	select Distinct 1155 ProcessID, '',case when KindTarget=0 then 0 else KindISOK/KindTarget *100 end KindPercent	,KindISOK , KindISOK PriceISOk2,KindTarget
	, 0 V1Prc,0 V2Prc,0 V3Prc,0 V4Prc,0 V5Prc,a.VisitPathID,VisitorAcntCode
	,ConditionISOK1,ConditionCount1,ConditionISOK2,ConditionCount2
	from  #VisitorSalaryCalc a
	order by VisitorAcntCode ,a.VisitPathID

-----بروز رسانی هدف های تعدادی----------------------------------------------------------------------------------				
	if @InvoiceTargetInHdr=1
		Update #tblVisitorPcntPrc1150
		set PriceISOk2=b.PriceISOk
		from  #tblVisitorPcntPrc1150 a
		inner join (Select Sum(PriceISOk) PriceISOk,ProcessID,VisitorAcntCode from #tblVisitorPcntPrc1150 group by ProcessID,VisitorAcntCode )b
		on b.ProcessID=1151 and  a.VisitorAcntCode=b.VisitorAcntCode
		where a.ProcessID=1152

	else
		Update #tblVisitorPcntPrc1150
		set PriceISOk2=b.PriceISOk
		from  #tblVisitorPcntPrc1150 a
		inner join 		(Select * from #tblVisitorPcntPrc1150)b
		on b.ProcessID=1151 and a.GoodsID=b.GoodsID and a.VisitorAcntCode=b.VisitorAcntCode
		where a.ProcessID=1152

	if @CustTargetInHdr=1
		Update #tblVisitorPcntPrc1150
		set PriceISOk2=b.PriceISOk
		from  #tblVisitorPcntPrc1150 a
		inner join (Select Sum(PriceISOk) PriceISOk,ProcessID,VisitorAcntCode from #tblVisitorPcntPrc1150 group by ProcessID,VisitorAcntCode )b
		on b.ProcessID=1151 and  a.VisitorAcntCode=b.VisitorAcntCode
		where a.ProcessID=1153
	else
		Update #tblVisitorPcntPrc1150
		set PriceISOk2=b.PriceISOk
		from  #tblVisitorPcntPrc1150 a
		inner join 		(Select * from #tblVisitorPcntPrc1150)b
		on b.ProcessID=1151 and a.GoodsID=b.GoodsID
		where a.ProcessID=1153

	if @PackTargetInHdr=1
		Update #tblVisitorPcntPrc1150
		set PriceISOk2=b.PriceISOk
		from  #tblVisitorPcntPrc1150 a
		inner join (Select Sum(PriceISOk) PriceISOk,ProcessID,VisitorAcntCode from #tblVisitorPcntPrc1150 group by ProcessID,VisitorAcntCode )b
		on b.ProcessID=1151 and  a.VisitorAcntCode=b.VisitorAcntCode
		where a.ProcessID=1154
	else
		Update #tblVisitorPcntPrc1150
		set PriceISOk2=b.PriceISOk
		from  #tblVisitorPcntPrc1150 a
		inner join 		(Select * from #tblVisitorPcntPrc1150)b
		on b.ProcessID=1151 and a.GoodsID=b.GoodsID
		where a.ProcessID=1154

	Update #tblVisitorPcntPrc1150
		set PriceISOk2=b.PriceISOk
		from  #tblVisitorPcntPrc1150 a
		inner join (Select Sum(PriceISOk) PriceISOk,ProcessID,VisitorAcntCode from #tblVisitorPcntPrc1150 group by ProcessID,VisitorAcntCode )b
		on b.ProcessID=1151 and  a.VisitorAcntCode=b.VisitorAcntCode
		where a.ProcessID=1155

--select * from  #tblVisitorPcntPrc1150
--select * from  #tblVisitorPcntPrc
--return
	update  #tblVisitorPcntPrc1150
	set  V1Prc = round(PriceISOk2*V1Percent/100 + PriceISOk*V1Price,0) 
		,V2Prc = round(PriceISOk2*V2Percent/100 + PriceISOk*V2Price,0)
		,V3Prc = round(PriceISOk2*V3Percent/100 + PriceISOk*V3Price,0)
		,V4Prc = round(PriceISOk2*V4Percent/100 + PriceISOk*V4Price,0)
		,V5Prc = round(PriceISOk2*V5Percent/100 + PriceISOk*V5Price,0)
	from  #tblVisitorPcntPrc1150 a
	inner join #tblVisitorPcntPrc b 
		on a.VisitPathID=b.VisitPathID 
		and  a.ProcessID=b.ProcessID 
		and PercentOK>FrDegree and PercentOK<=ToDegree
 
 update  #tblVisitorPcntPrc1150
	set  V1Prc = 0
		,V2Prc = 0
		,V3Prc = 0
		,V4Prc = 0
		,V5Prc = 0
	 where ConditionISOK1<ConditionCount1 or ConditionISOK2<ConditionCount2

-------اعمال ساختار درختی ویزیتور بالا سر------------------------------------------------------------------------------------		
		
	select 	VisitPathID	,TargetCount SerialNo	,TargetCount RowNo	,TargetCount FiscalYear	,TargetCount DocRowNo	
			,VisitorAcntCode V1AcntCode	,VisitorAcntCode V2AcntCode	,VisitorAcntCode V3AcntCode	,VisitorAcntCode V4AcntCode	
			,VisitorAcntCode V5AcntCode	,TargetCount MonthFr,TargetCount MonthTo	,VisitorAcntCode VisitorCostAcntCodePack
			,VisitorAcntCode VisitorCostAcntCodeCust ,VisitorAcntCode VisitorCostAcntCodeKind,VisitorAcntCode VisitorCostAcntCodeInvoice
			,VisitorAcntCode VisitorCostAcntCodePrice			
	into #tblVisitorTree
	from	 #VisitorSalaryCalc 
	where 1=0
	 
	 set @StrSelect='
 	insert into #tblVisitorTree
		select b.*, MonthFr,MonthTo ,VisitorCostAcntCodePack,VisitorCostAcntCodeCust
		,VisitorCostAcntCodeKind,VisitorCostAcntCodeInvoice,VisitorCostAcntCodePrice
		from '+@DBName0000+'.sal.tblVisitorTree a 
		inner join '+@DBName0000+'.sal.tblVisitorTreeDtl  b
		on a.VisitPathID=b.VisitPathID and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo 
		where '+str(@MonthCode)+' >=MonthFr and '+str(@MonthCode)+' <=MonthTo  '

	print @StrSelect
	EXEC sp_executesql @StrSelect;
 
-------ورود به جدول محاسبات ------------------------------------------------------------------------------------		
 
   delete from  sal.tblVisitorSaleResualt
   where FiscalYear=@FiscalYear and MonthCode=@MonthCode
   
   Insert into  sal.tblVisitorSaleResualt(FiscalYear ,MonthCode,ProcessID ,GoodsID	,PercentOK	,PriceISOk	,Target	,V1Prc	,V2Prc	,V3Prc	,V4Prc	,V5Prc	
		,VisitPathID	,VisitorAcntCode,V2AcntCode	,V3AcntCode,V4AcntCode,V5AcntCode,VisitorCostAcntCodePack,VisitorCostAcntCodeCust
		,VisitorCostAcntCodeKind,VisitorCostAcntCodeInvoice,VisitorCostAcntCodePrice	)
   select @FiscalYear FiscalYear ,@MonthCode MonthCode,a.ProcessID ,GoodsID	,PercentOK	,PriceISOk	,Target	,cast ( V1Prc as bigint) V1Prc
		,cast ( V2Prc as bigint) V2Prc,cast ( V3Prc as bigint) V3Prc,cast ( V4Prc as bigint) V4Prc,cast ( V5Prc as bigint) V5Prc
		,a.VisitPathID	,VisitorAcntCode,V2AcntCode	,V3AcntCode,V4AcntCode,V5AcntCode,VisitorCostAcntCodePack,VisitorCostAcntCodeCust
		,VisitorCostAcntCodeKind,VisitorCostAcntCodeInvoice,VisitorCostAcntCodePrice	
	from  #tblVisitorPcntPrc1150 a
	inner join #tblVisitorTree b on a.VisitPathID=b.VisitPathID	and a.VisitorAcntCode =b.V1AcntCode
	order by a.VisitPathID,a.VisitorAcntCode , a.ProcessID

end  

-------نمایش از جدول محاسبات ------------------------------------------------------------------------------------		
if isnull(@RetType,0)=0
	select @FiscalYear  FiscalYear ,@MonthCode MonthCode,
		case @MonthCode  when '1' then 'فروردین'  when '2' then 'اردیبهشت'  when '3' then 'خرداد'  when '4' then 'تیر'  when '5' then 'مرداد'  when '6' then 'شهریور'  
			when '7' then 'مهر'  when '8' then 'آبان'  when '9' then 'آذر'  when '10' then 'دی'  when '11' then 'بهمن' else 'اسفند' end MonthName
		,a.ProcessID,case ProcessID  when '1151' then 'مبلغ از فروش'  when '1152' then 'مبلغ از تعداد فاکتور'  when '1153' then 'مبلغ از تعداد مشتری'
			when '1154' then 'مبلغ از تعداد کارتن'  when '1155' then 'مبلغ از تعداد فروش جور'  end  ProcessName	
		,GoodsID,pub.funGetGoodsName(GoodsID,1) AS GoodsName ,PercentOK, PriceISOk	,Target	
		,V1Prc ,V2Prc ,V3Prc ,V4Prc ,V5Prc 
		,VisitPathID	,acc.funVisitPathName(VisitPathID	,1,1) VisitPathName	, REPLACE(VisitorAcntCode,' ',' ') VisitorAcntCode,pub.GetCodeName(VisitorAcntCode,1) AS VisitorAcntName1
		,REPLACE(V2AcntCode,' ',' ') V2AcntCode	,pub.GetCodeName(V2AcntCode,1) AS VisitorAcntName2	,REPLACE(V3AcntCode,' ',' ') V3AcntCode	,pub.GetCodeName(V3AcntCode,1) AS VisitorAcntName3
		,REPLACE(V4AcntCode,' ',' ') V4AcntCode,pub.GetCodeName(V4AcntCode,1) AS VisitorAcntName4	,REPLACE(V5AcntCode,' ',' ') V5AcntCode	,pub.GetCodeName(V5AcntCode,1) AS VisitorAcntName5
		,case ProcessID  when '1151' then VisitorCostAcntCodePrice  when '1152' then VisitorCostAcntCodeInvoice when '1153' then VisitorCostAcntCodeCust
			when '1154' then VisitorCostAcntCodePack when '1155' then VisitorCostAcntCodeKind  end VisitorCostAcntCode
	from  sal.tblVisitorSaleResualt a
	where	(isnull(@VisitorAcntCode,'')='' or VisitorAcntCode=@VisitorAcntCode) and (isnull(@VisitPathID,'')='' or VisitPathID=@VisitPathID)
	and MonthCode=@MonthCode and FiscalYear=@FiscalYear
	order by VisitPathID,VisitorAcntCode , a.ProcessID,GoodsID
	else
	select @FiscalYear  FiscalYear ,@MonthCode MonthCode
		,case @MonthCode  when '1' then 'فروردین'  when '2' then 'اردیبهشت'  when '3' then 'خرداد'  when '4' then 'تیر'  when '5' then 'مرداد'  when '6' then 'شهریور'  
			when '7' then 'مهر'  when '8' then 'آبان'  when '9' then 'آذر'  when '10' then 'دی'  when '11' then 'بهمن' else 'اسفند' end MonthName
		,a.ProcessID,case ProcessID  when '1151' then 'مبلغ از فروش'  when '1152' then 'مبلغ از تعداد فاکتور'  when '1153' then 'مبلغ از تعداد مشتری'
			when '1154' then 'مبلغ از تعداد کارتن'  when '1155' then 'مبلغ از تعداد فروش جور'  end  ProcessName	
		,Sum(V1Prc )V1Prc ,Sum(V2Prc )V2Prc ,Sum(V3Prc )V3Prc ,Sum(V4Prc )V4Prc ,Sum(V5Prc )V5Prc 
		,VisitPathID	,acc.funVisitPathName(VisitPathID	,1,1) VisitPathName	, REPLACE(VisitorAcntCode,' ',' ') VisitorAcntCode,pub.GetCodeName(VisitorAcntCode,1) AS VisitorAcntName1
		,REPLACE(V2AcntCode,' ',' ') V2AcntCode	,pub.GetCodeName(V2AcntCode,1) AS VisitorAcntName2	,REPLACE(V3AcntCode,' ',' ') V3AcntCode	,pub.GetCodeName(V3AcntCode,1) AS VisitorAcntName3
		,REPLACE(V4AcntCode,' ',' ') V4AcntCode,pub.GetCodeName(V4AcntCode,1) AS VisitorAcntName4	,REPLACE(V5AcntCode,' ',' ') V5AcntCode	,pub.GetCodeName(V5AcntCode,1) AS VisitorAcntName5
		,case ProcessID  when '1151' then VisitorCostAcntCodePrice  when '1152' then VisitorCostAcntCodeInvoice when '1153' then VisitorCostAcntCodeCust
			when '1154' then VisitorCostAcntCodePack when '1155' then VisitorCostAcntCodeKind  end VisitorCostAcntCode
	from  sal.tblVisitorSaleResualt a
	where	(isnull(@VisitorAcntCode,'')='' or VisitorAcntCode=@VisitorAcntCode) and (isnull(@VisitPathID,'')='' or VisitPathID=@VisitPathID)
	and MonthCode=@MonthCode and FiscalYear=@FiscalYear
	group by ProcessID	,VisitPathID	,VisitorAcntCode	,V2AcntCode	,V3AcntCode	,V4AcntCode	,V5AcntCode	,VisitorCostAcntCodePack
		,VisitorCostAcntCodeCust,VisitorCostAcntCodePrice,VisitorCostAcntCodeInvoice,VisitorCostAcntCodeKind
	order by VisitPathID,VisitorAcntCode , a.ProcessID


END
GO
