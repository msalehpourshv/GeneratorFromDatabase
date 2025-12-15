USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386
-- Viewed By	 : 
-- Last Modified : 1394/11/18
-- Last Modifier : TakroSystem\ZiA
-- Description   : <Store Stock>
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Stock_Sale]
	@SelectedStore			Int = 0,
	@SelectedGoods			Int = 0,
	@DocDateFr				Char(10) = Null,
	@DocDateTo				Char(10) = Null,
	@IncludeQuantity		Bit = 1, -- شامل ستون مقدار
	@IncludePrice			Bit = 1, -- شامل ستون ق?مت1395/02/20
	@IncludePrim			Bit = 1, -- شامل ستون اول دوره
	@IncludeInput			Bit = 1, -- شامل ستون ورود
	@IncludeOutput			Bit = 1, -- شامل ستون خروج
	@IncludeGroup			Bit = 1, -- شامل ستون گروه
	@IncludeNoCurrent		Bit = 1, -- شامل کالاها? بدون گردش
	@IncludeTechnical		Bit = 1, -- شامل ستون اطلاعات تکن?ک?
	@AmountWithoutQty		Bit = 0, -- مانده ر?ال? برا? کالاها? با موجود? صفر ن?ز محاسبه شود 
	@IncludeZeroAmount		Bit = 1, -- شامل رد?فها? بدون ق?مت
	@IncludeZeroQuantity	Bit = 1, -- شامل کالاها? با موجود? صفر ?ا کمتر
	@GroupByStore			Bit = 1, -- به تفک?ک انبار
	@PhysicallyEffected		Bit = 1, 
	@UseLastBuyAmount		Bit = 1, 
	@UseSecondUnit			Bit = 0, 
	@ValueRanges			NVarChar(2000) = Null, -- ف?لتر مقاد?ر
	@SortFields				NVarChar(100) = Null,
	@RepInfo				NVarChar(100) = '1@1@1@1@1',
	@ExtraParams			NVarChar(200) = Null
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect			NVarChar(max);
DECLARE @StrFrom			NVarChar(max);
DECLARE @StrWhere			NVarChar(max);
DECLARE @StrWhrSale			NVarChar(max);
DECLARE @StrWhereAvg		NVarChar(max);
DECLARE @AllGoods			NVarChar(4000);
DECLARE @StrGroup			NVarChar(2000);
DECLARE @StrStore			NVarChar(2000);
DECLARE @StrHaving			NVarChar(2000);
DECLARE @StrAmount			NVarChar(4000);
DECLARE @StrYear			Char(4);
Declare @GoodsAmount		VarChar(20);
Declare @LastCalc			Char(10);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int;
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		Bit;

DECLARE @DateField			NVarchar(20);
declare @GoodsIDField		varchar(200);
declare @UnitNameField		varchar(200);
declare @GoodsNameField		varchar(200);
DECLARE @GroupByLayer		Bit;
	
DECLARE @DrugSetID			VarChar(20);
DECLARE @DrugKindID			VarChar(20);
DECLARE @UseLastSalAmount	Bit;

DECLARE	@HasSerial			Bit;
DECLARE	@FromExpireDate		Varchar(10);
DECLARE	@ToExpireDate		Varchar(10);
DECLARE	@IsReservedGoods	bit;
DECLARE	@JustPermit			bit;
DECLARE @LayerLen			int;
DECLARE @GoodsPart			int;
DECLARE	@SuspendedTransferGoods	Bit;
DECLARE @GoodsClassificationID	VarChar(20);

