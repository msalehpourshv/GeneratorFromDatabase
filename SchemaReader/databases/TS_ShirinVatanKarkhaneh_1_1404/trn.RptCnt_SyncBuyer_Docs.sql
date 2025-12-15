USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 :REZA NOGREHPASAND
-- Create date   : 1392/01/18
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 :   گزارش برگه هاي ورود صورت وضعيت  - خريدار
-- =============================================
CREATE PROCEDURE [trn].[RptCnt_SyncBuyer_Docs]
	@FromSerialNo		INT ,
	@ToSerialNo			INT,
	@FromFiscalYear		INT,
	@ToFiscalYear		INT ,
	@FromDate			CHAR(10),
	@ToDate				CHAR(10),
	@FactoryID			VARCHAR(20),
	@ContractorIDFrom	VARCHAR(20),
	@ContractorIDTo		VARCHAR(20),
	@DriverID			VARCHAR(20),
	@GoodsID			VARCHAR(20),
	@CityID				VARCHAR(20),
	@FreightNo			NVARCHAR(50),
	@CarNo				NVARCHAR(20),
	@RepInfo			NVarChar(100) = '1@1@1' ,
	@pmFixOptions		NVarChar(100) = '1@1@1' ,
	@FromDocDate			CHAR(10),
	@ToDocDate				CHAR(10)

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID			Int; -- برای حالت کدهای انتخابی

DECLARE @GrpByFactory Bit;

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	
	SET @GrpByFactory = 0
	
	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @GrpByFactory	= pub.funSplitString(@RepInfo, '@', 6);

-- ================ WHERE ===========================

	SET @StrWhere = '(1=1) '
	
	IF (@FromSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.SerialNo >=' + LTRIM(STR(@FromSerialNo))
		
	IF (@ToSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.SerialNo <=' + LTRIM(STR(@ToSerialNo))
		
	IF (@FromFiscalYear IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.FiscalYear >= ' + LTRIM(STR(@FromFiscalYear))  
	
	IF (@ToFiscalYear IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.FiscalYear <= ' + LTRIM(STR(@ToFiscalYear))
	
	IF (@FromDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.FreightDate >= ''' + @FromDate + ''''
	
	IF (@ToDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.FreightDate <= ''' + @ToDate + ''''
		
	IF (@FactoryID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.FactoryAcntCode = ''' + @FactoryID + ''''
		
	IF (@ContractorIDFrom IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.ContractorAcntCode >= ''' + @ContractorIDFrom + ''''
	
	IF (@ContractorIDTo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.ContractorAcntCode <= ''' + @ContractorIDTo + ''''
		
	IF (@DriverID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.DriverID = ''' + @DriverID + ''''
		
	IF (@GoodsID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.GoodsID = ''' + @GoodsID + ''''
		
	IF (@CityID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.CityID = ''' + @CityID + ''''
		
	IF (@CarNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.CarNo = N''' + @CarNo + ''''
		
	IF (@FreightNo IS NOT null)
			SET @StrWhere = @StrWhere + ' AND h.FreightNo = N''' + @FreightNo + ''''
		
	IF (@FromDocDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.DocDate >= ''' + @FromDocDate + ''''
	
	IF (@ToDocDate IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.DocDate <= ''' + @ToDocDate + ''''
	
-- ================ SELECT ===========================

	SET @StrSelect =' 
	SELECT 
		cnt.funGetPureWeight(h.SerialNo,h.ProcessID,h.ProcessNo,h.FiscalYear,1) as wheight1,
		cnt.funBuyPrice(h.SerialNo,h.ProcessID,h.ProcessNo,h.FiscalYear,1) as BuyPrice1,
		cnt.funGetPureWeight(h.SerialNo,h.ProcessID,h.ProcessNo,h.FiscalYear,2) as wheight2,
		cnt.funBuyPrice(h.SerialNo,h.ProcessID,h.ProcessNo,h.FiscalYear,2) as BuyPrice2,
		cnt.funGetPureWeight(h.SerialNo,h.ProcessID,h.ProcessNo,h.FiscalYear,3) as wheight3,
		cnt.funBuyPrice(h.SerialNo,h.ProcessID,h.ProcessNo,h.FiscalYear,3) as BuyPrice3,
		cnt.funGetPureWeight(h.SerialNo,h.ProcessID,h.ProcessNo,h.FiscalYear,4) as wheight4,
		cnt.funBuyPrice(h.SerialNo,h.ProcessID,h.ProcessNo,h.FiscalYear,4) as BuyPrice4,
		h.*, pub.GetCodeName(h.ContractorAcntCode,' + ltrim(STR(@LangID)) + ') AS ContractorName,
		[pub].[funGetGoodsName](h.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		IsNull([inv].[FunGetGoodsBarCode] (h.GoodsID), '''') BarCode,
		pub.GetCodeName(h.FactoryAcntCode,' + ltrim(STR(@LangID)) + ') AS FactoryName
	FROM cnt.tblSyncSaleBuyHdr h
	LEFT JOIN pub.tblLocationsDtl l ON h.CityID=l.LocationID 
	WHERE ' + @StrWhere + '
	ORDER BY h.FactoryAcntCode,h.ContractorAcntCode '
	

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

END
GO
