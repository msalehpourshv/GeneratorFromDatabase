USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1397/02/22
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ----------------------------------------------
-- تایید خروج کالای فروش رفته
-- ==============================================

Create PROCEDURE [sal].[SpAllowExitSaleGoods]
	@ExtraParams		NVarChar(Max) 
	WITH ENCRYPTION
AS

BEGIN

DECLARE @StrSelect NVarChar(4000);
DECLARE @StrWhere  NVarChar(4000);
	
DECLARE	@LangID			 Int;
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

select @PartNumber=acc.FunGetAcntInfoForRemain(1),@StartLayer=acc.FunGetAcntInfoForRemain(2),@LenLayer=acc.FunGetAcntInfoForRemain(3)

SET @LangID			 = pub.funSplitString(@ExtraParams, '@', 1);
SET @FilterType		 = pub.funSplitString(@ExtraParams, '@', 2);
SET @StrWhere		 = pub.funSplitString(@ExtraParams, '@', 3);
SET @HdrType		 = pub.funSplitString(@ExtraParams, '@', 4);
SET @ProcessID		 = pub.funSplitString(@ExtraParams, '@', 5);

select @PartNumberGoods=SettingValue from pub.tblSettings where SettingKey='UnitPart'

--Declare @PartNumberGoods int=2
--select * from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=@PartNumberGoods
select @StartLayerGoods=isnull(sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)+1 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber<@PartNumberGoods
select @LenLayerGoods=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=@PartNumberGoods


--select 

