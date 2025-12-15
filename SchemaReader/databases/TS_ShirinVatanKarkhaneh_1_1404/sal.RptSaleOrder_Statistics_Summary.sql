USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ==================== 
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1386/11/14
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 1392/05/22
-- Last Modifier : TakroSystem\Zia
-- Description	 : آمار (یا وضعیت) سفارش کالاها - خلاصه
-- ==============================================
Create PROCEDURE [sal].[RptSaleOrder_Statistics_Summary] 
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = NULL,
	@SerialNoFr		Int = NULL,
	@FiscalYearTo	Int = NULL,
	@SerialNoTo		Int = NULL,
	@DateFr			Char(10) = NULL,
	@DateTo			Char(10) = NULL,
	@SelectedGoods	Int = NULL,
	@SelectedOrder1	Int = NULL,
	@SelectedOrder2	Int = NULL,
	@SelectedOrder3	Int = NULL,
	@SelectedOrder4	Int = NULL,
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@SalDateFr		Char(10) = NULL,
	@SalDateTo		Char(10) = NULL,
	@RepOptions		VarChar(20) = '0001020', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhereS	NVarChar(max);
DECLARE @StrWhereX	NVarChar(max);

DECLARE @CodeField	VarChar(20);
DECLARE @NameField	NVarChar(200);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @DocStep		Int;
DECLARE @GroupByGoods	Bit;	-- گروه بندی بر اساس کد کالا باشد؟
DECLARE @GroupByAcnt	Bit;	-- گروه بندی بر اساس کد سفارش دهنده باشد؟
DECLARE @ShowProduce	Bit;    -- در جریان تولید؟
DECLARE @RemainOnly		Bit;	-- فقط سفارشاتی که مانده دارند (سفارش با تحویل برابر نیست) بیاید؟
DECLARE @DecRet			Bit; 
DECLARE @CancelOnly		Bit; 
DECLARE @SoldOnly		Bit; 
DECLARE @GroupAllStore	Bit
DECLARE @PrintType		Bit
DECLARE @PriceField		NVarChar(1000);
DECLARE @round_val		int;
DECLARE	@SelectedStore	Int ;
DECLARE	@UserIsAdmin	bit;
DECLARE	@UserID			Int;

