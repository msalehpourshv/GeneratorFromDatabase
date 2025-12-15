USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1396/03/15
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < گزارش آماری فروش کالاها>
-- ==============================================
Create PROCEDURE sal.RptSaleRet
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	
WITH ENCRYPTION
AS
BEGIN
	DECLARE @StrSelect		NVarChar(Max);
	DECLARE @StrSelect1		NVarChar(Max);
	DECLARE @StrSelect2		NVarChar(Max);
	DECLARE @StrWhereH		NVarChar(Max);
	DECLARE @StrWhereT		NVarChar(Max);
	DECLARE @StrWhereD		NVarChar(Max);
	DECLARE @Orders			NVarChar(Max);
	DECLARE @StrDtl4		NVarChar(Max);
	DECLARE	@LangID			Char(1);
	DECLARE	@SessionNo		Int; 
	DECLARE	@ReportID		Int;
	DECLARE	@UserID			Int;
	DECLARE	@UserIsAdmin	bit;

	-- Acnt Layer
	Declare @StartLayer		TINYINT;
	Declare @LayerLen		TINYINT;
	Declare @PartNumber		TINYINT;
	Declare @StartLayer1	TINYINT;
	Declare @LayerLen1		TINYINT;
	Declare @StartLayer2	TINYINT;
	Declare @LayerLen2		TINYINT;
	Declare @StartLayer3	TINYINT;
	Declare @LayerLen3		TINYINT;
	Declare @StartLayer4	TINYINT;
	Declare @LayerLen4		TINYINT;

	DECLARE @StrAcntWhere	NVarChar(Max);
	DECLARE @CampaignID				int;
	DECLARE @VisitPathID11			int;
	DECLARE @VisitPathID21			int;
	DECLARE @VisitPathID31			int;
	DECLARE @VisitPathID41			int;
	DECLARE @SalesRoomClass			int;

	SELECT @StartLayer = SettingValue FROM pub.tblSettings WHERE SettingKey = 'StartLayerIndex'	
	select @LayerLen   = SettingValue From pub.tblSettings Where SettingKey='LayerLen'
	select @PartNumber = SettingValue From pub.tblSettings Where SettingKey='AcntPartNumberForRemainCalculation'
			
	IF (@StartLayer Is Null)	SET @StartLayer = 1;
	IF (@LayerLen Is Null)		SET @LayerLen = 1;
	IF (@PartNumber Is Null)	SET @PartNumber = 1;

	---------------Goods Layer ----------------------------------------------------
	Declare @GoodsLayerStart	TINYINT;
	Declare @GoodsLayer1		TINYINT;
	Declare @GoodsLayer2		TINYINT;

	Select @GoodsLayerStart=Layer1 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
	Select @GoodsLayer1=Layer2 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
	Select @GoodsLayer2=Layer3 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
		
	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);

	DECLARE	
		@ProcessID			INT ,
		@ProcessNo			Varchar(20) ,
		@FiscalYearFr		Int ,
		@SerialNoFr			Int ,
		@FiscalYearTo		Int ,
		@SerialNoTo			Int ,
		@DocDateFr			Char(10) ,
		@DocDateTo			Char(10) ,
		@VisitorAcntCode1  	Varchar(20),
		@VisitorAcntCode2  	Varchar(20),
		@VisitorAcntCode3  	Varchar(20),
		@VisitorAcntCode4  	Varchar(20),
		@StoreID			Varchar(20),
		@GoodsID			Varchar(20),
		@SelectedAcnt1		Varchar(20),
		@SelectedAcnt2		Varchar(20),
		@SelectedAcnt3		Varchar(20),
		@SelectedAcnt4		Varchar(20),
		@AcntGroups1		Varchar(20),
		@AcntGroups2		Varchar(20),
		@AcntGroups3		Varchar(20),
		@AcntGroups4		Varchar(20),
		@DriverID			Varchar(20),
		@DistributerID1		Varchar(20),
		@DistributerID2		Varchar(20),
		@DescRetSaleID		Varchar(20),
		@CurrencyTypeID		Varchar(20),
		@CustomerKindIDCode	Varchar(20),
		@SaleTypeIDCode		Varchar(20),
		@StoreIDCode		Varchar(20),
		@CustomerKindID		int,
		@SaleTypeID			int,
		@Visitor			bit,
		@Distributer		bit,
		@Driver				bit,
		@LastLayer			int,
		@FilterType			int,
		@IsCurrency			int,
		@FromPrice		Varchar(50),
		@ToPrice		Varchar(50),
		@FromPrecent	Varchar(10),
		@ToPercent		Varchar(10),
		@IsReward			int,
		@DistSerialNoFr		int,
		@DistSerialNoTo		int,
		@PayOffTypeID		int

	SET @ProcessID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ProcessNo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @FiscalYearFr		    = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @SerialNoFr			    = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @FiscalYearTo		    = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	SET @SerialNoTo		    	= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @DocDateFr			    = LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
	SET @DocDateTo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
	SET @VisitorAcntCode1  	    = LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @VisitorAcntCode2  	    = LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
	SET @VisitorAcntCode3  	    = LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
	SET @VisitorAcntCode4  	    = LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	SET @StoreID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
	SET @GoodsID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 
	SET @SelectedAcnt1		    = LTrim(pub.funSplitString(@ExtraParams, '@', 15));
	SET @SelectedAcnt2		    = LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 
	SET @SelectedAcnt3		    = LTrim(pub.funSplitString(@ExtraParams, '@', 17)); 
	SET @SelectedAcnt4		    = LTrim(pub.funSplitString(@ExtraParams, '@', 18));
	SET @AcntGroups1		    = LTrim(pub.funSplitString(@ExtraParams, '@', 19));
	SET @AcntGroups2		    = LTrim(pub.funSplitString(@ExtraParams, '@', 20)); 
	SET @AcntGroups3		    = LTrim(pub.funSplitString(@ExtraParams, '@', 21)); 
	SET @AcntGroups4		    = LTrim(pub.funSplitString(@ExtraParams, '@', 22));
	SET @DriverID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 23));
	SET @DistributerID1		    = LTrim(pub.funSplitString(@ExtraParams, '@', 24));
	SET @DistributerID2		    = LTrim(pub.funSplitString(@ExtraParams, '@', 25));
	SET @FilterType				= LTrim(pub.funSplitString(@ExtraParams, '@', 26));
	--27    @VisitPathID3 in formula
	--28    @VisitPathID4 in formula
	SET @Orders 				= LTrim(pub.funSplitString(@ExtraParams, '@', 29));
	SET @DescRetSaleID 			= LTrim(pub.funSplitString(@ExtraParams, '@', 30));
	SET @Visitor 				= LTrim(pub.funSplitString(@ExtraParams, '@', 31));
	SET @Distributer 			= LTrim(pub.funSplitString(@ExtraParams, '@', 32));
	SET @Driver					= LTrim(pub.funSplitString(@ExtraParams, '@', 33));
	SET @LastLayer				= LTrim(pub.funSplitString(@ExtraParams, '@', 34));
	SET @CampaignID				= LTrim(pub.funSplitString(@ExtraParams, '@', 35));
	SET @VisitPathID11			= LTrim(pub.funSplitString(@ExtraParams, '@', 36));
	SET @VisitPathID21			= LTrim(pub.funSplitString(@ExtraParams, '@', 37));
	SET @VisitPathID31			= LTrim(pub.funSplitString(@ExtraParams, '@', 38));
	SET @VisitPathID41			= LTrim(pub.funSplitString(@ExtraParams, '@', 39));
	SET @SalesRoomClass			= LTrim(pub.funSplitString(@ExtraParams, '@', 40));
	SET @CurrencyTypeID			= LTrim(pub.funSplitString(@ExtraParams, '@', 41));
	SET @CustomerKindID			= LTrim(pub.funSplitString(@ExtraParams, '@', 42));
	SET @SaleTypeID				= LTrim(pub.funSplitString(@ExtraParams, '@', 43));
	SET @CustomerKindIDCode		= LTrim(pub.funSplitString(@ExtraParams, '@', 44));
	SET @SaleTypeIDCode			= LTrim(pub.funSplitString(@ExtraParams, '@', 45));
	SET @StoreIDCode			= LTrim(pub.funSplitString(@ExtraParams, '@', 46));
	SET @IsCurrency				= LTrim(pub.funSplitString(@ExtraParams, '@', 47));
	Set @FromPrice				= LTrim(pub.funSplitString(@ExtraParams, '@', 48));
	Set	@ToPrice				= LTrim(pub.funSplitString(@ExtraParams, '@', 49));
	Set @FromPrecent			= LTrim(pub.funSplitString(@ExtraParams, '@', 50));
	Set @ToPercent				= LTrim(pub.funSplitString(@ExtraParams, '@', 51));
	Set @DistSerialNoFr			= LTrim(pub.funSplitString(@ExtraParams, '@', 52));
	Set @DistSerialNoTo			= LTrim(pub.funSplitString(@ExtraParams, '@', 53));
	Set @IsReward				= LTrim(pub.funSplitString(@ExtraParams, '@', 54)); 
	Set @PayOffTypeID			= LTrim(pub.funSplitString(@ExtraParams, '@', 55)); 
 
	--select @CampaignID,@VisitPathID1,@VisitPathID2,@VisitPathID3,@VisitPathID4,@SalesRoomClass

	if @LastLayer <4
	begin
		Select @GoodsLayerStart=0
		Select @GoodsLayer1=Layer1 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
		Select @GoodsLayer2=Layer2 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
	end 

	if @LastLayer >4
	begin
		Select @GoodsLayerStart=Layer2	from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
		Select @GoodsLayer1=Layer3		from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
		Select @GoodsLayer2=Layer4		from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
	end 

	--set @DocDateFr	='1396/01/01';
	--set @DocDateTo	='1396/12/29';

	IF (@ProcessID Is Null)		SET @ProcessID = 0;
	IF (@ProcessNo Is Null)		SET @ProcessNo = 10;
	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNoFr;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYearFr;

	--select @UserID,@UserIsAdmin
	--SET @StrWhereH = 'H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' AND H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))

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
	
	Insert into  #tblVisitorAcntCode (VisitorAcntCode)	SELECT Distinct VisitorAcntCode	FROM inv.tblStorageDocsHdr
	Insert into  #tblAcntCode (AcntCode)				SELECT Distinct AcntCode		FROM inv.tblStorageDocsHdr
	Insert into  #tblGoods (GoodsID)					SELECT Distinct GoodsID			FROM inv.tblStorageDocsDtl
	Insert into  #tblStoreID (StoreID)					SELECT Distinct StoreID			FROM inv.tblStorageDocsHdr
	 
	SET @StrWhereH = ''
	SET @StrWhereD = '' 
	SET @StrWhereT = ''  

	if @UserIsAdmin=0
	begin

		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblVisitorAcntCode', 'VisitorAcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblGoods', 'GoodsID', 'inv.tblGoods', @UserID;
		 exec pub.SpFilterByPermission2 '#tblStoreID', 'StoreID', 'inv.tblStores', @UserID;

		SET @StrWhereH =  
			' and H.AcntCode in (SELECT AcntCode FROM  #tblAcntCode ) ' +
			' and H.VisitorAcntCode in (SELECT VisitorAcntCode FROM  #tblVisitorAcntCode ) ' + 
			' and H.StoreID in (SELECT StoreID FROM  #tblStoreID ) '

		SET @StrWhereD =  ' and D.GoodsID in (SELECT GoodsID	FROM #tblGoods ) '

	END
				
	IF (@ProcessNo Is not Null)	
		SET @StrWhereH = @StrWhereH + ' AND (H.ProcessNo IN(' + @ProcessNo + ')) '
	
	-- Where ----------------------------------------
	IF (@SerialNoFr <>0)
		SET @StrWhereH = @StrWhereH + ' AND (H.SerialNo >=' + LTrim(Str(@SerialNoFr)) + ') '
	
	IF (@SerialNoTo  <>0)
		SET @StrWhereH = @StrWhereH + ' AND (H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'		
	
	IF (@FiscalYearFr  <>0)
		SET @StrWhereH = @StrWhereH + ' AND (H.FiscalYear >=' + LTrim(Str(@FiscalYearFr)) + ')'
	
	IF (@FiscalYearFr  <>0)
		SET @StrWhereH = @StrWhereH + ' AND (H.FiscalYear <=' + LTrim(Str(@FiscalYearFr)) + ')'
	
	If (@DocDateFr Is Not Null and  LTRIM(rtrim(@DocDateFr ))<>'')
		SET @StrWhereH = @StrWhereH + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	
	If (@DocDateTo Is Not Null  and  LTRIM(rtrim(@DocDateTo ))<>'')
		SET @StrWhereH = @StrWhereH + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	If (@DriverID Is Not Null  and  LTRIM(rtrim(@DriverID ))<>'')
		SET @StrWhereH = @StrWhereH + ' AND (H.DriverID = ''' + @DriverID + ''')'
	
	If (@DistributerID1 Is Not Null  and  LTRIM(rtrim(@DistributerID1 ))<>'')
		SET @StrWhereH = @StrWhereH + ' AND (H.DistributerID1 = ''' + @DistributerID1 + ''')'
	
	If (@DistributerID2 Is Not Null  and  LTRIM(rtrim(@DistributerID2 ))<>'')
		SET @StrWhereH = @StrWhereH + ' AND (H.DistributerID2 = ''' + @DistributerID2 + ''')'

	IF (@VisitorAcntCode1 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcntCode1, 'H.VisitorAcntCode')
	
	IF (@VisitorAcntCode2 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcntCode2, 'H.VisitorAcntCode')
	
	IF (@VisitorAcntCode3 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcntCode3, 'H.VisitorAcntCode')
	
	IF (@VisitorAcntCode4 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcntCode4, 'H.VisitorAcntCode')

	IF (@StoreID > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'H.StoreID')
	
	IF (@SelectedAcnt1 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	
	IF (@SelectedAcnt2 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	
	IF (@SelectedAcnt3 > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	
	IF (@SelectedAcnt4 > 0)	
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')
	
	IF (@DescRetSaleID <> '')	
		SET @StrWhereH = @StrWhereH + ' AND ( H.ProcessID<>100 or( H.ProcessID=100 and H.DescRetSaleID =''' + @DescRetSaleID + '''))'
	
	IF (@Visitor <> 0)	
		SET @StrWhereH = @StrWhereH + ' AND ( H.ProcessID<>100 or( H.DescRetSaleID in ( Select DescRetSaleID from sal.tblDescRetSale where Visitor=1)))'
	
	IF (@Distributer <> 0)	
		SET @StrWhereH = @StrWhereH + ' AND ( H.ProcessID<>100 or( H.DescRetSaleID in ( Select DescRetSaleID from sal.tblDescRetSale where Distributer=1)))'
	
	IF (@Driver <> 0)	
		SET @StrWhereH = @StrWhereH + ' AND ( H.ProcessID<>100 or( H.DescRetSaleID in ( Select DescRetSaleID from sal.tblDescRetSale where Driver=1)))'
	
	IF (@GoodsID > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID, 'D.GoodsID')
	
	If (@CurrencyTypeID Is Not Null  and  LTRIM(rtrim(@CurrencyTypeID ))<>'')
		SET @StrWhereH = @StrWhereH + ' AND (H.CurrencyTypeID = ''' + @CurrencyTypeID + ''')'
	
	IF (@SaleTypeID > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SaleTypeID, 'H.SaleTypeID')

	If (@SaleTypeIDCode Is Not Null  and  LTRIM(rtrim(@SaleTypeIDCode ))<>'')
		SET @StrWhereH = @StrWhereH + ' AND (H.SaleTypeID = ''' + @SaleTypeIDCode + ''')'
	
	If (@StoreIDCode Is Not Null  and  LTRIM(rtrim(@StoreIDCode ))<>'')
		SET @StrWhereH = @StrWhereH + ' AND (H.StoreID = ''' + @StoreIDCode + ''')'
	
	select  
		@StartLayer1=[acc].[funGetAcntLayerStartandLen](1,1)
		,@LayerLen1=[acc].[funGetAcntLayerStartandLen](1,2)
		,@StartLayer2=[acc].[funGetAcntLayerStartandLen](2,1)
		,@LayerLen2=[acc].[funGetAcntLayerStartandLen](2,2)
		,@StartLayer3=[acc].[funGetAcntLayerStartandLen](3,1)
		,@LayerLen3=[acc].[funGetAcntLayerStartandLen](3,2)
		,@StartLayer4=[acc].[funGetAcntLayerStartandLen](4,1)
		,@LayerLen4=[acc].[funGetAcntLayerStartandLen](4,2)
	
	IF (@AcntGroups1 > 0)	
		SET @StrWhereH = @StrWhereH + ' AND substring (H.AcntCode,'+ str(@StartLayer1)+', '+ str(@LayerLen1)+') in  ( SELECT   AcntCode FROM         acc.tblAcntGroupsDocDtl AG where ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntGroups1, 'AG.AcntGroupID')+' )'
	
	IF (@AcntGroups2 > 0)	
		SET @StrWhereH = @StrWhereH + ' AND substring (H.AcntCode,'+ str(@StartLayer2)+', '+ str(@LayerLen2)+')) in  ( SELECT   AcntCode FROM         acc.tblAcntGroupsDocDtl AG where ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntGroups2, 'AG.AcntGroupID')+' )'
	
	IF (@AcntGroups3 > 0)	
		SET @StrWhereH = @StrWhereH + ' AND substring (H.AcntCode,'+ str(@StartLayer3)+', '+ str(@LayerLen3)+') in  ( SELECT   AcntCode FROM         acc.tblAcntGroupsDocDtl AG where ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntGroups3, 'AG.AcntGroupID')+' )'
	
	IF (@AcntGroups4 > 0)	
		SET @StrWhereH = @StrWhereH + ' AND substring (H.AcntCode,'+ str(@StartLayer4)+', '+ str(@LayerLen4)+') in  ( SELECT   AcntCode FROM         acc.tblAcntGroupsDocDtl AG where ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntGroups4, 'AG.AcntGroupID')+' )'	
		
	if @FromPrice > 0
		set  @StrWhereH = @StrWhereH + 'And H.Price > '+@FromPrice+''
	else
		set  @StrWhereH = @StrWhereH + ''
	if @ToPrice >0
		set  @StrWhereH = @StrWhereH + 'And H.Price <= '+@ToPrice+''
	else
		set  @StrWhereH = @StrWhereH + ''
	if @FromPrecent >0
		set  @StrWhereT = @StrWhereT + 'And case when Price>0 then (Discount+Discount2+Discount3+OtherCost+AfterSaleDiscount+TotalLineDiscount)*100/Price else 0 end >= '+@FromPrecent+''
	else
		set  @StrWhereT = @StrWhereT + ''
	if @ToPercent >0
		set  @StrWhereT = @StrWhereT + 'And case when Price>0 then (Discount+Discount2+Discount3+OtherCost+AfterSaleDiscount+TotalLineDiscount)*100/Price else 0 end <= '+@ToPercent+''
	else
		set  @StrWhereT = @StrWhereT + ''
	IF (@DistSerialNoFr <>0)
		SET @StrWhereH = @StrWhereH + ' AND (H.BaseDistributionSerialNo >=' + Str(@DistSerialNoFr) + ') '
	
	IF (@DistSerialNoTo  <>0)
		SET @StrWhereH = @StrWhereH + ' AND (H.BaseDistributionSerialNo <= ' + Str(@DistSerialNoFr) + ')'
	
	if @IsReward = '' or @IsReward = null
		Set @IsReward = 1

	if @IsReward = 2
		SET @StrWhereD = @StrWhereD + ' AND D.IsReward = 0'
	if @IsReward = 3
		SET @StrWhereD = @StrWhereD + ' AND D.IsReward = 1'
	if @IsReward = 1
		SET @StrWhereD = @StrWhereD + ''

	IF (@PayOffTypeID > 0)
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @PayOffTypeID, 'H.PayOffTypeID')
--=========================

	Declare @CustomerPartNo			int;
	DECLARE @CustomerPartStart		int;
	DECLARE @CustomerPartLayerLen	int;
		
	select @CustomerPartNo=[acc].[FunGetAcntInfoForRemain](1)
	select @CustomerPartStart=[acc].[FunGetAcntInfoForRemain](2)
	select @CustomerPartLayerLen= [acc].[FunGetAcntInfoForRemain](3)

	set @StrAcntWhere=' '

	If  @CampaignID > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'CampaignID') 

	If  @VisitPathID11 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID11, 'VisitPathID1') 
		
	If  @VisitPathID21 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID21, 'VisitPathID2') 
		
	If  @VisitPathID31 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID31, 'VisitPathID3') 
		
	If  @VisitPathID41 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID41, 'VisitPathID4') 
		
	If @SalesRoomClass > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SalesRoomClass, 'SalesRoomClass') 
		
	If  @CustomerKindID > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerKindID, 'CustomerKindID') 
	
	If (@CustomerKindIDCode Is Not Null  and  LTRIM(rtrim(@CustomerKindIDCode ))<>'')
		SET @StrAcntWhere = @StrAcntWhere + ' AND (CustomerKindID = ''' + @CustomerKindIDCode + ''')'
	
	If  @StrAcntWhere <> ''
		SET @StrAcntWhere = '
			INNER JOIN (Select AcntCode AcntC From acc.tblAcnt Where PartNumber = ' + LTrim(RTrim(Str(@CustomerPartNo))) + ' 
			'+  @StrAcntWhere +'
			) a 
			ON Cast(Substring(H.AcntCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC '
		
  	--select @StrAcntWhere
	--=========================

	BEGIN TRY
		DROP TABLE #tblSale
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tblSale
	(
		GroupID 	Varchar(20)collate arabic_cs_as null,
		GroupName 	NVarchar(200)collate arabic_cs_as null,
		Sale		int,
		Ret			int,
		LastSale	char(10),
		LastRet		char(10),
		A1      	float ,
		A2      	float,
		A3      	float,
		A4      	float,
		A5      	float,
		A6      	float,
		A7      	float,
		A8      	float,
		A9      	float,
		A10     	float,
		A11     	float,
		A12     	float,
		A13     	float,
		A14     	float,
		A15     	float,
		A16     	float,
		A17     	float,
		A18     	float,
		A19     	float,
		A20     	float,
		B1      	float,
		B2      	float,
		B3      	float,
		B4      	float,
		B5      	float,
		B6      	float,
		B7      	float,
		B8      	float,
		B9      	float,
		B10     	float,
		B11     	float,
		B12     	float,
		B13     	float,
		B14     	float,
		B15     	float,
		B16     	float,
		B17     	float,
		B18     	float,
		B19     	float,
		B20     	float,
		AA1      	float,
		AA2      	float,
		AA3      	float,
		AA4      	float,
		AA5      	float,
		AA6      	float,
		AA7      	float,
		AA8      	float,
		AA9      	float,
		AA10     	float,
		AA11     	float,
		AA12     	float,
		AA13     	float,
		AA14     	float,
		AA15     	float,
		AA16     	float,
		AA17     	float,
		AA18     	float,
		AA19     	float,
		AA20     	float
		
	)
	
	DECLARE @GroupBy		NVarChar(Max);
	DECLARE @FilterLink		NVarChar(Max);
	DECLARE @FilterLink2	NVarChar(Max);
	DECLARE @FieldName		NVarChar(Max);
	Declare @LinkType		TINYINT;
	Declare @LinkTable1		TINYINT;
	Declare @LinkTable2		TINYINT;
	Declare @LinkTable3		TINYINT;
	DECLARE @JoinHdrDtl		NVarChar(Max);
	DECLARE @JoinHdrAcnt	NVarChar(Max);
	Declare @GoodsName VARCHAR(200)
		
--------------------------------------------------------------------------------------------------
	BEGIN TRY
		DROP TABLE #tblStorageDocsHdr
		DROP TABLE #tblStorageDocsDtl
	END TRY
	BEGIN CATCH
	END CATCH

	select ProcessID,ProcessNo,FiscalYear,SerialNo,AcntCode SerialNoPNO,AcntCode,StoreID,DocDate,VisitorAcntCode,DriverID,DistributerID1,DistributerID2,AfterSaleDiscount,Discount,Discount2 ,Discount3,OtherCost,DescRetSaleID,SaleTypeID,CurrencyTypeID,LocationID,AcntCode AcntCode1,AcntCode AcntCode2,AcntCode AcntCode3,AcntCode AcntCode4
	,Price,TotalLineDiscount,CurrencyRate, case when Price>0 then (Discount+Discount2+Discount3+OtherCost+AfterSaleDiscount+TotalLineDiscount)*100/Price else 0 end as TotalPercentage,BaseDistributionSerialNo	,cast( 0 as float ) DiscountHdr, PayOffTypeID
	into #tblStorageDocsHdr
	from inv.tblStorageDocsHdr
	where 1=0
			
	select ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,AcntCode SerialNoPNO,GoodsID,GoodsQuantity,GoodsPrice,DiscountDtl,DiscountDtl DiscountDtl2,AcntCode,DocDate,VisitorAcntCode
	,cast( 0 as float ) as GoodsPriceHdr,cast( 0 as float ) as GoodsPriceAfterSaleDiscount,cast( 0 as float ) AfterSaleDiscount, cast( 0 as float ) as GoodsPriceDtl,cast( 0 as float ) Balance	
	,cast( 0 as float ) GoodsWeight,cast( 0 as float ) PureWeight,cast( 0 as float ) DiscountHdr,cast( 0 as float ) DiscountPercentHdr
	, BaseProcessID	, BaseProcessNo	, BaseFiscalYear	, BaseSerialNo	, BaseDocRowNo
	into #tblStorageDocsDtl
	from inv.tblStorageDocsDtl
	where 1=0

	select * into #tblStorageDocsDtlSum  from #tblStorageDocsDtl
	
	if @IsCurrency=1
	 set @StrSelect = 
		' Insert into #tblStorageDocsHdr  
		 Select ProcessID,ProcessNo,FiscalYear,SerialNo,ltrim(rtrim(str(SerialNo)))+''@''+ltrim(rtrim(str(ProcessNo))) SerialNoPNO,AcntCode,StoreID,DocDate,VisitorAcntCode,DriverID,DistributerID1,DistributerID2,AfterSaleDiscount,Discount,Discount2 ,Discount3,OtherCost,DescRetSaleID,SaleTypeID,CurrencyTypeID ,LocationID,'''','''','''','''' 
				,Price,TotalLineDiscount,CurrencyRate, case when Price>0 then (Discount+Discount2+Discount3+OtherCost+AfterSaleDiscount+TotalLineDiscount)*100/Price else 0 end as TotalPercentage,BaseDistributionSerialNo
				,CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END *(AfterSaleDiscount+Discount+Discount2+Discount3+OtherCost),PayOffTypeID
		 from inv.tblStorageDocsHdr H '

	else
		 set @StrSelect = 
		' Insert into #tblStorageDocsHdr  
		 Select ProcessID,ProcessNo,FiscalYear,SerialNo,ltrim(rtrim(str(SerialNo)))+''@''+ltrim(rtrim(str(ProcessNo))) SerialNoPNO,AcntCode,StoreID,DocDate,VisitorAcntCode,DriverID,DistributerID1,DistributerID2,AfterSaleDiscount,Discount,Discount2,Discount3,OtherCost,DescRetSaleID,SaleTypeID,CurrencyTypeID ,LocationID,'''','''','''','''' 
				,Price,TotalLineDiscount,CurrencyRate, case when Price>0 then (Discount+Discount2+Discount3+OtherCost+AfterSaleDiscount+TotalLineDiscount)*100/Price else 0 end as TotalPercentage,BaseDistributionSerialNo
				,AfterSaleDiscount+Discount+Discount2+Discount3+OtherCost,PayOffTypeID
		 from inv.tblStorageDocsHdr H '

	if @StrAcntWhere<>'' 
		SET @StrSelect = @StrSelect +@StrAcntWhere 

	SET @StrSelect = @StrSelect + ' where H.ProcessID in(90,100)  '+ @StrWhereH +' ' + @StrWhereT +'' 
	
	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;
	  
	if @IsCurrency=1
		set @StrSelect = 
			' Insert into #tblStorageDocsDtl  
			 Select D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.DocRowNo,ltrim(rtrim(str(D.SerialNo)))+''@''+ltrim(rtrim(str(D.ProcessNo))) SerialNoPNO,D.GoodsID,D.GoodsQuantity
				,CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.GoodsPrice GoodsPrice
				,CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.DiscountDtl DiscountDtl 
				,CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * CASE WHEN (IsReward=0 and IsReward0=0) THEN 0 ELSE DiscountDtl END   DiscountDtl2
				,D.AcntCode,D.DocDate,D.VisitorAcntCode ,0 as GoodsPriceHdr,0 as GoodsPriceAfterSaleDiscount			
				,CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * AfterSaleDiscount 
				,ISNULL(  CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.GoodsPrice *GoodsQuantity- CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * D.DiscountDtl , 0) as GoodsPriceDtl
				,CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * Price - CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (1/H.CurrencyRate) END * TotalLineDiscount Balance
				,GoodsWeight,PureWeight
				,CASE WHEN Price=0 or Price=TotalLineDiscount then 0 else (D.GoodsPrice*GoodsQuantity-DiscountDtl) * (DiscountHdr)/(Price-TotalLineDiscount) end  				
				,case when Price=0 or Price=TotalLineDiscount  then 0 else ((D.GoodsPrice*GoodsQuantity-DiscountDtl) * (DiscountHdr)/(Price-TotalLineDiscount)) /(Price-TotalLineDiscount)*100 *CASE WHEN (H.CurrencyRate=0) THEN 0 ELSE (H.CurrencyRate) END  end
				, BaseProcessID	, BaseProcessNo	, BaseFiscalYear	, BaseSerialNo	, BaseDocRowNo
			 from inv.tblStorageDocsDtl D 
			 inner join #tblStorageDocsHdr H 
				On H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
				inner join inv.tblGoods G on G.GoodsID=D.GoodsID
			 where D.ProcessID in(90,100) '+ @StrWhereD +' '+ @StrWhereH 

	else
		set @StrSelect = 
			' Insert into #tblStorageDocsDtl  
			Select D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.DocRowNo,ltrim(rtrim(str(D.SerialNo)))+''@''+ltrim(rtrim(str(D.ProcessNo))) SerialNoPNO,D.GoodsID,D.GoodsQuantity,D.GoodsPrice,D.DiscountDtl,CASE WHEN (IsReward=0 and IsReward0=0) THEN 0 ELSE D.DiscountDtl END   DiscountDtl2,D.AcntCode,D.DocDate,D.VisitorAcntCode
				,0 as GoodsPriceHdr,0 as GoodsPriceAfterSaleDiscount,AfterSaleDiscount,	
				ISNULL(  D.GoodsPrice*D.GoodsQuantity- DiscountDtl , 0) as GoodsPriceDtl, Price-TotalLineDiscount Balance
				,GoodsWeight,PureWeight
				,case when Price=0 or Price=TotalLineDiscount then 0 else (D.GoodsPrice*GoodsQuantity-DiscountDtl) * (DiscountHdr)/(Price-TotalLineDiscount) end 
				,case when Price=0 or Price=TotalLineDiscount  then 0 else ((D.GoodsPrice*GoodsQuantity-DiscountDtl) * (DiscountHdr)/(Price-TotalLineDiscount)) /(Price-TotalLineDiscount)*100 end
				, BaseProcessID	, BaseProcessNo	, BaseFiscalYear	, BaseSerialNo	, BaseDocRowNo
			from inv.tblStorageDocsDtl D 
			inner join #tblStorageDocsHdr H 
				On H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
				inner join inv.tblGoods G on G.GoodsID=D.GoodsID
			where D.ProcessID in(90,100) '+ @StrWhereD +' '+ @StrWhereH 

	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;
 
	delete from  #tblStorageDocsHdr 
	from #tblStorageDocsHdr H
	inner join  
	(select  ProcessID,ProcessNo,FiscalYear,SerialNo  from #tblStorageDocsHdr   
		except
	select  ProcessID,ProcessNo,FiscalYear,SerialNo from #tblStorageDocsDtl
	) D	On H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo  
	--------------------------------------------------------------------------------------------------
	
	Update   #tblStorageDocsDtl 
		set GoodsPriceHdr=GoodsPriceDtl
	Update  #tblStorageDocsDtl
		set GoodsPriceAfterSaleDiscount= ISNULL(GoodsPriceHdr - GoodsPriceHdr *(DiscountHdr+AfterSaleDiscount)/Balance , 0) 
	where Balance>0
	--------------------------------------------------------------------------------------------------
	insert into #tblStorageDocsDtlSum
	select 		
		a.ProcessID	,a.ProcessNo	,a.FiscalYear	,a.SerialNo	,a.DocRowNo	,a.SerialNoPNO	,a.GoodsID	
		,a.GoodsQuantity-isnull(b.GoodsQuantity,0) GoodsQuantity
		,a.GoodsPrice	,a.DiscountDtl	-isnull(b.DiscountDtl,0)DiscountDtl	,a.DiscountDtl2	-isnull(b.DiscountDtl2,0)	DiscountDtl2,a.AcntCode	,a.DocDate	,a.VisitorAcntCode	
		,a.GoodsPriceHdr-isnull(b.GoodsPriceHdr,0)	GoodsPriceHdr,a.GoodsPriceAfterSaleDiscount	-isnull(b.GoodsPriceAfterSaleDiscount,0)	GoodsPriceAfterSaleDiscount,a.AfterSaleDiscount-isnull(b.AfterSaleDiscount,0)	AfterSaleDiscount
		,a.GoodsPriceDtl-isnull(b.GoodsPriceDtl,0)	GoodsPriceDtl,a.Balance-isnull(b.Balance	,0) Balance,a.GoodsWeight	-isnull(b.GoodsWeight,0)	GoodsWeight,a.PureWeight	-isnull(b.PureWeight,0)	PureWeight
		,a.DiscountHdr	-isnull(b.DiscountHdr,0)	DiscountHdr,a.DiscountPercentHdr	-isnull(b.DiscountPercentHdr,0)	DiscountPercentHdr,
		a.BaseProcessID	,a.BaseProcessNo	,a.BaseFiscalYear	,a.BaseSerialNo	,a.BaseDocRowNo
	from 	(	select * from  #tblStorageDocsDtl where ProcessID=90) a
	left join
		(select * from  #tblStorageDocsDtl where ProcessID=100)b
		on a.ProcessID=b.BaseProcessID
		and a.ProcessNo=b.BaseProcessNo
		and a.FiscalYear=b.BaseFiscalYear
		and a.SerialNo=b.BaseSerialNo
		and a.DocRowNo=b.BaseDocRowNo
		where 1=1 
		and abs(a.GoodsQuantity-isnull(b.GoodsQuantity,0))>0

--select *	from #tblStorageDocsHdr H
--select *	from #tblStorageDocsDtl
--select count(*)	from #tblStorageDocsDtl
--select count(*)	from #tblStorageDocsDtlSum


	set @JoinHdrAcnt = ' substring(H.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ') =A.AcntCode And A.PartNumber='+ltrim(str(@PartNumber)) 

	set @JoinHdrDtl	=' H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo '

	set @FilterLink=''
	set @LinkTable1=0
	set @LinkTable2=0
	set @LinkTable3=0

---------------------------Filter GoodsID-----------------------------------------------------------------------
	if @FilterType=1
	begin
	set @GoodsName = ',(SELECT GoodsName from inv.tblGoodsDtl WHERE GoodsID=D.GoodsID AND LanguageID='+@LangID +')'

	IF (select Layer1 from pub.tblCodeLayer WHERE Layer1>0 AND TableName = 'inv.tblGoods' AND PartNumber=2 )>0
		SET @GoodsName = ',pub.funGetGoodsName (D.GoodsID,'+@LangID +') '

		SET @StrSelect = 
		' Insert into #tblSale (GroupID,GroupName) 
			SELECT  Distinct  D.GoodsID ' + @GoodsName + '
			FROM #tblStorageDocsHdr AS H 
			INNER JOIN #tblStorageDocsDtl AS D ON '+@JoinHdrDtl 
			
		if @StrAcntWhere<>'' SET @StrSelect = @StrSelect +@StrAcntWhere 
								
		set @LinkTable1=1
		set @LinkTable2=1
		              
		set @FilterLink=' D.GoodsID=#tblSale.GroupID'
		set @FilterLink2=' D.GoodsID=#tblSale.GroupID'
		set @GroupBy=' #tblSale.GroupID'
		set @FieldName=' GoodsID '
		set @LinkType=2

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;

	end
---------------------------Filter GoodsID 2-----------------------------------------------------------------------
	if @FilterType=2
	begin
		set @GoodsName = ',(SELECT GoodsName from inv.tblGoodsDtl WHERE GoodsID=substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+ @GoodsLayer1)) + ') AND LanguageID='+@LangID +')'

		IF (select Layer2 from pub.tblCodeLayer WHERE Layer1>0 AND TableName = 'inv.tblGoods' AND PartNumber=2 )>0
			SET @GoodsName = ', pub.funGetGoodsName(substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+ @GoodsLayer1)) + '),'+@LangID +')'

		SET @StrSelect = 
		' Insert into  #tblSale (GroupID,GroupName) 
			SELECT  Distinct substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+ @GoodsLayer1)) + ')' + @GoodsName + '
			FROM #tblStorageDocsHdr AS H 
			INNER JOIN #tblStorageDocsDtl AS D ON '+@JoinHdrDtl 

		if @StrAcntWhere<>'' SET @StrSelect = @StrSelect +@StrAcntWhere

		set @LinkTable1=1
		set @LinkTable2=1
		          			
		set @FilterLink=' substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ')=#tblSale.GroupID'
		set @FilterLink2=' D.GoodsID=#tblSale.GroupID'
		set @GroupBy=' substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ')  '
		set @FieldName=' GoodsID '
		set @LinkType=2

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		
	end
---------------------------Filter GoodsID 3-----------------------------------------------------------------------
	if @FilterType=3
	begin
		SET @GoodsName = ',(SELECT GoodsName from inv.tblGoodsDtl WHERE GoodsID=substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+ @GoodsLayer1+@GoodsLayer2)) + ') AND LanguageID='+@LangID +')'

		IF (select Layer2 from pub.tblCodeLayer WHERE Layer1>0 AND TableName = 'inv.tblGoods' AND PartNumber=2 )>0
			SET @GoodsName = ', pub.funGetGoodsName(substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+ @GoodsLayer1+@GoodsLayer2)) + '),'+@LangID +')'

		SET @StrSelect = 
		' Insert into  #tblSale (GroupID,GroupName) 
			SELECT  Distinct substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1+@GoodsLayer2)) + ')' + @GoodsName + '  
			FROM #tblStorageDocsHdr AS H 
			INNER JOIN #tblStorageDocsDtl AS D ON '+@JoinHdrDtl 
					
		if 	@StrAcntWhere<>'' SET @StrSelect = @StrSelect +@StrAcntWhere

		set @LinkTable1=1
		set @LinkTable2=1

		set @FilterLink='  substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1+@GoodsLayer2)) + ')=#tblSale.GroupID'
		set @FilterLink2=' D.GoodsID=#tblSale.GroupID'
		set @GroupBy='   substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1+@GoodsLayer2)) + ')  '
		set @FieldName=' GoodsID '
		set @LinkType=2
		
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		
	end
---------------------------Filter Months-----------------------------------------------------------------------
	if @FilterType=4
	begin
		SET @StrSelect = 
			' Insert into #tblSale (GroupID) 
				SELECT  Distinct  Substring(H.DocDate,6,2)
				FROM #tblStorageDocsHdr AS H ' 
						
		if 	@StrAcntWhere<>'' SET @StrSelect = @StrSelect +@StrAcntWhere

		set @LinkTable1=1

		if 	@StrWhereD<>'' set @LinkTable2=1
					
		set @FilterLink='  Substring(H.DocDate,6,2)=#tblSale.GroupID'
		set @FilterLink2=' D.Months=#tblSale.GroupID'
		set @GroupBy=' Substring(H.DocDate,6,2)  '
		set @FieldName=' Months '
		set @LinkType=1

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		
		update #tblSale		set GroupName='فروردین'  where GroupID='01'
		update #tblSale		set GroupName='اردیبهشت'  where GroupID='02'
		update #tblSale		set GroupName='خرداد'  where GroupID='03'
		update #tblSale		set GroupName='تیر'  where GroupID='04'
		update #tblSale		set GroupName='مرداد'  where GroupID='05'
		update #tblSale		set GroupName='شهریور'  where GroupID='06'
		update #tblSale		set GroupName='مهر'  where GroupID='07'
		update #tblSale		set GroupName='آبان'  where GroupID='08'
		update #tblSale		set GroupName='آذر'  where GroupID='09'
		update #tblSale		set GroupName='دی'  where GroupID='10'
		update #tblSale		set GroupName='بهمن'  where GroupID='11'
		update #tblSale		set GroupName='اسفند'  where GroupID='12'
	end
---------------------------Filter DocDate-----------------------------------------------------------------------
	if @FilterType=5
	begin
		SET @StrSelect = 
		' Insert into  #tblSale (GroupID,GroupName) 
			SELECT  Distinct  H.DocDate,H.DocDate
			FROM #tblStorageDocsHdr AS H '
					
		if 	@StrAcntWhere<>''  SET @StrSelect = @StrSelect +@StrAcntWhere

		set @LinkTable1=1
		
		if 	@StrWhereD<>'' set @LinkTable2=1
				
		set @FilterLink='  H.DocDate=#tblSale.GroupID'
		set @FilterLink2=' D.DocDate=#tblSale.GroupID'
		set @GroupBy=' H.DocDate '
		set @FieldName=' DocDate '
		set @LinkType=1

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;

	end
---------------------------Filter VisitPathID3-----------------------------------------------------------------------
	if @FilterType=6
	begin
		SET @StrSelect = 
		' Insert into #tblSale (GroupID) 
			SELECT  Distinct  A.VisitPathID3
			FROM #tblStorageDocsHdr AS H '
		
		SET @StrSelect = @StrSelect +'INNER JOIN acc.tblAcnt AS A  ON '+@JoinHdrAcnt 

		set @LinkTable1=1

		if 	@StrWhereD<>'' set @LinkTable2=1

		set @LinkTable3=1 
		set @FilterLink='  A.VisitPathID3=#tblSale.GroupID'
		set @FilterLink2=' D.VisitPathID3=#tblSale.GroupID'
		set @GroupBy=' A.VisitPathID3 '
		set @FieldName=' VisitPathID3 '
		set @LinkType=3

		print  @StrSelect;             
		EXEC sp_executesql @StrSelect;
		
		update #tblSale	
			set GroupName= isnull(VisitPathName,'') 
			from #tblSale a 
			inner join  acc.tblVisitPathDtl b
			on a.GroupID=b.VisitPathID

	end
---------------------------Filter VisitPathID4-----------------------------------------------------------------------
	if @FilterType=7
	begin
		SET @StrSelect = 
		' Insert into  #tblSale (GroupID) 
			SELECT  Distinct  A.VisitPathID4
			FROM #tblStorageDocsHdr AS H '
				
		SET @StrSelect = @StrSelect +' INNER JOIN acc.tblAcnt AS A  ON '+@JoinHdrAcnt 
		set @LinkTable1=1

		if 	@StrWhereD<>'' set @LinkTable2=1

		set @LinkTable3=1 
		set @FilterLink='  A.VisitPathID4=#tblSale.GroupID'
		set @FilterLink2=' D.VisitPathID4=#tblSale.GroupID'
		set @GroupBy=' A.VisitPathID4 '
		set @FieldName=' VisitPathID4 '
		set @LinkType=3

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;

		update #tblSale	
			set GroupName= isnull(VisitPathName,'') 
			from #tblSale a 
			inner join acc.tblVisitPathDtl b
			on a.GroupID=b.VisitPathID

	end	
---------------------------Filter AcntCode-----------------------------------------------------------------------
	if @FilterType=8
	begin
		SET @StrSelect = ' 
		INSERT INTO #tblSale (GroupID) 
			SELECT Distinct SubString(H.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ') 
			FROM #tblStorageDocsHdr AS H '
				
		if 	@StrAcntWhere<>''  SET @StrSelect = @StrSelect +@StrAcntWhere
			
		set @LinkTable1  = 1 
		
		if 	@StrWhereD  <> '' set @LinkTable2  = 1

		set @FilterLink	 = ' substring(H.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ') = #tblSale.GroupID'
		set @FilterLink2 = ' D.AcntCode=#tblSale.GroupID'
		set @GroupBy	 = ' substring(H.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ')  '
		set @FieldName	 = ' AcntCode '
		set @LinkType=1
		
		PRINT @StrSelect;             
		EXEC sp_executesql @StrSelect;	

		Update #tblSale Set GroupName=acc.funGetAcntName(GroupID, @PartNumber, @LangID)

	end
---------------------------Filter VisitorAcntCode-----------------------------------------------------------------------
	if @FilterType=9
	begin
		SET @StrSelect = 
		' Insert into  #tblSale (GroupID) 
			SELECT  Distinct  substring(H.VisitorAcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ')
			FROM #tblStorageDocsHdr AS H '
				
		if 	@StrAcntWhere<>'' SET @StrSelect = @StrSelect +@StrAcntWhere
		
		set @LinkTable1=1

		if 	@StrWhereD<>'' set @LinkTable2=1

		set @FilterLink=' substring(H.VisitorAcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ')=#tblSale.GroupID'
		set @FilterLink2=' D.VisitorAcntCode=#tblSale.GroupID'
		set @GroupBy='   substring(H.VisitorAcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ') '
		set @FieldName=' VisitorAcntCode '
		set @LinkType=1

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		
		update #tblSale Set GroupName=acc.funGetAcntName(GroupID,  @PartNumber , @LangID )

	end
---------------------------Filter DistributerID1-----------------------------------------------------------------------
	if @FilterType=10
	begin
		SET @StrSelect = 
		' Insert into #tblSale (GroupID) 
			SELECT  Distinct  H.DistributerID1 
			FROM #tblStorageDocsHdr AS H '
				
		if 	@StrAcntWhere<>'' SET @StrSelect = @StrSelect +@StrAcntWhere
		
		set @LinkTable1=1

		if 	@StrWhereD<>'' set @LinkTable2=1

		set @FilterLink='  H.DistributerID1=#tblSale.GroupID'
		set @FilterLink2=' D.GroupID=#tblSale.GroupID'
		set @GroupBy='  H.DistributerID1 '
		set @FieldName=' GroupID '
		set @LinkType=1

		print @StrSelect;             
		EXEC sp_executesql @StrSelect;

		update #tblSale		
			set GroupName= isnull(FirstName+' '+ LastName,'') 
			from #tblSale a 
			inner join  prs.tblPersonnelsDtl b
			on a.GroupID=b.PersonnelID

	end
---------------------------Filter DistributerID2-----------------------------------------------------------------------
	if @FilterType=11
	begin
		SET @StrSelect = 
		' Insert into  #tblSale (GroupID) 
			SELECT  Distinct  H.DistributerID2 
			FROM #tblStorageDocsHdr AS H '
					
		if 	@StrAcntWhere<>''  SET @StrSelect = @StrSelect +@StrAcntWhere
		
		set @LinkTable1=1

		if 	@StrWhereD<>'' set @LinkTable2=1
			
		set @FilterLink='  H.DistributerID2=#tblSale.GroupID'
		set @FilterLink2=' D.DistributerID=#tblSale.GroupID'
		set @GroupBy='  H.DistributerID2 '
		set @FieldName=' DistributerID '
		set @LinkType=1

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		
		update #tblSale	
			set GroupName= isnull(FirstName+' '+ LastName,'') 
			from #tblSale a 
			inner join  prs.tblPersonnelsDtl b
			on a.GroupID=b.PersonnelID

	end
---------------------------Filter DriverID-----------------------------------------------------------------------
	if @FilterType=12
	begin
		SET @StrSelect = ' Insert into  #tblSale (GroupID) SELECT  Distinct  H.DriverID 
		FROM #tblStorageDocsHdr AS H '
		
		if 	@StrAcntWhere<>''  SET @StrSelect = @StrSelect +@StrAcntWhere
		
		set @LinkTable1=1
		if 	@StrWhereD<>'' 
		set @LinkTable2=1
				     
		set @FilterLink='  H.DriverID=#tblSale.GroupID'
		set @FilterLink2=' D.DriverID=#tblSale.GroupID'
		set @GroupBy='  H.DriverID '
		set @FieldName=' DriverID '
		set @LinkType=1
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
	
	 update #tblSale set GroupName= isnull(FirstName+' '+ LastName,'') from #tblSale a 
	 inner join  pub.tblDriversDtl b on a.GroupID=b.DriverID
	end	
---------------------------Filter LocationID-----------------------------------------------------------------------
 	if @FilterType=13
	begin
	
	SET @StrSelect = 
		' Insert into  #tblSale (GroupID) 
			SELECT  Distinct  H.LocationID 
			FROM #tblStorageDocsHdr AS H '
		
		if 	@StrAcntWhere<>'' SET @StrSelect = @StrSelect +@StrAcntWhere

		set @LinkTable1=1

		if 	@StrWhereD<>'' set @LinkTable2=1

		set @FilterLink='  H.LocationID=#tblSale.GroupID'
		set @FilterLink2=' D.LocationID=#tblSale.GroupID'
		set @GroupBy='  H.LocationID '
		set @FieldName=' LocationID '
		set @LinkType=1

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;

		update #tblSale		
			set GroupName= isnull(LocationName,'') 
			from #tblSale	a 
			inner join pub.tblLocationsDtl  b
			on a.GroupID=b.LocationID and b.LanguageID=@LangID
		
	end
	---------------------------Filter AcntCode1-----------------------------------------------------------------------
	if @FilterType=14
	begin

	 update #tblStorageDocsHdr	
	 set AcntCode1=SUBSTRING(AcntCode,@StartLayer1,@LayerLen1)
		
		SET @StrSelect = 
		' Insert into #tblSale (GroupID,GroupName) 
			SELECT  Distinct  H.AcntCode1 ,AcntName
			FROM #tblStorageDocsHdr AS H 
			inner join acc.tblAcntDtl AD on AD.AcntCode=H.AcntCode1 And PartNumber=1 AND LanguageID='+@LangID +'			'
			
		if 	@StrWhereD  <> '' set @LinkTable2  = 1
			
		if @StrAcntWhere<>'' SET @StrSelect = @StrSelect +@StrAcntWhere 
				
		set @LinkTable1=1
		              
		set @FilterLink=' H.AcntCode1=#tblSale.GroupID'
		set @FilterLink2=' D.AcntCode1=#tblSale.GroupID'
		set @GroupBy=' #tblSale.GroupID'
		set @FieldName=' AcntCode1 '
		set @LinkType=1

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;

	end
	---------------------------Filter AcntCode2-----------------------------------------------------------------------
	if @FilterType=15
	begin

	 update #tblStorageDocsHdr	 
	 set AcntCode2=SUBSTRING(AcntCode,@StartLayer2,@LayerLen2)
		
		SET @StrSelect = 
		' Insert into #tblSale (GroupID,GroupName) 
			SELECT  Distinct  H.AcntCode2 ,AcntName
			FROM #tblStorageDocsHdr AS H 
			inner join acc.tblAcntDtl AD on AD.AcntCode=H.AcntCode2  And PartNumber=2 AND LanguageID='+@LangID +'			'

		if 	@StrWhereD  <> '' set @LinkTable2  = 1

		if @StrAcntWhere<>'' SET @StrSelect = @StrSelect +@StrAcntWhere 
								
		set @LinkTable1=1
						              
		set @FilterLink=' H.AcntCode2=#tblSale.GroupID'
		set @FilterLink2=' D.AcntCode2=#tblSale.GroupID'
		set @GroupBy=' #tblSale.GroupID'
		set @FieldName=' AcntCode2 '
		set @LinkType=1

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;

	end
	---------------------------Filter AcntCode3-----------------------------------------------------------------------
	if @FilterType=16
	begin

	 update #tblStorageDocsHdr
	 set AcntCode3=SUBSTRING(AcntCode,@StartLayer3,@LayerLen3)

		SET @StrSelect = 
		' Insert into #tblSale (GroupID,GroupName) 
			SELECT  Distinct  H.AcntCode3 ,AcntName
			FROM #tblStorageDocsHdr AS H 
			inner join acc.tblAcntDtl AD on AD.AcntCode=H.AcntCode3  And PartNumber=3 AND LanguageID='+@LangID +'			'
		
		if 	@StrWhereD  <> '' set @LinkTable2  = 1
			
		if @StrAcntWhere<>'' SET @StrSelect = @StrSelect +@StrAcntWhere 
								
		set @LinkTable1=1
		              
		set @FilterLink=' H.AcntCode3=#tblSale.GroupID'
		set @FilterLink2=' D.AcntCode3=#tblSale.GroupID'
		set @GroupBy=' #tblSale.GroupID'
		set @FieldName=' AcntCode3 '
		set @LinkType=1

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;

	end
	---------------------------Filter AcntCode4-----------------------------------------------------------------------
	if @FilterType=17
	begin

	 update #tblStorageDocsHdr
	 set AcntCode4=SUBSTRING(AcntCode,@StartLayer4,@LayerLen4)

		SET @StrSelect = 
		' Insert into #tblSale (GroupID,GroupName) 
			SELECT  Distinct  H.AcntCode4 ,AcntName
			FROM #tblStorageDocsHdr AS H 
			inner join acc.tblAcntDtl AD on AD.AcntCode=H.AcntCode4  And PartNumber=4 AND LanguageID='+@LangID +'			'
		
		if 	@StrWhereD  <> '' set @LinkTable2  = 1			

		if @StrAcntWhere<>'' SET @StrSelect = @StrSelect +@StrAcntWhere 
								
		set @LinkTable1=1
		              
		set @FilterLink=' H.AcntCode4=#tblSale.GroupID'
		set @FilterLink2=' D.AcntCode4=#tblSale.GroupID'
		set @GroupBy=' #tblSale.GroupID'
		set @FieldName=' AcntCode4 '
		set @LinkType=1

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;

	end
	if @FilterType=18
	begin
		SET @StrSelect = ' 
		INSERT INTO #tblSale (GroupID) 
			SELECT Distinct SerialNoPNO
			FROM #tblStorageDocsHdr AS H '
				
		if 	@StrAcntWhere<>''  SET @StrSelect = @StrSelect +@StrAcntWhere
			
		set @LinkTable1  = 1 
		
		if 	@StrWhereD  <> '' set @LinkTable2  = 1

		set @FilterLink	 = ' H.SerialNoPNO = #tblSale.GroupID'
		set @FilterLink2 = ' D.SerialNoPNO=#tblSale.GroupID'
		set @GroupBy	 = ' H.SerialNoPNO  '
		set @FieldName	 = ' SerialNoPNO '
		set @LinkType=1
		
		PRINT @StrSelect;             
		EXEC sp_executesql @StrSelect;	

	Update #tblSale Set GroupName=GroupID

	end
---------
-------------Sets --------------------------------------------------------------------------------------
	 SET @StrSelect =''

	 if @LinkType=1
	 begin
		SET @StrSelect1 =  ' Inner join #tblStorageDocsHdr AS H ON' + @FilterLink 
		if @LinkTable2=1 
			if @FilterType<=3
				SET @StrSelect1 =@StrSelect1+' INNER JOIN #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl
							
		if @LinkTable3=1  SET @StrSelect1 =@StrSelect1+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end
	
	if @LinkType=2
	begin
		SET @StrSelect1 =   ' Inner join #tblStorageDocsDtl AS D  ON'+@FilterLink 
		if @LinkTable1=1  SET @StrSelect1 =@StrSelect1+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect1 =@StrSelect1+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end
	
	if @LinkType=3
	begin
		SET @StrSelect1 =   ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink 
		if @LinkTable1=1  SET @StrSelect1 =@StrSelect1+' INNER JOIN #tblStorageDocsHdr AS H ON '+@JoinHdrAcnt
		if @LinkTable2=1  
			
		if @FilterType<=3
			SET @StrSelect1 =@StrSelect1+ ' Inner join #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl 
		
	end	
	----------- Set LastSale = DocDate ------------------------------------------------------------------	
	SET @StrSelect = '
		Update #tblSale Set LastSale = D.MDocDate
		From #tblSale  
		Inner Join 
		(
			Select Max(H.DocDate) MDocDate, ' + @GroupBy + ' ' + @FieldName + ' 
			From #tblSale 
		  '
	SET @StrSelect =  @StrSelect + @StrSelect1 +' 
		Where H.ProcessID = 90 
	    Group by  ' + @GroupBy + ' 
	    ) D On ' + @FilterLink2
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	----------- Set LastRet = DocDate ------------------------------------------------------------------	
	SET @StrSelect = '
		Update #tblSale Set LastRet = D.MDocDate
		From #tblSale  
		Inner Join 
		(
			Select Max(H.DocDate) MDocDate, ' + @GroupBy + ' ' + @FieldName + ' 
			From #tblSale 
		  '
	SET @StrSelect =  @StrSelect + @StrSelect1 +' 
		Where H.ProcessID = 100 
	    Group by ' + @GroupBy + ' 
	    ) D On ' + @FilterLink2
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
		
	----------- Set   Sale=SaleCounr ------------------------------------------------------------------	
	SET @StrSelect = ' 	update #tblSale  Set Sale= D.DocDates from(
						select Count(Distinct  H.DocDate) DocDates , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
	SET @StrSelect =  @StrSelect + @StrSelect1 + ' Where  H.ProcessID=90 Group by  ' + @GroupBy + ' )D where ' + @FilterLink2
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	----------- Set   Ret=RetCount ------------------------------------------------------------------	
	SET @StrSelect = ' 	update #tblSale  Set Ret= D.DocDates from(
		select 	Count(Distinct  H.DocDate) DocDates , '+@GroupBy+' '+ @FieldName +' From #tblSale '
		
	SET @StrSelect =  @StrSelect + @StrSelect1 +' Where  H.ProcessID=100 
	    Group by  '+@GroupBy+' )D where  '+@FilterLink2

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
		
	Declare  @DiscountHdr as nvarchar(100)
	if @GoodsID>0 or @FilterType<=3
		set @DiscountHdr='+ D.DiscountHdr'
		else
		set @DiscountHdr=' '

	----------- Set   A1=Price ------------------------------------------------------------------	
	SET @StrSelect = ' 	update #tblSale  Set A1= D.Price ,A2=D.DiscountDtl,A20=D.DiscountDtl2,A17=D.GoodsWeight,A18=D.PureWeight from(
		select Sum( GoodsPrice * GoodsQuantity ) Price ,Sum( GoodsWeight * GoodsQuantity ) GoodsWeight ,Sum( PureWeight * GoodsQuantity ) PureWeight ,Sum(DiscountDtl '+@DiscountHdr+') DiscountDtl  ,Sum(DiscountDtl2) DiscountDtl2 , '+@GroupBy+' '+ @FieldName +' From #tblSale '

	if @LinkType=1
	 begin
		SET @StrSelect =  @StrSelect+ ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink 
		+' INNER JOIN  #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =@StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end
	
	if @LinkType=2
	begin
		SET @StrSelect =  @StrSelect+  ' Inner join #tblStorageDocsDtl AS D  ON'+@FilterLink 
		if @LinkTable1=1  SET @StrSelect =  @StrSelect+ ' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =  @StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end

	if @LinkType=3
	begin
		SET @StrSelect =  @StrSelect+  ' INNER JOIN acc.tblAcnt AS A ON ' + @FilterLink 
		+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt
		+ ' Inner join #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl 
	end
	
	SET @StrSelect =  @StrSelect  +' Where H.ProcessID=90 Group by  '+@GroupBy+' )D where  '+@FilterLink2
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	SET @StrSelect = ' 	update #tblSale  Set B1= D.Price,B2= D.DiscountDtl,B20= D.DiscountDtl2,B17=D.GoodsWeight,B18=D.PureWeight from(
		select Sum( GoodsPrice * GoodsQuantity ) Price,Sum(DiscountDtl '+@DiscountHdr+' ) DiscountDtl,Sum(DiscountDtl2) DiscountDtl2,Sum( GoodsWeight * GoodsQuantity ) GoodsWeight ,Sum( PureWeight * GoodsQuantity ) PureWeight , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
	if @LinkType=1
	 begin
		SET @StrSelect =  @StrSelect+ ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink 
			+' INNER JOIN #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl

		if @LinkTable3=1  SET @StrSelect =@StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end
	
	if @LinkType=2
	begin
		SET @StrSelect =  @StrSelect+  ' Inner join #tblStorageDocsDtl AS D  ON'+@FilterLink 
		if @LinkTable1=1  SET @StrSelect =  @StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =  @StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end

	if @LinkType=3
	begin
		SET @StrSelect =  @StrSelect+  ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink 
		if @LinkTable1=1  
			SET @StrSelect =@StrSelect+' INNER JOIN #tblStorageDocsHdr AS H ON '+@JoinHdrAcnt
		SET @StrSelect =@StrSelect +' Inner join #tblStorageDocsDtl AS D ON '+@JoinHdrDtl 
	end
	
	SET @StrSelect =  @StrSelect  +' Where  H.ProcessID=100 
                       Group by  '+@GroupBy+' )D where  '+@FilterLink2

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	if @GoodsID<>0  or @FilterType<=3
		set @DiscountHdr='0'
		else
		set @DiscountHdr=' DiscountHdr'
	----------- Set   A3=DiscountHdr ------------------------------------------------------------------	
	if @FilterType>3
	begin
		SET @StrSelect = 'update #tblSale Set A3= D.DiscountHdr from(
			select	Sum('+@DiscountHdr+') DiscountHdr , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
		SET @StrSelect =  @StrSelect +@StrSelect1 +' Where  H.ProcessID=90 Group by  '+@GroupBy+')D where  '+@FilterLink2
                      
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;

		SET @StrSelect = ' 	update #tblSale Set B3= D.DiscountHdr from(
			select 	Sum('+@DiscountHdr+') DiscountHdr , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
		SET @StrSelect =  @StrSelect +@StrSelect1 +' Where  H.ProcessID=100 
						   Group by  '+@GroupBy+')D where  '+@FilterLink2
                      
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
	end
	else
		begin
			update #tblSale Set B3=0 , A3=0

		SET @StrSelect = 'update #tblSale Set A3= D.DiscountHdr from(
			select	Sum( 0) DiscountHdr , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
		SET @StrSelect =  @StrSelect +@StrSelect1 +' Where  H.ProcessID=90 Group by  '+@GroupBy+')D where  '+@FilterLink2
                      
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;

		SET @StrSelect = ' 	update #tblSale Set B3= D.DiscountHdr from(
			select 	Sum(0)  DiscountHdr , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
		SET @StrSelect =  @StrSelect +@StrSelect1 +' Where  H.ProcessID=100 
						   Group by  '+@GroupBy+')D where  '+@FilterLink2
                      
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;

		end

	----------- Set   A4=------------------------------------------------------------------	
	SET @StrSelect = ' 	update #tblSale Set A4= A1-A2-A3,B4= B1-B2-B3 '          

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A5=COUNT (GoodsID)------------------------------------------------------------------	
	if @FilterType<>1
	BEGIN
		SET @StrSelect = ' 	update #tblSale Set A5= D.GoodsIDs from(
		Select '+ @FieldName +',COUNT( Distinct  GoodsIDs) GoodsIDs from ( 
		select 		Distinct D.GoodsID GoodsIDs , '+@GroupBy+' '+ @FieldName +' From #tblSale '

		if @LinkType=1
		 begin
			SET @StrSelect =  @StrSelect+ ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink 
			+' INNER JOIN #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl
			if @LinkTable3=1  SET @StrSelect =@StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
		end
			
		if @LinkType=2
			begin
			SET @StrSelect =  @StrSelect+  ' Inner join #tblStorageDocsDtl AS D  ON'+@FilterLink 
			 SET @StrSelect =  @StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
			if @LinkTable3=1  SET @StrSelect =  @StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
			end

		if @LinkType=3
			begin
			SET @StrSelect =  @StrSelect+  ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink 
			 SET @StrSelect=@StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt
			 SET @StrSelect =@StrSelect+ ' Inner join #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl 
			end

			SET @StrSelect =  @StrSelect +' Where  H.ProcessID=90 
							   Group by  '+@GroupBy+' ,D.GoodsID)a Group by '+@FieldName+' )D where  '+@FilterLink2
	                      
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
				
		set @StrSelect=REPLACE(@StrSelect,'A5','AA5') 
		set @StrSelect=REPLACE(@StrSelect,'#tblStorageDocsDtl','#tblStorageDocsDtlSum') 

		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
	END		
	ELSE
		update #tblSale Set A5 = 1 ,A6=1,A7=1, AA5 = 1 ,AA6=1,AA7=1


	SET @StrSelect = ' 	update #tblSale Set B5= D.GoodsIDs from(
	Select '+ @FieldName +',COUNT( Distinct  GoodsIDs) GoodsIDs from ( 
	select 		Distinct D.GoodsID GoodsIDs , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
	if @LinkType=1
	begin
		SET @StrSelect =  @StrSelect+ ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink
		 +' INNER JOIN #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =@StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end
	
	if @LinkType=2
	begin
		SET @StrSelect =  @StrSelect+  ' Inner join #tblStorageDocsDtl AS D  ON'+@FilterLink 
		if @LinkTable1=1  SET @StrSelect =  @StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =  @StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end

	if @LinkType=3
	begin
		SET @StrSelect =  @StrSelect+  ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink 
		if @LinkTable1=1  
			SET @StrSelect =@StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt
		SET @StrSelect =@StrSelect+ ' Inner join #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl 
	end

	SET @StrSelect =  @StrSelect +' Where  H.ProcessID=100 
                       Group by  '+@GroupBy+' ,D.GoodsID)a Group by  '+@FieldName+' )D where  '+@FilterLink2
                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A6=GoodsLayer1------------------------------------------------------------------	
	if @FilterType<>1
	BEGIN
		SET @StrSelect = ' 	update #tblSale 
			Set A6= D.GoodsLayer from(
			Select '+ @FieldName +',COUNT(Distinct  GoodsLayer) GoodsLayer from ( 					
			select 	Distinct	D.GoodsLayer1  GoodsLayer , '+@GroupBy+' '+ @FieldName +' 
			From #tblSale '

		if @LinkType=1
			SET @StrSelect =  @StrSelect + ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink 
			+' INNER JOIN  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * From #tblStorageDocsDtl) AS D  ON '+@JoinHdrDtl
		
		if @LinkType=2
			SET @StrSelect =  @StrSelect + ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl )AS D  ON'+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
		
		if @LinkType=3
			SET @StrSelect =  @StrSelect + ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt+ ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl ) AS D  ON'+@JoinHdrDtl 
			
			SET @StrSelect =  @StrSelect +
			' Where  H.ProcessID=90 
			  Group by  '+@GroupBy+'  ,D.GoodsLayer1)a   
			  Group by  '+@FieldName+')D
			  where  '+@FilterLink2
		                      
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;

		set @StrSelect=REPLACE(@StrSelect,'A6','AA6') 
		set @StrSelect=REPLACE(@StrSelect,'#tblStorageDocsDtl','#tblStorageDocsDtlSum') 

		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;

	END
	
	SET @StrSelect = 
	'update #tblSale 
	 Set B6= D.GoodsLayer from(
	 Select '+ @FieldName +',COUNT( Distinct  GoodsLayer) GoodsLayer from ( 					
	 select Distinct	D.GoodsLayer1  GoodsLayer , '+@GroupBy+' '+ @FieldName +' 
	 From #tblSale '

	if @LinkType=1
		SET @StrSelect =  @StrSelect + ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink +' INNER JOIN  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl) AS D  ON '+@JoinHdrDtl
	
	if @LinkType=2
		SET @StrSelect =  @StrSelect + ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl )AS D  ON'+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
	
	if @LinkType=3
		SET @StrSelect =  @StrSelect + ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt+ ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl ) AS D  ON'+@JoinHdrDtl 
		
		SET @StrSelect =  @StrSelect +
		' Where  H.ProcessID=100 
		  Group by  '+@GroupBy+'    ,D.GoodsLayer1)a   
		  Group by  '+@FieldName+'     )D
		  where  '+@FilterLink2
	                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A7=GoodsLayer2------------------------------------------------------------------
	if @FilterType<>1
	BEGIN	
		SET @StrSelect = 
		'update #tblSale 
		 Set A7= D.GoodsLayer from(
			 Select '+ @FieldName +',COUNT( Distinct  GoodsLayer) GoodsLayer from ( 					
			 select 			Distinct	D.GoodsLayer1  GoodsLayer , '+@GroupBy+' '+ @FieldName +' 
			 From #tblSale '

		if @LinkType=1
			SET @StrSelect =  @StrSelect + ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink +' INNER JOIN  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl ) AS D  ON '+@JoinHdrDtl
		
		if @LinkType=2
			SET @StrSelect =  @StrSelect + ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ',' + ltrim(str(@GoodsLayer2)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl )AS D  ON'+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
		
		if @LinkType=3
			SET @StrSelect =  @StrSelect + ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt+ ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl ) AS D  ON'+@JoinHdrDtl 
			
			SET @StrSelect =  @StrSelect +
			' Where  H.ProcessID=90 
			Group by  '+@GroupBy+' ,D.GoodsLayer1)a   
			 Group by  '+@FieldName+'     )D
			where  '+@FilterLink2
		                      
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;

		set @StrSelect=REPLACE(@StrSelect,'A7','AA7') 
		set @StrSelect=REPLACE(@StrSelect,'#tblStorageDocsDtl','#tblStorageDocsDtlSum') 

		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
	END
	
	SET @StrSelect = 
	' 	update #tblSale 
		Set B7= D.GoodsLayer from(
			Select '+ @FieldName +',COUNT( Distinct GoodsLayer) GoodsLayer from ( 					
			select Distinct	D.GoodsLayer1  GoodsLayer , '+@GroupBy+' '+ @FieldName +' 
			From #tblSale '

	if @LinkType=1
		SET @StrSelect =  @StrSelect + ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink +' INNER JOIN  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl ) AS D  ON '+@JoinHdrDtl

	if @LinkType=2
		SET @StrSelect =  @StrSelect + ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ',' + ltrim(str(@GoodsLayer2)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl )AS D  ON'+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
	
	if @LinkType=3
		SET @StrSelect =  @StrSelect + ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt+ ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl ) AS D  ON'+@JoinHdrDtl 
		
	SET @StrSelect =  @StrSelect +
	' Where  H.ProcessID=100 
	 Group by  '+@GroupBy+'    ,D.GoodsLayer1)a   
	 Group by  '+@FieldName+'     )D
	 where  '+@FilterLink2
                       
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A8=GoodsPrice  ------------------------------------------------------------------	
	SET @StrSelect = 
	' 	update #tblSale 
		Set A8= D.GoodsPrice from(
		Select '+ @FieldName +',COUNT( Distinct GoodsPrice) GoodsPrice from ( 					
		select 	Distinct	D.GoodsPrice   , '+@GroupBy+' '+ @FieldName +' 
		From #tblSale '

	if @LinkType=1
		SET @StrSelect =  @StrSelect + ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink +' INNER JOIN  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 ,* from #tblStorageDocsDtl) AS D  ON '+@JoinHdrDtl
	
	if @LinkType=2
		SET @StrSelect =  @StrSelect + ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ',' + ltrim(str(@GoodsLayer2)) + ' ) GoodsLayer1 ,* from #tblStorageDocsDtl)AS D  ON'+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
	
	if @LinkType=3
		SET @StrSelect =  @StrSelect + ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt+ ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 ,* from #tblStorageDocsDtl) AS D  ON'+@JoinHdrDtl 
		
	SET @StrSelect =  @StrSelect +
	' Where  H.ProcessID=90 
	 Group by  '+@GroupBy+'  ,D.GoodsPrice)a   
	 Group by  '+@FieldName+'     )D
	 where  '+@FilterLink2
                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	SET @StrSelect = 
	' 	update #tblSale 
		Set B8= D.GoodsPrice from(
		Select '+ @FieldName +',COUNT(Distinct  GoodsPrice) GoodsPrice from ( 					
		select 	Distinct	D.GoodsPrice   , '+@GroupBy+' '+ @FieldName +' 
		From #tblSale '
	
	if @LinkType=1
		SET @StrSelect =  @StrSelect + ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink +' INNER JOIN  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 ,* from #tblStorageDocsDtl) AS D  ON '+@JoinHdrDtl
	
	if @LinkType=2
		SET @StrSelect =  @StrSelect + ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ',' + ltrim(str(@GoodsLayer2)) + ' ) GoodsLayer1 ,* from #tblStorageDocsDtl)AS D  ON'+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
	
	if @LinkType=3
		SET @StrSelect =  @StrSelect + ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt+ ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl) AS D  ON'+@JoinHdrDtl 
		
	SET @StrSelect =  @StrSelect +
	' Where  H.ProcessID=100 
	  Group by  '+@GroupBy+' ,D.GoodsPrice)a   
	  Group by  '+@FieldName+' )D
	  where  '+@FilterLink2
                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A9=SerialNo  ------------------------------------------------------------------	
	SET @StrSelect = 
	' 	update #tblSale 
		Set A9= D.SerialNo from(
		Select '+ @FieldName +',COUNT(Distinct SerialNo) SerialNo from ( 					
		select Distinct	D.SerialNo   , '+@GroupBy+' '+ @FieldName +' 
		From #tblSale '

	if @LinkType=1
		SET @StrSelect =  @StrSelect + ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink +' INNER JOIN  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl) AS D  ON '+@JoinHdrDtl
	
	if @LinkType=2
		SET @StrSelect =  @StrSelect + ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ',' + ltrim(str(@GoodsLayer2)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl )AS D  ON'+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
	
	if @LinkType=3
		SET @StrSelect =  @StrSelect + ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt+ ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl) AS D  ON'+@JoinHdrDtl 
		
	SET @StrSelect =  @StrSelect +
	' Where  H.ProcessID=90 
	  Group by  '+@GroupBy+' ,D.SerialNo)a   
	  Group by  '+@FieldName+'     )D
	  where  '+@FilterLink2
                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	SET @StrSelect = 
	' 	update #tblSale 
		Set B9= D.SerialNo from(
		Select '+ @FieldName +',COUNT(Distinct SerialNo) SerialNo from ( 					
		select 	Distinct	D.SerialNo   , '+@GroupBy+' '+ @FieldName +' 
        From #tblSale '

	if @LinkType=1
		SET @StrSelect =  @StrSelect + ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink +' INNER JOIN  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 , * from #tblStorageDocsDtl) AS D  ON '+@JoinHdrDtl
	
	if @LinkType=2
		SET @StrSelect =  @StrSelect + ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ',' + ltrim(str(@GoodsLayer2)) + ' ) GoodsLayer1 ,* from #tblStorageDocsDtl)AS D  ON'+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
	
	if @LinkType=3
		SET @StrSelect =  @StrSelect + ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt+ ' Inner join  (Select substring( GoodsID ,' + ltrim(str(@GoodsLayerStart)) + ',' + ltrim(str(@GoodsLayer1)) + ' ) GoodsLayer1 ,* from #tblStorageDocsDtl) AS D  ON'+@JoinHdrDtl 
		
	SET @StrSelect =  @StrSelect +
	' Where  H.ProcessID=100 
	  Group by  '+@GroupBy+',D.SerialNo)a   
	  Group by  '+@FieldName+'     )D
	  where  '+@FilterLink2
                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A10=Sum( GoodsQuantity ) ------------------------------------------------------------------	
	SET @StrSelect = ' 	update #tblSale Set A10= D.GoodsQuantity from(
	select 				Sum( GoodsQuantity ) GoodsQuantity , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	if @LinkType=1
	begin
		SET @StrSelect =  @StrSelect+ ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink
			 +' INNER JOIN #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =@StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end
	
	if @LinkType=2
	begin
		SET @StrSelect =  @StrSelect+  ' Inner join #tblStorageDocsDtl AS D  ON'+@FilterLink 
		if @LinkTable1=1  SET @StrSelect =  @StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =  @StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end
	if @LinkType=3
	begin
		SET @StrSelect =  @StrSelect+  ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink 
		if @LinkTable1=1  
			SET @StrSelect =@StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt
		SET @StrSelect =@StrSelect +' Inner join #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl 
	end
	
	SET @StrSelect =  @StrSelect  +' Where  H.ProcessID=90 
                       Group by  '+@GroupBy+')D where  '+@FilterLink2
                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	SET @StrSelect = ' 	update #tblSale Set B10= D.GoodsQuantity from(
		select Sum( GoodsQuantity ) GoodsQuantity , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	if @LinkType=1
	 begin
		SET @StrSelect =  @StrSelect+ ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink 
			+' INNER JOIN #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =@StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end
	
	if @LinkType=2
	begin
		SET @StrSelect =  @StrSelect+  ' Inner join #tblStorageDocsDtl AS D  ON'+@FilterLink 
		if @LinkTable1=1  SET @StrSelect =  @StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =  @StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end

	if @LinkType=3
	begin
		SET @StrSelect =  @StrSelect+  ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink 
		if @LinkTable1=1  
			SET @StrSelect =@StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt
		SET @StrSelect =@StrSelect +' Inner join #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl 
	end
	
	SET @StrSelect =  @StrSelect  +' Where  H.ProcessID=100 
                       Group by  '+@GroupBy+')D where  '+@FilterLink2
                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A11=Sum( GoodsQuantity2 ) ------------------------------------------------------------------	
	SET @StrSelect = 
	'update #tblSale 
	 Set A11= D.GoodsQuantity2 from(
	 select Sum( GoodsQuantity2 ) GoodsQuantity2 , '+@GroupBy+' '+ @FieldName +' 
	 From #tblSale '

	if @LinkType=1
		SET @StrSelect =  @StrSelect + 
		' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink 
		+' INNER JOIN (select case when not(b.GoodsID IS NULL) then GoodsQuantity*b.UnitValue/MainUnitValue ELSE GoodsQuantity END GoodsQuantity2 ,D.* From #tblStorageDocsDtl D 
			left join (select * from inv.tblSubUnitsDtl where ShowInInvoice=''True'') b on D.GoodsID=b.GoodsID   ) AS D  ON '+@JoinHdrDtl+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 

	if @LinkType=2
		SET @StrSelect =  @StrSelect + 
		' Inner join (select case when not(b.GoodsID IS NULL) then GoodsQuantity*b.UnitValue/MainUnitValue ELSE GoodsQuantity END GoodsQuantity2 ,D.* From #tblStorageDocsDtl D
		  left join (select * from inv.tblSubUnitsDtl where ShowInInvoice=''True'') b on D.GoodsID=b.GoodsID    ) AS D  ON'+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	
	if @LinkType=3
		SET @StrSelect =  @StrSelect + 
		' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt
		+ ' Inner join (select case when not(b.GoodsID IS NULL) then GoodsQuantity*b.UnitValue/MainUnitValue ELSE GoodsQuantity END GoodsQuantity2 ,D.* From #tblStorageDocsDtl D
		left join (select * from inv.tblSubUnitsDtl where ShowInInvoice=''True'') b on D.GoodsID=b.GoodsID     ) AS D  ON '+@JoinHdrDtl 
		
		SET @StrSelect =  @StrSelect +
		' Where  H.ProcessID=90 
		  Group by  '+@GroupBy+')D
		  where  '+@FilterLink2
	                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	SET @StrSelect = 
	' 	update #tblSale 
		Set B11= D.GoodsQuantity2 from(
		select Sum( GoodsQuantity2 ) GoodsQuantity2 , '+@GroupBy+' '+ @FieldName +' 
		From #tblSale '

	if @LinkType=1
		SET @StrSelect =  @StrSelect + 
		' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink 
		+' INNER JOIN (select case when not(b.GoodsID IS NULL) then GoodsQuantity*b.UnitValue/MainUnitValue ELSE GoodsQuantity END GoodsQuantity2 ,D.* From #tblStorageDocsDtl D
		left join (select * from inv.tblSubUnitsDtl where ShowInInvoice=''True'') b on D.GoodsID=b.GoodsID    ) AS D  ON '+@JoinHdrDtl+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 

	if @LinkType=2
		SET @StrSelect =  @StrSelect + 
		' Inner join (select case when not(b.GoodsID IS NULL) then GoodsQuantity*b.UnitValue/MainUnitValue ELSE GoodsQuantity END GoodsQuantity2 ,D.* From #tblStorageDocsDtl D
		left join (select * from inv.tblSubUnitsDtl where ShowInInvoice=''True'') b on D.GoodsID=b.GoodsID    ) AS D  ON'+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 

	if @LinkType=3
		SET @StrSelect =  @StrSelect + 
		' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink +' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt
		+ ' Inner join (select case when not(b.GoodsID IS NULL) then GoodsQuantity*b.UnitValue/MainUnitValue ELSE GoodsQuantity END GoodsQuantity2 ,D.* From #tblStorageDocsDtl D
		left join (select * from inv.tblSubUnitsDtl where ShowInInvoice=''True'') b on D.GoodsID=b.GoodsID    ) AS D  ON '+@JoinHdrDtl 
				
		SET @StrSelect =  @StrSelect +
		' Where  H.ProcessID=100 
		  Group by  '+@GroupBy+' )D
		  where  '+@FilterLink2
                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A12=Count(D.GoodsID )  ------------------------------------------------------------------	
	SET @StrSelect = ' 	update #tblSale Set A12= D.GoodsIDs from(
		select Count(Distinct  D.GoodsID ) GoodsIDs , '+@GroupBy+' '+ @FieldName +' From #tblSale '

	if @LinkType=1
	begin
		SET @StrSelect =  @StrSelect+ ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink 
		+' INNER JOIN #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =@StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end
	
	if @LinkType=2
	begin
		SET @StrSelect =  @StrSelect+  ' Inner join #tblStorageDocsDtl AS D  ON'+@FilterLink 
		if @LinkTable1=1  SET @StrSelect =  @StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =  @StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end

	if @LinkType=3
	begin
		SET @StrSelect =  @StrSelect+  ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink 
		if @LinkTable1=1  
			SET @StrSelect =@StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt
		SET @StrSelect =@StrSelect +' Inner join #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl 
	end
	
	SET @StrSelect =  @StrSelect  +
	' Where  H.ProcessID=90 
      Group by  '+@GroupBy+')D where  '+@FilterLink2
                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	SET @StrSelect = ' 	update #tblSale Set B12= D.GoodsIDs from(
		select Count(Distinct  D.GoodsID ) GoodsIDs , '+@GroupBy+' '+ @FieldName +' From #tblSale '

	if @LinkType=1
	begin
		SET @StrSelect =  @StrSelect+ ' Inner join #tblStorageDocsHdr AS H  ON'+@FilterLink 
		+' INNER JOIN #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =@StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end
	
	if @LinkType=2
	begin
		SET @StrSelect =  @StrSelect+  ' Inner join #tblStorageDocsDtl AS D  ON'+@FilterLink 
		if @LinkTable1=1  SET @StrSelect =  @StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrDtl
		if @LinkTable3=1  SET @StrSelect =  @StrSelect+ ' INNER JOIN acc.tblAcnt AS A ON '+@JoinHdrAcnt 
	end

	if @LinkType=3
	begin
		SET @StrSelect =  @StrSelect+  ' INNER JOIN acc.tblAcnt AS A ON '+@FilterLink 
		if @LinkTable1=1 
			SET @StrSelect =@StrSelect+' INNER JOIN #tblStorageDocsHdr AS H  ON '+@JoinHdrAcnt
		SET @StrSelect =@StrSelect +' Inner join #tblStorageDocsDtl AS D  ON '+@JoinHdrDtl 
	end
	
	SET @StrSelect =  @StrSelect  +' Where  H.ProcessID=100 
                       Group by  '+@GroupBy+')D where  '+@FilterLink2
                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A13=COUNT (AcntCode)------------------------------------------------------------------	
	SET @StrSelect = 
	' 	update #tblSale Set A13= D.AcntCodes from(
	 Select '+ @FieldName +',COUNT(Distinct  AcntCodes) AcntCodes from ( 
	 select Distinct H.AcntCode AcntCodes , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
	SET @StrSelect =  @StrSelect +@StrSelect1 +
		' Where  H.ProcessID=90 
	     Group by  '+@GroupBy+'     ,H.AcntCode  )a   Group by  '+@FieldName+'       
		 )D where  '+@FilterLink2
	                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	SET @StrSelect = ' 	update #tblSale Set B13= D.AcntCodes from(
	Select '+ @FieldName +',COUNT(Distinct AcntCodes) AcntCodes from ( 
	select Distinct H.AcntCode AcntCodes , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
	SET @StrSelect =  @StrSelect +@StrSelect1 +
	' Where  H.ProcessID=100 
	  Group by  '+@GroupBy+' ,H.AcntCode  )a   Group by  '+@FieldName+'       
	  )D where  '+@FilterLink2
	                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A14=COUNT (VisitorAcntCode)------------------------------------------------------------------	
	SET @StrSelect = ' 	update #tblSale Set A14= D.VisitorAcntCodes from(
	Select '+ @FieldName +',COUNT(Distinct VisitorAcntCodes) VisitorAcntCodes from ( 
	select 		Distinct H.VisitorAcntCode VisitorAcntCodes , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
	SET @StrSelect =  @StrSelect +@StrSelect1 +
	' Where  H.ProcessID=90 
	 Group by  '+@GroupBy+'     ,H.VisitorAcntCode  )a   Group by  '+@FieldName+' )D where  '+@FilterLink2
	                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	SET @StrSelect = 
	' 	update #tblSale Set B14= D.VisitorAcntCodes from(
	Select '+ @FieldName +',COUNT(Distinct VisitorAcntCodes) VisitorAcntCodes from ( 
	select 		Distinct H.VisitorAcntCode VisitorAcntCodes , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
	SET @StrSelect =  @StrSelect +@StrSelect1 +
	' Where  H.ProcessID=100 
	  Group by  '+@GroupBy+'     ,H.VisitorAcntCode  )a   Group by  '+@FieldName+' )D where  '+@FilterLink2
	                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A15=COUNT (VisitorAcntCode)------------------------------------------------------------------	
	SET @StrSelect = 
	' 	update #tblSale Set A15= D.DistributerIDs from(
	Select '+ @FieldName +',COUNT(Distinct DistributerIDs) DistributerIDs from ( 
	select 		Distinct H.DistributerID1 DistributerIDs , '+@GroupBy+' '+ @FieldName +' From #tblSale '
	
	SET @StrSelect =  @StrSelect +@StrSelect1 +
	' Where  H.ProcessID=90 
	  Group by  '+@GroupBy+'     ,H.DistributerID1  
	  union 
	  select Distinct H.DistributerID2 , '+@GroupBy+' '+ @FieldName +' From #tblSale '

	SET @StrSelect =  @StrSelect +@StrSelect1 +
	' Where  H.ProcessID=90 
	  Group by  '+@GroupBy+'     ,H.DistributerID2  )a   Group by  '+@FieldName+' )D where  '+@FilterLink2
	                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	SET @StrSelect = 
	' 	update #tblSale Set B15= D.DistributerIDs from(
	Select '+ @FieldName +',COUNT(Distinct DistributerIDs) DistributerIDs from ( 
	select 		Distinct H.DistributerID1 DistributerIDs , '+@GroupBy+' '+ @FieldName +' From #tblSale '
		
	SET @StrSelect =  @StrSelect +@StrSelect1 +
	' Where  H.ProcessID=100 
	 Group by  '+@GroupBy+' ,H.DistributerID1  
	 union 
	 select Distinct H.DistributerID2 , '+@GroupBy+' '+ @FieldName +
	 'From #tblSale '
	
	SET @StrSelect =  @StrSelect +@StrSelect1 +
	' Where  H.ProcessID=100 
	  Group by  '+@GroupBy+'     ,H.DistributerID2  )a   Group by  '+@FieldName+' )D where  '+@FilterLink2
	                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	----------- Set   A16=COUNT (VisitorAcntCode)------------------------------------------------------------------	
	SET @StrSelect = 
	'update #tblSale Set A16= D.DriverIDs from(
	Select '+ @FieldName +',COUNT(Distinct DriverIDs) DriverIDs from ( 
	select Distinct H.DriverID DriverIDs, '+@GroupBy+' '+ @FieldName +' From #tblSale '
		
	SET @StrSelect =  @StrSelect +@StrSelect1 +
	' Where  H.ProcessID=90 
	  Group by  '+@GroupBy+'     ,H.DriverID  )a   Group by  '+@FieldName+' )D where  '+@FilterLink2
	                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	SET @StrSelect = 
	' update #tblSale Set B16= D.DriverIDs from(
	 Select '+ @FieldName +',COUNT(Distinct DriverIDs) DriverIDs from ( 
	 select Distinct H.DriverID DriverIDs, '+@GroupBy+' '+ @FieldName +' From #tblSale '

	SET @StrSelect =  @StrSelect +@StrSelect1 +
	' Where  H.ProcessID=100 
	 Group by  '+@GroupBy+',H.DriverID  )a Group by '+@FieldName+' )D where '+@FilterLink2
	                      
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	-----------------------------------------------------------------------------	
	if @FilterType=18
		begin
		update #tblSale
			set GroupName= pub.funSplitString(GroupID, '@', 2)
			  , GroupID= pub.funSplitString(GroupID, '@', 1)

		update #tblSale
		set GroupName= ProcessName
		from #tblSale a inner join    pub.tblProcess b
		on a.GroupName=ProcessNo and b.ProcessID=90	
	end

	if  charindex ( ' GroupID ',@Orders )>0 and  (select count(*) from #tblSale where ISNUMERIC(GroupID)=0)=0
		set @Orders=replace (@Orders,' GroupID ' , ' cast(GroupID as Float) ')


	--==============================================================
	update #tblSale Set 
		GroupID=isnull(GroupID,'') 
		,GroupName=isnull(GroupName,'') 
		,Sale=isnull(Sale,'') 
		,Ret=isnull(Ret,'') 
		,LastSale=isnull(LastSale,'') 
		,LastRet=isnull(LastRet,'') 
		,A1=isnull(A1,'') 
		,A2=isnull(A2,'') 
		,A3=isnull(A3,'') 
		,A4=isnull(A4,'') 
		,A5=isnull(A5,'') 
		,A6=isnull(A6,'') 
		,A7=isnull(A7,'') 
		,A8=isnull(A8,'') 
		,A9=isnull(A9,'') 
		,A10=isnull(A10,'') 
		,A11=isnull(A11,'') 
		,A12=isnull(A12,'') 
		,A13=isnull(A13,'') 
		,A14=isnull(A14,'') 
		,A15=isnull(A15,'') 
		,A16=isnull(A16,'') 
		,A17=isnull(A17,'') 
		,A18=isnull(A18,'') 
		,A19=isnull(A19,'') 
		,A20=isnull(A20,'') 
		,B1=isnull(B1,'') 
		,B2=isnull(B2,'') 
		,B3=isnull(B3,'') 
		,B4=isnull(B4,'') 
		,B5=isnull(B5,'') 
		,B6=isnull(B6,'') 
		,B7=isnull(B7,'') 
		,B8=isnull(B8,'') 
		,B9=isnull(B9,'') 
		,B10=isnull(B10,'') 
		,B11=isnull(B11,'') 
		,B12=isnull(B12,'') 
		,B13=isnull(B13,'') 
		,B14=isnull(B14,'') 
		,B15=isnull(B15,'') 
		,B16=isnull(B16,'') 
		,B17=isnull(B17,'') 
		,B18=isnull(B18,'') 
		,B19=isnull(B19,'') 
		,B20=isnull(B20,'') 
		,AA1=isnull(AA1,'') 
		,AA2=isnull(AA2,'') 
		,AA3=isnull(AA3,'') 
		,AA4=isnull(AA4,'') 
		,AA5=isnull(AA5,'') 
		,AA6=isnull(AA6,'') 
		,AA7=isnull(AA7,'') 
		,AA8=isnull(AA8,'') 
		,AA9=isnull(AA9,'') 
		,AA10=isnull(AA10,'') 
		,AA11=isnull(AA11,'') 
		,AA12=isnull(AA12,'') 
		,AA13=isnull(AA13,'') 
		,AA14=isnull(AA14,'') 
		,AA15=isnull(AA15,'') 
		,AA16=isnull(AA16,'') 
		,AA17=isnull(AA17,'') 
		,AA18=isnull(AA18,'') 
		,AA19=isnull(AA19,'') 
		,AA20=isnull(AA20,'') 
		
	-- ==============================================
	SET @StrSelect = ' Select * From #tblSale ' + @Orders
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
