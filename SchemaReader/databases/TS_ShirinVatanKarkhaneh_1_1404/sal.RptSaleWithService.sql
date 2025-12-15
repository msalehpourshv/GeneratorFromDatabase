USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation date : 1397/03/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش کلی فروش بهمن فولاد
-- ==============================================
Create PROCEDURE sal.RptSaleWithService
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111', -- bit array	
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS
BEGIN

	DECLARE @StrSelect	NVarChar(Max);
	DECLARE @StrWhere	NVarChar(Max);
	DECLARE	@PartNumberEnd			 Int;
	Declare @FilterText  nvarchar(1000);
	DECLARE	@CalcType		Int;

	DECLARE	@LangID		Char(1);
	DECLARE	@SessionNo	Int; 
	DECLARE	@ReportID	Int;
	DECLARE	@UserID		Int;
	DECLARE	@UserIsAdmin bit;
	DECLARE	@PartNumber			 Int;
	DECLARE	@StartLayer			 Int;
	DECLARE	@LenLayer			 Int;
	DECLARE	@PartNumberGoods	 Int;
	DECLARE	@StartLayerGoods	 Int;
	DECLARE	@LenLayerGoods		 Int;
	DECLARE	@GoodsGroupLayer	 Int;



	DECLARE		@AcntName		NVarChar(1000);
	DECLARE		@DocDate		Char(10);
	DECLARE		@DocDate2		Char(10);
	DECLARE		@GoodsGroup		NVarChar(1000);
	DECLARE		@GoodsHeight	Float;
	DECLARE		@GoodsHeight2	Float;
	DECLARE		@GoodsName		NVarChar(1000);
	DECLARE		@GoodsName2		NVarChar(1000);
	DECLARE		@Ral			NVarChar(1000);
	DECLARE		@SaleExport		NVarChar(1000);
	DECLARE		@Shamel			NVarChar(1000);
	DECLARE		@Shamel2		NVarChar(1000);
	DECLARE		@Shobe			NVarChar(1000);
	DECLARE		@StoreName		NVarChar(1000);
	DECLARE		@User			NVarChar(1000);
	DECLARE		@VisitorName	NVarChar(1000);
	DECLARE		@Width			Float;
	DECLARE		@Width2			Float;
	DECLARE		@chk1			bit;
	DECLARE		@chk2			bit;
	DECLARE		@chk3			bit;
	DECLARE		@chk4			bit;
	DECLARE		@Tax			int;
	DECLARE		@GoodsType		int;
	DECLARE		@InOutWSType	int;
	DECLARE		@SaleExportType	int;
	DECLARE		@SaleState		int;
	DECLARE		@Sort			int;
	DECLARE		@Tolerance		Float;
	DECLARE		@Tolerance2 	Float;


select @PartNumber=acc.FunGetAcntInfoForRemain(1),@StartLayer=acc.FunGetAcntInfoForRemain(2),@LenLayer=acc.FunGetAcntInfoForRemain(3)

select @PartNumberGoods=SettingValue from pub.tblSettings where SettingKey='UnitPart'

select @StartLayerGoods=isnull(sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)+1 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber<@PartNumberGoods
select @LenLayerGoods=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=@PartNumberGoods
	select @PartNumberEnd=max(PartNumber) from inv.tblGoods

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


	SET @CalcType		    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @AcntName		    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @DocDate		    = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @DocDate2		    = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @GoodsGroup		    = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	SET @GoodsHeight	    = LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
	SET @GoodsHeight2	    = LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
	SET @GoodsName		    = LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
	SET @GoodsName2		    = LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
	SET @Ral			    = LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
	SET @SaleExport		    = LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
	SET @Shamel			    = LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
	SET @Shamel2		    = LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
	SET @Shobe			    = LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 
	SET @StoreName		    = LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 
	SET @User			    = LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 
	SET @VisitorName	    = LTrim(pub.funSplitString(@ExtraParams, '@', 17)); 
	SET @Width			    = LTrim(pub.funSplitString(@ExtraParams, '@', 18)); 
	SET @Width2			    = LTrim(pub.funSplitString(@ExtraParams, '@', 19)); 
	SET @chk1			    = LTrim(pub.funSplitString(@ExtraParams, '@', 20)); 
	SET @chk2			    = LTrim(pub.funSplitString(@ExtraParams, '@', 21)); 
	SET @chk3			    = LTrim(pub.funSplitString(@ExtraParams, '@', 22)); 
	SET @chk4			    = LTrim(pub.funSplitString(@ExtraParams, '@', 23)); 
	SET @Tax			    = LTrim(pub.funSplitString(@ExtraParams, '@', 24)); 
	SET @GoodsType		    = LTrim(pub.funSplitString(@ExtraParams, '@', 25)); 
	SET @InOutWSType	    = LTrim(pub.funSplitString(@ExtraParams, '@', 26)); 
	SET @SaleExportType	    = LTrim(pub.funSplitString(@ExtraParams, '@', 27)); 
	SET @SaleState		    = LTrim(pub.funSplitString(@ExtraParams, '@', 28)); 
	SET @Sort			    = LTrim(pub.funSplitString(@ExtraParams, '@', 29)); 
	SET @Tolerance			    = LTrim(pub.funSplitString(@ExtraParams, '@', 30)); 
	SET @Tolerance2			    = LTrim(pub.funSplitString(@ExtraParams, '@', 31)); 

            
	SET @LangID				 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);




