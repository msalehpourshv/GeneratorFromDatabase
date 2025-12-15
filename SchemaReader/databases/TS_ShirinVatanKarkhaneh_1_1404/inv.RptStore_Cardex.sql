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
Create PROCEDURE [inv].[RptStore_Cardex]
	@GoodsID			VarChar(20) = '01000001',
	@StoreID			VarChar(20) = null,
	@UnitID				VarChar(20) = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@VolumeRowNo		int = 0,
	@SelectedStore		int = 0,
	@IncludeAcntName	Bit = 1, -- Include Acnt Name Column
	@PhysicallyEffected	Bit = null, 
	@RepOptions			VarChar(20) = '111001111',
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		nvarchar(500) = ''

WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect			NVarChar(MAX);
Declare @StrSelectP1		NVarChar(MAX);
Declare @StrSelectP2		NVarChar(MAX);
Declare @StrSelectP3		NVarChar(MAX);
Declare @StrSelectP4		NVarChar(MAX);
Declare @StrFrom			NVarChar(MAX);
Declare @StrWhere			NVarChar(MAX);
Declare @StrRemain			NVarChar(MAX);
Declare @StrYear			Char(4);
Declare @strQuantityControl	NVarChar(1000);

Declare @SelectedAcnt1	int;
Declare @SelectedAcnt2	int;
Declare @SelectedAcnt3	int;
Declare @SelectedAcnt4	int;

Declare @StrTransPID			VarChar(20)
Declare @StrBuySale				VarChar(20)
Declare @StrStoreBalancingPID	VarChar(20)
Declare @DateField				varchar(10)
Declare @QtyStr					nvarchar(2000)
Declare @PrcStr					nvarchar(2000)
Declare @AmtStr					nvarchar(2000)
Declare @GoodsAmount			varchar(20)
Declare @LastCalc				char(10)
Declare @StrAmount				nvarchar(2000)
Declare @StrAmt					nvarchar(2000)
Declare @StrGroupByAmount		nvarchar(2000)
Declare @StrGroupByAmt			nvarchar(2000)

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

DECLARE	@FromPrdSerialID		NVARCHAR(20);
DECLARE	@ToPrdSerialID			NVARCHAR(20);
DECLARE	@FromBatchNo			Varchar(20);
DECLARE	@ToBatchNo				Varchar(20);
DECLARE	@FromExpDate			Varchar(10);
DECLARE	@ToExpDate				Varchar(10);
DECLARE	@HasSerial				Bit;
DECLARE	@BatchNo1				Varchar(20);
DECLARE	@BatchNo2				Varchar(20);
DECLARE	@BaseSendID				Varchar(20);
DECLARE	@DriverID				Varchar(20);
DECLARE	@LocationID				Varchar(20);

DECLARE	@SuspendedTransferGoods	Bit;
DECLARE	@SelectedUnitName		Varchar(50);

Declare @ShowGoodsImage			Bit;
DECLARE @UnitPart				TINYINT
DECLARE @OtherFiscalYear		varchar(1)

DECLARE @UserPriceID			Varchar(20);

Declare @WithQuantityControl	Bit;
Declare @strUserPrice			NVarChar(200);
Declare @strUserPriceGrp		NVarChar(200);

