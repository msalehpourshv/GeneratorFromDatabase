USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari	
-- Create date   : 1400/08/08
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش برنامه ریزی
-- ==============================================
Create PROCEDURE pln.RptTaskOrderList
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111' ,-- bit array	
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS
---- Declarations ---------------
Declare @StrSelect				NVarChar(max);
Declare @StrWhereIN				NVarChar(max);
Declare @StrWhereD				NVarChar(max);
Declare @ProcessID				Varchar(20) 
Declare @ProcessNo				Varchar(20) 
DECLARE	@LangID					Char(1);
DECLARE	@UserID					Int;
DECLARE	@UserIsAdmin			bit;
Declare @StoreID				nvarchar(200)
Declare @StoreName				nvarchar(200)
Declare @Columns				nvarchar(max)
Declare @Columns2				nvarchar(max)
Declare @ColumnsSum				nvarchar(max)
declare @Name					nvarchar(2000);
declare @Group1					nvarchar(200);
declare @Group2					nvarchar(200);
declare @Col					int;
declare @Row					int;
declare @Cnt					int;
declare @FiscalYearFromOrder	int;
declare @SerialNoFromOrder		int;
declare @FiscalYearToOrder		int;
declare @SerialNoToOrder		int;
declare @FiscalYearFromTask		int;
declare @SerialNoFromTask		int;
declare @FiscalYearToTask		int;
declare @SerialNoToTask			int;
declare @ShowProduceStepName	bit;
declare @StrProduceStepName1	varchar(200);
declare @StrProduceStepName2	varchar(200);

SET @LangID				= pub.funSplitString(@RepInfo, '@', 1);
SET @UserID				= pub.funSplitString(@RepInfo, '@', 4);
SET @UserIsAdmin		= pub.funSplitString(@RepInfo, '@', 5);

SET @Col					= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @Row					= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @Cnt					= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
SET @ProcessID				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
SET @ProcessNo				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
SET @StrWhereIN				= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
SET @FiscalYearFromOrder	= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
SET @SerialNoFromOrder		= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
SET @FiscalYearToOrder		= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
SET @SerialNoToOrder		= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
SET @FiscalYearFromTask		= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
SET @SerialNoFromTask		= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
SET @FiscalYearToTask		= LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
SET @SerialNoToTask			= LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 
SET @ShowProduceStepName	= LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 

IF @Col<>1 AND @Row<>1
	SET @ShowProduceStepName='False'

set @StrProduceStepName1=' ,'' '' '
set @StrProduceStepName2='  '

if @ShowProduceStepName='true'
	begin
		Set @StrProduceStepName1=', Str(S.ProduceStepID) +''-''+ [ProduceStepName] ProduceStepName'
		Set @StrProduceStepName2=' inner join pln.tblProduceStepDtl S on D.ProduceStepID=S.ProduceStepID and H.ProductID=S.ProductID '
	end 

IF @Cnt=0 
	SET @Cnt = 5000

if @Col=1	
	if @ShowProduceStepName='true'
		Set @Group1='ProduceStepName'
	else
		Set @Group1='ProduceStepID'
if @Row=1  
begin
	if @ShowProduceStepName='true'
	BEGIN
		Set @Group2='ProduceStepName'
		set @Name ='Name1 '-- pub.ProduceStepID (Name1,'+ @LangID +')  '
	END 
	else
	BEGIN
		Set @Group2='ProduceStepID'
		set @Name ='Name1 '-- pub.ProduceStepID (Name1,'+ @LangID +')  '
	END 
end 
if @Col=2	 Set @Group1='ProductID'
if @Row=2 
begin
	Set @Group2='ProductID'
	set @Name =' pub.funGetGoodsName (Name1,'+  @LangID +')  '
end 
if @Col=3  Set @Group1='substring(StartDate,6,2)'
if @Row=3
begin
	Set @Group2='substring(StartDate,6,2)'
	set @Name ='case Name1  when ''01'' then ''فروردین''  when ''02'' then ''اردیبهشت''  when ''03'' then ''خرداد''  when ''04'' then ''تیر''  when ''05'' then ''مرداد''  when ''06'' then ''شهریور''  
			when ''07'' then ''مهر''  when ''08'' then ''آبان''  when ''09'' then ''آذر''  when ''10'' then ''دی''  when ''11'' then ''بهمن'' else ''اسفند'' end ' 
