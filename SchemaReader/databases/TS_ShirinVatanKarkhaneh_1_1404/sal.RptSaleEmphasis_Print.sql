USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1393/05/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 :  
-- =============================================
CREATE PROCEDURE [sal].[RptSaleEmphasis_Print] 
	@SerialFr			int= null,
	@SerialTo			int= null,
	@FiscalYear			INT=null,
	@CurrentSerialNo	INT =0,
	@AcntPart			INT =2,
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
declare @db_0000	nvarchar(50);

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
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
		
	--==============
	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

--
	set @StrWhere = '(1=1)'
	
	IF (@CurrentSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND  SerialNo=' + ltrim(rtrim(STR(@CurrentSerialNo)))
		
	IF (@SerialFr IS NOT null)
		SET @StrWhere = @StrWhere + ' AND  SerialNo >= ' + ltrim(rtrim(STR(@SerialFr)))
	IF (@SerialTo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND  SerialNo <= ' + ltrim(rtrim(STR(@SerialTo)))
	
	IF (@FiscalYear IS NOT null)
		SET @StrWhere = @StrWhere + ' AND  FiscalYear=' + ltrim(rtrim(STR(@FiscalYear)))
		
-- ================ SELECT ===========================

	SET @StrSelect = '
	Select *,[pub].[funGetGoodsName](EmphasisSaleGoodsID,' + LTrim(RTrim(@LangID)) + ') EmphasisGoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (EmphasisSaleGoodsID), '''') EmphasisBarCode,
		   [pub].[funGetGoodsName](EmphasisNotSaleGoodsID,' + LTrim(RTrim(@LangID)) + ') EmphasisNotGoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (EmphasisNotSaleGoodsID), '''') EmphasisNotBarCode
		From sal.tblEmphasisGoodsDtl
	WHERE ' + @StrWhere

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
