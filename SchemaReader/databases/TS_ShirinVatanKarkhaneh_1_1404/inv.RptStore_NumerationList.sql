USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386
-- Viewed By	 : 
-- Last Modified : 1392/01/25
-- Last Modifier : TakroSystem\ziA
-- Description   : <Store Stock>
-- ==============================================
Create PROCEDURE [inv].[RptStore_NumerationList]
	@SelectedStore			Int = 0,
	@SelectedGoods			Int = 0,
	@DocDateFr				Char(10) = Null,
	@DocDateTo				Char(10) = Null,
	@IncludeQuantity		Bit = 1, -- شامل ستون مقدار
	@IncludePrice			Bit = 1, -- شامل ستون قیمت
	@IncludePrim			Bit = 1, -- شامل ستون اول دوره
	@IncludeInput			Bit = 1, -- شامل ستون ورود
	@IncludeOutput			Bit = 1, -- شامل ستون خروج
	@IncludeGroup			Bit = 1, -- شامل ستون گروه
	@IncludePackage			Bit = 1, -- شامل کالاهای بدون گردش
	@IncludeTechnical		Bit = 1, -- شامل ستون اطلاعات تکنیکی
	@IncludePlace			Bit = 0, -- مانده ریالی برای کالاهای با موجودی صفر نیز محاسبه شود 
	@IncludeZeroAmount	 	Bit = 1, -- شامل ردیفهای بدون قیمت
	@IncludeZeroQuantity	Bit = 1, -- شامل کالاهای با موجودی صفر یا کمتر
	@GroupByStore			Bit = 1, -- به تفکیک انبار
	@PhysicallyEffected		Bit = 1, 
	@ValueRanges			NVarChar(2000) = Null, -- فیلتر مقادیر
	@SortFields				NVarChar(100) = Null,
	@RepInfo				NVarChar(100) = '1@1@1@1@1',
	@RepOptions				VarChar(10) = ''

WITH ENCRYPTION
AS 

