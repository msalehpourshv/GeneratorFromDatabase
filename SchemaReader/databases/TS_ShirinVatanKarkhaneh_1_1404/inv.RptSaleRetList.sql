USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari	
-- Create date   : 1398/05/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش فروش
-- ==============================================
Create PROCEDURE inv.RptSaleRetList
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111' ,-- bit array	
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS
---- Declarations ---------------
Declare @StrSelect		NVarChar(max);
Declare @StrFrom		NVarChar(max);
Declare @StrWhereIN		NVarChar(max);
Declare @StrWhereD		NVarChar(max);
Declare @StrTaxTollDtl	NVarChar(max);
Declare @StrTaxTollHdr	NVarChar(max);
Declare @ProcessID		Varchar(20) 
Declare @ProcessNo		Varchar(20) 
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;
Declare @ProcessIDSale	int;
Declare @ProcessIDRet1	int;
Declare @ProcessIDRet2	int;
Declare @StoreID		varchar(20)
Declare @StoreName		nvarchar(200)
Declare @GoodsID		varchar(20)
Declare @Columns		varchar(max)
Declare @Columns2		varchar(max)
Declare @ColumnsSum		varchar(max)
DECLARE	@Round			Int;
DECLARE	@CallType		Int;
DECLARE	@UnitType		Int;
Declare @Compagin		VarChar(100);
DECLARE	@ShowFullName	bit;

SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);
	----------------------------------------------------
declare @Name			varchar(2000);
declare @Group1			varchar(200);
declare @Group2			varchar(200);
declare @G1				int;
declare @G2				int;
declare @Cnt			int;
declare @AcntPartNo		int;
declare @GoodsAndReward int;
declare @GoodsGroup		int,
	@SelectedStore		Int = 0, 
	@SelectedGoods		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0
	
DECLARE	@TaxToll		bit;
declare @StartLayer2	int;
declare @LenLayer2		int;
declare @StartLayer3	int;
declare @LenLayer3		int;
declare @StartLayer4	int;
declare @LenLayer4		int;

select @StartLayer2 =acc.funGetAcntLayerStartandLen(2,1 )
select @LenLayer2=acc.funGetAcntLayerStartandLen(2,2 )
select @StartLayer3 =acc.funGetAcntLayerStartandLen(3,1 )
select @LenLayer3= acc.funGetAcntLayerStartandLen(3,2 )
select @StartLayer4 =acc.funGetAcntLayerStartandLen(4,1 )
select @LenLayer4 =acc.funGetAcntLayerStartandLen(4,2 )

SET @G1						= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @G2						= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @Cnt					= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
SET @ProcessID				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
SET @ProcessNo				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
SET @GoodsGroup				= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
SET @StrWhereIN				= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
SET @CallType				= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
SET @GoodsAndReward			= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
SET @ProcessIDSale			= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
SET @ProcessIDRet1			= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
SET @ProcessIDRet2			= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
SET @TaxToll				= LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
Set @UnitType				= LTrim(pub.funSplitString(@ExtraParams, '@', 14));
Set @ShowFullName			= LTrim(pub.funSplitString(@ExtraParams, '@', 15));

Update inv.tblStorageDocsDtl
set LocationIDDtl =LocationID
from inv.tblStorageDocsDtl a
inner join inv.tblStorageDocsHdr b
on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and 
   a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
where  a.ProcessID in (90,100)  and LocationIDDtl <> LocationID

--select @StrWhereIN,@ExtraParams
IF @Cnt=0 
	SET @Cnt = 5000

select @AcntPartNo=[acc].[FunGetAcntInfoForRemain](1)

if @G1=1	begin
    Set @Group1='D.GoodsID'
	if @GoodsGroup>0 
	Set @Group1=' SUBSTRING(D.GoodsID,1,'+str(@GoodsGroup )+') '
	  end
if @G2=1  
begin
Set @Group2='D.GoodsID'
	if @GoodsGroup>0 
		Set @Group2=' SUBSTRING(D.GoodsID,1,'+str(@GoodsGroup )+') '
	set @Name =' pub.funGetGoodsName (Name1,'+ @LangID +')  '
end 