set @StrWhere=''

if @AcntName<>'' 
	set @StrWhere=@StrWhere+' and  acc.funGetAcntName(substring(b.AcntCode,'+str(@StartLayer)+','+str(@LenLayer)+'),'+str(@PartNumber)+','+str(@LangID)+') Like ''%'+ @AcntName+'%'''
if @DocDate<>'' 
	set @StrWhere=@StrWhere+' and  b.DocDate >='''+ @DocDate+''''
if @DocDate2<>'' 	
	set @StrWhere=@StrWhere+' and b.DocDate <='''+ @DocDate2+''''
if @GoodsHeight<>'' 
	set @StrWhere=@StrWhere+' and  GoodsHeight >='''+ @GoodsHeight+''''
if @GoodsHeight2<>'' 	
	set @StrWhere=@StrWhere+' and GoodsHeight <='''+ @GoodsHeight2+''''
if @GoodsName<>'' 	
	set @StrWhere=@StrWhere+' and pub.funGetGoodsName(substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+'),'+str(@LangID)+') Like ''%'+ @GoodsName+'%'''
if @GoodsName2<>'' 	
	set @StrWhere=@StrWhere+' and ISNULL(pub.GetGoodsNamePart(GoodsID3,'+str(@PartNumberEnd)+','+str(@LangID)+'),'''') Like ''%'+ @GoodsName2+'%'''
if @StoreName<>'' 	
	set @StrWhere=@StrWhere+' and pub.GetStoreName(b.StoreID,'+str(@LangID)+') Like ''%'+ @StoreName+'%'''
if @VisitorName<>'' 
	set @StrWhere=@StrWhere+' and  acc.funGetAcntName(substring(a.VisitorAcntCode,'+str(@PartNumber)+','+str(@LangID)+') Like ''%'+ @VisitorName+'%'''
if @Width<>'' 
	set @StrWhere=@StrWhere+' and  b.Width >='''+ @Width+''''
if @Width2<>'' 	
	set @StrWhere=@StrWhere+' and b.Width  <='''+ @Width2+''''
if @Ral<>'' and 	@Ral<>'0'
	set @StrWhere=@StrWhere+' and c.ExtraField1  ='''+ @Ral+''''
if @SaleState=2
	set @StrWhere=@StrWhere+' and a.SaleState  =1'
if @SaleState=3
	set @StrWhere=@StrWhere+' and a.SaleState  =0'
if @GoodsType=1
	set @StrWhere=@StrWhere+' and substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+') in (select GoodsID From inv.tblGoods where IsService=0)'
if @GoodsType=2
	set @StrWhere=@StrWhere+' and substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+') in (select GoodsID From inv.tblGoods where IsService=1)'
if @Tolerance>0
	set @StrWhere=@StrWhere+' and b.SubUnitQuantity-b.VirtualQuantity>='+str(@Tolerance)
if @Tolerance2>0
	set @StrWhere=@StrWhere+' and b.SubUnitQuantity-b.VirtualQuantity<='+str(@Tolerance2)
if @Tax=2
	set @StrWhere=@StrWhere+' and a.TaxOverWorthCost>0'
if @Tax=3
	set @StrWhere=@StrWhere+' and a.TaxOverWorthCost=0'
if @Shamel<>''
	set @StrWhere=@StrWhere+' and pub.funGetGoodsName(b.GoodsID,'+str(@LangID)+') Like ''%'+ @Shamel+'%'''
