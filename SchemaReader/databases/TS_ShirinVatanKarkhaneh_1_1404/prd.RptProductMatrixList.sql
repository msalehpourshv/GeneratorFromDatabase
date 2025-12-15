USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari	
-- Create date   : 1401/08/04
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش ماتریسی تولید
-- ==============================================
Create PROCEDURE prd.RptProductMatrixList
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
DECLARE	@CurrencyType	Int;

SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);
	----------------------------------------------------
declare @Name			varchar(2000);
declare @Group1			varchar(200);
declare @Group2			varchar(200);
declare @FilterPrdCnt	varchar(200);
declare @G1				int;
declare @G2				int;
declare @Cnt			int;
declare @AcntPartNo		int;
declare @GoodsAndReward int;
declare 
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

SET @G1						= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @G2						= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @Cnt					= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
SET @StrWhereIN				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
SET @CallType				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
SET @CurrencyType			= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
--select @StrWhereIN,@ProcessID,@ProcessNo

if @ProcessNo=''
	set @ProcessNo=1
IF @Cnt=0 
	SET @Cnt = 100
SET @Cnt = isnull(@Cnt ,100)

select @AcntPartNo=[acc].[FunGetAcntInfoForRemain](1)

if @G1=1	 Set @Group1='ProductID'
if @G2=1 
begin
	Set @Group2='ProductID'
	set @Name =' pub.funGetGoodsName (Name1,'+ @LangID +')  '
	set @FilterPrdCnt='H.ProductID'
end  
if @G1=2	
    Set @Group1='GoodsID'
if @G2=2  
begin
	Set @Group2='GoodsID'
	set @Name =' pub.funGetGoodsName (Name1,'+ @LangID +')  '
	set @FilterPrdCnt='H.GoodsID'
end 
if @G1=3	 Set @Group1='D.AcntCode'
if @G2=3 
begin
	Set @Group2='D.AcntCode'
	set @Name =' acc.funPartAcntNameRecurcive (Name1,'+ str(@AcntPartNo) +')  '
	set @FilterPrdCnt='H.AcntCode'
end 
if @G1=4  Set @Group1='substring(D.DocDate,9,2)'
if @G2=4
begin
	Set @Group2='substring(D.DocDate,9,2)'
	set @Name =' Name1  '
	set @FilterPrdCnt='substring(H.DocDate,9,2)'
end  
if @G1=5  Set @Group1='substring(D.DocDate,6,2)'
if @G2=5
begin
	Set @Group2='substring(D.DocDate,6,2)'
	set @Name ='case Name1  when ''01'' then ''فروردین''  when ''02'' then ''اردیبهشت''  when ''03'' then ''خرداد''  when ''04'' then ''تیر''  when ''05'' then ''مرداد''  when ''06'' then ''شهریور''  
			when ''07'' then ''مهر''  when ''08'' then ''آبان''  when ''09'' then ''آذر''  when ''10'' then ''دی''  when ''11'' then ''بهمن'' else ''اسفند'' end ' 
	set @FilterPrdCnt='substring(H.DocDate,6,2)'
end  
if @G1=6  Set @Group1='D.DocDate'
if @G2=6
begin
	Set @Group2='D.DocDate'
	set @Name =' Name1'
	set @FilterPrdCnt='H.DocDate'
end  
if @G1=7  Set @Group1='D.StoreID'
if @G2=7
begin
	Set @Group2='D.StoreID'
	set @Name =' [pub].[GetStoreName](Name1,'+ @LangID +') '
	set @FilterPrdCnt='H.StoreID'
end  
if @G1=8	 Set @Group1='D.SerialNo'
if @G2=8 
begin
	Set @Group2='D.SerialNo'
	set @Name =' Name1 '
	set @FilterPrdCnt='H.SerialNo'
end  


set @Columns =''
set @Columns2 =''
set @ColumnsSum =''
set @StrWhereD=''
if @StrWhereIN='0'
	set @StrWhereIN=''

  If (@StrWhereIN Is Not Null  and  LTRIM(rtrim(@StrWhereIN ))<>'')
		SET @StrWhereD = @StrWhereD + @StrWhereIN

	set @Round = 1;

	select @Round = SettingValue	from pub.tblSettings	where SettingKey = 'QuantityDecimals'
	BEGIN TRY
		DROP TABLE #tblTemp
	END TRY
	BEGIN CATCH
	END CATCH
	
	CREATE TABLE #tblTemp
	(		StoreID VarChar(20) ,
			StoreName nVarChar(200)
	)
if @G1=7 and  @G2=1

	set @StrSelect='  
		insert into #tblTemp 
		select distinct top '+ str(@Cnt) +'   '+ @Group1 +' ,'+ @Group1 +' 
			FROM	inv.tblStorageDocsDtl D 
			INNER JOIN inv.tblStorageDocsHdr H
			ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo	
		where   D.ProcessID=80  and D.DocRowNo=1 '+@StrWhereD+''
	else
	
	set @StrSelect='  
		insert into #tblTemp 
		select distinct top '+ str(@Cnt) +'   '+ @Group1 +' ,'+ @Group1 +' 
			FROM	inv.tblStorageDocsDtl D 
		INNER JOIN (Select AcntCode,DocDate,StoreID,GoodsID ProductID,GoodsQuantity ProductCount,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,ProcessID,ProcessNo,FiscalYear,SerialNo From inv.tblStorageDocsDtl where ProcessID=80  and DocRowNo=1) H
			ON D.ProcessID = H.BaseProcessID And D.ProcessNo = H.BaseProcessNo And D.FiscalYear = H.BaseFiscalYear And D.SerialNo = H.BaseSerialNo
		where   D.ProcessID=70 '+@StrWhereD+''
	
	print @StrSelect
	
	Exec sp_executesql @StrSelect; 
	
