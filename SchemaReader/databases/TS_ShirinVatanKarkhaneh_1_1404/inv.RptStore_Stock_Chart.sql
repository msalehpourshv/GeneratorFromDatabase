USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/04/08
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : <Store Stock Chart>
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Stock_Chart]
	@DateFr			Char(10) = Null,
	@DateTo			Char(10) = Null,
	@SelectedGoods	Int = Null,
	@SelectedStore  Int = Null,
	@ColsPerPage	Int = 25,
	@RepOptions		NVarChar(500) = '11111101',
	@RepInfo		NVarChar(500) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrGroup	NVarChar(2000);
DECLARE @StrHaving	NVarChar(2000);

DECLARE @LangID			Char(2);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 

DECLARE @ShowPrice		Bit; -- نمایش قیمت
DECLARE @ShowPrim		Bit; -- شامل ستون اول دوره
DECLARE @ShowInput		Bit; -- شامل ستون ورود
DECLARE @ShowOutput		Bit; -- شامل ستون خروج
DECLARE @ZeroAmount		Bit; -- شامل سطرهای مبلغ صفر
DECLARE @ZeroQuantity	Bit; -- شامل سطرهای موجودی صفر
DECLARE @PhysAffect		Bit; -- تاثیر دادن P.A
DECLARE @PhysEffected	Bit; -- P.A
DECLARE @IsMultiplex	Bit; -- P.A

DECLARE @StrQtyPrim		NVarChar(200);
DECLARE @StrQtyInput	NVarChar(200);
DECLARE @StrQtyOutput	NVarChar(200);
DECLARE @StrQtyBalance	NVarChar(200);

DECLARE @StrPrcPrim		NVarChar(200);
DECLARE @StrPrcInput	NVarChar(200);
DECLARE @StrPrcOutput	NVarChar(200);
DECLARE @StrPrcBalance	NVarChar(200);

