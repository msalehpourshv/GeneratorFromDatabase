USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1386/01/21
-- Viewed By	 : 
-- Last Modified : 1390/08/04
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Production Goods Needed>
-- =================================================================
Create PROCEDURE [prd].[RptPrd_ProductNeeds_All_StockEx]
	@ProductID			varchar(20) = null, -- not used
	@ProductQuantity	float = 0,          -- not used        
	@FormulaNo			int = 0,
	@SelectedStore		int = 0, 
	@SelectedGoods		int = 0, 
	@DateTo				char(10) = null,
	@StoreID			varchar(20) = null,
	@RepOptions			varchar(10) = '11001',  -- bit array options
	@RepInfo			nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportIDX	int; 
DECLARE @UserID		int;
DECLARE @RepInfoX	nvarchar(100);
DECLARE	@FirstLayer	bit; -- فقط لایه اول در کد کالا ظاهر شود یا نه؟

DECLARE @WhrStore	nvarchar(4000)
DECLARE @StrSelect	nvarchar(4000)
DECLARE @StrWhere	nvarchar(2000)
DECLARE @StrSelect2	nvarchar(2000)
DECLARE @StrCMR		nvarchar(2000)
DECLARE @StrBuy		nvarchar(2000)
DECLARE	@Level		varchar(255);
DECLARE	@XProductID	VarChar(20)
DECLARE	@XGoodsID	VarChar(20);
DECLARE	@StrLevel	VarChar(50);

DECLARE	@XQuantity	Real;
DECLARE	@AvailQty	float
DECLARE	@HasChild		Bit;
DECLARE	@IsFirstLayer	Bit;
DECLARE	@ShowPrice		bit; 
DECLARE	@ShowProds		bit; 

DECLARE @UnitPart	TINYINT