IF (SELECT COUNT(*) from #tblTemp)>4096
	BEGIN
		Raiserror (N'تعداد ستون ها بیشتر از 4096 است و گزارش نمیتواند پاسخگو باشد',16,1)
		Return
	END
 
Declare	curStoreID CURSOR For 
 select StoreID,StoreName from #tblTemp 

Open  curStoreID; 

Fetch NEXT From curStoreID Into @StoreID,@StoreName

While (@@Fetch_Status = 0)
	BEGIN
		set @Columns=@Columns+',['+@StoreID+']'
		set @ColumnsSum=@ColumnsSum+'+isnull(['+@StoreID+'],0)'
		set @Columns2=@Columns2+', cast (isnull(['+@StoreID+'],0) as float) as ['+ @StoreName +'] '
		Fetch NEXT From curStoreID Into @StoreID,@StoreName
	END

Close curStoreID;  
Deallocate curStoreID; 

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
	
	select   ProductID,  ProductCount,D.* 
		into  #RptTable 
	FROM	inv.tblStorageDocsDtl D 
	INNER JOIN inv.tblStorageDocsHdr H
		ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
	where   1=0 
	
	--------------------------------------------------------------------------------------------
	if @UserIsAdmin=0
	begin
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
	 Insert into  #tblAcntCode (AcntCode) SELECT  Distinct AcntCode	FROM         inv.tblStorageDocsHdr
	 Insert into  #tblGoods (GoodsID) SELECT  Distinct GoodsID	FROM         inv.tblStorageDocsDtl	 	
	 Insert into  #tblStoreID (StoreID) SELECT  Distinct StoreID	FROM         inv.tblStorageDocsHdr
	
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblStoreID', 'StoreID', 'inv.tblStores', @UserID;
		 exec pub.SpFilterByPermission2 '#tblGoods', 'GoodsID', 'inv.tblGoods', @UserID;
	-----------------------------------------------------------------
	--SET @StrWhereH = '  and  acc.funAllowAcntCode('+ltrim(str(@UserID))+','+ ltrim(str(@UserIsAdmin))+',	H.AcntCode,'+ltrim(str(@PartNumber))+') =1 '
	SET @StrWhereD =  @StrWhereD + '  and   H.AcntCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) '
	SET @StrWhereD =  @StrWhereD + '  and   H.StoreID in (SELECT   StoreID	FROM  #tblStoreID    ) '
	SET @StrWhereD =  @StrWhereD + '  and   D.GoodsID in (SELECT   GoodsID	FROM  #tblGoods    ) '
------------------------------------------------------------------------------------------------
	END
 	

declare @StrType as varchar(max)	
declare @StrCurrencyType as varchar(max)	
 

if @CallType=1
begin
	if @CurrencyType=0
		set @StrType =' sum( GoodsQuantity * EnterKind * -1)'
	else
		set @StrType =' sum( GoodsQuantity * GoodsAmount * EnterKind * -1)'
	
	SET @StrSelect = ' 
		insert into #RptTable
		select  H.ProductID,H.ProductCount,D.* 
		FROM	inv.tblStorageDocsDtl D 
		INNER JOIN  (Select GoodsAmount,AcntCode,DocDate,StoreID,GoodsID ProductID,GoodsQuantity ProductCount,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,ProcessID,ProcessNo,FiscalYear,SerialNo  From inv.tblStorageDocsDtl where ProcessID=80  and DocRowNo=1) H
			ON D.ProcessID = H.BaseProcessID And D.ProcessNo = H.BaseProcessNo And D.FiscalYear = H.BaseFiscalYear And D.SerialNo = H.BaseSerialNo
		where   D.ProcessID=70 '+@StrWhereD+''
end
else
begin
	if @CurrencyType=0
		set @StrType =' sum( ProductCount*EnterKind )'
	else
		set @StrType =' sum( GoodsAmount*EnterKind)'	
	
	SET @StrSelect = ' 
		insert into #RptTable
		select  H.ProductID,H.ProductCount,D.* 
		FROM	inv.tblStorageDocsDtl D 
		INNER JOIN  (Select GoodsAmount,AcntCode,DocDate,StoreID,GoodsID ProductID,GoodsQuantity ProductCount,ProcessID,ProcessNo,FiscalYear,SerialNo From inv.tblStorageDocsDtl where ProcessID=80  and DocRowNo=1) H
			ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
		where   D.ProcessID=80  and D.DocRowNo=1 '+@StrWhereD+''
end					

	print @StrSelect
	Exec sp_executesql @StrSelect; 
	
--select * into RptTable1  from #RptTable 

-- select  @Group2,@Group1,@StrType, *   from  #RptTable

set @FilterPrdCnt=isnull(@FilterPrdCnt,'H.ProductID')
SET @StrSelect = '
	select Name1 [کد ], '+ @Name +' [نام], '+@Columns2+' ,'+@ColumnsSum+' [مجموع]   
	from
		(select Name1  ,'+@Columns+' from
		(select Name1 , Name2 ,  GoodsQuantity from
		(select '+@Group2+' Name1 , '+@Group1+' Name2 , '+ @StrType +'  GoodsQuantity  from  #RptTable D 
				where   '+ @Group1 +'<>''''	and  1=1  
				GROUP BY  '+@Group2+', '+@Group1+' 
			) T
		) 
		P	PIVOT 
			(
				Sum(P.GoodsQuantity)
				for P.Name2 In ('+@Columns+')
			) AS PVT 
)a	'
	SET @StrSelect = @StrSelect + ' where '+@ColumnsSum+'<>0'
	print @StrSelect	
	Exec sp_executesql @StrSelect;
GO
