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
Create PROCEDURE [sal].[RptSale_PriceList]
	@SelectedGoods	Int = 0,
	@PriceFr		BigInt = Null,
	@PriceTo		BigInt = Null,
	@SaleTypeID		int = 0,
	@ZeroPrice		Bit = 1,	-- شامل سطرهای با مبلغ صفر
	@SortFields		NVarChar(100) = Null,
	@RepInfo		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(max);
DECLARE @StrWhere		NVarChar(max);
DECLARE @StrWhereGoods	NVarChar(max);
DECLARE @StrFrom		NVarChar(max);
DECLARE @FldGoodsID		VarChar(20);
DECLARE @FldGoodsName	NVarChar(100);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@price			NVarChar(500);

	If (@ZeroPrice = 1)
	Begin
		SET @FldGoodsID = 'G.GoodsID'
		SET @FldGoodsName = '[pub].[funGetGoodsName](G.GoodsID, ' + LTrim(RTrim(@LangID)) + ')'
	End
	Else
	Begin
		SET @FldGoodsID = 'S.GoodsID'
		SET @FldGoodsName = '[pub].[funGetGoodsName](S.GoodsID, ' + LTrim(RTrim(@LangID)) + ')'
	End

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
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	If (@ZeroPrice = 1)
	Begin
		SET @FldGoodsID = 'G.GoodsID'
		SET @FldGoodsName = '[pub].[funGetGoodsName](G.GoodsID, ' + LTrim(RTrim(@LangID)) + ')'
	End
	Else
	Begin
		SET @FldGoodsID = 'S.GoodsID'
		SET @FldGoodsName = '[pub].[funGetGoodsName](S.GoodsID, ' + LTrim(RTrim(@LangID)) + ')'
	End
	---------------------------------------------
	set @StrWhereGoods = ''
	-- Where Clause ------------------------------------------------------------
	IF (@SelectedGoods > 0)
		SET @StrWhereGoods = ' WHERE ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, @FldGoodsID) 

	set @StrWhere = '(1=1)'
	
	IF (@SaleTypeID > 0)
		begin
			if (@ZeroPrice = 1)
				SET @StrWhere = @StrWhere + ' And ( (S.SaleTypeID Is Null) OR ' + pub.funGetFilterString(@SessionNo, @ReportID, @SaleTypeID, 'S.SaleTypeID ') + ' )'
			else
				SET @StrWhere = @StrWhere + ' And ' + pub.funGetFilterString(@SessionNo, @ReportID, @SaleTypeID, 'S.SaleTypeID ') 
		end 
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
		
	------------------------------------------------------------

	-- From Clause -------------------------------------------
	If (@ZeroPrice = 1)
		SET @StrFrom = '[inv].[tblGoodsDtl] G
				LEFT JOIN (SELECT * FROM [sal].[tblGoodsPricesDtl] S WHERE ' + @StrWhere + ')  S ON G.GoodsID = S.GoodsID AND G.LanguageID = ' + @LangID
	Else
		SET @StrFrom = '(SELECT * FROM [sal].[tblGoodsPricesDtl] S WHERE ' + @StrWhere + ')  S '
	----------------------------------------------------------

	-- Select Clause -------------------------------------------
	If (@SaleTypeID>0)
		set @price = 'IsNull(S.SalePrice, 0)'
	Else
		set @price = 'null'
	
	SET @StrSelect = '
		SELECT T.*,U.UnitID, U.UnitName,CASE WHEN  UDS.GoodsID IS NULL THEN U.UnitID ELSE UDS.SubUnitID END SubUnitID 
			         ,ISNULL(U2.UnitName,'''') SubUnitName,isnull(UDS.UnitValue,1) UnitValue ,isnull(UDS.MainUnitValue,1) MainUnitValue, IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode, 
			   G.TechnicalSpecifications, G.ExtraField1, G.ExtraField2, G.ExtraField3, 
			   G.ExtraField4, G.ExtraField5, 
				(
					select sum(GoodsQuantity*EnterKind)
					from inv.tblStorageDocsDtl
					where GoodsID=T.GoodsID
				) BalanceQty ,IsNull(UPI.UParams,'''') UserPrice, IsNull(G.BuyPrice,0) GBuyPrice, IsNull(G.SalePrice,0) GSalePrice
				,BarCodeImage,QRCodeImage
		FROM
		(
			SELECT DISTINCT ' + @FldGoodsID + ', ' + @price + ' as SalePrice, ' + @FldGoodsName + ' GoodsName, S.UserPriceID,DescDtl
			FROM	' + @StrFrom + '
			  	    ' + @StrWhereGoods + '
		) T 
		INNER JOIN inv.tblGoods G ON G.GoodsID=SUBSTRING(T.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		LEFT  JOIN inv.tblUnitsDtl U ON U.UnitID = G.UnitID AND U.LanguageID = ' + @LangID + '
		LEFT  JOIN inv.tblGoodsUserPrice UPI on T.GoodsID = UPI.GoodsID and T.UserPriceID = UPI.ID 
		left  JOIN inv.tblSubUnitsDtl UDS ON G.GoodsID=UDS.GoodsID AND UDS.ShowInInvoice=1
		Left  join inv.tblUnitsDtl U2 on U2.UnitID = UDS.SubUnitID AND U2.LanguageID =  1
		LEFT  JOIN rpt.tblBarCodeImage BC	ON BC.BarCode = T.GoodsID and BC.SessionNo='+ str(@SessionNo)+' and BC.ReportID='+ str(@ReportID)+' and BC.UserPriceID = isnull(T.UserPriceID,0)
		LEFT  JOIN rpt.tblQRCodeImage QR	ON QR.QRCode = T.GoodsID and QR.SessionNo='+ str(@SessionNo)+' and QR.ReportID='+ str(@ReportID)+' and QR.UserPriceID = isnull(T.UserPriceID,0)
		'
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