end 
if @Col=4  Set @Group1='StartDate'
if @Row=4
begin
	Set @Group2='StartDate'
	set @Name =' Name1'
end 
if @Col=5  Set @Group1='D.AcceptStoreID'
if @Row=5
begin
	Set @Group2='D.AcceptStoreID'
	set @Name =' [pub].[GetStoreName](Name1,'+ @LangID +') '
end 
if @Col=6	 Set @Group1='MachineryEquipmentID'
if @Row=6 
begin
	Set @Group2='MachineryEquipmentID'
	DECLARE @db_0000		NVarchar(50)
	SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	set @Name =@db_0000+'.tpm.funGetMachineryEquipmentName(Name1,'+ @LangID +')  '
end 
if @Col=7	 Set @Group1='OperatorID'
if @Row=7 
begin
	Set @Group2='OperatorID'
	set @Name =' prs.funGetPersonnelName(Name1,'+ @LangID +')  '
end 
if @Col=8	 Set @Group1='ToolID'
if @Row=8 
begin
	Set @Group2='ToolID'
	set @Name =' pln.funGetToolName(Name1,'+ @LangID +')  '
end 
if @Col=9	 Set @Group1='ShiftTypeID'
if @Row=9
begin
	Set @Group2='ShiftTypeID'
	set @Name =' emp.funGetShiftTypeName(Name1,'+ @LangID +')  '
end  
if @Col=10	 Set @Group1='ProductionLineID'
if @Row=10
begin
	Set @Group2='ProductionLineID'
	set @Name =' pln.funGetProductionLineName(Name1,'+ @LangID +')  '
end 
if @Col=11	 Set @Group1='BatchNo'
if @Row=11
begin
	Set @Group2='BatchNo'
	set @Name =' [inv].[funGetBatchName](Name1,'+ @LangID +')  '
end 
if @Col=12	 Set @Group1='FaultID'
if @Row=12
begin
	Set @Group2='FaultID'
	set @Name =' pln.funGetFaultName(Name1,'+ @LangID +')  '
end  

if @Col=13  Set @Group1='BaseFiscalYearSerialNo'
if @Row=13
begin
	Set @Group2='BaseFiscalYearSerialNo'
	set @Name =' Name1 ' 
end 
if @Col=14  Set @Group1='FiscalYearSerialNo'
if @Row=14
begin
	Set @Group2='FiscalYearSerialNo'
	set @Name =' Name1  ' 
end 

set @Columns =''
set @Columns2 =''
set @ColumnsSum =''
set @StrWhereD=''

IF (@ProcessID Is not Null)	
	SET @StrWhereD = @StrWhereD + ' AND (D.ProcessID IN(' + @ProcessID + ')) '

IF (@ProcessNo Is not Null)	
	SET @StrWhereD = @StrWhereD + ' AND (D.ProcessNo IN(' + @ProcessNo + ')) '

if @FiscalYearFromOrder>0
	SET @StrWhereD = @StrWhereD + ' AND (H.BaseFiscalYear =' + str(@FiscalYearFromOrder) + ')'
if @SerialNoFromOrder>0
	SET @StrWhereD = @StrWhereD + ' AND (H.BaseSerialNo >=' + str(@SerialNoFromOrder) + ')'
if @FiscalYearToOrder>0
	SET @StrWhereD = @StrWhereD + ' AND (H.BaseFiscalYear =' + str(@FiscalYearToOrder) + ')'
if @SerialNoToOrder>0
	SET @StrWhereD = @StrWhereD + ' AND (H.BaseSerialNo <=' + str(@SerialNoToOrder) + ')'
if @FiscalYearFromTask>0
	SET @StrWhereD = @StrWhereD + ' AND (H.FiscalYear =' + str(@FiscalYearFromTask) + ')'
if @SerialNoFromTask>0
	SET @StrWhereD = @StrWhereD + ' AND (H.SerialNo >=' + str(@SerialNoFromTask) + ')'
if @FiscalYearToTask>0
	SET @StrWhereD = @StrWhereD + ' AND (H.FiscalYear =' + str(@FiscalYearToTask) + ')'
if @SerialNoToTask>0
	SET @StrWhereD = @StrWhereD + ' AND (H.SerialNo <=' + str(@SerialNoToTask) + ')'

