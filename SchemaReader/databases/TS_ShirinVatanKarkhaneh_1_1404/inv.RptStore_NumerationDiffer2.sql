USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ==================
-- Author		 : TakroSyatem\Zia
-- Create date   : 1390/08/01
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : لیست مغایرت دو انبار گردانی 
-- ============================================
Create PROCEDURE [inv].[RptStore_NumerationDiffer2] 
	@SerialNo1		int,
	@SerialNo2		int,
	@SelectedGoods	int = 0,
	@SortFields		NVarChar(100) = Null,
	@RepOptions		NVarChar(100) = '11001', 
	@RepInfo		NVarChar(100) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhereSD	NVarChar(2000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StoreID	NVarChar(20);

DECLARE @AllGoods1	Bit; -- تمام کالاهای برگ 1
DECLARE @AllGoods2	Bit; -- تمام کالاهای برگ 2
DECLARE @Decrease	Bit; -- کاهش ها
DECLARE @Increase	Bit; -- افزایش ها
DECLARE @DontFilt	Bit; -- همه کالاها

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@Decimlas	Int;

--DECLARE @ShowPE		Bit; -- مجوزها دخیل نباشد

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

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
	-- Init Variables --------------------------------
	if (@RepInfo	Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions Is Null)	set @RepOptions = '11001';
	if (@SortFields Is Null)	set @SortFields = 'GoodsID';
	if (@SelectedGoods Is Null)	set @SelectedGoods = 0

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @AllGoods1	= Substring(@RepOptions, 1, 1);
	set @AllGoods2	= Substring(@RepOptions, 2, 1);
	set @Decrease	= Substring(@RepOptions, 3, 1);
	set @Increase	= Substring(@RepOptions, 4, 1);
	set @DontFilt	= Substring(@RepOptions, 5, 1);
	--set @ShowPE		= Substring(@RepOptions, 6, 1);

	set		@Decimlas = 2;
	select	@Decimlas = SettingValue
	from	pub.tblSettings
	where	SettingKey = 'QuantityDecimals'
	----------------------------------------------------------
	-- init Clause -------------------------------------------
	create table #tbl_StoreNumerationDiffer2_Result
	(
		GoodsID		varchar(20) collate arabic_cs_as not null,
		StoreID		varchar(20) collate arabic_cs_as not null,
		DocDate     char(10),
		Quantity1	float not null,
		Quantity2	float not null
	);

	if (@AllGoods1 = 1)
	insert into #tbl_StoreNumerationDiffer2_Result(GoodsID,StoreID,DocDate, Quantity1, Quantity2)
	select GoodsID,StoreID,DocDate, GoodsQuantity, 0
	from inv.tblStoresNumerationDtl
	where SerialNo = @SerialNo1

	if (@AllGoods2 = 1)
	insert into #tbl_StoreNumerationDiffer2_Result(GoodsID,StoreID,DocDate, Quantity1, Quantity2)
	select GoodsID,StoreID,DocDate, 0, GoodsQuantity
	from inv.tblStoresNumerationDtl
	where SerialNo = @SerialNo2

	if (@AllGoods1 = 1) and (@AllGoods2 = 0)
	insert into #tbl_StoreNumerationDiffer2_Result(GoodsID,StoreID,DocDate, Quantity1, Quantity2)
	select GoodsID,StoreID,DocDate, 0, GoodsQuantity
	from inv.tblStoresNumerationDtl
	where SerialNo = @SerialNo2 and GoodsID in (select GoodsID from inv.tblStoresNumerationDtl where SerialNo = @SerialNo1)

	if (@AllGoods1 = 0) and (@AllGoods2 = 1)
	insert into #tbl_StoreNumerationDiffer2_Result(GoodsID,StoreID,DocDate, Quantity1, Quantity2)
	select GoodsID,StoreID,DocDate, GoodsQuantity, 0
	from inv.tblStoresNumerationDtl
	where SerialNo = @SerialNo1 and GoodsID in (select GoodsID from inv.tblStoresNumerationDtl where SerialNo = @SerialNo2)

	if (@AllGoods1 = 0) and (@AllGoods2 = 0)
	insert into #tbl_StoreNumerationDiffer2_Result(GoodsID,StoreID,DocDate, Quantity1, Quantity2)
	select GoodsID,StoreID,DocDate, GoodsQuantity, 0
	from inv.tblStoresNumerationDtl
	where SerialNo = @SerialNo1 and GoodsID not in (select GoodsID from inv.tblStoresNumerationDtl where SerialNo = @SerialNo2)
	union all
	select GoodsID,StoreID,DocDate, 0, GoodsQuantity
	from inv.tblStoresNumerationDtl
	where SerialNo = @SerialNo2 and GoodsID not in (select GoodsID from inv.tblStoresNumerationDtl where SerialNo = @SerialNo1)
	--------------------------------------------------
	-- Where Clause ----------------------------------
	set @StrWhere = '(1=1)';

	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		
	--If (@ShowPE = 1) 
	--	SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected=1)'		
		
	--------------------------------------------------------------
	-- Select Clause ---------------------------------------------
	SET @StrSelect = '
		SELECT	D.GoodsID, pub.funGetGoodsName(D.GoodsID,' + @LangID + ') GoodsName, U.UnitName,
				round(sum(D.Quantity1),' + str(@Decimlas) + ') Quantity1, round(sum(D.Quantity2), ' + str(@Decimlas) + ') Quantity2,
				[inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,D.StoreID,D.GoodsID,'''',D.DocDate,0) realGoodsRemain
		FROM	#tbl_StoreNumerationDiffer2_Result D
					left join inv.tblGoods G on G.GoodsID =  SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
					left join inv.tblUnitsDtl U on U.UnitID = G.UnitID AND U.LanguageID = ' + @LangID + '
		WHERE	' + @StrWhere + '
		GROUP BY D.GoodsID,D.StoreID, U.UnitName,D.DocDate'

	if (@DontFilt = 0)
	begin
		if (@Increase = 1) AND (@Decrease = 1)
			set @StrWhere = '(Quantity1 <> Quantity2)'

		if (@Increase = 1) AND (@Decrease = 0)
			set @StrWhere = '(Quantity1 > Quantity2)'

		if (@Increase = 0) AND (@Decrease = 1)
			set @StrWhere = '(Quantity1 < Quantity2)'

		if (@Increase = 0) AND (@Decrease = 0)
			set @StrWhere = '(Quantity1 = Quantity2)'

		SET @StrSelect = '
		select	*
		from	(' + @StrSelect + ') T
		where	(' + @StrWhere + ')'
	end;
	------------------------------------------------------------
	-- Sort Clause ---------------------------------------------
	SET @StrSelect = @StrSelect + ' 
	order by ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