DECLARE @RptFiscalYear	Int;

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

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

	SET @StrYear = LTrim(RIGHT(db_name(), 4));
	SET @GoodsAmount = LTRIM(inv.funGoodsAmount(@DocDateTo))

	SET @DrugSetID				= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @DrugKindID				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @UseLastSalAmount		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @HasSerial				= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @FromExpireDate			= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @ToExpireDate			= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @IsReservedGoods		= LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @JustPermit				= LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @SuspendedTransferGoods	= LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @GoodsClassificationID	= LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	SET @GroupByLayer			= LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	SET @LayerLen				= LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	SET @GoodsPart				= LTrim(pub.funSplitString(@ExtraParams, '@', 13));
	SET @RptFiscalYear			= LTrim(pub.funSplitString(@ExtraParams, '@', 14));
		
	if (@LayerLen = 0) set @LayerLen = 20;		
	----------------------------------------------------------------------------------
	set @LastCalc = ''
	
	select @LastCalc = IsNull(Max(ToDate), '')
	from inv.tblStorageCosts
	
	begin try
		drop table #tbl_RptStore_Stock_Prices
		drop table #tbl_RptStore_Stock_Prices2
	end try
	begin catch
	end catch

	begin try
		drop table ##tbl_Store_Stock
	end try
	begin catch
	end catch
	
	begin try
		drop table ##tbl_Reserved_Goods
	end try
	begin catch
	end catch
	
	begin try
		drop table ##tbl_Reserved_Temp
	end try
	begin catch
	end catch

	create table #tbl_RptStore_Stock_Prices
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		BuyPrice float not null
	);
	
	create table #tbl_RptStore_Stock_Prices2
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		SalPrice float not null
	);

	
	create table ##tbl_Reserved_Goods
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		ReservedQty float not null
	);
	
	create table ##tbl_Reserved_Temp
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		ProcessID int not null,
		ProcessNo int not null,
		FiscalYear int not null,
		SerialNo int not null,
		Quantity float not null,
		GoodsName nvarchar(100) collate arabic_cs_as not null,
		UnitNmae  nvarchar(100) collate arabic_cs_as  ,
		ProduceStepName  nvarchar(100) collate arabic_cs_as not null,
		Title  nvarchar(100) collate arabic_cs_as not null,
		DocDate  char(10) collate arabic_cs_as not null
	);
	
	create table #tbl_Orders
	(
		OGoodsID	varchar(20) collate Arabic_CS_AS null,
		OrderQty	float
	);	
	
	-- رزرو کالا ####################
	if @IsReservedGoods=1
	begin
		insert into ##tbl_Reserved_Temp
		exec [pln].[RptPln_ProduceOrder_Reserves]
		
		insert into ##tbl_Reserved_Goods
		select GoodsID, SUM(Quantity)
		from ##tbl_Reserved_Temp
		Group by GoodsID
	 end
	--###############################
	
	if (@GroupByLayer = 0)
	begin
		insert into #tbl_RptStore_Stock_Prices (GoodsID, BuyPrice)
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
		
		insert into #tbl_RptStore_Stock_Prices2 (GoodsID, SalPrice)
		select *
		from 
		(
			select distinct GoodsID, 
				IsNull((
					select top 1 SalePrice 
					FROM sal.tblGoodsPricesDtl P 
					WHERE P.DefaultSalePriceTypeID=1 and P.GoodsID=M.GoodsID
				),0) SalPrice		
			from inv.tblStorageDocsDtl M
		) T 
		
		update #tbl_RptStore_Stock_Prices
		set BuyPrice = GoodsPrice
		from inv.tblGoods
		where #tbl_RptStore_Stock_Prices.GoodsID = inv.tblGoods.GoodsID 
			and #tbl_RptStore_Stock_Prices.BuyPrice = 0
			
		update #tbl_RptStore_Stock_Prices2
		set SalPrice = GoodsPrice
		from inv.tblGoods
		where #tbl_RptStore_Stock_Prices2.GoodsID = inv.tblGoods.GoodsID 
			and #tbl_RptStore_Stock_Prices2.SalPrice = 0		

		insert into #tbl_RptStore_Stock_Prices(GoodsID, BuyPrice)
		select GoodsID, GoodsPrice
		from inv.tblGoods
		where GoodsID not in (select GoodsID from #tbl_RptStore_Stock_Prices)
		
		-- مانده سفارشات
		insert #tbl_Orders(OGoodsID, OrderQty)
		SELECT	GoodsID, Sum(GoodsQuantity-CancelQuantity) - Sum(SoldQuantity-SoldRetQuantity) 
		FROM
		(
			SELECT	D.GoodsID, (D.GoodsQuantity) GoodsQuantity,
					isnull((
						SELECT	Sum(C.GoodsQuantity)
						FROM	sal.tblSaleOrderDtl C
						WHERE	(C.BaseProcessID=D.ProcessID)
							AND (C.BaseProcessNo=D.ProcessNo)
							AND (C.BaseFiscalYear=D.FiscalYear)
							AND (C.BaseSerialNo=D.SerialNo)
							AND (C.BaseDocRowNo=D.DocRowNo)
							AND (C.ProcessID=185)
					),0) CancelQuantity,
					isnull((
						SELECT	sum(GoodsQuantity) 
						FROM	inv.tblStorageDocsDtl SD
						WHERE	(SD.ProcessID=90)
							AND SD.BaseProcessID=D.ProcessID 
							AND SD.BaseProcessNo=D.ProcessNo 
							AND SD.BaseFiscalYear=D.FiscalYear 
							AND SD.BaseSerialNo=D.SerialNo 
							AND SD.BaseDocRowNo=D.DocRowNo
					),0) SoldQuantity, 0 SoldRetQuantity
			FROM    sal.tblSaleOrderDtl AS D
						INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			WHERE   (D.ProcessID=180)
		) T  
		where (GoodsQuantity-CancelQuantity)-(SoldQuantity-SoldRetQuantity) > 0
		group by GoodsID
	end
	----------------------------------------------------------------------------
	-- Where Clause ------------------------------------------------------------
	if (@IncludePrice = 1)
		--set @DateField = 'VchDate2'
		set @DateField = 'DocDate'
	else
		set @DateField = 'DocDate'
	
	SET	@StrWhrSale = ''
	declare @GoodsPartLen int;
	
	select @GoodsPartLen = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' and PartNumber=1

	SET @StrWhere = '(D.FiscalYear = ' + @StrYear + ') And left(D.GoodsID,' + str(@GoodsPartLen) + ') IN (Select GoodsID From inv.tblGoods Where IsService = 0)';
	SET @StrWhereAvg = @StrWhere;
	
	--If (@PhysicallyEffected Is Not Null)
	--	If (@PhysicallyEffected = 1) 
	--		SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
	--	Else If (@PhysicallyEffected = 0) 
	--		SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'	

	If (@PhysicallyEffected Is Not Null)
		If (@PhysicallyEffected = 1 And @JustPermit = 0) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
		Else If (@PhysicallyEffected = 1 And @JustPermit = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'
		Else If (@PhysicallyEffected = 0 And @JustPermit = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'			
	
	If (@DocDateTo Is Not Null)
	BEGIN
		SET @StrWhere = @StrWhere + ' AND (D.' + LTrim(@DateField) + ' <= ''' + @DocDateTo + ''')'
		SET @StrWhrSale = @StrWhrSale + ' AND (DocDate <= ''' + @DocDateTo + ''')'
	END		
	If (@DocDateFr Is Not Null)
	BEGIN
		SET @StrWhereAvg = @StrWhereAvg + ' AND D.DocDate >= ''' + @DocDateFr + ''''
		SET @StrWhrSale = @StrWhrSale + ' AND DocDate >= ''' + @DocDateFr + ''''
	END		

	If (@IncludeZeroAmount = 0)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsAmount <> 0)'

	If (@SelectedGoods > 0)
	begin
		SET @StrWhere	 = @StrWhere	+ ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		SET @StrWhereAvg = @StrWhereAvg + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	end
	
	If (@SelectedStore > 0)
	BEGIN
		SET @StrWhere	 = @StrWhere	+ ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhereAvg = @StrWhereAvg + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	END

	if (@DrugSetID <> '')
		Set @StrWhere = @StrWhere + ' AND GH.DrugSetID = ''' + @DrugSetID + ''''

	if (@DrugKindID <> '')
		Set @StrWhere = @StrWhere + ' AND GH.DrugKindID = ''' + @DrugKindID + ''''
		
	if (@GoodsClassificationID Is Not Null And @GoodsClassificationID <> '')
		Set @StrWhere = @StrWhere + ' AND GH.GoodsClassificationID = ''' + @GoodsClassificationID + ''''		
		
	----------------------------------------------------------------------------------
	if (@IncludeNoCurrent = 1)
		set @AllGoods = ' 
			UNION ALL 
			SELECT	50 ProcessID, ' + @StrYear + ' FiscalYear, ''0000/00/00'' DocDate, S.StoreID, 
					G.GoodsID, 0 GoodsQuantity, 0 SubUnitQuantity, 0 GoodsAmount, 0 EnterKind, 0 PhysicallyEffected,G.UnitID SubUnitID,0 DiscountDtl,0 GoodsPrice
			FROM	inv.tblStores S
						cross join inv.tblGoods G
			WHERE  (StoreID <> '''') and (GoodsID <> '''')'
	else
		set @AllGoods = ''
	----------------------------------------------------------------------------------------------------------
	IF (@GroupByStore = 1)
	begin
		SET @StrGroup = 'D.StoreID, D.GoodsID, GH.UnitID'
		set @StrStore = 'D.StoreID'
	end
	Else
	begin
		SET @StrGroup = 'D.GoodsID, GH.UnitID'
		set @StrStore = 'Cast(''-'' AS VarChar(20))'
	end

	-- آخرین قیمت خرید
	if (@UseLastBuyAmount = 1)
		set @StrAmount = 'ISNULL((SELECT BuyPrice FROM #tbl_RptStore_Stock_Prices P WHERE P.GoodsID=D1.GoodsID),0) AS GoodsAmount'
	
	-- آخرین قیمت فروش
	if (@UseLastSalAmount = 1)
		set @StrAmount = 'ISNULL((SELECT SalPrice FROM #tbl_RptStore_Stock_Prices2 P WHERE P.GoodsID=D1.GoodsID),0) AS GoodsAmount'
				
	if (@UseLastBuyAmount = 0) AND (@UseLastSalAmount = 0)
		set @StrAmount = @GoodsAmount + ' AS GoodsAmount'
		
	if (@GroupByLayer = 1)
		set @GoodsIDField = 'Left(D1.GoodsID, ' + str(@LayerLen) + ') GoodsID'
	else
		set @GoodsIDField = 'D1.GoodsID'
		
	DECLARE @strQuantity varchar(400)='D.GoodsQuantity'			
	if (@UseSecondUnit=1)
		SET @strQuantity= ' CASE WHEN SU.SubUnitID IS NULL THEN D.GoodsQuantity WHEN SU.SubUnitID<>D.SubUnitID THEN D.GoodsQuantity * SU.UnitValue / SU.MainUnitValue ELSE SubUnitQuantity END '

				
	-- Select Clause -----------------------------------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.GoodsID, ' + ltrim(@StrStore) + ' StoreID,' + 
			CASE WHEN (@DocDateTo Is Not Null) THEN '
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <=  ''' + @DocDateTo  + ''' THEN D.EnterKind * ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityToPrim, '
			ELSE
			'isnull(SUM(D.EnterKind * ' + @strQuantity + ' ),0) AS TotalQuantityToPrim, '
			END +
			CASE WHEN (@DocDateFr Is Not Null) THEN '
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + ''' THEN D.EnterKind * ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityPrim, 
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityInput,
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityOutput, 
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + ''' THEN D.GoodsQuantity * D.GoodsAmount * D.EnterKind  ELSE 0 END),0) AS TotalPricePrim,
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPriceInput,
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPriceOutput,
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 90 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale,
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 100 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale_Ret, 
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 90 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantitySale, 
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 100 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantitySale_Ret,
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 90 THEN D.DiscountDtl ELSE 0 END),0) AS TotalDiscountSale, 
			isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 100 THEN D.DiscountDtl ELSE 0 END),0) AS TotalDiscountSale_Ret'
			ELSE '
			isnull(SUM(CASE WHEN D.ProcessID =  50 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityPrim, 
			isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityInput,
			isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityOutput, 
			isnull(SUM(CASE WHEN D.ProcessID =  50 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPricePrim,
			isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPriceInput,
			isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPriceOutput ,
			isnull(SUM(CASE WHEN D.ProcessID = 90 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale,
			isnull(SUM(CASE WHEN D.ProcessID = 100 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale_Ret, 
			isnull(SUM(CASE WHEN D.ProcessID = 90 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantitySale, 
			isnull(SUM(CASE WHEN D.ProcessID = 100 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantitySale_Ret,
			isnull(SUM(CASE WHEN D.ProcessID = 90 THEN D.DiscountDtl ELSE 0 END),0) AS TotalDiscountSale, 
			isnull(SUM(CASE WHEN D.ProcessID = 100 THEN D.DiscountDtl ELSE 0 END),0) AS TotalDiscountSale_Ret'
			END + ', GH.UnitID
	INTO ##tbl_Store_Stock
	FROM
		(
			SELECT D1.ProcessID, D1.FiscalYear, D1.DocDate, D1.StoreID, ' + ltrim(@GoodsIDField) + ', D1.GoodsQuantity, D1.SubUnitQuantity, ' + @StrAmount + ', 
				   D1.EnterKind, D1.PhysicallyEffected ,D1.SubUnitID ,D1.DiscountDtl,D1.GoodsPrice
			FROM inv.tblStorageDocsDtl D1 ' + @AllGoods + '
		) D
		INNER JOIN (SELECT DISTINCT GoodsID from  inv.tblStorageDocsDtl WHERE 1=1 ' + @StrWhrSale + ') DD1 ON DD1.GoodsID=D.GoodsID 
		LEFT JOIN inv.tblGoods GH ON GH.GoodsID = D.GoodsID and GH.PartNumber = ' + str(@GoodsPart) + '
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = D.GoodsID AND SU.ShowInInvoice = 1 and GH.PartNumber = ' + str(@GoodsPart) + '
	WHERE	' + @StrWhere + '
	GROUP BY ' + @StrGroup
	-------------------------------------------------------------------------------------------------------------

	-- Having Clause ------------------------------------------------------------------------------------------
	IF (@IncludeZeroQuantity = 0) 
	Begin
		IF (@StrSelect <> '') 
		
			SET @StrSelect = @StrSelect + 
				CASE WHEN (@DocDateFr Is Not Null) THEN 
					' HAVING SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr + ''' THEN ' + @strQuantity + ' * D.EnterKind ELSE 0 END) +
							 SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr + ''' AND D.EnterKind = +1 THEN ' + @strQuantity + ' ELSE 0 END) -
							 SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr + ''' AND D.EnterKind = -1 THEN ' + @strQuantity + ' ELSE 0 END) > 0 '
				ELSE + ' HAVING SUM(' + @strQuantity + '*D.EnterKind) > 0 ' 
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
	
	if (@UseSecondUnit=1)
		update ##tbl_Store_Stock 
		set 
			--TotalQuantityPrim = TotalQuantityPrim * SU.UnitValue / SU.MainUnitValue,
			--TotalQuantityInput = TotalQuantityInput * SU.UnitValue / SU.MainUnitValue,
			--TotalQuantityOutput = TotalQuantityOutput * SU.UnitValue / SU.MainUnitValue,
			UnitID = SU.SubUnitID
			from ##tbl_Store_Stock
				left join 
				(
					select GoodsID, SubUnitID, UnitValue, MainUnitValue
					from inv.tblSubUnitsDtl
					where ShowInInvoice = 1 
				) SU on SU.GoodsID = ##tbl_Store_Stock.GoodsID
		where SU.UnitValue is not null
		
	-- ==== AGV Input Output ========================================	
		
	create table #tbl_Store_Stock_AVG_IN (
		GoodsID varchar(20) collate arabic_cs_as not null,
		StoreID varchar(20) collate arabic_cs_as not null,
		Quantity float not null		
	)
	create table #tbl_Store_Stock_AVG_OUT (
		GoodsID varchar(20) collate arabic_cs_as not null,
		StoreID varchar(20) collate arabic_cs_as not null,
		Quantity float not null		
	)	
	
	IF (@GroupByStore = 1)
	begin
		SET @StrGroup = 'D.GoodsID, D.StoreID'
		set @StrStore = 'D.StoreID'
	end
	Else
	begin
		SET @StrGroup = 'D.GoodsID'
		set @StrStore = 'Cast(''-'' AS VarChar(20))'
	end	
	
	set @StrSelect = '
		insert into #tbl_Store_Stock_AVG_IN(GoodsID, StoreID, Quantity)
		select D.GoodsID, ' + ltrim(@StrStore) + ', isnull(AVG(' + @strQuantity + '),0)
		from inv.tblStorageDocsDtl D
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = D.GoodsID AND SU.ShowInInvoice = 1 
		where EnterKind=+1 and ' + @StrWhereAvg + '
		group by ' + @StrGroup + '

		insert into #tbl_Store_Stock_AVG_OUT(GoodsID, StoreID, Quantity)
		select D.GoodsID, ' + ltrim(@StrStore) + ', isnull(AVG(' + @strQuantity + '),0)
		from inv.tblStorageDocsDtl D
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = D.GoodsID AND SU.ShowInInvoice = 1 
		where EnterKind=-1 and ' + @StrWhereAvg + '
		group by  ' + @StrGroup 
			
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	-- ====================================================
	
	--if (@GroupByLayer = 1)
	--begin
		set @GoodsNameField = '[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName'
		
		set @UnitNameField = 'inv.funGetUnitName(D.UnitID,' + @LangID + ') UnitName'
	--end
	--else
	--begin
	--	set @GoodsNameField = 'GD.GoodsName'
	--	set @UnitNameField = 'UD.UnitName'
	--end

	Declare @intIsMultiGoods AS Tinyint
	Declare @BarCode AS VARCHAR(50)
	
	SET @intIsMultiGoods = 0
	
	Select @intIsMultiGoods = Layer1 
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 2 

	IF @intIsMultiGoods > 0 And @intIsMultiGoods < 20
		SET @BarCode= 'ISNULL(GB.BarCode,'''')'
	ELSE
		SET @BarCode= 'ISNULL(GH.BarCode,'''')'

		
	set @StrSelect = '
	SELECT	D.*, P.BuyPrice LastBuyPrice, P2.SalPrice LastSalPrice, ' + ltrim(@UnitNameField) + ',
		    GH.CodeClosed, GH.TechnicalSpecifications, GH.TechnicalNo, GH.MiscSpecifications, GH.GoodsLength, GH.GoodsWidth, GH.GoodsHeight, 
		    GH.GoodsWeight, GH.MapNo, GH.MasterCode, GH.CheckBuyRequest, GH.CheckBuyOrder, GH.CheckQualityControl, GH.RecID, GH.SessionNo, 
		    ' + @BarCode + ' BarCode, GH.GlobalCodingID, GH.IranCodeID, GH.ExtraField1, GH.ExtraField2, GH.ExtraField3, GH.ExtraField4, GH.ExtraField5, 
		    GH.FitPoint, GH.SetPoint, GH.BatchSize, GH.HasSerial, GH.UseFactor, GH.CostCenterAcntCode, GH.ProduceWithoutFormula, 
		    GH.GoodsClassificationID, GH.PrinterID, GH.ShowInSaleMenu, GH.GoodsPrice, GH.VisitorPercent, GH.SpecialCode, GH.NationalCode, 
		    GH.DrugKindID, GH.CompanyID, GH.MinSaleCeiling, GH.MaxBuyCeiling, GH.QtyInPerPacket, GH.SalePrice GoodsSalePrice, GH.IsRation, GH.RationQty, 
		    GH.IsCombination, GH.CombinationAmount, GH.IsMammyDrug, GH.IsSalePermit, GH.IsComplementDrug, GH.IsDecorDrug, 
		    GH.IsNotInventoryCountDrug, GH.IsNotTariffDrug, GH.IsComrade, GH.DoseID, GH.SpecialAlarm, GH.GenericCode, GH.IsOTC, GH.DrugSetID, 
		    GH.UseExpireDate, GH.GenericID, GH.IsService, GH.IsCombined, GH.IsSendInfo, GH.ContainTax, GH.HasExpireDate, GH.HasBatchNo, 
		    GH.HasLentgh, GH.SaleTypeID, GH.DfStoreID, GH.GoodsGroup, GH.SubGroup, GH.PublisherAcntCode, GH.GoodsCount, GH.GoodsType, 
		    GH.PrintTurn, GH.PrintYear, GH.PageCount, GH.BuyPricePercent, 
			' + @GoodsNameField + ', GD.GoodsName2, GD.GenericName, GD.Author, GD.Translator, GD.GoodsLocation, '''' GroupName, S.StoreName, 
			Cast(''-'' AS NVarChar(50)) PackageInfo, Cast(''-'' AS NVarChar(50)) PlaceName, 
			''' + @LastCalc + ''' as LastAmountDate,
			IsNull((SELECT TOP 1 SalePrice from sal.tblGoodsPricesDtl P where P.DefaultSalePriceTypeID=1 and P.GoodsID=D.GoodsID),0) SalePrice,
			IsNull(O.OrderQty, 0) RemainOrder,isnull(RZ.ReservedQty,0) as ReservedQty,
			AVGI.Quantity as InStoreAvg, AVGO.Quantity as OutStoreAvg
	FROM	##tbl_Store_Stock D
			LEFT JOIN #tbl_RptStore_Stock_Prices P on P.GoodsID = D.GoodsID
			LEFT JOIN #tbl_RptStore_Stock_Prices2 P2 on P2.GoodsID = D.GoodsID
			LEFT JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ' AND GD.LanguageID=' + @LangID + '			
			LEFT JOIN inv.tblUnitsDtl UD ON UD.UnitID = D.UnitID and UD.LanguageID=' + @LangID + '
			LEFT JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID and S.LanguageID=' + @LangID + '
			LEFT JOIN (SELECT DISTINCT GoodsID,BarCode from inv.tblGoodsBarCodeDtl) GB ON GB.GoodsID=D.GoodsID
		    LEFT JOIN #tbl_Orders O on O.OGoodsID = D.GoodsID 
		    LEFT JOIN #tbl_Store_Stock_AVG_IN  AVGI on AVGI.GoodsID = D.GoodsID and AVGI.StoreID=D.StoreID
		    LEFT JOIN #tbl_Store_Stock_AVG_OUT AVGO on AVGO.GoodsID = D.GoodsID and AVGO.StoreID=D.StoreID
		    LEFT JOIN ##tbl_Reserved_Goods RZ on RZ.GoodsID = D.GoodsID 
			where TotalQuantityPrim>0 OR TotalQuantityInput>0 OR TotalQuantityOutput>0'
				
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
End
GO