BEGIN 
	SET NOCOUNT ON;

	--================================== UnitPart
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
	--==================================
	
	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '11001';
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	
	set @ReportIDX	= 20101011
	set @RepInfoX	= '1@' + LTrim(Str(@SessionNo)) + '@' + LTrim(Str(@ReportIDX)) + '@' + LTrim(Str(@UserID))

	set @Level = '  1';
	set @FirstLayer	= Substring(@RepOptions, 1, 1);
	set @ShowPrice	= Substring(@RepOptions, 2, 1);
	set @ShowProds	= Substring(@RepOptions, 3, 1);

	-- جدول موجودی کالاها - موقت
	CREATE TABLE #tbl_PrdProductNeedsAllStock_BalanceTemp
	(
		GoodsID    VarChar(20) COLLATE Arabic_CS_AS  Not Null,
		Quantity   Real Not Null
	)
	-- جدول موجودی کالاها - دائم
	CREATE TABLE #tbl_PrdProductNeedsAllStock_BalanceMain
	(
		GoodsID    VarChar(20) COLLATE Arabic_CS_AS  Not Null,
		Quantity   Real Not Null
	)
	-- جدول نتیجه
	CREATE TABLE #tbl_PrdProductNeedsAllStock_Result
	(
		ProductID	varchar(20) COLLATE Arabic_CS_AS  Not Null, 
		GoodsID		varchar(20) COLLATE Arabic_CS_AS  Not Null, 
		ReqQty		float Not Null,
		LackQty		float Not Null,
		Balance		float Not Null,
		IsLeaf		bit,
		[Level]		varchar(255),
		ConstPrdText1  nVarchar(100),
		ConstPrdText2  nVarchar(100),
		ConstPrdText3  nVarchar(100),
		ConstPrdText4  nVarchar(100),
		ConstPrdText5  nVarchar(100)
	)
	-- جدول محصول - کالا
	CREATE TABLE #tbl_PrdProductNeedsAllStock_Requests
	(
		ProductID	VarChar(20) COLLATE Arabic_CS_AS Not Null,
		GoodsID		VarChar(20) COLLATE Arabic_CS_AS Not Null,
		GoodsQty	Real Not Null,
		[Level]		varchar(255)
	)
	-- جدول موقت برای آخرین قیمت کالاها
	create table #tbl_PrdProductNeedsAllStock_Prices
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		Amount	float not null
	);
	
	-- fill goods stock table ---
	TRUNCATE TABLE #tbl_PrdProductNeedsAllStock_BalanceTemp
	TRUNCATE TABLE #tbl_PrdProductNeedsAllStock_BalanceMain
	Declare @ConstPrdText1Name  nVarchar(100)
	Declare @ConstPrdText2Name  nVarchar(100)
	Declare @ConstPrdText3Name  nVarchar(100)
	Declare @ConstPrdText4Name  nVarchar(100)
	Declare @ConstPrdText5Name  nVarchar(100)
	
	
	SELECT @ConstPrdText1Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText1'
	SELECT @ConstPrdText2Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText2'
	SELECT @ConstPrdText3Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText3'
	SELECT @ConstPrdText4Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText4'
	SELECT @ConstPrdText5Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText5'
	
	
	set @StrWhere = '(D.GoodsID = G.GoodsID)'

	if (@StoreID is not null)
		set @StrWhere = @StrWhere + ' and (D.StoreID = ''' + @StoreID + ''')'
	if (@DateTo is not null)
		set @StrWhere = @StrWhere + ' and (D.DocDate <= ''' + @DateTo + ''')'
	if (@SelectedStore > 0)
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	set @StrSelect = '
	INSERT	INTO #tbl_PrdProductNeedsAllStock_BalanceTemp(GoodsID, Quantity)
	SELECT	G.GoodsID, 
			(
				SELECT	IsNull(Sum(D.GoodsQuantity * D.EnterKind), 0)
				FROM    inv.tblStorageDocsDtl D
				WHERE	(' + @StrWhere + ')
			) as Quantity
	FROM	inv.tblGoods G '

	print @StrSelect;
	exec sp_executesql @StrSelect;

	INSERT	INTO #tbl_PrdProductNeedsAllStock_BalanceMain
	SELECT	* 
	FROM	#tbl_PrdProductNeedsAllStock_BalanceTemp

	-- کرسر برای حرکت در جدول کالاهای مورد نیاز
	DECLARE CRS_Goods CURSOR FOR							
       SELECT ProductID, GoodsID, GoodsQty, [Level]
       FROM   #tbl_PrdProductNeedsAllStock_Requests
	--------------------------------------------------------
	-- Append Root Goods -----------------------------------
	if (@FormulaNo = 0)
		INSERT	INTO #tbl_PrdProductNeedsAllStock_Requests(ProductID, GoodsID, GoodsQty, [Level])
		SELECT	FH.ProductID, FD.GoodsID, isnull(sum(PRDS.Quantity * FD.GoodsQuantity / FH.ProductCount), 0) as GoodsQty, STR(FD.DocRowNo, 3) As [Level]
		FROM	prd.tblFormulasDtl FD 
					INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
					inner join
					(
						SELECT	ProductID, Quantity
						FROM	prd.tblProductSlc
						WHERE	(UserID = @UserID) AND (ReportID = @ReportID) AND (ObjectID = 1)
					) PRDS on PRDS.ProductID = FH.ProductID
		WHERE	(FH.IsDefault = 1) AND (FH.ProductID = PRDS.ProductID)
		GROUP BY FH.ProductID, FD.GoodsID, FD.DocRowNo
	else
		INSERT	INTO #tbl_PrdProductNeedsAllStock_Requests(ProductID, GoodsID, GoodsQty, [Level])
		SELECT	FH.ProductID, FD.GoodsID, isnull(sum(PRDS.Quantity * FD.GoodsQuantity / FH.ProductCount), 0) as GoodsQty, STR(FD.DocRowNo, 3) As [Level]
		FROM	prd.tblFormulasDtl FD 
					INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
					inner join
					(
						SELECT	ProductID, Quantity
						FROM	prd.tblProductSlc
						WHERE	(UserID = @UserID) AND (ReportID = @ReportID) AND (ObjectID = 1)
					) PRDS on PRDS.ProductID = FH.ProductID
		WHERE	(FH.SerialNo = @FormulaNo) AND (FH.ProductID = PRDS.ProductID)
		GROUP BY FH.ProductID, FD.GoodsID, FD.DocRowNo

	-- Read First Row from #tbl_PrdProductNeedsAllStock_Requests 
	OPEN  CRS_Goods
	FETCH NEXT FROM CRS_Goods INTO @XProductID, @XGoodsID, @XQuantity, @Level
	
	WHILE (@@FETCH_STATUS = 0) -- CRS_Goods
	BEGIN
		-- Get Available Quantity of Goods
		SELECT @AvailQty = sum(Quantity)
		FROM   #tbl_PrdProductNeedsAllStock_BalanceTemp
		WHERE  GoodsID = @XGoodsID
		
		-- Requested Quantity is more than available; Append Goods Leafs from Current Product
		-- تعداد کالای درخواستی بیشتر از تعداد موجود است. پس موادی از فرمول مورد نیاز است
		If (@XQuantity > @AvailQty)
		BEGIN
			if (@FormulaNo = 0)
				INSERT	INTO #tbl_PrdProductNeedsAllStock_Requests(ProductID, GoodsID, GoodsQty, [Level])
				SELECT	FH.ProductID, FD.GoodsID, ((@XQuantity - @AvailQty) * FD.GoodsQuantity / FH.ProductCount), @Level + STR(FD.DocRowNo, 3)
				FROM	prd.tblFormulasDtl FD 
							INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
				WHERE	(FH.IsDefault = 1) AND (FH.ProductID = @XGoodsID)
			else
				INSERT	INTO #tbl_PrdProductNeedsAllStock_Requests(ProductID, GoodsID, GoodsQty, [Level])
				SELECT	FH.ProductID, FD.GoodsID, ((@XQuantity - @AvailQty) * FD.GoodsQuantity / FH.ProductCount), @Level + STR(FD.DocRowNo, 3)
				FROM	prd.tblFormulasDtl FD 
							INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
				WHERE	(FH.SerialNo = @FormulaNo) AND (FH.ProductID = @XGoodsID)

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
					update #tbl_PrdProductNeedsAllStock_Result
					set ReqQty = ReqQty + @XQuantity, LackQty = LackQty + (@XQuantity - @AvailQty)
					where (ProductID = @XProductID) and (GoodsID = @XGoodsID)
					
					if (@@RowCount = 0)
						-- سطح اول فرمول تولید
						INSERT INTO #tbl_PrdProductNeedsAllStock_Result(ProductID, GoodsID, ReqQty, LackQty, Balance, IsLeaf, [Level])
						VALUES (@XProductID, @XGoodsID, @XQuantity, @XQuantity - @AvailQty, @AvailQty, 1, @Level)
				END
			END
			Else -- All records of Tree is needed
			BEGIN
				-- تمامی سطوح مورد نیاز است
				update #tbl_PrdProductNeedsAllStock_Result
				set ReqQty = ReqQty + @XQuantity, LackQty = LackQty + (@XQuantity - @AvailQty)
				where (ProductID = @XProductID) and (GoodsID = @XGoodsID)
					
				if (@@RowCount = 0)
					INSERT INTO #tbl_PrdProductNeedsAllStock_Result(ProductID, GoodsID, ReqQty, LackQty, Balance, IsLeaf, [Level])
					VALUES (@XProductID, @XGoodsID, @XQuantity, @XQuantity - @AvailQty, @AvailQty, ~ @HasChild, @Level)
			END

			-- Consume All Goods Stock; Remain 0  
			UPDATE	#tbl_PrdProductNeedsAllStock_BalanceTemp
			SET		Quantity = 0
			WHERE	GoodsID = @XGoodsID
		END
		Else -- Available quantity is enough for request; Consume from goods stock for amount of @XQuantity
		BEGIN 
			Update	#tbl_PrdProductNeedsAllStock_BalanceTemp
			SET		Quantity = Quantity - @XQuantity
			WHERE	GoodsID = @XGoodsID
		END

		-- Read Next Row FROM #tbl_PrdProductNeedsAllStock_Requests
		FETCH NEXT FROM CRS_Goods INTO @XProductID, @XGoodsID, @XQuantity, @Level
	END -- CRS_Goods

	CLOSE	CRS_Goods -- Refresh Cursor
	TRUNCATE TABLE #tbl_PrdProductNeedsAllStock_Requests

	DEALLOCATE  CRS_Goods
	
--  ========================================================================================
	update #tbl_PrdProductNeedsAllStock_Result
	set IsLeaf = 1
	where GoodsID not in (select ProductID from #tbl_PrdProductNeedsAllStock_Result)

	-- calc last amount
	if (@ShowPrice = 1)
	begin
		insert into #tbl_PrdProductNeedsAllStock_Prices
		select *
		from 
		(
			select distinct GoodsID, 
				(
					select top 1 GoodsAmount 
					from inv.tblStorageDocsDtl D 
					where (D.GoodsID = M.GoodsID) and (D.GoodsAmount <> 0) and (D.EnterKind = 1) 
					order by DocDate DESC, VolumeRowNo DESC
				) GoodsAmount
			from inv.tblStorageDocsDtl M
		) T 
		where GoodsAmount is not null
	end;
	
	if (@SelectedGoods > 0)
		set @StrWhere = pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'R.GoodsID')
	else
		set @StrWhere = '(1=1)'
		
	set @StrWhere = @StrWhere + ' and (IsLeaf = 1)'


	update #tbl_PrdProductNeedsAllStock_Result
	Set ConstPrdText1  =f.ConstPrdText1 ,
		ConstPrdText2  =f.ConstPrdText2 ,
		ConstPrdText3  =f.ConstPrdText3  ,
		ConstPrdText4  =f.ConstPrdText4  ,
		ConstPrdText5  =f.ConstPrdText5  
		from #tbl_PrdProductNeedsAllStock_Result a inner join prd.tblFormulasDtl f
		on a.ProductID=f.ProductID and a.GoodsID=f.GoodsID
		INNER JOIN prd.tblFormulasHdr H ON f.ProductID = H.ProductID AND f.SerialNo = H.SerialNo
		and H.IsDefault = 1 
		
		
	set @StrSelect = '
	SELECT	R.GoodsID, GD.GoodsName, U.UnitName, 
			sum(R.LackQty) LackQuantity, 
			isnull(S.Quantity, 0) AvailableQuantity, 
			isnull(P.Amount, 0) LastAmount
	,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5,
	'''+@ConstPrdText1Name +''' ConstPrdText1Name,'''+@ConstPrdText2Name +''' ConstPrdText2Name,'''+@ConstPrdText3Name +''' ConstPrdText3Name,
	'''+@ConstPrdText4Name +''' ConstPrdText4Name,'''+@ConstPrdText5Name +''' ConstPrdText5Name
	FROM	#tbl_PrdProductNeedsAllStock_Result R 

	INNER JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(R.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND G.PartNumber=' + LTRIM(STR(@UnitPart)) + '
	LEFT  JOIN #tbl_PrdProductNeedsAllStock_BalanceMain S ON S.GoodsID = R.GoodsID
	INNER JOIN inv.tblUnitsDtl U ON U.UnitID = G.UnitID
	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND GD.PartNumber=' + LTRIM(STR(@UnitPart)) + '
	LEFT JOIN #tbl_PrdProductNeedsAllStock_Prices P on P.GoodsID = R.GoodsID
	WHERE ' + @StrWhere + '
	GROUP BY R.GoodsID, GD.GoodsName, U.UnitName, S.Quantity, P.Amount,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5
	ORDER BY GoodsID'
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
END
GO
