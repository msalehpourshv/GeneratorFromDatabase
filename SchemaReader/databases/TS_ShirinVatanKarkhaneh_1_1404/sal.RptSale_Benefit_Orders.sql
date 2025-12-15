USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1387/07/04
-- Viewed By	 : 
-- Last Modified : 1392/01/24
-- Last Modifier : TakroSystem\Zia
-- Description	 : گزارش سود و زیان ناویژه فروش به تفکیک فاکتورهای فروش
-- ==============================================
Create PROCEDURE [sal].[RptSale_Benefit_Orders]
	@ProcessID			Int = 90,
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@SelectedStore		Int = Null,
	@SelectedAcnt1		Int = Null, -- انتخاب طرف حساب
	@SelectedAcnt2		Int = Null,
	@SelectedAcnt3		Int = Null,
	@SelectedAcnt4		Int = Null,
	@SelectedOrders1	Int = Null, -- انتخاب طرف حساب
	@SelectedOrders2	Int = Null,
	@SelectedOrders3	Int = Null,
	@SelectedOrders4	Int = Null,
	@SelectedVisitor1	Int = Null, -- انتخاب بازاریاب
	@SelectedVisitor2	Int = Null, 
	@SelectedVisitor3	Int = Null, 
	@SelectedVisitor4	Int = Null, 
	@DocStep			Int = 0,  -- مرحله
	@SaleTypeID			VarChar(20) = Null, -- کد نوع فروش
	@DecReturn			Bit = 1,
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(max);
Declare @StrFrom	NVarChar(max);
Declare @StrWhere	NVarChar(max);

Declare @StrRetQty		NVarChar(max);
Declare @StrRetDiscountHdr	NVarChar(max);
Declare @StrRetDiscountDtl	NVarChar(max);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;

DECLARE @Dist0		NVarChar(20); -- DriverID
DECLARE @Dist1		NVarChar(20); -- DistributerID1
DECLARE @Dist2		NVarChar(20); -- DistributerID2
DECLARE @Dist3		NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4		NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5		NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6		NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7		NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8		NVarChar(20); -- BaseDistributionSerialNo   to
Begin --============== S T A R T  C O D E =====================================================

	SET NOCOUNT ON;
	
	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);

	--==============
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
	
	-- Init -----------------------------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	If (@ProcessID Is Null)		SET @ProcessID = 90; -- sale 
	If (@ProcessNo Is Null)		SET @ProcessNo = 1;
	IF (@DocStep	Is Null)	SET @DocStep = 0
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null#null#null#null#null#null#null';

	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0
	IF (@SelectedOrders1  Is Null)	SET @SelectedOrders1 = 0
	IF (@SelectedOrders2  Is Null)	SET @SelectedOrders2 = 0
	IF (@SelectedOrders3  Is Null)	SET @SelectedOrders3 = 0
	IF (@SelectedOrders4  Is Null)	SET @SelectedOrders4 = 0
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

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
	End

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-------------------------------------------------------------------------------------------
	-- Where Clause ---------------------------------------------------------------------------
	SET @StrWhere = ' D.ProcessID = ' + LTrim(Str(@ProcessID))

	If (@Dist0 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
	If (@Dist1 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
	If (@Dist2 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''

	If (@Dist5 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	If (@Dist7 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(@Dist8)

	If (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate  = ''' + @DocDateFr + ''')'
		Else 
		BEGIN
			IF (@DocDateFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		END

	IF (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	If (@SelectedOrders1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders1, 'D.OrderAcntCode') 
	If (@SelectedOrders2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders2, 'D.OrderAcntCode') 
	If (@SelectedOrders3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders3, 'D.OrderAcntCode') 
	If (@SelectedOrders4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrders4, 'D.OrderAcntCode')

	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'

	If (@SaleTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @SaleTypeID + ''')'

	IF (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep = ' + LTrim(Str(@DocStep)) + ')'

	DECLARE @GoodsAmount AS NVarChar(30);

	set @GoodsAmount = LTRIM(inv.funGoodsAmount(@DocDateTo))
	----------------------------------------------------------------------------------------------------
	-- SELECT Clause -----------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	IF (@DecReturn = 1)
		SET @StrRetQty = '
				isnull((
					SELECT	SUM(GoodsQuantity)
					FROM	inv.tblStorageDocsDtl 
					WHERE	ProcessID = 100 AND 
							ProcessNo = ' + Str(@ProcessNo) + ' AND 
							BaseProcessID = D.ProcessID AND 
							BaseProcessNo = D.ProcessNo AND 
							BaseFiscalYear = D.FiscalYear AND 
							BaseSerialNo = D.SerialNo AND 
							BaseDocRowNo = D.DocRowNo
				),0)'
	ELSE
		SET @StrRetQty = '0'
		
	IF (@DecReturn = 1)
	begin
		SET @StrRetDiscountHdr = '
				IsNull((
					SELECT	SUM(a.Discount)
					FROM	inv.tblStorageDocsHdr  a
					WHERE	a.ProcessID = 100 AND 
							a.ProcessNo = D.ProcessNo  AND 
							a.BaseProcessID = D.ProcessID AND 
							a.BaseProcessNo = D.ProcessNo AND 
							a.BaseFiscalYear = D.FiscalYear AND 
							a.BaseSerialNo = D.SerialNo 
							
				),0)'
		SET @StrRetDiscountDtl = '
				IsNull((
					SELECT	sum(DiscountDtl)
					FROM	inv.tblStorageDocsDtl 
					WHERE	ProcessID = 100 AND 
							ProcessNo = ' + Str(@ProcessNo) + ' AND 
							BaseProcessID = D.ProcessID AND 
							BaseProcessNo = D.ProcessNo AND 
							BaseFiscalYear = D.FiscalYear AND 
							BaseSerialNo = D.SerialNo AND 
							BaseDocRowNo = D.DocRowNo
				),0)'
		end 
	ELSE
	begin
		SET @StrRetDiscountHdr = '0'		
		SET @StrRetDiscountDtl = '0'		
	end 

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

		CREATE TABLE #tblStoreID
		(
		StoreID 			Varchar(20)collate arabic_cs_as null
		)
	
		Insert into  #tblStoreID (StoreID)	SELECT Distinct StoreID	FROM inv.tblStorageDocsDtl
	 
		exec pub.SpFilterByPermission2 '#tblStoreID', 'StoreID', 'inv.tblStores', @UserID;

		SET @StrWhere +=  ' and D.StoreID in (SELECT StoreID FROM  #tblStoreID ) '

	END		

	SET @StrSelect = '
		SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocDate, 
				D.StoreID, D.GoodsID, D.AcntCode, D.GoodsQuantity, D.DiscountDtl,
				D.' + @GoodsAmount + ' GoodsAmount, D.GoodsPrice, ' + @StrRetQty + ' GoodsQuantityRet,
				' + @StrRetDiscountHdr + ' DiscountHdrRet,
				' + @StrRetDiscountDtl + ' DiscountDtlRet,
				S.StoreName, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, H.Discount+H.Discount2 +H.Discount3 DiscountHdr,
				pub.GetCodeName(H.AcntCode, ' + @LangID + ') AcntName
		FROM	inv.tblStorageDocsDtl D 
		INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		LEFT JOIN inv.tblStoresDtl S ON S.StoreID = H.StoreID
		LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		WHERE ' + @StrWhere + '
		ORDER BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo'
	------------------------------------------------------------
	-- SORT Clause ---------------------------------------------
	------------------------------------------------------------
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
