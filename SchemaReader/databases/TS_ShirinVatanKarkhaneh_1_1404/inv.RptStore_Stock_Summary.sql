USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/01/07
-- Viewed By	 : 
-- Last Modified : 1389/11/03
-- Last Modifier : TakroSystem\Zia
-- Description   : <Store Stock Summary>
-- ==============================================
Create PROCEDURE [inv].[RptStore_Stock_Summary] 
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SelectedStore		Int = 0,
	@SelectedGoods		Int = 0,
	@ValueRanges		NVarChar(1500) = Null, -- فیلتر مقادیر
	@SortFields			NVarChar(100) = Null,
	@RepOptions			NVarChar(100) = '11111110', -- bit array
	@RepInfo			NVarChar(100) = '1@1@1@0@0'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrGroup	NVarChar(2000);
DECLARE @StrHaving	NVarChar(2000);
DECLARE @StrYear		Char(4);
Declare @GoodsAmount varchar(20)

DECLARE @ShowQuantity	Bit; -- شامل ستون مقدار
DECLARE @ShowPrice		Bit; -- شامل ستون قیمت
DECLARE @ShowPrim		Bit; -- شامل ستون اول دوره
DECLARE @ShowInput		Bit; -- شامل ستون ورود
DECLARE @ShowOutput		Bit; -- شامل ستون خروج
DECLARE @ZeroAmount		Bit; -- شامل سطرهای مبلغ صفر
DECLARE	@ZeroQuantity	Bit; -- شامل سطرهای موجودی صفر
DECLARE @Ph_Effected	Bit; 

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;

DECLARE @DateField	nvarchar(20);

