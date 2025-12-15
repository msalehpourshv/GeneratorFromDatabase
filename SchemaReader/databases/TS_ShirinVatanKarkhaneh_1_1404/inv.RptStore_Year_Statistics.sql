USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--use "TS_AzarBatri_1_1403"
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/04/02
-- Viewed By	 : 
-- Last Modified : 1392/11/27
-- Last Modifier : TakroSystem\Zia
-- Description	 : نمودار اسناد انبار به تفکیک تاریخ
-- ==============================================
--[inv].[RptStore_Year_Statistics] 90
Create PROCEDURE [inv].[RptStore_Year_Statistics]
	@ProcessID			Int=0,  -- Required --
	@ProcessNo			Int = 0,
	@SelectedGoods		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedAcnt1		Int = 0,
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@DateFr				char(10) = null, 
	@DateTo				char(10) = null, 
	@UseAmount			Bit = 1, -- Use Amount Instead of Price
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null#null#null',
	@RepInfo			NVarChar(100) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(MAX);
Declare @StrSelect2	NVarChar(MAX);
Declare @StrSelect3	NVarChar(MAX);
Declare @StrFrom	NVarChar(2000);
Declare @StrWhere	NVarChar(4000);
Declare @StrWhereH	NVarChar(4000);
Declare @StrWhereHH	NVarChar(4000);
Declare @StrWhereD	NVarChar(2000);
DECLARE @StrPID		VarChar(20);

DECLARE @Dist0		NVarChar(20); -- DriverID
DECLARE @Dist1		NVarChar(20); -- DistributerID1
DECLARE @Dist2		NVarChar(20); -- DistributerID2
DECLARE @Dist3		NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4		NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5		NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6		NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7		NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8		NVarChar(20); -- BaseDistributionSerialNo   to
DECLARE @Dist9		NVarChar(20); -- WithoutDistributer
DECLARE @Dist10		NVarChar(20); -- WithDistributer

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

Declare @Code1		TinyInt;
Declare @Code2		TinyInt;
Declare @Code3		TinyInt;
Declare @Code4		TinyInt;
Declare @Code5		TinyInt;

Declare @RetCode1	TinyInt;
Declare @RetCode2	TinyInt;
Declare @RetCode3	TinyInt;
Declare @RetCode4	TinyInt;
Declare @RetCode5	TinyInt;

DECLARE @StartLayerAcntRemain	int;
DECLARE @LenLayerAcntRemain		int;

Declare @ProcessID_Ret Int;
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
	Select @StartLayerAcntRemain=acc.FunGetAcntInfoForRemain(2 )
	Select @LenLayerAcntRemain=acc.FunGetAcntInfoForRemain(3 )

	-- Init Variables & Default Values --------------------
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;
	IF (@UseAmount Is Null)			SET @UseAmount = 1;

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0;
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0;
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0;
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0;
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null#null';

