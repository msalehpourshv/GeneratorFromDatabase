USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1393/10/13
-- Viewed By	 : 
-- Last Modified :  
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[RptSal_VisitorGoodsQuotas]

	@GoodsID			Varchar(20) = Null,
	@SelectedVisitor1	Int = NULL,
	@SelectedVisitor2	Int = NULL,
	@SelectedVisitor3	Int = NULL,
	@SelectedVisitor4	Int = NULL,
	@RepOptions			VarChar(20) = '00',
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = ''

WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
 
DECLARE @CustomersAcntPartNumber AS Tinyint;
DECLARE @StartLayerIndex AS TINYINT;
DECLARE @LayerLen AS TINYINT;

Begin -- ============== S T A R T  C O D E ====================================

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
	
	-- Init Variables -------------------------------------
 	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)	SET @RepOptions = '110001';
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0
		 
	SET @CustomersAcntPartNumber = 0
	SET @StartLayerIndex = 0
	SET @LayerLen = 0
	
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'

	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'
	
	SELECT @CustomersAcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
			 
	-- Where Clause -----------------------------------------
	Select @StrWhere = '1 = 1'

	IF (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'V.VisitorAcntCode') + ')'
	IF (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'V.VisitorAcntCode') + ')'
	IF (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'V.VisitorAcntCode') + ')'
	IF (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'V.VisitorAcntCode') + ')'
		
	IF @GoodsID Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND V.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''''
		
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	Select V.GoodsID, [pub].[funGetGoodsName](V.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (V.GoodsID), '''') BarCode, V.VisitorAcntCode, 
		   IsNull(acc.funGetAcntName(SubString(V.VisitorAcntCode, ' + LTrim(RTrim(Str(@StartLayerIndex))) + ',' + LTrim(RTrim(Str(@LayerLen))) + '),' + LTrim(RTrim(Str(@CustomersAcntPartNumber))) + ', ' + LTrim(RTrim(Str(@LangID))) + '),'''') As VisitorName,
	       V.VisitorPercent 
	From sal.tblVisitorPortionDtl V
	Inner Join inv.tblGoodsDtl G ON G.GoodsID=SUBSTRING(V.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	Where '+ @StrWhere
			 
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
