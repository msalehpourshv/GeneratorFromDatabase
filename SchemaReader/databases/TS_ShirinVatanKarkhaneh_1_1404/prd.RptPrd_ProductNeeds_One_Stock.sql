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
Create  PROCEDURE [prd].[RptPrd_ProductNeeds_One_Stock]
	@ProductID			varchar(20),
	@ProductQuantity	float = 1,
	@FormulaNo			int = 0,
	@SelectedStore		int = 0,
	@SelectedGoods		int = 0,
	@DateTo				char(10) = null,
	@StoreID			varchar(20) = null,
	@RepOptions			varchar(10) = '00',
	@RepInfo			nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare	@LangID		char(1);
declare	@SessionNo	int; -- برای حالت کدهای انتخابی
declare	@ReportID	int; -- برای حالت کدهای انتخابی

declare @StrSelect	nvarchar(max);
declare @StrWhere	nvarchar(2000);
declare @strWhereLostGoods nvarchar(2000)='AND 1=1   ';
Declare @StrDate	NVarChar(2000);

declare	@XProductID	varchar(20);
declare	@XGoodsID	varchar(20);
declare	@XQuantity	float;
declare	@AvailQty	float;
declare	@HasChild	bit;
declare	@Level		varchar(255);

declare	@FirstLayer bit;
declare	@ShowPrice	bit;

declare @InProduucingGoods as char(1)  
declare @fromDate as char(10)
declare @toDate as char(10)

declare	@SelectedAcnt1	as	Int = Null -- کد واحد تولید
declare	@SelectedAcnt2	as	Int = Null -- کد واحد تولید
declare	@SelectedAcnt3	as	Int = Null -- کد واحد تولید
declare	@SelectedAcnt4	as	Int = Null -- کد واحد تولید
 

declare @strLostGoods as NVarchar(max)
declare @strLostGoodsQty as NVarchar(max)

DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		Bit;
declare @InProduucingQty	bit

BEGIN 
	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '1100';
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;
	if (@FormulaNo		Is Null)	set @FormulaNo = 0;

	SET @LangID				= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		= pub.funSplitString(@RepInfo, '@', 5);
	
	SET @InProduucingGoods	=  pub.funSplitString(@RepInfo, '@', 6);
	SET @fromDate			=  pub.funSplitString(@RepInfo, '@', 7);
	SET @toDate				=  pub.funSplitString(@RepInfo, '@', 8);	
	
	--SET @SelectedGoods		=  pub.funSplitString(@RepInfo, '@', 9);
	SET @SelectedAcnt1		=  pub.funSplitString(@RepInfo, '@', 10);
	SET @SelectedAcnt2		=  pub.funSplitString(@RepInfo, '@', 11);
	SET @SelectedAcnt3		=  pub.funSplitString(@RepInfo, '@', 12);
    SET @SelectedAcnt4		=  pub.funSplitString(@RepInfo, '@', 13);
    SET @InProduucingQty	=  pub.funSplitString(@RepInfo, '@', 14);
	

	SET @StrDate = ''