if @Shamel2<>''
	set @StrWhere=@StrWhere+' and pub.funGetGoodsName(b.GoodsID,'+str(@LangID)+') Like ''%'+ @Shamel2+'%'''
if @GoodsGroup<>''
	set @StrWhere=@StrWhere+' and SubString(b.GoodsID,1,'+ str(@GoodsGroupLayer)+')=  SubString('''+ @GoodsGroup+''',1,'+ str(@GoodsGroupLayer)+') '

if @InOutWSType>0
	set @StrWhere=@StrWhere+' and InOutWithServiceType=  '+ str(@InOutWSType)+' '




--TaxOverWorthCost  @Tax

set @StrSelect=' Select * from  inv.tblStorageDocsDtl '
if @CalcType=1
begin
set @StrSelect='
select a.SerialNo,a.DocDate,acc.funGetAcntName(substring(a.AcntCode,'+str(@StartLayer)+','+str(@LenLayer)+'),'+str(@PartNumber)+','+str(@LangID)+') AcntName
, pub.funGetGoodsName(substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+'),'+str(@LangID)+') AS GoodsName 
,GoodsHeight
,GoodsWidth
,cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float ) SubUnitQuantity
,b.GoodsPrice
,Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end *b.GoodsPrice Price 

,ISNULL(pub.GetGoodsNamePart(GoodsID3,'+str(@PartNumberEnd)+','+str(@LangID)+'),'''') AS GoodsName3 
,Height
,cast(SubUnitQuantity3 as float ) SubUnitQuantity3 
,cast((Width*Height*SubUnitQuantity3)  as float ) metr
,ServiceAmount
, a.SerialNo SerialNo2
,substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+') GoodsID1

,pub.GetStoreName(b.StoreID,'+str(@LangID)+') StoreName

,inv.funGetUnitName(SubUnitID,'+str(@LangID)+') AS SubUnitName, inv.funGetUnitName(SubUnitID3,'+str(@LangID)+') AS SubUnitName3
, c.IsService
  from inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID
  
where a.ProcessID=90' +@StrWhere


end

