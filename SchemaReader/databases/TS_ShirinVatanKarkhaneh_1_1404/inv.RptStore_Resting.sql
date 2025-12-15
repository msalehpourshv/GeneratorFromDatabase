USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/10/10
-- Viewed By	 : 
-- Last Modified : 1388/04/18
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : گزارش اقلام راکد انبار
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Resting]
	@SelectedStore		Int = 0,
	@SelectedGoods		Int = 0,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@IncludeQuantity	Bit = 1, -- شامل ستون مقدار
	@IncludePrice		Bit = 1, -- شامل ستون قیمت
	@IncludePrim		Bit = 1, -- شامل ستون اول دوره
	@IncludeInput		Bit = 1, -- شامل ستون ورود
	@IncludeOutput		Bit = 1, -- شامل ستون خروج
	@IncludeGroup		Bit = 1, -- شامل ستون گروه
	@IncludePackage		Bit = 1, -- شامل ستون بسته بندی
	@IncludeTechnical	Bit = 1, -- شامل ستون اطلاعات تکنیکی
	@IncludePlace		Bit = 0, -- شامل ستون مکان
	@IncludeZeroAmount	Bit = 1, -- شامل سطرهای مبلغ صفر
	@IncludeZeroQuantity	Bit = 1, -- شامل سطرهای موجودی صفر
	@PhysicallyEffected	Bit = 0, 
	@ValueRanges		NVarChar(500) = Null, -- فیلتر مقادیر
	@Scale				Float = 1,
	@SortFields			NVarChar(100) = Null,
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrGroup	NVarChar(2000);
DECLARE @StrHaving	NVarChar(2000);
DECLARE @StrYear		Char(4);
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables ----------------------------------------------------------
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;

	If @IncludeGroup Is Null SET @IncludeGroup = 0;
	If @IncludePackage Is Null SET @IncludePackage = 0;
	If @IncludeTechnical Is Null SET @IncludeTechnical = 0;
	IF @Scale Is Null SET @Scale = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @StrYear = LTrim(RIGHT(db_name(), 4))
	----------------------------------------------------------------------------

	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart


	-- Where Clause ------------------------------------------------------------
	SET @StrWhere = '(D.FiscalYear = ' + @StrYear + ')';

	If (@PhysicallyEffected Is Not Null)
		If (@PhysicallyEffected = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
		Else
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'

	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DocDateTo + ''''

	If (@IncludeZeroAmount = 0) 
		SET @StrWhere = @StrWhere + ' AND D.GoodsAmount <> 0 '

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	----------------------------------------------------------------------------------

	-- From Clause -------------------------------------------------------------------
	SET @StrFrom = ' 
		inv.tblStorageDocsDtl D
			INNER JOIN inv.tblGoods GDH ON GDH.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GDH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			LEFT JOIN inv.tblStoresDtl S ON D.StoreID = S.StoreID AND S.LanguageID = ' + @LangID + '
			LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = GDH.UnitID AND U.LanguageID = ' + @LangID

	If (@IncludeGroup = 1)
		SET @StrFrom = @StrFrom + '
			LEFT JOIN inv.tblGoodsGroupsGoodsListDtl GRL ON GRL.GoodsID = D.GoodsID 
			LEFT JOIN inv.tblGoodsGroupsDtl GR ON GR.GoodsGroupID = GRL.GoodsGroupID AND GR.LanguageID = ' + @LangID

	If (@IncludePlace = 1) 
		SET @StrFrom = @StrFrom + '
			LEFT JOIN inv.tblGoodsStatusDtl GS ON GS.GoodsID = D.GoodsID AND GS.StoreID = D.StoreID
			LEFT JOIN inv.tblStorePlacesDtl PD ON PD.StoreID = GS.StoreID AND PD.PlaceID = GS.PlaceID AND PD.LanguageID = ' + @LangID
	----------------------------------------------------------------------------------------------------------

	SET @StrGroup = 'D.StoreID, D.GoodsID, S.StoreName, U.UnitName'

	If (@IncludePlace = 1)
		SET @StrGroup = @StrGroup + ', PD.PlaceName'

	If (@IncludeGroup = 1)
		SET @StrGroup = @StrGroup + ', GR.GoodsGroupName'

	If (@IncludeTechnical = 1)
		SET @StrGroup = @StrGroup + ', GDH.TechnicalSpecifications'

	-- Select Clause -----------------------------------------------------------------------------------------
	SET @StrSelect = '
		SELECT	D.GoodsID, pub.GetGoodsName(D.GoodsID, ' + @LangID + ') GoodsName, U.UnitName,' +
				CASE WHEN(@IncludeGroup = 1)	THEN ' IsNull(GR.GoodsGroupName, ''-'') '          ELSE '''-''' END + ' AS GroupName,' + 
  				CASE WHEN(@IncludePackage = 1)  THEN ' N''بسته بندی'' '                            ELSE '''-''' END + ' AS PackageInfo,' +
  				CASE WHEN(@IncludeTechnical = 1)THEN ' IsNull(GDH.TechnicalSpecifications, ''-'') 'ELSE '''-''' END + ' AS TechInfo,' +
  				CASE WHEN(@IncludePlace = 1)    THEN ' IsNull(PD.PlaceName, ''-'') '               ELSE '''-''' END + ' AS PlaceName, ' + 
				CASE WHEN (@DocDateFr Is Not Null) THEN '
					SUM(CASE WHEN DocDate <  ''' + @DocDateFr + ''' THEN D.GoodsQuantity * D.EnterKind ELSE 0 END) AS TotalQuantityPrim, 
					SUM(CASE WHEN DocDate >= ''' + @DocDateFr + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) AS TotalQuantityInput,
					SUM(CASE WHEN DocDate >= ''' + @DocDateFr + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) AS TotalQuantityOutput, 
					SUM(CASE WHEN DocDate <  ''' + @DocDateFr + ''' THEN D.GoodsQuantity * D.GoodsAmount * D.EnterKind ELSE 0 END) AS TotalPricePrim,
					SUM(CASE WHEN DocDate >= ''' + @DocDateFr + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END) AS TotalPriceInput,
					SUM(CASE WHEN DocDate >= ''' + @DocDateFr + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END) AS TotalPriceOutput '
				ELSE '
					SUM(CASE WHEN D.ProcessID =  50 THEN D.GoodsQuantity ELSE 0 END) AS TotalQuantityPrim, 
					SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) AS TotalQuantityInput,
					SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) AS TotalQuantityOutput, 
					SUM(CASE WHEN D.ProcessID =  50 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END) AS TotalPricePrim,
					SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END) AS TotalPriceInput,
					SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity * D.GoodsAmount ELSE 0 END) AS TotalPriceOutput '
				END + ' 
		FROM	' + @StrFrom + '
 		WHERE	' + @StrWhere + '
		GROUP BY ' + @StrGroup
	-------------------------------------------------------------------------------------------------------------

	-- Having Clause ------------------------------------------------------------------------------------------
	IF (@StrSelect <> '') 
		SET @StrSelect = @StrSelect + 
		CASE WHEN (@DocDateFr Is Not Null) THEN '
	HAVING	SUM(CASE WHEN DocDate <  ''' + @DocDateFr + ''' THEN D.GoodsQuantity * D.EnterKind ELSE 0 END) * ' + Str(@Scale, 20, 2) + ' >
			(SUM(CASE WHEN DocDate >= ''' + @DocDateFr + ''' AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) +
			 SUM(CASE WHEN DocDate >= ''' + @DocDateFr + ''' AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) ) '
		ELSE + '
	HAVING	SUM(CASE WHEN D.ProcessID =  50 THEN D.GoodsQuantity ELSE 0 END) * ' + Str(@Scale, 20, 2) + ' >
			(SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) +
			 SUM(CASE WHEN D.ProcessID <> 50 AND D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) ) '
		END   
	--------------------------------------------------------------

	If (@ValueRanges Is Not Null)
	SET @StrSelect = '
	SELECT *
	FROM
	('+ @StrSelect +'
	) TOTAL
	WHERE ' + @ValueRanges

	-- Sort Clause ---------------------------------------------
	If @SortFields Is Not Null AND (@SortFields <> '') 
		SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- Run -----------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
