USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/11/20
-- Viewed By	 :
-- Last Modified : 1390/11/20
-- Last Modifier : TakroSystem\Zia
-- Description   : تغییرات قیمت کالاها
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_PriceChangesCopy]
	@SelectedGoods	Int = 0,
	@DateFr			char(10) = Null,
	@DateTo			char(10) = Null,
	@PriceFr		BigInt = Null,
	@PriceTo		BigInt = Null,
	@SaleTypeID		VarChar(20) = null,
	@SortFields		NVarChar(100) = Null,
	@RepOptions		VarChar(10) = '1', -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1',
	@TestInfo		NVarChar(100) = 'MyTest'

WITH ENCRYPTION
AS
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrFrom		NVarChar(2000);
DECLARE @FldGoodsID		VarChar(20);
DECLARE @FldGoodsName	NVarChar(100);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int;
DECLARE	@ReportID		Int;
DECLARE	@price			NVarChar(500);
DECLARE	@ZeroPrice		Bit;	-- شامل سطرهای با مبلغ صفر
BEGIN --============== S T A R T  C O D E ===================================================

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
	
	-- Init Variables ---------------------------
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '1';
	IF (@SortFields	Is Null)	SET @RepOptions = 'DocDate, DocTime';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	--	SET @ZeroPrice	= Substring(@RepOptions, 1, 1)

	---------------------------------------------

	-- Where Clause ------------------------------------------------------------
	if (@SaleTypeID is not null)
	set @StrWhere = '(D.SaleTypeID = ''' + @SaleTypeID + ''')'
	else
	set @StrWhere = '(1=1)'

	IF (@SelectedGoods > 0)
	SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID')

	If (@PriceFr Is Not Null) OR (@PriceTo Is Not Null)
	If (@PriceFr = @PriceTo)
	SET @StrWhere = @StrWhere + ' AND (NewPrice = ' + LTrim(Str(@PriceFr)) + ')'
	Else
	begin
	If (@PriceFr Is Not Null)
	SET @StrWhere = @StrWhere + ' AND (NewPrice >= ' + LTrim(Str(@PriceFr)) + ')'
	If (@PriceTo Is Not Null)
	SET @StrWhere = @StrWhere + ' AND (NewPrice <= ' + LTrim(Str(@PriceTo)) + ')'
	end

	If (@DateFr Is Not Null) OR (@DateTo Is Not Null)
	If (@DateFr = @DateTo)
	SET @StrWhere = @StrWhere + ' AND (DocDate = ''' + @DateFr + ''')'
	Else
	begin
	If (@PriceFr Is Not Null)
	SET @StrWhere = @StrWhere + ' AND (DocDate >= ''' + @DateFr + ''')'
	If (@PriceTo Is Not Null)
	SET @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @DateTo + ''')'
	end
	------------------------------------------------------------

	-- Select Clause -------------------------------------------
	SET @StrSelect = '
		SELECT	D.*, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, pub.GetUserName(SessionNo) AS UserName
		FROM	sal.tblGoodsPriceChanges D
		INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '		
		WHERE	' + @StrWhere
	--------------------------------------------------------------

	-- Sort Clause -----------------------------------------------
	If (@SortFields Is Not Null) AND (@SortFields <> '')
	SET @StrSelect = @StrSelect + '
	ORDER BY ' + @SortFields
	--------------------------------------------------------------
	-- Run -------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	--------------------------------------------------------------
End
GO
