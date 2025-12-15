USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/01/21
-- Viewed By	 : 
-- Last Modified : 1392/07/11
-- Last Modifier : TakroSystem\Zia
-- Description   : لیست قیمت فروش کالاها
-- ==============================================

Create PROCEDURE [sal].[RptSale_PriceList2]
	@SelectedGoods	Int = 0,
	@PriceFr		BigInt = Null,
	@PriceTo		BigInt = Null,
	@SaleTypeID		VarChar(20) = Null,
	@SortFields		NVarChar(100) = Null,
	@RepInfo		NVarChar(100) = '1@1@1',
	@RepOptions		NVarChar(50) = '111',
	@ExtraParams	NVarChar(200) = ''

WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(4000);
DECLARE @StrFrom		NVarChar(4000);
DECLARE @FldGoodsID		VarChar(20);
DECLARE @FldGoodsName	NVarChar(100);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@price			nvarchar(500);

DECLARE	@ZeroPrice		Bit; -- شامل سطرهای با مبلغ صفر
DECLARE	@ZeroRemain		Bit; -- شامل سطرهای با موجودی صفر
DECLARE	@ShowImage		Bit; -- نمایش تصویر کالا

Declare @TollOverWorthPercentInSaleValue float
Declare @TaxOverWorthPercentInSaleValue float
Declare @Value float
Declare @SalePriceTax bigint

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
	
	select @TaxOverWorthPercentInSaleValue=isnull(SettingValue,0)  from pub.tblSettings where  (SettingKey = N'TaxOverWorthPercentInSale')
    select @TollOverWorthPercentInSaleValue=isnull(SettingValue,0)  from pub.tblSettings where  (SettingKey = N'TollOverWorthPercentInSale')

    select @Value=@TollOverWorthPercentInSaleValue+@TaxOverWorthPercentInSaleValue
	
	-- Init Variables ---------------------------
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '110001';
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ZeroPrice	= Substring(@RepOptions, 1, 1);
	SET @ZeroRemain	= Substring(@RepOptions, 2, 1);
	SET @ShowImage	= Substring(@RepOptions, 3, 1);
	
	--SET @ZeroPrice = LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	--================================
	If (@ZeroPrice = 1)
	Begin
		SET @FldGoodsID = 'G.GoodsID'
		SET @FldGoodsName = '[pub].[funGetGoodsName](G.GoodsID,' + LTrim(RTrim(@LangID)) + ')'
	End
	Else
	Begin
		SET @FldGoodsID = 'S.GoodsID'
		SET @FldGoodsName = '[pub].[funGetGoodsName](S.GoodsID,' + LTrim(RTrim(@LangID)) + ')'
	End
	
	---------------------------------------------

	-- Where Clause ------------------------------------------------------------
	if (@SaleTypeID is not null)
		if (@ZeroPrice = 1)
			set @StrWhere = '( (S.SaleTypeID Is Null) OR (S.SaleTypeID = ''' + @SaleTypeID + ''') )'
		else
			set @StrWhere = '(S.SaleTypeID = ''' + @SaleTypeID + ''')'
	else
		set @StrWhere = '(1=1)'

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, @FldGoodsID) 

	If (@PriceFr Is Not Null) OR (@PriceTo Is Not Null)
		If (@PriceFr = @PriceTo)
			SET @StrWhere = @StrWhere + ' AND (S.SalePrice = ' + LTrim(Str(@PriceFr)) + ')'
		Else
		begin
			If (@PriceFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (S.SalePrice >= ' + LTrim(Str(@PriceFr)) + ')'
			If (@PriceTo Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (S.SalePrice <= ' + LTrim(Str(@PriceTo)) + ')'
		end

	If (@ZeroPrice = 0)
		SET @StrWhere = @StrWhere + ' AND (SalePrice <> 0) '
		
	If (@ZeroRemain = 0)
		SET @StrWhere = @StrWhere + ' AND (' + @FldGoodsID + ' In 
									  (Select T.GoodsID From
											(Select D.GoodsID, 
												   SUM(CASE WHEN D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) TotalQuantityInput,
												   SUM(CASE WHEN D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) TotalQuantityOutput,
												   SUM(CASE WHEN D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) -
												   SUM(CASE WHEN D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) As GoodsRemain   
											 From inv.tblStorageDocsDtl D
											 Group by D.GoodsID) T
										Where T.GoodsRemain > 0)) '		
										
	------------------------------------------------------------

	-- From Clause -------------------------------------------
	If (@ZeroPrice = 1)
		SET @StrFrom = '[inv].[tblGoodsDtl] G
				LEFT JOIN [sal].[tblGoodsPricesDtl] S ON G.GoodsID = S.GoodsID AND G.LanguageID = ' + @LangID
	Else
		SET @StrFrom = '[sal].[tblGoodsPricesDtl] S '
	----------------------------------------------------------
   set @SalePriceTax = 0
	-- Select Clause -------------------------------------------
	If (@SaleTypeID is not null)
	begin
	set @price = 'IsNull(S.SalePrice, 0)'	
	
	end
		
	Else
	begin
	set @price = 'null'
	set @Value='null'
	end
	
	SET @StrSelect = '
		SELECT T.*, 
			   U.UnitName, 
			   IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode, 
			   G.TechnicalSpecifications, 
			   G.ExtraField1, 
			   G.ExtraField2, 
			   G.ExtraField3, 
			   G.ExtraField4, 
			   G.ExtraField5, 
			   (SELECT SUM(GoodsQuantity * EnterKind)
			    FROM inv.tblStorageDocsDtl
				WHERE GoodsID = T.GoodsID) BalanceQty,
			   ISNULL(UPI.UParams,'''') UserPrice, 
			   b.UnitName UnitName2,
			   UnitValue,
			   MainUnitValue,
			   NULL GoodsImage,
			   CASE WHEN G.ContainTax = 1 THEN ROUND(('+CAST (@Value AS NVARCHAR(500))+' * ISNULL(T.SalePrice, 0))/100 ,2) + T.SalePrice ELSE 0 END AS SalePriceTax,
			   '+ LTrim(RTrim(Str(@ShowImage))) +' ShowImage
		FROM (SELECT ' + @FldGoodsID + ', ' + @price + ' as SalePrice,
					 PriceDate,
					 ' + @FldGoodsName + ' GoodsName,-- S.UserPriceID, 
					 S.UserPrice UserPrice2,
					 DescDtl
			  FROM ' + @StrFrom + '
			  WHERE	' + @StrWhere + ') T 
		INNER JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(T.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = G.UnitID AND U.LanguageID = ' + @LangID + '
		LEFT JOIN inv.tblGoodsUserPrice UPI on T.GoodsID = UPI.GoodsID   and UPI.UserPrice=T.UserPrice2 --and T.UserPriceID = UPI.ID 
		LEFT JOIN  (Select * From inv.tblSubUnitsDtl where ShowInInvoice=' + @LangID + ')a on G.GoodsID =a.GoodsID 
		LEFT JOIN (Select * From  inv.tblUnitsDtl where LanguageID=1 )b on a.SubUnitID=b.UnitID '
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
END
GO