DECLARE	@GoodsPartLen1	Int;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables ----------------------------------------------------------
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;
	IF (@RepOptions	 Is Null)	SET @RepOptions = '11111110';

	SET @ShowQuantity	= Substring(@RepOptions, 1, 1)
	SET @ShowPrice		= Substring(@RepOptions, 2, 1)
	SET @ShowPrim		= Substring(@RepOptions, 3, 1)
	SET @ShowInput		= Substring(@RepOptions, 4, 1)
	SET @ShowOutput		= Substring(@RepOptions, 5, 1)
	SET @ZeroAmount		= Substring(@RepOptions, 6, 1)
	SET @ZeroQuantity	= Substring(@RepOptions, 7, 1)

	IF Substring(@RepOptions, 8, 1) = '2'
		SET @Ph_Effected = Null
	ELSE
		SET @Ph_Effected = Substring(@RepOptions, 8, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

	SET @GoodsAmount = LTRIM(inv.funGoodsAmount(@DocDateTo))
	SET @StrYear = LTrim(RIGHT(db_name(), 4))

	SET @GoodsPartLen1 = 1;
	Select @GoodsPartLen1 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 1

	----------------------------------------------------------------------------
	-- Where Clause ------------------------------------------------------------
	if (@ShowPrice = 1)
		--set @DateField = 'VchDate2'
		set @DateField = 'DocDate'
	else
		set @DateField = 'DocDate'

	SET @StrWhere = '(D.FiscalYear = ' + @StrYear + ') And SubString(D.GoodsID, 1, ' + LTrim(RTrim(Str(@GoodsPartLen1))) + ') IN (Select GoodsID From inv.tblGoods Where PartNumber = 1 And IsService = 0)';

	If (@Ph_Effected Is Not Null)
		If (@Ph_Effected = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
		Else
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'

	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.' + LTrim(@DateField) + ' <> '''' AND D.' + LTrim(@DateField) + ' <= ''' + @DocDateTo + ''''

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	If (@ZeroAmount = 0) 
		SET @StrWhere = @StrWhere + ' AND D.' + @GoodsAmount + ' <> 0 '
	----------------------------------------------------------------------------------

	-- Select Clause -----------------------------------------------------------------------------------------
	SET @StrSelect = '
		SELECT	D.StoreID, S.StoreName, ' + 
				CASE WHEN (@DocDateFr Is Not Null) THEN '
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + ''' THEN D.EnterKind * D.EnterKind ELSE 0 END),0) AS TotalQuantityPrim, 
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantityInput,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantityOutput, 
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 90 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantitySale, 
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 100 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantitySale_Ret,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + ''' THEN D.GoodsQuantity * D.' + @GoodsAmount + ' * D.EnterKind  ELSE 0 END),0) +
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr  + '''  AND D.EnterKind = +1 AND D.ProcessID = 51 THEN D.GoodsPrice  ELSE 0 END),0) AS TotalPricePrim,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity * D.' + @GoodsAmount + ' ELSE 0 END),0) +
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = +1 AND D.ProcessID = 51  THEN D.GoodsPrice ELSE 0 END),0) AS TotalPriceInput,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity * D.' + @GoodsAmount + ' ELSE 0 END),0) +
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.EnterKind = -1 AND D.ProcessID = 51  THEN D.GoodsPrice ELSE 0 END),0) AS TotalPriceOutput,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 90 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale,
				isnull(SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr  + ''' AND D.ProcessID = 100 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale_Ret'
			ELSE '
				isnull(SUM(CASE WHEN D.ProcessID =  50 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantityPrim, 
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantityInput,
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantityOutput, 
				isnull(SUM(CASE WHEN D.ProcessID = 90 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantitySale, 
				isnull(SUM(CASE WHEN D.ProcessID = 100 THEN D.GoodsQuantity ELSE 0 END),0) AS TotalQuantitySale_Ret,
				isnull(SUM(CASE WHEN D.ProcessID =  50 THEN D.GoodsQuantity * D.' + @GoodsAmount + ' ELSE 0 END),0) AS TotalPricePrim,
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity * D.' + @GoodsAmount + ' ELSE 0 END),0)
				+isnull(SUM(CASE WHEN D.ProcessID =51 AND D.EnterKind = +1 THEN  D.GoodsPrice ELSE 0 END),0) AS TotalPriceInput,
				isnull(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity * D.' + @GoodsAmount + ' ELSE 0 END),0)
				+isnull(SUM(CASE WHEN D.ProcessID =51 AND D.EnterKind = -1 THEN  D.GoodsPrice ELSE 0 END),0) AS TotalPriceOutput ,
				isnull(SUM(CASE WHEN D.ProcessID = 90 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale,
				isnull(SUM(CASE WHEN D.ProcessID = 100 THEN D.GoodsQuantity * D.GoodsPrice ELSE 0 END),0) AS TotalPriceSale_Ret'
			END + ' 
		into	##tbl_RptStore_Stock_Summary
		FROM	inv.tblStorageDocsDtl D
				--INNER JOIN inv.tblGoods GDH ON GDH.GoodsID = D.GoodsID 
				--INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = GDH.GoodsID AND GD.LanguageID = ' + @LangID + '
				LEFT JOIN  inv.tblStoresDtl S ON D.StoreID = S.StoreID AND S.LanguageID = ' + @LangID + '
				--LEFT JOIN  inv.tblUnitsDtl U ON U.UnitID = GDH.UnitID AND U.LanguageID = ' + @LangID + '
				--LEFT JOIN  inv.tblGoodsGroupsGoodsListDtl GR ON GR.GoodsID = GDH.GoodsID 
 		WHERE	' + @StrWhere + '
		GROUP BY D.StoreID, S.StoreName '
	-------------------------------------------------------------------------------------------------------------

	begin try
		drop table ##tbl_RptStore_Stock_Summary
	end try
	begin catch
	end catch

	-- Having Clause ------------------------------------------------------------------------------------------
	IF (@ZeroQuantity = 0)
	Begin
		IF (@StrSelect <> '') 
		
			SET @StrSelect = @StrSelect + 
				CASE WHEN (@DocDateFr Is Not Null) THEN 
					' HAVING SUM(CASE WHEN ' + LTrim(@DateField) + ' <  ''' + @DocDateFr + ''' THEN D.GoodsQuantity * D.EnterKind ELSE 0 END) +
					 	     SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) -
						     SUM(CASE WHEN ' + LTrim(@DateField) + ' >= ''' + @DocDateFr + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) <> 0 '
				ELSE + ' HAVING SUM(D.GoodsQuantity*D.EnterKind) <> 0 '
				END   
	End

	print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	if (@UserIsAdmin = 0)
	begin
		exec pub.SpFilterByPermission2 '##tbl_RptStore_Stock_Summary', 'StoreID', 'inv.tblStores', @UserID;
	end
	
	--------------------------------------------------------------
	If (@ValueRanges Is Not Null)
	SET @StrSelect = '
	SELECT *
	FROM ##tbl_RptStore_Stock_Summary TOTAL
	WHERE ' + @ValueRanges
	Else
	SET @StrSelect = '
	SELECT *
	FROM ##tbl_RptStore_Stock_Summary TOTAL'

	-- Sort Clause ---------------------------------------------
	If (@SortFields Is Not Null) AND (@SortFields <> '') 
		SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