if @G1=2	 Set @Group1='AcntCode'
if @G2=2 
begin
	Set @Group2='REPLACE(AcntCode,'' '','' '' )'
	if @ShowFullName='True'
		set @Name =' pub.GetCodeName (Name1,1)  '
	else
		set @Name =' acc.funPartAcntName (Name1,'+ str(@AcntPartNo) +')  '
end  

if @G1=3  Set @Group1='substring(DocDate,9,2)'
if @G2=3
begin
	Set @Group2='substring(DocDate,9,2)'
	set @Name =' Name1  '
end  


if @G1=4  Set @Group1='substring(DocDate,6,2)'
if @G2=4
begin
	Set @Group2='substring(DocDate,6,2)'
	set @Name ='case Name1  when ''01'' then ''فروردین''  when ''02'' then ''اردیبهشت''  when ''03'' then ''خرداد''  when ''04'' then ''تیر''  when ''05'' then ''مرداد''  when ''06'' then ''شهریور''  
			when ''07'' then ''مهر''  when ''08'' then ''آبان''  when ''09'' then ''آذر''  when ''10'' then ''دی''  when ''11'' then ''بهمن'' else ''اسفند'' end ' 
end  

if @G1=5  Set @Group1='DocDate'
if @G2=5
begin
	Set @Group2='DocDate'
	set @Name =' Name1'	
end  


if @G1=6  Set @Group1='StoreID'
if @G2=6
begin
	Set @Group2='StoreID'
	set @Name =' [pub].[GetStoreName](Name1,'+ @LangID +') '
end  


if @G1=7	 Set @Group1='VisitorAcntCode'
if @G2=7 
begin
	Set @Group2='REPLACE(VisitorAcntCode,'' '','' '' )'
	if @ShowFullName='True'
		set @Name =' pub.GetCodeName (Name1,1)  '
	else
		set @Name =' acc.funPartAcntName (Name1,'+ str(@AcntPartNo) +')  '
end  


if @G1=8	 Set @Group1='SaleTypeID'
if @G2=8 
begin
	Set @Group2='SaleTypeID'
	set @Name =' [pub].[funGetSaleTypesName] (Name1,'+ @LangID +')  '
end  


if @G1=9	 Set @Group1='SerialNo'
if @G2=9 
begin
	Set @Group2='SerialNo'
	set @Name =' Name1 '
end  

if @G1=10	 Set @Group1='LocationIDDtl'
if @G2=10
begin
	Set @Group2='LocationIDDtl'
	set @Name =' [pub].[funGetLocationName](Name1,'+ @LangID +')  '
end  

if @G1=11	 Set @Group1='subString(AcntCode,'+str(@StartLayer2)+','+str(@LenLayer2)+')'
if @G2=11 
begin
	Set @Group2='REPLACE(subString(AcntCode,'+str(@StartLayer2)+','+str(@LenLayer2)+'),'' '','' '' )'
	set @Name =' acc.funGetAcntName(Name1,2,1)  '
end  

if @G1=12	 Set @Group1='subString(AcntCode,'+str(@StartLayer3)+','+str(@LenLayer3)+')'
if @G2=12 
begin
	Set @Group2='REPLACE(subString(AcntCode,'+str(@StartLayer3)+','+str(@LenLayer3)+'),'' '','' '' )'
	set @Name =' acc.funGetAcntName(Name1,3,1)  '
end  


if @G1=13	 Set @Group1='subString(AcntCode,'+str(@StartLayer4)+','+str(@LenLayer4)+')'
if @G2=13 
begin
	Set @Group2='REPLACE(subString(AcntCode,'+str(@StartLayer4)+','+str(@LenLayer4)+'),'' '','' '' )'
	set @Name =' acc.funGetAcntName (Name1,4,1)  '
end  

if @G1=14  Set @Group1='CampaignID'
if @G2=14
begin
	Set @Group2='CampaignID'
	set @Name =' acc.funGetCampaignName(Name1,'+ @LangID +') '
end  
--select @G1,@G2,@GoodsGroup,@Group1,@Group2

set @Columns =''
set @Columns2 =''
set @ColumnsSum =''

set @StrWhereD=' AND ( 1=0 '
  IF (@ProcessIDSale =1)	
		SET @StrWhereD = @StrWhereD + ' or  D.ProcessID=90  '
  IF (@ProcessIDRet1 =1)	
		SET @StrWhereD = @StrWhereD + ' or  (D.ProcessID=100 and D.BaseProcessID=0 )'
  IF (@ProcessIDRet2 =1)	
		SET @StrWhereD = @StrWhereD + ' or  (D.ProcessID=100 and D.BaseProcessID=90 )'
