USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation Date : 1394/08/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : وضعیت حساب مشتری و خوانده حسابها
-- ==============================================
Create procedure trs.SpSettlementDtl
@ProcessID int=0 ,
@ProcessNo int =0,
@FiscalYear int =0,
@SerialNo1 int=0,
@SerialNo2 int=0,
@CallType int=0
WITH ENCRYPTION
as
begin
Declare @StartLayerIndex	TINYINT;
	Declare @AcntPartNumber	TINYINT;
	Declare @LayerLen	TINYINT;

-- ==========

	DECLARE @PriceDecimalsToForms AS Int

	SELECT  @PriceDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PriceDecimalsToForms'
	
	DECLARE @PercentDecimals AS Int

	SELECT  @PercentDecimals=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PercentDecimals'
	

----- بروز رسانی شماره پخش در فرم تسویه در صورت مورد دار بودن
	Update trs.tblSettlementDtl 
		set BaseDstProcessID=b.BaseDistributionProcessID,	BaseDstProcessNo	=b.BaseDistributionProcessNo
			,BaseDstFiscalYear	=b.BaseDistributionFiscalYear, BaseDstSerialNo=b.BaseDistributionSerialNo
	from trs.tblSettlementDtl a
		inner join inv.tblStorageDocsHdr b
			on a.BaseSaleProcessID	=b.ProcessID 
				and a.BaseSaleProcessNo=b.ProcessNo
				and a.BaseSaleFiscalYear=b.FiscalYear
				and a.BaseSaleSerialNo=b.SerialNo
	where a.BaseDstSerialNo<>b.BaseDistributionSerialNo
----- بررسی و اصلاح مبالغ فاکتور های مورد دار

	update inv.tblStorageDocsHdr 
		set Price=GPrice
	from inv.tblStorageDocsHdr  a
	inner join (
		SELECT   Sum(GoodsQuantity*GoodsPrice) GPrice,ProcessID,ProcessNo,FiscalYear,SerialNo
		FROM inv.tblStorageDocsDtl
		where  ProcessID=90
		group by ProcessID,ProcessNo,FiscalYear,SerialNo
	) b
	on a.ProcessID=b.ProcessID And a.ProcessNo=b.ProcessNo And a.FiscalYear=b.FiscalYear And a.SerialNo=b.SerialNo
	where Price<>GPrice

	update inv.tblStorageDocsHdr 
	set Amount=b.Price+b.SidePriceSum
	from inv.tblStorageDocsHdr  a
	inner join [inv].[vwStorageDocsHdr]  b
	on a.ProcessID=b.ProcessID And a.ProcessNo=b.ProcessNo And a.FiscalYear=b.FiscalYear And a.SerialNo=b.SerialNo
	where  a.ProcessID=90 and abs(b.Price+b.SidePriceSum-a.Amount)>10
 
-----  بروز  رسانی تخفیفات پس از فروش هایی  که سند داردند ولی از فروش حذف شده اند 

update  inv.tblStorageDocsHdr 
set AfterSaleDiscount=v.Credit , AfterSaleVchNo=v.SerialNo, AfterSaleDate=v.DocDate  
from inv.tblStorageDocsHdr s
inner join  
(select * from acc.tblVoucherDtl
where SourceProcessID =95) v
on s.ProcessID=90
and s.ProcessNo=v.SourceProcessNo
and s.FiscalYear=v.SourceFiscalYear
and s.SerialNo=v.SourceSerialNo
and s.AfterSaleDiscount=0
and s.AcntCode=v.AcntCode



if @CallType =8
	begin
select  a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.DocDate DocDateSale
, Case when a.AfterSaleVchNo <>0 then a.AfterSaleDate else '' end AfterSaleDate
,ISNULL(c.DocDate,'') DocDateSettlement
,ISNULL(c.SerialNo,0) SerialNoSettlement
from inv.tblStorageDocsHdr a 
Left join trs.tblSettlementDtl b
on a.ProcessID=b.BaseSaleProcessID and a.ProcessNo=b.BaseSaleProcessNo and a.FiscalYear=b.BaseSaleFiscalYear and a.SerialNo=b.BaseSaleSerialNo
Left join trs.tblSettlementHdr c
on c.ProcessID=b.ProcessID and c.ProcessNo=b.ProcessNo and c.FiscalYear=b.FiscalYear and c.SerialNo=b.SerialNo
where a.ProcessID=@ProcessID and a.ProcessNo=@ProcessNo and a.FiscalYear=@FiscalYear and a.SerialNo=@SerialNo1


	 end
	 


