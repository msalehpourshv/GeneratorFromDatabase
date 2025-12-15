USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/05/29
-- Viewed By	 : 
-- Last Modified : 1393/08/14
-- Last Modifier : Hamid
-- Description	 : کارت کالا
-- ==============================================
Create PROCEDURE [inv].[RptStore_Cardex1_2]
	@GoodsID			VarChar(20) = '',
	@StoreID			VarChar(20) = Null,
	@UnitID				VarChar(20) = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@VolumeRowNo		int = 0,
	@SelectedStore		int = 0,
	@IncludeAcntName	Bit = 1, -- Include Acnt Name Column
	@PhysicallyEffected	Bit = Null, 
	@RepOptions			VarChar(20) = '111001111',
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(500) = ''

WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect		NVarChar(MAX);
Declare @StrSelect2		NVarChar(MAX);
Declare @StrFrom		NVarChar(4000);
Declare @StrWhere		NVarChar(4000);
Declare @StrWhereRemain		NVarChar(4000);
Declare @StrRemain		NVarChar(4000);
Declare @StrYear		Char(4);

Declare @SelectedAcnt1	int;
Declare @SelectedAcnt2	int;
Declare @SelectedAcnt3	int;
Declare @SelectedAcnt4	int;

Declare @StrTransPID			VarChar(20)
Declare @StrBuySale				VarChar(20)
Declare @StrStoreBalancingPID	VarChar(20)
Declare @DateField				varchar(10)
Declare @QtyStr					nvarchar(2000)
Declare @SubQtyStr					nvarchar(2000)
Declare @PrcStr					nvarchar(2000)
Declare @GoodsAmount			varchar(20)
Declare @LastCalc				char(10)
Declare @StrAmount				nvarchar(2000)
Declare @StrGroupByAmount		nvarchar(2000)

Declare @IncludeQuantity	Bit; -- Include Quantity Column
Declare @IncludePrice		Bit; -- Include Price Column
Declare @IncludeDescDtl		Bit; -- Include Dtl Desc Column
Declare @IncludeDescHdr		Bit; -- Include Hdr Desc Column
Declare @IncludeZeroAmount	Bit; -- Include Rows with Zero Amount
Declare @GroupByStore		Bit; -- Group By StoreID
Declare @ShowPrim			Bit;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

DECLARE	@FromPrdSerialID		Int;
DECLARE	@ToPrdSerialID			Int;
DECLARE	@FromBatchNo			Varchar(20);
DECLARE	@ToBatchNo				Varchar(20);
DECLARE	@FromExpDate			Varchar(10);
DECLARE	@ToExpDate				Varchar(10);
DECLARE	@HasSerial				Bit;
DECLARE	@SubUnitQty				Bit;
DECLARE	@BatchNo1			Varchar(20);
DECLARE	@BatchNo2			Varchar(20);
DECLARE	@BaseSendID				Varchar(20);
DECLARE	@DriverID				Varchar(20);
DECLARE	@LocationID				Varchar(20);

DECLARE	@SuspendedTransferGoods	Bit;
DECLARE	@SelectedUnitName		Varchar(50);

Declare @ShowGoodsImage			Bit;
DECLARE @UnitPart			TINYINT

DECLARE @UserPriceID			Varchar(20);

Declare @WithQuantityControl	Bit;
Declare @strUserPrice			NVarChar(200);
Declare @strUserPriceGrp		NVarChar(200);

Declare @bolAggregateSimilarGoods		Bit;

-- ======
DECLARE @goods_id					Varchar(20);
DECLARE @serial_no					int;
DECLARE @processid					int;
DECLARE @processno					int;
DECLARE @fiscalyear					int;
DECLARE @serialno					int;
DECLARE @rowno						int;
DECLARE @goods_quantity				DECIMAL(28,9);
DECLARE @goods_quantityInput		DECIMAL(28,9);
DECLARE @goods_quantityOutput		DECIMAL(28,9);
DECLARE @goods_quantityRemain		DECIMAL(28,9);

-- ======
DECLARE @unit_name			nvarchar(200);
DECLARE @unit_id			varchar(20);
DECLARE @unit_value			float;
DECLARE @unit_value_Temp	float;
DECLARE @Mainunit_value		float;
DECLARE @Cnt				INT;

-- ======
DECLARE @unit_nameInput1		nvarchar(200);
DECLARE @unit_idInput1			varchar(20);
DECLARE @unit_valueInput1		float;
DECLARE @Mainunit_valueInput1	float;

DECLARE @unit_nameInput2		nvarchar(200);
DECLARE @unit_idInput2			varchar(20);
DECLARE @unit_valueInput2		float;
DECLARE @Mainunit_valueInput2	float;

-- ======
DECLARE @unit_nameOutput1		nvarchar(200);
DECLARE @unit_idOutput1			varchar(20);
DECLARE @unit_valueOutput1		float;
DECLARE @Mainunit_valueOutput1	float;

DECLARE @unit_nameOutput2		nvarchar(200);
DECLARE @unit_idOutput2			varchar(20);
DECLARE @unit_valueOutput2		float;
DECLARE @Mainunit_valueOutput2	float;

-- ======
DECLARE @unit_nameRemain1		nvarchar(200);
DECLARE @unit_idRemain1			varchar(20);
DECLARE @unit_valueRemain1		float;
DECLARE @Mainunit_valueRemain1	float;

DECLARE @unit_nameRemain2		nvarchar(200);
DECLARE @unit_idRemain2			varchar(20);
DECLARE @unit_valueRemain2		float;
DECLARE @Mainunit_valueRemain2	float;

