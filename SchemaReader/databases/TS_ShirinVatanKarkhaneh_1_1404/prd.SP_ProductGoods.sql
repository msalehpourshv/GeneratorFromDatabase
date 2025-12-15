USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation date : 1390/07/27
-- Viewed By	 : 
-- Last Modified : 1390/08/03
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Product Goods Needed>
-- =================================================================
--EXEC [prd].[SP_ProductGoods] '101000244250000021', 5, '101', '1394/12/29', '', '000', N'1@15422@160001@0@1'
CREATE PROCEDURE [prd].[SP_ProductGoods]
	@ProductID			varchar(20),
	@ProductQuantity	float = 1,
	@StoreID			varchar(20) = null,
	@DocDate			char(10) = null,
	@DateTo				char(10) = null,
	@RepOptions			varchar(10) = '00',
	@RepInfo			nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare	@LangID		char(1);
declare	@SessionNo	int; -- برای حالت کدهای انتخابی
declare	@ReportID	int; -- برای حالت کدهای انتخابی

declare @StrSelect	nvarchar(4000);
declare @StrWhere	nvarchar(2000);

declare	@XProductID	varchar(20);
declare	@XGoodsID	varchar(20);
declare	@XQuantity	float;
declare	@AvailQty	float;
declare	@HasChild	bit;
declare	@Level		varchar(255);
declare	@FStoreID	varchar(20);