if @CallType =7
	begin
			Select * From trs.tblSettlementDtl c 
		Where ID =@SerialNo2

	 end
	 
if @CallType =6
	begin
	Declare @AcntCode	varchar(20);
	Declare @ShowAll	bit;
	
	Select @ShowAll=SettingValue From pub.tblSettings
	where SettingKey='Sal_ShowAllReturnNoBaseInSettlement'
 
	 Select @AcntCode = AcntCode From inv.tblStorageDocsHdr
	 where ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND SerialNo = @SerialNo1

  Select @SerialNo1 = ID from trs.tblSettlementDtl 
  where SerialNo=@SerialNo2 and BaseSaleProcessID = @ProcessID AND BaseSaleProcessNo = @ProcessNo AND BaseSaleFiscalYear = @FiscalYear AND BaseSaleSerialNo = @SerialNo1
	
	Select * from (
	 select pub.Trim(FiscalYear) +'/'+ pub.Trim(SerialNo) Ret
		,isnull( (
		Select Distinct  SettlementID   From trs.tblSettlementRetInvoice b
				where b.ProcessID=a.ProcessID and  b.ProcessNo =a.ProcessNo 
				and  b.FiscalYear =a.FiscalYear  and b.SerialNo=a.SerialNo
				),0)Sett
				,Case when VchNo=0 then 0  else ISNULL(Amount,0) end   Price , DocStep  ,FiscalYear,SerialNo,ProcessID,ProcessNo,1 BaseType , @SerialNo1 ID
				from  inv.tblStorageDocsHdr a
							where ProcessID=100 AND ProcessNo = @ProcessNo  AND BaseSerialNo = 0
							and AcntCode=@AcntCode ) a
							
						where   @ShowAll=1 Or a.Sett in(0 , @SerialNo2)
			

	 end

if @CallType =5
	begin
	 select pub.Trim(FiscalYear) +'/'+ pub.Trim(SerialNo) Ret
		,isnull( (
		Select top 1  SettlementID   From trs.tblSettlementRetInvoice b
				where b.ProcessID=a.ProcessID and  b.ProcessNo =a.ProcessNo 
				and  b.FiscalYear =a.FiscalYear  and b.SerialNo=a.SerialNo
				),0)Sett

				,  CAse when VchNo=0 then 0  else ISNULL(Amount,0) end  Price , DocStep  ,FiscalYear,SerialNo,ProcessID,ProcessNo,1 BaseType , @SerialNo2 ID
				from  inv.tblStorageDocsHdr a
							where ProcessID=100 and   BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo1
			

	 end
	 
	if @CallType =4
	begin
	 Declare @Fact Decimal(28,9)
Select @Fact =inv.funGetRemainInvoice(@ProcessID,@ProcessNo,@FiscalYear,@SerialNo1)
if @Fact<0
set @Fact=0
Select   @Fact 

	end

	if @CallType =3
	begin
	  SELECT  * from   trs.tblPayHdr a  
	  WHERE a.SettlementSerialNo=@SerialNo2  and a.BaseProcessID=@ProcessID    and  a.BaseProcessNo=@ProcessNo
	   and a.BaseFiscalYear=  @FiscalYear and a.BaseSerialNo=@SerialNo1
	  
	end
	
	
	if @CallType =2
	begin
	
	  SELECT     ISNULL(SUM(Amount), 0) AS Amount ,  b.PayTypeID , b.ChequeNo ,b.DocDate,b.ChequeDate
	  FROM  trs.tblPayDtl b inner join    trs.tblPayHdr a  
	   on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.SerialNo=b.SerialNo and  a.FiscalYear=b.FiscalYear 
	  WHERE a.SettlementSerialNo=@SerialNo2  and a.BaseProcessID=@ProcessID    and  a.BaseProcessNo=@ProcessNo
	   and  a.BaseFiscalYear=  @FiscalYear  and a.BaseSerialNo=@SerialNo1 
	        Group by  b.PayTypeID , b.ChequeNo ,b.DocDate,b.ChequeDate
	  
	end
	
	if @CallType =1
	begin
	
	
	SELECT @StartLayerIndex = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'StartLayerIndex'	
	select @AcntPartNumber = SettingValue From pub.tblSettings Where SettingKey='AcntPartNumberForRemainCalculation'
	select @LayerLen = SettingValue From pub.tblSettings Where SettingKey='LayerLen'
		
	IF (@StartLayerIndex Is Null)		SET @StartLayerIndex = Null;
	IF (@LayerLen Is Null)		SET @LayerLen = 1;
	IF (@AcntPartNumber Is Null)		SET @AcntPartNumber = 1;
	
	update   trs.tblSettlementDtl 	
	set BasePayProcessID=p.ProcessID ,BasePayProcessNo =p.ProcessNo ,BasePayFiscalYear=p.FiscalYear ,BasePaySerialNo=p.SerialNo 
	from trs.tblSettlementDtl 	s
	inner join trs.tblPayHdr p 
	on p.SettlementID=s.SettlementID
	and p.BaseID=s.BaseSaleID
	and p.CreditCode=s.CustomerAcntCode
	and BasePayProcessID=0
					
