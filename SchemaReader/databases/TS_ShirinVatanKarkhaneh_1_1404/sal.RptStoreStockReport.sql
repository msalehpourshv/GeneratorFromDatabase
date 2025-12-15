USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sal].[RptStoreStockReport]
	@ProcessID		Tinyint  	  = 240,
	@ProcessNo		Tinyint  	  = 1,
	@FiscalYear		Smallint 	  = Null,
	@SerialNo		Int		 	  = Null,
	@SelectedGoods	int 		  = 0,
	@SelectedStore	int 		  = 0,
	@GoodsHeight	Float		  = Null,
	@GoodsWidth		Float		  = Null,
	@DocDate		Char(10)	  = Null,
	@RepOptions		VarChar(10)	  = '10',
	@ExtraParams	NVarChar(200) = '@0@@@-1@-1',
	@RepInfo		NVarChar(100) = '1@1@1'	
WITH ENCRYPTION
AS

BEGIN

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

SET NOCOUNT ON;

	DECLARE @StrSelect	NVarChar(Max);
	DECLARE @StrWhere	NVarChar(Max);
	
	-- ==========
	DECLARE @UserName NVarChar(4000)
	SET @UserName = ''
	SELECT @UserName = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'Pub_CurrentUserName'
		
	--==============
	IF (@RepOptions Is Null)	SET @RepOptions = '10';
	IF (@ExtraParams Is Null)	SET @ExtraParams = '@0@@@-1@-1';
		
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
		
	--==============
	SET @LangID = pub.funGetCurrentLanguageID();

	--==============
	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0;	
	
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
	where TableName='inv.tblGoods' AND PartNumber < @UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	-- ============================================================= Where
	SET @StrSelect = ''
	SET @StrWhere = '1 = 1'
	
	IF (@GoodsHeight <> 0) And (@GoodsHeight Is Not Null)
		SET @StrWhere = @StrWhere + ' AND GH.GoodsHeight = ' + Str(@GoodsHeight, Len(@GoodsHeight),3)
		
	IF (@GoodsWidth <> '') And (@GoodsWidth Is Not Null)
		SET @StrWhere = @StrWhere + ' AND GH.GoodsWidth = ' + Str(@GoodsWidth, Len(@GoodsWidth),3)

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'A.GoodsID')
		
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'A.StoreID')
						
	-- ============================================================= Select
	SET @StrSelect = '
		SELECT A.*, SD.StoreName, G.GoodsName, [pub].[funGetGoodsUnitName] (A.GoodsID, ' + LTrim(Str(@LangID)) + ') As UnitName, 
			   GH.GoodsHeight, GH.GoodsWidth, IsNull(A.StoreRemain - A.BaskulQty, 0) RealQty, 
			   IsNull(A.StoreRemain - A.BaskulQty, 0) - A.ActiveDoc - A.PreSaleRemain SalableQty, ''' + @UserName + ''' UserName
		FROM
		(
			SELECT A.StoreID, A.GoodsID, SUM(A.BaskulQty) BaskulQty, SUM(A.PreSaleRemain) PreSaleRemain, StoreRemain, 
				  (Select COUNT(*) 
				   From inv.tblStorageDocsDtl SS
				   Where SS.GoodsID = A.GoodsID And SS.SubUnitQuantity = 0) ActiveDoc
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
												   PH.FiscalYear = P.FiscalYear And PH.SerialNo = P.SerialNo And 
												   PH.ConfirmState = 1 
				LEFT JOIN inv.tblStorageDocsDtl S ON S.BaseProcessID = P.ProcessID And S.BaseProcessNo = P.ProcessNo And
													 S.BaseFiscalYear = P.FiscalYear And S.BaseSerialNo = P.SerialNo And 
													 S.BaseDocRowNo = P.DocRowNo
				WHERE P.ProcessID = ' + LTrim(Str(@ProcessID)) + ' And P.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ' 
					  --And P.FiscalYear = @FiscalYear And P.SerialNo = @SerialNo
			) A
			GROUP BY A.StoreID, A.GoodsID, StoreRemain
		) A
		INNER JOIN inv.tblGoods	   GH ON GH.GoodsID = SUBSTRING(A.GoodsID, ' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GH.PartNumber = ' + ltrim(rtrim(STR(@UnitPart))) + '
		INNER JOIN inv.tblGoodsDtl G  ON G.GoodsID = SUBSTRING(A.GoodsID, ' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber = ' + ltrim(rtrim(STR(@UnitPart))) + ' AND G.LanguageID = ' + LTrim(Str(@LangID)) + '
		INNER JOIN inv.tblStoresDtl SD ON SD.StoreID = A.StoreID
		WHERE ' + @StrWhere + '
		ORDER BY A.StoreID, A.GoodsID '
	-- =============================================================
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	-- =============================================================
		
END
GO
