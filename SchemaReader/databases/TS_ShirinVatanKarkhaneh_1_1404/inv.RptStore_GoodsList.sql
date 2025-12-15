USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/06/11
-- Viewed By	 : 
-- Last Modified : 1390/02/18
-- Last Modifier : TakroSystem\Zia
-- Description	 : لیست کالاها
-- ===============================================
Create PROCEDURE [inv].[RptStore_GoodsList]
	@SelectedGoods	int = 0,
	@CodeLen		int = null,
	@RepOptions		VarChar(20) = '000',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect		NVARCHAR(4000);
DECLARE @StrWhere		NVARCHAR(2000);

DECLARE	@LangID			CHAR(1);
DECLARE	@SessionNo		INT; 
DECLARE	@ReportID		INT;

DECLARE	@SortByName		BIT;
DECLARE	@InactiveGoods	BIT;
DECLARE @SortByTechCode BIT;
DECLARE @inv_GoodsAcntGroup	BIT

BEGIN --============================ S T A R T ===============================================

	SET NOCOUNT ON;

	--=== INIT =========================================================================
	IF (@RepOptions	Is Null)	SET @RepOptions = '000';
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @SortByName		= Substring(@RepOptions, 1, 1);
	SET @InactiveGoods	= Substring(@RepOptions, 2, 1);
	SET @SortByTechCode		= Substring(@RepOptions, 3, 1);

	SET @inv_GoodsAcntGroup = 'False'

	SELECT @inv_GoodsAcntGroup = SettingValue 
	FROM pub.tblSettings 
	WHERE UPPER(SettingKey) = UPPER('inv_GoodsAcntGroup')
	--=== WHERE =========================================================================
	SET @StrWhere = '(H.GoodsID<>'''')';

	if (@InactiveGoods = 0)
		SET @StrWhere = @StrWhere + ' AND (H.CodeClosed<>1)'

	if (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.GoodsID') 

	if (@CodeLen is not null)
		SET @StrWhere = @StrWhere + ' AND (Len(H.GoodsID) = ' + LTrim(Str(@CodeLen)) +')'

	--=== SELECT ================================================================

	SET @StrSelect = '
	SELECT H.*, 
		   D.GoodsName, 
		   I.GoodsImage, 
		   ISNULL(U.UnitName,'''') UnitName , 
	       ISNULL(SU.UnitValue, ' + @LangID + ') UnitValue, 
		   ISNULL(SU.MainUnitValue, ' + @LangID + ') MainUnitValue,
		   [inv].[funGetUnitName](SU.SubUnitID, ' + @LangID + ')  SubUnitName,
		   CASE WHEN '+str(@inv_GoodsAcntGroup)+' = 0 THEN '''' ELSE IsNull(GAD.GoodsAcntGroupName,'''') END GoodsAcntGroupName
	FROM inv.tblGoods H 
	INNER JOIN inv.tblGoodsDtl D ON (H.GoodsID = D.GoodsID) AND (D.LanguageID = ' + @LangID + ')			
	LEFT JOIN inv.tblGoodsImages I ON I.GoodsID = H.GoodsID		
	LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = H.GoodsID AND  SU.ShowInInvoice=1
	LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = H.UnitID AND (D.LanguageID = ' + @LangID + ')
	LEFT JOIN inv.tblGoodsAcntGroupDtl GAD ON H.GoodsAcntGroupID = GAD.GoodsAcntGroupID AND GAD.LanguageID='+@LangID+'
	WHERE ' + @StrWhere
		
	If (@SortByName = 1)
		SET @StrSelect = @StrSelect + '
		ORDER By GoodsName '
	Else If (@SortByTechCode = 1)
		SET @StrSelect = @StrSelect + '
		ORDER By TechnicalNo '
	Else
		SET @StrSelect = @StrSelect + '
		ORDER By H.GoodsID '

	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
END
GO
