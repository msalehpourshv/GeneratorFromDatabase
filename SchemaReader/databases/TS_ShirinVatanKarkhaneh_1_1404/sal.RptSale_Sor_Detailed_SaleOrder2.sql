USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid
-- Create date   : 1392/12/19
-- Viewed By	 : Ahmad Nejad
-- Last Modified : 
-- Last Modifier : 
-- Description   : آمار (یا وضعیت) سفارش کالاها - تفصیلی
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_Sor_Detailed_SaleOrder2] 
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = NULL,
	@SerialNoFr		Int = NULL,
	@FiscalYearTo	Int = NULL,
	@SerialNoTo		Int = NULL,
	@DateFr			Char(10) = NULL,
	@DateTo			Char(10) = NULL,
	@SelectedGoods	Int = NULL,
	@SelectedOrder1	Int = NULL,
	@SelectedOrder2	Int = NULL,
	@SelectedOrder3	Int = NULL,
	@SelectedOrder4	Int = NULL,
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@SalDateFr		Char(10) = NULL,
	@SalDateTo		Char(10) = NULL,
	@GoodsID		Varchar(20) = NULL,	
	@AcntCode		Varchar(20) = NULL,	
	@RepOptions		VarChar(20) = '000102', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhereS	NVarChar(max);
DECLARE @StrWhereX	NVarChar(max);
DECLARE @StrOrder	NVarChar(200);
DECLARE @StrGroup	NVarChar(200);

DECLARE @CodeField	VarChar(20);
DECLARE @NameField	NVarChar(200);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @DocStep		Int;

