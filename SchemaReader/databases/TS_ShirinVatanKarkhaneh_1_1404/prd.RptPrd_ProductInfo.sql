USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1393/05/14
-- Viewed By	 : 
-- Last Modifier : TakroSystem\Hamid
-- Last Modified : 1393/10/04
-- Description   : 
-- ==============================================
Create PROCEDURE [prd].[RptPrd_ProductInfo]
	@SelectedProds	Int = 0,
	@SelectedStore	Int = 0,
	@SelectedAcnt1	Int = 0,
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@FiscalYearFr	int = null,
	@FiscalYearTo	int = null,	
	@SerialNoFr		int = null,
	@SerialNoTo		int = null,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@RepOptions		varchar(10) = '',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarchar(200) = ''
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @SelectedProduct VarChar(20);
DECLARE @CustomersAcntPartNumber AS Tinyint;
DECLARE @StartLayerIndex AS TINYINT;
DECLARE @LayerLen AS TINYINT;

BEGIN

	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	IF (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	set @RepOptions = '';
	IF (@SelectedProds	Is Null)	set @SelectedProds = 0;
	IF (@SelectedStore	Is Null)	set @SelectedStore = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	
	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;
		
	SET @CustomersAcntPartNumber = 0
	SET @StartLayerIndex = 0
	SET @LayerLen = 0
	
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'

	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'
	
	SELECT @CustomersAcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
			
	---------------------------------------------------------------------------
	-- Where Section ----------------------------------------------------------
	SET @StrWhere = 'SD.ProcessID = 80 And SH.ProcessID = 70';

	IF (@SelectedProds > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'SH.ProductID') 

	IF (@SelectedStore > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'SD.StoreID') 

	IF (@SelectedAcnt1 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'SD.AcntCode')
	IF (@SelectedAcnt2 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'SD.AcntCode')
	IF (@SelectedAcnt3 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'SD.AcntCode')

	IF (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (SD.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (SD.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SD.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))'
	IF (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (SD.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (SD.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))'

	IF (@DocDateFr is not null) 
		SET @StrWhere = @StrWhere + ' AND (SD.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (SD.DocDate <= ''' + @DocDateTo + ''')'
		
	-- Select Section ----------------------------------------------------------
	--acc.funGetAcntName(SUBSTRING(SH.AcntCode, ' + LTrim(RTrim(Str(@StartLayerIndex))) + ',' + LTrim(RTrim(Str(@LayerLen))) + '),' + LTrim(RTrim(Str(@CustomersAcntPartNumber))) + ', ' + LTrim(RTrim(Str(@LangID))) + ') As ProduserAcntName
	SET @StrSelect = '
	SELECT SH.ProductID, SH.StoreID, [pub].[funGetGoodsName](SH.ProductID, ' + Ltrim(RTrim(@LangID)) + ') As ProductName,
	   SH.DocDate As SendDate, SD.DocDate As ProductReceiveDate, SH.DocDesc, 
	   pub.funFarsiDateDiff(''Day'', SH.DocDate, SD.DocDate) As DayDiff,
	   SD.GoodsID, [pub].[funGetGoodsName](SD.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') As GoodsName, SD.GoodsQuantity As ProductReceiveCount, 
	   SH.ProductCount As ProductTotalCount, SH.AcntCode As ProduserAcntCode,
	   acc.funPartAcntNameRecurcive(SH.AcntCode,' + LTrim(RTrim(Str(@CustomersAcntPartNumber))) + ') ProduserAcntName,
	   GH1.GoodsWeight,GH1.PureWeight, [inv].[funGetUnitName]( GH1.UnitID,' + Ltrim(RTrim(@LangID)) + ') AS UnitName
	FROM inv.tblStorageDocsHdr SH
	INNER JOIN inv.tblStorageDocsDtl SD 
	ON 	SH.ProductID = SD.GoodsID And 
			((SH.ProcessID = SD.BaseProcessID 	And SH.ProcessNo = SD.BaseProcessNo 
				And SH.SerialNo = SD.BaseSerialNo And SH.FiscalYear = SD.BaseFiscalYear ) 
			or (SH.BatchNo= SD.BatchNo and  SH.BatchNo<>''''))
	INNER Join inv.tblGoods GH1 ON SH.ProductID = GH1.GoodsID
	INNER Join inv.tblGoodsDtl GD1 ON SH.ProductID = GD1.GoodsID
	INNER Join inv.tblGoodsDtl GD2 ON SD.GoodsID = GD2.GoodsID
	WHERE ' + @StrWhere
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	---------------------------------------------------------------------------
END
GO
