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
CREATE PROCEDURE [prd].[RptPrd_ProductStatus]
	@SelectedProds	Int = 0,
	@SelectedStore	Int = 0,
	@SelectedAcnt1	Int = 0,
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@FiscalYearFr	int = null,
	@FiscalYearTo	int = null,	
	@SerialNo		int = null,
	@BatchNo		varchar(20) = null,
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
DECLARE @StrWhereBase	NVarChar(max)

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
	
	DECLARE @SelectedStore2	Int 
	DECLARE @ShowType	Int 
	
	SET @SelectedStore2		 = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ShowType		 = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	
		
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
	SET @StrWhere = ' 1 = 1 ';
	SET @StrWhereBase = ' 1 = 1 ';

	IF (@SelectedProds > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D.GoodsID') 

	IF (@SelectedStore > 0)
		set @StrWhereBase = @StrWhereBase + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'C.StoreID') 
	IF (@SelectedStore2 > 0)
		set @StrWhereBase = @StrWhereBase + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'B.StoreID') 

	IF (@SelectedAcnt1 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.ProducerAcntCode')
	IF (@SelectedAcnt2 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.ProducerAcntCode')
	IF (@SelectedAcnt3 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.ProducerAcntCode')

	IF (@SerialNo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.SerialNo = ' + LTrim(Str(@SerialNo)) + ')'
	IF (@BatchNo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.BatchNo = ''' + @BatchNo + ''')'

	IF (@DocDateFr is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	IF (@ShowType is not null and @ShowType =2)	
		SET @StrWhereBase = @StrWhereBase  + ' AND (isnull(C.GoodsQuantity,0) >= isnull(B.GoodsQuantity,0) )'
	IF (@ShowType is not null and @ShowType =3)		
		SET @StrWhereBase = @StrWhereBase + ' AND (isnull(C.GoodsQuantity,0) < isnull(B.GoodsQuantity,0) )'

	-- Select Section ----------------------------------------------------------
	
	--,isull(B.StoreID,'''') as StoreIDGoods,isull(C.StoreID,'''') as StoreIDProduct
	SET @StrSelect = '
	
	SELECT A.ProducerAcntCode, [pub].[GetCodeName](	A.ProducerAcntCode, '+ STR(@LangID) +') As ProducerAcntName,A.SerialNo, A.BatchNo, A.ContractID,
		   A.GoodsID, [pub].[funGetGoodsName](A.GoodsID, '+ STR(@LangID) +')as GoodsName ,A.GoodsQuantity, isnull(B.GoodsQuantity,0) AS SendQty, 
		   ISNULL(C.GoodsQuantity,0) AS ResQty, ISNULL(B.StoreID,'''') as StoreIDGoods, ISNULL(C.StoreID,'''')  as StoreIDProduct
	FROM
		(SELECT TOP (100) PERCENT H.ProducerAcntCode, H.SerialNo, H.BatchNo, D.GoodsID, SUM(D.GoodsQuantity * D.EnterKind) AS GoodsQuantity, 
			                      H.ContractID , '''' as StoreID
		 FROM prd.tblProducersWageDtl AS D 
		 INNER JOIN
         prd.tblProducersWageHdr AS H ON D.ProducerAcntCode = H.ProducerAcntCode AND D.SerialNo = H.SerialNo AND D.ProcessID = H.ProcessID
		 WHERE    ' + @StrWhere+ ' 
		 GROUP BY H.ProducerAcntCode, H.SerialNo, H.BatchNo, D.GoodsID, H.ContractID
		 ORDER BY H.ProducerAcntCode, H.SerialNo, H.BatchNo, D.GoodsID) AS A 
	LEFT OUTER JOIN
	(SELECT H.AcntCode, H.BaseSerialNo, H.BatchNo, D.GoodsID, ISNULL(SUM(D.GoodsQuantity * D.EnterKind), 0) AS GoodsQuantity, H.StoreID
     FROM inv.tblStorageDocsHdr AS H 
     INNER JOIN inv.tblStorageDocsDtl AS D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND 
                                              H.SerialNo = D.SerialNo
     WHERE (H.ProcessID = 80 OR H.ProcessID = 85)
     GROUP BY H.AcntCode, H.BaseSerialNo, H.BatchNo, D.GoodsID,H.StoreID) AS C ON A.ProducerAcntCode = C.AcntCode AND A.SerialNo = C.BaseSerialNo AND
																			   A.BatchNo = C.BatchNo AND A.GoodsID = C.GoodsID 
	 LEFT OUTER JOIN
     (SELECT DISTINCT AcntCode, BaseSerialNo, BatchNo, ProductID, prd.funGetMaxSendGoodsID(AcntCode, ProductID, BaseSerialNo,FormulaNo) AS GoodsQuantity,H.StoreID
     FROM inv.tblStorageDocsHdr AS H
     WHERE (ProcessID = 70 OR ProcessID = 75)) AS B ON A.ProducerAcntCode = B.AcntCode AND 
	        A.SerialNo = B.BaseSerialNo AND A.BatchNo = B.BatchNo AND A.GoodsID = B.ProductID
	WHERE ' + @StrWhereBase
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	---------------------------------------------------------------------------
END
GO