--  جهت اصلاح مرجع فرم تسویه
	Update inv.tblStorageDocsHdr
		set BaseSettlementID=0
	from inv.tblStorageDocsHdr a
	where BaseSettlementID<>0 and 
		(Select Count(*) from trs.tblSettlementDtl b where b.SerialNo =a.BaseSettlementID and  b.BaseSaleSerialNo= a.SerialNo) =0
	
	update   trs.tblSettlementDtl 	
	set CashPrice=( Select isnull(Sum(Amount),0) Amount From trs.tblPayDtl  p
					where PayTypeID=1  and trs.tblSettlementDtl.BasePayProcessID=p.ProcessID and  trs.tblSettlementDtl.BasePayProcessNo =p.ProcessNo 	 
						and  trs.tblSettlementDtl.BasePayFiscalYear=p.FiscalYear and  trs.tblSettlementDtl.BasePaySerialNo=p.SerialNo 
						and  trs.tblSettlementDtl.CustomerAcntCode=p.CreditCode    )	
	WHERE     (ProcessID = @ProcessID) AND (ProcessNo = @ProcessNo) AND (FiscalYear = @FiscalYear) AND (SerialNo = @SerialNo1)
	
	update   trs.tblSettlementDtl 	
	set ChequePrice=( Select isnull(Sum(Amount),0) Amount From trs.tblPayDtl  p
						where PayTypeID=6  and trs.tblSettlementDtl.BasePayProcessID=p.ProcessID and  trs.tblSettlementDtl.BasePayProcessNo =p.ProcessNo 	 
							and  trs.tblSettlementDtl.BasePayFiscalYear=p.FiscalYear and  trs.tblSettlementDtl.BasePaySerialNo=p.SerialNo 
							and  trs.tblSettlementDtl.CustomerAcntCode=p.CreditCode    )	
	WHERE     (ProcessID = @ProcessID) AND (ProcessNo = @ProcessNo) AND (FiscalYear = @FiscalYear) AND (SerialNo = @SerialNo1)

	update   trs.tblSettlementDtl 	
	set DraftPrice=( Select isnull(Sum(Amount),0) Amount From trs.tblPayDtl  p
						where PayTypeID=35  and trs.tblSettlementDtl.BasePayProcessID=p.ProcessID and  trs.tblSettlementDtl.BasePayProcessNo =p.ProcessNo 	 
							and  trs.tblSettlementDtl.BasePayFiscalYear=p.FiscalYear and  trs.tblSettlementDtl.BasePaySerialNo=p.SerialNo 
							and  trs.tblSettlementDtl.CustomerAcntCode=p.CreditCode    )	
	WHERE     (ProcessID = @ProcessID) AND (ProcessNo = @ProcessNo) AND (FiscalYear = @FiscalYear) AND (SerialNo = @SerialNo1)

	update   trs.tblSettlementDtl 	
		set Discount=S.AfterSaleDiscount	

	   ,DiscountPercent =round( 1.0*S.AfterSaleDiscount/Case when Amount =0  then 1 else Amount end *100 ,@PercentDecimals)
	from trs.tblSettlementDtl D
	inner join inv.tblStorageDocsHdr S	
	ON S.ProcessID = D.BaseSaleProcessID AND S.ProcessNo = D.BaseSaleProcessNo AND S.FiscalYear = D.BaseSaleFiscalYear AND S.SerialNo = D.BaseSaleSerialNo  
	WHERE  D.ProcessID = @ProcessID AND D.ProcessNo = @ProcessNo AND D.FiscalYear = @FiscalYear AND D.SerialNo = @SerialNo1 
	--AND D.Discount<>S.AfterSaleDiscount

	SELECT D.*, pub.GetCodeName(D.CustomerAcntCode,1) AS CustomerAcntName
	, pub.funLockStatus(D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo,0) AS Locked 
	, [acc].[funAccountRemain](D.CustomerAcntCode,H.DocDate) as CustomerDebitRemain  
	,(SELECT  MaxDebitRemain FROM acc.tblAcnt WHERE PartNumber=@AcntPartNumber and AcntCode=SUBSTRING(D.CustomerAcntCode,@StartLayerIndex,@LayerLen)) MaxDebitRemain
	,(Select isnull(SUM(a),0) a from (Select                      
										  (Select  Case when VchNo=0 then 0  else Amount end  Price from  inv.tblStorageDocsHdr a where a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo ) a	
										from trs.tblSettlementRetInvoice as b 
										where   D.BaseSaleProcessID=b.SaleProcessID and D.BaseSaleProcessNo=b.SaleProcessNo and D.BaseSaleFiscalYear=b.SaleFiscalYear and D.BaseSaleSerialNo=b.SaleSerialNo
										and  b.SettlementID=D.SerialNo  and b.BaseType=1)  aa) SaleRetPrice
	,(Select isnull(SUM(a),0) a from   (Select                      
											(Select  Case when VchNo=0 then 0  else Amount end  Price from  inv.tblStorageDocsHdr a where a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo ) a	
										from trs.tblSettlementRetInvoice as b 
										where   D.BaseSaleProcessID=b.SaleProcessID and D.BaseSaleProcessNo=b.SaleProcessNo and D.BaseSaleFiscalYear=b.SaleFiscalYear and D.BaseSaleSerialNo=b.SaleSerialNo
										and  b.SettlementID=D.SerialNo  and b.BaseType=2)  aa) SaleRetPrice2
	,S.VisitorAcntCode,Case when S.VchNo=0 then 0  else ISNULL(S.Amount+S.AfterSaleDiscount,0) end TotalPriceSale
	,S.TaxSerialNo ,S.TaxSerialNoInvoice,DH.DriverID ,isnull(d.FirstName+' '+d.LastName , '') DriverName
	,DH.DistributerID1	,isnull(p1.FirstName +' '+p1.LastName , '') DistributerName1
	, DH.DistributerID2,isnull(p2.FirstName +' '+p2.LastName , '') DistributerName2	, S.IsOfficial,F.NationalIdentity,F.NationalIDNumber,sal.GetPayOffTypeName(S.PayOffTypeID,1) PayOffTypeName
	FROM         trs.tblSettlementDtl AS D 
	INNER JOIN  trs.tblSettlementHdr AS H 
		ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo  
	Left join 		inv.tblStorageDocsHdr S	
		on S.ProcessID = D.BaseSaleProcessID AND S.ProcessNo = D.BaseSaleProcessNo AND S.FiscalYear = D.BaseSaleFiscalYear AND S.SerialNo = D.BaseSaleSerialNo
	left join  sal.tblDistributionsHdr DH 
		on DH.ProcessID=D.BaseDstProcessID and DH.SerialNo =D.BaseDstSerialNo
	left join prs.tblPersonnelsDtl p1 on p1.PersonnelID=DH.DistributerID1
	left join prs.tblPersonnelsDtl p2 on p2.PersonnelID=DH.DistributerID2
	left join pub.tblDriversDtl d on d.DriverID=DH.DriverID
	OUTER APPLY acc.funGetCodeInfo(D.CustomerAcntCode) AS F
	WHERE     (D.ProcessID = @ProcessID) AND (D.ProcessNo = @ProcessNo) AND (D.FiscalYear = @FiscalYear) AND (D.SerialNo = @SerialNo1)
	ORDER BY D.DocRowNo
 
 end
 
End
GO
