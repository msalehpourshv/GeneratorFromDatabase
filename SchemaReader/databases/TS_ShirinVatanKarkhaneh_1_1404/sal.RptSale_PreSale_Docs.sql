USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1387/10/01
-- Viewed By	 : 
-- Last Modified : 1393/02/20
-- Last Modifier : TakroSystem\Hamid
-- Description	 : گزارش لیست پیش فاکتورهای فروش
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_PreSale_Docs] 
	@ProcessID			Int = 240,
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = NULL,
	@SerialNoFr			Int = NULL,
	@FiscalYearTo		Int = NULL,
	@SerialNoTo			Int = NULL,
	@DocDateFr			Char(10) = NULL,
	@DocDateTo			Char(10) = NULL,
	@SelectedGoods		Int = NULL,
	@SelectedStore		Int = NULL,
	@SelectedAcnt1		Int = Null, -- انتخاب طرف حساب
	@SelectedAcnt2		Int = Null,
	@SelectedAcnt3		Int = Null,
	@SelectedAcnt4		Int = Null,
	@SelectedVisitor1	Int = NULL,
	@SelectedVisitor2	Int = NULL,
	@SelectedVisitor3	Int = NULL,
	@SelectedVisitor4	Int = NULL,
	@SaleTypeID			VarChar(20) = Null,   -- کد نوع فروش
	@RepOptions			NVarChar(100) = '10', -- bit array (showQty-showPrc)
	@SortFields			NVarChar(100) = Null,
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = ''
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(1000);
Declare @StrWhere	NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@VisitorDocNo	Int;

DECLARE @ShowQuantity	Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		Bit;  -- شامل ستون قیمت
DECLARE @CustKind	VarChar(20);

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--==============
	IF (SELECT COUNT(*) FROM inv.tblPreSaleDtl WHERE ProcessID = @ProcessID AND ProcessNo = @ProcessNo) <= 0 SET @ProcessNo = 1

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
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1'
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;
	IF (@RepOptions Is Null)		SET @RepOptions = '11';

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ShowQuantity	= Substring(@RepOptions, 1, 1);
	SET @ShowPrice		= Substring(@RepOptions, 2, 1);

	SET @CustKind = LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @VisitorDocNo = LTrim(pub.funSplitString(@ExtraParams, '@', 10));
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	Set @StrWhere = ' D.ProcessID = ' + LTrim(Str(@ProcessID))

	If @ProcessNo Is Not Null
		Set @StrWhere = @StrWhere + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	if (@CustKind <> '')
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(D.AcntCode) = ''' + @CustKind + ''')'

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate  = ''' + @DocDateFr + ''')'
		Else 
		Begin
			IF (@DocDateFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		End

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	IF (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	-- Acnt Filter 
	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	-- VisitorAcnt Filter 

	IF (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	IF (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'

	If (@SaleTypeID Is Not Null)
		Set @StrWhere = @StrWhere + ' AND D.SaleTypeID = ''' + @SaleTypeID + ''''
	---------------------------------------------------------
	If (@VisitorDocNo Is Not Null) AND @VisitorDocNo>0
		Set @StrWhere = @StrWhere + ' AND H.VisitorDocNo = ' + LTrim(Str(@VisitorDocNo)) + ''

	
	-- FROM Clause ------------------------------------------
	Set @StrFrom = ' '
	---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
	Set @StrSelect = '
	SELECT	D.GoodsQuantity * D.GoodsAmount AS Price,H.*,D.DocRowNo, pub.GetUserName(H.SessionNo) As UserName, D.GoodsQuantity Quantity, 
			D.GoodsID, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		    IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, S.StoreName, 
			F.CustomerFirstName+'' ''+F.CustomerLastName CustomerName, F.CompanyRegisterNo,D.DiscountPercent As DtlDiscountPercent,
			D.Discount As DtlDiscount, D.Discount2 As DtlDiscount2,
			F.NationalIDNumber, F.EconomicalCode, F.ZipCode, F.Address1, F.Address2,
			IsNull(F.Tel,'''') Tel, F.Mobile,DescDtl,Var1,Var2,Var3,Var4,ConstText1,ConstText2,ConstText3,ConstText4
	FROM  inv.tblPreSaleDtl D 
			INNER JOIN inv.tblPreSaleHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			INNER JOIN inv.tblStoresDtl S ON D.StoreID = S.StoreID AND S.LanguageID = ' + @LangID + '
			OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS F
	WHERE ' + @StrWhere
	------------------------------------------------------------

	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
