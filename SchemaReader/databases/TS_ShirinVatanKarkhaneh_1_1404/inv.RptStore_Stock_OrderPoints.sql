USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1386/05/11
-- Viewed By	 : 
-- Last Modified : 1389/04/22
-- Last Modifier : TakroSystem\Zia
-- Description   : گزارش موجودیهای کمتر از نقطه سفارش کالاها در یک انبار
-- ==============================================
Create PROCEDURE [inv].[RptStore_Stock_OrderPoints]
	@SelectedStore		Int = 0,
	@SelectedGoods		Int = 0,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@DecreaseOrder		Bit = 1,
	@ExtendedMode		Bit = 0,
	@ZeroAmount			Bit = Null, -- شامل سطرهای مبلغ صفر
	@PhysicallyEffected	Bit = 0, 
	@SortFields			NVarChar(100) = Null,
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrCmrQty	NVarChar(2000);
DECLARE @StrWhereStoreS	NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

DECLARE @NameValue AS NVarChar(200);
Declare @GoodsAmount varchar(20)

DECLARE	@AllSetPoints Bit;
DECLARE	@GoodsGroup	  Bit;

--DECLARE @ExtendedMode AS  Nvarchar(5);
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--========================
	DECLARE @UnitPart TINYINT
	DECLARE @CMRGoodsStatusFilterStoreKind BIT
	SET @UnitPart  = 1
	SET @CMRGoodsStatusFilterStoreKind = 'False'
	SET @StrWhereStoreS = ''

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	SELECT @CMRGoodsStatusFilterStoreKind = SettingValue from pub.tblSettings where SettingKey = 'CMRGoodsStatusFilterStoreKind'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	IF @CMRGoodsStatusFilterStoreKind = 'True'
		SET @StrWhereStoreS = ' D.StoreID IN (select StoreID from inv.tblStores  WHERE InventoryType=0 and InventoryOwnership=0) '
	ELSE
		SET @StrWhereStoreS = ' D.StoreID = S.StoreID '

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- Init Variables --------
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null) SET @SelectedStore = 0;

	SET @LangID		  = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	  = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	  = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		  = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin  = pub.funSplitString(@RepInfo, '@', 5);
	SET @AllSetPoints = pub.funSplitString(@RepInfo, '@', 6);
	SET @GoodsGroup		= pub.funSplitString(@RepInfo, '@', 7);

	set @GoodsAmount = LTRIM(inv.funGoodsAmount(@DocDateTo))
	-- Where Clause -----------------------------------------------------------
	Set @StrWhere = '(1 = 1) And SUBSTRING(S.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') IN (SELECT GoodsID FROM inv.tblGoods WHERE IsService = 0 AND CodeClosed = 0 AND PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ')'

	If (@PhysicallyEffected Is Not Null)
		If (@PhysicallyEffected = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
		Else
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'

	If (@ZeroAmount = 0) 
		Set @StrWhere = @StrWhere + ' AND D.' + @GoodsAmount + ' <> 0 '

	If (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		If (@DocDateFr = @DocDateTo)
			Set @StrWhere = @StrWhere + ' AND (D.DocDate  = ''' + @DocDateFr + ''')'
		Else 
		Begin
			If (@DocDateFr Is Not Null)
				Set @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
			If @DocDateTo Is Not Null
				Set @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		End

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'S.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'S.StoreID') 

	------------------------------------------------------------
	begin try
		drop table ##tbl_Store_Stock_OrderPoints
	end try
	begin catch
	end catch

	-- Select Clause -------------------------------------------
	if @ExtendedMode = 1
	begin
		SET @StrSelect = '
		SELECT	S.GoodsID,S.GoodsPlaceID, S.SetPoint, S.FitPoint,S.PlaceName RecDesc,
				[pub].[funGetGoodsName](S.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (S.GoodsID), '''') BarCode,
				IsNull(SUM(D.GoodsQuantity * D.EnterKind), 0) AS TotalQuantity,
				IsNull(Sum(T.GoodsQuantity), 0) AS OrderQuantity, S.StoreID, pub.GetStoreName(S.StoreID,' + LTrim(RTrim(@LangID)) + ') StoreName
		INTO	##tbl_Store_Stock_OrderPoints
		FROM	(SELECT *,inv.GetGoodsPlaceNameFromStore(StoreID,DocRowNo,1) PlaceName from inv.tblGoodsStatusDtl ) S 
		LEFT JOIN inv.tblStorageDocsDtl D 	 ON D.GoodsID = S.GoodsID AND ' +  @StrWhereStoreS + ' 
		LEFT JOIN
		(
			SELECT GoodsID, IsNull(Sum(GoodsQuantity), 0) as GoodsQuantity
			FROM 
			(
				select ProcessID, ProcessNo, FiscalYear, SerialNo
				from  sal.tblSaleOrderDtl 
				where ProcessID = 180
				except 
				select BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo
				from  inv.tblStorageDocsDtl
				where BaseProcessID = 180
			) RO inner join sal.tblSaleOrderDtl D1 on D1.ProcessID = RO.ProcessID and D1.ProcessNo = RO.ProcessNo and D1.FiscalYear = RO.FiscalYear and D1.SerialNo = RO.SerialNo
			GROUP BY GoodsID
		) T ON T.GoodsID = S.GoodsID 
		WHERE	' + @StrWhere +	'
		GROUP BY S.GoodsID, S.SetPoint, S.FitPoint,S.GoodsPlaceID,S.PlaceName,S.StoreID ' + 
		Case When @AllSetPoints = 0 Then 
		'HAVING IsNull(SUM(D.GoodsQuantity * D.EnterKind), 0) < S.SetPoint ' Else '' End
	end
	else
	begin	
		SET @StrSelect = '
		SELECT	S.GoodsID,S.GoodsPlaceID, S.SetPoint, S.FitPoint,S.PlaceName RecDesc,
				[pub].[funGetGoodsName](S.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (S.GoodsID), '''') BarCode,
				IsNull(SUM(D.GoodsQuantity * D.EnterKind), 0) AS TotalQuantity,
				IsNull(Sum(T.GoodsQuantity), 0) AS OrderQuantity, S.StoreID, pub.GetStoreName(S.StoreID,' + LTrim(RTrim(@LangID)) + ') StoreName
		INTO	##tbl_Store_Stock_OrderPoints
		FROM	(SELECT *,inv.GetGoodsPlaceNameFromStore(StoreID,DocRowNo,1) PlaceName from inv.tblGoodsStatusDtl ) S
		LEFT JOIN inv.tblStorageDocsDtl D 		 ON D.GoodsID = S.GoodsID AND ' +  @StrWhereStoreS + ' 
		LEFT JOIN
		(
			SELECT GoodsID, IsNull(Sum(GoodsQuantity), 0) AS GoodsQuantity
			FROM 
			(
				SELECT GoodsID, GoodsQuantity
				FROM sal.tblSaleOrderDtl 
				WHERE ProcessID = 180
				union all
				SELECT GoodsID, 0 - GoodsQuantity
				FROM sal.tblSaleOrderDtl 
				WHERE ProcessID = 185
				union all
				SELECT GoodsID, 0 - GoodsQuantity			
				FROM inv.tblStorageDocsDtl
				WHERE BaseProcessID = 180
			) M
			GROUP BY GoodsID
		) T ON T.GoodsID = S.GoodsID
		WHERE	' + @StrWhere +	'
		GROUP BY S.GoodsID, S.SetPoint, S.FitPoint,S.GoodsPlaceID,S.PlaceName ,S.StoreID ' + 
		Case When @AllSetPoints = 0 Then 
		'HAVING IsNull(SUM(D.GoodsQuantity * D.EnterKind), 0) < S.SetPoint ' Else '' End
	end
	
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	if (@UserIsAdmin = 0)
	begin
		exec pub.SpFilterByPermission2 '##tbl_Store_Stock_OrderPoints', 'GoodsID', 'inv.tblGoods', @UserID;
	end
	
	SET @StrCmrQty = '
	 ,IsNull((SELECT Sum(GoodsQuantity) FROM  (SELECT GoodsID	,SubUnitID	,	SUM(ConfirmQuantity) GoodsQuantity 	From   cmr.FunCmrGoodsQtyRemain2( 150 ,0,0,0,0,0,0,0,0,0,T.GoodsID)	group by GoodsID	,SubUnitID	) T2 ), 0)  AS CmrBuyQuantity
	 ,IsNull((SELECT Sum(GoodsQuantity) FROM  (SELECT GoodsID	,SubUnitID	,	SUM(ConfirmQuantity) GoodsQuantity 	From   cmr.FunCmrGoodsQtyRemain2( 160 ,0,0,0,0,0,0,0,0,0,T.GoodsID)	group by GoodsID	,SubUnitID	) T3 ), 0)  AS OrderBuyQuantity
	 ,IsNull((SELECT Sum(GoodsQuantity) FROM  (SELECT GoodsID	,SubUnitID	,	SUM(ConfirmQuantity) GoodsQuantity 	From   cmr.FunCmrGoodsQtyRemain2( 170 ,0,0,0,0,0,0,0,0,0,T.GoodsID)	group by GoodsID	,SubUnitID	) T4 ), 0)  AS TempReceiptQuantity'
	------------------------------------------------------------
	-- Sort Clause ---------------------------------------------
	IF @GoodsGroup = 'False'
	BEGIN
		SET @StrSelect = '
		SELECT * ' + @StrCmrQty + '
		FROM ##tbl_Store_Stock_OrderPoints T '	
	END
	ELSE
	BEGIN
		SET @StrSelect = '
		SELECT GoodsID,GoodsPlaceID,SUM(SetPoint) SetPoint,SUM(FitPoint) FitPoint,'''' RecDesc,GoodsName,BarCode,isnull(( Select Sum(GoodsQuantity*EnterKind ) from inv.tblStorageDocsDtl D where D.GoodsID = T.GoodsID),0) TotalQuantity,OrderQuantity		
		,'''' StoreID, '''' StoreName
		' + @StrCmrQty + '
		FROM ##tbl_Store_Stock_OrderPoints T 		
		GROUP BY GoodsID,GoodsPlaceID,GoodsName,BarCode,OrderQuantity'
	END
		If (@SortFields Is Not Null) AND (@SortFields <> '') 
			Set @StrSelect = @StrSelect + '
		 ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