DECLARE @StrPrim		NVarChar(200);
DECLARE @StrInput		NVarChar(200);
DECLARE @StrOutput		NVarChar(200);
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables ----------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo	= '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '11111101'

	IF (@SelectedGoods Is Null)	SET @SelectedGoods = 0
	IF (@SelectedStore Is Null)	SET @SelectedStore = 0

	SET @ShowPrice		= Substring(@RepOptions, 1, 1)
	SET @ShowPrim		= Substring(@RepOptions, 2, 1)
	SET @ShowInput		= Substring(@RepOptions, 3, 1)
	SET @ShowOutput		= Substring(@RepOptions, 4, 1)
	SET @ZeroAmount		= Substring(@RepOptions, 5, 1)
	SET @ZeroQuantity	= Substring(@RepOptions, 6, 1)
	SET @PhysAffect		= Substring(@RepOptions, 7, 1)
	SET @PhysEffected	= Substring(@RepOptions, 8, 1)
	SET @IsMultiplex	= Substring(@RepOptions, 10, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	----------------------------------------------------------------------------

	-- Where Clause ------------------------------------------------------------
	SET @StrWhere = '(D.FiscalYear = ' + LTrim(RIGHT(db_name(), 4)) + ') And D.GoodsID IN (Select GoodsID From inv.tblGoods Where IsService = 0)';

	If (@PhysAffect = 1)
		If (@PhysEffected = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
		Else
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'

	If (@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DateTo + ''''

	If (@ZeroAmount = 0) 
		SET @StrWhere = @StrWhere + ' AND D.GoodsAmount <> 0 '

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	IF (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	----------------------------------------------------------------------------------

	DECLARE @strGoodsAmount as nvarchar(200) = 'GoodsAmount'
	IF @IsMultiplex = 'False'
		Set @strGoodsAmount = 'GoodsAmount'
	ELSE
		IF @DateTo is not null and @DateTo <> ''
			SET @strGoodsAmount = LTRIM(inv.funGoodsAmount(@DateTo))
	-- Select Clause -----------------------------------------------------------------------------------------
	IF (@DateFr Is Not Null) 
	BEGIN
		IF (@ShowPrim = 1)
		BEGIN
			SET @StrQtyPrim = 'SUM(CASE WHEN DocDate <  ''' + @DateFr + ''' THEN D.GoodsQuantity ELSE 0 END)'
			SET @StrPrcPrim = 'SUM(CASE WHEN DocDate <  ''' + @DateFr + ''' THEN D.GoodsQuantity * D.' + @strGoodsAmount + ' ELSE 0 END)'
		END
		ELSE
		BEGIN
			SET @StrQtyPrim = '0'
			SET @StrPrcPrim = '0'
		END

		IF (@ShowInput = 1)
		BEGIN
			SET @StrQtyInput = 'SUM(CASE WHEN DocDate >= ''' + @DateFr + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END)'
			SET @StrPrcInput = 'SUM(CASE WHEN DocDate >= ''' + @DateFr + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity * D.' + @strGoodsAmount + ' ELSE 0 END)'
		END
		ELSE
		BEGIN
			SET @StrQtyInput = '0'
			SET @StrPrcInput = '0'
		END

		IF (@ShowOutput = 1)
		BEGIN
			SET @StrQtyOutput = 'SUM(CASE WHEN DocDate >= ''' + @DateFr + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END)'
			SET @StrPrcOutput = 'SUM(CASE WHEN DocDate >= ''' + @DateFr + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity * D.' + @strGoodsAmount + ' ELSE 0 END)'
		END
		ELSE
		BEGIN
			SET @StrQtyOutput = '0'
			SET @StrPrcOutput = '0'
		END
	END
	ELSE -- No DateFr Filter
	BEGIN
		IF (@ShowPrim = 1)
		BEGIN
			SET @StrQtyPrim = 'SUM(CASE WHEN D.ProcessID = 50 THEN D.GoodsQuantity ELSE 0 END)'
			SET @StrPrcPrim = 'SUM(CASE WHEN D.ProcessID = 50 THEN D.GoodsQuantity * D.' + @strGoodsAmount + ' ELSE 0 END)'
		END
		ELSE
		BEGIN
			SET @StrQtyPrim = '0'
			SET @StrPrcPrim = '0'
		END

		IF (@ShowInput = 1)
		BEGIN
			SET @StrQtyInput = 'SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END)'
			SET @StrPrcInput = 'SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity * D.' + @strGoodsAmount + ' ELSE 0 END)'
		END
		ELSE
		BEGIN
			SET @StrQtyInput = '0'
			SET @StrPrcInput = '0'
		END

		IF (@ShowOutput = 1)
		BEGIN
			SET @StrQtyOutput = 'SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END)'
			SET @StrPrcOutput = 'SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity * D.' + @strGoodsAmount + ' ELSE 0 END)'
		END
		ELSE
		BEGIN
			SET @StrQtyOutput = '0'
			SET @StrPrcOutput = '0'
		END
	END

	SET @StrQtyBalance = 'SUM(D.GoodsQuantity * D.EnterKind)'
	SET @StrPrcBalance = 'SUM(D.GoodsQuantity * D.EnterKind * D.' + @strGoodsAmount + ')'

	SET @StrSelect = '
	DECLARE @MaxQtyPrim		float;
	DECLARE @MaxQtyInput	float;
	DECLARE @MaxQtyOutput	float;
	DECLARE @MaxQtyBalance	float;
	DECLARE @MaxPrcPrim		float;
	DECLARE @MaxPrcInput	float;
	DECLARE @MaxPrcOutput	float;
	DECLARE @MaxPrcBalance	float;

	CREATE TABLE #tbl_RptStore_Stock_Chart
	(
		GoodsID			VarChar(20) COLLATE Arabic_CS_AS,
		QuantityPrim	float,
		QuantityInput	float,
		QuantityOutput	float,
		QuantityBalance	float,
		PricePrim		float,
		PriceInput		float,
		PriceOutput		float,
		PriceBalance	float,
		MyGroup			Int
	);

	INSERT	INTO #tbl_RptStore_Stock_Chart
	SELECT	D.GoodsID, 
			' + @StrQtyPrim   + ' AS QuantityPrim,
			' + @StrQtyInput  + ' AS QuantityInput,
			' + @StrQtyOutput + ' AS QuantityOutput,
			' + @StrQtyBalance+ ' AS QuantityBalance,
			' + @StrPrcPrim   + ' AS PricePrim,
			' + @StrPrcInput  + ' AS PriceInput,
			' + @StrPrcOutput + ' AS PriceOutput,
			' + @StrPrcBalance+ ' AS PriceBalance,
			(Row_Number() Over ( ORDER BY D.GoodsID)) / ' + LTrim(Str(@ColsPerPage)) + ' MyGroup
	FROM	inv.tblStorageDocsDtl D
	WHERE	' + @StrWhere + '
	GROUP BY D.GoodsID '
	-------------------------------------------------------------------------------------------------------------

	-- Having Clause ------------------------------------------------------------------------------------------
	SET @StrHaving = '';

	IF (@ZeroQuantity = 0)
	BEGIN
		SET @StrHaving = 
		CASE WHEN (@DateFr Is Not Null) THEN '
		HAVING	SUM(CASE WHEN DocDate <  ''' + @DateFr  + ''' THEN D.GoodsQuantity ELSE 0 END) +
				SUM(CASE WHEN DocDate >= ''' + @DateFr  + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) -
				SUM(CASE WHEN DocDate >= ''' + @DateFr  + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) <> 0 '
		ELSE + '
		HAVING	SUM(CASE WHEN D.ProcessID =  50 THEN D.GoodsQuantity ELSE 0 END) +
				SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) -
				SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) <> 0 '
		END
	END
	-------------------------------------------------------------------------------------------------------------
	If (@ShowPrice = 1)
	SET @StrSelect = @StrSelect + ' 
	SELECT	@MaxQtyPrim	  = 0, 
			@MaxQtyInput  = 0, 
			@MaxQtyOutput = 0, 
			@MaxQtyBalance = 0, 
			@MaxPrcPrim   = Max(PricePrim), 
			@MaxPrcInput  = Max(PriceInput), 
			@MaxPrcOutput = Max(PriceOutput),
			@MaxPrcOutput = Max(PriceBalance) 
	FROM	#tbl_RptStore_Stock_Chart '
	ELSE
	SET @StrSelect = @StrSelect + ' 
	SELECT	@MaxQtyPrim	  = Max(QuantityPrim), 
			@MaxQtyInput  = Max(QuantityInput), 
			@MaxQtyOutput = Max(QuantityOutput), 
			@MaxQtyBalance = Max(QuantityBalance), 
			@MaxPrcPrim   = 0, 
			@MaxPrcInput  = 0, 
			@MaxPrcOutput = 0,
			@MaxPrcBalance = 0
	FROM	#tbl_RptStore_Stock_Chart; '
	-- Select ---------------------------------------------------------------------------------------------------
	SET @StrSelect = @StrSelect + ' 
	INSERT	INTO #tbl_RptStore_Stock_Chart
	SELECT	CHAR(9)+''ماکزیمم'', @MaxQtyPrim, @MaxPrcPrim, @MaxQtyInput, @MaxQtyBalance, @MaxPrcInput, @MaxQtyOutput, @MaxPrcOutput, @MaxPrcBalance, MyGroup
	FROM	#tbl_RptStore_Stock_Chart
	GROUP	BY MyGroup

	SELECT	C.*, case when (C.GoodsID=CHAR(9)+''ماکزیمم'') then CHAR(9)+''ماکزیمم'' else G.GoodsName end GoodsName
	FROM	#tbl_RptStore_Stock_Chart C
				left join inv.tblGoodsDtl G on G.GoodsID = C.GoodsID
	ORDER	BY MyGroup, GoodsID'
	------------------------------------------------------------

	-- Run -----------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