declare	@FirstLayer bit;
declare	@ShowPrice	bit;
BEGIN 
	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '1100';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @FirstLayer	= Substring(@RepOptions, 1, 1);
	set @ShowPrice	= Substring(@RepOptions, 2, 1);

	set @XProductID = @ProductID;
	set @XQuantity	= @ProductQuantity;
	set @Level = '  1';
	
	-- جدول موجودی کالاها - موقت
	CREATE TABLE #tbl_PrdProductNeedsOneStock_BalanceTemp
	(
		GoodsID    VarChar(20) COLLATE Arabic_CS_AS  Not Null,
		Quantity   Real Not Null,
		StoreID   VarChar(20) COLLATE Arabic_CS_AS   Null
	)
	-- جدول موجودی کالاها - دائم
	CREATE TABLE #tbl_PrdProductNeedsOneStock_BalanceMain
	(
		GoodsID    VarChar(20) COLLATE Arabic_CS_AS  Not Null,
		Quantity   Real Not Null,
		StoreID    VarChar(20) COLLATE Arabic_CS_AS  Null
	)
	-- جدول نتیجه
	CREATE TABLE #tbl_PrdProductNeedsOneStock_Result
	(
		ProductID	varchar(20) COLLATE Arabic_CS_AS  Not Null, 
		GoodsID		varchar(20) COLLATE Arabic_CS_AS  Not Null, 
		StoreID		varchar(20) COLLATE Arabic_CS_AS  Null, 
		ReqQty		float Not Null,
		LackQty		float Not Null,
		Balance		float Not Null,
		IsLeaf		bit,
		[Level]		varchar(255)
	)
	-- جدول محصول - کالا
	CREATE TABLE #tbl_PrdProductNeedsOneStock_Requests
	(
		ProductID	VarChar(20) COLLATE Arabic_CS_AS Not Null,
		GoodsID		VarChar(20) COLLATE Arabic_CS_AS Not Null,
		StoreID		VarChar(20) COLLATE Arabic_CS_AS Null,
		GoodsQty	Real Not Null,
		[Level]		varchar(255)
	)
	---------------------------------------------------------------------------
	-- fill goods stock table -------------------------------------------------
	set @StrWhere = '(D.GoodsID = G.GoodsID)'

	if (@StoreID is not null)
		set @StrWhere = @StrWhere + ' and (D.StoreID = ''' + @StoreID + ''')'
	if (@DateTo is not null)
		set @StrWhere = @StrWhere + ' and (D.DocDate <= ''' + @DateTo + ''')'

	set @StrSelect = '
	INSERT	INTO #tbl_PrdProductNeedsOneStock_BalanceTemp(GoodsID, Quantity, StoreID)
	SELECT	DISTINCT G.GoodsID, 
			(
				SELECT	IsNull(Sum(D.GoodsQuantity * D.EnterKind), 0)
				FROM    inv.tblStorageDocsDtl D
				WHERE	(' + @StrWhere + ')
			) as Quantity,
			(
				SELECT Distinct IsNull(H.DefaultStoreID, '''')
				FROM    prd.tblFormulasHdr H
				WHERE	(H.ProductID = G.GoodsID) And IsDefault = 1
			) as StoreID		
				
	FROM	(SELECT DISTINCT * From (SELECT DISTINCT GoodsID FROM inv.tblStorageDocsDtl
			 UNION ALL
			 SELECT DISTINCT GoodsID FROM prd.tblFormulasDtl
			 UNION ALL
			 SELECT DISTINCT ProductID FROM prd.tblFormulasDtl
			 ) A) G '

	print @StrSelect;
	exec sp_executesql @StrSelect;

	INSERT	INTO #tbl_PrdProductNeedsOneStock_BalanceMain
	SELECT	* 
	FROM	#tbl_PrdProductNeedsOneStock_BalanceTemp
	---------------------------------------------------------------------------
	
	SELECT @FStoreID = DefaultStoreID
	FROM   prd.tblFormulasHdr
	WHERE  ProductID = @XProductID

	-- کرسر برای حرکت در جدول کالاهای مورد نیاز
	DECLARE CRS_Goods CURSOR FOR							
       SELECT ProductID, GoodsID, GoodsQty, [Level]
       FROM   #tbl_PrdProductNeedsOneStock_Requests
	--------------------------------------------------------
	-- Append Goods Leafs from Current Product -------------
	INSERT	INTO #tbl_PrdProductNeedsOneStock_Requests(ProductID, GoodsID, GoodsQty, [Level], StoreID)
	SELECT	FH.ProductID, FD.GoodsID, (@XQuantity * FD.GoodsQuantity / FH.ProductCount), 
			STR(FD.DocRowNo, 3) As [Level], FH.DefaultStoreID
	FROM	prd.tblFormulasDtl FD 
				INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
	WHERE	(FH.IsDefault = 1) AND (FH.ProductID = @XProductID)

	DECLARE @intDefaultFormulaNo Int;
	SELECT	@intDefaultFormulaNo = FH.SerialNo
	FROM	prd.tblFormulasDtl FD 
				INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
	WHERE	(FH.IsDefault = 1) AND (FH.ProductID = @XProductID)

	-- Read First Row from #tbl_PrdProductNeedsOneStock_Requests 
	OPEN  CRS_Goods
	FETCH NEXT FROM CRS_Goods INTO @XProductID, @XGoodsID, @XQuantity, @Level
	
	WHILE (@@FETCH_STATUS = 0) -- CRS_Goods
	BEGIN
		-- Get Available Quantity of Goods
		SELECT @AvailQty = sum(Quantity)
		FROM   #tbl_PrdProductNeedsOneStock_BalanceTemp
		WHERE  GoodsID = @XGoodsID
		
		-- Requested Quantity is more than available; Append Goods Leafs from Current Product
		-- تعداد کالای درخواستی بیشتر از تعداد موجود است. پس موادی از فرمول مورد نیاز است
		If (@XQuantity > @AvailQty)
		BEGIN
			INSERT	INTO #tbl_PrdProductNeedsOneStock_Requests(ProductID, GoodsID, GoodsQty, [Level], StoreID)
			SELECT	FH.ProductID, FD.GoodsID, ((@XQuantity - @AvailQty) * FD.GoodsQuantity / FH.ProductCount), 
					@Level + STR(FD.DocRowNo, 3), FH.DefaultStoreID
			FROM	prd.tblFormulasDtl FD 
						INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
			WHERE	(FH.SerialNo = @intDefaultFormulaNo) AND (FH.ProductID = @XGoodsID)


			-- Check whether inserted any row (is leaf or not)
			If (@@RowCount = 0)
				-- (انتهای درخت فرمول (برگ
				SET @HasChild = 0
			Else 
				-- فرمول هنوز برگ دارد
				SET @HasChild = 1
				
			If (@FirstLayer = 1)  -- Only First Layer Must Returned
			BEGIN
				-- فقط سطح اول مورد نیاز است
				If (len(@Level) = 3) -- Current Record is in First Layer
				BEGIN 
					update #tbl_PrdProductNeedsOneStock_Result
					set ReqQty = ReqQty + @XQuantity, LackQty = LackQty + (@XQuantity - @AvailQty)
					where (ProductID = @XProductID) and (GoodsID = @XGoodsID)
					
					if (@@RowCount = 0)
						-- سطح اول فرمول تولید
						INSERT INTO #tbl_PrdProductNeedsOneStock_Result(ProductID, GoodsID, ReqQty, LackQty, Balance, IsLeaf, [Level], StoreID)
						VALUES (@XProductID, @XGoodsID, @XQuantity, @XQuantity - @AvailQty, @AvailQty, 1, @Level, @FStoreID)
				END
			END
			Else -- All records of Tree is needed
			BEGIN
				-- تمامی سطوح مورد نیاز است
				update #tbl_PrdProductNeedsOneStock_Result
				set ReqQty = ReqQty + @XQuantity, LackQty = LackQty + (@XQuantity - @AvailQty)
				where (ProductID = @XProductID) and (GoodsID = @XGoodsID)
					
				if (@@RowCount = 0)
					INSERT INTO #tbl_PrdProductNeedsOneStock_Result(ProductID, GoodsID, ReqQty, LackQty, Balance, IsLeaf, [Level], StoreID)
					VALUES (@XProductID, @XGoodsID, @XQuantity, @XQuantity - @AvailQty, @AvailQty, ~ @HasChild, @Level, @FStoreID)
			END

			-- Consume All Goods Stock; Remain 0  
			UPDATE	#tbl_PrdProductNeedsOneStock_BalanceTemp
			SET		Quantity = 0
			WHERE	GoodsID = @XGoodsID
		END
		Else -- Available quantity is enough for request; Consume from goods stock for amount of @XQuantity
		BEGIN 
			Update	#tbl_PrdProductNeedsOneStock_BalanceTemp
			SET		Quantity = Quantity - @XQuantity
			WHERE	GoodsID = @XGoodsID
		END

		-- Read Next Row FROM #tbl_PrdProductNeedsOneStock_Requests
		FETCH NEXT FROM CRS_Goods INTO @XProductID, @XGoodsID, @XQuantity, @Level
	END -- CRS_Goods

	CLOSE	CRS_Goods -- Refresh Cursor
	TRUNCATE TABLE #tbl_PrdProductNeedsOneStock_Requests

	DEALLOCATE  CRS_Goods
	
--  ========================================================================================
	update #tbl_PrdProductNeedsOneStock_Result
	set IsLeaf = 1
	where GoodsID not in (select ProductID from #tbl_PrdProductNeedsOneStock_Result)
	--------------------------------------------------------------------
	
	If @FStoreID = '' OR @FStoreID Is Null
		Set @FStoreID = @StoreID
	
	-- final select ----------------------------------------------------
	set @StrWhere = '(1=1)'

	set @StrSelect = '
	SELECT	R.ProductID, R.GoodsID, IsNull(R.StoreID,'''') StoreID, R.Level, 
			[pub].[funGetGoodsName](R.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') As GoodsName,
			[inv].[funGetGoodsRemain](Null, Null, Null, Null, Null, ''' + @FStoreID + ''', 
			R.GoodsID, Null, ''' + @DocDate + ''',0) GoodsRemain,
			[pub].[funGetGoodsUnitName] (R.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') UnitName, R.IsLeaf,
			R.ReqQty as RequestedQuantity,
			R.Balance as AvailableQuantity,
			R.LackQty as LackQuantity, 
			IsNull(S.Quantity, 0) as TotalAvailableQuantity, ' + 
			LTrim(RTrim(Str(@intDefaultFormulaNo))) + ' FormulaNo
	FROM	#tbl_PrdProductNeedsOneStock_Result R 
	LEFT  JOIN #tbl_PrdProductNeedsOneStock_BalanceMain S ON S.GoodsID = R.GoodsID
	WHERE ' + @StrWhere + '
	ORDER BY [Level], ProductID, GoodsID'
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
END
GO