if @CalcType=2
begin
set @StrSelect='
select acc.funGetAcntName(substring(a.AcntCode,'+str(@StartLayer)+','+str(@LenLayer)+'),'+str(@PartNumber)+','+str(@LangID)+') AcntName
,substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')GoodsID
, pub.funGetGoodsName(substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+'),'+str(@LangID)+') AS GoodsName 
,GoodsHeight
,GoodsWidth
,cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float  ) SubUnitQuantity
,b.GoodsPrice
,Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice Price 
,ISNULL(pub.GetGoodsNamePart(GoodsID3,'+str(@PartNumberEnd)+','+str(@LangID)+'),'''') AS GoodsName3 

,cast(SubUnitQuantity3 as float ) SubUnitQuantity3 
,cast((Width*Height*SubUnitQuantity3)  as float ) metr
,ServiceAmount
 from inv.tblStorageDocsHdr a
 inner join inv.tblStorageDocsDtl b
 on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID 
where a.ProcessID=90' +@StrWhere

end

if @CalcType=3
begin
set @StrSelect='
select  AcntName GroupName1,SubUnitQuantity, case when SubUnitQuantity=0 then 0 else  Price/ SubUnitQuantity end  GoodsPrice
, Price,SubUnitQuantity3,metr, case when metr=0 then 0 else  Price/ metr end ServiceAmount,''نام مشتری'' GroupName from(
select 
 acc.funGetAcntName(substring(a.AcntCode,'+str(@StartLayer)+','+str(@LenLayer)+'),'+str(@PartNumber)+','+str(@LangID)+') AcntName
,Sum(cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float  )) SubUnitQuantity
--,b.GoodsPrice
,Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice) Price 
,Sum(cast(SubUnitQuantity3 as float )) SubUnitQuantity3 
,Sum(cast((Width*Height*SubUnitQuantity3)  as float )) metr
--,ServiceAmount
  from inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID
where a.ProcessID=90' +@StrWhere+'
Group by substring(a.AcntCode,'+str(@StartLayer)+','+str(@LenLayer)+') )b'

end


if @CalcType=4
begin
set @StrSelect='
select  GoodsName GroupName1,SubUnitQuantity, case when SubUnitQuantity=0 then 0 else  Price/ SubUnitQuantity end  GoodsPrice
, Price,SubUnitQuantity3,metr, case when metr=0 then 0 else  Price/ metr end ServiceAmount ,''نام کالا'' GroupName from(
select 
 pub.funGetGoodsName(substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+'),'+str(@LangID)+') AS GoodsName 
,Sum(cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float  )) SubUnitQuantity
--,b.GoodsPrice
,Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice) Price 
,Sum(cast(SubUnitQuantity3 as float )) SubUnitQuantity3 
,Sum(cast((Width*Height*SubUnitQuantity3)  as float )) metr
--,ServiceAmount
  from inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID  
where a.ProcessID=90' +@StrWhere+'
Group by substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+') )b'

end

--select @GoodsGroupLayer
if @CalcType=5
begin
set @StrSelect='
select  GoodsName GroupName1,SubUnitQuantity, case when SubUnitQuantity=0 then 0 else  Price/ SubUnitQuantity end  GoodsPrice
, Price,SubUnitQuantity3,metr, case when metr=0 then 0 else  Price/ metr end ServiceAmount,''نام گروه کالا'' GroupName from(
select 
pub.funGetGoodsName(substring(b.GoodsID,1,'+ str(@GoodsGroupLayer)+'),'+str(@LangID)+') AS GoodsName 
 
,Sum(cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float  )) SubUnitQuantity
--,b.GoodsPrice
,Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice) Price 
,Sum(cast(SubUnitQuantity3 as float )) SubUnitQuantity3 
,Sum(cast((Width*Height*SubUnitQuantity3)  as float )) metr
--,ServiceAmount
  from inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID  
where a.ProcessID=90' +@StrWhere+'
Group by substring(b.GoodsID,1,'+ str(@GoodsGroupLayer)+') )b'

end


if @CalcType=6
begin
set @StrSelect='
select  StoreName GroupName1,SubUnitQuantity, case when SubUnitQuantity=0 then 0 else  Price/ SubUnitQuantity end  GoodsPrice
, Price,SubUnitQuantity3,metr, case when metr=0 then 0 else  Price/ metr end ServiceAmount ,''نام انبار'' GroupName from(
select 
pub.GetStoreName(b.StoreID,'+str(@LangID)+') StoreName
,Sum(cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float  )) SubUnitQuantity
--,b.GoodsPrice
,Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice) Price 
,Sum(cast(SubUnitQuantity3 as float )) SubUnitQuantity3 
,Sum(cast((Width*Height*SubUnitQuantity3)  as float )) metr
--,ServiceAmount
  from inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID  
where a.ProcessID=90' +@StrWhere+'
Group by b.StoreID )b'

end



if @CalcType=7
begin
set @StrSelect='
select  GoodsName GroupName1,SubUnitQuantity, case when SubUnitQuantity=0 then 0 else  Price/ SubUnitQuantity end  GoodsPrice
, Price,SubUnitQuantity3,metr, case when metr=0 then 0 else  Price/ metr end ServiceAmount,''نام کالای تولیدی'' GroupName  from(
select 
ISNULL(pub.GetGoodsNamePart(GoodsID3,'+str(@PartNumberEnd)+','+str(@LangID)+'),'''') AS GoodsName
,Sum(cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float  )) SubUnitQuantity
--,b.GoodsPrice
,Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice) Price 
,Sum(cast(SubUnitQuantity3 as float )) SubUnitQuantity3 
,Sum(cast((Width*Height*SubUnitQuantity3)  as float )) metr
--,ServiceAmount
  from inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID  
where a.ProcessID=90' +@StrWhere+'
Group by GoodsID3 )b'

end




if @CalcType=8
begin
set @StrSelect='
select  UserName,CountSerialNo,SubUnitQuantity, case when SubUnitQuantity=0 then 0 else  Price/ SubUnitQuantity end  GoodsPrice
, Price,SubUnitQuantity3,metr, case when metr=0 then 0 else  Price/ metr end ServiceAmount from(
select 
pub.GetUserName(a.SessionNo) UserName
,Count(a.SerialNo) CountSerialNo
,Sum(cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float  )) SubUnitQuantity
--,b.GoodsPrice
,Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice) Price 
,Sum(cast(SubUnitQuantity3 as float )) SubUnitQuantity3 
,Sum(cast((Width*Height*SubUnitQuantity3)  as float )) metr
--,ServiceAmount
  from inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID  
where a.ProcessID=90' +@StrWhere+'
Group by pub.GetUserName(a.SessionNo)  )b'

