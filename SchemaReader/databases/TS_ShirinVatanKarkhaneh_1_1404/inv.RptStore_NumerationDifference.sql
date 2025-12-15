USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ==================
-- Author		 : TakroSyatem\Ahmadnejad
-- Create date   : 1386/05/24
-- Viewed By	 : 
-- Last Modified : 1390/07/06
-- Last Modifier : TakroSyatem\Zia
-- Description   : لیست مغایرت انبار گردانی ;
-- ============================================
Create PROCEDURE inv.RptStore_NumerationDifference 
	@SerialNo		VarChar(20),
	@GoodsIDFr		VarChar(20) = Null,
	@GoodsIDTo		VarChar(20) = Null,
	@GoodsIDMask	VarChar(20) = Null, 
	@DocDateTo		VarChar(10) = Null, 
	@SortFields		NVarChar(100) = Null,
	@RepOptions		NVarChar(100) = '111110', 
	@RepInfo		NVarChar(100) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrSelect1	NVarChar(max);
DECLARE @StrWhereSD	NVarChar(2000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StoreID	NVarChar(20);
DECLARE @FiscalYear int;

DECLARE @ShowPrice	Bit; -- شامل ستون قیمت
DECLARE @ZeroAmount	Bit; -- شامل کالاهای با مبلغ صفر
DECLARE @AllGoods	Bit; -- شامل کالاهائی که در سند شمارش نیستند
DECLARE @Decrease	Bit; -- کاهش ها
DECLARE @Increase	Bit; -- افزایش ها
DECLARE @DontFilt	Bit; -- همه کالاها

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@Decimlas	Int;
DECLARE @strRound VARCHAR(50)

DECLARE @ShowPE		Bit; -- مجوزها دخیل نباشد
DECLARE	@CallType	Int;
DECLARE	@ProcessID	Int;

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
	DECLARE @UnitPart TINYINT	
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	-- Init Variables --------------------------------
	IF (@RepOptions Is Null) SET @RepOptions = '11101';
	IF (@RepInfo Is Null)	 SET @RepInfo = '1@1@1';
	IF (@SortFields Is Null) SET @SortFields = 'GoodsID';
		
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @CallType	= pub.funSplitString(@RepInfo, '@', 6);
	SET @ProcessID	= pub.funSplitString(@RepInfo, '@', 7);
	
	set @Decimlas = 2
	select @Decimlas = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimalsToForms'

	SELECT	@StoreID = StoreID
	FROM	inv.tblStoresNumerationDtl
	WHERE	SerialNo = @SerialNo

	IF (@StoreID Is Null) SET @StoreID = ''

	SET @ShowPrice	= Substring(@RepOptions, 1, 1)
	SET @ZeroAmount	= Substring(@RepOptions, 2, 1)
	SET @AllGoods	= Substring(@RepOptions, 3, 1)
	SET @Decrease	= Substring(@RepOptions, 4, 1)
	SET @Increase	= Substring(@RepOptions, 5, 1)
	SET @DontFilt	= Substring(@RepOptions, 6, 1)
	SET @FiscalYear	= Substring(@RepOptions, 7, 4)
	SET @ShowPE		= Substring(@RepOptions, 11, 1)
	
update inv.tblStorageDocsSerials
 set NumberPerContainer=0 , ContainerStoresID='',ProductionDate='',ExpireDate=''
 where ContainerID ='' and NumberPerContainer<>0
	
update inv.tblStoresNumerationSerials
 set NumberPerContainer=0 , ContainerStoresID='',ProductionDate='',ExpireDate=''
 where ContainerID ='' and NumberPerContainer<>0

	--------------------------------------------------		 
if @CallType<>4
	begin

	IF @Decrease = 1
		SET @strRound = ',' + str(@Decimlas) + ''
	ELSE
		SET @strRound = ''
CREATE TABLE #tbl_RptStore_Numeration_Diff
	(
		GoodsID				VarChar(20) COLLATE ARABIC_CS_AS,
		GoodsName			VarChar(500) COLLATE ARABIC_CS_AS,
		UnitID				VarChar(20) COLLATE ARABIC_CS_AS,
		UnitName			VarChar(1000) COLLATE ARABIC_CS_AS,
		CostCenterAcntCode	VarChar(20) COLLATE ARABIC_CS_AS,
		TotalEnumQty		Float,
		TotalEnumSubQty		Float,
		TotalSubBalanceQty	Float,
		TotalBalanceQty		Float,
		TotalPrice			Float,
		UserPrice			NVarChar(100) ,
		UserPriceID			VarChar(20) COLLATE ARABIC_CS_AS,
		BatchNo  			VarChar(20) COLLATE ARABIC_CS_AS,
		BatchNameDtl		VarChar(1000) COLLATE ARABIC_CS_AS,
		SubUnitID  			VarChar(20) COLLATE ARABIC_CS_AS,
		SubUnitName  		VarChar(500) COLLATE ARABIC_CS_AS
		)
	
	-- Where Clause ----------------------------------
	SET @StrWhere = '(1=1)';

	IF (@GoodsIDFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.GoodsID >= ''' + @GoodsIDFr + ''''
	IF (@GoodsIDTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.GoodsID <= ''' + @GoodsIDTo + ''''
	IF (@GoodsIDMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.GoodsID LIKE ''' + RTrim(Replace(@GoodsIDMask, ' ', '_')) + '%'''
		
	IF (@ShowPE = 1) 
		SET @StrWhereSD = @StrWhereSD + ' AND (D.PhysicallyEffected=1)'			
		
	----------------------------------------------------------------------------------
	-- Select Clause -------------------------------------------
	DECLARE @OtherFiscalYear		varchar(1)
	SET @OtherFiscalYear  = '0'
	SELECT @OtherFiscalYear = SettingValue from pub.tblSettings where SettingKey = 'OtherFiscalYear'
	IF @OtherFiscalYear IS NULL 
		SET @OtherFiscalYear = '0'

	SET	@StrWhereSD =  ' (D.StoreID = ''' + @StoreID + ''') '

	IF @OtherFiscalYear = '0'	
		SET @StrWhereSD = @StrWhereSD +' AND (D.FiscalYear = '+ ltrim(str(@FiscalYear)) +')'
		 
	IF (@AllGoods = 0)
		SET @StrWhereSD = @StrWhereSD + ' 
				AND (D.GoodsID IN (SELECT E.GoodsID FROM inv.tblStoresNumerationDtl E WHERE E.SerialNo = ' + @SerialNo + '))'

	IF (@DocDateTo Is Not Null)
		SET @StrWhereSD = @StrWhereSD + ' 
				AND (D.DocDate <= ''' + @DocDateTo + ''')'

	If (@ZeroAmount = 0) 
		SET @StrWhereSD = @StrWhereSD + '
				AND (D.GoodsAmount <> 0)'

	SET @StrSelect = '
		SELECT	D.GoodsID,
				D.BatchNo,
				D.UserPriceID,
				Sum(D.EnterKind * D.GoodsQuantity) AS BalanceQuantity, 
				SUM(D.EnterKind * case WHEN S.GoodsID IS NULL THEN D.GoodsQuantity when D.SubUnitID = S.SubUnitID then D.SubUnitQuantity else D.GoodsQuantity * (S.UnitValue / S.MainUnitValue) end) BalanceSubQuantity,
			    SUM(D.EnterKind * D.GoodsQuantity * D.GoodsAmount) AS BalancePrice,
				0 AS EnumQuantity, 0 AS EnumSubUnitQuantity				
		FROM	inv.tblStorageDocsDtl D 
		LEFT JOIN inv.tblSubUnitsDtl S ON D.GoodsID=S.GoodsID AND S.ShowInInvoice=''True''
		WHERE	' + @StrWhereSD + '
		GROUP BY D.GoodsID,D.BatchNo,D.UserPriceID,S.SubUnitID, D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo , D.DocRowNo
		HAVING	Sum(D.EnterKind * D.GoodsQuantity) <> 0 

		UNION ALL

		SELECT	D.GoodsID,
				D.BatchNo,
				D.UserPriceID, 
				0 AS BalanceQuantity, 
				0 AS BalanceSubQuantity,
				0 AS BalancePrice, 
				Sum(D.GoodsQuantity) AS EnumQuantity,
				SUM(case WHEN S.GoodsID IS NULL THEN D.GoodsQuantity when D.SubUnitID = S.SubUnitID then D.SubUnitQuantity else D.GoodsQuantity * (S.UnitValue / S.MainUnitValue) end) AS EnumSubUnitQuantity								
		FROM	inv.tblStoresNumerationDtl D
		LEFT JOIN inv.tblSubUnitsDtl S ON D.GoodsID=S.GoodsID AND S.ShowInInvoice=''True''
		WHERE	D.SerialNo = ' + @SerialNo + '
		GROUP BY D.GoodsID,D.BatchNo,D.UserPriceID , D.SerialNo , D.DocRowNo '

	SET @StrSelect = ' insert INTO #tbl_RptStore_Numeration_Diff
	SELECT	D.GoodsID, pub.funGetGoodsName(D.GoodsID,' + @LangID + ') GoodsName, U.UnitID, U.UnitName,CostCenterAcntCode,
			cast(Sum(EnumQuantity) as float ) AS TotalEnumQty,
			cast(Sum(EnumSubUnitQuantity) as float ) AS TotalEnumSubQty,
			cast(Sum(BalanceSubQuantity) as float ) AS TotalSubBalanceQty, 
			cast(Round(Sum(BalanceQuantity),'+ str(@Decimlas)+') as float ) AS TotalBalanceQty, 
			cast(Sum(BalancePrice) as float ) AS TotalPrice,
			ISNULL(P.UParams,'''') UserPrice,
			ISNULL(D.UserPriceID,0) UserPriceID,
			BatchNo,
			[inv].[funGetBatchName](BatchNo,' + LTrim(RTrim(@LangID)) + ') BatchNameDtl,
			CASE WHEN  S.GoodsID IS NULL THEN U.UnitID ELSE S.SubUnitID END SubUnitID, CASE WHEN  S.GoodsID IS NULL THEN U.UnitName ELSE ISNULL(U2.UnitName,'''') END SubUnitName			
	FROM
	( ' + @StrSelect + '
	) D 
		inner join inv.tblGoods	GH on GH.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		left  join inv.tblUnitsDtl U on U.UnitID = GH.UnitID AND U.LanguageID =  '+ @LangID+ ' 
		left  join inv.tblGoodsUserPrice P on P.GoodsID = D.GoodsID and D.UserPriceID=P.ID
		left  JOIN inv.tblSubUnitsDtl S ON D.GoodsID=S.GoodsID AND S.ShowInInvoice=''True''
		left  join inv.tblUnitsDtl U2 on U2.UnitID = S.SubUnitID AND U2.LanguageID =  1 
 	WHERE ' + @StrWhere + '
	GROUP BY D.GoodsID,D.BatchNo,D.UserPriceID,P.UParams , U.UnitID, U.UnitName, CostCenterAcntCode
		, CASE WHEN  S.GoodsID IS NULL THEN U.UnitID ELSE S.SubUnitID END 
		, CASE WHEN  S.GoodsID IS NULL THEN U.UnitName ELSE ISNULL(U2.UnitName,'''') END 
		'

	if (@DontFilt = 0)
	begin
		IF (@Increase = 1) AND (@Decrease = 1)
			SET @StrSelect = @StrSelect + ' HAVING cast(Sum(EnumQuantity) as float ) <> cast(Sum(BalanceQuantity) as float )   OR D.GoodsID  in (Select GoodsID From inv.tblGoods where HasContainer=''True'' ) '
		else IF (@Increase = 1) AND (@Decrease = 0)
			SET @StrSelect = @StrSelect + ' HAVING cast(Sum(EnumQuantity) as float )  > cast(Sum(BalanceQuantity) as float )   OR D.GoodsID  in (Select GoodsID From inv.tblGoods where HasContainer=''True'' ) '
		else IF (@Increase = 0) AND (@Decrease = 1)
			SET @StrSelect = @StrSelect + ' HAVING cast(Sum(EnumQuantity) as float )  < cast(Sum(BalanceQuantity) as float )   OR D.GoodsID  in (Select GoodsID From inv.tblGoods where HasContainer=''True'' ) '
		else IF (@Increase = 0) AND (@Decrease = 0)
			SET @StrSelect = @StrSelect + ' HAVING cast(Sum(EnumQuantity) as float )  = cast(Sum(BalanceQuantity) as float )  OR D.GoodsID  in (Select GoodsID From inv.tblGoods where HasContainer=''True'' ) '
	end

	-- Sort Clause ---------------------------------------------
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields + ' ; '
	
	if (@ShowPrice = 1) 
	begin
		SET @StrSelect = @StrSelect + '
		update #tbl_RptStore_Numeration_Diff 
		set TotalPrice = 
			isnull((
				select top 1 GoodsAmount 
				from inv.tblStorageDocsDtl D2
				where (D2.GoodsID = #tbl_RptStore_Numeration_Diff.GoodsID) and (D2.StoreID = ''' + @StoreID + ''')  and ((D2.GoodsAmount > 0) OR (TotalBalanceQty = 0 AND TotalPrice > 0 ))
				order by DocDate desc, VolumeRowNo desc
			) , 0)
		where (TotalBalanceQty = 0) '--and (TotalPrice = 0) '

		SET @StrSelect = @StrSelect + '
		update #tbl_RptStore_Numeration_Diff 
		set TotalPrice = 
			isnull((
				select top 1 GoodsAmount 
				from inv.tblStorageDocsDtl D2
				where (D2.GoodsID = #tbl_RptStore_Numeration_Diff.GoodsID) and (D2.GoodsAmount > 0)
				order by DocDate desc, VolumeRowNo desc
			), 0)
		where (TotalBalanceQty = 0) and (TotalPrice = 0); '
		 
	end;
	
	-- Run -----------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
		
if @CallType=0
begin
	SET @StrSelect = 'select *	from #tbl_RptStore_Numeration_Diff 	'
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
end 
if ( @ProcessID = 188 or @ProcessID = 189 ) and (@CallType=1 or @CallType=2 or @CallType=3)
begin 

	select  1 EnterKind ,b.StoreID ,b.GoodsID ,b.GoodsID PSerialNo,GoodsID ProductSerialID
		,   pub.funGetGoodsName (b.GoodsID,1) GoodsName
		, [pub].[funGetGoodsUnitID] (b.GoodsID) UnitID
		,  pub.funGetGoodsName (b.GoodsID,1) UnitName	
	into #tblStores 
	from inv.tblStoresNumerationDtl b
	where 1=0

		SET	@StrWhere =  ' (D.StoreID = ''' + @StoreID + ''') '

	IF (@GoodsIDFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.GoodsID >= ''' + @GoodsIDFr + ''''
	IF (@GoodsIDTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.GoodsID <= ''' + @GoodsIDTo + ''''
	IF (@GoodsIDMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.GoodsID LIKE ''' + RTrim(Replace(@GoodsIDMask, ' ', '_')) + '%'''
		
	IF (@AllGoods = 0)
		SET @StrWhere = @StrWhere + ' 
				AND (D.GoodsID IN (SELECT E.GoodsID FROM inv.tblStoresNumerationDtl E WHERE E.SerialNo = ' + @SerialNo + '))'

	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' 
				AND (D.DocDate <= ''' + @DocDateTo + ''')'

SET @StrSelect =  ' 
	  from (
		select  1 EnterKind, a.StoreID , GoodsID , PSerialNo,isnull(ProductSerialID,0) ProductSerialID
		from inv.tblStoresNumerationSerials a				
			inner join inv.tblStoresNumerationDtl D
			on   a.SerialNo=D.SerialNo and a.DocRowNo=D.DocRowNo
		where '+@StrWhere+'
		and a.SerialNo=' + @SerialNo + '
		) a Full join (

		 select sum(a.EnterKind ) EnterKind, a.StoreID, GoodsID, PSerialNo,ProductSerialID
		From (
		select  a.EnterKind , a.StoreID , GoodsID, PSerialNo,ProductSerialID
		from inv.tblStorageDocsSerials a				
			inner join inv.tblStorageDocsDtl D
			on a.ProcessID=D.ProcessID and a.ProcessNo=D.ProcessNo and a.FiscalYear=D.FiscalYear and a.SerialNo=D.SerialNo and a.DocRowNo=D.DocRowNo
		where 	'+@StrWhere+'
		--Union all 
		--select  Case when a.ProcessID=188 then 1 else -1 end EnterKind , a.StoreID , GoodsID, PSerialNo,ProductSerialID
		--from inv.tblStorageDocsSerials a				
		--	inner join  sal.tblSaleOrderDtl D
		--	on a.ProcessID=D.ProcessID and a.ProcessNo=D.ProcessNo and a.FiscalYear=D.FiscalYear and a.SerialNo=D.SerialNo and a.DocRowNo=D.DocRowNo
		--where 	'+@StrWhere+'
		) a group by a.StoreID , GoodsID, PSerialNo,ProductSerialID
		having sum(a.EnterKind)<>0
		) b on a.PSerialNo=b.PSerialNo  
		
	'
	if @CallType=1
		SET @StrSelect =  ' insert into #tblStores(EnterKind,StoreID,GoodsID,PSerialNo,ProductSerialID)	
			select  b.EnterKind ,b.StoreID ,b.GoodsID ,b.PSerialNo,b.ProductSerialID	'+ @StrSelect+' Where a.EnterKind  is null 
			union All 	select a.EnterKind	,a.StoreID	,a.GoodsID	,a.PSerialNo,a.ProductSerialID '+ @StrSelect+' Where b.EnterKind  is null '
	
	if @CallType=2
		SET @StrSelect =  ' insert into #tblStores(EnterKind,StoreID,GoodsID,PSerialNo,ProductSerialID)	select  b.EnterKind ,b.StoreID ,b.GoodsID ,b.PSerialNo,b.ProductSerialID	'+ @StrSelect+' Where a.EnterKind  is null '
	
	if @CallType=3
		SET @StrSelect =  ' insert into #tblStores(EnterKind,StoreID,GoodsID,PSerialNo,ProductSerialID)	select a.EnterKind	,a.StoreID	,a.GoodsID	,a.PSerialNo,a.ProductSerialID '+ @StrSelect+' Where b.EnterKind  is null'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	update #tblStores
	set 	GoodsName=pub.funGetGoodsName (GoodsID,1) 
		,UnitID= [pub].[funGetGoodsUnitID] (GoodsID) 
		
	update #tblStores
	set 	UnitName=  inv.funGetUnitName(UnitID,1)  

	 if @CallType=1
		select Distinct StoreID	,GoodsID	,	GoodsName	,UnitID,	UnitName from #tblStores	
		order by StoreID	,GoodsID	,	GoodsName	,UnitID
	else
		select * from #tblStores	
		order by StoreID,GoodsID,GoodsName,UnitID,PSerialNo
end 
else 
begin

if @CallType=1
begin
	SET @StrSelect = 'select *
	from #tbl_RptStore_Numeration_Diff 
	--where SUBSTRING(GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ')  
		--IN (SELECT E.GoodsID FROM inv.tblGoods E WHERE E.HasSerial = 0 AND PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+  ') 
		'
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
end 

if @CallType=2
	begin
	
		SET @StrSelect1 = ' select GoodsID, sum(a.EnterKind ) EnterKind, a.StoreID,a.PSerialNo ,a.ContainerID	,a.NumberPerContainer,a.ContainerStoresID,a.ProductionDate,a.ExpireDate,a.ProductSerialID
								From (
									select  GoodsID, case when NumberPerContainer =0 then  a.EnterKind else NumberPerContainer* a.EnterKind end EnterKind, a.StoreID,a.PSerialNo ,a.ContainerID	,a.NumberPerContainer,a.ContainerStoresID,a.ProductionDate,a.ExpireDate,a.ProductSerialID
									from inv.tblStorageDocsSerials a				
										inner join inv.tblStorageDocsDtl b
										on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
									where 	a.StoreID = ''' + @StoreID + ''' 	'
		IF (@DocDateTo Is Not Null)
			SET @StrSelect1 += ' AND (b.DocDate <= ''' + @DocDateTo + ''') '	
			
			--SET @StrSelect1 +=' Union all 
			--						select  GoodsID, Case when a.ProcessID=188 then   1 else -1 end EnterKind , a.StoreID,a.PSerialNo ,a.ContainerID	,a.NumberPerContainer,a.ContainerStoresID,a.ProductionDate,a.ExpireDate,a.ProductSerialID
			--						from inv.tblStorageDocsSerials a				
			--							inner join  sal.tblSaleOrderDtl b
			--							on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
			--						where 	a.StoreID = ''' + @StoreID + ''' 	'
		IF (@DocDateTo Is Not Null)
			SET @StrSelect1 += ' AND (b.DocDate <= ''' + @DocDateTo + ''') '
									
		SET @StrSelect1 += ') a group by a.StoreID,a.PSerialNo ,GoodsID, a.ContainerID	,a.NumberPerContainer,a.ContainerStoresID,a.ProductionDate,a.ExpireDate,a.ProductSerialID
								having sum(a.EnterKind)>0 '

		select  1 TotalBalanceQty,  0 TotalEnumQty,GoodsID,CostCenterAcntCode,cast (''  as varchar(20))StoreID,UnitID, GoodsName,UnitName ,UserPriceID,UserPrice
					,0 ProcessID	,0 ProcessNo	,0 FiscalYear	,0 SerialNo	,0 DocRowNo	,0 AtomRowNo	,0 DocAtomRowNo	,cast (''  as varchar(20)) ProductSerialID	,0 EventNo	,BatchNo	, cast (''  as varchar(20)) PSerialNo	
					,cast (''  as varchar(20)) StoreID2	, 1 EnterKind	,0 NumberPerSerial	,cast (''  as varchar(20)) ContainerID	,0 NumberPerContainer	,cast (''  as varchar(20))  ContainerStoresID  ,cast (''  as char(10)) ProductionDate,cast (''  as char(10)) ExpireDate ,cast (''  as varchar(20)) SerialDesc	,cast (''  as varchar(20)) ContainerWeight	,cast (''  as varchar(20)) ContainerID2	,0 SerialGoodsWeight 
					Into #tbl_RptStore_Numeration_Diff2
					from #tbl_RptStore_Numeration_Diff 
					where 0=1
					
		SET @StrSelect = ' insert into #tbl_RptStore_Numeration_Diff2
			select  Distinct 1 TotalBalanceQty, 0 TotalEnumQty,b.GoodsID,CostCenterAcntCode, a.StoreID,c.UnitID, e.GoodsName,U2.UnitName ,UserPriceID,UserPrice
					,0 ProcessID	,0 ProcessNo	,0 FiscalYear	,0 SerialNo	,0 DocRowNo	,0 AtomRowNo	,0 DocAtomRowNo	,a.ProductSerialID	,0 EventNo	,a.BatchNo	,a.PSerialNo	
					,a.StoreID	,d.EnterKind	,0 NumberPerSerial	,d.ContainerID	,d.NumberPerContainer	,d.ContainerStoresID,d.ProductionDate,d.ExpireDate,a.SerialDesc	,a.ContainerWeight	,a.ContainerID2	,a.SerialGoodsWeight

				from inv.tblStorageDocsSerials a
				inner join inv.tblStorageDocsDtl b
					on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
						AND (b.GoodsID IN (SELECT E.GoodsID FROM inv.tblStoresNumerationDtl E WHERE E.SerialNo = '+ str(@SerialNo ) + ' )) 
						AND (b.GoodsID IN (SELECT GoodsID FROM #tbl_RptStore_Numeration_Diff where SUBSTRING(GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ')  
		IN (SELECT E.GoodsID FROM inv.tblGoods E WHERE ( E.HasSerial = 0 or E.HasContainer=1) AND PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+  ') ))
				inner join ('+ @StrSelect1 +')  d on d.PSerialNo=a.PSerialNo and d.StoreID=a.StoreID and d.GoodsID=b.GoodsID and d.ContainerID=a.ContainerID  and d.ContainerStoresID=a.ContainerStoresID 
				 and d.ProductionDate=a.ProductionDate  and d.ExpireDate=a.ExpireDate 
				inner join inv.tblGoods c on SUBSTRING(b.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ')=c.GoodsID  and ( c.HasSerial = 0 or c.HasContainer=1)  AND c.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+  '
				inner join inv.tblGoodsDtl e on e.GoodsID=c.GoodsID  and e.LanguageID=1 AND e.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+  '
				left  join inv.tblUnitsDtl U2 on U2.UnitID = c.UnitID AND U2.LanguageID =  1 
		where a.StoreID = ''' + @StoreID + ''' 	 
		'
		 IF (@DocDateTo Is Not Null)
			SET @StrSelect = @StrSelect + ' AND (b.DocDate <= ''' + @DocDateTo + ''')'
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;

		select * from #tbl_RptStore_Numeration_Diff2
		union all 
		select 1 TotalBalanceQty,  0 TotalEnumQty,GoodsID,CostCenterAcntCode,@StoreID StoreID,UnitID, GoodsName,UnitName ,UserPriceID,UserPrice
					,0 ProcessID	,0 ProcessNo	,0 FiscalYear	,0 SerialNo	,0 DocRowNo	,0 AtomRowNo	,0 DocAtomRowNo	,'' ProductSerialID	,0 EventNo	,BatchNo	, '' PSerialNo	
					,@StoreID StoreID	, 1 EnterKind	,0 NumberPerSerial	,'' ContainerID	,0 NumberPerContainer	,'' ContainerStoresID,'' ProductionDate,'' ExpireDate,'' SerialDesc	,'' ContainerWeight	,'' ContainerID2	,0  SerialGoodsWeight
		 from #tbl_RptStore_Numeration_Diff
		where GoodsID not in (select GoodsID from #tbl_RptStore_Numeration_Diff2) and  TotalEnumQty	 <	TotalBalanceQty
			and GoodsID in (select GoodsID FROM inv.tblGoods E WHERE ( E.HasSerial = 0 or E.HasContainer=1)) 
	END
if @CallType=3
	begin

		SET @StrSelect1 = ' select GoodsID,  sum(a.EnterKind ) EnterKind, a.StoreID,a.PSerialNo ,a.ContainerID	,a.NumberPerContainer,a.ContainerStoresID,a.ProductionDate,a.ExpireDate,a.ProductSerialID
								From (
									select  GoodsID,  case when NumberPerContainer =0 then  a.EnterKind else NumberPerContainer* a.EnterKind end EnterKind, a.StoreID,a.PSerialNo ,a.ContainerID	,a.NumberPerContainer,a.ContainerStoresID,a.ProductionDate,a.ExpireDate,a.ProductSerialID
									from inv.tblStoresNumerationSerials a				
										inner join inv.tblStoresNumerationDtl b
										on a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
									where 	a.StoreID = ''' + @StoreID + ''' 	'
		IF (@DocDateTo Is Not Null)
			SET @StrSelect1 += ' AND (b.DocDate <= ''' + @DocDateTo + ''') '				
								
		SET @StrSelect1 += ') a group by GoodsID, a.StoreID,a.PSerialNo ,a.ContainerID	,a.NumberPerContainer,a.ContainerStoresID,a.ProductionDate,a.ExpireDate,a.ProductSerialID
							 having sum(a.EnterKind)>0'

	select  1 TotalBalanceQty,  0 TotalEnumQty,GoodsID,CostCenterAcntCode,cast (''  as varchar(20))StoreID,UnitID, GoodsName,UnitName ,UserPriceID,UserPrice
					,0 ProcessID	,0 ProcessNo	,0 FiscalYear	,0 SerialNo	,0 DocRowNo	,0 AtomRowNo	,0 DocAtomRowNo	,cast (''  as varchar(20)) ProductSerialID	,0 EventNo	,BatchNo	, cast (''  as varchar(20)) PSerialNo	
					,cast (''  as varchar(20)) StoreID2	, 1 EnterKind	,0 NumberPerSerial	,cast (''  as varchar(20)) ContainerID	,0 NumberPerContainer	,cast (''  as varchar(20))  ContainerStoresID,cast (''  as char(10)) ProductionDate,cast (''  as char(10)) ExpireDate ,cast (''  as varchar(20)) SerialDesc	,cast (''  as varchar(20)) ContainerWeight	,cast (''  as varchar(20)) ContainerID2	,0 SerialGoodsWeight 
					Into #tbl_RptStore_Numeration_Diff3
					from #tbl_RptStore_Numeration_Diff 
					where 0=1

		SET @StrSelect =  '  insert into #tbl_RptStore_Numeration_Diff3
			select Distinct 0 TotalBalanceQty, 1 TotalEnumQty,b.GoodsID,CostCenterAcntCode, a.StoreID,c.UnitID, e.GoodsName,U2.UnitName ,UserPriceID,UserPrice
			, 0 ProcessID	, 0 ProcessNo	, 0 FiscalYear	,0 SerialNo	,0 DocRowNo	,0 AtomRowNo	,0 DocAtomRowNo	,a.ProductSerialID	,0 EventNo	,a.BatchNo	,a.PSerialNo	
			,a.StoreID	, d.EnterKind	,0 NumberPerSerial	,d.ContainerID	,d.NumberPerContainer,d.ContainerStoresID,d.ProductionDate,d.ExpireDate,a.SerialDesc	,a.ContainerWeight	,a.ContainerID	, 0 SerialGoodsWeight
			from inv.tblStoresNumerationSerials a 
			inner join inv.tblStoresNumerationDtl b on a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo 
			inner join ('+ @StrSelect1 +')  d on d.PSerialNo=a.PSerialNo and d.StoreID=a.StoreID  and d.GoodsID=b.GoodsID and d.ContainerID=a.ContainerID	and d.ContainerStoresID=a.ContainerStoresID				
			and d.ProductionDate=a.ProductionDate  and d.ExpireDate=a.ExpireDate 
				AND (b.GoodsID IN (SELECT GoodsID FROM #tbl_RptStore_Numeration_Diff  where SUBSTRING(GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ')  
		IN (SELECT E.GoodsID FROM inv.tblGoods E WHERE ( E.HasSerial = 0 or E.HasContainer=1)  AND PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+  ') ))
			inner join inv.tblGoods c on SUBSTRING(b.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ')=c.GoodsID  and ( c.HasSerial = 0 or c.HasContainer=1)  AND c.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+  '
			inner join inv.tblGoodsDtl e on e.GoodsID=c.GoodsID  and e.LanguageID=1 AND e.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+  '
			left  join inv.tblUnitsDtl U2 on U2.UnitID = c.UnitID AND U2.LanguageID =  1 
			where a.SerialNo='+ str(@SerialNo ) + '
			and a.StoreID = ''' + @StoreID + ''' 			
		 '
	 	 IF (@DocDateTo Is Not Null)
			SET @StrSelect = @StrSelect + ' AND (b.DocDate <= ''' + @DocDateTo + ''')'
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
		select * from #tbl_RptStore_Numeration_Diff3
		union all 
		select 1 TotalBalanceQty,  0 TotalEnumQty,GoodsID,CostCenterAcntCode,@StoreID StoreID,UnitID, GoodsName,UnitName ,UserPriceID,UserPrice
					,0 ProcessID	,0 ProcessNo	,0 FiscalYear	,0 SerialNo	,0 DocRowNo	,0 AtomRowNo	,0 DocAtomRowNo	,'' ProductSerialID	,0 EventNo	,BatchNo	, '' PSerialNo	
					,@StoreID StoreID	, 1 EnterKind	,0 NumberPerSerial	,'' ContainerID	,0 NumberPerContainer,'' ContainerStoresID,'' ProductionDate,'' ExpireDate ,'' SerialDesc	,'' ContainerWeight	,'' ContainerID2	,0 SerialGoodsWeight
		 from #tbl_RptStore_Numeration_Diff
		where GoodsID not in (select GoodsID from #tbl_RptStore_Numeration_Diff3) and  TotalEnumQty	 >	TotalBalanceQty
	END	
END	
end 

if @CallType=4
	begin

	SET @AllGoods		= Substring(@RepOptions, 12, 1)

		SELECT	D.GoodsID,
				D.BatchNo,
				D.UserPriceID,  
				ProductSerialID,
				PSerialNo,
				ContainerID,
				NumberPerContainer,
				ContainerStoresID,
				ProductionDate,
				A.ExpireDate,
				D.GoodsID GoodsID2,
				D.BatchNo BatchNo2,
				D.UserPriceID UserPriceID2,
				ProductSerialID ProductSerialID2,
				PSerialNo PSerialNo2 ,
				ContainerID ContainerID2,
				NumberPerContainer NumberPerContainer2, 
				ContainerStoresID ContainerStoresID2,
				ProductionDate ProductionDate2,
				A.ExpireDate ExpireDate2
		into #Serials
		FROM	inv.tblStorageDocsDtl D 
		inner join inv.tblStorageDocsSerials A
				on A.ProcessID=D.ProcessID and A.ProcessNo=D.ProcessNo and A.FiscalYear=D.FiscalYear and A.SerialNo=D.SerialNo and A.DocRowNo=D.DocRowNo
		where 1=0	

		SELECT	'موجودی'  SType,GoodsID,BatchNo,UserPriceID,  ProductSerialID	,PSerialNo ,ContainerID,NumberPerContainer,ContainerStoresID,ProductionDate,ExpireDate
		into #AllSerials
		FROM	#Serials	

	SET	@StrWhereSD =  ' (D.StoreID = ''' + @StoreID + ''') '

	IF @OtherFiscalYear = '0'
		SET @StrWhereSD = @StrWhereSD +' AND (D.FiscalYear = '+ ltrim(str(@FiscalYear)) +')'
	IF (@DocDateTo Is Not Null)
		SET @StrWhereSD = @StrWhereSD + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	IF (@AllGoods = 1)
		SET @StrWhereSD = @StrWhereSD + ' 
				AND (D.GoodsID IN (SELECT E.GoodsID FROM inv.tblStoresNumerationDtl E WHERE E.SerialNo = ' + @SerialNo + '))'

		SET @StrSelect =  ' insert into #Serials
		SELECT 
		isnull( GoodsID , '''') GoodsID,
		isnull( BatchNo, '''') BatchNo,
		isnull( UserPriceID, '''') UserPriceID,  
		isnull( ProductSerialID, '''') ProductSerialID,
		isnull( PSerialNo, '''') PSerialNo,
		isnull( ContainerID, '''') ContainerID,
		isnull( NumberPerContainer,0) NumberPerContainer,
		isnull( ContainerStoresID, '''') ContainerStoresID,
		isnull( ProductionDate, '''') ProductionDate,
		isnull( ExpireDate, '''') ExpireDate,
		isnull( GoodsID2 , '''') GoodsID2,
		isnull( BatchNo2, '''') BatchNo2,
		isnull( UserPriceID2, '''') UserPriceID2 ,
		isnull( ProductSerialID2, '''')ProductSerialID2,
		isnull( PSerialNo2, '''') PSerialNo2,
		isnull( ContainerID2, '''') ContainerID2,
		isnull( NumberPerContainer2,0) NumberPerContainer2,
		isnull( ContainerStoresID2, '''') ContainerStoresID2,
		isnull( ProductionDate2, '''') ProductionDate2,
		isnull( ExpireDate2, '''') ExpireDate2
		FROM  
			(
				SELECT GoodsID,
					   BatchNo,
					   UserPriceID,
					   ProductSerialID,
					   PSerialNo,
					   ContainerID,
					   Sum(NumberPerContainer*EnterKind) NumberPerContainer, 
					   ContainerStoresID,
					   ProductionDate,
					   ExpireDate 
				FROM (
				SELECT isnull( D.GoodsID , '''') GoodsID ,
					   D.BatchNo,
					   D.UserPriceID, 
					   ProductSerialID,
					   PSerialNo,
					   A.EnterKind,
					   ContainerID,
					   NumberPerContainer,
					   ContainerStoresID,
					   ProductionDate,
					   A.ExpireDate
				FROM inv.tblStorageDocsDtl D 
				INNER JOIN inv.tblStorageDocsSerials A
					  ON A.ProcessID=D.ProcessID AND A.ProcessNo=D.ProcessNo AND A.FiscalYear=D.FiscalYear AND A.SerialNo=D.SerialNo AND A.DocRowNo=D.DocRowNo
				WHERE	 '+ @StrWhereSD +'				 
				) a 

				GROUP BY GoodsID,BatchNo,UserPriceID,ProductSerialID	,PSerialNo,ContainerID,ContainerStoresID,ProductionDate,ExpireDate
				having Sum(EnterKind*NumberPerContainer)<>0

			)a  
			FULL OUTER JOIN 
			(
				SELECT isnull( D.GoodsID , '''') GoodsID2,
					   D.BatchNo BatchNo2,
					   D.UserPriceID UserPriceID2,
					   ProductSerialID ProductSerialID2,
					   PSerialNo PSerialNo2,
					   ContainerID ContainerID2,
					   NumberPerContainer NumberPerContainer2,
					   ContainerStoresID ContainerStoresID2 ,
					   ProductionDate ProductionDate2,
					   ExpireDate ExpireDate2 
				FROM inv.tblStoresNumerationDtl D
				INNER JOIN inv.tblStoresNumerationSerials A ON A.SerialNo=D.SerialNo AND A.DocRowNo=D.DocRowNo 
				WHERE D.SerialNo = '+ str(@SerialNo ) + '
				GROUP BY D.GoodsID,D.BatchNo,D.UserPriceID ,ProductSerialID	,PSerialNo,ContainerID,NumberPerContainer,ContainerStoresID,ProductionDate,ExpireDate
			) b on a.GoodsID=b.GoodsID2
			and a.PSerialNo=b.PSerialNo2
			and a.ContainerID=b.ContainerID2
			and a.ContainerStoresID=b.ContainerStoresID2
			where a.GoodsID is null  or b.GoodsID2 is null
			or NumberPerContainer<>NumberPerContainer2
		 '

		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;

		insert into #AllSerials
		select 	'موجودی',GoodsID,BatchNo,UserPriceID,  ProductSerialID	,PSerialNo ,ContainerID,NumberPerContainer,ContainerStoresID,ProductionDate,ExpireDate
		FROM	#Serials
		where GoodsID <>''

		insert into #AllSerials
		select 	'شمارش',GoodsID2,BatchNo2,UserPriceID2,  ProductSerialID2	,PSerialNo2 ,ContainerID2,NumberPerContainer2,ContainerStoresID2,ProductionDate2,ExpireDate2
		FROM	#Serials
		where GoodsID2<>''

		select a.SType,a.GoodsID,GoodsName 	,a.BatchNo	,a.UserPriceID	,a.ProductSerialID	,a.PSerialNo	,a.ContainerID,a.NumberPerContainer,ContainerStoresID,ProductionDate,ExpireDate
		, inv.funGetContainerStoresName(ContainerStoresID,1) ContainerStoresName
		from #AllSerials a
		left join inv.tblGoodsDtl g on a.GoodsID=g.GoodsID and g.LanguageID=1
		order by a.GoodsID,a.SType

	END	
END
GO