Declare @strQuantityControl		NVarChar(1000);
DECLARE @OtherFiscalYear		varchar(1)

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	SELECT @OtherFiscalYear = SettingValue from pub.tblSettings where SettingKey = 'OtherFiscalYear'

	IF @OtherFiscalYear IS NULL 
		SET @OtherFiscalYear = '0'

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	-- ==========
	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	IF @QuantityDecimalsToForms>0
		SET		@QuantityDecimalsToForms = @QuantityDecimalsToForms - 1

	-- ==========
	begin try
		drop table #tbl_result
	end try
	begin catch
	end catch
	
	Create Table #tbl_result
	(
		ProcessID				Int, 
		ProcessNo				Int,
		FiscalYear				Int,
		SerialNo				Int,
		RowNo					Int,
		GoodsID					varchar(20) collate Arabic_CS_AS null,
		TotalQuantityInput		DECIMAL(28,9),
		UnitNameInput1			nvarchar(20) collate Arabic_CS_AS null,
		TotalQuantityInput1		DECIMAL(28,9),
		UnitNameInput2			nvarchar(20) collate Arabic_CS_AS null,
		TotalQuantityInput2		DECIMAL(28,9),
		TotalQuantityOutput		DECIMAL(28,9),
		TotalQuantityOutput1	DECIMAL(28,9),
		TotalQuantityOutput2	DECIMAL(28,9),
		TotalQuantityRemain		DECIMAL(28,9),
		TotalQuantityRemain1	DECIMAL(28,9),
		TotalQuantityRemain2	DECIMAL(28,9)
	);
		
	Declare @tbl_units as table
	(
		unit_id					varchar(20) not null, 
		unit_name				nvarchar(200) not null, 
		unit_value				float not null,
		Mainunit_value			float not null,
		cnt						int not null--,
	);
	
	-- Init Variables -------------------------------------
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;
	set	@SelectedAcnt1 = 0;
	set	@SelectedAcnt2 = 0;
	set	@SelectedAcnt3 = 0;
	set	@SelectedAcnt4 = 0;

	SET @IncludeQuantity			= Substring(@RepOptions, 1, 1);
	SET @IncludePrice				= Substring(@RepOptions, 2, 1);
	SET @IncludeDescDtl				= Substring(@RepOptions, 3, 1);
	SET @IncludeDescHdr				= Substring(@RepOptions, 4, 1);
	SET @IncludeZeroAmount			= Substring(@RepOptions, 5, 1);
	SET @GroupByStore				= Substring(@RepOptions, 6, 1);
	SET @ShowPrim					= Substring(@RepOptions, 7, 1);
	SET @ShowGoodsImage				= Substring(@RepOptions, 8, 1);
	SET @WithQuantityControl		= Substring(@RepOptions, 9, 1);
	SET @bolAggregateSimilarGoods   = Substring(@RepOptions, 10, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

	set @LastCalc = ''
	
	select @LastCalc = IsNull(Max(ToDate), '')
	from inv.tblStorageCosts

	Set @StrTransPID			= '120, 125' -- انتقال کالا بین انبار
	Set @StrBuySale				= '55, 60, 90, 100' -- خرید و فروش
	Set @StrStoreBalancingPID	= '140, 145, 150, 155' -- تعدیل انبار
	Set @SelectedUnitName	= '' -- واحد انتخابی
	
	SET @FromPrdSerialID			 = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ToPrdSerialID				 = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @FromBatchNo				 = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @ToBatchNo					 = LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @FromExpDate				 = LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @ToExpDate					 = LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @HasSerial					 = LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @SuspendedTransferGoods		 = LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @SelectedUnitName			 = LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @BatchNo1					 = LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	SET @BatchNo2					 = LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	SET @BaseSendID					 = LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	SET @SubUnitQty					 = LTrim(pub.funSplitString(@ExtraParams, '@', 13));
	SET @LocationID					 = LTrim(pub.funSplitString(@ExtraParams, '@', 14));
	SET @UserPriceID				 = LTrim(pub.funSplitString(@ExtraParams, '@', 17));
		
	SET @StrYear = LTrim(RIGHT(db_name(), 4))
	
	select @SelectedAcnt1 = ObjectID
	from rpt.tblFilters
	where SessionNo = @SessionNo and ReportID = @ReportID and CodingTable = 'acc.tblAcnt' and PartNo = 1

	select @SelectedAcnt2 = ObjectID
	from rpt.tblFilters
	where SessionNo = @SessionNo and ReportID = @ReportID and CodingTable = 'acc.tblAcnt' and PartNo = 2

	select @SelectedAcnt3 = ObjectID
	from rpt.tblFilters
	where SessionNo = @SessionNo and ReportID = @ReportID and CodingTable = 'acc.tblAcnt' and PartNo = 3

	select @SelectedAcnt4 = ObjectID
	from rpt.tblFilters
	where SessionNo = @SessionNo and ReportID = @ReportID and CodingTable = 'acc.tblAcnt' and PartNo = 4
	
	-- ------------------------------------------------------
	set @GoodsAmount = LTRIM(inv.funGoodsAmount(@DocDateTo))
	if (@UnitID is null) 	
		select @UnitID =UnitID from inv.tblGoods Where GoodsID=@GoodsID
	if (@UnitID is null) 
		SET @UnitID = '0000000'
	--begin
		set @QtyStr = 'D.GoodsQuantity'
		set @PrcStr = 'D.' + @GoodsAmount
	--end
	--else
	--begin
	--	set @QtyStr = 'case when (D.SubUnitID = ''' + LTrim(@UnitID) + ''') then D.SubUnitQuantity else GoodsQuantity * (SU.UnitValue / SU.MainUnitValue) end '
	--	set @PrcStr = 'case when (D.GoodsQuantity = 0 or SubUnitQuantity = 0) then 0 else (D.' + @GoodsAmount + ' * D.GoodsQuantity) / (' + @QtyStr +') end'
	--end
	
	set @SubQtyStr = 'ISNULL(case when (D.SubUnitID = ''' + LTrim(@UnitID) + ''') then D.SubUnitQuantity else GoodsQuantity * (SU.UnitValue / SU.MainUnitValue) end,0) '
	
	-- Where Clause -----------------------------------------
	Select @StrWhere = ' D.EnterKind <>0 AND (D.GoodsID = ''' + @GoodsID + ''') '

	IF @OtherFiscalYear = '0'
		SET @StrWhere = @StrWhere +' AND (D.FiscalYear = ' + @StrYear + ')'

	If (@PhysicallyEffected Is Not Null)
		If (@PhysicallyEffected = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
		Else
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'

	if (@VolumeRowNo <> 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate<''' + @DocDateTo + ''' or (D.DocDate=''' + @DocDateTo + ''' and D.VolumeRowNo<=' + Ltrim(STR(@VolumeRowNo)) + '))'
	if (@StoreID is not null)
		SET @StrWhere = @StrWhere + ' AND (D.StoreID=''' + @StoreID + ''')'
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	If (@IncludeZeroAmount = 0)
		SET @StrWhere = @StrWhere + ' AND (D.' + @GoodsAmount + ' <> 0) '

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	if (@BatchNo1 is not null AND @BatchNo1 <>'' )
		SET @StrWhere = @StrWhere + ' AND (D.BatchNo>=''' + @BatchNo1 + ''')'	
	if (@BatchNo2 is not null AND @BatchNo2 <>'')
		SET @StrWhere = @StrWhere + ' AND (D.BatchNo<=''' + @BatchNo2 + ''')'
	
	IF (@UserPriceID Is Not Null) And (@UserPriceID <> '') And (@UserPriceID <> '0')
		SET @StrWhere = @StrWhere + ' AND (D.UserPriceID = ''' + LTrim(RTrim(@UserPriceID)) + ''')'

	SET @StrWhereRemain = ' AND ' + replace(@StrWhere ,'D.','b.')
	
	if (@DriverID is not null and @DriverID<>'' )
			SET @StrWhere = @StrWhere + ' AND (H.DriverID=''' + @DriverID + ''')'
	if (@LocationID is not null and @LocationID<>'')
			SET @StrWhere = @StrWhere + ' AND (H.LocationID=''' + @LocationID + ''')'
	if (@BaseSendID is not null and @BaseSendID<>'')
			SET @StrWhere = @StrWhere + ' AND (H.BaseSendID=''' + @BaseSendID + ''')'

	SET @StrRemain = @StrWhere 

	if (@IncludePrice = 1)
	begin
		set @DateField = 'DocDate'
		set @StrAmount = 'Sum(' + @PrcStr + ')'
		
		if (@bolAggregateSimilarGoods = 1)
			set @StrGroupByAmount = ', D.GoodsAmount11'
	end
	else
	begin
		set @DateField = 'DocDate'
		set @StrAmount = 'Sum(' + @PrcStr + ')'
		
		if (@bolAggregateSimilarGoods = 1)
		begin
			set @StrGroupByAmount = ''
		end
		else
		begin
			set @StrGroupByAmount = ', D.GoodsAmount11'
		end
	end
	
	If (@DocDateTo Is Not Null) OR (@DocDateFr Is Not Null)
		If (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (D.' + @DateField + ' = ''' + @DocDateFr + ''')'
		Else
		Begin
			If (@DocDateFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (D.' + @DateField + ' >= ''' + @DocDateFr + ''')'
			If (@DocDateTo Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (D.' + @DateField + ' <= ''' + @DocDateTo + ''')'
		End
		
	SET @strQuantityControl = ''
	SET @strUserPrice = ''''' GoodsUserPriceID, 0 UserPrice, 0 UserPriceQty, '
	SET @strUserPriceGrp = ''
	
	If @WithQuantityControl = 1
	Begin
		SET @strQuantityControl = 'LEFT JOIN inv.tblGoodsUserPrice GU ON GU.ID = D.UserPriceID --AND GU.UserPrice = D.GoodsQuantity '
		SET @strUserPrice = 'IsNull(GU.ID,0) GoodsUserPriceID, IsNull(GU.UParams,'''') UserPrice, IsNull(GU.GoodsQuantity,0) UserPriceQty, '
		SET @strUserPriceGrp = ', GU.ID, GU.UParams, GU.GoodsQuantity'
		--SET @StrWhere = @StrWhere + ' AND (D.UserPriceID <> 0) '
	End

	--=======================
	CREATE TABLE #tbl_Goods_Images
	(
		GoodsID   Varchar(20),
		GoodsImage Image
	);

	SET @StrSelect = '
	INSERT INTO #tbl_Goods_Images(GoodsID, GoodsImage)
	SELECT GoodsID, GoodsImage
	FROM inv.tblGoodsImages GI
	-- =========='
		
	--Print @StrSelect;
	EXEC sp_executesql @StrSelect;	
			
	------------------------------------------------------------
	declare @unit nvarchar (50)

	set @unit = '';

	IF (@UnitID IS NULL)
	Begin
		select @unit = isnull(UnitName , '')
		from inv.tblUnitsDtl 
		where UnitID = (select UnitID from inv.tblGoods where GoodsID =  SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart )
	End
	Else
	Begin
		select @unit = isnull(UnitName , '')
		from inv.tblUnitsDtl 
		where UnitID = @UnitID
	End
	
	-- From Clause ---------------------------------------------
	SET @StrFrom = 'inv.tblStorageDocsDtl D
		INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND 
											  H.SerialNo = D.SerialNo 
		INNER JOIN inv.tblGoods G on (G.GoodsID = ''' + SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) + ''') AND G.PartNumber=' + LTRIM(STR(@UnitPart)) + '
		' + @strQuantityControl + '
		LEFT JOIN pub.tblProcess PC ON D.ProcessID = PC.ProcessID AND D.ProcessNo = PC.ProcessNo
		LEFT JOIN inv.tblGoodsStatusDtl S on S.StoreID = D.StoreID and S.GoodsID = ''' + SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) + ''''
		
	IF (@UnitID is not null)
		SET @StrFrom = @StrFrom + '
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = ''' + @GoodsID + ''' AND SU.SubUnitID = ''' + Ltrim(@UnitID) + ''' '
		
	IF @FromBatchNo <> '' OR @ToBatchNo <> '' OR @FromExpDate <> '' OR @ToExpDate <> '' OR @FromPrdSerialID <> '' OR @ToPrdSerialID <> ''
	Begin
		SET @StrFrom = @StrFrom + '
		INNER JOIN inv.tblStorageDocsSerials SS ON SS.ProcessID = D.ProcessID AND SS.ProcessNo = D.ProcessNo AND SS.FiscalYear = D.FiscalYear AND SS.SerialNo = D.SerialNo AND SS.DocRowNo=D.DocRowNo ' + 
					Case When @FromPrdSerialID <> 0 Then ' And SS.ProductSerialID >= ''' + LTrim(RTrim(Str(@FromPrdSerialID))) + '''' Else '' End +
					Case When @ToPrdSerialID <> 0 Then ' And SS.ProductSerialID <= ''' + LTrim(RTrim(Str(@ToPrdSerialID))) + '''' Else '' End +
					Case When @FromBatchNo <> '' Then ' And SS.BatchNo >= ''' + LTrim(RTrim(@FromBatchNo)) + '''' Else '' End +
					Case When @ToBatchNo <> '' Then ' And SS.BatchNo <= ''' + LTrim(RTrim(@ToBatchNo)) + '''' Else '' End +
					Case When @FromExpDate <> '' Then ' And SS.ExpireDate >= ''' + LTrim(RTrim(@FromExpDate)) + '''' Else '' End +
					Case When @ToExpDate <> '' Then ' And SS.ExpireDate <= ''' + LTrim(RTrim(@ToExpDate)) + '''' Else '' End
	End	
			
	-- Select Clause -------------------------------------------
	begin try
		drop table ##tbl_Cardex1_2
	end try
	begin catch
	end catch
	
	IF @bolAggregateSimilarGoods = 0
	Begin
		SET @StrSelect = '
		SELECT D.GoodsID CGoodsID,D.ProcessID,D.ProcessNo,IsNull(PC.ProcessName, '''') ProcessName, D.AcntCode,
			D.' + @DateField + ' as DocDate, D.FiscalYear, D.RowNo, D.SerialNo, D.StoreID, D.StoreID2, D.EnterKind, 
			D.GoodsQuantity AS QuantityIn,' + @SubQtyStr + ' SubQuantityIn, D.GoodsQuantity AS QuantityOut,' + @SubQtyStr + ' SubQuantityOut, ' + @strUserPrice + '
			(SELECT SUM(GoodsQuantity*EnterKind) FROM inv.tblStorageDocsDtl b 
			 WHERE b.GoodsID= D.GoodsID and b.StoreID=D.StoreID AND (D.DocDate>b.DocDate OR (D.DocDate=b.DocDate and D.VolumeRowNo>=b.VolumeRowNo)) ' + @StrWhereRemain + ') Remain, 
			(SELECT SUM(ISNULL(case when (b.SubUnitID = ''' + LTrim(@UnitID) + ''') then b.SubUnitQuantity else GoodsQuantity * (SU.UnitValue / SU.MainUnitValue) end,0) *EnterKind) FROM inv.tblStorageDocsDtl b LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = ''' + SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) + ''' AND SU.SubUnitID = ''' + Ltrim(@UnitID) + ''' 
			 WHERE b.GoodsID= D.GoodsID and b.StoreID=D.StoreID AND (D.DocDate>b.DocDate OR (D.DocDate=b.DocDate and D.VolumeRowNo>=b.VolumeRowNo))' + @StrWhereRemain + ') SubRemain,			
			(SELECT StoreName FROM inv.tblStoresDtl I WHERE (I.StoreID = D.StoreID) AND (I.LanguageID = ' + @LangID + ')) StoreName,
			Case When D.BaseProcessID=93 Then D.BaseProcessID Else 0 End As PhrProcessID,
			Case When D.BaseProcessID=93 Then D.BaseProcessNo Else 0 End As PhrProcessNo,
			Case When D.BaseProcessID=93 Then D.BaseFiscalYear Else 0 End As PhrFiscalYear,
			Case When D.BaseProcessID=93 Then D.BaseSerialNo Else 0 End As PhrSerialNo,
			CASE WHEN (D.BaseSerialNo Is Not Null) THEN (LTrim(Str(D.BaseFiscalYear)) + ''/'' + LTrim(Str(D.BaseSerialNo))) ELSE ''-'' END AS RefSerial,
			CASE WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @PrcStr + ' ELSE (D.GoodsQuantity * ' + @PrcStr + ') END AS PriceIn, 
			CASE WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @PrcStr + ' ELSE (D.GoodsQuantity * ' + @PrcStr + ') END AS PriceOut, ' +
			CASE WHEN (@IncludeAcntName = 1) THEN ' CASE 
					WHEN D.ProcessID IN(' + @StrTransPID + ') THEN pub.GetStoreName(D.StoreID2, ' + @LangID + ')
					ELSE IsNull(pub.GetCodeName(D.AcntCode, ' + @LangID + '), CAST(''-'' AS NVarChar(50))) END ' ELSE ' CAST(''-'' AS NVarChar(50)) ' END + ' AS AcntName,' + 
			CASE WHEN (@IncludeDescHdr  = 1) THEN ' CASE WHEN H.DocDesc = '''' THEN CAST(''-'' AS NVarChar(250)) ELSE H.DocDesc END ' ELSE ' CAST(''-'' AS NVarChar(250)) ' END + 'AS DescHdr,' +
			CASE WHEN (@IncludeDescDtl  = 1) THEN ' CASE WHEN D.DescDtl = '''' THEN CAST(''-'' AS NVarChar(250)) ELSE D.DescDtl END ' ELSE ' CAST(''-'' AS NVarChar(250)) ' END + 'AS DescDtl, '
		SET @StrSelect2 = 
		   ' VolumeRowNo, cast(''' + ltrim(@unit) + ''' as nvarchar(50)) as UniName,G.ExtraField1,G.ExtraField2,G.ExtraField3,G.ExtraField4,G.ExtraField5,D.DocRowNo,H.VchNo,StoreVariable1,StoreVariable2,
			D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, H.AgreeNo, D.UserPriceID, D.VirtualQuantity, S.SetPoint, S.MaxPoint, S.FitPoint
		INTO ##tbl_Cardex1_2
		FROM ' + @StrFrom + '
		WHERE ' + @StrWhere
	End
	Else
	Begin
		SET @StrSelect = '
		SELECT D.GoodsID CGoodsID,D.ProcessID,D.ProcessNo,IsNull(PC.ProcessName, '''') ProcessName,D.AcntCode,
			D.' + @DateField + ' as DocDate,D.FiscalYear,D.SerialNo,D.RowNo,D.StoreID,D.StoreID2,D.EnterKind, 
			Sum(D.GoodsQuantity) AS QuantityIn,Sum(' + @SubQtyStr + ') SubQuantityIn, Sum(D.GoodsQuantity) AS QuantityOut,Sum(' + @SubQtyStr + ') SubQuantityOut, ' + @strUserPrice + '
			(SELECT SUM(GoodsQuantity*EnterKind) FROM inv.tblStorageDocsDtl b 
			 WHERE b.GoodsID= D.GoodsID and b.StoreID=D.StoreID AND (D.DocDate>b.DocDate OR (D.DocDate=b.DocDate and D.VolumeRowNo>=b.VolumeRowNo))' + @StrWhereRemain + ') Remain,
			(SELECT SUM(' + @SubQtyStr + '*EnterKind) FROM inv.tblStorageDocsDtl b 
			 WHERE b.GoodsID= D.GoodsID and b.StoreID=D.StoreID AND (D.DocDate>b.DocDate OR (D.DocDate=b.DocDate and D.VolumeRowNo>=b.VolumeRowNo))' + @StrWhereRemain + ') SubRemain,				
			(SELECT StoreName FROM inv.tblStoresDtl I WHERE (I.StoreID = D.StoreID) AND (I.LanguageID = ' + @LangID + ')) StoreName,
			0 As PhrProcessID, 0 As PhrProcessNo, 0 As PhrFiscalYear, 0 As PhrSerialNo, 0 AS RefSerial,
			CASE WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @StrAmount + ' ELSE Sum(D.GoodsQuantity * ' + @PrcStr + ') END AS PriceIn, 
			CASE WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @StrAmount + ' ELSE Sum(D.GoodsQuantity * ' + @PrcStr + ') END AS PriceOut, ' +
			CASE WHEN (@IncludeAcntName = 1) THEN ' CASE 
					WHEN D.ProcessID IN(' + @StrTransPID + ') THEN pub.GetStoreName(D.StoreID2, ' + @LangID + ')
					ELSE IsNull(pub.GetCodeName(D.AcntCode, ' + @LangID + '), CAST(''-'' AS NVarChar(50))) END ' ELSE ' CAST(''-'' AS NVarChar(50)) ' END + ' AS AcntName,
			'''' AS DescHdr, '''' AS DescDtl, (Select top 1 VolumeRowNo 
											   From inv.tblStorageDocsDtl a 
											   Where a.ProcessID=D.ProcessID and a.ProcessNo=D.ProcessNo and 
													 a.FiscalYear=D.FiscalYear and a.SerialNo=D.SerialNo and 
													 a.StoreID=D.StoreID AND a.GoodsID = ''' + @GoodsID + ''' ) VolumeRowNo, 
			Cast(''' + ltrim(@unit) + ''' as nvarchar(50)) as UniName,G.ExtraField1,
			G.ExtraField2,G.ExtraField3,G.ExtraField4,G.ExtraField5, 0 DocRowNo, H.VchNo, 0 StoreVariable1, 0 StoreVariable2,'
		SET @StrSelect2 = '
			0 BaseProcessID, 0 BaseProcessNo, 0 BaseFiscalYear, 0 BaseSerialNo, H.AgreeNo, 0 UserPriceID, D.VirtualQuantity,
			S.SetPoint, S.MaxPoint, S.FitPoint
		INTO ##tbl_Cardex1_2
		FROM ' + @StrFrom + '
		WHERE ' + @StrWhere + '
		Group By D.ProcessID, D.ProcessNo, PC.ProcessName, D.AcntCode, D.DocDate, D.FiscalYear, D.SerialNo, D.StoreID,
				 D.StoreID2, D.EnterKind, G.ExtraField1, G.ExtraField2, G.ExtraField3, G.ExtraField4, G.ExtraField5, 
				 H.VchNo, H.AgreeNo, D.VirtualQuantity, S.SetPoint, S.MaxPoint, S.FitPoint ' + @StrGroupByAmount + @strUserPriceGrp 
	End

	Print @StrSelect + @StrSelect2;
	set @StrSelect = @StrSelect + @StrSelect2
	Exec sp_executesql @StrSelect;

	If (@DocDateFr Is Not Null) And (@ShowPrim = 1)
	begin

