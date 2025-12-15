USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1391/05/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : آمار فروش ویزیتورها - کالاها
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_VisitorSaleStats_Goods]
	@ProcessID		Int = 90,  -- default is sale
	@ProcessNo		Int = Null,
	@FiscalFr		Int = Null,
	@SerialFr		Int = Null,
	@FiscalTo		Int = Null,
	@SerialTo		Int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SaleTypeID		VarChar(20) = Null, -- کد نوع فروش
	@CustKindID		VarChar(20) = Null, --
	@SelectedGoods	Int = 0, 
	@SelectedStore	Int = 0, 
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0, 
	@SelectedVist1	Int = 0, 
	@SelectedVist2	Int = 0, 
	@SelectedVist3	Int = 0, 
	@SelectedVist4	Int = 0, 
	@SortFields		VarChar(100) = Null,
	@RepOptions		VarChar(20) = '1111', -- bit array options
	@RepInfo		VarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(max);
DECLARE @StrFrom		NVarChar(2000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrWhereRets	NVarChar(2000);
DECLARE @@StrSelectRets	NVarChar(2000);

DECLARE @StrQty			VarChar(2000);
DECLARE @StrPrc			VarChar(2000);

DECLARE @ShowQuantity	Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		Bit;  -- شامل ستون قیمت
DECLARE @DecReturn		Bit;  -- کسر برگشتیها
DECLARE @DecDisc		Bit; 

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@DocStep		Int; -- مرحله

DECLARE @WithoutVisitor	Bit; 

Begin --============== S T A R T  C O D E ===================================================

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
	
	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '110001';
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1;
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@SortFields	Is Null)	SET @SortFields = 'VisitorAcntCode';

	IF (@SelectedGoods Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null)	SET @SelectedStore = 0;
	IF (@SelectedAcnt1 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)	SET @SelectedAcnt4 = 0;
	IF (@SelectedVist1 Is Null)	SET @SelectedVist1 = 0;
	IF (@SelectedVist2 Is Null)	SET @SelectedVist2 = 0;
	IF (@SelectedVist3 Is Null)	SET @SelectedVist3 = 0;
	IF (@SelectedVist4 Is Null)	SET @SelectedVist4 = 0;

	If (@FiscalFr Is Null)	SET @SerialFr = Null;
	If (@FiscalTo Is Null)	SET @SerialTo = Null;
	If (@SerialFr Is Null)	SET @FiscalFr = Null;
	If (@SerialTo Is Null)	SET @FiscalTo = Null;

	SET @ShowQuantity	= Substring(@RepOptions, 1, 1);
	SET @ShowPrice		= Substring(@RepOptions, 2, 1);
	SET @DecReturn		= Substring(@RepOptions, 3, 1);
	SET @DecDisc		= Substring(@RepOptions, 4, 1);
	SET @DocStep		= Substring(@RepOptions, 5, 1);
	SET @WithoutVisitor	= Substring(@RepOptions, 6, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	IF @WithoutVisitor = 1
	Begin
		Set @StrWhere = '(D.ProcessID=' + LTrim(Str(@ProcessID)) + ')'
		Set @StrWhereRets = '(ProcessID = 100)'
	End
	ELSE
	Begin
		Set @StrWhere = '(D.ProcessID=' + LTrim(Str(@ProcessID)) + ') AND (H.VisitorAcntCode Is Not Null) AND (H.VisitorAcntCode <> '''')'
		Set @StrWhereRets = '(ProcessID = 100) AND (VisitorAcntCode Is Not Null) AND (VisitorAcntCode <> '''')'
	End

	IF (@ProcessNo Is Not Null)
	Begin
		Set @StrWhere = @StrWhere + ' AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'
		Set @StrWhereRets = @StrWhereRets + ' AND (ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'
	End
	
	IF (@DocStep is not null) and (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep>=' + LTrim(Str(@DocStep)) + ')'

	if (@CustKindID is not null)
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(D.AcntCode)=''' + @CustKindID + ''')'

	IF (@SerialFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialFr)) + '))'
	IF (@SerialTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialTo)) + '))'

	IF (@DocDateFr Is Not Null)
	Begin
		Set @StrWhere = @StrWhere + ' AND (D.DocDate>=''' + @DocDateFr + ''')'
		Set @StrWhereRets = @StrWhereRets + ' AND (DocDate >= ''' + @DocDateFr + ''')'
	End
	IF @DocDateTo Is Not Null
	Begin
		Set @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @DocDateTo + ''')'
		Set @StrWhereRets = @StrWhereRets + ' AND (DocDate<=''' + @DocDateTo + ''')'
	End

	If (@SaleTypeID Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.SaleTypeID=''' + @SaleTypeID + ''')'

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	--If (@SelectedVist1 > 0) OR (@SelectedVist2 > 0) OR (@SelectedVist3 > 0) OR (@SelectedVist4 > 0)
	--Begin
	--	SET @StrWhere = @StrWhere + 'AND (VisitorAcntCode Is Not Null) AND (VisitorAcntCode <> '''')'
	--	SET @StrWhereRets = @StrWhereRets + 'AND (VisitorAcntCode Is Not Null) AND (VisitorAcntCode <> '''')'
	--End

	If (@SelectedVist1 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist1, 'H.VisitorAcntCode') + ')'
		SET @StrWhereRets = @StrWhereRets + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist1, 'VisitorAcntCode') + ')'
	End
		
	If (@SelectedVist2 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist2, 'H.VisitorAcntCode') + ')'
		SET @StrWhereRets = @StrWhereRets + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist2, 'VisitorAcntCode') + ')'
	End
	
	If (@SelectedVist3 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist3, 'H.VisitorAcntCode') + ')'
		SET @StrWhereRets = @StrWhereRets + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist3, 'VisitorAcntCode') + ')'
	End
	If (@SelectedVist4 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist4, 'H.VisitorAcntCode') + ')'
		SET @StrWhereRets = @StrWhereRets + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVist4, 'VisitorAcntCode') + ')'
	End
	
	---------------------------------------------------------
	set @StrQty = 'D.GoodsQuantity'
	set @StrPrc	= '(D.GoodsQuantity*D.GoodsPrice)'
	
	Set @@StrSelectRets = '0 RetsQty, 0 RetsPrice, '
	
	IF (@DecReturn = 1)
	BEGIN
		SET @@StrSelectRets	= ' 
			(Select SUM(GoodsQuantity)
			 From inv.tblStorageDocsDtl 
			 Where ' + @StrWhereRets + ') RetsQty,
			(Select SUM(GoodsQuantity * GoodsPrice)
			 From inv.tblStorageDocsDtl 
			 Where ' + @StrWhereRets + ') RetsPrice,'
	END

	IF (@DecDisc = 1)
	BEGIN
		--SET @StrQty = @StrQty
		SET @StrPrc	= @StrPrc + ' - D.DiscountDtl'
	END
	
	-- SELECT Clause ----------------------------------------
	SET @StrSelect = '
	select	D.VisitorAcntCode, D.GoodsID, 
			[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		    IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, 
			pub.GetCodeName(D.VisitorAcntCode, ' + @LangID + ') VisitorAcntName,
			
			Sum(Quantity) SumQuantity, 
			Sum(Price) SumPrice, ' + 
			@@StrSelectRets + '
			(Select Sum(TaxOverWorthCost) From inv.tblStorageDocsHdr 
			 Where ProcessID=90 And ProcessNo=10 And (VisitorAcntCode Is Not Null) And (VisitorAcntCode <> '''') And
				   VisitorAcntCode = D.VisitorAcntCode) TaxOverWorthCost,
			(Select Sum(TollOverWorthCost) From inv.tblStorageDocsHdr 
			 Where ProcessID=90 And ProcessNo=10 And (VisitorAcntCode Is Not Null) And (VisitorAcntCode <> '''') And
				   VisitorAcntCode = D.VisitorAcntCode) TollOverWorthCost			
	from
	(
		select	H.VisitorAcntCode, D.GoodsID, 
				(' + @StrQty + ') Quantity, 
				(' + @StrPrc + ') Price,
				H.TaxOverWorthCost HdrTaxOverWorthCost, H.TollOverWorthCost HdrTollOverWorthCost,
				D.TaxOverWorthCostDtl DtlTaxOverWorthCost, D.TollOverWorthCostDtl DtlTollOverWorthCost				
		from	inv.tblStorageDocsDtl D 
		inner join inv.tblStorageDocsHdr H ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo
		where ' + @StrWhere + '
	) D	
	LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	group by D.VisitorAcntCode, D.GoodsID, G.GoodsName '
	------------------------------------------------------------
	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + ' 
	order by ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
