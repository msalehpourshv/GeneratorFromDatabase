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
Create PROCEDURE inv.RptStore_Stock
	@SelectedStore			Int = 0,
	@SelectedGoods			Int = 0,
	@DocDateFr				Char(10) = Null,
	@DocDateTo				Char(10) = Null,
	@IncludeQuantity		Bit = 1, -- شامل ستون مقدار
	@IncludePrice			Bit = 1, -- شامل ستون ق?مت
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
DECLARE @StrSelect1			NVarChar(max);
DECLARE @StrSelect2			NVarChar(max);
DECLARE @StrSelect3			NVarChar(max);
DECLARE @StrSelect4			NVarChar(max);
DECLARE @StrSelect5			NVarChar(max);
DECLARE @StrSelect6			NVarChar(max);
DECLARE @StrWhereD			NVarChar(max);
DECLARE @StrTempReceiptBuy	NVarChar(max);
DECLARE @StrTempReceiptPrd	NVarChar(max);
DECLARE @StrFrom			NVarChar(max);
DECLARE @StrWhere			NVarChar(max);
DECLARE @StrWhereGoods		NVarChar(max);
DECLARE @StrWhere2			NVarChar(max);
DECLARE @StrWhereAvg		NVarChar(max);
DECLARE @AllGoods			NVarChar(4000);
DECLARE @StrGroup			NVarChar(2000);
DECLARE @StrStore			NVarChar(2000);
DECLARE @StrHaving			NVarChar(2000);
DECLARE @StrAmount			NVarChar(4000);
DECLARE @StrYear			Char(4);
Declare @GoodsAmount		VarChar(20);
Declare @LastCalc			Char(10);
Declare @strQuantityControl	NVarChar(1000);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int;
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		Bit;

DECLARE @DateField			NVarchar(20);
DECLARE @GoodsIDField		varchar(200);
DECLARE @UnitNameField		varchar(200);
DECLARE @GoodsNameField		varchar(200);
DECLARE @GroupByLayer		Bit;
	
DECLARE @DrugSetID			VarChar(20);
DECLARE @DrugKindID			VarChar(20);
DECLARE @UseLastSalAmount	Bit;
DECLARE @UseLastBuySalAmount	Bit;
Declare @ShowGoodsImage			Bit;
DECLARE	@HasSerial			Bit;
DECLARE	@FromPrdSerialID	NVARCHAR(20);
DECLARE	@ToPrdSerialID		NVARCHAR(20);
DECLARE	@FromBatchNo		Varchar(20);
DECLARE	@ToBatchNo			Varchar(20);
DECLARE	@FromExpireDate		Varchar(10);
DECLARE	@ToExpireDate		Varchar(10);
DECLARE	@IsReservedGoods	bit;
DECLARE	@JustPermit			bit;
DECLARE @LayerLen			int;
DECLARE @GoodsPart			int;
DECLARE	@SuspendedTransferGoods	Bit;
DECLARE @GoodsClassificationID	VarChar(20);
DECLARE @BatchNo1	VarChar(20);
DECLARE @BatchNo2	VarChar(20);

DECLARE @RptFiscalYear			Int;
DECLARE @AllocateGoodsToStore	Int;
DECLARE	@TechnicalNo			NVarchar(50);
DECLARE	@ShowSaleOrderRemain	Bit;
DECLARE	@strSaleOrderRemain		NVarChar(1000);

DECLARE @WithQuantityControl	Bit;
DECLARE @strUserPrice			NVarChar(200);
DECLARE @strUserPriceGrp		NVarChar(200);
DECLARE @strUserPriceSort		NVarChar(200);