end



if @CalcType=9
begin
set @StrSelect='
select  ExtraField1 GroupName1,SubUnitQuantity, case when SubUnitQuantity=0 then 0 else  Price/ SubUnitQuantity end  GoodsPrice
, Price,SubUnitQuantity3,metr, case when metr=0 then 0 else  Price/ metr end ServiceAmount,''نام رال'' GroupName  from(
select 
c.ExtraField1 
,Sum(cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float  )) SubUnitQuantity
--,b.GoodsPrice
,Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice) Price 
,Sum(cast(SubUnitQuantity3 as float )) SubUnitQuantity3 
,Sum(cast((Width*Height*SubUnitQuantity3)  as float )) metr
--,ServiceAmount
  from inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID  
where a.ProcessID=90' +@StrWhere+'
Group by c.ExtraField1 )b'

end



if @CalcType=10
begin
set @StrSelect='
select  Month GroupName1,SubUnitQuantity, case when SubUnitQuantity=0 then 0 else  Price/ SubUnitQuantity end  GoodsPrice
, Price,SubUnitQuantity3,metr, case when metr=0 then 0 else  Price/ metr end ServiceAmount,''نام فصل'' GroupName  from(
select 
 Month
,Sum(cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float  )) SubUnitQuantity
--,b.GoodsPrice
,Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice) Price 
,Sum(cast(SubUnitQuantity3 as float )) SubUnitQuantity3 
,Sum(cast((Width*Height*SubUnitQuantity3)  as float )) metr
--,ServiceAmount
  from (Select Case SubString(DocDate,6,2)
 when ''01'' then ''بهار'' 
 when ''02'' then ''بهار'' 
 when ''03'' then ''بهار'' 
when  ''04'' then ''تابستان'' 
when  ''05'' then ''تابستان'' 
when  ''06'' then ''تابستان'' 
when  ''07'' then ''پاییز'' 
when  ''08'' then ''پاییز'' 
when  ''09'' then ''پاییز'' 
else ''زمستان'' end   as Month ,* from inv.tblStorageDocsHdr) a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID  
where a.ProcessID=90' +@StrWhere+'
Group by Month )b'

end



if @CalcType=11
begin
set @StrSelect='
select  Month GroupName1,SubUnitQuantity, case when SubUnitQuantity=0 then 0 else  Price/ SubUnitQuantity end  GoodsPrice
, Price,SubUnitQuantity3,metr, case when metr=0 then 0 else  Price/ metr end ServiceAmount,''نام ماه'' GroupName  from(
select 
case SubString(a.DocDate,6,2)
when ''01'' then ''فروردین''  
when ''02'' then ''اردیبهشت''  
when ''03'' then ''خرداد''  
when ''04'' then ''تیر''  
when ''05'' then ''مرداد''  
when ''06'' then ''شهریور''  
when ''07'' then ''مهر''  
when ''08'' then ''آبان''  
when ''09'' then ''آذر''  
when ''10'' then ''دی''  
when ''11'' then ''بهمن'' 
else ''اسفند'' end  
 as Month
,Sum(cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float  )) SubUnitQuantity
--,b.GoodsPrice
,Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice) Price 
,Sum(cast(SubUnitQuantity3 as float )) SubUnitQuantity3 
,Sum(cast((Width*Height*SubUnitQuantity3)  as float )) metr
--,ServiceAmount
  from inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID  
where a.ProcessID=90' +@StrWhere+'
Group by SubString(a.DocDate,6,2))b'

end



if @CalcType=12
begin

set @StrSelect=' Select 
acc.funGetAcntName(a.VisitorAcntCode,'+str(@PartNumber)+','+str(@LangID)+') VisitorName
,cast(Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*GoodsPrice) as float) Price
,Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*GoodsPrice)*a.VisitorPercent /100 VisitorPrice
,cast(Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end) as float)SubUnitQuantity,cast(a.VisitorPercent as float)VisitorPercent 
  from   inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
  where a.ProcessID=90'+@StrWhere+'
  group by a.VisitorPercent,a.VisitorAcntCode
'

end



if @CalcType=13
begin

