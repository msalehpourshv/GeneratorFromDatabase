USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1397/03/29
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ----------------------------------------------
-- 'گزارش سفارش خرید
-- ==============================================

Create PROCEDURE [cmr].[RptBuyOrder]
	@ExtraParams		NVarChar(Max),
	@RepOptions			VarChar(20) = '111', -- bit array	
	@RepInfo			NVarChar(100) = '1@1@1' 
	WITH ENCRYPTION
AS

BEGIN

DECLARE @StrSelect NVarChar(4000);
DECLARE @StrWhere  NVarChar(4000);
	

DECLARE	@LangID		int;
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

DECLARE	@FilterType			 Int;
DECLARE	@PartNumberEnd			 Int;
select @PartNumberEnd=max(PartNumber) from inv.tblGoods
DECLARE	@PartNumber			 Int;
DECLARE	@StartLayer			 Int;
DECLARE	@LenLayer			 Int;

DECLARE	@PartNumberGoods	 Int;
DECLARE	@StartLayerGoods	 Int;
DECLARE	@LenLayerGoods		 Int;
DECLARE	@HdrType			 Int;
DECLARE	@ProcessID			 Int;

         
	SET @LangID				 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);


DECLARE	@GoodsGroupLayer	 Int;

Set @GoodsGroupLayer=2	
select @GoodsGroupLayer=SettingValue from pub.tblSettings where SettingKey='GoodsGroupLayer'
if @GoodsGroupLayer=1
	select @GoodsGroupLayer=Layer1 from pub.tblCodeLayer where TableName='inv.tblGoods'  and PartNumber=1
if @GoodsGroupLayer=2
	select @GoodsGroupLayer=Layer1+Layer2 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
if @GoodsGroupLayer=3
	select @GoodsGroupLayer=Layer1+Layer2+Layer3 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
if @GoodsGroupLayer=4
	select @GoodsGroupLayer=Layer1+Layer2+Layer3+Layer4 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
if @GoodsGroupLayer=5
	select @GoodsGroupLayer=Layer1+Layer2+Layer3+Layer4+Layer5 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1


select @PartNumber=acc.FunGetAcntInfoForRemain(1),@StartLayer=acc.FunGetAcntInfoForRemain(2),@LenLayer=acc.FunGetAcntInfoForRemain(3)

--SET @LangID			 = pub.funSplitString(@ExtraParams, '@', 1);
SET @FilterType		 = pub.funSplitString(@ExtraParams, '@', 1);
SET @StrWhere		 = pub.funSplitString(@ExtraParams, '@', 2);
SET @HdrType		 = pub.funSplitString(@ExtraParams, '@', 3);
SET @ProcessID		 = pub.funSplitString(@ExtraParams, '@', 4);

