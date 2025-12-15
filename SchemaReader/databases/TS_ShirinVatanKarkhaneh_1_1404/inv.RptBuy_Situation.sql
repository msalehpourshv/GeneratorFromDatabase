USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid	
-- Create date   : 1394/09/10
-- Viewed By		 : Hadi Sadeghi
-- Last Modified : 
-- Last Modifier : 
-- Description   : گزارش وضعیت یک خرید
-- =============================================
CREATE PROCEDURE [inv].[RptBuy_Situation]
	@ProcessID				Int = 55, 
	@ProcessNo				Int = 1,
	@FiscalYearFr			Int = Null,
	@SerialNoFr				Int = Null,
	@FiscalYearTo			Int = Null,
	@SerialNoTo				Int = Null,
	@DocDateFr				Char(10) = Null,
	@DocDateTo				Char(10) = Null,
	@SelectedGoods			Int = 0, 
	@SelectedAcnt1			Int = 0, 
	@SelectedAcnt2			Int = 0, 
	@SelectedAcnt3			Int = 0, 
	@SelectedAcnt4			Int = 0,
	@RepInfo				NVarChar(100) = '1@1@1',
	@ExtraParams			NVarChar(500) = ''

WITH ENCRYPTION
AS
Declare @StrSelect	NVarChar(Max);
Declare @StrSelect1	NVarChar(Max);
Declare @StrSelect2	NVarChar(Max);
Declare @StrSelect3	NVarChar(Max);
Declare @StrWhere	NVarChar(Max);
Declare @StrWhere2	NVarChar(Max);
Declare @StrWhere3	NVarChar(Max);

Declare @StrGoodsID		VarChar(100);
Declare @StrGoodsName	VarChar(100);
Declare @StrQuantity	VarChar(100);
Declare @StrGoodsUnit	VarChar(100);
Declare @StrOrderDuration VarChar(100);
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

Begin --============== S T A R T  C O D E ===================================================

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	Set NoCount On;
	
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
	
	-- I N I T ----------------------------------------------------------------
	IF (@ProcessNo  Is Null) SET @ProcessNo  = 1;
	IF (@RepInfo	Is Null) SET @RepInfo	= '1@1@1';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;

	IF (@SelectedAcnt1	 	 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	 	 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	 	 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	 	 Is Null)	SET @SelectedAcnt4 = 0;
	
	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = 'C.ProcessID = ' + LTrim(Str(@ProcessID)) + ' AND C.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (C.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(C.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND C.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (C.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(C.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND C.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (C.DocDate = ''' + @DocDateFr + ''')'
		Else
		Begin
			IF (@DocDateFr Is Not Null) 
				SET @StrWhere = @StrWhere + ' AND (C.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (C.DocDate <= ''' + @DocDateTo + ''')'
		End
		
	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'C.GoodsID') 
		
	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'C.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'C.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'C.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'C.AcntCode')
				
	---------------------------------------------------------------------------

	---- S E L E C T ----------------------------------------------------------
	Set @StrSelect1 = '
	Select C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.GoodsID, 
		   [pub].[funGetGoodsName](C.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (C.GoodsID), '''') BarCode, IsNull(Sum(C.SubUnitQuantity),0) As SubUnitQuantity, 
		   IsNull(Sum(S.SubUnitQuantity),0) As BuyRetQuantity, 
		   Case When S.DocStep >= 1 Then ''True'' Else ''False'' End As CountBuy,
		   Case When S.DocStep >= 2 Then ''True'' Else ''False'' End As PriceBuy,
		   (Select Count(VchNo) From inv.tblStorageDocsHdr Where BaseProcessID = C.ProcessID And BaseProcessNo = C.ProcessNo And 
														  BaseFiscalYear = C.FiscalYear And BaseSerialNo = C.SerialNo And
														  VchNo > 0) AS HasVchNo
	From inv.tblStorageDocsDtl C

	--================ برگشت از خرید
	LEFT JOIN inv.tblStorageDocsDtl S ON S.BaseProcessID = C.ProcessID And S.BaseProcessNo = C.ProcessNo And S.BaseFiscalYear = C.FiscalYear And 
									     S.BaseSerialNo = C.SerialNo And S.BaseDocRowNo = C.DocRowNo	

	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(C.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	Where ' + @StrWhere + '
	Group By C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.GoodsID, GD.GoodsName, S.DocStep '

	---- R U N ----------------------------------------------------------------
	--Print '--================================================'
	Print @StrSelect1;
	Exec sp_executesql @StrSelect1;
	---------------------------------------------------------------------------
End
GO
