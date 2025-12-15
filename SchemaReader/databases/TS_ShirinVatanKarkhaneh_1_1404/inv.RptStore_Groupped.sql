USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1390/09/16
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش لیست برگه های انبار
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Groupped]
	@ProcessID			Int = 90,  -- default is sale
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			char(10) = Null,
	@DocDateTo			char(10) = Null,
	@SelectedGoods		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedStore2		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@GroupField1		VarChar(20) = 'StoreID', 
	@GroupField2		VarChar(20) = 'StoreID2', 
	@GroupField3		VarChar(20) = 'AcntCode', 
	@RepOptions			VarChar(30) = '1100011111', -- bit array options
	@RepInfo			NVarChar(100) = Null,
	@SortFields			NVarChar(100) = Null,
	@ExtraParams		NVarChar(200) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrQty			VarChar(1000);
DECLARE @StrPrc			VarChar(1000);
DECLARE @StrRetPID		VarChar(3);
DECLARE @StrPID		    VarChar(20);

DECLARE @ShowQuantity	bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		bit;  -- شامل ستون قیمت
DECLARE @DecReturn		bit;  -- کسر برگشتیها
DECLARE @UseAmount		bit;  -- Use Amount Filed Instead of Price
DECLARE @PID1	bit;
DECLARE @PID2	bit;
DECLARE @PID3	bit;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '1100011111';
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@ProcessID	Is Null)	SET @ProcessID = 0;
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 0;

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0;
	IF (@SelectedStore2 Is Null)	SET @SelectedStore2 = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;

	If (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ShowQuantity= Substring(@RepOptions, 1, 1)
	SET @ShowPrice	= Substring(@RepOptions, 2, 1)
	SET @DecReturn	= Substring(@RepOptions, 3, 1)
	SET @UseAmount	= Substring(@RepOptions, 4, 1)
	SET @PID1	= Substring(@RepOptions, 5, 1)
	SET @PID2	= Substring(@RepOptions, 6, 1)
	SET @PID3	= Substring(@RepOptions, 7, 1)

	if (@ProcessID = 90) 
		set @StrRetPID = '100'
	else if (@ProcessID = 55) 
		set @StrRetPID = '60'
	else
		set @StrRetPID = '0'
	
	if (@ProcessID = 70) or (@ProcessID = 80)
	begin	
		set @StrPID = '0';

		if (@PID1 = 1)
			set @StrPID = @StrPID + ',' + ltrim(str(@ProcessID));

		if (@PID2 = 1)
			if (@ProcessID = 70) 
				set @StrPID = @StrPID + ',82' 
			else
				set @StrPID = @StrPID + ',72' 
			
		if (@PID3 = 1)
			if (@ProcessID = 70) 
				set @StrPID = @StrPID + ',83' 
			else
				set @StrPID = @StrPID + ',73' 
	end
	else
		set @StrPID = ltrim(str(@ProcessID))
	---------------------------------------------------------
	-- Where Clause -----------------------------------------
	set @StrWhere = ' D.ProcessID in (' + @StrPID + ')'

	if (@ProcessNo Is Not Null) and (@ProcessNo <> 0)
		Set @StrWhere = @StrWhere + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	if (@DocDateFr Is Not Null) 
		set @StrWhere = @StrWhere + ' and (D.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo Is Not Null) 
		set @StrWhere = @StrWhere + ' and (D.DocDate <= ''' + @DocDateTo + ''')'

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	If (@SelectedStore2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	---------------------------------------------------------
	-- SELECT Clause ----------------------------------------
	DECLARE @StrPrice AS NVarChar(20);
	DECLARE @StrRetQty AS NVarChar(2000);
	DECLARE @StrRetPrc AS NVarChar(2000);

	DECLARE @strGoodsAmount as nvarchar(200) = 'GoodsAmount'
	IF @DocDateTo is not null and @DocDateTo <> ''
		SET @strGoodsAmount = LTRIM(inv.funGoodsAmount(@DocDateTo))

	IF (@UseAmount = 1)
		SET @StrPrice = @strGoodsAmount
	ELSE
		SET @StrPrice = 'GoodsPrice'

	set @StrRetQty = '0'
	set @StrRetPrc = '0'
	
	IF (@DecReturn = 1)
	BEGIN
		SET @StrRetQty = '
		(
			SELECT	IsNull(SUM(GoodsQuantity), 0)
			FROM	inv.tblStorageDocsDtl 
			WHERE	ProcessID = ' + @StrRetPID + ' AND 
					ProcessNo = ' + Str(@ProcessNo) + ' AND 
					BaseProcessID = D.ProcessID AND 
					BaseProcessNo = D.ProcessNo AND 
					BaseFiscalYear = D.FiscalYear AND 
					BaseSerialNo = D.SerialNo AND 
					BaseDocRowNo = D.DocRowNo
		)'
		SET @StrRetPrc = '
		(
			SELECT	IsNull(SUM(GoodsQuantity * ' + @StrPrice + '), 0)
			FROM	inv.tblStorageDocsDtl 
			WHERE	ProcessID = ' + @StrRetPID + ' AND 
					ProcessNo = ' + Str(@ProcessNo) + ' AND 
					BaseProcessID = D.ProcessID AND 
					BaseProcessNo = D.ProcessNo AND 
					BaseFiscalYear = D.FiscalYear AND 
					BaseSerialNo = D.SerialNo AND 
					BaseDocRowNo = D.DocRowNo
		)'
	END

	SET @StrSelect = '
	SELECT	D.StoreID, D.StoreID2, S1.StoreName, S2.StoreName AS StoreName2, 
			D.GoodsID, G.GoodsName, D.AcntCode, pub.GetCodeName(D.AcntCode, 1) AcntName,
			isnull(sum(D.GoodsQuantity), 0) SumQuantity, 
			isnull(sum(D.GoodsQuantity * D.' + @StrPrice + '), 0) SumPrice
	FROM	inv.tblStorageDocsDtl D 
				INNER JOIN inv.vwStorageDocsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
				LEFT  JOIN inv.tblGoodsDtl G ON G.GoodsID = D.GoodsID
				LEFT  JOIN inv.tblStoresDtl S1 ON S1.StoreID = D.StoreID 
				LEFT  JOIN inv.tblStoresDtl S2 ON S2.StoreID = D.StoreID2
	WHERE ' + @StrWhere + '
	GROUP BY D.StoreID, D.StoreID2, S1.StoreName, S2.StoreName, D.GoodsID, G.GoodsName, D.AcntCode'
	------------------------------------------------------------

	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + '
	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