set @StrWhere =Replace(@StrWhere,'''''','''')

select @PartNumberGoods=SettingValue from pub.tblSettings where SettingKey='UnitPart'

--Declare @PartNumberGoods int=2
--select * from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=@PartNumberGoods
select @StartLayerGoods=isnull(sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)+1 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber<@PartNumberGoods
select @LenLayerGoods=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=@PartNumberGoods


--and SubString(b.GoodsID,1,'+ str(@GoodsGroupLayer)+')=  SubString('+ @GoodsGroup+',1,'+ str(@GoodsGroupLayer)+') 


--select 

set @StrSelect=' select *,SubUnitQuantity-SubUnitQuantity2 Qty from (
Select 
case b.InOutWithServiceType when 1 then ''دایم'' when 2 then ''ورود موقت'' when 3 then ''عبور موقت'' else ''---'' end InOutWithServiceTypeName ,b.InOutWithServiceType
,a.SettlementDate,a.BuyTypeID,isnull(BuyTypeName,'''') BuyTypeName, b.SerialNo,b.DocDate,pub.funGetGoodsName(b.GoodsID,'+str(@LangID)+') AS GoodsName 
 ,ExtraField2 ,RolQty ,SubUnitQuantity ,pub.GetCodeName(b.AcntCode, '+str(@LangID)+') AS AcntName 
 ,OrderDate 
 ,cast ( isnull(
 (select sum(SubUnitQuantity) as SubUnitQuantity
 from inv.tblStorageDocsDtl d where ProcessID=55 and BaseProcessID=160 
 and  pub.funIDNOFSRow(d.BaseProcessID,d.BaseProcessNo,d.BaseFiscalYear,d.BaseSerialNo,d.BaseDocRowNo)
	 =pub.funIDNOFSRow(b.ProcessID,b.ProcessNo,b.FiscalYear,b.SerialNo,b.DocRowNo)
   ),0) as Float)  SubUnitQuantity2
    ,isnull(pub.GetStoreName(StoreID,'+str(@LangID)+') ,'''') StoreName
  ,GoodsWidth  ,GoodsHeight  ,b.ProcessID,b.ProcessNo,b.FiscalYear,DocRowNo
,''پیش خرید'' OrderName
,pub.funGetGoodsName(SubString(b.GoodsID,1,'+ str(@GoodsGroupLayer)+'),'+str(@LangID)+') AS GroupGoodsName
,ExtraField1,b.GoodsQuantity * b.GoodsPrice Price
,isnull(
 (select  top 1 SerialNo
 from inv.tblStorageDocsDtl d where ProcessID=55 and BaseProcessID=160 
 and
pub.funIDNOFSRow(d.BaseProcessID,d.BaseProcessNo,d.BaseFiscalYear,d.BaseSerialNo,d.BaseDocRowNo)
	 =pub.funIDNOFSRow(b.ProcessID,b.ProcessNo,b.FiscalYear,b.SerialNo,b.DocRowNo)
) ,0)  SerialNo2

 from   
 cmr.tblOrderHdr a inner join   cmr.tblOrderDtl b  on a.ProcessID=b.ProcessID and  a.ProcessNo=b.ProcessNo and  a.FiscalYear=b.FiscalYear and  a.SerialNo=b.SerialNo
 --cmr.tblOrderDtl b 
 left join inv.tblGoods c
on substring(b.GoodsID,'+str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID
Left join inv.tblBuyTypeDtl t on a.BuyTypeID=t.BuyTypeID and t.LanguageID='+str(@LangID)+'
'
set @StrSelect+= ' ) a where 1=1 ' +@StrWhere


if @FilterType=2
set @StrSelect+= ' and pub.funIDNOFSRow(ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo)
not in (select pub.funIDNOFSRow(BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo)
 from inv.tblStorageDocsDtl where ProcessID=55 and BaseProcessID=160)'


if @FilterType=3
set @StrSelect+= ' and  pub.funIDNOFSRow(ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo)
 in (select   pub.funIDNOFSRow(BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo)
 from inv.tblStorageDocsDtl where ProcessID=55 and BaseProcessID=160 and DocStep=1)'


if @HdrType=2
set @StrSelect+= ' and SubUnitQuantity2>=SubUnitQuantity'


if @HdrType=3
set @StrSelect+= ' and  SubUnitQuantity2<SubUnitQuantity'

if @FilterType=0
begin

	Select 1 Visible,200 ColSize,'نام               مشتری' ColName into #tblRows
	
	Delete from #tblRows
	
	insert into   #tblRows select  1,60,'colSerialNo'
	insert into   #tblRows select  1,85,'colDocDate'
	insert into   #tblRows select  1,150,'colGoodsName'
	insert into   #tblRows select  1,60,'colExtraField2'
	insert into   #tblRows select  1,60,'colRolQty'
	insert into   #tblRows select  1,60,'colSubUnitQuantity'
	insert into   #tblRows select  1,150,'colAcntName'
	insert into   #tblRows select  1,85,'colOrderDate'
	insert into   #tblRows select  1,60,'colSubUnitQuantity2'
	insert into   #tblRows select  1,120,'colStoreName'
	insert into   #tblRows select  1,60,'colQty'
	insert into   #tblRows select  1,60,'colSerialNo2'
	insert into   #tblRows select  1,60,'colBuyTypeName'
	insert into   #tblRows select  1,85,'colSettlementDate'
	insert into   #tblRows select  1,85,'colInOutWithServiceType'
 																								
 
	set @StrSelect= ' select * from #tblRows'
end

print @StrSelect
EXECUTE sp_executesql @StrSelect



end

GO