SET @StrWhereD = @StrWhereD + ' )  '
	
  IF (@ProcessNo Is not Null)	
		SET @StrWhereD = @StrWhereD + ' AND (D.ProcessNo IN(' + @ProcessNo + ')) '
	
  If (@StrWhereIN Is Not Null  and  LTRIM(rtrim(@StrWhereIN ))<>'')
		SET @StrWhereD = @StrWhereD + @StrWhereIN

  IF @GoodsAndReward =2
		SET @StrWhereD = @StrWhereD + ' AND (IsReward =0 and IsReward0=0) '
  IF @GoodsAndReward =3 
		SET @StrWhereD = @StrWhereD + ' AND (IsReward =1 or IsReward0=1) '

--select @StrWhereD

	set @Round = 1;

	select @Round = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'


		BEGIN TRY
			DROP TABLE #tblTemp
		END TRY
		BEGIN CATCH
		END CATCH
	
	CREATE TABLE #tblTemp
	(		StoreID VarChar(20) ,
			StoreName nVarChar(200)
	)

	if   @G1=14	
	set @StrSelect='   insert into #tblTemp select distinct top '+ str(@Cnt) +' 
				acc.funGetCampaignIDAcnt(D.AcntCode,'+str(@AcntPartNo)+')   '+ @Group1 +' , acc.funGetCampaignIDAcnt(D.AcntCode,'+str(@AcntPartNo)+')  '+ @Group1 +' 
			From inv.tblStorageDocsDtl D where 1=1 '+@StrWhereD
	else
	set @StrSelect='   insert into #tblTemp select distinct top '+ str(@Cnt) +'   '+ @Group1 +' ,'+ @Group1 +' 
			From inv.tblStorageDocsDtl D where  '+ @Group1 +'<>''''	and  1=1 '+@StrWhereD

	print @StrSelect
	
	Exec sp_executesql @StrSelect; 

	if   @G1=14	
		delete from #tblTemp where ISnull(StoreID,'') =''

IF (SELECT COUNT(*) from #tblTemp)>4096
	BEGIN
		Raiserror (N'تعداد ستون ها بیشتر از 4096 است و گزارش نمیتواند پاسخگو باشد',16,1)
		Return
	END
-- select StoreID from #tblStores 
 --select StoreID,StoreName from #tblTemp 

 
Declare	curStoreID CURSOR For 
 select StoreID,StoreName from #tblTemp 

Open  curStoreID; 

Fetch NEXT From curStoreID Into @StoreID,@StoreName

While (@@Fetch_Status = 0)
	BEGIN
	set @Columns=@Columns+',['+@StoreID+']'
	set @ColumnsSum=@ColumnsSum+'+isnull(['+@StoreID+'],0)'
	set @Columns2=@Columns2+', cast (isnull(['+@StoreID+'],0) as float) as ['+ @StoreName +'] '
	--set @Columns2=@Columns2+', ['+@StoreID+'] '
	
	Fetch NEXT From curStoreID Into @StoreID,@StoreName
	END

Close curStoreID;  
Deallocate curStoreID; 

--Select @Columns,@Columns2


if @Columns=''
return 


	if LEN(@Columns)>1
		set  @Columns= SUBSTRING(@Columns,2,LEN(@Columns)-1)
	if LEN(@ColumnsSum)>1
	begin
		set  @ColumnsSum= SUBSTRING(@ColumnsSum,2,LEN(@ColumnsSum)-1)
		set @ColumnsSum= ' cast ('+@ColumnsSum+' as float) '
	end

if LEN(@Columns)>1
set  @Columns2= SUBSTRING(@Columns2,2,LEN(@Columns2)-1)

		
		--select @Columns2
	--	select @StrWhereD
	if @TaxToll ='True'
		set @StrTaxTollDtl='+TaxOverWorthCostDtl+TollOverWorthCostDtl'
	else
		set @StrTaxTollDtl=''	

	if @TaxToll ='True'
		set @StrTaxTollHdr='+TaxOverWorthCost+TollOverWorthCost'
	else
		set @StrTaxTollHdr=''		

	select H.AcntCode CampaignID,
	H.Price,H.Amount,
	GoodsPrice DiscountAll,
	GoodsPrice GoodsPriceHdr,
	GoodsPrice GoodsPriceAfterSaleDiscount,
	AfterSaleDiscount, TransportationCost,
	Discount+Discount2+Discount3 DiscountHdr,
	ISNULL(  GoodsPrice*GoodsQuantity- DiscountDtl+TaxOverWorthCostDtl+TollOverWorthCostDtl , 0) as GoodsPriceDtl,
	SUM(GoodsPrice*GoodsQuantity- DiscountDtl+TaxOverWorthCostDtl+TollOverWorthCostDtl)over (partition by D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo) Balance,
	D.*  into  #RptTable FROM	inv.tblStorageDocsDtl D 
		INNER JOIN inv.tblStorageDocsHdr H
		ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
where   1=0 
		
		--where    (D.ProcessID IN(90))  AND (D.ProcessNo IN(1,2,3,4,10)) AND  D.DocDate >= '1398/04/15' AND  D.DocDate <= '1398/04/15'
		--select * from  #RptTable		
		--return 
------------------------------------------------------------------------------------------------
		BEGIN TRY
			DROP TABLE #tblAcntCode
			DROP TABLE #tblStoreID
			DROP TABLE #tblVisitorAcntCode
			DROP TABLE #tblGoods
		END TRY
		BEGIN CATCH
		END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 CREATE TABLE #tblGoods
	(
	GoodsID 			Varchar(20)collate arabic_cs_as null
	)
	CREATE TABLE #tblStoreID
	(
	StoreID 			Varchar(20)collate arabic_cs_as null
	)
	 CREATE TABLE #tblVisitorAcntCode
	(
	VisitorAcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 Insert into  #tblVisitorAcntCode (VisitorAcntCode) SELECT  Distinct VisitorAcntCode	FROM         inv.tblStorageDocsHdr
	 Insert into  #tblAcntCode (AcntCode) SELECT  Distinct AcntCode	FROM         inv.tblStorageDocsHdr
	 Insert into  #tblGoods (GoodsID) SELECT  Distinct GoodsID	FROM         inv.tblStorageDocsDtl	 	
	 Insert into  #tblStoreID (StoreID) SELECT  Distinct StoreID	FROM         inv.tblStorageDocsHdr
	if @UserIsAdmin=0
	begin
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblVisitorAcntCode', 'VisitorAcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblStoreID', 'StoreID', 'inv.tblStores', @UserID;
		 exec pub.SpFilterByPermission2 '#tblGoods', 'GoodsID', 'inv.tblGoods', @UserID;
	END
	-----------------------------------------------------------------
	--SET @StrWhereH = '  and  acc.funAllowAcntCode('+ltrim(str(@UserID))+','+ ltrim(str(@UserIsAdmin))+',	H.AcntCode,'+ltrim(str(@PartNumber))+') =1 '
	SET @StrWhereD =  @StrWhereD + '  and   H.AcntCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) '
	SET @StrWhereD =  @StrWhereD + '  and   H.VisitorAcntCode in (SELECT   VisitorAcntCode	FROM  #tblVisitorAcntCode    ) '
	SET @StrWhereD =  @StrWhereD + '  and   H.StoreID in (SELECT   StoreID	FROM  #tblStoreID    ) '
	SET @StrWhereD =  @StrWhereD + '  and   D.GoodsID in (SELECT   GoodsID	FROM  #tblGoods    ) '
------------------------------------------------------------------------------------------------
	Set @Compagin=''''''
	if @G1=14 or @G2=14
		Set @Compagin=' acc.funGetCampaignIDAcnt(H.AcntCode,'+str(@AcntPartNo)+') '

	SET @StrSelect = ' insert into #RptTable
		select  '+ @Compagin+' CampaignID,
			H.Price,H.Amount,
			0 as DiscountAll,
			0 as GoodsPriceHdr,
			0 as GoodsPriceAfterSaleDiscount,
			AfterSaleDiscount, TransportationCost,
			Discount+Discount2+Discount3 DiscountHdr,		
			ISNULL(  GoodsPrice*GoodsQuantity- DiscountDtl'+@StrTaxTollDtl+', 0) as GoodsPriceDtl, 
			Price-TotalLineDiscount '+@StrTaxTollHdr+'  Balance,
			D.*  
			FROM	inv.tblStorageDocsDtl D 
		INNER JOIN inv.tblStorageDocsHdr H
		ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
		where   1=1 '+@StrWhereD+''
	print @StrSelect
	Exec sp_executesql @StrSelect; 
	--select @StrWhereD
 
Update  #RptTable
set GoodsPriceHdr=GoodsPriceDtl-- ISNULL(GoodsPriceDtl -(GoodsPriceDtl*DiscountHdr/Balance), 0) 

--select * from #RptTable where Price<=0

Update  #RptTable
set GoodsPriceAfterSaleDiscount= ISNULL(GoodsPriceHdr - GoodsPriceHdr *(DiscountHdr+AfterSaleDiscount)/Balance , 0) 
where Balance>0
--TransportationCost  برای همخوانی با گزارش سالیانه حذف شد
--set GoodsPriceAfterSaleDiscount= ISNULL(GoodsPriceHdr - GoodsPriceHdr *(TransportationCost+DiscountHdr+AfterSaleDiscount)/Price , 0) 

--select * into RptTable1  from #RptTable 

declare @StrType as varchar(max)
if @UnitType = 1
begin
	if @CallType=1
		set @StrType =' sum( GoodsPriceAfterSaleDiscount*EnterKind*-1 )'
	else
		set @StrType =' sum( GoodsQuantity*EnterKind*-1)'
	end
if @UnitType = 2
begin

	if @CallType=1
		set @StrType =' sum( GoodsPriceAfterSaleDiscount*EnterKind*-1 )'
	else
		--set @StrType =' Case When GoodsQuantity<>SubUnitQuantity then sum( SubUnitQuantity*EnterKind*-1)*UnitValue / MainUnitValue else sum( GoodsQuantity*EnterKind*-1)*UnitValue / MainUnitValue end'
		set @StrType =' Cast(SUM(CASE WHEN sud.SubUnitID IS NULL THEN D.GoodsQuantity 
									  WHEN sud.SubUnitID<>D.SubUnitID THEN Cast(D.GoodsQuantity * sud.UnitValue / sud.MainUnitValue as float) 
									  ELSE SubUnitQuantity 
									  END * EnterKind * -1) as float)'
end
	
--	select   * into RptTable from  #RptTable
if @UnitType = 2 and @CallType=2
begin
SET @StrSelect = N'
select Name1 [کد ], '+ @Name +' [نام],'+@Columns2+' ,'+@ColumnsSum+' [مجموع]   
   from
		(select Name1  ,'+@Columns+' from
		( 
			select Name1 , Name2 ,  Price
			from
			(
				select '+@Group2+' Name1 , '+@Group1+' Name2 , '+ @StrType +'  Price  
				from  #RptTable D -- inv.tblStorageDocsDtl
				left join inv.tblSubUnitsDtl sud on sud.GoodsID = D.GoodsID and ShowInInvoice = 1
				where   '+ @Group1 +'<>''''	and  1=1  
				GROUP BY  '+@Group2+', '+@Group1+' 
			) T
		) 
		P	PIVOT 
			(
				Sum(P.Price)
				for P.Name2 In ('+@Columns+')
			) AS PVT 
)a	'
--if @NotShowZeroQty=1
SET @StrSelect = @StrSelect + ' where '+@ColumnsSum+'<>0'
end
else
begin
SET @StrSelect = N'
select Name1 [کد ], '+ @Name +' [نام],'+@Columns2+' ,'+@ColumnsSum+' [مجموع]   
   from
		(select Name1  ,'+@Columns+' from
		( 
			select Name1 , Name2 ,  Price
			from
			(
				select '+@Group2+' Name1 , '+@Group1+' Name2 , '+ @StrType +'  Price  
				from  #RptTable D -- inv.tblStorageDocsDtl 
				where   '+ @Group1 +'<>''''	and  1=1  
				GROUP BY  '+@Group2+', '+@Group1+' 
			) T
		) 
		P	PIVOT 
			(
				Sum(P.Price)
				for P.Name2 In ('+@Columns+')
			) AS PVT 
)a	'
--if @NotShowZeroQty=1
SET @StrSelect = @StrSelect + ' where '+@ColumnsSum+'<>0'
end

	print @StrSelect
	
	Exec sp_executesql @StrSelect;
GO