If (@fromDate <> '') OR (@toDate  <>'')
		If (@fromDate = @toDate)
			SET @StrDate = @StrDate + ' AND DocDate  = ''' + @fromDate + ''''
		Else 
		Begin
			If (@fromDate Is Not Null)
				SET @StrDate = @StrDate + ' AND DocDate >= ''' + @fromDate + ''''
			If (@toDate Is Not Null)
				SET @StrDate = @StrDate + ' AND DocDate <>'''' AND DocDate <= ''' + @toDate + ''''
		End

	set @FirstLayer	= Substring(@RepOptions, 1, 1);
	set @ShowPrice	= Substring(@RepOptions, 2, 1);
	

	set @XProductID = @ProductID;
	set @XQuantity	= @ProductQuantity;
	set @Level = '  1';
	
  
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = '0';
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = '0';
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = '0';
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = '0';
 
	If (@SelectedAcnt1 <> '0')
		SET @strWhereLostGoods = @strWhereLostGoods + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 <> '0')
		SET @strWhereLostGoods = @strWhereLostGoods + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 <> '0')
		SET @strWhereLostGoods = @strWhereLostGoods + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 <> '0')
		SET @strWhereLostGoods = @strWhereLostGoods + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	
	
	if (@InProduucingGoods='1') 
	begin
	set @strLostGoods='	,
			ISNULL((SELECT SUM(a.ProductCount-PrdQuantity) from (
		SELECT a.*,IsNull((prd.funMaxRetProduct(a.ProcessID, a.ProcessNo, a.FiscalYear, a.SerialNo, 1)),0) PrdQuantity
		FROM 
		(   SELECT a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.ProductID,a.ProductCount -ISNULL(PrdQuantity,0) ProductCount --+IsNull((prd.funMaxRetProduct(a.ProcessID, a.ProcessNo, a.FiscalYear, a.SerialNo, 0)),0) PrdQuantity
			FROM inv.tblStorageDocsHdr a 
			LEFT join 
			(SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,SUM(GoodsQuantity) PrdQuantity 
			 FROM inv.tblStorageDocsDtl WHERE  ProcessID=80 
			 GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
			) c
			ON a.ProcessID=c.BaseProcessID and a.ProcessNo=c.BaseProcessNo and a.FiscalYear=c.BaseFiscalYear AND a.SerialNo=c.BaseSerialNo
			where a.ProcessID=70  AND a.ProductID= R.GoodsID and ProductCount - ISNULL(PrdQuantity,0)>0
		) a
		)a WHERE a.ProductCount-PrdQuantity > 0),0) LostGoods
	   ,ISNULL((
		SELECT SUM((SndD.GoodsQuantity*(ProductCount-PrdQuantity))/ProductCount-ISNULL(gdsQuantity,0)) Remain
		FROM 
		(   SELECT a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.ProductID,a.ProductCount ,PrdQuantity
			FROM inv.tblStorageDocsHdr a 
			inner join 
			(SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,SUM(GoodsQuantity) PrdQuantity 
			 FROM inv.tblStorageDocsDtl WHERE  ProcessID=80 
			 GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
			) c
			ON a.ProcessID=c.BaseProcessID and a.ProcessNo=c.BaseProcessNo and a.FiscalYear=c.BaseFiscalYear AND a.SerialNo=c.BaseSerialNo
			where a.ProcessID=70 and ProductCount>PrdQuantity
		) SndH
		inner join inv.tblStorageDocsDtl SndD
		ON SndH.ProcessID=SndD.ProcessID and SndH.ProcessNo=SndD.ProcessNo and SndH.FiscalYear=SndD.FiscalYear and SndH.SerialNo=SndD.SerialNo
		LEFT JOIN (
			 SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID,SUM(GoodsQuantity) gdsQuantity 
			 FROM inv.tblStorageDocsDtl 
			 WHERE  ProcessID=75 
			 GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID
			 ) SndRet
		on SndH.ProcessID=SndRet.BaseProcessID and SndH.ProcessNo=SndRet.BaseProcessNo and 
		   SndH.FiscalYear=SndRet.BaseFiscalYear and SndH.SerialNo=SndRet.BaseSerialNo AND
		   SndD.GoodsID=SndRet.GoodsID
		WHERE (SndD.GoodsQuantity*(ProductCount-PrdQuantity))/ProductCount-ISNULL(gdsQuantity,0) >0  AND SndD.GoodsID= P.GoodsID),0) LostGds '
end 
else
begin
set @strLostGoods=', -1 as LostGoods,0 LostGds '
end 
	
	set @strLostGoodsQty=' 0 '
	if @InProduucingQty='True' and (@InProduucingGoods='1') 
		set @strLostGoodsQty=
		'ISNULL((SELECT SUM(a.ProductCount-PrdQuantity) from (
		SELECT a.*,IsNull((prd.funMaxRetProduct(a.ProcessID, a.ProcessNo, a.FiscalYear, a.SerialNo, 1)),0) PrdQuantity
		FROM 
		(   SELECT a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.ProductID,a.ProductCount -ISNULL(PrdQuantity,0) ProductCount --+IsNull((prd.funMaxRetProduct(a.ProcessID, a.ProcessNo, a.FiscalYear, a.SerialNo, 0)),0) PrdQuantity
			FROM inv.tblStorageDocsHdr a 
			LEFT join 
			(SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,SUM(GoodsQuantity) PrdQuantity 
			 FROM inv.tblStorageDocsDtl WHERE  ProcessID=80 
			 GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo
			) c
			ON a.ProcessID=c.BaseProcessID and a.ProcessNo=c.BaseProcessNo and a.FiscalYear=c.BaseFiscalYear AND a.SerialNo=c.BaseSerialNo
			where a.ProcessID=70  AND a.ProductID= G.GoodsID and ProductCount - ISNULL(PrdQuantity,0)>0
		) a
		)a WHERE a.ProductCount-PrdQuantity > 0),0)'
	 
	-- جدول موجودی کالاها - موقت
	CREATE TABLE #tbl_PrdProductNeedsOneStock_BalanceTemp
	(
		GoodsID    VarChar(20) COLLATE Arabic_CS_AS  Not Null,
		Quantity   Real Not Null
	)
	-- جدول موجودی کالاها - دائم
	CREATE TABLE #tbl_PrdProductNeedsOneStock_BalanceMain
	(
		GoodsID    VarChar(20) COLLATE Arabic_CS_AS  Not Null,
		Quantity   Real Not Null
	)
	-- جدول نتیجه
	CREATE TABLE #tbl_PrdProductNeedsOneStock_Result
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
	CREATE TABLE #tbl_PrdProductNeedsOneStock_Requests
	(
		ProductID	VarChar(20) COLLATE Arabic_CS_AS Not Null,
		GoodsID		VarChar(20) COLLATE Arabic_CS_AS Not Null,
		GoodsQty	Real Not Null,
		[Level]		varchar(255)
	)
	Declare @ConstPrdText1Name  nVarchar(100)
	Declare @ConstPrdText2Name  nVarchar(100)
	Declare @ConstPrdText3Name  nVarchar(100)
	Declare @ConstPrdText4Name  nVarchar(100)
	Declare @ConstPrdText5Name  nVarchar(100)
	
	Set @ConstPrdText1Name = ''
	Set @ConstPrdText2Name = ''
	Set @ConstPrdText3Name = ''
	Set @ConstPrdText4Name = ''
	Set @ConstPrdText5Name = ''
		
	SELECT @ConstPrdText1Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText1'
	SELECT @ConstPrdText2Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText2'
	SELECT @ConstPrdText3Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText3'
	SELECT @ConstPrdText4Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText4'
	SELECT @ConstPrdText5Name=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'ConstPrdText5'
	
	-- جدول موقت برای آخرین قیمت کالاها
	create table #tbl_PrdProductNeedsOneStock_Prices
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		Amount	float not null
	);
	---------------------------------------------------------------------------
	-- fill goods stock table -------------------------------------------------
	set @StrWhere = '(D.GoodsID = G.GoodsID)'

	if (@StoreID is not null)
		set @StrWhere = @StrWhere + ' and (D.StoreID = ''' + @StoreID + ''')'
	if (@DateTo is not null)
		set @StrWhere = @StrWhere + ' and (D.DocDate <= ''' + @DateTo + ''')'
	if (@SelectedStore > 0)
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	set @StrSelect = '
	INSERT	INTO #tbl_PrdProductNeedsOneStock_BalanceTemp(GoodsID, Quantity)
	SELECT DISTINCT G.GoodsID, 
			(
				SELECT	IsNull(Sum(D.GoodsQuantity * D.EnterKind), 0)
				FROM    inv.tblStorageDocsDtl D
				WHERE	(' + @StrWhere + ')
			)   + ('+ @strLostGoodsQty +') as Quantity
	FROM	(SELECT DISTINCT GoodsID FROM inv.tblStorageDocsDtl
			 UNION ALL
			 SELECT DISTINCT GoodsID FROM prd.tblFormulasDtl
			 UNION ALL
			 SELECT DISTINCT ProductID FROM prd.tblFormulasDtl
			 ) G '

	print @StrSelect;
	exec sp_executesql @StrSelect;
 
	INSERT	INTO #tbl_PrdProductNeedsOneStock_BalanceMain
	SELECT	* 
	FROM	#tbl_PrdProductNeedsOneStock_BalanceTemp
	---------------------------------------------------------------------------

if (@FormulaNo = 0)
		INSERT	INTO #tbl_PrdProductNeedsOneStock_Requests(ProductID, GoodsID, GoodsQty, [Level])
		SELECT	FH.ProductID, FD.GoodsID, (@XQuantity * FD.GoodsQuantity / FH.ProductCount), STR(FD.DocRowNo, 3) As [Level]
		FROM	prd.tblFormulasDtl FD 
					INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
		WHERE	(FH.IsDefault = 1) AND (FH.ProductID = @XProductID)
	else
		INSERT	INTO #tbl_PrdProductNeedsOneStock_Requests(ProductID, GoodsID, GoodsQty, [Level])
		SELECT	FH.ProductID, FD.GoodsID, (@XQuantity * FD.GoodsQuantity / FH.ProductCount), STR(FD.DocRowNo, 3) As [Level]
		FROM	prd.tblFormulasDtl FD 
					INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
		WHERE	(FH.SerialNo = @FormulaNo) AND (FH.ProductID = @XProductID)

	-- کرسر برای حرکت در جدول کالاهای مورد نیاز
	DECLARE CRS_Goods CURSOR FOR							
       SELECT ProductID, GoodsID, GoodsQty, [Level]
       FROM   #tbl_PrdProductNeedsOneStock_Requests
	--------------------------------------------------------
	-- Append Goods Leafs from Current Product -------------
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
			if (@FormulaNo = 0)
				INSERT	INTO #tbl_PrdProductNeedsOneStock_Requests(ProductID, GoodsID, GoodsQty, [Level])
				SELECT	FH.ProductID, FD.GoodsID, ((@XQuantity - @AvailQty) * FD.GoodsQuantity / FH.ProductCount), @Level + STR(FD.DocRowNo, 3)
				FROM	prd.tblFormulasDtl FD 
							INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
				WHERE	(FH.IsDefault = 1) AND (FH.ProductID = @XGoodsID)
			else
				INSERT	INTO #tbl_PrdProductNeedsOneStock_Requests(ProductID, GoodsID, GoodsQty, [Level])
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
					update #tbl_PrdProductNeedsOneStock_Result
					set ReqQty = ReqQty + @XQuantity, LackQty = LackQty + (@XQuantity - @AvailQty)
					where (ProductID = @XProductID) and (GoodsID = @XGoodsID)
					
					if (@@RowCount = 0)
						-- سطح اول فرمول تولید
						INSERT INTO #tbl_PrdProductNeedsOneStock_Result(ProductID, GoodsID, ReqQty, LackQty, Balance, IsLeaf, [Level])
						VALUES (@XProductID, @XGoodsID, @XQuantity, @XQuantity - @AvailQty, @AvailQty, 1, @Level)
				END
			END
			Else -- All records of Tree is needed
			BEGIN
				-- تمامی سطوح مورد نیاز است
				update #tbl_PrdProductNeedsOneStock_Result
				set ReqQty = ReqQty + @XQuantity, LackQty = LackQty + (@XQuantity - @AvailQty)
				where (ProductID = @XProductID) and (GoodsID = @XGoodsID)
					
				if (@@RowCount = 0)
					INSERT INTO #tbl_PrdProductNeedsOneStock_Result(ProductID, GoodsID, ReqQty, LackQty, Balance, IsLeaf, [Level])
					VALUES (@XProductID, @XGoodsID, @XQuantity, @XQuantity - @AvailQty, @AvailQty, ~ @HasChild, @Level)
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
	-- calc price of goods ---------------------------------------------
	if (@ShowPrice = 1)
	begin
		insert into #tbl_PrdProductNeedsOneStock_Prices
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
	--------------------------------------------------------------------
	-- final select ----------------------------------------------------
	if (@SelectedGoods > 0)
		set @StrWhere = pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'R.GoodsID')
	else
		set @StrWhere = '(1=1)'

	update #tbl_PrdProductNeedsOneStock_Result
	Set ConstPrdText1  =f.ConstPrdText1 ,
		ConstPrdText2  =f.ConstPrdText2 ,
		ConstPrdText3  =f.ConstPrdText3  ,
		ConstPrdText4  =f.ConstPrdText4  ,
		ConstPrdText5  =f.ConstPrdText5  
		from #tbl_PrdProductNeedsOneStock_Result a inner join prd.tblFormulasDtl f
		on a.ProductID=f.ProductID and a.GoodsID=f.GoodsID
		INNER JOIN prd.tblFormulasHdr H ON f.ProductID = H.ProductID AND f.SerialNo = H.SerialNo
		and H.IsDefault = 1 
		
	--where GoodsID not in (select ProductID from #tbl_PrdProductNeedsOneStock_Result)
	
	
 
	SELECT	R.ProductID, R.GoodsID, R.Level, [pub].[funGetGoodsName](R.GoodsID, 1) As GoodsName, 
			[pub].[funGetGoodsUnitName] (R.GoodsID, 1) UnitName, R.IsLeaf,
			R.ReqQty as RequestedQuantity,
			R.Balance as AvailableQuantity,
			R.LackQty as LackQuantity, 
			isnull(S.Quantity, 0) as TotalAvailableQuantity, 
			isnull(P.Amount, 0) as LastAmount
			,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5,
	[pub].[funGetGoodsUnitName] (R.GoodsID, 1)  ConstPrdText1Name,[pub].[funGetGoodsUnitName] (R.GoodsID, 1)  ConstPrdText2Name,[pub].[funGetGoodsUnitName] (R.GoodsID, 1)  ConstPrdText3Name,
	[pub].[funGetGoodsUnitName] (R.GoodsID, 1)  ConstPrdText4Name,[pub].[funGetGoodsUnitName] (R.GoodsID, 1)  ConstPrdText5Name
	, -1 as LostGoods,0 LostGds 
	into #tblTempResult
	FROM	#tbl_PrdProductNeedsOneStock_Result R 
				LEFT  JOIN #tbl_PrdProductNeedsOneStock_BalanceMain S ON S.GoodsID = R.GoodsID
				LEFT  JOIN #tbl_PrdProductNeedsOneStock_Prices P on P.GoodsID = R.GoodsID
	WHERE 1=0
	


	set @StrSelect = ' Insert into #tblTempResult
	SELECT	R.ProductID, R.GoodsID, R.Level, [pub].[funGetGoodsName](R.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') As GoodsName, 
			[pub].[funGetGoodsUnitName] (R.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') UnitName, R.IsLeaf,
			R.ReqQty as RequestedQuantity,
			R.Balance as AvailableQuantity,
			R.LackQty as LackQuantity, 
			isnull(S.Quantity, 0) as TotalAvailableQuantity, 
			isnull(P.Amount, 0) as LastAmount
			,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5,
	'''+@ConstPrdText1Name +''' ConstPrdText1Name,'''+@ConstPrdText2Name +''' ConstPrdText2Name,'''+@ConstPrdText3Name +''' ConstPrdText3Name,
	'''+@ConstPrdText4Name +''' ConstPrdText4Name,'''+@ConstPrdText5Name +''' ConstPrdText5Name
	'+ @strLostGoods +'
			
	FROM	#tbl_PrdProductNeedsOneStock_Result R 
				LEFT  JOIN #tbl_PrdProductNeedsOneStock_BalanceMain S ON S.GoodsID = R.GoodsID
				LEFT  JOIN #tbl_PrdProductNeedsOneStock_Prices P on P.GoodsID = R.GoodsID
	WHERE ' + @StrWhere + '
	ORDER BY [Level], ProductID, GoodsID'
	
	print @StrSelect;
	exec sp_executesql @StrSelect;

	if @InProduucingQty='True' and (@InProduucingGoods='1') 
		Update  #tblTempResult
			 set AvailableQuantity=AvailableQuantity-LostGoods
				,TotalAvailableQuantity =TotalAvailableQuantity-LostGoods

	 select * from #tblTempResult

END
GO