DECLARE @GroupByGoods	Bit;	-- گروه بندی بر اساس کد کالا باشد؟
DECLARE @GroupByAcnt	Bit;	-- گروه بندی بر اساس کد سفارش دهنده باشد؟
DECLARE @ShowProduce	Bit;    -- در جریان تولید؟
DECLARE @RemainOnly		Bit;	-- فقط سفارشاتی که مانده دارند (سفارش با تحویل برابر نیست) بیاید؟
Declare @DecRet			Bit; 
Declare @SoldOnly		Bit; 
DECLARE @round_val		int;
Begin --============== S T A R T  C O D E ===================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

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
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '000102';
	IF (@ProcessNo	   Is Null) SET @ProcessNo  = 1;

	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;

	IF (@SelectedOrder1 Is Null)	SET @SelectedOrder1 = 0;
	IF (@SelectedOrder2 Is Null)	SET @SelectedOrder2 = 0;
	IF (@SelectedOrder3 Is Null)	SET @SelectedOrder3 = 0;
	IF (@SelectedOrder4 Is Null)	SET @SelectedOrder4 = 0;

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @GroupByGoods	= Substring(@RepOptions, 1, 1);
	SET @GroupByAcnt	= Substring(@RepOptions, 2, 1);
	SET @ShowProduce	= Substring(@RepOptions, 3, 1);
	SET @RemainOnly		= Substring(@RepOptions, 4, 1);
	SET @DecRet			= Substring(@RepOptions, 5, 1);
	SET @DocStep		= Substring(@RepOptions, 6, 1);
	-- 7 is used
	SET @SoldOnly		= Substring(@RepOptions, 8, 1);

	Select @round_val = IsNull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'	
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = ' (D.ProcessID=180) AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DateFr + ''')' 
		
	IF (@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DateTo + ''')'

	-- Goods
	IF	(@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	-- Acnt
	IF	(@SelectedOrder1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder1, 'D.AcntCode') 
	IF	(@SelectedOrder2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder2, 'D.AcntCode') 
	IF	(@SelectedOrder3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder3, 'D.AcntCode') 
	IF	(@SelectedOrder4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder4, 'D.AcntCode') 

	-- Visitor
	IF	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	IF	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	IF	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	IF	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')

	-- DocStep
	If (@DocStep Is Not Null) AND (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep = ' + Str(@DocStep) + ')'
		
	IF (@GoodsID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID = ''' + @GoodsID + ''')'
	
	IF (@AcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AcntCode = ''' + @AcntCode + ''')'
		
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	set @StrWhereS = '(SD.ProcessID=90)'
	
	If (@SalDateFr Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (SD.DocDate>=''' + @SalDateFr + ''')' 
	If (@SalDateTo Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (SD.DocDate<=''' + @SalDateTo + ''')'
	
	if (@DecRet = 1)
		set @StrSelect = '
				IsNull((
					SELECT	Sum(R.GoodsQuantity)
					FROM	inv.tblStorageDocsDtl SD
								inner join inv.tblStorageDocsDtl R on R.BaseProcessID=SD.ProcessID AND R.BaseProcessNo=SD.ProcessNo AND R.BaseFiscalYear=SD.FiscalYear AND R.BaseSerialNo=SD.SerialNo AND R.BaseDocRowNo=SD.DocRowNo
					WHERE	' + @StrWhereS + '
						AND (SD.BaseProcessID=D.ProcessID)
						AND (SD.BaseProcessNo=D.ProcessNo)
						AND (SD.BaseFiscalYear=D.FiscalYear)
						AND (SD.BaseSerialNo=D.SerialNo)
						AND (SD.BaseDocRowNo=D.DocRowNo)
						AND (R.ProcessID=100)
				),0) '
	else
		set @StrSelect = 'cast(0 as float)'

	--- extended ------------------------------------------------
	
	set @StrWhereX = '(1=1)'
	
	-- مقدار تحویل داده شده بیشتر از صفر باشد
	if (@SoldOnly = 1)
		set @StrWhereX = @StrWhereX + ' AND (Round(SoldQuantity,' + ltrim(str(@round_val)) + ')>0)'
		
	-- مقدار تحویل داده شده برابر با خالص سفارش نباشد
	IF (@RemainOnly = 1)
		set @StrWhereX = @StrWhereX + ' AND (Round((GoodsQuantity-CancelQuantity)-(SoldQuantity-SoldRetQuantity),' + ltrim(str(@round_val)) + ')<>0)'

	if (@GroupByAcnt=1)
	begin
		set @StrGroup ='T.AcntCode, T.GoodsID'
		set @StrOrder ='T.AcntCode, T.GoodsID'
	end
	else
	begin
		set @StrGroup ='T.GoodsID, T.AcntCode'
		set @StrOrder ='T.GoodsID, T.AcntCode'
	end

	SET @StrSelect = '
	SELECT	GoodsID, SerialNo, DocRowNo, FiscalYear, AcntCode, GoodsQuantity, CancelQuantity, 
			[pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName,
			[pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode
	FROM
	(
		SELECT	D.GoodsID, D.AcntCode, D.GoodsQuantity, D.SerialNo, D.DocRowNo, D.FiscalYear,
				isnull((
					SELECT	Sum(GoodsQuantity)
					FROM	sal.tblSaleOrderDtl C
					WHERE	(C.BaseProcessID = D.ProcessID)
						AND (C.BaseProcessNo = D.ProcessNo)
						AND (C.BaseFiscalYear = D.FiscalYear)
						AND (C.BaseSerialNo = D.SerialNo)
						AND (C.BaseDocRowNo = D.DocRowNo)
						AND (C.ProcessID=185)
				),0) CancelQuantity,
				isnull((
					SELECT	sum(GoodsQuantity) 
					FROM	inv.tblStorageDocsDtl SD
					WHERE	' + @StrWhereS + '
						AND SD.BaseProcessID=D.ProcessID 
						AND SD.BaseProcessNo=D.ProcessNo 
						AND SD.BaseFiscalYear=D.FiscalYear 
						AND SD.BaseSerialNo=D.SerialNo 
						AND SD.BaseDocRowNo=D.DocRowNo
				),0) SoldQuantity, ' + @StrSelect + ' SoldRetQuantity
		FROM    sal.tblSaleOrderDtl AS D
					INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		WHERE   ' + @StrWhere + '
	) T  
	WHERE ' + @StrWhereX + '
	ORDER BY ' + @StrOrder
	---------------------------------------------------------------------------
	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
