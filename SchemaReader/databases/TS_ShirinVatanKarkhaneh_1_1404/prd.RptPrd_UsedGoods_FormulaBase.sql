USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED =====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/05/22
-- Viewed By	 : 
-- Last Modified : 1392/06/13
-- Last Modifier : Zia
-- Description	 : 
-- ------------------------------------------------
-- مواد مورد نیاز برای تولید چند محصول طبق فرمول 
-- ================================================
CREATE PROCEDURE [prd].[RptPrd_UsedGoods_FormulaBase]
	@ProcessID			Int = 80, 
	@ProcessNo			Int = 1,
	@ProductGroupID		VarChar(20) = Null,
	@ProductIDMask		VarChar(20) = Null,
	@ProductIDFr		VarChar(20) = Null,
	@ProductIDTo		VarChar(20) = Null,
	@GoodsGroupID		VarChar(20) = Null,
	@GoodsIDMask		VarChar(20) = Null,
	@GoodsIDFr			VarChar(20) = Null,
	@GoodsIDTo			VarChar(20) = Null,
	@AcntCodeFr			VarChar(20) = Null,
	@AcntCodeTo			VarChar(20) = Null,
	@DateFr				Char(10) = Null,
	@DateTo				Char(10) = Null,
	@VchNoFr			Char(10) = Null,
	@VchNoTo			Char(10) = Null,
	@OnlyFirstLayer		Bit = 1, -- فقط لایه اول کد ظاهر شود؟
	@SortFields			NVarChar(50) = Null
WITH ENCRYPTION
AS 
----------- Declare Variables -------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(2000);
Declare @StrWhere1	NVarChar(2000);
Declare @StrWhere2	NVarChar(2000);

DECLARE @UnitPart	TINYINT

