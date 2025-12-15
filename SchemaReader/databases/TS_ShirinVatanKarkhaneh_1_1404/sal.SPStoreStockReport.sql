USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sal].[SPStoreStockReport]
	@ProcessID		Tinyint  	  = 240,
	@ProcessNo		Tinyint  	  = 1,
	@FiscalYear		Smallint 	  = Null,
	@SerialNo		Int		 	  = Null,
	@StoreID		Varchar(20)   = Null,
	@StoreName		NVarchar(200) = Null,
	@GoodsID		Varchar(20)   = Null,
	@GoodsName		NVarchar(200) = Null,
	@GoodsHeight	Float		  = Null,
	@GoodsWidth		Float		  = Null,
	@DocDate		Char(10)	  = Null	
WITH ENCRYPTION
AS

BEGIN

DECLARE @LanguageID TinyInt;

SET NOCOUNT ON;

	DECLARE @StrSelect	NVarChar(Max);
	DECLARE @StrWhere	NVarChar(Max);
	
	SET @LanguageID = pub.funGetCurrentLanguageID();
	
	-- ==========
	DECLARE @UserName NVarChar(4000)
	SET @UserName = ''
	SELECT @UserName = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'Pub_CurrentUserName'
		
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

	-- ============================================================= Where
	SET @StrSelect = ''
	SET @StrWhere = '1 = 1'
	
	IF (@StoreID <> '') And (@StoreID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND A.StoreID Like ''%' + @StoreID + '%'''
	
	IF (@StoreName <> '') And (@StoreName Is Not Null)
		SET @StrWhere = @StrWhere + ' AND SD.StoreName Like ''%' + @StoreName + '%'''	
	
	IF (@GoodsID <> '') And (@GoodsID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND A.GoodsID Like ''%' + @GoodsID + '%'''
		
	IF (@GoodsName <> '') And (@GoodsName Is Not Null)
		SET @StrWhere = @StrWhere + ' AND G.GoodsName Like ''%' + @GoodsName + '%'''
		
	IF (@GoodsHeight <> 0) And (@GoodsHeight Is Not Null)
		SET @StrWhere = @StrWhere + ' AND GH.GoodsHeight = ' + Str(@GoodsHeight, Len(@GoodsHeight),3)
		
	IF (@GoodsWidth <> '') And (@GoodsWidth Is Not Null)
		SET @StrWhere = @StrWhere + ' AND GH.GoodsWidth = ' + Str(@GoodsWidth, Len(@GoodsWidth),3)
		
	-- ============================================================= Select
	SET @StrSelect = '
		SELECT A.*, SD.StoreName, G.GoodsName, [pub].[funGetGoodsUnitName] (A.GoodsID, ' + LTrim(Str(@LanguageID)) + ') As UnitName, 
			   GH.GoodsHeight, GH.GoodsWidth, IsNull(A.StoreRemain - A.BaskulQty, 0) RealQty, 
			   IsNull(A.StoreRemain - A.BaskulQty, 0) - A.ActiveDoc - A.PreSaleRemain SalableQty, ''' + @UserName + ''' UserName
		FROM
		(
			SELECT A.StoreID
			, A.GoodsID
			--, [inv].[funGetGoodsRemainVirtualQuantity](A.GoodsID,A.StoreID,''' + LTrim(RTrim(@DocDate)) + ''') BaskulQty
			,(Select ISNULL(Sum(SubUnitQuantity ) ,0)
				From inv.tblStorageDocsDtl S Where (S.ProcessID = 90) AND DocDate<=''' + LTrim(RTrim(@DocDate)) + ''' 
				And StoreID = A.StoreID AND GoodsID2 =A.GoodsID	
				)BaskulQty
			, inv.funGetGoodsRemainInPreSaleWithService(A.GoodsID,A.StoreID,''' + LTrim(RTrim(@DocDate)) + ''') PreSaleRemain
			, StoreRemain
			, [inv].[funGetGoodsRemainActiveDoc](A.GoodsID,A.StoreID,''' + LTrim(RTrim(@DocDate)) + ''') ActiveDoc
			FROM
			(
				SELECT P.ProcessID, P.ProcessNo, P.FiscalYear, P.SerialNo, P.DocRowNo, P.StoreID,
					   IsNull(S.ProcessID, 0) SaleProcessID, IsNull(S.ProcessNo, 0) SaleProcessNo, 
					   IsNull(S.FiscalYear, 0) SaleFiscalYear, IsNull(S.SerialNo, 0) SaleSerialNo, 
					   IsNull(S.DocRowNo, 0) SaleDocRowNo, P.GoodsID2 GoodsID,
					   IsNull(P.GoodsQuantity, 0) PreSaleQty, IsNull(S.VirtualQuantity, 0) SaleQty,
					   IsNull(P.GoodsQuantity, 0) - IsNull(S.VirtualQuantity, 0) PreSaleRemain,
					   IsNull(S.SubUnitQuantity, 0) BaskulQty,
					   [inv].[funGetGoodsRemain](NULL, NULL, NULL, NULL, NULL, P.StoreID, P.GoodsID2, Null, ''' + LTrim(RTrim(@DocDate)) + ''', 0) StoreRemain
				FROM inv.tblPreSaleDtl P
				INNER JOIN inv.tblPreSaleHdr PH ON PH.ProcessID = P.ProcessID And PH.ProcessNo = P.ProcessNo And
												   PH.FiscalYear = P.FiscalYear And PH.SerialNo = P.SerialNo 
												    --And PH.ConfirmState = 1 
				LEFT JOIN inv.tblStorageDocsDtl S ON S.BaseProcessID = P.ProcessID And S.BaseProcessNo = P.ProcessNo And
													 S.BaseFiscalYear = P.FiscalYear And S.BaseSerialNo = P.SerialNo And 
													 S.BaseDocRowNo = P.DocRowNo
				WHERE P.ProcessID = ' + LTrim(Str(@ProcessID)) + ' And P.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ' 
					  --And P.FiscalYear = @FiscalYear And P.SerialNo = @SerialNo
			) A
			GROUP BY A.StoreID, A.GoodsID, StoreRemain
		) A
		INNER JOIN inv.tblGoods	   GH ON GH.GoodsID = SUBSTRING(A.GoodsID, ' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GH.PartNumber = ' + ltrim(rtrim(STR(@UnitPart))) + '
		INNER JOIN inv.tblGoodsDtl G  ON G.GoodsID = SUBSTRING(A.GoodsID, ' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber = ' + ltrim(rtrim(STR(@UnitPart))) + ' AND G.LanguageID = ' + LTrim(Str(@LanguageID)) + '
		INNER JOIN inv.tblStoresDtl SD ON SD.StoreID = A.StoreID
		WHERE ' + @StrWhere + '
		ORDER BY A.StoreID, A.GoodsID '
	-- =============================================================
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	-- =============================================================
		
END
GO
