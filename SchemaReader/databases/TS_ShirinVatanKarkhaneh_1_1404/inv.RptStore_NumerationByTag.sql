USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/12/06
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : تگ انبارگردانی
-- ==============================================
Create PROCEDURE [inv].[RptStore_NumerationByTag]
	@StoreID		VarChar(20),
	@SelectedGoods	Int = 0,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@RepOptions		VarChar(20) = '1101', -- bit array options
	@SortFields		NVarChar(100) = 'GoodsID',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrWhereD	NVarChar(4000);
DECLARE @StrWhereB	NVarChar(4000);

DECLARE @StrYear	Char(4);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

declare @ShowZA		Bit; -- شامل سطرهای مبلغ صفر
declare @ShowZQ		Bit; -- شامل سطرهای موجودی صفر
declare @ShowPE		Bit; -- مجوزها دخیل نباشد
declare @AllGoods	Bit; -- تمام کالاها
declare @IsCodeClosed	Bit; -- کالاهاي مسدود نشان داده نشود
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
		--==============	
	Declare @intIsMultiGoods AS Tinyint
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	-- Init Variables ----------------------------------------------------------
	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	IF (@StoreID Is Null)		SET @StoreID = '';
	IF (@RepOptions Is Null)	SET @RepOptions = '11010';

	SET @ShowZA		= Substring(@RepOptions, 1, 1);
	SET @ShowZQ		= Substring(@RepOptions, 2, 1);
	SET @ShowPE		= Substring(@RepOptions, 3, 1);
	SET @AllGoods	= Substring(@RepOptions, 4, 1);
	SET @IsCodeClosed	= Substring(@RepOptions, 5, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @intIsMultiGoods = 0
	
	SET @StrYear = LTrim(RIGHT(db_name(), 4));
	----------------------------------------------------------------------------

	-- Where Clause ------------------------------------------------------------
	create table #tbl_Store_NumerationByTag_Goods
	(
		GoodsID varchar(20) collate arabic_cs_as not null
	);

	
	Select @intIsMultiGoods = Layer1 
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 2 
	
	IF @intIsMultiGoods > 0 And @intIsMultiGoods < 20
		set @AllGoods = 0 

	if (@AllGoods = 0)
	begin
		SET @StrWhereD = '(D.FiscalYear = ' + @StrYear + ')';
		
		If (@ShowPE = 1) 
			SET @StrWhereD = @StrWhereD + ' AND (D.PhysicallyEffected=1)'

		If (@AllGoods = 0)
			SET @StrWhereD = @StrWhereD + ' AND (D.StoreID=''' + @StoreID + ''') '

		If (@DocDateTo Is Not Null)
			SET @StrWhereD = @StrWhereD + ' AND (D.DocDate<>'''') AND (D.DocDate<=''' + @DocDateTo + ''')'

		If (@ShowZA = 0) 
			SET @StrWhereD = @StrWhereD + ' AND (D.GoodsAmount<>0) '

		SET @StrWhereB = @StrWhereD;

		If (@DocDateFr Is Not Null)
			SET @StrWhereD = @StrWhereD + ' AND (D.DocDate<>'''') AND (D.DocDate>=''' + @DocDateFr + ''')'

		If (@SelectedGoods > 0)
			SET @StrWhereD = @StrWhereD + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
			

			
		SET @StrSelect = '
		insert into #tbl_Store_NumerationByTag_Goods
		select distinct D.GoodsID 
		from inv.tblStorageDocsDtl D 
		where ' + @StrWhereD 
		
		-- Run -----------------------------------------------------
		print @StrSelect;
		Exec sp_executesql @StrSelect;
		------------------------------------------------------------
	end;

	SET @StrWhere = '(1=1)  and (select Count(*) from  inv.tblGoods D where substring (D.GoodsID,1,len (GH.GoodsID))=GH.GoodsID and  Len(GH.GoodsID)<LEN(D.GoodsID) )=0';

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'GH.GoodsID') 
	if (@AllGoods = 0) and (@ShowZQ=0)
		SET @StrWhere = @StrWhere + ' AND isnull((select sum(GoodsQuantity*EnterKind) from inv.tblStorageDocsDtl D where D.GoodsID=GH.GoodsID and ' + @StrWhereB + '),0) > 0 '
	
	If (@IsCodeClosed =1)
			SET @StrWhere  = @StrWhere  + ' AND GH.CodeClosed=0'
			
			
	----------------------------------------------------------------------------------
	-- Select Clause -----------------------------------------------------------------------------------------
	IF @intIsMultiGoods > 0 And @intIsMultiGoods < 20
	BEGIN
		
		SET @StrSelect = '
		SELECT	GH.GoodsID,G.SalePrice,G.BuyPrice, pub.funGetGoodsName(GH.GoodsID,' + @LangID + ') GoodsName, UD.UnitName, G.TechnicalNo, PD.PlaceName,G.BarCode
		FROM	#tbl_Store_NumerationByTag_Goods GH 
				left  join inv.tblGoods G ON G.GoodsID = SUBSTRING(GH.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
				left  join inv.tblUnitsDtl UD ON UD.UnitID = G.UnitID 
				left  join inv.tblGoodsStatusDtl GS ON GS.GoodsID = GH.GoodsID AND GS.StoreID = ''' + @StoreID + '''
				left  join inv.tblStorePlacesDtl PD ON PD.StoreID = GS.StoreID AND PD.PlaceID = GS.PlaceID 
		WHERE 	' + @StrWhere 

	END
	ELSE
	BEGIN
		set @StrFrom = '';
		if (@AllGoods = 0)
			SET @StrFrom = @StrFrom + ' 
			inner join #tbl_Store_NumerationByTag_Goods T on T.GoodsID=GH.GoodsID ';

	
		SET @StrSelect = '
		SELECT	GD.GoodsID,GH.SalePrice,GH.BuyPrice, GD.GoodsName, UD.UnitName, GH.TechnicalNo, PD.PlaceName,GH.BarCode
		FROM	inv.tblGoods GH 
				inner join inv.tblGoodsDtl GD ON GD.GoodsID = GH.GoodsID 
				left  join inv.tblUnitsDtl UD ON UD.UnitID = GH.UnitID 
				left  join inv.tblGoodsStatusDtl GS ON GS.GoodsID = GD.GoodsID AND GS.StoreID = ''' + @StoreID + '''
				left  join inv.tblStorePlacesDtl PD ON PD.StoreID = GS.StoreID AND PD.PlaceID = GS.PlaceID ' + @StrFrom + '
		WHERE 	' + @StrWhere 
		-------------------------------------------------------------------------------------------------------------


	END
	-- Sort Clause -------------------------------------------
	If (@SortFields Is Not Null) AND (@SortFields <> '') 
		SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