---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @AllGoods	NVarChar(4000);
DECLARE @StrGroup	NVarChar(2000);
DECLARE @StrStore	NVarChar(2000);
DECLARE @StrHaving	NVarChar(2000);
DECLARE @StrYear	Char(4);
DECLARE @StrGoods	NVarChar(1000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

DECLARE @DateField	nvarchar(20);

DECLARE	@WithGroups bit;
DECLARE	@StoreID	VarChar(20)
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--========================
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

	-- Init Variables ----------------------------------------------------------
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;
	IF (@RepOptions Is Null)	SET @RepOptions = '10';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);
	SET @StoreID	= pub.funSplitString(@RepInfo, '@', 6);
	
	SET @StrYear = LTrim(RIGHT(db_name(), 4));

	SET @WithGroups	= Substring(@RepOptions, 1, 1);

	----------------------------------------------------------------------------------
	begin try
		drop table #tbl_RptStore_Stock_Prices
	end try
	begin catch
	end catch
	
	create table #tbl_RptStore_Stock_Prices
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		BuyPrice float not null
	);

	insert into #tbl_RptStore_Stock_Prices
	select *
	from 
	(
		select distinct GoodsID, 
			(
				select top 1 GoodsPrice
				from inv.tblStorageDocsDtl D 
				where (D.GoodsID = M.GoodsID) and (D.ProcessID = 55)
				order by DocDate DESC, VolumeRowNo DESC
			) BuyPrice
		from inv.tblStorageDocsDtl M
	) T 
	where BuyPrice is not null

	update #tbl_RptStore_Stock_Prices
	set BuyPrice = GoodsPrice
	from inv.tblGoods
	where SUBSTRING(#tbl_RptStore_Stock_Prices.GoodsID,@str_Goods+1,@str_GoodsSum) = inv.tblGoods.GoodsID 
		and #tbl_RptStore_Stock_Prices.BuyPrice = 0

	Declare @intIsMultiGoods AS Tinyint
	SET @intIsMultiGoods = 0
	
	Select @intIsMultiGoods = Layer1 
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 2 
	
	IF @intIsMultiGoods > 0 And @intIsMultiGoods < 20
		insert into #tbl_RptStore_Stock_Prices(GoodsID, BuyPrice)
		select GoodsID, GoodsPrice
		from inv.tblGoods
		where GoodsID not in (select GoodsID from #tbl_RptStore_Stock_Prices)
	----------------------------------------------------------------------------
	-- Where Clause ------------------------------------------------------------
	if (@IncludePrice = 1)
		--set @DateField = 'VchDate2'
		set @DateField = 'DocDate'
	else
		set @DateField = 'DocDate'

	SET @StrWhere = '(D.FiscalYear = ' + @StrYear + ')';

	If (@PhysicallyEffected Is Not Null)
		If (@PhysicallyEffected = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
		Else
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'

	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.' + LTrim(@DateField) + ' <= ''' + @DocDateTo + ''')'

	If (@IncludeZeroAmount = 0)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsAmount <> 0)'

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	If (not @StoreID is null and @StoreID<>'')
		SET @StrWhere = @StrWhere + ' AND D.StoreID=''' + @StoreID+ '''' 		
		
	----------------------------------------------------------------------------------
	
	IF (@WithGroups = 0)
		SET @StrGoods = '(SELECT * FROM inv.tblGoods a WHERE (SELECT COUNT(*) FROM inv.tblGoods b WHERE SubString(b.GoodsID,1,LEN(a.GoodsID)) = a.GoodsID ) = 1)'
	ELSE
		SET @StrGoods = 'inv.tblGoods'
		
	IF (@IncludePackage = 1)
	BEGIN
		SET @AllGoods = ' 
			union all 
			select	50 ProcessID, ' + @StrYear + ' FiscalYear, ''0000/00/00'' DocDate, S.StoreID, 
					G.GoodsID, '''' BatchNo, 0 GoodsQuantity, 0 GoodsAmount, 0 EnterKind, 0 PhysicallyEffected,0 SubUnitQuantity
			from	inv.tblStores S
						cross join ' + @StrGoods + ' G
			where  (StoreID <> '''') and (GoodsID <> '''')'
			
	If (@SelectedStore > 0)
		SET @AllGoods = @AllGoods + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'S.StoreID') 

	END
	ELSE
		SET @AllGoods = ''
	----------------------------------------------------------------------------------------------------------
	IF (@GroupByStore = 1)
	begin
		SET @StrGroup = 'D.StoreID, D.GoodsID, D.BatchNo'
		set @StrStore = 'D.StoreID'
	end
	Else
	begin
		SET @StrGroup = 'D.GoodsID, D.BatchNo'
		set @StrStore = 'Cast(''-'' AS VarChar(20))'
	end

	-- Select Clause -----------------------------------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.GoodsID, D.BatchNo, ' + ltrim(@StrStore) + ' StoreID,' + 
			CASE WHEN (@DocDateFr Is Not Null) THEN '
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + ''' THEN D.EnterKind * D.GoodsQuantity ELSE 0 END),0) AS TotalQuantityPrim, 
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantityInput,
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantityOutput, 
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + ''' THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPricePrim,
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPriceInput,
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPriceOutput,
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + ''' THEN D.EnterKind * D.SubUnitQuantity ELSE 0 END),0) AS TotalSubQuantityPrim, 
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 THEN D.SubUnitQuantity ELSE 0 END),0) AS TotalSubQuantityInput,
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 THEN D.SubUnitQuantity ELSE 0 END),0) AS TotalSubQuantityOutput '
			ELSE '
			isnull(SUM(CASE WHEN D.ProcessID =  50 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantityPrim, 
			isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantityInput,
			isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantityOutput, 
			isnull(SUM(CASE WHEN D.ProcessID =  50 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPricePrim,
			isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPriceInput,
			isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPriceOutput, 
			isnull(SUM(CASE WHEN D.ProcessID =  50 THEN D.SubUnitQuantity ELSE 0 END),0) AS TotalSubQuantityPrim, 
			isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.SubUnitQuantity ELSE 0 END),0) AS TotalSubQuantityInput,
			isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.SubUnitQuantity ELSE 0 END),0) AS TotalSubQuantityOutput '
			END + ' 
			
	INTO ##tbl_Store_Stock
	FROM
		(
			Select ProcessID, FiscalYear, DocDate, StoreID, GoodsID, BatchNo, GoodsQuantity, GoodsAmount, EnterKind, 
				   PhysicallyEffected , SubUnitQuantity  
			From inv.tblStorageDocsDtl ' + @AllGoods + ' 
		) D
	LEFT JOIN inv.tblGoods GH ON GH.GoodsID =SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	WHERE	' + @StrWhere + '
	GROUP BY ' + @StrGroup

	-------------------------------------------------------------------------------------------------------------

	-- Having Clause ------------------------------------------------------------------------------------------
	IF (@IncludeZeroQuantity = 0) 
	Begin
		IF (@StrSelect <> '') 
		
			SET @StrSelect = @StrSelect + 
				CASE WHEN (@DocDateFr Is Not Null) THEN 
					' HAVING SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr + ''' THEN D.GoodsQuantity * D.EnterKind ELSE 0 END) +
							 SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) -
							 SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) > 0 '
				ELSE + ' HAVING SUM(D.GoodsQuantity*D.EnterKind) > 0 ' 
				END   
	End


	begin try
		drop table ##tbl_Store_Stock
	end try
	begin catch
	end catch
	
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;

	if (@UserIsAdmin = 0)
	begin
		exec pub.SpFilterByPermission2 '##tbl_Store_Stock', 'StoreID', 'inv.tblStores', @UserID;
		exec pub.SpFilterByPermission2 '##tbl_Store_Stock', 'GoodsID', 'inv.tblGoods', @UserID;
	end
	
	set @StrSelect = '
	SELECT D.*, 
		   [inv].[funGetBatchName](D.BatchNo,' + LTrim(RTrim(@LangID)) + ') BatchNameDtl, 
		   P.BuyPrice LastBuyPrice, 
		   [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, 
		   IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, 
		   UD.UnitName,
		   CASE WHEN  UDS.GoodsID IS NULL THEN UD.UnitID ELSE UDS.SubUnitID END SubUnitID,
		   ISNULL(U2.UnitName,'''') SubUnitName,
		   GH.TechnicalSpecifications TechInfo,
		   GR.GoodsGroupName GroupName, 
		   S.StoreName, 
		   Cast(''-'' AS NVarChar(50)) PackageInfo, 
		   Cast(''-'' AS NVarChar(50)) PlaceName,
		   isnull(GH.TechnicalNo,'''') TechnicalNo
	FROM ##tbl_Store_Stock D
		 LEFT JOIN #tbl_RptStore_Stock_Prices P on P.GoodsID = D.GoodsID
		 LEFT JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		 LEFT JOIN inv.tblUnitsDtl UD ON UD.UnitID = GH.UnitID 			
		 LEFT JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID 
		 LEFT JOIN inv.tblSubUnitsDtl UDS ON D.GoodsID=UDS.GoodsID AND UDS.ShowInInvoice=''True''
		 LEFT JOIN inv.tblUnitsDtl U2 on U2.UnitID = UDS.SubUnitID AND U2.LanguageID =  1 
		 LEFT JOIN (Select * 
					   FROM 
					   (
							SELECT *, ROW_NUMBER()over(Partition by GoodsID ORDER BY GoodsGroupID, GoodsID) r
							FROM inv.tblGoodsGroupsGoodsListDtl
						) b
					   WHERE b.r = 1) GL ON GL.GoodsID = D.GoodsID
		 LEFT JOIN inv.tblGoodsGroupsDtl GR ON GR.GoodsGroupID = GL.GoodsGroupID '
				
	--------------------------------------------------------------
	If (@ValueRanges Is Not Null) 
	SET @StrSelect = '
	SELECT TOTAL.*
	FROM
	(' + @StrSelect + ') TOTAL
	WHERE ' + @ValueRanges	
				
	-- Sort Clause ---------------------------------------------
	If (@SortFields Is Not Null) AND (@SortFields <> '') 
		SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;

	------------------------------------------------------------
END
GO