Declare @bolAggregateSimilarGoods		Bit;
DECLARE	@ContainerID			VarChar(20);
DECLARE	@ContainerID2			VarChar(20);
DECLARE	@ContainerStoresID		VarChar(20);
DECLARE	@ContainerStoresID2		VarChar(20);
DECLARE	@HasContainer			Bit;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	SET @UnitPart  = 1
	SET @OtherFiscalYear  = '0'

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'
	SELECT @OtherFiscalYear = SettingValue from pub.tblSettings where SettingKey = 'OtherFiscalYear'

	IF @OtherFiscalYear IS NULL 
		SET @OtherFiscalYear = '0'

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
	

	SET @LangID				 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);

	SET @LastCalc = ''
	
	select @LastCalc = IsNull(Max(ToDate), '')
	from inv.tblStorageCosts

	Set @StrTransPID			= '120, 125' -- انتقال کالا بین انبار
	Set @StrBuySale				= '55, 60, 90, 100' -- خرید و فروش
	Set @StrStoreBalancingPID	= '51,140, 145, 150, 155' -- تعدیل انبار
	Set @SelectedUnitName	= '' -- واحد انتخابی
	
	SET @FromPrdSerialID		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ToPrdSerialID			= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @FromBatchNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @ToBatchNo				= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @FromExpDate			= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @ToExpDate				= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @HasSerial				= LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @SuspendedTransferGoods	= LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @SelectedUnitName		= LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @BatchNo1				= LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	SET @BatchNo2				= LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	SET @BaseSendID				= LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	SET @DriverID				= LTrim(pub.funSplitString(@ExtraParams, '@', 13));
	SET @LocationID				= LTrim(pub.funSplitString(@ExtraParams, '@', 14));
	SET @UserPriceID			= LTrim(pub.funSplitString(@ExtraParams, '@', 17));
	SET @ContainerID			= LTrim(pub.funSplitString(@ExtraParams, '@', 18));		
	SET @ContainerID2			= LTrim(pub.funSplitString(@ExtraParams, '@', 19));		
	SET @HasContainer			= LTrim(pub.funSplitString(@ExtraParams, '@', 20));
	SET @ContainerStoresID		= LTrim(pub.funSplitString(@ExtraParams, '@', 22));		
	SET @ContainerStoresID2		= LTrim(pub.funSplitString(@ExtraParams, '@', 23));		
	
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
	declare @StrAmountT varchar (200) = ''
	set @GoodsAmount = LTRIM(inv.funGoodsAmount(@DocDateTo))
	Set @StrAmountT = 'GoodsAmount'


	if (@UnitID is null) 
	begin
		set @QtyStr = 'D.GoodsQuantity'
		set @PrcStr = 'D.' + @GoodsAmount
		Set @AmtStr = 'D.' + @StrAmountT +''
	end
	else
	begin
		set @QtyStr = 'case when (D.SubUnitID = ''' + LTrim(@UnitID) + ''') then D.SubUnitQuantity else D.GoodsQuantity * (SU.UnitValue / SU.MainUnitValue) end '
		set @PrcStr = 'case when (D.GoodsQuantity = 0 or D.SubUnitQuantity = 0) then 0 else (D.' + @GoodsAmount + ' * D.GoodsQuantity) / (' + @QtyStr +') end'
		set @AmtStr = 'case when (D.GoodsQuantity = 0 or D.SubUnitQuantity = 0) then 0 else (D.' + @StrAmountT +' * D.GoodsQuantity) / (' + @QtyStr +') end'
	end

	-- Where Clause -----------------------------------------
	Select @StrWhere = ' (D.EnterKind <> 0 OR ((H.ProcessID=51 or H.ProcessID=188  or H.ProcessID=189 ) and D.EnterKind=0)) AND (D.GoodsID = ''' + @GoodsID + ''') '
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
	if (@DriverID is not null and @DriverID<>'' )
			SET @StrWhere = @StrWhere + ' AND (H.DriverID=''' + @DriverID + ''')'
	if (@LocationID is not null and @LocationID<>'')
			SET @StrWhere = @StrWhere + ' AND (H.LocationID=''' + @LocationID + ''')'
	if (@BaseSendID is not null and @BaseSendID<>'')
			SET @StrWhere = @StrWhere + ' AND (H.BaseSendID=''' + @BaseSendID + ''')'

	IF (@UserPriceID Is Not Null) And (@UserPriceID <> '') And (@UserPriceID <> '0')
		SET @StrWhere = @StrWhere + ' AND (D.UserPriceID = ''' + LTrim(RTrim(@UserPriceID)) + ''')'
		
	SET @StrRemain = @StrWhere 

	if (@IncludePrice = 1)
	begin
		set @DateField = 'DocDate'
		set @StrAmount = 'Sum(' + @PrcStr + ')'
		Set @StrAmt	 = 'Sum('+@AmtStr+')'
		
		if (@bolAggregateSimilarGoods = 1)
			set @StrGroupByAmount = ', D.GoodsAmount11'
	end
	else
	begin
		set @DateField = 'DocDate'
		set @StrAmount = 'Sum(' + @PrcStr + ')'
		set @StrAmt = 'Sum('+@AmtStr+')'
		
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

	------------------------------------------------------------
	declare @unit nvarchar (50)

	set @unit = '';

	IF (@UnitID IS NULL)
	Begin
		SELECT @unit = isnull(UnitName , '')
		FROM inv.tblUnitsDtl 
		WHERE LanguageID =  @LangID AND UnitID = (select UnitID from inv.tblGoods where GoodsID =  SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) AND PartNumber=@UnitPart )
	End
	Else
	Begin
		select @unit = isnull(UnitName , '')
		from inv.tblUnitsDtl 
		where LanguageID =  @LangID AND UnitID = @UnitID 
	End
	
	-- From Clause ---------------------------------------------
	SET @StrFrom = 'inv.tblStorageDocsDtl D
		INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND 
											  H.SerialNo = D.SerialNo 
		INNER JOIN inv.tblGoods G on (G.GoodsID = ''' + SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) + ''') AND G.PartNumber = ' + LTRIM(STR(@UnitPart)) + '
		' + @strQuantityControl + '
		LEFT JOIN pub.tblProcess PC ON D.ProcessID = PC.ProcessID AND D.ProcessNo = PC.ProcessNo
		LEFT JOIN inv.tblGoodsStatusDtl S on S.StoreID = D.StoreID and S.GoodsID = ''' + SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) + ''''

	IF (@UnitID is not null)
		SET @StrFrom = @StrFrom + '
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = ''' + @GoodsID + ''' AND SU.SubUnitID = ''' + Ltrim(@UnitID) + ''' '
		 
	IF @ContainerID <> '' OR @ContainerID2 <> '' OR 
	   @ContainerStoresID <> '' OR @ContainerStoresID2 <> '' OR 
	   @FromBatchNo <> '' OR @ToBatchNo <> '' OR 
	   @FromExpDate <> '' OR @ToExpDate <> '' OR 
	   ((@FromPrdSerialID <> '' OR @ToPrdSerialID <> '') AND (@FromPrdSerialID <> '0' OR @ToPrdSerialID <> '0'))
	Begin
		SET @StrFrom = @StrFrom + '
		INNER JOIN inv.tblStorageDocsSerials SS ON SS.ProcessID = D.ProcessID AND SS.ProcessNo = D.ProcessNo AND SS.FiscalYear = D.FiscalYear AND SS.SerialNo = D.SerialNo AND SS.DocRowNo=D.DocRowNo ' + 
					Case When @FromPrdSerialID	  <> '' and @FromPrdSerialID <> '0' Then ' AND SS.PSerialNo	>= ''' + LTrim(RTrim(@FromPrdSerialID)) + ''''	Else '' End +
					Case When @ToPrdSerialID	  <> '' and @ToPrdSerialID <> '0' Then ' AND SS.PSerialNo	<= ''' + LTrim(RTrim(@ToPrdSerialID)) + ''''	Else '' End +
					Case When @FromBatchNo		  <> '' Then ' AND SS.BatchNo >= ''' + LTrim(RTrim(@FromBatchNo)) + '''' Else '' End +
					Case When @ToBatchNo		  <> '' Then ' AND SS.BatchNo <= ''' + LTrim(RTrim(@ToBatchNo)) + '''' Else '' End +
					Case When @ContainerID		  <> '' Then ' AND SS.ContainerID >= ''' + LTrim(RTrim(@ContainerID)) + '''' Else '' End +
					Case When @ContainerID2		  <> '' Then ' AND SS.ContainerID <= ''' + LTrim(RTrim(@ContainerID2)) + '''' Else '' End +
					Case When @ContainerStoresID  <> '' Then ' AND SS.ContainerStoresID >= ''' + LTrim(RTrim(@ContainerStoresID)) + '''' Else '' End +
					Case When @ContainerStoresID2 <> '' Then ' AND SS.ContainerStoresID <= ''' + LTrim(RTrim(@ContainerStoresID2)) + '''' Else '' End +
					Case When @FromExpDate		  <> '' Then ' AND SS.ExpireDate >= ''' + LTrim(RTrim(@FromExpDate)) + ''''	Else '' End +
					Case When @ToExpDate		  <> '' Then ' AND SS.ExpireDate <= ''' + LTrim(RTrim(@ToExpDate)) + '''' Else '' End + '
	   '
	End			
	------------------------------------------------------------

	-- Select Clause -------------------------------------------
	begin try
		drop table ##tbl_Cardex
	end try
	begin catch
	end catch
	
	IF @bolAggregateSimilarGoods = 0
	Begin
		SET @StrSelectP1 = '
		SELECT DISTINCT D.ProcessID, D.ProcessNo,
		case when D.ProcessID=120 then		 IsNull(PC.ProcessName, '''') +''  به انبار '' + isnull(S2.StoreName,'''')
		 when D.ProcessID=125 then		 IsNull(PC.ProcessName, '''') +'' از انبار '' + isnull(S2.StoreName,'''')
		 when D.ProcessID in (72,73,82,82) then		 IsNull(PC.ProcessName, '''') +'' از سفارش '' + LTRIM(STR(D.BaseSerialNo))
		 else 		 IsNull(PC.ProcessName, '''') 		 end ProcessName, D.AcntCode,
			D.' + @DateField + ' as DocDate, D.FiscalYear, D.SerialNo, D.StoreID, D.StoreID2, D.EnterKind, 
			' + @QtyStr + ' AS QuantityIn, ' + @QtyStr + ' AS QuantityOut, ' + @strUserPrice + '
			isnull(S1.StoreName,'''') StoreName,isnull(S2.StoreName,'''') StoreName2,
			Case When D.BaseProcessID = 93 Then D.BaseProcessID Else 0 End As PhrProcessID,
			Case When D.BaseProcessID = 93 Then D.BaseProcessNo Else 0 End As PhrProcessNo,
			Case When D.BaseProcessID = 93 Then D.BaseFiscalYear Else 0 End As PhrFiscalYear,
			Case When D.BaseProcessID = 93 Then D.BaseSerialNo Else 0 End As PhrSerialNo,
			CASE WHEN (D.BaseSerialNo Is Not Null) THEN (LTrim(Str(D.BaseFiscalYear)) + ''/'' + LTrim(Str(D.BaseSerialNo))) ELSE ''-'' END AS RefSerial,
			CASE WHEN D.ProcessID = 51 THEN D.GoodsPrice WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @AmtStr + ' ELSE (' + @QtyStr + ' * ' + @AmtStr + ') END AS AmountIn, 
			CASE WHEN D.ProcessID = 51 THEN D.GoodsPrice WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @AmtStr + ' ELSE (' + @QtyStr + ' * ' + @AmtStr + ') END AS AmountOut,'
		Set @StrSelectP4 ='
			CASE WHEN D.ProcessID = 51 THEN D.GoodsPrice WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @PrcStr + ' ELSE (' + @QtyStr + ' * ' + @PrcStr + ') END AS PriceIn, 
			CASE WHEN D.ProcessID = 51 THEN D.GoodsPrice WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @PrcStr + ' ELSE (' + @QtyStr + ' * ' + @PrcStr + ') END AS PriceOut, ' +
			CASE WHEN (@IncludeAcntName = 1) THEN ' CASE 
					WHEN D.ProcessID IN(' + @StrTransPID + ') THEN pub.GetStoreName(D.StoreID2, ' + @LangID + ')
					ELSE IsNull(pub.GetCodeName(D.AcntCode, ' + @LangID + '), CAST(''-'' AS NVarChar(50))) END ' ELSE ' CAST(''-'' AS NVarChar(50)) ' END + ' AS AcntName,' + 
			CASE WHEN (@IncludeDescHdr  = 1) THEN ' CASE WHEN H.DocDesc = '''' THEN CAST(''-'' AS NVarChar(250)) ELSE H.DocDesc END ' ELSE ' CAST(''-'' AS NVarChar(250)) ' END + 'AS DescHdr,' +
			CASE WHEN (@IncludeDescDtl  = 1) THEN ' CASE WHEN D.DescDtl = '''' THEN CAST(''-'' AS NVarChar(250)) ELSE D.DescDtl END ' ELSE ' CAST(''-'' AS NVarChar(250)) ' END + 'AS DescDtl, 
			VolumeRowNo, cast(''' + ltrim(@unit) + ''' as nvarchar(50)) as UniName,G.GoodsClassificationID,
			[inv].[funGoodsClassificationName](G.GoodsClassificationID,' + @LangID + ') GoodsClassificationName,G.ExtraField1,G.ExtraField2,G.ExtraField3,G.ExtraField4,G.ExtraField5,D.DocRowNo,
			H.VchNo,StoreVariable1,StoreVariable2,
			D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, H.AgreeNo, D.UserPriceID, D.VirtualQuantity, S.SetPoint, S.MaxPoint, S.FitPoint,
			D.Var1,D.Var2,D.Var3,D.Var4,H.DriverID,DR.FirstName,DR.LastName,
					   D.SubUnitQuantity / (Case When D.VirtualQuantity = 0 Then 1 Else D.VirtualQuantity End) Averge, D.BatchNo, H.GoodsReciverID,
					   [inv].[funGetBatchName](D.BatchNo,' + LTrim(RTrim(@LangID)) + ') BatchNameDtl,
					   [inv].[funGetReciverName]( H.GoodsReciverID,1) GoodsReciverName,
					   [inv].[GetGoodsPlaceNameFromStore](S.StoreID,S.DocRowNo,' + @LangID + ') PlaceName'

		Set @StrSelectP2 = '
		INTO ##tbl_Cardex
		FROM ' + @StrFrom + ' 
		LEFT  JOIN pub.tblDriversDtl DR on H.DriverID=DR.DriverID and DR.LanguageID=' + @LangID + '
		LEFT  JOIN inv.tblStoresDtl S1 on S1.StoreID=D.StoreID and S1.LanguageID=' + @LangID + '
		LEFT  JOIN inv.tblStoresDtl S2 on S2.StoreID=D.StoreID2 and S2.LanguageID=' + @LangID + '
		WHERE ' 
		SET @StrSelectP3 = @StrSelectP1 +@StrSelectP4 + @StrSelectP2 + @StrWhere

	End
	Else
	Begin
		SET @StrSelectP1 = '
		SELECT D.ProcessID, D.ProcessNo
		, case when D.ProcessID=120 then IsNull(PC.ProcessName, '''') +''  به انبار '' + isnull(S2.StoreName,'''')
		 when D.ProcessID=125 then IsNull(PC.ProcessName, '''') +'' از انبار '' + isnull(S2.StoreName,'''')
		 when D.ProcessID in (72,73,82,82) then		 IsNull(PC.ProcessName, '''') +'' از سفارش '' + LTRIM(STR(D.BaseSerialNo))
		else 		 IsNull(PC.ProcessName, '''')  end  ProcessName, D.AcntCode,
			D.' + @DateField + ' as DocDate, D.FiscalYear, D.SerialNo, D.StoreID, D.StoreID2, D.EnterKind, 
			Sum(' + @QtyStr + ') AS QuantityIn, Sum(' + @QtyStr + ') AS QuantityOut, ' + @strUserPrice + '
			isnull(S1.StoreName,'''') StoreName,isnull(S2.StoreName,'''') StoreName2,
			0 As PhrProcessID, 0 As PhrProcessNo, 0 As PhrFiscalYear, 0 As PhrSerialNo, 0 AS RefSerial,
			CASE WHEN D.ProcessID = 51 THEN SUM(D.GoodsPrice) WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @StrAmt + ' ELSE Sum(' + @QtyStr + ' * ' + @AmtStr + ') END AS AmountIn, 
			CASE WHEN D.ProcessID = 51 THEN SUM(D.GoodsPrice) WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @StrAmt + ' ELSE Sum(' + @QtyStr + ' * ' + @AmtStr + ') END AS AmountOut,'
			Set @StrSelectP4 ='
			CASE WHEN D.ProcessID = 51 THEN SUM(D.GoodsPrice) WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @StrAmount + ' ELSE Sum(' + @QtyStr + ' * ' + @PrcStr + ') END AS PriceIn, 
			CASE WHEN D.ProcessID = 51 THEN SUM(D.GoodsPrice) WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') THEN ' + @StrAmount + ' ELSE Sum(' + @QtyStr + ' * ' + @PrcStr + ') END AS PriceOut, ' +

			CASE WHEN (@IncludeAcntName = 1) THEN ' CASE 
					WHEN D.ProcessID IN(' + @StrTransPID + ') THEN pub.GetStoreName(D.StoreID2, ' + @LangID + ')
					ELSE IsNull(pub.GetCodeName(D.AcntCode, ' + @LangID + '), CAST(''-'' AS NVarChar(50))) END ' ELSE ' CAST(''-'' AS NVarChar(50)) ' END + ' AS AcntName,
			'''' AS DescHdr, '''' AS DescDtl, (Select top 1 VolumeRowNo 
											   From inv.tblStorageDocsDtl a 
											   Where a.ProcessID=D.ProcessID and a.ProcessNo=D.ProcessNo and 
													 a.FiscalYear=D.FiscalYear and a.SerialNo=D.SerialNo and 
													 a.StoreID=D.StoreID AND a.GoodsID = ''' + @GoodsID + ''' ) VolumeRowNo, 
			Cast(''' + ltrim(@unit) + ''' as nvarchar(50)) as UniName,G.GoodsClassificationID,[inv].[funGoodsClassificationName](G.GoodsClassificationID,' + @LangID + ') GoodsClassificationName,G.ExtraField1,
			G.ExtraField2,G.ExtraField3,G.ExtraField4,G.ExtraField5, 0 DocRowNo, H.VchNo, 0 StoreVariable1, 0 StoreVariable2,
			0 BaseProcessID, 0 BaseProcessNo, 0 BaseFiscalYear, 0 BaseSerialNo, H.AgreeNo, 0 UserPriceID, D.VirtualQuantity,
			S.SetPoint, S.MaxPoint, S.FitPoint,D.Var1,D.Var2,D.Var3,D.Var4 , H.DriverID,DR.FirstName,DR.LastName,
					   D.SubUnitQuantity / (Case When D.VirtualQuantity=0 Then 1 Else D.VirtualQuantity End) Averge, D.BatchNo, H.GoodsReciverID,
					   [inv].[funGetBatchName](D.BatchNo,' + LTrim(RTrim(@LangID)) + ') BatchNameDtl,
					   [inv].[funGetReciverName]( H.GoodsReciverID,1) GoodsReciverName,
					   '''' PlaceName '
		
		Set @StrSelectP2 = '
		into ##tbl_Cardex
		FROM ' + @StrFrom + ' 
		LEFT JOIN pub.tblDriversDtl DR on H.DriverID=DR.DriverID and DR.LanguageID=' + @LangID + '
		LEFT  JOIN inv.tblStoresDtl S1 on S1.StoreID=D.StoreID and S1.LanguageID=' + @LangID + '
		LEFT  JOIN inv.tblStoresDtl S2 on S2.StoreID=D.StoreID2 and S2.LanguageID=' + @LangID + '
		WHERE ' + @StrWhere + '
		Group By D.ProcessID, D.ProcessNo, PC.ProcessName, D.AcntCode, D.DocDate, D.FiscalYear, D.SerialNo, D.StoreID,S1.StoreName,
				 D.StoreID2,S2.StoreName, D.EnterKind,G.GoodsClassificationID, G.ExtraField1, G.ExtraField2, G.ExtraField3, G.ExtraField4, G.ExtraField5, 
				 D.Var1,D.Var2,D.Var3,D.Var4,H.VchNo, H.AgreeNo, D.VirtualQuantity, S.SetPoint, S.MaxPoint, 
				 S.FitPoint,H.DriverID,DR.FirstName,DR.LastName,D.SubUnitQuantity,D.VirtualQuantity ,D.BaseSerialNo, D.BatchNo, H.GoodsReciverID '
				 

		SET @StrSelectP3 = @StrSelectP1 + @StrSelectP4 + @StrSelectP2 + @StrGroupByAmount + @strUserPriceGrp 
	End	

	print @StrSelectP3;
	Exec sp_executesql @StrSelectP3;
	
	
	If (@DocDateFr Is Not Null) And (@ShowPrim = 1)
	begin
		SET @StrSelect = '
		insert into ##tbl_Cardex
		SELECT 0 ProcessID, 0 ProcessNo, ''مانده'' ProcessName, '''' AcntCode, ''' + @DocDateFr + ''' DocDate, 
			   0 FiscalYear, 0 SerialNo, D.StoreID, '''' StoreID2, 0 EnterKind, 
			   SUM(CASE WHEN EnterKind > 0 THEN ' + @QtyStr + ' ELSE 0 END) AS QuantityIn, 
			   SUM(CASE WHEN EnterKind < 0 THEN ' + @QtyStr + ' ELSE 0 END) AS QuantityOut, ' + @strUserPrice + ' 
			   isnull(S1.StoreName,'''') StoreName,	'''' StoreName2,
			   0 PhrProcessID, 0 PhrProcessNo, 0 PhrFiscalYear, 0 PhrSerialNo, ''-'' AS RefSerial,
			   SUM(
				CASE WHEN (EnterKind < 0) 
				THEN 0 
				ELSE
					CASE  WHEN D.ProcessID = 51 THEN D.GoodsPrice
					WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') 
					THEN ' + @AmtStr + '
					ELSE (' + @QtyStr + ' * ' + @AmtStr + ') 
					END
				END
				) AS AmountIn,
			SUM(
				CASE WHEN (EnterKind > 0) 
				THEN 0 
				ELSE
					CASE  WHEN D.ProcessID = 51 THEN D.GoodsPrice
					      WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') 
					THEN ' + @AmtStr + '  
					ELSE (' + @QtyStr + ' * ' + @AmtStr + ') 
					END
				END
				) AS AmountOut,
			   SUM(
				CASE WHEN (EnterKind < 0) 
				THEN 0 
				ELSE
					CASE  WHEN D.ProcessID = 51 THEN D.GoodsPrice
					WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') 
					THEN ' + @PrcStr + '
					ELSE (' + @QtyStr + ' * ' + @PrcStr + ') 
					END
				END
				) AS PriceIn,
			SUM(
				CASE WHEN (EnterKind > 0) 
				THEN 0 
				ELSE
					CASE  WHEN D.ProcessID = 51 THEN D.GoodsPrice
					      WHEN D.ProcessID IN(' + @StrStoreBalancingPID + ') 
					THEN ' + @PrcStr + '  
					ELSE (' + @QtyStr + ' * ' + @PrcStr + ') 
					END
				END
				) AS PriceOut,
			''-'' AS AcntName, ''-'' AS DescHdr, ''-'' AS DescDtl, -999999999 As VolumeRowNo, 
			cast(''' + ltrim(@unit) + ''' as nvarchar(50)) as UniName,'''' GoodsClassificationID,'''' GoodsClassificationName,
			'''' ExtraField1, '''' ExtraField2, '''' ExtraField3, '''' ExtraField4, '''' ExtraField5,
			0 DocRowNo, 0 VchNo, 0 StoreVariable1, 0 StoreVariable2, 0 BaseProcessID, 0 BaseProcessNo, 0 BaseFiscalYear,
			0 BaseSerialNo, '''' AgreeNo, 0 UserPriceID, 0 VirtualQuantity, 0 SetPoint, 0 MaxPoint, 0 FitPoint,
			0 Var1,0 Var2,0 Var3,0 Var4, '''' DriverID,'''' FirstName,'''' LastName,0 Averge ,'''' BatchNo, '''' BatchNameDtl, '''' GoodsReciverID,'''' GoodsReciverName, '''' PlaceName
		FROM  ' + @StrFrom + ' 
		LEFT  JOIN inv.tblStoresDtl S1 on S1.StoreID=D.StoreID and S1.LanguageID=' + @LangID + '
		WHERE ' + @StrRemain + ' AND (D.' + @DateField + ' < ''' + @DocDateFr + ''') 
		GROUP BY D.StoreID,S1.StoreName ' + 
				 @strUserPriceGrp +''
-------------------------------------------------
		Print @StrSelect;
		Exec sp_executesql @StrSelect;

	end

	SET @StrSelect = '
	SELECT T.*, G.GoodsID, ' + 
	Case When @ShowGoodsImage = 1 Then 'GI1.GoodsImage, GI2.BatchImage, ' Else 'Null As GoodsImage,Null As BatchImage, ' End + '
	G.TechnicalSpecifications, G.TechnicalNo, G.MiscSpecifications, G.GoodsLength, G.GoodsWidth, G.GoodsHeight, G.GoodsWeight
	FROM ##tbl_Cardex T 
	INNER JOIN inv.tblGoods G on (G.GoodsID = ''' + SUBSTRING(@GoodsID,@str_Goods+1,@str_GoodsSum) + ''')	AND G.PartNumber=' + LTRIM(STR(@UnitPart)) + 
	Case When @ShowGoodsImage = 1 Then ' LEFT JOIN inv.tblGoodsImages GI1 ON GI1.GoodsID = ''' + @GoodsID + ''' 
										 LEFT JOIN inv.tblBatchImages GI2 ON GI2.BatchNo = T.BatchNo ' Else ' ' End

	SET @StrSelect = '
	Select T.*, --S.SetPoint, S.MaxPoint, S.FitPoint, S.RecDesc, R.BaseFiscalYear as PorduceOrderFiscalYear, 
		   R.BaseSerialNo as ProduceOrderSerialNo,ISNULL(DD.SerialNo,0) DisSerialNo, ' + LTrim(Str(@HasSerial)) + ' ShowSerials
	Into ##tbl_Store_Cardex
	From 
	(' + @StrSelect + '
	) T 
		left join pln.tblItemRelations R on R.ProcessID=T.BaseProcessID and R.ProcessNo=T.BaseProcessNo and R.FiscalYear=T.BaseFiscalYear and R.SerialNo=T.BaseSerialNo
		left join (select StoreID, GoodsID, min(RowNo) MinRowNo from inv.tblGoodsStatusDtl Group By StoreID, GoodsID) S0 on S0.StoreID = T.StoreID and S0.GoodsID = ''' + Ltrim(@GoodsID) + ''' 
		left join inv.tblGoodsStatusDtl S on S.StoreID = S0.StoreID and S.GoodsID = ''' + Ltrim(@GoodsID) + ''' and S.RowNo = S0.MinRowNo 
		LEFT JOIN (SELECT * from sal.tblDistributionsDtl WHERE BaseSaleProcessID <>0 and SerialNo<>0) DD ON BaseSaleProcessID=T.ProcessID AND BaseSaleProcessNo=T.ProcessNo AND 
		BaseSaleFiscalYear=T.FiscalYear AND BaseSaleSerialNo=T.SerialNo'
	
	If (@GroupByStore = 1)
	begin
	SET @StrSelect = @StrSelect + '
	ORDER BY StoreID, ' + @DateField + ', VolumeRowNo,ProcessID '
	end
	Else
	begin
	SET @StrSelect = @StrSelect + '
	ORDER BY ' + @DateField + ', VolumeRowNo,ProcessID  '
	end
	
	
	begin try
		drop table ##tbl_Store_Cardex
	end try
	begin catch
	end catch

	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
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
	
	-- ==================================================
	
	If (@GroupByStore = 1)
	begin
	
	SELECT X.*, @LastCalc AS LastAmountDate
	FROM ##tbl_Store_Cardex X
	ORDER BY StoreID, DocDate , VolumeRowNo,ProcessID 
	
	end
	Else
	begin
	
	SELECT X.*, @LastCalc AS LastAmountDate
	FROM ##tbl_Store_Cardex X
	ORDER BY  DocDate , VolumeRowNo,ProcessID 
	
	end
	
	-- ==================================================
END
GO