set @StrSelect=' select * from (
select a.*,pub.funGetGoodsName(a.GoodsID,'+str(@LangID)+') AS GoodsName 
,ISNULL(pub.GetGoodsNamePart(GoodsID3,'+str(@PartNumberEnd)+','+str(@LangID)+'),'''') AS ServiceName
,acc.funGetAcntName(substring(AcntCode,'+str(@StartLayer)+','+str(@LenLayer)+'),'+str(@PartNumber)+','+str(@LangID)+') AcntName
,pub.GetStoreName(StoreID,'+str(@LangID)+') StoreName
,isnull((select SerialNo from inv.tblStorageDocsDtl b where 
ltrim(str(a.ProcessID))+''@''+	ltrim(str(a.ProcessNo))	+''@''+	ltrim(str(a.FiscalYear))	+''@''+	ltrim(str(a.SerialNo))	+''@''+	ltrim(str(a.DocRowNo)) 
=ltrim(str(b.BaseProcessID))+''@''+		ltrim(str(b.BaseProcessNo))	+''@''+	ltrim(str(b.BaseFiscalYear))	 +''@''+ 	ltrim(str(b.BaseSerialNo))	+''@''+	ltrim(str(b.BaseDocRowNo)) 
 and ProcessID=93 and BaseProcessID=90),0) SerialNo2
, b.IsService
  from inv.tblStorageDocsDtl a
 inner join inv.tblGoods b on substring(a.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=b.GoodsID
  
where ProcessID=90'

if @FilterType=2
set @StrSelect+= ' and ltrim(str(ProcessID))+''@''+	ltrim(str(ProcessNo))	+''@''+	ltrim(str(FiscalYear))	+''@''+	ltrim(str(SerialNo))	+''@''+	ltrim(str(DocRowNo))
 in (select ltrim(str(BaseProcessID))+''@''+		ltrim(str(BaseProcessNo))	+''@''+	ltrim(str(BaseFiscalYear))	 +''@''+ 	ltrim(str(BaseSerialNo))	+''@''+	ltrim(str(BaseDocRowNo))
 from inv.tblStorageDocsDtl where ProcessID=93 and BaseProcessID=90)'

if @FilterType=3
set @StrSelect+= '  and ltrim(str(ProcessID))+''@''+	ltrim(str(ProcessNo))	+''@''+	ltrim(str(FiscalYear))	+''@''+	ltrim(str(SerialNo))	+''@''+	ltrim(str(DocRowNo))
not in (select ltrim(str(BaseProcessID))+''@''+		ltrim(str(BaseProcessNo))	+''@''+	ltrim(str(BaseFiscalYear))	 +''@''+ 	ltrim(str(BaseSerialNo))	+''@''+	ltrim(str(BaseDocRowNo))
 from inv.tblStorageDocsDtl where ProcessID=93 and BaseProcessID=90)'


if @FilterType=4
set @StrSelect+= ' and  SubUnitQuantity<>0'


if @FilterType=5
set @StrSelect+= ' and  SubUnitQuantity=0'



if @FilterType=6
set @StrSelect+= ' and ltrim(str(ProcessID))+''@''+	ltrim(str(ProcessNo))	+''@''+	ltrim(str(FiscalYear))	+''@''+	ltrim(str(SerialNo))	+''@''+	ltrim(str(DocRowNo))
not in (select ltrim(str(BaseProcessID))+''@''+		ltrim(str(BaseProcessNo))	+''@''+	ltrim(str(BaseFiscalYear))	 +''@''+ 	ltrim(str(BaseSerialNo))	+''@''+	ltrim(str(BaseDocRowNo))
 from inv.tblStorageDocsDtl where ProcessID=93 and BaseProcessID=90)
 and  SubUnitQuantity<>0 '


set @StrSelect+= ' ) a where 1=1 ' +@StrWhere


if @HdrType=1
set @StrSelect = ' Select  Distinct ProcessNo,ProcessID,FiscalYear,SerialNo,BaseProcessNo,BaseProcessID,BaseFiscalYear,BaseSerialNo,DocDate,AcntCode,AcntName,StoreID,StoreName  
,Case when BaseSerialNo=0 then ''بدون مرجع'' else Case when BaseProcessID=180 then ''طبق سفارش فروش''  else ''طبق پیش فاکتور'' end end BaseType

From ( '+@StrSelect+') a '

if @HdrType=2
begin
if @ProcessID=240
set @StrSelect= '
select  ProcessID,ProcessNo,FiscalYear,SerialNo,StoreID,AcntCode ,pub.GetStoreName(StoreID,'+str(@LangID)+') StoreName ,acc.funGetAcntName(substring(AcntCode,'+str(@StartLayer)+','+str(@LenLayer)+'),'+str(@PartNumber)+','+str(@LangID)+') AcntName from    inv.tblPreSaleHdr 
where    ConfirmState=1 and  ltrim(str(ProcessID))+''@''+		ltrim(str(ProcessNo))	+''@''+	ltrim(str(FiscalYear))	 +''@''+ 	ltrim(str(SerialNo))
not in(  select ltrim(str(BaseProcessID))+''@''+		ltrim(str(BaseProcessNo))	+''@''+	ltrim(str(BaseFiscalYear))	 +''@''+ 	ltrim(str(BaseSerialNo)) from    inv.tblStorageDocsHdr)
' +@StrWhere


if @ProcessID=180
set @StrSelect= '
select  Distinct ProcessID,ProcessNo,FiscalYear,SerialNo,StoreID,AcntCode ,pub.GetStoreName(StoreID,'+str(@LangID)+') StoreName ,acc.funGetAcntName(substring(AcntCode,'+str(@StartLayer)+','+str(@LenLayer)+'),'+str(@PartNumber)+','+str(@LangID)+') AcntName from    sal.tblSaleOrderDtl
where ltrim(str(ProcessID))+''@''+		ltrim(str(ProcessNo))	+''@''+	ltrim(str(FiscalYear))	 +''@''+ 	ltrim(str(SerialNo))+''@''+	ltrim(str(DocRowNo))
not in(  select ltrim(str(BaseProcessID))+''@''+		ltrim(str(BaseProcessNo))	+''@''+	ltrim(str(BaseFiscalYear))	 +''@''+ 	ltrim(str(BaseSerialNo))+''@''+	ltrim(str(BaseDocRowNo)) from    inv.tblStorageDocsDtl)
' +@StrWhere



 end 


print @StrSelect
EXECUTE sp_executesql @StrSelect



end

GO
