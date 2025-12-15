USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\S.Mahdi Mostafavi
-- Create date   : 1403/10/30
-- Viewed By	 : 
-- Last Modifier : 
-- Last Modified : 
-- Description   : 
-- ==============================================
Create PROCEDURE [prd].[RptPrd_UsedConsumablesListInProductRpt]
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
DECLARE @StrWhereProd	NVarChar(max)
DECLARE @StrWherePlan	NVarChar(max)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @SelectedProduct VarChar(20);
DECLARE @CustomersAcntPartNumber AS Tinyint;
DECLARE @StartLayerIndex AS TINYINT;
DECLARE @LayerLen AS TINYINT;
DECLARE @ProcessIDStep as TINYINT;

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

	SET @ProcessIDStep	= pub.funSplitString(@ExtraParams, '@', 1);
	
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
	SET @StrWhereProd = 'D.ProcessID = 80 ';
	SET @StrWherePlan = 'D.ProcessID in (82,72,83,73)'

	IF (@SelectedProds > 0)
	BEGIN
		set @StrWhereProd = @StrWhereProd + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D.GoodsID') 
		set @StrWherePlan = @StrWherePlan + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D.GoodsID') 
	END

	IF (@SelectedStore > 0)
	BEGIN
		set @StrWhereProd = @StrWhereProd + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
		set @StrWherePlan = @StrWherePlan + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	END

	IF (@SelectedAcnt1 > 0)
	BEGIN
		set @StrWhereProd = @StrWhereProd + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
		set @StrWherePlan = @StrWherePlan + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	END
	IF (@SelectedAcnt2 > 0)
	BEGIN
		set @StrWhereProd = @StrWhereProd + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
		set @StrWherePlan = @StrWherePlan + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	END
	IF (@SelectedAcnt3 > 0)
	BEGIN
		set @StrWhereProd = @StrWhereProd + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
		set @StrWherePlan = @StrWherePlan + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	END

	IF (@SerialNoFr Is Not Null)
	BEGIN
		Set @StrWhereProd = @StrWhereProd + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))'
		Set @StrWherePlan = @StrWherePlan + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))'
	END
	IF (@SerialNoTo Is Not Null)
	BEGIN
		Set @StrWhereProd = @StrWhereProd + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))'
		Set @StrWherePlan = @StrWherePlan + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))'
	END

	IF (@DocDateFr is not null) 
	BEGIN
		SET @StrWhereProd = @StrWhereProd + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
		SET @StrWherePlan = @StrWherePlan + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	END
	IF (@DocDateTo is not null)
	BEGIN
		SET @StrWhereProd = @StrWhereProd + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		SET @StrWherePlan = @StrWherePlan + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
	END
		
	-- Select Section ----------------------------------------------------------
	--acc.funGetAcntName(SUBSTRING(SH.AcntCode, ' + LTrim(RTrim(Str(@StartLayerIndex))) + ',' + LTrim(RTrim(Str(@LayerLen))) + '),' + LTrim(RTrim(Str(@CustomersAcntPartNumber))) + ', ' + LTrim(RTrim(Str(@LangID))) + ') As ProduserAcntName
	IF @ProcessIDStep = 1
	Begin
		SET @StrSelect = '
		SELECT D.GoodsID GoodsIDRec,
			   pub.funGetGoodsName(D.GoodsID,1) AS GoodsNameRec,
			   D.GoodsQuantity GoodsQuantityRec,
			   D.GoodsAmount GoodsAmountRec,
			   D.SubUnitQuantity SubUnitQuantityRec,
			   D.SubUnitID SubUnitIDRec,
			   inv.funGetUnitName(D.SubUnitID,1) AS SubUnitNameRec,
			   D.StoreID StoreIDRec,
			   D.DocDate DocDateRec,
			   D.SerialNo SerialNoRec,
			   D.FiscalYear,D.SerialNo,D.GoodsID,D.DocRowNo,
			   DD.GoodsID GoodsIDSen,
			   pub.funGetGoodsName(DD.GoodsID,1) AS GoodsNameSen,
			   DD.GoodsQuantity GoodsQuantitySen,
			   DD.GoodsAmount GoodsAmountSen,
			   DD.SubUnitQuantity SubUnitQuantitySen,
			   DD.SubUnitID SubUnitIDSen,
			   inv.funGetUnitName(DD.SubUnitID,1) AS SubUnitNameSen,
			   DD.StoreID StoreIDSen,
			   DD.DocDate DocDateSen,
			   DD.SerialNo SerialNoSen
		FROM  inv.tblStorageDocsDtl D
		LEFT JOIN inv.tblStorageDocsDtl DD ON 	
			D.BaseProcessID = DD.ProcessID AND 	
			D.BaseProcessNo = DD.ProcessNo AND 	
			D.BaseFiscalYear = DD.FiscalYear AND 	
			D.BaseSerialNo = DD.SerialNo
		WHERE ' + @StrWhereProd +'
		ORDER BY D.FiscalYear,D.SerialNo,D.GoodsID,D.DocRowNo'
		
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
	END
	
	ELSE IF @ProcessIDStep = 2
	Begin
		SET @StrSelect = '
		SELECT D.GoodsID GoodsIDRec,
		   pub.funGetGoodsName(D.GoodsID,1) AS GoodsNameRec,
		   D.GoodsQuantity GoodsQuantityRec,
		   D.GoodsAmount GoodsAmountRec,
		   D.SubUnitQuantity SubUnitQuantityRec,
		   D.SubUnitID SubUnitIDRec,
		   inv.funGetUnitName(D.SubUnitID,1) AS SubUnitNameRec,
		   D.StoreID StoreIDRec,
		   D.DocDate DocDateRec,
		   D.SerialNo SerialNoRec,
		   D.FiscalYear,D.SerialNo,D.GoodsID,D.DocRowNo,
		   DD.GoodsID GoodsIDSen,
		   pub.funGetGoodsName(DD.GoodsID,1) AS GoodsNameSen,
		   DD.GoodsQuantity GoodsQuantitySen,
		   DD.GoodsAmount GoodsAmountSen,
		   DD.SubUnitQuantity SubUnitQuantitySen,
		   DD.SubUnitID SubUnitIDSen,
		   inv.funGetUnitName(DD.SubUnitID,1) AS SubUnitNameSen,
		   DD.StoreID StoreIDSen,
		   DD.DocDate DocDateSen,
		   DD.SerialNo SerialNoSen
		FROM  inv.tblStorageDocsDtl D
		LEFT JOIN inv.tblStorageDocsDtl DD ON 	
			D.BaseProcessID = DD.BaseProcessID AND 	
			D.BaseProcessNo = DD.BaseProcessNo AND 	
			D.BaseFiscalYear = DD.BaseFiscalYear AND 	
			D.BaseSerialNo = DD.BaseSerialNo AND
			D.BaseDocRowNo = DD.BaseDocRowNo
		WHERE ' + @StrWherePlan +'
		ORDER BY D.FiscalYear,D.SerialNo,D.GoodsID,D.DocRowNo'
		
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
	END

	ELSE IF @ProcessIDStep = 3
	Begin
		SET @StrSelect = '
		SELECT D.GoodsID GoodsIDRec,
			   pub.funGetGoodsName(D.GoodsID,1) AS GoodsNameRec,
			   D.GoodsQuantity GoodsQuantityRec,
			   D.GoodsAmount GoodsAmountRec,
			   D.SubUnitQuantity SubUnitQuantityRec,
			   D.SubUnitID SubUnitIDRec,
			   inv.funGetUnitName(D.SubUnitID,1) AS SubUnitNameRec,
			   D.StoreID StoreIDRec,
			   D.DocDate DocDateRec,
			   D.SerialNo SerialNoRec,
			   D.FiscalYear,D.SerialNo,D.GoodsID,D.DocRowNo,
			   DD.GoodsID GoodsIDSen,
			   pub.funGetGoodsName(DD.GoodsID,1) AS GoodsNameSen,
			   DD.GoodsQuantity GoodsQuantitySen,
			   DD.GoodsAmount GoodsAmountSen,
			   DD.SubUnitQuantity SubUnitQuantitySen,
			   DD.SubUnitID SubUnitIDSen,
			   inv.funGetUnitName(DD.SubUnitID,1) AS SubUnitNameSen,
			   DD.StoreID StoreIDSen,
			   DD.DocDate DocDateSen,
			   DD.SerialNo SerialNoSen
		FROM  inv.tblStorageDocsDtl D
		LEFT JOIN inv.tblStorageDocsDtl DD ON 	
			D.BaseProcessID = DD.ProcessID AND 	
			D.BaseProcessNo = DD.ProcessNo AND 	
			D.BaseFiscalYear = DD.FiscalYear AND 	
			D.BaseSerialNo = DD.SerialNo
		WHERE ' + @StrWhereProd +'
		UNION
		SELECT D.GoodsID GoodsIDRec,
		   pub.funGetGoodsName(D.GoodsID,1) AS GoodsNameRec,
		   D.GoodsQuantity GoodsQuantityRec,
		   D.GoodsAmount GoodsAmountRec,
		   D.SubUnitQuantity SubUnitQuantityRec,
		   D.SubUnitID SubUnitIDRec,
		   inv.funGetUnitName(D.SubUnitID,1) AS SubUnitNameRec,
		   D.StoreID StoreIDRec,
		   D.DocDate DocDateRec,
		   D.SerialNo SerialNoRec,
		   D.FiscalYear,D.SerialNo,D.GoodsID,D.DocRowNo,
		   DD.GoodsID GoodsIDSen,
		   pub.funGetGoodsName(DD.GoodsID,1) AS GoodsNameSen,
		   DD.GoodsQuantity GoodsQuantitySen,
		   DD.GoodsAmount GoodsAmountSen,
		   DD.SubUnitQuantity SubUnitQuantitySen,
		   DD.SubUnitID SubUnitIDSen,
		   inv.funGetUnitName(DD.SubUnitID,1) AS SubUnitNameSen,
		   DD.StoreID StoreIDSen,
		   DD.DocDate DocDateSen,
		   DD.SerialNo SerialNoSen
		FROM  inv.tblStorageDocsDtl D
		LEFT JOIN inv.tblStorageDocsDtl DD ON 	
			D.BaseProcessID = DD.BaseProcessID AND 	
			D.BaseProcessNo = DD.BaseProcessNo AND 	
			D.BaseFiscalYear = DD.BaseFiscalYear AND 	
			D.BaseSerialNo = DD.BaseSerialNo AND
			D.BaseDocRowNo = DD.BaseDocRowNo
		WHERE ' + @StrWherePlan +'
		ORDER BY D.FiscalYear,D.SerialNo,D.GoodsID,D.DocRowNo'
		
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
	END
	---------------------------------------------------------------------------
END
GO