Declare @ShowBatchNo	Bit
DECLARE	@TempReceiptBuy	Bit;
DECLARE	@TempReceiptPrd	Bit;
DECLARE	@CodeClosed		Bit;
DECLARE	@ContainerID	VarChar(20);
DECLARE	@ContainerID2	VarChar(20);
DECLARE	@ContainerStoresID	VarChar(20);
DECLARE	@ContainerStoresID2	VarChar(20);
DECLARE	@HasContainer	Bit;
DECLARE	@ShowInWebsite	Bit;
DECLARE	@ShowIsService	Bit;

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
	
	--========================
	DECLARE @PrimaryMaterialRemain Bit
	SET @PrimaryMaterialRemain  = 0

	SELECT @PrimaryMaterialRemain = SettingValue from pub.tblSettings where SettingKey = 'SalCheckGoodsRemainByPrimaryMaterial'

	DECLARE	@QuantityDecimals	CHAR(1);
	set	@QuantityDecimals = '2';
	select	@QuantityDecimals = SettingValue from pub.tblSettings where	SettingKey = 'QuantityDecimals'
		
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

	SET @DrugSetID				 = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @DrugKindID				 = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @UseLastSalAmount		 = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @HasSerial				 = LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @FromExpireDate			 = LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @ToExpireDate			 = LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @IsReservedGoods		 = LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @JustPermit				 = LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @SuspendedTransferGoods	 = LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @GoodsClassificationID	 = LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	SET @GroupByLayer			 = LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	SET @LayerLen				 = LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	SET @GoodsPart				 = LTrim(pub.funSplitString(@ExtraParams, '@', 13));
	SET @RptFiscalYear			 = LTrim(pub.funSplitString(@ExtraParams, '@', 14));
	SET @TechnicalNo			 = LTrim(pub.funSplitString(@ExtraParams, '@', 15));
	SET @ShowSaleOrderRemain	 = LTrim(pub.funSplitString(@ExtraParams, '@', 16));
	SET @BatchNo1				 = LTrim(pub.funSplitString(@ExtraParams, '@', 17));
	SET @BatchNo2				 = LTrim(pub.funSplitString(@ExtraParams, '@', 18));
	SET @WithQuantityControl	 = LTrim(pub.funSplitString(@ExtraParams, '@', 19));
	SET @ShowBatchNo			 = LTrim(pub.funSplitString(@ExtraParams, '@', 20));
	SET @FromPrdSerialID		 = LTrim(pub.funSplitString(@ExtraParams, '@', 22)); 
	SET @ToPrdSerialID			 = LTrim(pub.funSplitString(@ExtraParams, '@', 23)); 
	SET @FromBatchNo			 = LTrim(pub.funSplitString(@ExtraParams, '@', 24));
	SET @ToBatchNo				 = LTrim(pub.funSplitString(@ExtraParams, '@', 25));	
	SET @AllocateGoodsToStore	 = LTrim(pub.funSplitString(@ExtraParams, '@', 26));	
	SET @UseLastBuySalAmount	 = LTrim(pub.funSplitString(@ExtraParams, '@', 27));	
	SET @ShowGoodsImage			 = LTrim(pub.funSplitString(@ExtraParams, '@', 28));	
	SET @TempReceiptBuy			 = LTrim(pub.funSplitString(@ExtraParams, '@', 29));		
	SET @CodeClosed				 = LTrim(pub.funSplitString(@ExtraParams, '@', 30));		
	SET @ContainerID			 = LTrim(pub.funSplitString(@ExtraParams, '@', 31));		
	SET @ContainerID2			 = LTrim(pub.funSplitString(@ExtraParams, '@', 32));		
	SET @HasContainer			 = LTrim(pub.funSplitString(@ExtraParams, '@', 33));
	SET @ShowInWebsite			 = LTrim(pub.funSplitString(@ExtraParams, '@', 34));
	SET @ContainerStoresID		 = LTrim(pub.funSplitString(@ExtraParams, '@', 35));		
	SET @ContainerStoresID2		 = LTrim(pub.funSplitString(@ExtraParams, '@', 36));
	SET @ShowIsService			 = LTrim(pub.funSplitString(@ExtraParams, '@', 37));
	SET @TempReceiptPrd			 = LTrim(pub.funSplitString(@ExtraParams, '@', 38));		
		 
	IF (@LayerLen = 0) SET @LayerLen = 20;		
	----------------------------------------------------------------------------------

	DECLARE @StrIsService as nVarChar(50) = ''
	IF @ShowIsService = 'False' 
		SET @StrIsService = ' Where IsService = 0 '
	ELSE
		SET @StrIsService = ''
	SET @LastCalc = ''
	
	  if @FromPrdSerialID='0' 
	  set @FromPrdSerialID=''

	  if @ToPrdSerialID='0' 
	  set @ToPrdSerialID=''

	select @LastCalc = IsNull(Max(ToDate), '')
	from inv.tblStorageCosts
	
	begin try
		drop table #tbl_RptStore_Stock_Prices2
	end try
	begin catch
	end catch

	begin try
		drop table #tbl_RptStore_Stock_Prices
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
	IF @IsReservedGoods=1
	begin
		insert into ##tbl_Reserved_Temp
		exec [pln].[RptPln_ProduceOrder_Reserves]
		
		insert into ##tbl_Reserved_Goods
		select GoodsID, SUM(Quantity)
		from ##tbl_Reserved_Temp
		Group by GoodsID
	 end
	--###############################
	
	IF (@GroupByLayer = 0)
	begin
		insert into #tbl_RptStore_Stock_Prices (GoodsID, BuyPrice)
		select *
		from 
		(
			select distinct GoodsID, 
				(
					select top 1 GoodsPrice
					from inv.tblStorageDocsDtl D 
					where (D.GoodsID = M.GoodsID) and (D.ProcessID in (55,50)) 	and GoodsPrice<>0	
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
					select top 1 GoodsPrice
					from inv.tblStorageDocsDtl D 
					where (D.GoodsID = M.GoodsID) and (D.ProcessID in (90)) 	and GoodsPrice<>0	
					order by DocDate DESC, VolumeRowNo DESC
				),0) SalPrice		
			from inv.tblStorageDocsDtl M
		) T 
		
		update #tbl_RptStore_Stock_Prices
		SET BuyPrice = GoodsPrice
		from inv.tblGoods
		where #tbl_RptStore_Stock_Prices.GoodsID = inv.tblGoods.GoodsID 
			and #tbl_RptStore_Stock_Prices.BuyPrice = 0
			
		update #tbl_RptStore_Stock_Prices2
		SET SalPrice = GoodsPrice
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
	IF (@IncludePrice = 1)
		--SET @DateField = 'VchDate2'
		SET @DateField = 'D.DocDate'
	else
		SET @DateField = 'D.DocDate'
		
	declare @GoodsPartLen int;
	
	select @GoodsPartLen = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' and PartNumber=1

	DECLARE @OtherFiscalYear		varchar(1)
	SET @OtherFiscalYear  = '0'
	SELECT @OtherFiscalYear = SettingValue from pub.tblSettings where SettingKey = 'OtherFiscalYear'

	IF @OtherFiscalYear IS NULL 
		SET @OtherFiscalYear = '0'

	IF @OtherFiscalYear= '0'
		SET @StrWhere = '(D.FiscalYear = ' + @StrYear + ')' ;
	ELSE
		SET @StrWhere = '(D.FiscalYear <>0) ' ;

	SET @StrWhereAvg = @StrWhere ;
	SET @StrWhere2 = '1 = 1';
	SET @StrSelect5 = ''
	
	--IF (@PhysicallyEffected Is Not Null)
	--	IF (@PhysicallyEffected = 1) 
	--		SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
	--	Else IF (@PhysicallyEffected = 0) 
	--		SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'	

	IF (@PhysicallyEffected Is Not Null)
		IF (@PhysicallyEffected = 1 And @JustPermit = 0) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
		Else IF (@PhysicallyEffected = 1 And @JustPermit = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'
		Else IF (@PhysicallyEffected = 0 And @JustPermit = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'			
	
	IF (@DocDateFr Is Not Null)
		SET @StrWhereAvg = @StrWhereAvg + ' AND D.DocDate >= ''' + @DocDateFr + ''''
		
	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (' + LTrim(@DateField) + ' <= ''' + @DocDateTo + ''')'
		
	IF (@IncludeZeroAmount = 0)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsAmount <> 0)'
	
	set @StrWhereGoods=''
	IF (@SelectedGoods > 0)
	begin
		SET @StrWhereGoods	 = ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D1.GoodsID') 
		SET @StrWhereAvg = @StrWhereAvg + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	end
	
	IF (@SelectedStore > 0)
	BEGIN
		SET @StrWhere	 = @StrWhere	+ ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhereAvg = @StrWhereAvg + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	END

	IF (@DrugSetID <> '')
		SET @StrWhere = @StrWhere + ' AND GH.DrugSetID = ''' + @DrugSetID + ''''

	IF (@DrugKindID <> '')
		SET @StrWhere = @StrWhere + ' AND GH.DrugKindID = ''' + @DrugKindID + ''''
		
	IF (@GoodsClassificationID Is Not Null And @GoodsClassificationID <> '')
		SET @StrWhere = @StrWhere + ' AND GH.GoodsClassificationID = ''' + @GoodsClassificationID + ''''		
		
	IF (@TechnicalNo <> '' And @TechnicalNo Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (UPPER(GH.TechnicalNo) = UPPER(''' + @TechnicalNo + '''))'
				
	IF (@BatchNo1 <> '' And @BatchNo1 Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.BatchNo >= ''' + @BatchNo1 + ''')'
	IF (@BatchNo2 <> '' And @BatchNo2 Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.BatchNo <= ''' + @BatchNo2 + ''')'

	IF @CodeClosed = '1' 
		SET @StrWhere = @StrWhere + ' AND (GH.CodeClosed = ''False'')'
		
	IF @ShowInWebsite = 'true' 
		SET @StrWhere = @StrWhere + ' AND (GH.ShowInWebsite = ''True'')'
								
	-- ===========			
	IF @IncludePrim = 1 And @IncludeInput = 0 And @IncludeOutput = 0
		SET @StrWhere2 = @StrWhere2 + ' AND D1.ProcessID = 50 '

	IF @IncludePrim = 0 And @IncludeInput = 1 And @IncludeOutput = 0
		SET @StrWhere2 = @StrWhere2 + ' AND (D1.EnterKind = +1 AND D1.ProcessID <> 50) '
		
	IF @IncludePrim = 0 And @IncludeInput = 0 And @IncludeOutput = 1
		SET @StrWhere2 = @StrWhere2 + ' AND (D1.EnterKind = -1 AND D1.ProcessID <> 50) '
	
	-- ===========			
	IF @IncludePrim = 1 And @IncludeInput = 1 And @IncludeOutput = 0
		SET @StrWhere2 = @StrWhere2 + ' AND (D1.EnterKind <> -1) '

	IF @IncludePrim = 0 And @IncludeInput = 1 And @IncludeOutput = 1
		SET @StrWhere2 = @StrWhere2 + ' AND (D1.ProcessID <> 50)'
		
	IF @IncludePrim = 1 And @IncludeInput = 0 And @IncludeOutput = 1
		SET @StrWhere2 = @StrWhere2 + ' AND D1.EnterKind <> +1 '
		
	-- ===============================
	IF @ContainerID  <> '' OR   @ContainerID2  <> '' OR  @FromBatchNo <> '' OR @ToBatchNo <> '' OR @FromExpireDate <> '' OR @ToExpireDate <> '' OR @FromPrdSerialID <> '' OR @ToPrdSerialID <> '' OR @ContainerStoresID <> '' OR @ContainerStoresID2 <> ''
	Begin
		SET @StrWhere = @StrWhere + '
			And D.GoodsID In (SELECT GoodsID 
							  FROM inv.tblStorageDocsDtl D
							  INNER JOIN (Select * 
							  			  From inv.tblStorageDocsSerials SS 
										  Where 1 = 1 ' + 
										  Case When @FromPrdSerialID	<> '' Then ' And SS.PSerialNo >= ''' + @FromPrdSerialID + '''' Else '' End +
										  Case When @ToPrdSerialID		<> '' Then ' And SS.PSerialNo <= ''' + @ToPrdSerialID + '''' Else '' End +
										  Case When @FromBatchNo		<> '' Then ' And SS.BatchNo	>= ''' + LTrim(RTrim(@FromBatchNo)) + '''' Else '' End +
										  Case When @ToBatchNo			<> '' Then ' And SS.BatchNo	<= ''' + LTrim(RTrim(@ToBatchNo)) + '''' Else '' End +
										  Case When @ContainerID		<> '' Then ' And SS.ContainerID >= ''' + LTrim(RTrim(@ContainerID)) + '''' Else '' End +
										  Case When @ContainerID2		<> '' Then ' And SS.ContainerID <= ''' + LTrim(RTrim(@ContainerID2)) + '''' Else '' End +
										  Case When @ContainerStoresID	<> '' Then ' And SS.ContainerStoresID >= ''' + LTrim(RTrim(@ContainerStoresID)) + ''''	Else '' End +
										  Case When @ContainerStoresID2	<> '' Then ' And SS.ContainerStoresID <= ''' + LTrim(RTrim(@ContainerStoresID2)) + '''' Else '' End +
										  Case When @FromExpireDate		<> '' Then ' And SS.ExpireDate >= ''' + LTrim(RTrim(@FromExpireDate)) + '''' Else '' End +
										  Case When @ToExpireDate		<> '' Then ' And SS.ExpireDate <= ''' + LTrim(RTrim(@ToExpireDate)) + '''' Else '' End + '
										  ) SS ON SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And
												  SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
												  SS.DocRowNo = D.DocRowNo)'
	End		
				
	-- ==============================				
	SET @strQuantityControl = ''
	SET @strUserPrice = ', '''' GoodsUserPriceID, 0 UserPrice, 0 UserPriceQty '
	SET @strUserPriceGrp = ''
	SET @strUserPriceSort = ''
	IF @WithQuantityControl = 1
	Begin
		SET @strQuantityControl = 'LEFT JOIN inv.tblGoodsUserPrice GU ON GU.ID = D.UserPriceID --AND GU.UserPrice = D.GoodsQuantity '
		SET @strUserPrice = ', IsNull(GU.ID,0) GoodsUserPriceID, IsNull(GU.UParams,'''') UserPrice, IsNull(GU.GoodsQuantity,0) UserPriceQty '
		SET @strUserPriceGrp = ', GU.ID, GU.UParams, GU.GoodsQuantity, D.UserPriceID, D.StoreID '
		SET @strUserPriceSort = 'ORDER BY D.StoreID, D.GoodsID, D.UserPriceID '
		--SET @StrWhere = @StrWhere + ' AND (D.UserPriceID <> 0) '
	End
					
	----------------------------------------------------------------------------------
	IF (@IncludeNoCurrent = 1)
	begin
		SET @AllGoods = ' 
			UNION ALL 
			SELECT	50 ProcessID, ' + @StrYear + ' FiscalYear, ''0000/00/00'' DocDate, S.StoreID, G.GoodsID, 0 GoodsQuantity, 
					0 SubUnitQuantity, 0 GoodsAmount, 0 EnterKind, 0 PhysicallyEffected, G.UnitID SubUnitID, 0 DiscountDtl, 
					0 GoodsPrice, CAST('''' as varchar(20)) BatchNo, 0 UserPriceID, 0 GoodsAmountT
			FROM	inv.tblStores S
						cross join inv.tblGoods G
			WHERE  (StoreID <> '''') and (GoodsID <> '''') ' 
		IF (@SelectedGoods > 0)
			SET @AllGoods = @AllGoods + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'G.GoodsID') 
	end
	else
		SET @AllGoods = ''
	----------------------------------------------------------------------------------------------------------
	IF (@GroupByStore = 1)
	begin
		SET @StrGroup = 'D.StoreID, D.GoodsID, GH.UnitID,D.BatchNo'
		SET @StrStore = 'D.StoreID'
	end
	Else
	begin
		SET @StrGroup = 'D.GoodsID, GH.UnitID,D.BatchNo'
		SET @StrStore = 'Cast(''-'' AS VarChar(20))'
	end

	-- آخرين قيمت خريد
	IF (@UseLastBuyAmount = 1)
		SET @StrAmount = 'ISNULL((SELECT BuyPrice FROM #tbl_RptStore_Stock_Prices P WHERE P.GoodsID=D1.GoodsID),0) AS GoodsAmount'
	
	-- آخرين قيمت فروش
	IF (@UseLastSalAmount = 1)
		SET @StrAmount = 'ISNULL((SELECT SalPrice FROM #tbl_RptStore_Stock_Prices2 P WHERE P.GoodsID=D1.GoodsID),0) AS GoodsAmount'
	-- آخرين قيمت خريد برای وارده و آخرين قيمت فروش برای صادره
	IF (@UseLastBuySalAmount = 1)
		SET @StrAmount = ' Case When EnterKind =1 then 
								ISNULL((SELECT BuyPrice FROM #tbl_RptStore_Stock_Prices P WHERE P.GoodsID=D1.GoodsID),0) 
							else 
								ISNULL((SELECT SalPrice FROM #tbl_RptStore_Stock_Prices2 P WHERE P.GoodsID=D1.GoodsID),0) 
							end  AS GoodsAmount'
	
	IF (@UseLastBuyAmount = 0) AND (@UseLastSalAmount = 0) AND (@UseLastBuySalAmount = 0)
		SET @StrAmount = @GoodsAmount + ' AS GoodsAmount'

	IF (@GroupByLayer = 1)
		SET @GoodsIDField = 'Left(D1.GoodsID, ' + str(@LayerLen) + ') GoodsID'
	else
		SET @GoodsIDField = 'D1.GoodsID'
		
	DECLARE @strQuantity varchar(400)
	SET @strQuantity = 'D.GoodsQuantity'			
	IF (@UseSecondUnit=1)
		SET @strQuantity= ' CASE WHEN SU.SubUnitID IS NULL THEN D.GoodsQuantity WHEN SU.SubUnitID<>D.SubUnitID THEN D.GoodsQuantity * SU.UnitValue / SU.MainUnitValue ELSE SubUnitQuantity END '

	DECLARE @strQuantity2 varchar(400)
	SET @strQuantity2	= ' CASE WHEN SU.SubUnitID IS NULL THEN D.GoodsQuantity WHEN SU.SubUnitID<>D.SubUnitID THEN D.GoodsQuantity * SU.UnitValue / SU.MainUnitValue ELSE SubUnitQuantity END '
		
	BEGIN TRY
		DROP TABLE #tblStoreID
		DROP TABLE #tblGoods
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tblGoods
	(
	GoodsID 			Varchar(20)collate arabic_cs_as null
	)
	CREATE TABLE #tblStoreID
	(
	StoreID 			Varchar(20)collate arabic_cs_as null
	)
	Insert into  #tblGoods (GoodsID)	SELECT Distinct GoodsID			FROM inv.tblStorageDocsDtl
	Insert into  #tblStoreID (StoreID)	SELECT Distinct StoreID			FROM inv.tblStorageDocsDtl
	 
	SET @StrWhereD = ''  

	if @UserIsAdmin=0
	begin
		 exec pub.SpFilterByPermission2 '#tblGoods', 'GoodsID', 'inv.tblGoods', @UserID;
		 exec pub.SpFilterByPermission2 '#tblStoreID', 'StoreID', 'inv.tblStores', @UserID;
		SET @StrWhereD =  ' and D1.GoodsID in (SELECT GoodsID	FROM #tblGoods )  and D1.StoreID in (SELECT StoreID FROM  #tblStoreID )'
	END

	-- Select Clause -----------------------------------------------------------------------------------------
	SET @StrSelect1 = '
	SELECT ' + Case When @WithQuantityControl = 1 Then 
					'CASE WHEN D.UserPriceID = 0 THEN D.GoodsID ELSE D.GoodsID + '' - '' + LTrim(RTrim(GU.UParams)) END GoodsID, ' 
			   Else 'D.GoodsID, ' End + ' D.GoodsID GoodsID2, 
			    ' + Case when @ShowBatchNo =1 Then    +  'D.BatchNo, ' Else 'CAST('''' as varchar(20)) as BatchNo ,' End
		     + ltrim(@StrStore) + ' StoreID,' 

	SET @StrSelect2 = '' + 
			CASE WHEN (@DocDateFr Is Not Null) THEN '
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + ''' THEN D.EnterKind * ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityPrim, 
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityInput,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityOutput, 
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 90 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantitySale, 
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 100 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantitySale_Ret,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + ''' THEN D.GoodsQuantity * D.GoodsAmount * D.EnterKind  ELSE 0 END),0) +
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + '''  AND D.EnterKind = +1 AND D.ProcessID = 51 THEN D.GoodsPrice  ELSE 0 END),0) AS TotalPricePrim,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) +
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 AND D.ProcessID = 51  THEN D.GoodsPrice ELSE 0 END),0) AS TotalPriceInput,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) +
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 AND D.ProcessID = 51  THEN D.GoodsPrice ELSE 0 END),0) AS TotalPriceOutput,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + ''' THEN D.GoodsQuantity * D.GoodsAmountT * D.EnterKind  ELSE 0 END),0) +
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + '''  AND D.EnterKind = +1 AND D.ProcessID = 51 THEN D.GoodsPrice  ELSE 0 END),0) AS TotalAmountPrim,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity * D.GoodsAmountT ELSE 0 END),0) +
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 AND D.ProcessID = 51  THEN D.GoodsPrice ELSE 0 END),0) AS TotalAmountInput,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity * D.GoodsAmountT ELSE 0 END),0) +
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 AND D.ProcessID = 51  THEN D.GoodsPrice ELSE 0 END),0) AS TotalAmountOutput,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 90 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 100 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale_Ret,'
			ELSE '
				isnull(SUM(CASE WHEN D.ProcessID =  50 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityPrim, 
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityInput,
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantityOutput, 
				isnull(SUM(CASE WHEN D.ProcessID = 90 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantitySale, 
				isnull(SUM(CASE WHEN D.ProcessID = 100 THEN ' + @strQuantity + ' ELSE 0 END),0) AS TotalQuantitySale_Ret,
				isnull(SUM(CASE WHEN D.ProcessID =  50 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0) AS TotalPricePrim,
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0)
				+isnull(SUM(CASE WHEN D.ProcessID =51 AND D.EnterKind = +1 THEN  D.GoodsPrice ELSE 0 END),0) AS TotalPriceInput,
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END),0)
				+isnull(SUM(CASE WHEN D.ProcessID =51 AND D.EnterKind = -1 THEN  D.GoodsPrice ELSE 0 END),0) AS TotalPriceOutput ,
				isnull(SUM(CASE WHEN D.ProcessID =  50 THEN D.GoodsQuantity * D.GoodsAmountT ELSE 0 END),0) AS TotalAmountPrim,
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity * D.GoodsAmountT ELSE 0 END),0)
				+isnull(SUM(CASE WHEN D.ProcessID =51 AND D.EnterKind = +1 THEN  D.GoodsPrice ELSE 0 END),0) AS TotalAmountInput,
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity * D.GoodsAmountT ELSE 0 END),0)
				+isnull(SUM(CASE WHEN D.ProcessID =51 AND D.EnterKind = -1 THEN  D.GoodsPrice ELSE 0 END),0) AS TotalAmountOutput ,
				isnull(SUM(CASE WHEN D.ProcessID = 90 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale,
				isnull(SUM(CASE WHEN D.ProcessID = 100 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale_Ret,'
			END + ''

	
	SET @StrSelect3 = '' + 
			CASE WHEN (@DocDateFr Is Not Null) THEN '			
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 90 THEN D.DiscountDtl ELSE 0 END),0) AS TotalDiscountSale, 
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 100 THEN D.DiscountDtl ELSE 0 END),0) AS TotalDiscountSale_Ret,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + ''' THEN D.EnterKind * ' + @strQuantity2 + ' ELSE 0 END),0) AS TotalQuantityPrim2, 
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 THEN ' + @strQuantity2 + ' ELSE 0 END),0) AS TotalQuantityInput2,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 THEN ' + @strQuantity2 + ' ELSE 0 END),0) AS TotalQuantityOutput2, 
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 90 THEN ' + @strQuantity2 + ' ELSE 0 END),0) AS TotalQuantitySale2, 
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 100 THEN ' + @strQuantity2 + ' ELSE 0 END),0) AS TotalQuantitySale_Ret2 ' + '
				' + @strUserPrice
			ELSE '
				isnull(SUM(CASE WHEN D.ProcessID = 90 THEN D.DiscountDtl ELSE 0 END),0) AS TotalDiscountSale, 
				isnull(SUM(CASE WHEN D.ProcessID = 100 THEN D.DiscountDtl ELSE 0 END),0) AS TotalDiscountSale_Ret,			
				isnull(SUM(CASE WHEN D.ProcessID =  50 THEN ' + @strQuantity2 + ' ELSE 0 END),0) AS TotalQuantityPrim2, 
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN ' + @strQuantity2 + ' ELSE 0 END),0) AS TotalQuantityInput2,
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN ' + @strQuantity2 + ' ELSE 0 END),0) AS TotalQuantityOutput2, 
				isnull(SUM(CASE WHEN D.ProcessID = 90 THEN ' + @strQuantity2 + ' ELSE 0 END),0) AS TotalQuantitySale2, 
				isnull(SUM(CASE WHEN D.ProcessID = 100 THEN ' + @strQuantity2 + ' ELSE 0 END),0) AS TotalQuantitySale_Ret2 ' + '
				' + @strUserPrice
			END + ''
				 
			 
	SET @StrSelect4 =  ', GH.UnitID
	INTO ##tbl_Store_Stock
	FROM
		(
			SELECT D1.ProcessID, D1.FiscalYear, D1.DocDate, D1.StoreID, ' + ltrim(@GoodsIDField) + ', D1.GoodsQuantity, D1.SubUnitQuantity, ' + @StrAmount + ' ,
				   D1.EnterKind, D1.PhysicallyEffected ,D1.SubUnitID ,D1.DiscountDtl,D1.GoodsPrice,  '+ case when @ShowBatchNo =1 then    +  'D1.BatchNo ' else ''''' as BatchNo ' end+', D1.UserPriceID,
				   D1.GoodsAmount GoodsAmountT
			FROM inv.tblStorageDocsDtl D1 WHERE '  + @StrWhere2+ @StrWhereD + @StrWhereGoods + @AllGoods  +'
		) D'
	--Print @StrSelect1;
	
	SET @StrSelect5 = '		
		inner join  (Select GoodsID From inv.tblGoods '+ @StrIsService +') G on left(D.GoodsID,' + str(@GoodsPartLen) + ') =G.GoodsID
		LEFT JOIN inv.tblGoods GH ON GH.GoodsID = SUBSTRING(D.GoodsID,' + STR(@str_Goods+1) + ',' + STR( @str_GoodsSum) + ') and GH.PartNumber = ' + str(@GoodsPart) + '
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = D.GoodsID AND SU.ShowInInvoice = 1 and GH.PartNumber = ' + str(@GoodsPart) + '
		' + @strQuantityControl + '
	WHERE	 ' + @StrWhere + '
	GROUP BY ' + @StrGroup + @strUserPriceGrp +''

	set @StrSelect6 =  ''

	-- Having Clause ------------------------------------------------------------------------------------------
	IF (@IncludeZeroQuantity = 0) 
	Begin
		SET @StrSelect6 =  
			CASE WHEN (@DocDateFr Is Not Null) THEN 
				' HAVING ROUND(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr + ''' THEN D.GoodsQuantity * D.EnterKind ELSE 0 END) +
						 SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) -
						 SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END),5) > 0 '
			ELSE + ' HAVING ROUND(SUM(D.GoodsQuantity * D.EnterKind),' + @QuantityDecimals + ') > 0 ' 
			END   
	End

	begin try
		drop table ##tbl_Store_Stock
	end try
	begin catch
	end catch
	
	-- Run -----------------------------------------------------
	
	Print @StrSelect1 
	 Print @StrSelect2
	 Print @StrSelect3
	 Print @StrSelect4
	 Print @StrSelect5
	 Print @StrSelect6
	 Print @strUserPriceSort

	 SET @StrSelect = @StrSelect1 + @StrSelect2+ @StrSelect3+ @StrSelect4+ @StrSelect5 + @StrSelect6 + @strUserPriceSort

	Exec sp_executesql @StrSelect ;
	
	IF (@UseSecondUnit=1)
		update ##tbl_Store_Stock 
		SET 
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
	BatchNo nvarchar(20) collate arabic_cs_as not null,
		GoodsID varchar(20) collate arabic_cs_as not null,
		StoreID varchar(20) collate arabic_cs_as not null,
		Quantity float not null		
	)
	create table #tbl_Store_Stock_AVG_OUT (
	BatchNo nvarchar(20) collate arabic_cs_as not null,
		GoodsID varchar(20) collate arabic_cs_as not null,
		StoreID varchar(20) collate arabic_cs_as not null,
		Quantity float not null		
	)	
	
	IF (@GroupByStore = 1)
	begin
		SET @StrGroup = 'D.GoodsID, D.StoreID'
		SET @StrStore = 'D.StoreID'
	end
	Else
	begin
		SET @StrGroup = 'D.GoodsID'
		SET @StrStore = 'Cast(''-'' AS VarChar(20))'
	end	
	
	IF(@ShowBatchNo= 1 )
	begin
	SET @StrGroup= @StrGroup+ ',D.BatchNo'
	end
	
	SET @StrSelect = '
		insert into #tbl_Store_Stock_AVG_IN(BatchNo,GoodsID, StoreID, Quantity)
		select 
		 ' + case when @ShowBatchNo =1 then    +  'D.BatchNo ' else ' CAST('''' as varchar(20))  ' end +' BatchNo,
		D.GoodsID, ' + ltrim(@StrStore) + ', isnull(AVG(' + @strQuantity + '),0) Quantity
		from inv.tblStorageDocsDtl D
		inner join  (Select GoodsID From inv.tblGoods '+ @StrIsService +') G on left(D.GoodsID,' + str(@GoodsPartLen) + ') =G.GoodsID
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = D.GoodsID AND SU.ShowInInvoice = 1 
		where EnterKind = +1 and ' + @StrWhereAvg + '
		group by ' + @StrGroup + '

		insert into #tbl_Store_Stock_AVG_OUT(BatchNo,GoodsID, StoreID, Quantity)
		select 
		 ' + case when @ShowBatchNo =1 then    +  'D.BatchNo ' else ' CAST('''' as varchar(20)) ' end +' BatchNo
		,D.GoodsID, ' + ltrim(@StrStore) + ', isnull(AVG(' + @strQuantity + '),0) Quantity
		from inv.tblStorageDocsDtl D
		inner join  (Select GoodsID From inv.tblGoods '+ @StrIsService +') G on left(D.GoodsID,' + str(@GoodsPartLen) + ') =G.GoodsID
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = D.GoodsID AND SU.ShowInInvoice = 1 
		where EnterKind=-1 and ' + @StrWhereAvg + '
		group by  ' + @StrGroup 
			
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	-- ====================================================
	
	--IF (@GroupByLayer = 1)
	--begin
		SET @GoodsNameField = '[pub].[funGetGoodsName](D.GoodsID2,' + LTrim(RTrim(@LangID)) + ') GoodsName'
		
		SET @UnitNameField = 'inv.funGetUnitName(D.UnitID,' + @LangID + ') UnitName'
	--end
	--else
	--begin
	--	SET @GoodsNameField = 'GD.GoodsName'
	--	SET @UnitNameField = 'UD.UnitName'
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

	IF (@ShowSaleOrderRemain = 0)
		SET @strSaleOrderRemain = ' '''' As SaleOrderRemain, '
	Else
		SET @strSaleOrderRemain = ' [sal].[funGetSaleOrderGoodsRemain](D.GoodsID,''' + @DateField + ''',Null,0) As SaleOrderRemain, '
 
	set @StrTempReceiptBuy=' ,0.0  TempReceiptRemain'	
 if @TempReceiptBuy='True'
	set @StrTempReceiptBuy=' , isnull(inv.funInvTempReceiptRemain (D.GoodsID,D.StoreID,'+ isnull(@DocDateTo,'''''') +',D.BatchNo),0)  TempReceiptRemain'

	set @StrTempReceiptPrd=' ,0.0  TempReceiptPrdRemain'	
if @TempReceiptPrd='True'
	set @StrTempReceiptPrd=' , isnull(inv.funGetGoodsRemainInTempReceipt( D.StoreID,D.GoodsID,D.BatchNo,'+ isnull(@DocDateTo,'''''') +'),0)  TempReceiptPrdRemain'


	-- ===============================
	SET @StrSelect = '
	SELECT  D.*'+ @StrTempReceiptBuy +' '+ @StrTempReceiptPrd +', [inv].[funGetBatchName](D.BatchNo, ' + @LangID + ') BatchName, P.BuyPrice LastBuyPrice, 
			P2.SalPrice LastSalPrice, ' + ltrim(@UnitNameField) + ', (TotalQuantityOutput - TotalQuantityInput - TotalQuantityPrim) TotalQuantitySum1, 
			(TotalQuantityPrim + TotalQuantityInput - TotalQuantityOutput) TotalQuantitySum2, ' + 
			Case When @PrimaryMaterialRemain = 'True' Then '
			[inv].[funGetPreSaleAndSaleOrderRemain] (D.GoodsID, '''', '''', 0)' Else '0' End + ' As PreSaleReservedRemain, ' +
			Case When @PrimaryMaterialRemain = 'True' Then '
			[inv].[funGetPreSaleAndSaleOrderRemain] (D.GoodsID, '''', '''', 1)' Else '0' End + ' As SaleOrderReservedRemain,' + 
			@strSaleOrderRemain + '
		    GH.CodeClosed, GH.TechnicalSpecifications, GH.TechnicalNo, GH.MiscSpecifications, GH.GoodsLength, GH.GoodsWidth, GH.GoodsHeight, GH.GoodsCID, 
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
			AVGI.Quantity as InStoreAvg, AVGO.Quantity as OutStoreAvg,inv.GetGoodsPlaceNameFromStore(GS.StoreID,GS.DocRowNo,1) GoodsStatusRecDesc,
			isnull(GS.FitPoint,0) as GoodsStatusFitPoint , isnull(GS.SetPoint,0) as GoodsStatusSetPoint
			, ' + Case When @ShowGoodsImage = 1 Then 'GI1.GoodsImage, GI2.BatchImage ' Else 'Null As GoodsImage,Null As BatchImage ' End + '
	 '
		 SET @StrSelect = @StrSelect+'	FROM	##tbl_Store_Stock D
			LEFT JOIN #tbl_RptStore_Stock_Prices P on P.GoodsID = D.GoodsID
			LEFT JOIN #tbl_RptStore_Stock_Prices2 P2 on P2.GoodsID = D.GoodsID
			LEFT JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ' AND GD.LanguageID=' + @LangID + '			
			LEFT JOIN inv.tblUnitsDtl UD ON UD.UnitID = D.UnitID and UD.LanguageID=' + @LangID + '
			LEFT JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID and S.LanguageID=' + @LangID + '
			LEFT JOIN (SELECT DISTINCT GoodsID,BarCode from inv.tblGoodsBarCodeDtl) GB ON GB.GoodsID=D.GoodsID
		    LEFT JOIN #tbl_Orders O on O.OGoodsID = D.GoodsID 
		    LEFT JOIN #tbl_Store_Stock_AVG_IN  AVGI on AVGI.GoodsID = D.GoodsID and AVGI.StoreID = D.StoreID AND IsNull(AVGI.BatchNo,'''') = D.BatchNo    
		    LEFT JOIN #tbl_Store_Stock_AVG_OUT AVGO on AVGO.GoodsID = D.GoodsID and AVGO.StoreID = D.StoreID AND IsNull(AVGO.BatchNo,'''') = D.BatchNo   
		    LEFT JOIN ##tbl_Reserved_Goods RZ on RZ.GoodsID = D.GoodsID 
			'+Case When @ShowGoodsImage = 1 Then ' LEFT JOIN inv.tblGoodsImages GI1 ON GI1.GoodsID = D.GoodsID 
			LEFT JOIN inv.tblBatchImages GI2 ON GI2.BatchNo = D.BatchNo ' Else ' ' End+'
		  LEFT JOIN inv.tblGoodsStatusDtl GS on D.GoodsID = GS.GoodsID and D.StoreID= GS.StoreID And 
											GS.RowNo = (Select Top 1 RowNo 
														From inv.tblGoodsStatusDtl GS1 
														Where D.GoodsID = GS1.GoodsID and D.StoreID= GS1.StoreID 
														Order By GS1.RowNo Desc)'
	if @AllocateGoodsToStore=1
		SET @StrSelect = @StrSelect+'	inner join inv.tblAllocateGoodsToStoreDtl b
									on D.StoreID=b.StoreID and substring(D.GoodsID,1,len(b.GoodsID))=b.GoodsID'													
	--------------------------------------------------------------
	IF (@ValueRanges Is Not Null) 
		SET @StrSelect = '
		SELECT TOTAL.*
		FROM
		(' + @StrSelect + ') TOTAL
		WHERE ' + @ValueRanges
	-- Sort Clause ---------------------------------------------
	IF (@SortFields Is Not Null) AND (@SortFields <> '') 
		SET @StrSelect = @StrSelect+ ' 
	ORDER BY ' + @SortFields 
	------------------------------------------------------------
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