-------------------------------------
BEGIN -- ============================ S T A R T   C O D E =========================================

	Set NoCount On;

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
	
	-- Init Variables & Default Values ----------------------------------------
	If @ProcessNo	Is Null Set @ProcessNo  = 1
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	Create Table #tblInputProducts
	(
		ProductID		VarChar(20) COLLATE Arabic_CS_AS Not Null,
		ProduceQuantity Real Not Null,
		FormulaNo		Int
	)
	Create Table #tblProductGoods
	(
		ProductID  VarChar(20) COLLATE Arabic_CS_AS Not Null,
		GoodsID    VarChar(20) COLLATE Arabic_CS_AS Not Null,
		GoodsQty   Real Not Null,
		IsFirstLayer Bit,
		FormulaNo  Int
	)
	Create Table #tblResult 
	(
		GoodsID		VarChar(20) COLLATE Arabic_CS_AS Not Null,
		GoodsQty	Real Not Null
	)
	DECLARE	@ProductID	VarChar(20)
	DECLARE	@ProduceQty	Real
	DECLARE @FormulaNo	Int
	DECLARE	@GoodsID	VarChar(20) 
	DECLARE	@HasChild	Bit
	DECLARE	@IsFirstLayer Bit 

	Set @StrWhere1 = ' SD.ProcessID = 80'-- + LTrim(Str(@ProcessID))

	If (@ProcessNo Is Not Null)
		Set @StrWhere1 = @StrWhere1 + ' AND SD.ProcessNo = ' + LTrim(Str(@ProcessNo))
	If (@ProductGroupID Is Not Null)
		Set @StrWhere1 = @StrWhere1 + ' AND PG.GoodsGroupID = ''' + @ProductGroupID + ''''
	If (@ProductIDMask Is Not Null)
		Set @StrWhere1 = @StrWhere1 + ' AND SD.GoodsID LIKE ''' + RTrim(Replace(@ProductIDMask, ' ', '_')) + '%'''

	--If (@GoodsIDFr Is Not Null)
	--	Set @StrWhere1 = @StrWhere1 + ' AND (SD.GoodsID >= ''' + @GoodsIDFr + ''')'
	--If (@GoodsIDTo Is Not Null)
	--	Set @StrWhere1 = @StrWhere1 + ' AND (SD.GoodsID <= ''' + @GoodsIDTo + ''')'

	If (@AcntCodeFr Is Not Null)
		Set @StrWhere1 = @StrWhere1 + ' AND (SD.AcntCode >= ''' + @AcntCodeFr + ''')'
	If @AcntCodeTo Is Not Null
		Set @StrWhere1 = @StrWhere1 + ' AND (SD.AcntCode <= ''' + @AcntCodeTo + ''')'

	If (@DateFr Is Not Null)
		Set @StrWhere1 = @StrWhere1 + ' AND (SD.DocDate >= ''' + @DateFr + ''')'
	If (@DateTo Is Not Null)
		Set @StrWhere1 = @StrWhere1 + ' AND (SD.DocDate <= ''' + @DateTo + ''')'
	
	If (@VchNoFr Is Not Null)
		Set @StrWhere1 = @StrWhere1 + ' AND (SH.VchNo >= ''' + @VchNoFr + ''')'
	If (@VchNoTo Is Not Null)
		Set @StrWhere1 = @StrWhere1 + ' AND (SH.VchNo <= ''' + @VchNoTo + ''')'	
	If (@ProductIDFr Is Not Null)
		Set @StrWhere1 = @StrWhere1 + ' AND (SD.GoodsID >= ''' + @ProductIDFr + ''')'
	If @ProductIDTo Is Not Null
		Set @StrWhere1 = @StrWhere1 + ' AND (SD.GoodsID <= ''' + @ProductIDTo + ''')'

	-- Where 2 --------------------------------------------------------------
	Set @StrWhere2 = ' (1=1)'

	If (@GoodsGroupID Is Not Null)
		Set @StrWhere2 = @StrWhere2 + ' AND (GG.GoodsGroupID = ''' + @GoodsGroupID + ''')'
	If (@GoodsIDFr Is Not Null)
		Set @StrWhere2 = @StrWhere2 + ' AND (GH.GoodsID >= ''' + @GoodsIDFr + ''')'
	If (@GoodsIDTo Is Not Null)
		Set @StrWhere2 = @StrWhere2 + ' AND (GH.GoodsID <= ''' + @GoodsIDTo + ''')'
	If (@GoodsIDMask Is Not Null)
		Set @StrWhere2 = @StrWhere2 + ' AND (GH.GoodsID LIKE ''' + RTrim(Replace(@GoodsIDMask, ' ', '_')) + '%'')'
	--------------------------------------------------------------------
	----------------------------------------------------------------------------------
	begin try
		drop table #tbl_Prd_UsedGoods_FormulaBase_Prices
	end try
	begin catch
	end catch
	
	create table #tbl_Prd_UsedGoods_FormulaBase_Prices
	(
		GoodsID varchar(20) collate arabic_cs_as not null,
		BuyPrice float not null
	);

	insert into #tbl_Prd_UsedGoods_FormulaBase_Prices
	select *
	from 
	(
		select distinct GoodsID, 
			(
				select top 1 GoodsPrice
				from inv.tblStorageDocsDtl D 
				where (D.GoodsID = M.GoodsID) and (D.ProcessID = 55)
				order by DocDate DESC, VolumeRowNo DESC
			) BuyPrice
		from inv.tblStorageDocsDtl M
	) T 
	where BuyPrice is not null

	update #tbl_Prd_UsedGoods_FormulaBase_Prices
	set BuyPrice = GoodsPrice
	from inv.tblGoods
	where #tbl_Prd_UsedGoods_FormulaBase_Prices.GoodsID = inv.tblGoods.GoodsID 
		and #tbl_Prd_UsedGoods_FormulaBase_Prices.BuyPrice = 0

	insert into #tbl_Prd_UsedGoods_FormulaBase_Prices(GoodsID, BuyPrice)
	select GoodsID, GoodsPrice
	from inv.tblGoods
	where GoodsID not in (select GoodsID from #tbl_Prd_UsedGoods_FormulaBase_Prices)
	----------------------------------------------------------------------------------
	-- From Clause ---------------------------------------------------
	Set @StrFrom = ' inv.tblStorageDocsDtl AS SD 
			INNER JOIN inv.tblStorageDocsHdr AS SH ON SD.ProcessID = SH.ProcessID AND SD.ProcessNo = SH.ProcessNo AND SD.FiscalYear = SH.FiscalYear AND SD.SerialNo = SH.SerialNo '

	If (@ProductGroupID Is Not Null)
		Set @StrFrom = @StrFrom + ' 
			INNER JOIN inv.tblGoodsGroupsGoodsListDtl PG ON PG.GoodsID = SD.GoodsID '
	--------------------------------------------------------------------
	----------- Fill in InputProducts Table ------------
	Set @StrSelect = '
	INSERT INTO #tblInputProducts
	SELECT SD.GoodsID, SUM(SD.GoodsQuantity) ProducedQuantity, SH.FormulaNo
	FROM   ' + @StrFrom + '
	WHERE  ' + @StrWhere1 + '
	GROUP BY SD.GoodsID, SH.FormulaNo'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	--* Declare Cursors ------------------------------------
	Declare Cursor_All CURSOR For			
		Select ProductID, ProduceQuantity, FormulaNo
		From   #tblInputProducts
																
	Declare Cursor_Once CURSOR For					
		Select ProductID, GoodsID, GoodsQty, IsFirstLayer, FormulaNo
		From   #tblProductGoods
	--------------------------------------------------------
	Open Cursor_All;
	Fetch NEXT From Cursor_All Into @ProductID, @ProduceQty, @FormulaNo

	While @@FETCH_STATUS = 0 -- Cursor_All
	Begin
	
		-- Append Goods Leafs From Current Product --
		INSERT INTO #tblProductGoods(ProductID, GoodsID, GoodsQty, IsFirstLayer, FormulaNo)
			SELECT FH.ProductID, FD.GoodsID, (@ProduceQty * FD.GoodsQuantity / FH.ProductCount), 1 As IsFirstLayer, @FormulaNo
			FROM   prd.tblFormulasDtl FD INNER JOIN prd.tblFormulasHdr FH 
			ON	   FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
			WHERE  FH.ProductID = @ProductID AND FH.SerialNo = @FormulaNo

		-- Read First Row From #tblProductGoods
		OPEN  Cursor_Once
		FETCH NEXT FROM Cursor_Once INTO @ProductID, @GoodsID, @ProduceQty, @IsFirstLayer, @FormulaNo

		While @@FETCH_STATUS = 0 -- Cursor_Once
		Begin
			INSERT INTO #tblProductGoods
			SELECT FH.ProductID, FD.GoodsID, (@ProduceQty * FD.GoodsQuantity / FH.ProductCount), 0 As IsFirstLayer, @FormulaNo
			FROM	 prd.tblFormulasDtl FD INNER JOIN prd.tblFormulasHdr FH ON FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
			WHERE	 FH.ProductID = @GoodsID AND FH.SerialNo = @FormulaNo 

			-- check whether inserted any row
			If @@RowCount = 0  
				Set @HasChild = 0
			Else 
				Set @HasChild = 1 

			If @OnlyFirstLayer = 1  -- Only First Layer Must Returned
			Begin
				If @IsFirstLayer = 1  -- Current Record is in First Layer
					INSERT INTO #tblResult
					VALUES (@GoodsID, @ProduceQty)
			End
			Else -- All records of Tree is needed
			Begin
				-- Has not any child
				If (@HasChild = 0)
					INSERT INTO #tblResult
					VALUES (@GoodsID, @ProduceQty)
			End

			-- Read Next Row From #tblProductGoods
			FETCH NEXT FROM Cursor_Once INTO @ProductID, @GoodsID, @ProduceQty, @IsFirstLayer, @FormulaNo
		End -- Cursor_Once

		CLOSE	 Cursor_Once -- Refresh Cursor
		DELETE FROM #tblProductGoods

		-- Read Next Row Fom @tblInputProducts
		FETCH NEXT FROM Cursor_All INTO @ProductID, @ProduceQty, @FormulaNo
    End -- Cursor_All

	Close		Cursor_All
	DeAllocate  Cursor_Once
	DeAllocate  Cursor_All
	
	Set @StrSelect = ' 
	SELECT R.GoodsID, SUM(R.GoodsQty) As GoodsQty, GD.GoodsName
	FROM   #tblResult R
    INNER JOIN inv.tblGoods GH ON GH.GoodsID = SUBSTRING(R.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND GH.PartNumber=' + LTRIM(STR(@UnitPart)) + '
    INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(R.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND GD.PartNumber=' + LTRIM(STR(@UnitPart)) + '
    ' 

	If (@GoodsGroupID Is Not Null)
		Set @StrSelect = @StrSelect + '
			 INNER JOIN inv.tblGoodsGroupsGoodsListDtl GG ON GG.GoodsID = GH.GoodsID '

	If (@StrWhere2 <> '')
	Set @StrSelect = @StrSelect + '
	WHERE ' + @StrWhere2
	------------------------------------------------------------
	-- Group By ------------------------------------------------
	Set @StrSelect = @StrSelect + '
	GROUP BY R.GoodsID, GD.GoodsName '
	------------------------------------------------------------
	Set @StrSelect = '
	select T.*, P.BuyPrice LastBuyPrice
	from 
	(
	' + @StrSelect + '
	) T	left join #tbl_Prd_UsedGoods_FormulaBase_Prices P on P.GoodsID=T.GoodsID'
	-- Order By ------------------------------------------------
	
	If (@SortFields Is Not Null) AND (@SortFields <> '')
	Set @StrSelect = @StrSelect + '
	ORDER BY ' + @SortFields
	------------------------------------------------------------
   
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