set @StrSelect=' Select a.SerialNo,a.DocDate,
acc.funGetAcntName(a.VisitorAcntCode,'+str(@PartNumber)+','+str(@LangID)+') VisitorName
,cast(Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice) as float) Price
,Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end*b.GoodsPrice)*a.VisitorPercent /100 VisitorPrice
,cast(Sum(Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end) as float)SubUnitQuantity,cast(a.VisitorPercent as float)VisitorPercent 
,Sum(cast((Width*Height*SubUnitQuantity3)  as float )) metr
  from   inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID  
    where a.ProcessID=90'+@StrWhere+'
  group by  a.SerialNo,a.DocDate,a.VisitorPercent,a.VisitorAcntCode
'

end
if @CalcType=14
begin
set @StrSelect='
select a.SerialNo,a.DocDate,acc.funGetAcntName(substring(a.AcntCode,'+str(@StartLayer)+','+str(@LenLayer)+'),'+str(@PartNumber)+','+str(@LangID)+') AcntName
, pub.funGetGoodsName(substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+'),'+str(@LangID)+') AS GoodsName 
,GoodsHeight
,GoodsWidth
,cast (VirtualQuantity as float ) VirtualQuantity
,b.GoodsPrice

,ISNULL(pub.GetGoodsNamePart(GoodsID3,'+str(@PartNumberEnd)+','+str(@LangID)+'),'''') AS GoodsName3 
,Height
,cast(SubUnitQuantity3 as float ) SubUnitQuantity3 
,cast((Width*Height*SubUnitQuantity3)  as float ) metr
,cast (Case when SubUnitQuantity=0 then VirtualQuantity else SubUnitQuantity end  as float  ) SubUnitQuantity

,c.GoodsWeight
,b.GoodsPrice Price
  from inv.tblStorageDocsHdr a
  inner join inv.tblStorageDocsDtl b
  on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
 inner join inv.tblGoods c on substring(b.GoodsID,'+ str(@StartLayerGoods)+','+str(@LenLayerGoods)+')=c.GoodsID
  
where a.ProcessID=90' +@StrWhere


end


set @FilterText=''
if @DocDate<>'' 
	set @FilterText=@FilterText+' از تاریخ '+ @DocDate
if @DocDate2<>'' 	
	set @FilterText=@FilterText+' تا تاریخ '+ @DocDate2
if @GoodsType=1 	
	set @FilterText=@FilterText+' بدون احتساب خدمات '
if @GoodsType=2 	
	set @FilterText=@FilterText+' فقط خدمات'
if @GoodsType=3 
	set @FilterText=@FilterText+' کالا و خدمات'

set @FilterText=@FilterText+' - '

if @SaleState=1 
	set @FilterText=@FilterText+' کل فروش'
if @SaleState=2
	set @FilterText=@FilterText+' رول های فروش '
if @SaleState=3 
	set @FilterText=@FilterText+' رول های متری'
set @FilterText=@FilterText+' - '

if @SaleExportType=1 
	set @FilterText=@FilterText+' کل فروش'
if @SaleExportType=2
	set @FilterText=@FilterText+' حواله های غیر صادراتی'
if @SaleExportType=3 
	set @FilterText=@FilterText+' حواله های صادراتی'
set @FilterText=@FilterText+' - '



if @InOutWSType=0 
	set @FilterText=@FilterText+' همه حواله ها'
if @InOutWSType=1
	set @FilterText=@FilterText+' حواله های دائم'
if @InOutWSType=2 
	set @FilterText=@FilterText+' حواله های ورود موقت'
if @InOutWSType=3 
	set @FilterText=@FilterText+' حواله های عبور موقت'
set @FilterText=@FilterText+' - '
	
if @chk2=0
	set @FilterText=@FilterText+'با احتساب عوارض و مالیات'
if @chk2=1
	set @FilterText=@FilterText+'بدون احتساب عوارض و مالیات'
set @FilterText=@FilterText+' - '
	
	
if @chk3=0
	set @FilterText=@FilterText+'با احتساب کرایه حمل'
if @chk3=1
	set @FilterText=@FilterText+'بدون احتساب کرایه حمل'
	
--select 	@GoodsType,@SaleState,@SaleExportType,@Sale
	

set @StrSelect=' Select *,'''+cast(@FilterText as CHAR(200))+''' FilterText from ('+@StrSelect+') a '

if @Sort=1 
set @StrSelect= @StrSelect+' Order by  Price '
if @Sort=2
set @StrSelect= @StrSelect+' Order by  SubUnitQuantity '
if @Sort=3
set @StrSelect= @StrSelect+' Order by  metr '

PRINT @StrSelect;
EXEC sp_executesql @StrSelect;


end 
GO
