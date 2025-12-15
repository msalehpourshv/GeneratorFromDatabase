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
Create PROCEDURE [sal].[RptSale_PriceList2_2]
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
DECLARE @StrSelect		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(MAX);
DECLARE @StrWhere2		NVarChar(MAX);
DECLARE @StrWhere3		NVarChar(MAX);
DECLARE @StrWhere4		NVarChar(MAX);
DECLARE @StrFrom		NVarChar(4000);
DECLARE @FldGoodsID		VarChar(200);
DECLARE @FldUnitID		VarChar(200);
DECLARE @FldGoodsName	NVarChar(100);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@price			NVarChar(500);
DECLARE	@price2			NVarChar(500);
DECLARE	@price3			NVarChar(500);
DECLARE	@UserPriceID1	NVarChar(500);
DECLARE	@UserPriceID2	NVarChar(500);
DECLARE	@UserPriceID3	NVarChar(500);

DECLARE	@ZeroPrice		Bit; -- شامل سطرهای با مبلغ صفر
DECLARE	@ZeroRemain		Bit; -- شامل سطرهای با موجودی صفر
			 
Declare @ShowGoodsImage	Bit;
Declare @ShowSubPrice	Bit;

Declare @SaleTypeID2	VarChar(20);
Declare @SaleTypeID3	VarChar(20);

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
	IF (@RepOptions Is Null)	SET @RepOptions = '110001';
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ZeroPrice		= Substring(@RepOptions, 1, 1);
	SET @ZeroRemain		= Substring(@RepOptions, 2, 1);
	SET @ShowGoodsImage	= Substring(@RepOptions, 3, 1);
	SET @ShowSubPrice	= Substring(@RepOptions, 4, 1);

	SET @SaleTypeID2 = LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @SaleTypeID3 = LTrim(pub.funSplitString(@ExtraParams, '@', 2));

	--If @SaleTypeID2 = ''
	--	Set @SaleTypeID2 = Null
	--If @SaleTypeID3 = ''
	--	Set @SaleTypeID3 = Null		
	--================================
	CREATE TABLE #tbl_Goods_Images
	(
		GoodsID    Varchar(20) COLLATE Arabic_CS_AS,
		GoodsImage Image
	);

	SET @StrSelect = '
	INSERT INTO #tbl_Goods_Images(GoodsID, GoodsImage)
	SELECT GoodsID, GoodsImage
	FROM inv.tblGoodsImages GI'
		
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	

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
	SET @StrWhere = '1 = 1'
	SET @StrWhere2 = ''
	SET @StrWhere3 = ''
	SET @StrWhere4 = ''
	
	IF (@SaleTypeID IS NOT NULL)
	BEGIN
		if (@ZeroPrice = 1)
			set @StrWhere2 = @StrWhere2 + ' And ((S.SaleTypeID Is Null) OR (S.SaleTypeID = ''' + @SaleTypeID + '''))'
		else
			set @StrWhere2 = @StrWhere2 + ' And (S.SaleTypeID = ''' + @SaleTypeID + ''')'
	END
		
	if (@SaleTypeID Is Not Null AND @SaleTypeID2 Is Not Null)
	BEGIN
		if (@ZeroPrice = 1)
			set @StrWhere3 = @StrWhere3 + ' And ((S2.SaleTypeID Is Null) OR (S2.SaleTypeID = ''' + @SaleTypeID2 + '''))'
		else
			set @StrWhere3 = @StrWhere3 + ' And (S2.SaleTypeID = ''' + @SaleTypeID2 + ''')'
	END
			
	if (@SaleTypeID Is Not Null AND @SaleTypeID2 Is Not Null AND @SaleTypeID3 Is Not Null)
	BEGIN
		if (@ZeroPrice = 1)
			set @StrWhere4 = @StrWhere4 + ' And ((S3.SaleTypeID Is Null) OR (S3.SaleTypeID = ''' + @SaleTypeID3 + '''))'
		else
			set @StrWhere4 = @StrWhere4 + ' And (S3.SaleTypeID = ''' + @SaleTypeID3 + ''')'			
	END


	-- ======
	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, @FldGoodsID) 

	IF @ShowSubPrice = '1'
		SET @FldUnitID =  '  ISNULL(SU.SubUnitID,'''') SubUnitID '
	ELSE
		SET @FldUnitID = ' '''' SubUnitID '


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
		SET @StrWhere = @StrWhere + ' AND (S.SalePrice <> 0) '
		
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
	-- From Clause ---------------------------------------------
	If (@ZeroPrice = 1)
	Begin
		SET @StrFrom = '[inv].[tblGoodsDtl] G
						LEFT JOIN [sal].[tblGoodsPricesDtl] S  ON G.GoodsID = S.GoodsID AND G.LanguageID = ' + @LangID + '
						LEFT JOIN [sal].[tblGoodsPricesDtl] S2 ON G.GoodsID = S2.GoodsID AND G.LanguageID = ' + @LangID + ' ' + @StrWhere3 + '
						LEFT JOIN [sal].[tblGoodsPricesDtl] S3 ON G.GoodsID = S3.GoodsID AND G.LanguageID = ' + @LangID + ' ' + @StrWhere4 + '
						LEFT JOIN (SELECT * from inv.tblSubUnitsDtl WHERE ShowInInvoice=1) SU ON S.GoodsID=SU.GoodsID '
	End
	Else
	Begin
		SET @StrFrom = '[sal].[tblGoodsPricesDtl] S 
						LEFT JOIN [inv].[tblGoodsDtl] G ON G.GoodsID = S.GoodsID AND G.LanguageID = ' + @LangID + '
						LEFT JOIN [sal].[tblGoodsPricesDtl] S2 ON G.GoodsID = S2.GoodsID AND G.LanguageID = ' + @LangID + ' ' + @StrWhere3 + ' And S2.SalePrice <> 0 ' + '
						LEFT JOIN [sal].[tblGoodsPricesDtl] S3 ON G.GoodsID = S3.GoodsID AND G.LanguageID = ' + @LangID + ' ' + @StrWhere4 + ' And S3.SalePrice <> 0
						LEFT JOIN (SELECT * from inv.tblSubUnitsDtl WHERE ShowInInvoice=1) SU ON S.GoodsID=SU.GoodsID '		
	End
	
	----------------------------------------------------------

	-- Select Clause -------------------------------------------
	set @price = 'Null'
	set @price2 = 'Null'
	set @price3 = 'Null'
	set @UserPriceID1 = 'Null'
	set @UserPriceID2 = 'Null'
	set @UserPriceID3 = 'Null'

	If (@SaleTypeID IS NOT NULL)
	begin 
		IF @ShowSubPrice = '1'
			set @price = 'CASE WHEN SU.GoodsID IS NULL THEN IsNull(S.SalePrice, 0)ELSE IsNull(S.SalePrice, 0)/SU.UnitValue*SU.MainUnitValue END'
		ELSE
			set @price = 'IsNull(S.SalePrice, 0)'

		--set @UserPriceID1 = ' S.UserPriceID '
	end
	
	If (@SaleTypeID2 IS NOT NULL)
	begin 
		IF @ShowSubPrice = '1'
			set @price2 = 'CASE WHEN SU.GoodsID IS NULL THEN IsNull(S2.SalePrice, 0)ELSE IsNull(S2.SalePrice, 0)/SU.UnitValue*SU.MainUnitValue END'
		ELSE
			set @price2 = 'IsNull(S2.SalePrice, 0)'

		--set @UserPriceID2 = ' S2.UserPriceID '
	end
	If (@SaleTypeID3 IS NOT NULL)
	begin
		IF @ShowSubPrice = '1'
			set @price3 = 'CASE WHEN SU.GoodsID IS NULL THEN IsNull(S3.SalePrice, 0)ELSE IsNull(S3.SalePrice, 0)/SU.UnitValue*SU.MainUnitValue END'
		ELSE
			set @price3 = 'IsNull(S3.SalePrice, 0)'

		--set @UserPriceID3 = ' S3.UserPriceID '
	end
					
	-- ======
	SET @StrSelect = '
		SELECT T.*,CASE WHEN T.SubUnitID='''' THEN U.UnitName ELSE [inv].[funGetUnitName](T.SubUnitID,' + @LangID + ') END UnitName, IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode, G.TechnicalSpecifications, G.ExtraField1, G.ExtraField2, 
			   G.ExtraField3, G.ExtraField4, G.ExtraField5, 
				(
					select sum(GoodsQuantity*EnterKind)
					from inv.tblStorageDocsDtl
					where GoodsID=T.GoodsID
				) BalanceQty ' + 
				Case When @ShowGoodsImage = 1 Then ',GI1.GoodsImage ' Else ',Null As GoodsImage ' End + '
			, isnull(p1.UParams,'''')	UserPrice1, isnull(p2.UParams,'''')	UserPrice2, isnull(p3.UParams,'''')	UserPrice3
			, b.UnitName UnitName2,UnitValue,MainUnitValue
		FROM
		(
			SELECT	' + @FldGoodsID + ', ' + @FldUnitID + ', ' + @FldGoodsName + ' GoodsName' 
					  + ', ' + @price + ' as SalePrice ,S.UserPrice UserPrice11' 
					  + ', ' + @price2 + ' as SalePrice2  ,S2.UserPrice UserPrice22'
					  + ', ' + @price3 + ' as SalePrice3  ,S2.UserPrice UserPrice33'
					  + ', ' + @UserPriceID1 + ' as UserPriceID1 '
					  + ', ' + @UserPriceID2 + ' as UserPriceID2 '
					  + ', ' + @UserPriceID3 + ' as UserPriceID3 '
			+' ,S.[DescDtl] DescDtl1,S2.[DescDtl] DescDtl2,S3.[DescDtl]  DescDtl3 FROM	' + @StrFrom + '
			WHERE	' + @StrWhere + ' ' + @StrWhere2 +'
		) T 
		INNER JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(T.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		left Join  inv.tblGoodsUserPrice p1 On G.GoodsID=p1.GoodsID and p1.UserPrice=T.UserPrice11  --and T.UserPriceID1=p1.ID
		left Join  inv.tblGoodsUserPrice p2 On G.GoodsID=p2.GoodsID and p2.UserPrice=T.UserPrice22 -- and T.UserPriceID2=p2.ID
		left Join  inv.tblGoodsUserPrice p3 On G.GoodsID=p3.GoodsID and p3.UserPrice=T.UserPrice33 --and T.UserPriceID3=p3.ID
		LEFT  JOIN inv.tblUnitsDtl U ON U.UnitID = G.UnitID AND U.LanguageID = ' + @LangID + '
		left join  (Select * From inv.tblSubUnitsDtl where ShowInInvoice=' + @LangID + ')a on G.GoodsID =a.GoodsID 
		LEFT join (Select * From  inv.tblUnitsDtl where LanguageID=1 )b on a.SubUnitID=b.UnitID ' +
	    Case When @ShowGoodsImage = 1 Then ' 
	    LEFT JOIN #tbl_Goods_Images GI1 ON GI1.GoodsID = T.GoodsID ' Else '' End
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
