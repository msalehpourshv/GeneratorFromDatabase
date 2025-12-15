USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1393/03/01
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : <Production Goods Needed>
-- =================================================================
CREATE PROCEDURE [sal].[RptSaleOrder_ProductNeeds]
	@ProcessNo		Int = 1,
	@FiscalYear		SmallInt = Null,
	@SerialNo		Int = Null,
	@SelectedStore	int = 0, 
	@SelectedGoods	int = 0, 
	@DateTo			char(10) = null,
	@StoreID		varchar(20) = null,
	@RepOptions		varchar(10) = '11001',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
	
WITH ENCRYPTION
AS

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
declare @UserID		int;
declare	@FirstLayer	bit; -- فقط لایه اول در کد کالا ظاهر شود یا نه؟
declare	@EndLayer	bit; -- فقط لایه آخر

declare @WhrStore	nvarchar(4000)
declare @StrSelect	nvarchar(4000)
declare @StrWhere	nvarchar(2000)

declare	@Level		varchar(255);
declare	@XProductID	VarChar(20)
declare	@XGoodsID	VarChar(20);
declare	@StrLevel	VarChar(50);
declare	@XQuantity	Real;
declare	@AvailQty	float
declare	@HasChild	Bit;
declare	@IsFirstLayer	Bit;
declare @FormulaNo as int;

BEGIN 
	
	SET NOCOUNT ON;

	--==============
	DECLARE @UnitPart TINYINT
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
	
	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '11001';
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;
	if (@SelectedStore	Is Null)	set @SelectedStore = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);

	set @Level = '  1';
	set @FirstLayer	= Substring(@RepOptions, 1, 1);
	-- 2 is reserved
	set @EndLayer	= Substring(@RepOptions, 3, 1)

	-- جدول موجودی کالاها - موقت
	CREATE TABLE #tbl_PrdProductNeedsAllStock_BalanceTemp
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
		[Level]		varchar(255)
	)
	-- جدول محصول - کالا
	CREATE TABLE #tbl_PrdProductNeedsAllStock_Requests
	(
		ProductID	VarChar(20) COLLATE Arabic_CS_AS Not Null,
		GoodsID		VarChar(20) COLLATE Arabic_CS_AS Not Null,
		GoodsQty	float Not Null,
		FormulaNo	int  Not Null,
		[Level]		varchar(255)
	)
	
	-- fill goods stock table ---
	TRUNCATE TABLE #tbl_PrdProductNeedsAllStock_BalanceTemp

	set @StrWhere = '(D.GoodsID = G.GoodsID)'

	if (@StoreID IS NOT NULL)
		set @StrWhere = @StrWhere + ' and (D.StoreID = ''' + @StoreID + ''')'

	if (@DateTo IS NOT NULL)
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

	-- کرسر برای حرکت در جدول کالاهای مورد نیاز
	DECLARE CRS_Goods CURSOR FOR							
       SELECT ProductID, GoodsID, GoodsQty, FormulaNo, [Level]
       FROM   #tbl_PrdProductNeedsAllStock_Requests
	--------------------------------------------------------
	-- Append Root Goods -----------------------------------
	INSERT	INTO #tbl_PrdProductNeedsAllStock_Requests(ProductID, GoodsID, GoodsQty, FormulaNo, [Level])
	SELECT	FH.ProductID, FD.GoodsID, 
				isnull(sum(PO.GoodsQuantity * FD.GoodsQuantity / FH.ProductCount), 0) as GoodsQty, 
				FH.SerialNo,
				str(FD.DocRowNo, 3) As [Level]
	FROM	prd.tblFormulasDtl FD 
				inner join prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
				inner join
				(
					SELECT	GoodsID, GoodsQuantity
					FROM	sal.tblSaleOrderDtl
					WHERE	(ProcessID = 180) and (ProcessNo = @ProcessNo) and (FiscalYear = LTrim(RTrim(Str(@FiscalYear)))) and (SerialNo = @SerialNo)
				) PO on PO.GoodsID = FH.ProductID
	WHERE	(FH.ProductID = PO.GoodsID) and ((FH.IsDefault = 1))
	GROUP BY FH.ProductID, FD.GoodsID, FD.DocRowNo, FH.SerialNo

	-- Read First Row from #tbl_PrdProductNeedsAllStock_Requests 
	OPEN  CRS_Goods
	FETCH NEXT FROM CRS_Goods INTO @XProductID, @XGoodsID, @XQuantity, @FormulaNo, @Level
	
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
			INSERT	INTO #tbl_PrdProductNeedsAllStock_Requests(ProductID, GoodsID, GoodsQty, FormulaNo, [Level])
			SELECT	FH.ProductID, FD.GoodsID, 
					((@XQuantity - @AvailQty) * FD.GoodsQuantity / FH.ProductCount), 
					@FormulaNo,
					@Level + str(FD.DocRowNo, 3)
			FROM	prd.tblFormulasDtl FD 
						INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
			WHERE	(FH.ProductID = @XGoodsID) and ((@FormulaNo = 0 and FH.IsDefault = 1) or (@FormulaNo <> 0 and FH.SerialNo = @FormulaNo))

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
		FETCH NEXT FROM CRS_Goods INTO @XProductID, @XGoodsID, @XQuantity, @FormulaNo, @Level
		
		
	END -- CRS_Goods

	CLOSE	CRS_Goods -- Refresh Cursor
	TRUNCATE TABLE #tbl_PrdProductNeedsAllStock_Requests

	DEALLOCATE  CRS_Goods
	
--  ========================================================================================
	update #tbl_PrdProductNeedsAllStock_Result
	set IsLeaf = 1
	where GoodsID not in (select ProductID from #tbl_PrdProductNeedsAllStock_Result)

	if (@SelectedGoods > 0)
		set @StrWhere = pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'R.GoodsID')
	else
		set @StrWhere = '(1=1)'
		
	if (@EndLayer = 1)
	begin
		set @StrLevel = 'cast(0 as varchar(255)) as Level'
		set @StrWhere = @StrWhere + ' and (IsLeaf = 1)'
	end
	else
	begin
		set @StrLevel = 'R.Level'
	end;
		
	set @StrSelect = '
	SELECT	R.ProductID, R.GoodsID, ' + @StrLevel + ', 
			[pub].[funGetGoodsName](R.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		    IsNull([inv].[FunGetGoodsBarCode] (R.GoodsID), '''') BarCode, U.UnitName, R.IsLeaf,
			R.ReqQty  as RequestedQuantity,
			R.Balance as AvailableQuantity,
			R.LackQty as LackQuantity
	FROM	#tbl_PrdProductNeedsAllStock_Result R 
	INNER JOIN inv.tblGoods G ON G.GoodsID=SUBSTRING(R.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	INNER JOIN inv.tblUnitsDtl U ON U.UnitID = G.UnitID
	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(R.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	WHERE ' + @StrWhere + '
	ORDER BY [Level], ProductID, GoodsID'
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
END
GO