declare @Quantity as bit
declare @CampaignID as int
DECLARE @PID1				bit;
DECLARE @PID2				bit;
DECLARE @PID3				bit;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @Quantity     =  pub.funSplitString(@RepInfo, '@', 6);
	set @CampaignID =  pub.funSplitString(@RepInfo, '@', 7);
	set @PID1 =  pub.funSplitString(@RepInfo, '@', 8);
	set @PID2 =  pub.funSplitString(@RepInfo, '@', 9);
	set @PID3 =  pub.funSplitString(@RepInfo, '@', 10);
		
 
	IF (@DistributeInfo <> '')
	Begin
		SET @Dist0	= pub.funSplitString(@DistributeInfo, '#', 1);
		SET @Dist1	= pub.funSplitString(@DistributeInfo, '#', 3);
		SET @Dist2	= pub.funSplitString(@DistributeInfo, '#', 5);
		SET @Dist3	= pub.funSplitString(@DistributeInfo, '#', 7);
		SET @Dist4	= pub.funSplitString(@DistributeInfo, '#', 8);
		SET @Dist5	= pub.funSplitString(@DistributeInfo, '#', 9);
		SET @Dist6	= pub.funSplitString(@DistributeInfo, '#', 10);
		SET @Dist7	= pub.funSplitString(@DistributeInfo, '#', 11);
		SET @Dist8	= pub.funSplitString(@DistributeInfo, '#', 12);
		SET @Dist9	= pub.funSplitString(@DistributeInfo, '#', 13);
		SET @Dist10	= pub.funSplitString(@DistributeInfo, '#', 14);		
	End
	Else
	Begin
		SET @Dist0	= 'null';
		SET @Dist1	= 'null';
		SET @Dist2	= 'null';
		SET @Dist3	= 'null'; 
		SET @Dist4	= 'null';
		SET @Dist5	= 'null';
		SET @Dist6	= 'null';
		SET @Dist7	= 'null';
		SET @Dist8	= 'null';
		SET @Dist9	= 'null';
		SET @Dist10	= 'null';		
	End
	-- ----------------------------------------------------

	Set @Code1 = 55;  -- Buy
	Set @Code2 = 70;  -- Produce Send
	Set @Code3 = 80;  -- Produce Receive
	Set @Code4 = 90;  -- Sale
	Set @Code5 = 110; -- Use

	Set @RetCode1 = 60;  -- Buy Return
	Set @RetCode2 = 75;  -- Produce Send Return
	Set @RetCode3 = 85;  -- Produce Receive Return
	Set @RetCode4 = 100; -- Sale Return
	Set @RetCode5 = 115; -- Use Return

	Set @ProcessID_Ret =
		Case @ProcessID 
			When @Code1 Then @RetCode1
			When @Code2 Then @RetCode2
			When @Code3 Then @RetCode3
			When @Code4 Then @RetCode4
			When @Code5 Then @RetCode5
			Else 0
		End
	
	SET @StrPID = @ProcessID
	------------------------------------------------------------
	IF (@ProcessID = 70) or (@ProcessID = 80)
	BEGIN	
		IF (@PID1=0 and @PID2=0 and @PID3=0)
			SET @PID1 = 1
			
		SET @StrPID = '0';

		IF (@PID1 = 1)
			SET @StrPID = @StrPID + ',' + ltrim(str(@ProcessID));

		IF (@PID2 = 1)
			IF (@ProcessID = 70) 
				SET @StrPID = @StrPID + ',82' 
			ELSE
				SET @StrPID = @StrPID + ',72' 
			
		IF (@PID3 = 1)
			IF (@ProcessID = 70) 
				SET @StrPID = @StrPID + ',83' 
			ELSE
				SET @StrPID = @StrPID + ',73' 
	END
	--ELSE 
	--	IF @bolSaleAndRet = 1
	--		SET @StrPID = '90, 100'
	--	Else
	--		SET @StrPID = LTRIM(STR(@ProcessID))
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	declare @strRetText as NVarchar = ''
	SET @strRetText = ',' 

	DECLARE	@QuantityDecimals	CHAR(1);
	set	@QuantityDecimals = '2';
	select	@QuantityDecimals = SettingValue from pub.tblSettings where	SettingKey = 'QuantityDecimals'

	DECLARE	@PriceDecimals	CHAR(1);
	set	@PriceDecimals = '2';
	select	@PriceDecimals = SettingValue from pub.tblSettings where	SettingKey = 'PriceDecimals'
	-- 1-common --
			Set @StrWhere   = ' 1 = 1 '
			SET @StrWhereH  = ' 1 = 1 '
			SET @StrWhereD  = ' EnterKind <> 0 '
			SET @StrWhereHH = ''
	if @ProcessNo<>0
		begin
			Set @StrWhere = '  ProcessNo = ' + LTrim(Str(@ProcessNo))
			SET @StrWhereH = '  H.ProcessNo = ' + LTrim(Str(@ProcessNo))
			SET @StrWhereD = '  EnterKind <> 0 AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))+' AND D.ProcessID IN (' + LTrim(@StrPID) + @strRetText + LTrim(Str(@ProcessID_Ret)) + ') '
		end 
	IF (@SelectedStore > 0)
	begin
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 
	end
	-- 2-hdr --
	If (@Dist0 <> 'null')
		SET @StrWhereH = @StrWhereH + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
	If (@Dist1 <> 'null')
		SET @StrWhereH = @StrWhereH + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
	If (@Dist2 <> 'null')
		SET @StrWhereH = @StrWhereH + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''

	If (@Dist5 <> 'null')
	Begin
		SET @StrWhereH = @StrWhereH + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
		SET @StrWhereHH = @StrWhereHH + ' AND HH.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND HH.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND HH.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND HH.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	End
	
	If (@Dist7 <> 'null')
	Begin
		SET @StrWhereH = @StrWhereH + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(@Dist8)
		SET @StrWhereHH = @StrWhereHH + ' AND HH.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND HH.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND HH.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND HH.BaseDistributionSerialNo <= ' + LTrim(@Dist8)
	End
	
	IF ((@Dist9 <> 'null') And (@Dist9 <> '0') And (@Dist10 <> '')) And ((@Dist10 = 'null') Or (@Dist10 = '0') Or (@Dist9 = ''))
	Begin
		SET @StrWhere = @StrWhere + ' AND (H.DistributerID1 = '''' AND H.DistributerID2 = '''')'
		SET @StrWhereHH = @StrWhereHH + ' AND (HH.DistributerID1 = '''' AND HH.DistributerID2 = '''')'
	End
	IF ((@Dist10 <> 'null') And (@Dist10 <> '0') And (@Dist10 <> '')) And ((@Dist9 = 'null') Or (@Dist9 = '0') Or (@Dist9 = ''))
	Begin
		SET @StrWhere = @StrWhere + ' AND (H.DistributerID1 <> '''' OR H.DistributerID2 <> '''')'		
		SET @StrWhereHH = @StrWhereHH + ' AND (HH.DistributerID1 <> '''' OR HH.DistributerID2 <> '''')'		
	End
			
	SET @StrWhereD = @StrWhereD + @StrWhereHH
	
	IF (@SelectedAcnt1 > 0)
	Begin
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
		SET @StrWhereHH = @StrWhereHH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'HH.AcntCode')
	End
	IF (@SelectedAcnt2 > 0)
	Begin
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
		SET @StrWhereHH = @StrWhereHH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'HH.AcntCode')
	End
	IF (@SelectedAcnt3 > 0)
	Begin
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
		SET @StrWhereHH = @StrWhereHH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'HH.AcntCode')
	End
	IF (@SelectedAcnt4 > 0)
	Begin
		SET @StrWhereH = @StrWhereH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')
		SET @StrWhereHH = @StrWhereHH + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'HH.AcntCode')
	End

	If (@SelectedVisitor1 > 0)
	Begin
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
		SET @StrWhereHH = @StrWhereHH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'HH.VisitorAcntCode') + ')'
	End
	If (@SelectedVisitor2 > 0)
	Begin
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
		SET @StrWhereHH = @StrWhereHH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'HH.VisitorAcntCode') + ')'
	End
	If (@SelectedVisitor3 > 0)
	Begin
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
		SET @StrWhereHH = @StrWhereHH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'HH.VisitorAcntCode') + ')'
	End
	If (@SelectedVisitor4 > 0)
	Begin
		SET @StrWhereH = @StrWhereH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'
		SET @StrWhereHH = @StrWhereHH + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'HH.VisitorAcntCode') + ')'
	End

	IF (@CampaignID > 0)
	Begin
		SET @StrWhereD = @StrWhereD + ' AND  substring(HH.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') in (select AcntCode  from acc.tblAcnt A where '+ pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'A.CampaignID') +' ) '
	End

	 --3-dtl --
	IF (@SelectedGoods > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID')

	IF (@DateFr is not null)
	begin
		set @StrWhereD = @StrWhereD + ' AND (HH.DocDate >= ''' + @DateFr + ''')';
		if @Quantity = 0
		begin
			set @StrWhereH = @StrWhereH + ' AND (H.DocDate >= ''' + @DateFr + ''')';
			set @StrWhereHH = @StrWhereHH + ' AND (HH.DocDate >= ''' + @DateFr + ''')';
		end
		else
		begin 
			set @StrWhereH = @StrWhereH + ' AND (H.DocDate >= ''' + @DateFr + ''')';
			set @StrWhereHH = @StrWhereHH + ' AND (HH.DocDate >= ''' + @DateFr + ''')';
		end
	end;

	IF (@DateTo is not null)
	begin
		set @StrWhereD = @StrWhereD + ' AND (HH.DocDate <= ''' + @DateTo + ''')';
		if @Quantity = 0
		begin
			set @StrWhereH = @StrWhereH + ' AND (H.DocDate <= ''' + @DateTo + ''')';
			set @StrWhereHH = @StrWhereHH + ' AND (HH.DocDate <= ''' + @DateTo + ''')';
		end 
		else
		begin
			set @StrWhereH = @StrWhereH + ' AND (H.DocDate <= ''' + @DateTo + ''')';
			set @StrWhereHH = @StrWhereHH + ' AND (HH.DocDate <= ''' + @DateTo + ''')';
		end
	end;
	
	IF (@SelectedAcnt1 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	If (@SelectedVisitor1 > 0)
		SET @StrWhereD = @StrWhereD + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhereD = @StrWhereD + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhereD = @StrWhereD + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhereD = @StrWhereD + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode') + ')'

	--------------------------------------------------------------------
	-- Select Clause ---------------------------------------------------
	DECLARE @StrPrice AS NVarChar(20);
	DECLARE @GoodsAmount AS NVarChar(30);
	DECLARE @HdrSection VarChar(Max); 

	set @GoodsAmount = LTRIM(inv.funGoodsAmount(@DateTo))

	If (@UseAmount = 1)
		Set @StrPrice = 'D.GoodsAmount'
	Else
		Set @StrPrice = 'D.GoodsPrice'

	IF (@DateFr is not null) or (@DateTo is not null) 
		Set @StrSelect = ''
	else
		Set @StrSelect = '
	WHILE (@idx1 <= 12)
	BEGIN
		SET @idx2 = 1
		DECLARE @Count INT 
		SET @Count = 31
		IF @idx1 >6
			SET @Count = 30
	
		WHILE @idx2 <= @Count
		BEGIN
			INSERT INTO #tblDays	
			VALUES (CASE WHEN Len(LTrim(Str(@idx1))) < 2 THEN ''0'' ELSE '''' END + LTrim(Str(@idx1)) + ''/'' + CASE WHEN Len(LTrim(Str(@idx2))) < 2 THEN ''0'' ELSE '''' END + LTrim(Str(@idx2)))
			SET @idx2 = @idx2 + 1
		END

		SET @idx1 = @idx1 + 1
	END;'

	if (@SelectedGoods = 0)	
		set @HdrSection = '
		UNION ALL
		SELECT	RIGHT(H.DocDate, 5) DocDate, 0, 0, 0, 0, 0, 0,0,0,0,0,
				Sum(CASE WHEN H.ProcessID = ' + LTrim(Str(@ProcessID))     + ' THEN Discount + Discount2 + Discount3 ELSE 0 END) AS MainDiscount,
				Sum(CASE WHEN H.ProcessID = ' + LTrim(Str(@ProcessID_Ret)) + ' THEN Discount + Discount2 + Discount3 ELSE 0 END) AS RetDiscount		
				,0,0, 0, 0, 0,0,Sum(TransportationCost) TransportationCost	,Sum(TransportationIncome) TransportationIncome
		FROM	inv.tblStorageDocsHdr H
		WHERE	' + @StrWhereH + '
		GROUP BY RIGHT(H.DocDate, 5)
		'
	else
		set @HdrSection = ''
	
	Set @StrSelect = '
	Declare @idx1 Int
	Declare @idx2 Int
	CREATE TABLE #tblDays (Days Char(10) COLLATE Arabic_CS_AS)
	-- Fill Table Variale With Year Days --
	SET @idx1 = 1 
	' + @StrSelect + '
	SELECT	T.DocDate,  
			Round(SUM(T.Price), ' + @PriceDecimals + ') AS Price, 
			Round(SUM(T.Amount), ' + @PriceDecimals + ') AS Amount, 
			Round(SUM(T.RewardAmount), ' + @PriceDecimals + ') AS RewardAmount, 
			Round(SUM(T.ReturnPrice), ' + @PriceDecimals + ') AS ReturnPrice,
			Round(SUM(T.ReturnAmount), ' + @PriceDecimals + ') AS ReturnAmount,
			Round(SUM(T.ReturnRewardAmount), ' + @PriceDecimals + ') AS ReturnRewardAmount,
			Round(SUM(T.Quantity), ' + @QuantityDecimals + ') AS Quantity, 
			Round(SUM(T.ReturnQuantity), ' + @QuantityDecimals + ') AS ReturnQuantity,
			Round(SUM(T.MainDiscount), ' + @PriceDecimals + ') AS MainDiscount,
			Round(SUM(T.RetDiscount), ' + @PriceDecimals + ') AS RetDiscount,
			ISNULL( SUM(T.CCDiscountSale), 0) as CCDiscountSale,
			ISNULL( SUM(T.CCDiscountRet), 0) as CCDiscountRet,
			ISNULL( SUM(T.AfterSaleDiscount/ Case when isnull(T.CountRow,0)<=0 then 1 else  T.CountRow end ), 0) as AfterSaleDiscount,
			ISNULL( SUM(T.AfterPrice1), 0) as OtherDstDiscounts,
			ISNULL( SUM(T.AfterPrice2), 0) as OtherDstIncoms ,
			ISNULL( SUM(T.TransportationCost), 0) as TransportationCost ,
			ISNULL( SUM(T.TransportationIncome), 0) as TransportationIncome '			
	Set @StrSelect2 = '
	FROM
	(
		SELECT	RIGHT(D.DocDate, 5) DocDate, 
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(@StrPID)     + ') THEN (D.GoodsQuantity) ELSE 0 END ,0) AS Quantity, 
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(@StrPID)    + ') THEN (D.GoodsQuantity * ' + @StrPrice + ') ELSE 0 END ,0) AS Price, 
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(@StrPID)     + ')  AND  IsReward=''True'' THEN (D.GoodsQuantity * ' + @StrPrice + ') ELSE 0 END ,0) AS RewardPrice, 
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(@StrPID)     + ') THEN (D.GoodsQuantity *  D.' + @GoodsAmount + ' ) ELSE 0 END ,0) AS Amount, 
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(@StrPID)     + ') AND  IsReward=''True'' THEN (D.GoodsQuantity *  D.' + @GoodsAmount + ' ) ELSE 0 END ,0) AS RewardAmount, 
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(Str(@ProcessID_Ret)) + ') THEN (D.GoodsQuantity) ELSE 0 END ,0) AS ReturnQuantity,
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(Str(@ProcessID_Ret)) + ') THEN (D.GoodsQuantity * ' + @StrPrice + ') ELSE 0 END ,0) AS ReturnPrice,
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(Str(@ProcessID_Ret)) + ') AND  IsReward=''True'' THEN (D.GoodsQuantity * ' + @StrPrice + ') ELSE 0 END ,0) AS ReturnRewardPrice,
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(Str(@ProcessID_Ret)) + ') THEN (D.GoodsQuantity * D.' + @GoodsAmount + ') ELSE 0 END ,0) AS ReturnAmount,
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(Str(@ProcessID_Ret)) + ') AND  IsReward=''True'' THEN (D.GoodsQuantity * D.' + @GoodsAmount + ') ELSE 0 END ,0) AS ReturnRewardAmount,
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(@StrPID)     + ') THEN (D.DiscountDtl) ELSE 0 END ,0) AS MainDiscount, 
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(Str(@ProcessID_Ret)) + ') THEN (D.DiscountDtl) ELSE 0 END ,0) AS RetDiscount,
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(@StrPID)     + ') THEN (B1.Price) ELSE 0 END ,0) AS AfterPrice1, 
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(@StrPID)     + ') THEN (B2.Price) ELSE 0 END ,0) AS AfterPrice2, 
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(@StrPID)     + ') THEN (CCDiscount) ELSE 0 END ,0) AS  CCDiscountSale, 
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(Str(@ProcessID_Ret)) + ') THEN (CCDiscount) ELSE 0 END ,0) AS CCDiscountRet, 
				ISNULL(CASE WHEN D.ProcessID in (' + LTrim(@StrPID)     + ') THEN (case when AfterSaleDiscount<=0 then 0 else	AfterSaleDiscount end)  ELSE 0 END ,0) AS AfterSaleDiscount, 
				(select count(*) from 	inv.tblStorageDocsDtl DD WHERE	' + @StrWhereD + '  and D.ProcessID = DD.ProcessID And D.ProcessNo = DD.ProcessNo And D.FiscalYear = DD.FiscalYear And D.SerialNo = DD.SerialNo) as CountRow,
				0 TransportationCost,
				0 TransportationIncome '
	Set @StrSelect3 = '
		FROM	inv.tblStorageDocsDtl D 
		INNER JOIN inv.tblStorageDocsHdr HH ON D.ProcessID = HH.ProcessID And D.ProcessNo = HH.ProcessNo And D.FiscalYear = HH.FiscalYear And D.SerialNo = HH.SerialNo
		left join sal.tblAfterSaleBillDtl  B1 on D.ProcessID = 212 and HH.ProcessID = B1.BaseProcessID And HH.ProcessNo = B1.BaseProcessNo And HH.FiscalYear = B1.BaseFiscalYear And HH.SerialNo = B1.BaseSerialNo
		left join sal.tblAfterSaleBillDtl  B2 on D.ProcessID = 212 and HH.ProcessID = B2.BaseProcessID And HH.ProcessNo = B2.BaseProcessNo And HH.FiscalYear = B2.BaseFiscalYear And HH.SerialNo = B2.BaseSerialNo
   		WHERE	' + @StrWhereD + @HdrSection +  '
		UNION	ALL
		SELECT	Days, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0,0,0,0,0,0
		FROM #tblDays
	) T
	GROUP BY T.DocDate
	ORDER BY T.DocDate'

	------------------------------------------------------------
	-- Run -----------------------------------------------------
	PRINT @StrSelect;
	PRINT @StrSelect2;
	PRINT @StrSelect3
	
	SET @StrSelect = @StrSelect + @StrSelect2 + @StrSelect3;
	EXEC sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
