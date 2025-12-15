USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/08/16
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : <Production Goods Needed>
-- =================================================================
Create PROCEDURE [prd].[RptPrd_ProductNeeds_All_StockPO]
	@ProcSet		varchar(20),
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
declare	@ReportIDX	int; 
declare @UserID		int;
declare @RepInfoX	nvarchar(100) 
declare	@FirstLayer	bit; -- فقط لایه اول در کد کالا ظاهر شود یا نه؟
declare	@EndLayer	bit; -- فقط لایه آخر

declare @WhrStore	nvarchar(4000)
declare @StrSelect	nvarchar(4000)
declare @StrWhere	nvarchar(2000)
declare @StrSelect2	nvarchar(2000)
declare @StrCMR		nvarchar(2000)
declare @StrBuy		nvarchar(2000)
declare	@Level		varchar(255);
declare	@XProductID	VarChar(20)
declare	@XGoodsID	VarChar(20);
declare	@StrLevel	VarChar(50);
declare	@XQuantity	Real;
declare	@AvailQty	float
declare	@HasChild		Bit;
declare	@IsFirstLayer	Bit;
declare	@ShowPln		bit; 
declare	@ShowCMR		bit; 
declare	@ShowPrice		bit; 
declare	@ShowProds		bit; 

declare @ProcessID as int;
declare @ProcessNo as int;
declare @FiscalYear as int;
declare @SerialNo as int;
declare @FormulaNo as int;
BEGIN 
	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '11001';
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;
	if (@SelectedStore	Is Null)	set @SelectedStore = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);

	SET @ProcessID	= pub.funSplitString(@ProcSet, '@', 1);
	SET @ProcessNo	= pub.funSplitString(@ProcSet, '@', 2);
	SET @FiscalYear	= pub.funSplitString(@ProcSet, '@', 3);
	SET @SerialNo	= pub.funSplitString(@ProcSet, '@', 4);
	
	set @ReportIDX	= 20101011
	set @RepInfoX	= '1@' + LTrim(Str(@SessionNo)) + '@' + LTrim(Str(@ReportIDX)) + '@' + LTrim(Str(@UserID))

	set @Level = '  1';
	set @FirstLayer	= Substring(@RepOptions, 1, 1);
	set @ShowPrice	= Substring(@RepOptions, 2, 1);
	set @ShowProds	= Substring(@RepOptions, 3, 1);

	if len(@RepOptions) > 3
		set @ShowPln= Substring(@RepOptions, 4, 1)
	else
		set @ShowPln= 0
		
	if len(@RepOptions) > 4
		set @ShowCMR= Substring(@RepOptions, 5, 1)
	else
		set @ShowCMR= 0

	if len(@RepOptions) > 5
		set @EndLayer= Substring(@RepOptions, 6, 1)
	else
		set @EndLayer= 0

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
	-- جدول موقت برای آخرین قیمت کالاها
	create table #tbl_PrdProductNeedsAllStock_Prices
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		Amount	float not null
	);
	-- جدول موقت سفارشات تولید
	CREATE TABLE #tbl_PrdProductNeedsAllStock_Reserved
	(
		GoodsID    VarChar(20) COLLATE Arabic_CS_AS  Not Null,
		Quantity   Real Not Null
	)
	
	-- fill goods stock table ---
	TRUNCATE TABLE #tbl_PrdProductNeedsAllStock_BalanceTemp
	TRUNCATE TABLE #tbl_PrdProductNeedsAllStock_BalanceMain

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
       SELECT ProductID, GoodsID, GoodsQty, FormulaNo, [Level]
       FROM   #tbl_PrdProductNeedsAllStock_Requests
	--------------------------------------------------------
	-- Append Root Goods -----------------------------------
	INSERT	INTO #tbl_PrdProductNeedsAllStock_Requests(ProductID, GoodsID, GoodsQty, FormulaNo, [Level])
	SELECT	FH.ProductID, FD.GoodsID, 
				isnull(sum(PO.ProductCount * FD.GoodsQuantity / FH.ProductCount), 0) as GoodsQty, 
				PO.FormulaNo,
				str(FD.DocRowNo, 3) As [Level]
	FROM	prd.tblFormulasDtl FD 
				inner join prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
				inner join
				(
					SELECT	ProductID, ProductCount, FormulaNo
					FROM	pln.tblProduceOrderDtl
					WHERE	(ProcessID = @ProcessID) and (ProcessNo = @ProcessNo) and (FiscalYear = @FiscalYear) and (SerialNo = @SerialNo)
				) PO on PO.ProductID = FH.ProductID
	WHERE	(FH.ProductID = PO.ProductID) and ((PO.FormulaNo = 0 and FH.IsDefault = 1) or (PO.FormulaNo <> 0 and FH.SerialNo = PO.FormulaNo))
	GROUP BY FH.ProductID, FD.GoodsID, FD.DocRowNo, PO.FormulaNo

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

	-- calc last amount
	if (@ShowPrice = 1)
	begin
		insert into #tbl_PrdProductNeedsAllStock_Prices
		select distinct GoodsID, 
				(
					select top 1 Amount 
					from pln.tblProduceAnalysisGoods D 
					where (D.GoodsID = M.GoodsID) and (M.ProcessID = D.ProcessID) and (M.ProcessNo = D.ProcessNo) and (M.FiscalYear = D.FiscalYear) and (M.SerialNo = D.SerialNo)
				) 
		from pln.tblProduceAnalysisGoods M
		where (M.ProcessID = @ProcessID) and (M.ProcessNo = @ProcessNo) and (M.FiscalYear = @FiscalYear) and (M.SerialNo = @SerialNo)
	end;
	
	-- calc reserved quantities
	if (@ShowPln = 1)
	begin
		create table #tbl_Outer_SumPO
		(
			GoodsID		varchar(20) collate arabic_cs_as not null,
			Quantity	float not null
		);

		create table #tbl_InnerPO
		(
			GoodsID		varchar(20) collate arabic_cs_as not null,
			Quantity	float not null,
			Balance		float not null,
			GoodsName	nvarchar(100) not null,
			UnitID		varchar(20) collate arabic_cs_as not null,
			UnitName	nvarchar(100) not null,
			SumCMR		float not null,
			SumBuy		float not null,
			LastAmount  float,
			SetPoint	float,
			ConstPrdText1		varchar(20) collate arabic_cs_as   null,
			ConstPrdText2		varchar(20) collate arabic_cs_as   null,
			ConstPrdText3		varchar(20) collate arabic_cs_as   null,
			ConstPrdText4		varchar(20) collate arabic_cs_as   null,
			ConstPrdText5		varchar(20) collate arabic_cs_as   null,
			ConstPrdText1Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText2Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText3Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText4Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText5Name		varchar(20) collate arabic_cs_as   null
		);

		create table #tbl_OuterPO
		(
			GoodsID		varchar(20) collate arabic_cs_as not null,
			Quantity	float null,
			Balance		float not null,
			GoodsName	nvarchar(100) not null,
			UnitID		varchar(20) collate arabic_cs_as not null,
			UnitName	nvarchar(100) not null,
			SumCMR		float not null,
			SumBuy		float not null,
			LastAmount  float,
			SetPoint	float,
			ConstPrdText1		varchar(20) collate arabic_cs_as   null,
			ConstPrdText2		varchar(20) collate arabic_cs_as   null,
			ConstPrdText3		varchar(20) collate arabic_cs_as   null,
			ConstPrdText4		varchar(20) collate arabic_cs_as   null,
			ConstPrdText5		varchar(20) collate arabic_cs_as   null,
			ConstPrdText1Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText2Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText3Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText4Name		varchar(20) collate arabic_cs_as   null,
			ConstPrdText5Name		varchar(20) collate arabic_cs_as   null
		);

		delete from prd.tblProductSlc 
		where (UserID = @UserID) and (ReportID = @ReportIDX) and (ObjectID = 1)		

        insert into prd.tblProductSlc(ProductID, UserID, ReportID, ObjectID, Quantity)
        select ProductID, @UserID, @ReportIDX, 1, ProductCount as Quantity 
        from pln.tblProduceOrderHdr H
				inner join pln.tblProduceOrderDtl D on D.ProcessID = H.ProcessID and D.ProcessNo = H.ProcessNo and D.FiscalYear = H.FiscalYear and D.SerialNo = H.SerialNo
        where (H.ProcessID = @ProcessID) and (H.ProcessNo = @ProcessNo) and (H.FiscalYear = @FirstLayer) and (H.SerialNo < @FirstLayer) 
				and (H.ReserveGoods = 1) and (H.IsFinished = 0) 
	
		insert into #tbl_InnerPO--(GoodsID, Quantity, Balance, GoodsName, UnitID, UnitName, SumCMR, SumBuy, LastAmount,)
		exec [prd].[RptPrd_ProductGoods_All_Stock] '', 0, 0, 0, 0, @DateTo, null, 'GoodsID', '01000', @RepInfoX
	
		print 1

		insert into prd.tblProductSlc(ProductID, UserID, ReportID, ObjectID, Quantity)
		select A.GoodsID, @UserID, @ReportIDX, 1, A.Quantity
		from #tbl_InnerPO A

		insert into #tbl_OuterPO
		exec [prd].[RptPrd_ProductGoods_All_Stock] '', 0, 0, 0, 0, @DateTo, null, 'GoodsID', '10100', @RepInfoX

		insert into #tbl_Outer_SumPO
		select GoodsID, Sum(Quantity) Quantity
		from #tbl_OuterPO
		group by GoodsID
		except 
		select GoodsID, Sum(GoodsQuantity) as Quantity
		from inv.tblStorageDocsDtl
		where ProcessID = 120 and BaseProcessID = 600
		group by GoodsID

		insert into #tbl_PrdProductNeedsAllStock_Reserved (GoodsID, Quantity)
		select GoodsID, isnull(Quantity, 0)
		from #tbl_Outer_SumPO 
	end;
	
	if (@SelectedGoods > 0)
		set @StrWhere = pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'R.GoodsID')
	else
		set @StrWhere = '(1=1)'
		
	if (@ShowCMR = 1)
		set @StrCMR = 'isnull((select sum(ConfirmQuantity) from cmr.tblCMRDtl where GoodsID = R.GoodsID), 0)'
	else
		set @StrCMR = '0'

	if (@ShowCMR = 1)
		set @StrBuy = 'isnull((select sum(GoodsQuantity)   from inv.tblStorageDocsDtl where (ProcessID = 55) and (GoodsID = R.GoodsID) and (BaseProcessID = 150)), 0)'
	else
		set @StrBuy = '0'
		
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
	SELECT	R.ProductID, R.GoodsID, ' + @StrLevel + ', [pub].[funGetGoodsName](R.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') As GoodsName, 
			[pub].[funGetGoodsUnitName] (R.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') As UnitName, R.IsLeaf,
			R.ReqQty  as RequestedQuantity,
			R.Balance as AvailableQuantity,
			R.LackQty as LackQuantity, 
			isnull(S.Quantity, 0) as TotalAvailableQuantity, 
			isnull(V.Quantity, 0) as ReservedQuantity,
			isnull(P.Amount, 0)   as LastAmount,
			' + @StrCMR + ' SumCMR, ' + @StrBuy + ' SumBuy
	FROM	#tbl_PrdProductNeedsAllStock_Result R 
				left  JOIN #tbl_PrdProductNeedsAllStock_BalanceMain S ON S.GoodsID = R.GoodsID
				left  join #tbl_PrdProductNeedsAllStock_Prices P on P.GoodsID = R.GoodsID
				left  join #tbl_PrdProductNeedsAllStock_Reserved V on V.GoodsID = R.GoodsID
	WHERE ' + @StrWhere + '
	ORDER BY [Level], ProductID, GoodsID'
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
END
GO