Begin --============== S T A R T  C O D E ===================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();
	SET NOCOUNT ON;

	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue FROM pub.tblSettings WHERE SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	SELECT @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	FROM pub.tblCodeLayer 
	WHERE TableName ='inv.tblGoods' AND PartNumber < @UnitPart

	SELECT @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE TableName = 'inv.tblGoods' AND PartNumber = @UnitPart
	
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo    = '1@1@1';
	IF (@RepOptions	  Is Null)	SET @RepOptions = '0001020';
	IF (@ProcessNo	   Is Null) SET @ProcessNo  = 1;

	If (@FiscalYearFr	Is Null) SET @SerialNoFr	= Null;
	If (@FiscalYearTo	Is Null) SET @SerialNoTo	= Null;
	If (@SerialNoFr		Is Null) SET @FiscalYearFr	= Null;
	If (@SerialNoTo		Is Null) SET @FiscalYearTo  = Null;

	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;

	IF (@SelectedOrder1 Is Null)	SET @SelectedOrder1 = 0;
	IF (@SelectedOrder2 Is Null)	SET @SelectedOrder2 = 0;
	IF (@SelectedOrder3 Is Null)	SET @SelectedOrder3 = 0;
	IF (@SelectedOrder4 Is Null)	SET @SelectedOrder4 = 0;

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);
	SET @SelectedStore	= pub.funSplitString(@RepInfo, '@', 6);
	
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;

	SET @GroupByGoods	= Substring(@RepOptions, 1, 1);
	SET @GroupByAcnt	= Substring(@RepOptions, 2, 1);
	SET @ShowProduce	= Substring(@RepOptions, 3, 1);
	SET @RemainOnly		= Substring(@RepOptions, 4, 1);
	SET @DecRet			= Substring(@RepOptions, 5, 1);
	SET @DocStep		= Substring(@RepOptions, 6, 1);
	SET @CancelOnly		= Substring(@RepOptions, 7, 1);
	SET @SoldOnly		= Substring(@RepOptions, 8, 1);
	SET @GroupAllStore	= Substring(@RepOptions, 9, 1);
	SET @PrintType		= Substring(@RepOptions, 10, 1);
	
	SELECT @round_val = isnull(SettingValue, 0)
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimals'	
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = ' (D.ProcessID=180) AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	IF (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ') OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ') OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	IF (@DateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DateFr + ''')' 
	IF (@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DateTo + ''')'

	-- Goods
	IF	(@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	IF	(@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 

	-- Acnt
	IF	(@SelectedOrder1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder1, 'D.AcntCode') 
	IF	(@SelectedOrder2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder2, 'D.AcntCode') 
	IF	(@SelectedOrder3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder3, 'D.AcntCode') 
	IF	(@SelectedOrder4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder4, 'D.AcntCode') 

	-- Visitor
	IF	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	IF	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	IF	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	IF	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')

	-- DocStep
	IF (@DocStep Is Not Null) and (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep=' + Str(@DocStep) + ')'
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	IF (@GroupByAcnt = 1)
	BEGIN
		SET @CodeField = 'AcntCode'
		SET @NameField = '[pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName, '''' BarCode'
	END
	ELSE
	BEGIN
		SET @CodeField = 'GoodsID'
		SET @NameField = '[pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') As GoodsName,
						  IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode,
						  [inv].[FunGetGoodsWeight] (T.GoodsID) GoodsWeight'
	END

	SET @StrWhereS = '(SD.ProcessID=90)'
	
	IF (@SalDateFr Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (SD.DocDate>=''' + @SalDateFr + ''')' 
	IF (@SalDateTo Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (SD.DocDate<=''' + @SalDateTo + ''')'

	IF (@DecRet = 1)
		SET @StrSelect = '
				ISNULL((SELECT Sum(R.GoodsQuantity)
						FROM inv.tblStorageDocsDtl SD
						INNER JOIN inv.tblStorageDocsDtl R ON R.BaseProcessID = SD.ProcessID 
														  AND R.BaseProcessNo = SD.ProcessNo 
														  AND R.BaseFiscalYear = SD.FiscalYear 
														  AND R.BaseSerialNo = SD.SerialNo 
														  AND R.BaseDocRowNo = SD.DocRowNo
						WHERE ' + @StrWhereS + '
						  AND (SD.BaseProcessID = D.ProcessID) 
						  AND (SD.BaseProcessNo = D.ProcessNo) 
						  AND (SD.BaseFiscalYear = D.FiscalYear) 
						  AND (SD.BaseSerialNo = D.SerialNo) 
						  AND (SD.BaseDocRowNo = D.DocRowNo) 
						  AND (R.ProcessID = 100) ),0) SoldRetQuantity,
				ISNULL((SELECT Sum(R.GoodsQuantity*SD.GoodsPrice)
						FROM inv.tblStorageDocsDtl SD
						INNER JOIN inv.tblStorageDocsDtl R ON R.BaseProcessID = SD.ProcessID 
														  AND R.BaseProcessNo = SD.ProcessNo 
														  AND R.BaseFiscalYear = SD.FiscalYear 
														  AND R.BaseSerialNo = SD.SerialNo 
														  AND R.BaseDocRowNo = SD.DocRowNo
						WHERE ' + @StrWhereS + '
						  AND (SD.BaseProcessID = D.ProcessID) 
						  AND (SD.BaseProcessNo = D.ProcessNo) 
						  AND (SD.BaseFiscalYear = D.FiscalYear) 
						  AND (SD.BaseSerialNo = D.SerialNo) 
						  AND (SD.BaseDocRowNo = D.DocRowNo) 
						  AND (R.ProcessID = 100) ),0) SoldRetPrice '
	ELSE
		SET @StrSelect = 'CAST(0 AS FLOAT) SoldRetQuantity, CAST(0 AS FLOAT) SoldRetPrice '
	
	--- sale ----------------------------------------------------
	
	SET @StrWhereS = '(SD.ProcessID=90)'
	
	IF (@SalDateFr Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (SD.DocDate >= ''' + @SalDateFr + ''')' 
	IF (@SalDateTo Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (SD.DocDate <= ''' + @SalDateTo + ''')'

	--- extended ------------------------------------------------
	
	SET @StrWhereX = '(1=1)'
	
	-- مقدار تحویل داده شده بیشتر از صفر باشد
	IF (@SoldOnly = 1)
		SET @StrWhereX = @StrWhereX + ' AND (ROUND(SoldQuantity, ' + ltrim(str(@round_val)) + ') > 0)'
		
	-- مقدار تحویل داده شده برابر با خالص سفارش نباشد
	IF (@RemainOnly = 1)
		SET @StrWhereX = @StrWhereX + ' AND (ROUND((GoodsQuantity - CancelQuantity) - (SoldQuantity - SoldRetQuantity), ' + ltrim(str(@round_val)) + ') <> 0)'
	
	-- فقط سفارشاتی که انصرافی دارند
	IF (@CancelOnly = 1)
		SET @StrWhereX = @StrWhereX + ' AND (ROUND(CancelQuantity, ' + ltrim(str(@round_val)) + ') > 0)'


		
	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblStoreID
		DROP TABLE #tblVisitorAcntCode
		DROP TABLE #tblGoods
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tblAcntCode
	(AcntCode 	Varchar(20)collate arabic_cs_as null)
	CREATE TABLE #tblGoods
	(GoodsID 	Varchar(20)collate arabic_cs_as null)
	CREATE TABLE #tblStoreID
	(StoreID 	Varchar(20)collate arabic_cs_as null)
	 CREATE TABLE #tblVisitorAcntCode
	(VisitorAcntCode 	Varchar(20)collate arabic_cs_as null)
	
	 INSERT INTO  #tblVisitorAcntCode (VisitorAcntCode) SELECT Distinct VisitorAcntCode	FROM sal.tblSaleOrderDtl 
	 INSERT INTO  #tblAcntCode (AcntCode) SELECT Distinct AcntCode FROM sal.tblSaleOrderDtl 
	 INSERT INTO  #tblGoods (GoodsID) SELECT Distinct GoodsID FROM sal.tblSaleOrderDtl	 	
	 INSERT INTO  #tblStoreID (StoreID) SELECT Distinct StoreID	FROM sal.tblSaleOrderDtl
	 
	 INSERT INTO  #tblVisitorAcntCode (VisitorAcntCode) SELECT Distinct VisitorAcntCode FROM sal.tblSaleOrderHdr
	 INSERT INTO  #tblAcntCode (AcntCode) SELECT Distinct AcntCode FROM sal.tblSaleOrderHdr 
	 INSERT INTO  #tblStoreID (StoreID) SELECT Distinct StoreID	FROM sal.tblSaleOrderHdr
	 
	IF @UserIsAdmin=0
	BEGIN
		 EXEC pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		 EXEC pub.SpFilterByPermission2 '#tblVisitorAcntCode', 'VisitorAcntCode', 'acc.tblAcnt', @UserID;
		 EXEC pub.SpFilterByPermission2 '#tblStoreID', 'StoreID', 'inv.tblStores', @UserID;
		 EXEC pub.SpFilterByPermission2 '#tblGoods', 'GoodsID', 'inv.tblGoods', @UserID;
	END
	 
	SET @StrWhere =  @StrWhere + ' AND ( D.AcntCode IN (SELECT AcntCode	FROM #tblAcntCode) OR H.AcntCode IN (SELECT AcntCode FROM #tblAcntCode))'
	SET @StrWhere =  @StrWhere + ' AND ( D.VisitorAcntCode IN (SELECT VisitorAcntCode FROM #tblVisitorAcntCode) OR H.VisitorAcntCode IN (SELECT VisitorAcntCode	FROM #tblVisitorAcntCode))'
	SET @StrWhere =  @StrWhere + ' AND ( D.StoreID IN (SELECT StoreID FROM #tblStoreID) OR H.StoreID IN (SELECT StoreID FROM #tblStoreID))'
	SET @StrWhere =  @StrWhere + ' AND ( D.GoodsID IN (SELECT GoodsID FROM #tblGoods))'
	
	--- extended ------------------------------------------------
	
	IF @PrintType =1
		SET @PriceField='SUM(GoodsPrice) GoodsPrice, 
						 SUM(CancelPrice) CancelPrice, 
						 SUM(SoldPrice) SoldPrice, 
						 SUM(SoldRetPrice) SoldRetPrice,'
	ELSE 
		SET @PriceField='0 GoodsPrice, 
						 0 CancelPrice, 
						 0 SoldPrice, 
						 0 SoldRetPrice,'

	SET @StrSelect = '
	SELECT ' + @CodeField + ', 
		   ' + @NameField + ',
		   SUM(GoodsQuantity) OrderQuantity, 
		   SUM(CancelQuantity) CancelQuantity, 
		   ' + @PriceField + '
		   SUM(SoldQuantity) SoldQuantity, 
		   SUM(SoldRetQuantity) SoldRetQuantity,
		   StoreID,   
		   SUM(Qty) Qty
	FROM (SELECT D.' + @CodeField + ',
				 (D.GoodsQuantity) GoodsQuantity,
				 (D.GoodsQuantity*D.GoodsPrice) GoodsPrice,
				 ' + CASE WHEN @GroupAllStore=1 THEN ''''' AS StoreID ' ELSE 'H.StoreID' END + ',
				 ISNULL((SELECT	SUM(GoodsQuantity * EnterKind)
						 FROM inv.tblStorageDocsDtl SD
						 WHERE SD.GoodsID = D.GoodsID 
						   AND (SD.StoreID = D.StoreID OR D.StoreID='''')), 0) Qty,
				 ISNULL((SELECT	SUM(C.GoodsQuantity)
						 FROM sal.tblSaleOrderDtl C
						 WHERE (C.BaseProcessID = D.ProcessID) 
						   AND (C.BaseProcessNo = D.ProcessNo) 
						   AND (C.BaseFiscalYear = D.FiscalYear) 
						   AND (C.BaseSerialNo = D.SerialNo) 
						   AND (C.BaseDocRowNo = D.DocRowNo) 
						   AND (C.ProcessID = 185)), 0) CancelQuantity,
				 ISNULL((SELECT SUM(C.GoodsQuantity * C.GoodsPrice)
						 FROM sal.tblSaleOrderDtl C
						 WHERE (C.BaseProcessID = D.ProcessID) 
						   AND (C.BaseProcessNo = D.ProcessNo) 
						   AND (C.BaseFiscalYear = D.FiscalYear) 
						   AND (C.BaseSerialNo = D.SerialNo) 
						   AND (C.BaseDocRowNo = D.DocRowNo) 
						   AND (C.ProcessID = 185)), 0) CancelPrice,
				 ISNULL((SELECT	SUM(GoodsQuantity) 
						 FROM inv.tblStorageDocsDtl SD
						 WHERE ' + @StrWhereS + '
						   AND SD.BaseProcessID = D.ProcessID 
						   AND SD.BaseProcessNo = D.ProcessNo 
						   AND SD.BaseFiscalYear = D.FiscalYear 
						   AND SD.BaseSerialNo = D.SerialNo 
						   AND SD.BaseDocRowNo = D.DocRowNo),0) SoldQuantity,
				 ISNULL((SELECT	SUM(GoodsQuantity * GoodsPrice) 
						 FROM inv.tblStorageDocsDtl SD
						 WHERE ' + @StrWhereS + '
						   AND SD.BaseProcessID = D.ProcessID 
						   AND SD.BaseProcessNo = D.ProcessNo  
						   AND SD.BaseFiscalYear = D.FiscalYear 
						   AND SD.BaseSerialNo = D.SerialNo 
						   AND SD.BaseDocRowNo = D.DocRowNo), 0) SoldPrice,
				 ' + @StrSelect + ' 
		  FROM sal.tblSaleOrderDtl AS D
		  INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID 
										  AND H.ProcessNo = D.ProcessNo 
										  AND H.FiscalYear = D.FiscalYear 
										  AND H.SerialNo = D.SerialNo
		  WHERE ' + @StrWhere + ') T  
	WHERE ' + @StrWhereX + '
	GROUP BY T.StoreID, T.' + @CodeField

	---- S O R T --------------------------------------------------------------
	SET @StrSelect = @StrSelect + '
	ORDER BY T.' + @CodeField
	---------------------------------------------------------------------------
	---- R U N ----------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
