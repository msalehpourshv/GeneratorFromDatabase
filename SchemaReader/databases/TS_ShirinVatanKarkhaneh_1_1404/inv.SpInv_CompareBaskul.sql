USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1400/08/29
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.SpInv_CompareBaskul
@CallType Int, 
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin

DECLARE @StrSelect		NVarChar(max)
DECLARE @StrWhere		NVarChar(2000)
DECLARE @StrWhere2		NVarChar(2000)
DECLARE @StrGoods		NVarChar(200)
DECLARE @SerialNoFR		int
DECLARE @SerialNoTO		int
DECLARE @FiscalYearFR	int
DECLARE @FiscalYearTO	int
DECLARE @BSerialNoFR	int
DECLARE @BSerialNoTO	int
DECLARE @BFiscalYearFR	int
DECLARE @BFiscalYearTO	int
DECLARE @DateFR			Char(10)
DECLARE @DateTO			Char(10)
DECLARE @BDateFR		Char(10)
DECLARE @BDateTO		Char(10)
DECLARE @ProcessID		int
DECLARE @EqualQty		int


DECLARE @Inv_BaskulDocsType		int;
SELECT @Inv_BaskulDocsType = SettingValue 
FROM pub.tblSettings 
WHERE SettingKey = 'Inv_BaskulDocsType'
	
DECLARE @WeightNumberDivision	int;
SELECT @WeightNumberDivision = SettingValue 
FROM pub.tblSettings 
WHERE SettingKey = 'WeightNumberDivision'

SET @WeightNumberDivision = ISNULL(@WeightNumberDivision, 1)

IF @WeightNumberDivision = 0
	SET @WeightNumberDivision = 1

DECLARE @ContentNumberDivision	int;
SELECT @ContentNumberDivision = SettingValue 
FROM pub.tblSettings 
WHERE SettingKey = 'ContentNumberDivision'

SET @ContentNumberDivision = ISNULL(@ContentNumberDivision, 1)

IF @ContentNumberDivision = 0
	SET @ContentNumberDivision = 1
	