If (@StrWhereIN Is Not Null  and  LTRIM(rtrim(@StrWhereIN ))<>'')
	SET @StrWhereD = @StrWhereD + @StrWhereIN

select  
		H.ProductID ,H.OrderCount,	H.BatchNo,	H.TaskStateID	,H.ProduceStepSerialNo ProduceStepSerialNoHdr	,H.UsageStoreID UsageStoreIDHdr	,
		H.AcceptStoreID AcceptStoreIDHdr	,H.FailedStoreID FailedStoreIDHdr,H.ProductStoreID	,H.RepairStepID	,H.FormulaNo	,H.LossStoreID LossStoreIDHdr	
		,H.BaseProcessID	,H.BaseProcessNo	,H.BaseFiscalYear	,H.BaseSerialNo	,H.BaseDocRowNo	,H.Suspend
		,D.*  ,H.ProductID OperatorID,H.ProductID FaultID
		,ltrim(rtrim(str(H.BaseFiscalYear)))+'/'+ltrim(rtrim(str(H.BaseSerialNo)))	BaseFiscalYearSerialNo
		,ltrim(rtrim(str(H.FiscalYear)))+'/'+ltrim(rtrim(str(H.SerialNo)))	FiscalYearSerialNo
		,D.DescDtl ProduceStepName
	into  #RptTable
FROM	pln.tblTaskOrderDtl D 
	INNER JOIN pln.tblTaskOrderHdr H
		ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
where   1=0
		