SET @StrSelect = '
		INSERT INTO ##tbl_Cardex1_2
		SELECT '''' , 0 , 0 , ''مانده'' , '''' AcntCode, ''' + @DocDateFr + ''' , 0 , 0 , 0 , D.StoreID, '''' , 0 , 
			SUM(CASE WHEN EnterKind > 0 THEN D.GoodsQuantity ELSE 0 END) AS QuantityIn, 
			Sum(CASE WHEN EnterKind > 0 THEN ' + @SubQtyStr + ' ELSE 0 END) SubQuantityIn,
			SUM(CASE WHEN EnterKind < 0 THEN D.GoodsQuantity ELSE 0 END) AS QuantityOut, 
			Sum(CASE WHEN EnterKind < 0 THEN ' + @SubQtyStr + ' ELSE 0 END) SubQuantityOut,' + @strUserPrice + '
			(SELECT SUM(GoodsQuantity*EnterKind) 
			 FROM inv.tblStorageDocsDtl b 
			 WHERE b.GoodsID= D.GoodsID and b.StoreID=D.StoreID AND (D.DocDate>b.DocDate OR 
				  (D.DocDate=b.DocDate and D.VolumeRowNo>=b.VolumeRowNo))) Remain, 0 SubRemain,	
			(SELECT StoreName FROM inv.tblStoresDtl I WHERE (I.StoreID = D.StoreID) AND (I.LanguageID = ' + @LangID + ')) StoreName,
			0 PhrProcessID, 0 PhrProcessNo, 0 PhrFiscalYear, 0 PhrSerialNo,''-'' AS RefSerial,
			SUM( CASE WHEN (EnterKind < 0) THEN 0 ELSE  CASE WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @PrcStr + ' ELSE (D.GoodsQuantity * ' + @PrcStr + ') END END ) AS PriceIn,
			SUM( CASE WHEN (EnterKind > 0) THEN 0 ELSE	CASE WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @PrcStr + ' ELSE (D.GoodsQuantity * ' + @PrcStr + ') END END ) AS PriceOut,
			''-''  , ''-''  , ''-''  , -999999999  VolumeRowNo, cast(''' + ltrim(@unit) + ''' as nvarchar(50))  UniName,
			'''' , '''' , '''' , '''' , '''' , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , '''' AgreeNo, 0 , 0 , 0 , 0 , 0 FitPoint
					
					FROM  ' + @StrFrom + '
		WHERE ' + @StrRemain + ' AND (D.' + @DateField + ' < ''' + @DocDateFr + ''') 
		GROUP BY D.StoreID, D.GoodsID, D.DocDate, D.VolumeRowNo' + @strUserPriceGrp + '' 
		-- =========='
		Print @StrSelect;
		Exec sp_executesql @StrSelect;
	end

	-- ******************************************************************************
	--SET @StrSelect2 = '
	--INSERT INTO #tbl_result
	--Select S.ProcessID, S.ProcessNo, S.FiscalYear, S.SerialNo, S.RowNo, S.CGoodsID, '''', S.QuantityIn, '''', '''', 0, 
	--	   '''', '''', 0, S.QuantityOut, '''', '''', 0, '''', '''', 0, S.Remain, '''', '''', 0, '''', '''', 0, 0, 0, ''''
	--From ##tbl_Cardex1_2 S 
	---- =========='
	--print @StrSelect2;
	--Exec sp_executesql @StrSelect2;	
	
	--Select * From ##tbl_Cardex1_2
	--Drop Table ##tbl_Cardex1_2
	--Drop Table #tbl_result

	-- ******************************************************************************
	-- *********************************** Units ************************************
	-- ******************************************************************************
	INSERT INTO #tbl_result
	SELECT  ProcessID,				
			ProcessNo,				
			FiscalYear,				
			SerialNo,				
			RowNo,	
			GoodsID,
			
			TotalQuantityInput,
			UNameQuantityIn1,			
			FLOOR(TotalQuantityInput / U1) TotalQuantityInput1,
			UNameQuantityIn2,
			FLOOR((CASE WHEN U2 = 0 then 0 ELSE (TotalQuantityInput - (FLOOR((TotalQuantityInput / U1)+ 0.000000001) * U1))/U2 END)+0.000000001) TotalQuantityInput2,
			
			TotalQuantityOutput,
			FLOOR(TotalQuantityOutput / UO1) TotalQuantityOutput1,
			FLOOR((CASE WHEN UO2 = 0 then 0 ELSE (TotalQuantityOutput - (FLOOR((TotalQuantityOutput / UO1)+ 0.000000001) * UO1))/UO2 END)+0.000000001) TotalQuantityOutput2,
			
			TotalQuantityRemain,
			FLOOR(TotalQuantityRemain / UO1) TotalQuantityRemain1,
			FLOOR((CASE WHEN UR2 = 0 then 0 ELSE (TotalQuantityRemain - (FLOOR((TotalQuantityRemain / UR1)+ 0.000000001) * UR1))/UR2 END)+0.000000001) TotalQuantityRemain2
						
	FROM (
			Select Sale.ProcessID, Sale.ProcessNo, Sale.FiscalYear, Sale.SerialNo, Sale.RowNo, Sale.GoodsID,
				   IsNull(Sum(Sale.QuantityIn),0) TotalQuantityInput, IsNull(Sum(Sale.QuantityOut),0) TotalQuantityOutput,
				   IsNull(Sum(Sale.QuantityRemain),0) TotalQuantityRemain,
				   (
					   Select Top 1 (t.MainUnitValue/ t.UnitValue)
					   From
						   (
								select UnitID, 1 As UnitValue,1 MainUnitValue
								from inv.tblGoods
								where GoodsID = Sale.GoodsID
								union
								select SubUnitID, UnitValue,MainUnitValue
								from inv.tblSubUnitsDtl S
								where GoodsID = Sale.GoodsID And ShowInInvoice = 1
								
							) t 
						Inner Join inv.tblUnitsDtl u On u.UnitID = t.UnitID and u.LanguageID = 1
						order by (t.MainUnitValue/ t.UnitValue) desc
					) U1,
					(
					 Select top 1 u.UnitName
					 From
						(
							select UnitID, 1 As UnitValue,1 MainUnitValue
							from inv.tblGoods
							where GoodsID = Sale.GoodsID
							union
							select SubUnitID, UnitValue,MainUnitValue
							from inv.tblSubUnitsDtl S
							where GoodsID = Sale.GoodsID And ShowInInvoice = 1
							
						) t 
					 Inner Join inv.tblUnitsDtl u On u.UnitID = t.UnitID and u.LanguageID = 1
					 order by (t.MainUnitValue/ t.UnitValue) desc
					) UNameQuantityIn1,
				   ISNULL((
	   						Select UU 
	   						From 
	   							(
	   								Select (t.MainUnitValue / t.UnitValue) UU,
	   										ROW_NUMBER()over(order by (t.MainUnitValue / t.UnitValue) desc) R
									From
									(
										select UnitID, 1 As UnitValue,1 MainUnitValue
										from inv.tblGoods
										where GoodsID = Sale.GoodsID
										union
										select SubUnitID, UnitValue, MainUnitValue
										from inv.tblSubUnitsDtl S
										where GoodsID = Sale.GoodsID And ShowInInvoice = 1
									) t 
									Inner Join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = 1
	   							) U2 WHERE R = 2
	   						  ), 0) U2,
				   ISNULL((
							Select UnitName 
							From 
								(
									select UnitName,
										   ROW_NUMBER()over(order by (t.MainUnitValue / t.UnitValue) desc) R
									from
										(
											select UnitID, 1 As UnitValue,1 MainUnitValue
											from inv.tblGoods
											where GoodsID = Sale.GoodsID
											union
											select SubUnitID, UnitValue, MainUnitValue
											from inv.tblSubUnitsDtl S
											where GoodsID = Sale.GoodsID And ShowInInvoice = 1
										) t 
									Inner Join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = 1
								) U2 WHERE R = 2
							), '') UNameQuantityIn2,
				   (
					   Select Top 1 (t.MainUnitValue/ t.UnitValue)
					   From
						   (
								select UnitID, 1 As UnitValue,1 MainUnitValue
								from inv.tblGoods
								where GoodsID = Sale.GoodsID
								union
								select SubUnitID, UnitValue,MainUnitValue
								from inv.tblSubUnitsDtl S
								where GoodsID = Sale.GoodsID And ShowInInvoice = 1
								
							) t 
						Inner Join inv.tblUnitsDtl u On u.UnitID = t.UnitID and u.LanguageID = 1
						order by (t.MainUnitValue/ t.UnitValue) desc
					) UO1,
				   ISNULL((
	   						Select UU 
	   						From 
	   							(
	   								Select (t.MainUnitValue / t.UnitValue) UU,
	   										ROW_NUMBER()over(order by (t.MainUnitValue / t.UnitValue) desc) R
									From
									(
										select UnitID, 1 As UnitValue,1 MainUnitValue
										from inv.tblGoods
										where GoodsID = Sale.GoodsID
										union
										select SubUnitID, UnitValue, MainUnitValue
										from inv.tblSubUnitsDtl S
										where GoodsID = Sale.GoodsID And ShowInInvoice = 1
									) t 
									Inner Join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = 1
	   							) U2 WHERE R = 2
	   						  ), 0) UO2,
				   (
					   Select Top 1 (t.MainUnitValue/ t.UnitValue)
					   From
						   (
								select UnitID, 1 As UnitValue,1 MainUnitValue
								from inv.tblGoods
								where GoodsID = Sale.GoodsID
								union
								select SubUnitID, UnitValue,MainUnitValue
								from inv.tblSubUnitsDtl S
								where GoodsID = Sale.GoodsID And ShowInInvoice = 1
								
							) t 
						Inner Join inv.tblUnitsDtl u On u.UnitID = t.UnitID and u.LanguageID = 1
						order by (t.MainUnitValue/ t.UnitValue) desc
					) UR1,
				   ISNULL((
	   						Select UU 
	   						From 
	   							(
	   								Select (t.MainUnitValue / t.UnitValue) UU,
	   										ROW_NUMBER()over(order by (t.MainUnitValue / t.UnitValue) desc) R
									From
									(
										select UnitID, 1 As UnitValue,1 MainUnitValue
										from inv.tblGoods
										where GoodsID = Sale.GoodsID
										union
										select SubUnitID, UnitValue, MainUnitValue
										from inv.tblSubUnitsDtl S
										where GoodsID = Sale.GoodsID And ShowInInvoice = 1
									) t 
									Inner Join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = 1
	   							) U2 WHERE R = 2
	   						  ), 0) UR2
			From (
					Select S.ProcessID, S.ProcessNo, S.FiscalYear, S.SerialNo, S.RowNo, S.CGoodsID GoodsID, S.QuantityIn, 
						   '''' UNameQuantityIn1, 0 QuantityIn1, '''' UNameQuantityIn2, 0 QuantityIn2, 
						   S.QuantityOut, 0 QuantityOut1, 0 QuantityOut2, 
						   S.Remain QuantityRemain, 0 QuantityRemain1, 0 QuantityRemain2
					From ##tbl_Cardex1_2 S 
				  ) Sale
			Left Join 
				( 
					select  D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, D.BaseDocRowNo, D.GoodsID, 
							SUM(D.GoodsQuantity) GoodsQuantity--,SUM(case when NOT(@UnitID IS NULL) OR (D.SubUnitID =LTrim(@UnitID)) then D.SubUnitQuantity else GoodsQuantity * (SU.UnitValue / SU.MainUnitValue) end)SubGoodsQuantity
					from	inv.tblStorageDocsHdr H
					Inner Join inv.tblStorageDocsDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And
														  D.SerialNo = H.SerialNo
					Left Join sal.tblDistributionsHdr DH ON DH.ProcessID = H.BaseDistributionProcessID And
															 DH.SerialNo = H.BaseDistributionSerialNo 											  
					where  (H.ProcessID = 100) And (D.ProcessID in (100)) AND (D.ProcessNo IN (1))
					group by D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, D.BaseDocRowNo, D.GoodsID
				) Ret ON Sale.ProcessID = Ret.BaseProcessID And Sale.ProcessNo = Ret.BaseProcessNo And
						 Sale.FiscalYear = Ret.BaseFiscalYear And Sale.SerialNo = Ret.BaseSerialNo And
						 Sale.RowNo = Ret.BaseDocRowNo
			Group By Sale.ProcessID, Sale.ProcessNo, Sale.FiscalYear, Sale.SerialNo, Sale.RowNo, Sale.GoodsID
		) a
	-- ******************************************************************************
	-- ********************************* Units End **********************************
	-- ******************************************************************************
	--Select * From #tbl_result
	
	if @SubUnitQty= '1'
		UPDATE #tbl_result
		SET UnitNameInput1 = (select isnull(UnitName , '')
							  from inv.tblUnitsDtl 
							  where UnitID = (select UnitID from inv.tblGoods where GoodsID =  SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart ) and LanguageID = @LangID ) 
		   ,UnitNameInput2 = ISNULL((select isnull(UnitName , '')
							  from inv.tblUnitsDtl 
							  where UnitID = (select SubUnitID from inv.tblSubUnitsDtl where GoodsID =  @GoodsID and ShowInInvoice='True' ) and LanguageID = @LangID ),'')
	
	--==================================
	SET @StrSelect = '
	SELECT T.*, G.GoodsID, ' + 
	Case When @ShowGoodsImage = 1 Then 'GI1.GoodsImage, ' Else 'Null As GoodsImage, ' End + '
	G.TechnicalSpecifications, G.TechnicalNo, G.MiscSpecifications, G.GoodsLength, G.GoodsWidth, G.GoodsHeight, G.GoodsWeight
	FROM ##tbl_Cardex1_2 T 
	INNER JOIN inv.tblGoods G on (G.GoodsID = ''' + SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) + ''')	AND G.PartNumber=' + LTRIM(STR(@UnitPart)) + 
	Case When @ShowGoodsImage = 1 Then ' LEFT JOIN #tbl_Goods_Images GI1 ON GI1.GoodsID = ''' + @GoodsID + ''' ' Else ' ' End
		
	SET @StrSelect = '
	select T.*, --S.SetPoint, S.MaxPoint, S.FitPoint, S.RecDesc,
		R.BaseFiscalYear as PorduceOrderFiscalYear, R.BaseSerialNo as ProduceOrderSerialNo,
		ROUND(IsNull(R2.TotalQuantityInput,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityInput, '''' RUnitIDInput1,
		IsNull(R2.UnitNameInput1,'''') RUnitNameInput1, ROUND(IsNull(R2.TotalQuantityInput1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityInput1,
		'''' RUnitIDInput2,IsNull(R2.UnitNameInput2,'''') RUnitNameInput2, 
		ROUND(IsNull(R2.TotalQuantityInput2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityInput2,		
		ROUND(IsNull(R2.TotalQuantityOutput,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityOutput, '''' RUnitIDOutput1,
		IsNull(R2.UnitNameInput1,'''') RUnitNameOutput1, ROUND(IsNull(R2.TotalQuantityOutput1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityOutput1,
		'''' RUnitIDOutput2,IsNull(R2.UnitNameInput2,'''') RUnitNameOutput2, 
		ROUND(IsNull(R2.TotalQuantityOutput2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityOutput2, 
		ROUND(IsNull(R2.TotalQuantityRemain,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityRemain, '''' RUnitIDRemain1,
		IsNull(R2.UnitNameInput1,'''') RUnitNameRemain1, ROUND(IsNull(R2.TotalQuantityRemain1,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityRemain1,
		'''' RUnitIDRemain2,IsNull(R2.UnitNameInput2,'''') RUnitNameRemain2, 
		ROUND(IsNull(R2.TotalQuantityRemain2,0), ' + LTrim(RTrim(Str(@QuantityDecimalsToForms))) + ') RTotalQuantityRemain2, 		
		0 RWeight, 0 RVolume, '''' RBarCode		
		
	into ##tbl_Store_Cardex
	from 
	(' + @StrSelect + '
	) T 
		left join pln.tblItemRelations R on R.ProcessID=T.BaseProcessID and R.ProcessNo=T.BaseProcessNo and R.FiscalYear=T.BaseFiscalYear and R.SerialNo=T.BaseSerialNo
		left join (select StoreID, GoodsID, min(RowNo) MinRowNo from inv.tblGoodsStatusDtl GROUP BY StoreID, GoodsID) S0 on S0.StoreID = T.StoreID and S0.GoodsID = ''' + Ltrim(@GoodsID) + ''' 
		left join inv.tblGoodsStatusDtl S on S.StoreID = S0.StoreID and S.GoodsID = ''' + Ltrim(@GoodsID) + ''' and S.RowNo = S0.MinRowNo
		left join sal.tblDistributionsDtl DD ON BaseSaleProcessID=T.ProcessID AND BaseSaleProcessNo=T.ProcessNo AND 
												BaseSaleFiscalYear=T.FiscalYear AND BaseSaleSerialNo=T.SerialNo		
		left join #tbl_result R2 on R2.GoodsID = ''' + Ltrim(@GoodsID) + ''' And R2.ProcessID = T.ProcessID And 
									R2.ProcessNo = T.ProcessNo And R2.FiscalYear = T.FiscalYear And 
									R2.SerialNo = T.SerialNo And R2.RowNo = T.RowNo ' 
	If (@GroupByStore = 1)
	SET @StrSelect = @StrSelect + '
	ORDER BY StoreID, ' + @DateField + ', VolumeRowNo,ProcessID '
	Else
	SET @StrSelect = @StrSelect + '
	ORDER BY ' + @DateField + ', VolumeRowNo,ProcessID 
	-- =========='
		
	begin try
		drop table ##tbl_Store_Cardex
	end try
	begin catch
	end catch

	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	Declare @val01 AS bit
	
	SET @val01 = 0
	
	SELECT @val01 = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'Inv_AcntPermitInRpts'
	
	if (@UserIsAdmin = 0)
	begin
		exec pub.SpFilterByPermission2 '##tbl_Store_Cardex', 'StoreID', 'inv.tblStores', @UserID;
		exec pub.SpFilterByPermission2 '##tbl_Store_Cardex', 'GoodsID', 'inv.tblGoods', @UserID;
		if (@val01 = 1)
			exec pub.SpFilterByPermission2 '##tbl_Store_Cardex', 'AcntCode', 'acc.tblAcnt', @UserID;
	end
	
	select X.*, @LastCalc as LastAmountDate
	from ##tbl_Store_Cardex X
	------------------------------------------------------------
END
GO