IF @CallType=1
	BEGIN
		SET @ProcessID		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
		SET @StrGoods		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @FiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
		SET @SerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
		SET @FiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
		SET @SerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 		
		SET @BFiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
		SET @BSerialNoFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SET @BFiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
		SET @BSerialNoTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
		
		SET @DateFR			= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
		SET @DateTO			= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
		SET @BDateFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
		SET @BDateTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 	
		SET @EqualQty		= LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 	
			

		SET @StrWhere = ' D.ProcessID = ' + str(@ProcessID)
		IF @StrGoods <> ''
			SET @StrWhere = @StrWhere + @StrGoods

		IF @FiscalYearFR > 0
			SET @StrWhere = @StrWhere + ' AND D.FiscalYear >= ' +str(@FiscalYearFR)
		IF @SerialNoFR > 0
			SET @StrWhere = @StrWhere + ' AND D.SerialNo >= ' +str(@SerialNoFR)
		IF @FiscalYearTO > 0
			SET @StrWhere = @StrWhere + ' AND D.FiscalYear <= ' +str(@FiscalYearTO)
		IF @SerialNoTO > 0
			SET @StrWhere = @StrWhere +' AND D.SerialNo	<= ' +str(@SerialNoTO)
		IF @DateFR <> ''
			SET @StrWhere = @StrWhere + ' AND D.DocDate	>= ''' + @DateFR +''''
		IF @DateTO<>''
			SET @StrWhere = @StrWhere + ' AND D.DocDate	<= ''' + @DateTO +''''

	
		IF @BFiscalYearFR > 0
			SET @StrWhere = @StrWhere + ' AND b.FiscalYear >= ' +str(@BFiscalYearFR)
		IF @BSerialNoFR > 0
			SET @StrWhere = @StrWhere +' AND b.SerialNo >= ' +str(@BSerialNoFR)
		IF @BFiscalYearTO > 0
			SET @StrWhere = @StrWhere + ' AND b.FiscalYear <= ' +str(@BFiscalYearTO)
		IF @BSerialNoTO > 0
			SET @StrWhere = @StrWhere + ' AND b.SerialNo <= ' +str(@BSerialNoTO)	
		IF @BDateFR <> ''
			SET @StrWhere = @StrWhere + ' AND aa.DocDate >= ''' + @BDateFR +''''
		IF @BDateTO <> ''
			SET @StrWhere = @StrWhere + ' AND aa.DocDate <= ''' + @BDateTO +''''

		SET @StrWhere2 = @StrWhere
	IF @EqualQty=1
	BEGIN
		SET @StrWhere = @StrWhere + ' AND D.SubUnitQuantity	= b.SubUnitQuantity'
		SET @StrWhere2 = @StrWhere2 + ' AND (( '+str(@Inv_BaskulDocsType)+' = 2 
										AND D.GoodsQuantity * GoodsWeight / ' + str(@WeightNumberDivision)+' = b.SubUnitQuantity) OR ('+str(@Inv_BaskulDocsType)+' <> 2 AND D.SubUnitQuantity = b.SubUnitQuantity))'
	END 
	IF @EqualQty=2
	BEGIN
		SET @StrWhere = @StrWhere + ' AND D.SubUnitQuantity	<> b.SubUnitQuantity'
		SET @StrWhere2 = @StrWhere2 + ' AND (( '+str(@Inv_BaskulDocsType)+' = 2 
										AND D.GoodsQuantity * GoodsWeight / ' + str(@WeightNumberDivision)+' <> b.SubUnitQuantity) OR ('+str(@Inv_BaskulDocsType)+' <> 2 AND D.SubUnitQuantity <> b.SubUnitQuantity))'
	END
	
SELECT D.ProcessID,
	   D.ProcessNo,
	   D.FiscalYear,
	   D.SerialNo,
	   D.DocRowNo,
	   D.DocDate,
	   b.ProcessID BaskulProcessID,
	   b.ProcessNo BaskulProcessNo,
	   b.FiscalYear BaskulFiscalYear,
	   b.SerialNo BaskulSerialNo,
	   b.DocRowNo BaskulDocRowNo,
	   aa.DocDate BaskulDocDate,
	   D.GoodsID,
	   [pub].[funGetGoodsName] (D.GoodsID,1)GetGoodsName ,D.SubUnitID,
	   [inv].[funGetUnitName] (D.SubUnitID ,1) UnitName,
	   CAST (D.GoodsQuantity AS FLOAT )GoodsQuantity,
	   CAST (D.SubUnitQuantity AS FLOAT )SubUnitQuantity,
	   CAST (b.SubUnitQuantity AS FLOAT )BaskulSubUnitQuantity,
	   CAST (D.SubUnitQuantity AS FLOAT ) Margin,
	   CAST (D.SubUnitQuantity AS FLOAT )MarginPercent,
	   D.AcntCode,
	   CAST ('' AS VARCHAR(200)) AS AcntName, 
	   CAST ('' AS VARCHAR(2000)) AS DocDesc,
	   CAST ('' AS VARCHAR(4000)) AS DocDesc2,
	   CAST (D.SubUnitQuantity AS FLOAT )Volume,
	   CAST (D.SubUnitQuantity AS FLOAT )GoodsWeight,
	   CAST (D.SubUnitQuantity AS FLOAT )MachineContent,
	   CAST (D.SubUnitQuantity AS FLOAT )MachineBurden	
INTO #tblBaskul
FROM inv.tblStorageDocsDtl D
LEFT JOIN inv.tblBaskulSalesDtl b ON D.BaseProcessID = b.ProcessID 
								 AND D.BaseProcessNo = b.ProcessNo 
								 AND D.BaseFiscalYear = b.FiscalYear 
								 AND D.BaseSerialNo = b.SerialNo 
								 AND D.BaseDocRowNo = b.DocRowNo
LEFT JOIN inv.tblBaskulSalesHdr aa ON b.ProcessID = aa.ProcessID 
								  AND b.ProcessNo = aa.ProcessNo 
								  AND b.FiscalYear = aa.FiscalYear 
								  AND b.SerialNo=aa.SerialNo 
WHERE 1=0

set @StrSelect = ' 
	INSERT INTO #tblBaskul
	SELECT D.ProcessID,
		   D.ProcessNo,
		   D.FiscalYear,
		   D.SerialNo,
		   D.DocRowNo,
		   D.DocDate,
		   b.ProcessID BaskulProcessID,
		   b.ProcessNo BaskulProcessNo,
		   b.FiscalYear BaskulFiscalYear,
		   b.SerialNo BaskulSerialNo,
		   b.DocRowNo BaskulDocRowNo,
		   aa.DocDate BaskulDocDate,
		   D.GoodsID,
		   [pub].[funGetGoodsName] (D.GoodsID, 1) GetGoodsName,
		   D.SubUnitID,
		   [inv].[funGetUnitName] (D.SubUnitID, 1) UnitName,
		   CAST (D.GoodsQuantity AS FLOAT )GoodsQuantity,
		   CASE WHEN '+str(@Inv_BaskulDocsType)+' = 2 THEN D.GoodsQuantity * GoodsWeight / '+str(@WeightNumberDivision)+' ELSE CAST (D.SubUnitQuantity AS FLOAT ) END SubUnitQuantity,
		   CAST (b.SubUnitQuantity AS FLOAT )BaskulSubUnitQuantity,
		   0,
		   0,
		   D.AcntCode,
		   pub.GetCodeName (D.AcntCode, 1) as AcntName, 
		   h.DocDesc, 
		   h.DocDesc2,
		   GoodsLength * GoodsWidth * GoodsHeight * GoodsQuantity Volume,
		   GoodsWeight * GoodsQuantity GoodsWeight,
		   MachineContent,
		   MachineBurden
	FROM inv.tblStorageDocsHdr h
	INNER JOIN inv.tblStorageDocsDtl D ON h.ProcessID = D.ProcessID 
									  AND h.ProcessNo = D.ProcessNo 
									  AND h.FiscalYear = D.FiscalYear 
									  AND h.SerialNo=D.SerialNo 
	LEFT JOIN inv.tblBaskulSalesDtl b ON b.BaseProcessID = D.ProcessID 
									 AND b.BaseProcessNo = D.ProcessNo 
									 AND b.BaseFiscalYear = D.FiscalYear 
									 AND b.BaseSerialNo = D.SerialNo 
									 AND b.GoodsID = D.GoodsID 
									 --AND b.BaseDocRowNo=D.DocRowNo
	LEFT JOIN inv.tblBaskulSalesHdr aa ON b.ProcessID = aa.ProcessID 
									  AND b.ProcessNo = aa.ProcessNo 
									  AND b.FiscalYear = aa.FiscalYear 
									  AND b.SerialNo = aa.SerialNo 
	INNER JOIN inv.tblGoods g ON D.GoodsID = g.GoodsID
	LEFT JOIN pub.tblDrivers d ON d.DriverID = h.DriverID
	WHERE ' + @StrWhere2 +' '

	PRINT @StrSelect
	EXEC sp_executesql @StrSelect;
	
	UPDATE  #tblBaskul
	   SET Margin = SubUnitQuantity - BaskulSubUnitQuantity,
	   	   MarginPercent = ROUND (100 - BaskulSubUnitQuantity * 100 / SubUnitQuantity, 3)

	SELECT * FROM #tblBaskul
END 

IF @CallType=2
	BEGIN
		SET @ProcessID		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
		SET @StrGoods		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @FiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
		SET @SerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
		SET @FiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
		SET @SerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 		
		SET @BFiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
		SET @BSerialNoFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SET @BFiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
		SET @BSerialNoTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
		
		SET @DateFR			= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
		SET @DateTO			= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
		SET @BDateFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
		SET @BDateTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 	
		SET @EqualQty		= LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 	
			

		SET @StrWhere = ' D.ProcessID = '+ str(@ProcessID)
		IF @StrGoods <> ''
			SET @StrWhere = @StrWhere + @StrGoods

		IF @FiscalYearFR > 0
			SET @StrWhere = @StrWhere + ' AND D.FiscalYear >= ' +str(@FiscalYearFR)
		IF @SerialNoFR > 0
			SET @StrWhere = @StrWhere + ' AND D.SerialNo >= ' +str(@SerialNoFR)
		IF @FiscalYearTO > 0
			SET @StrWhere = @StrWhere + ' AND D.FiscalYear <= ' +str(@FiscalYearTO)
		IF @SerialNoTO > 0
			SET @StrWhere = @StrWhere + ' AND D.SerialNo <= ' +str(@SerialNoTO)
		IF @DateFR <> ''
			SET @StrWhere = @StrWhere + ' AND D.DocDate	>= ''' + @DateFR +''''
		IF @DateTO <> ''
			SET @StrWhere = @StrWhere + ' AND D.DocDate	<= ''' + @DateTO +''''

	
		IF @BFiscalYearFR > 0
			SET @StrWhere = @StrWhere + ' AND b.FiscalYear>=' +str(@BFiscalYearFR)
		IF @BSerialNoFR > 0
			SET @StrWhere = @StrWhere+ ' AND b.SerialNo >=' +str(@BSerialNoFR)
		IF @BFiscalYearTO > 0
			SET @StrWhere =@StrWhere + ' AND b.FiscalYear <= ' +str(@BFiscalYearTO)
		IF @BSerialNoTO > 0
			SET @StrWhere = @StrWhere + ' AND b.SerialNo <= ' +str(@BSerialNoTO)	
		IF @BDateFR <> ''
			SET @StrWhere = @StrWhere + ' AND aa.DocDate >= ''' + @BDateFR +''''
		IF @BDateTO <> ''
			SET @StrWhere = @StrWhere + ' AND aa.DocDate <= ''' + @BDateTO +''''

		SET @StrWhere2 = @StrWhere
	IF @EqualQty=1
	BEGIN
		SET @StrWhere = @StrWhere + ' AND D.SubUnitQuantity = b.SubUnitQuantity'
		SET @StrWhere2 = @StrWhere2 + ' AND (( '+str(@Inv_BaskulDocsType)+' = 2  
										AND D.GoodsQuantity * GoodsWeight / '+str(@WeightNumberDivision)+' = b.SubUnitQuantity) OR ('+str(@Inv_BaskulDocsType)+' <> 2 AND D.SubUnitQuantity = b.SubUnitQuantity))'
	END 
	IF @EqualQty=2
	BEGIN
		SET @StrWhere = @StrWhere + ' AND D.SubUnitQuantity	<> b.SubUnitQuantity'
		SET @StrWhere2 = @StrWhere2 + ' AND (( '+str(@Inv_BaskulDocsType)+' = 2 
										AND D.GoodsQuantity * GoodsWeight / '+str(@WeightNumberDivision)+' <> b.SubUnitQuantity) OR ('+str(@Inv_BaskulDocsType)+' <> 2 AND D.SubUnitQuantity <> b.SubUnitQuantity))'
	END
	
	SELECT D.ProcessID,
		   D.ProcessNo,
		   D.FiscalYear,
		   D.SerialNo,
		   D.DocDate,
		   b.ProcessID BaskulProcessID,
		   b.ProcessNo BaskulProcessNo,
		   b.FiscalYear BaskulFiscalYear,
		   b.SerialNo BaskulSerialNo,
		   aa.DocDate BaskulDocDate,
		   CAST (D.GoodsQuantity AS FLOAT ) GoodsQuantity,
		   CAST (D.SubUnitQuantity AS FLOAT ) SubUnitQuantity,
		   CAST (b.SubUnitQuantity AS FLOAT ) BaskulSubUnitQuantity,
		   CAST (D.SubUnitQuantity AS FLOAT ) Margin,
		   CAST (D.SubUnitQuantity AS FLOAT ) MarginPercent,
		   D.AcntCode, 
		   CAST ('' AS VARCHAR(200)) AS AcntName, 
		   CAST ('' AS VARCHAR(2000)) AS DocDesc,
		   CAST ('' AS VARCHAR(4000)) AS DocDesc2,
		   CAST (D.SubUnitQuantity AS FLOAT ) Volume,
		   CAST (D.SubUnitQuantity AS FLOAT ) GoodsWeight,
		   CAST (D.SubUnitQuantity AS FLOAT ) MachineContent,
		   CAST (D.SubUnitQuantity AS FLOAT ) MachineBurden	
	INTO #tblBaskulAll
	FROM inv.tblStorageDocsDtl D
	LEFT JOIN inv.tblBaskulSalesDtl b ON b.BaseProcessID = D.ProcessID 
									 AND b.BaseProcessNo = D.ProcessNo 
									 AND b.BaseFiscalYear = D.FiscalYear 
									 AND b.BaseSerialNo = D.SerialNo 
									 AND b.GoodsID = D.GoodsID 
									 --and b.BaseDocRowNo=D.DocRowNo
	LEFT JOIN inv.tblBaskulSalesHdr aa ON b.ProcessID = aa.ProcessID 
									  AND b.ProcessNo = aa.ProcessNo 
									  AND b.FiscalYear = aa.FiscalYear 
									  AND b.SerialNo = aa.SerialNo 
	WHERE 1=0

set @StrSelect = ' 
	INSERT INTO #tblBaskulAll
	SELECT D.ProcessID,
		   D.ProcessNo,
		   D.FiscalYear,
		   D.SerialNo,
		   D.DocDate,
		   b.ProcessID BaskulProcessID,
		   b.ProcessNo BaskulProcessNo,
		   b.FiscalYear BaskulFiscalYear,
		   b.SerialNo BaskulSerialNo,
		   aa.DocDate BaskulDocDate,
		   SUM(D.GoodsQuantity) GoodsQuantity,
		   SUM(CASE WHEN '+str(@Inv_BaskulDocsType)+' = 2 THEN D.GoodsQuantity * GoodsWeight / '+str(@WeightNumberDivision)+' ELSE CAST (D.SubUnitQuantity AS FLOAT ) END )SubUnitQuantity,
		   SUM(CAST(b.SubUnitQuantity AS FLOAT ))BaskulSubUnitQuantity,
		   0,
		   0,
		   D.AcntCode,
		   pub.GetCodeName(D.AcntCode,1) AS AcntName, 
		   h.DocDesc, 
		   h.DocDesc2,
		   SUM(GoodsLength * GoodsWidth * GoodsHeight * GoodsQuantity) Volume,
		   SUM(GoodsWeight * GoodsQuantity) GoodsWeight,
		   MachineContent,
		   MachineBurden
	FROM inv.tblStorageDocsHdr h
	INNER JOIN inv.tblStorageDocsDtl D ON h.ProcessID = D.ProcessID 
									  AND h.ProcessNo = D.ProcessNo 
									  AND h.FiscalYear = D.FiscalYear 
									  AND h.SerialNo = D.SerialNo 
	LEFT JOIN inv.tblBaskulSalesDtl b ON b.BaseProcessID = D.ProcessID 
									 AND b.BaseProcessNo = D.ProcessNo 
									 AND b.BaseFiscalYear = D.FiscalYear 
									 AND b.BaseSerialNo = D.SerialNo 
									 AND b.GoodsID = D.GoodsID 
									 AND b.BaseDocRowNo = D.DocRowNo
	LEFT JOIN inv.tblBaskulSalesHdr aa ON b.ProcessID = aa.ProcessID 
									  AND b.ProcessNo = aa.ProcessNo 
									  AND b.FiscalYear = aa.FiscalYear 
									  AND b.SerialNo = aa.SerialNo 
	INNER JOIN inv.tblGoods g ON D.GoodsID = g.GoodsID
	LEFT JOIN pub.tblDrivers d ON d.DriverID = h.DriverID
	WHERE ' + @StrWhere2 +' 
	GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocDate, b.ProcessID, b.ProcessNo, b.FiscalYear, b.SerialNo, aa.DocDate, D.AcntCode, h.DocDesc, h.DocDesc2, MachineContent, MachineBurden'

	PRINT @StrSelect
	EXEC sp_executesql @StrSelect;
	
	--Update  #tblBaskulAll 	set SubUnitQuantity=SubUnitQuantity/1000	, BaskulSubUnitQuantity=BaskulSubUnitQuantity/1000
	UPDATE #tblBaskulAll
	   SET Margin = SubUnitQuantity - BaskulSubUnitQuantity,
		   MarginPercent = ROUND(100 - BaskulSubUnitQuantity * 100/ SubUnitQuantity, 3),
		   Volume = Volume / @ContentNumberDivision

	SELECT * FROM #tblBaskulAll
END 
END 
GO