------------------------------------------------------------------------------------------------
if @Col=7 or  @Row=7 
SET @StrSelect = ' insert into #RptTable
		select  H.ProductID ,H.OrderCount,	H.BatchNo,	H.TaskStateID	,H.ProduceStepSerialNo ProduceStepSerialNoHdr	,H.UsageStoreID UsageStoreIDHdr	,
				H.AcceptStoreID AcceptStoreIDHdr	,H.FailedStoreID FailedStoreIDHdr,H.ProductStoreID	,H.RepairStepID	,H.FormulaNo	,H.LossStoreID LossStoreIDHdr	,H.BaseProcessID	,H.BaseProcessNo	,H.BaseFiscalYear	,H.BaseSerialNo	,H.BaseDocRowNo	,H.Suspend
				,D.*   ,isnull(o.OperatorID,''''),''''
				,ltrim(rtrim(str(H.BaseFiscalYear)))+''/''+ltrim(rtrim(str(H.BaseSerialNo)))	BaseFiscalYearSerialNo
				,ltrim(rtrim(str(H.FiscalYear)))+''/''+ltrim(rtrim(str(H.SerialNo)))	FiscalYearSerialNo
				'+@StrProduceStepName1 +'
		FROM	pln.tblTaskOrderDtl D 
		INNER JOIN pln.tblTaskOrderHdr H
			ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
		left join  pln.tblTaskOrderOperators o
			ON D.ProcessID = o.ProcessID And D.ProcessNo = o.ProcessNo And D.FiscalYear = o.FiscalYear And D.SerialNo = o.SerialNo And D.RowNo= o.RowNo
		'+@StrProduceStepName2 +'
		where   1=1 '+@StrWhereD+''	
else if @Col=12 or  @Row=12 
	SET @StrSelect = ' insert into #RptTable
		select  H.ProductID ,H.OrderCount,	H.BatchNo,	H.TaskStateID	,H.ProduceStepSerialNo ProduceStepSerialNoHdr	,H.UsageStoreID UsageStoreIDHdr	,
				H.AcceptStoreID AcceptStoreIDHdr	,H.FailedStoreID FailedStoreIDHdr,H.ProductStoreID	,H.RepairStepID	,H.FormulaNo	,H.LossStoreID LossStoreIDHdr	,H.BaseProcessID	,H.BaseProcessNo	,H.BaseFiscalYear	,H.BaseSerialNo	,H.BaseDocRowNo	,H.Suspend
				,D.*  ,'''',isnull(o.FaultID,'''')
				,ltrim(rtrim(str(H.BaseFiscalYear)))+''/''+ltrim(rtrim(str(H.BaseSerialNo)))	BaseFiscalYearSerialNo
				,ltrim(rtrim(str(H.FiscalYear)))+''/''+ltrim(rtrim(str(H.SerialNo)))	FiscalYearSerialNo
				'+@StrProduceStepName1 +'
		FROM	pln.tblTaskOrderDtl D 
		INNER JOIN pln.tblTaskOrderHdr H 		
			ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
		'+@StrProduceStepName2 +'
	left join  pln.tblFaultItems o
			ON D.ProcessID = o.ProcessID And D.ProcessNo = o.ProcessNo And D.FiscalYear = o.FiscalYear And D.SerialNo = o.SerialNo And D.DocRowNo= o.DocRowNo	
		where   1=1 '+@StrWhereD+''
else
	SET @StrSelect = ' insert into #RptTable
		select  H.ProductID ,H.OrderCount,	H.BatchNo,	H.TaskStateID	,H.ProduceStepSerialNo ProduceStepSerialNoHdr	,H.UsageStoreID UsageStoreIDHdr	,
				H.AcceptStoreID AcceptStoreIDHdr	,H.FailedStoreID FailedStoreIDHdr,H.ProductStoreID	,H.RepairStepID	,H.FormulaNo	,H.LossStoreID LossStoreIDHdr	,H.BaseProcessID	,H.BaseProcessNo	,H.BaseFiscalYear	,H.BaseSerialNo	,H.BaseDocRowNo	,H.Suspend
				,D.*  ,'''',''''
				,ltrim(rtrim(str(H.BaseFiscalYear)))+''/''+ltrim(rtrim(str(H.BaseSerialNo)))	BaseFiscalYearSerialNo
				,ltrim(rtrim(str(H.FiscalYear)))+''/''+ltrim(rtrim(str(H.SerialNo)))	FiscalYearSerialNo
				'+@StrProduceStepName1 +'
		FROM	pln.tblTaskOrderDtl D 
		INNER JOIN pln.tblTaskOrderHdr H
			ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
		'+@StrProduceStepName2 +'
		where   1=1 '+@StrWhereD+''
	
print @StrSelect
Exec sp_executesql @StrSelect; 

BEGIN TRY
	DROP TABLE #tblTemp
END TRY
BEGIN CATCH
END CATCH
	
CREATE TABLE #tblTemp
	(		
		StoreID VarChar(200) ,
		StoreName nVarChar(200)
	)
set @StrSelect='insert into #tblTemp 
					select distinct top '+ str(@Cnt) +'  '+ @Group1 +' ,'+ @Group1 +' 
					From #RptTable D
					where  '+ @Group1 +'<>''''	'--and  1=1 '+@StrWhereD+''
print @StrSelect
Exec sp_executesql @StrSelect; 

IF (SELECT COUNT(*) from #tblTemp)>4096
	BEGIN
		Raiserror (N'تعداد ستون ها بیشتر از 4096 است و گزارش نمیتواند پاسخگو باشد',16,1)
		Return
	END
 if @Col=13 or @Col=14 
 begin
	Declare	curStoreID CURSOR For 
		select StoreID,StoreName from #tblTemp 
		order by cast (substring(StoreID ,1,4) as int) ,cast (substring(StoreID ,6,len(StoreID)-5) as int)
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
end 
else
begin
	Declare	curStoreID CURSOR For 
		select [StoreID],[StoreName] from #tblTemp 
		order by StoreID
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
end 
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

declare @StrType as varchar(max)	
set @StrType=' sum(AcceptableCount )'

SET @StrSelect = '
select Name1 [کد ], '+ @Name +' [نام],'+@Columns2+' ,'+@ColumnsSum+' [مجموع]   
   from
		(select Name1  ,'+@Columns+' from
		( 
			select Name1 , Name2 ,  Price
			from
			(
				select '+@Group2+' Name1 , '+@Group1+' Name2 , '+ @StrType +'  Price  from  #RptTable D -- pln.tblTaskOrderDtl 
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

 if @Row=13 or @Row=14 
	SET @StrSelect = @StrSelect + ' where '+@ColumnsSum+'<>0  order by cast (substring(Name1 ,1,4) as int) ,cast (substring(Name1 ,6,len(Name1)-5) as int) '	
else
	SET @StrSelect = @StrSelect + ' where '+@ColumnsSum+'<>0  order by Name1 '


print @StrSelect
Exec sp_executesql @StrSelect;
GO
