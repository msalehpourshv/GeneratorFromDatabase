USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1392/08/05
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 1392/08/05
-- Last Modifier : TakroSystem\Zia
-- Description   : آمار (یا وضعیت) سفارش کالاها - تفصیلی
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_Sor_Detailed_SaleOrder] 
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
DECLARE @StrSelect2	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrOrder	NVarChar(200);
DECLARE @StrGroup	NVarChar(200);

DECLARE @CodeField	VarChar(20);
DECLARE @NameField	NVarChar(200);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @DocStep		Int;

DECLARE @round_val		int;
DECLARE @RemainOnly		Bit;

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

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @DocStep		= Substring(@RepOptions, 1, 1);
	
	SET @StrSelect2 = ''
	
	Select @round_val = IsNull(SettingValue, 0)
	From pub.tblSettings
	Where SettingKey = 'QuantityDecimals'
	
	SET @RemainOnly	= Substring(@RepOptions, 4, 1);
		
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = ' (S.ProcessID=180) AND (S.ProcessNo=' + LTrim(Str(@ProcessNo)) + ') AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	IF (@DateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (S.DocDate >= ''' + @DateFr + ''')' 
	IF (@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (S.DocDate <= ''' + @DateTo + ''')'

	-- Goods
	IF	(@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'S.GoodsID') 

	-- Acnt
	IF	(@SelectedOrder1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder1, 'S.AcntCode') 
	IF	(@SelectedOrder2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder2, 'S.AcntCode') 
	IF	(@SelectedOrder3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder3, 'S.AcntCode') 
	IF	(@SelectedOrder4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder4, 'S.AcntCode') 

	-- Visitor
	IF	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'SH.VisitorAcntCode')
	IF	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'SH.VisitorAcntCode')
	IF	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'SH.VisitorAcntCode')
	IF	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'SH.VisitorAcntCode')

	-- DocStep
	IF (@DocStep Is Not Null) AND (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (S.DocStep = ' + Str(@DocStep) + ')'
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	SET @StrWhere = @StrWhere + ' And (D.ProcessID=90)'
	
	IF (@SalDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @SalDateFr + ''')' 
	
	IF (@SalDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @SalDateTo + ''')'
	
	IF (@GoodsID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (S.GoodsID = ''' + @GoodsID + ''')'
	
	IF (@AcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (S.AcntCode = ''' + @AcntCode + ''')'
	
	IF (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (S.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(S.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND S.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (S.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(S.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND S.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '	
	
	IF (@RemainOnly = 1)
	
		SET @StrSelect2 = '
		INNER JOIN (
		Select *
		From(
			SELECT *,
					(
						SELECT	IsNull(Sum(GoodsQuantity), 0)
						FROM	sal.tblSaleOrderDtl
						WHERE	BaseProcessID = D.ProcessID 
								AND BaseProcessNo = D.ProcessNo 
								AND BaseFiscalYear = D.FiscalYear 
								AND BaseSerialNo = D.SerialNo 
								AND BaseDocRowNo = D.DocRowNo
					) AS CancelQuantity,
					(
						-- sum of sold qty 
						SELECT IsNull(Sum(Sold), 0)
						FROM
						(
							SELECT	GoodsQuantity AS Sold
							FROM	inv.tblStorageDocsDtl SD
							WHERE	SD.ProcessID=90
								AND SD.BaseProcessID = D.ProcessID 
								AND SD.BaseProcessNo = D.ProcessNo 
								AND SD.BaseFiscalYear = D.FiscalYear 
								AND SD.BaseSerialNo = D.SerialNo 
								AND SD.BaseDocRowNo = D.DocRowNo
						) Sale
					) AS SoldQuantity, 0 AS SoldRetQuantity
			FROM    sal.tblSaleOrderDtl AS D
			) M Where (Round((GoodsQuantity-CancelQuantity)-(SoldQuantity-SoldRetQuantity),' + ltrim(str(@round_val)) + ') <> 0)
			) T
		ON T.ProcessID = S.ProcessID AND T.ProcessNo = S.ProcessNo AND T.FiscalYear = S.FiscalYear AND 
		   T.SerialNo = S.SerialNo AND T.RowNo = S.RowNo'
		   	
	--- extended ------------------------------------------------
	
	SET @StrSelect = '
		Select S.GoodsID ,[pub].[funGetGoodsName](S.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (S.GoodsID), '''') BarCode ,S.SerialNo ,S.RowNo ,S.GoodsQuantity 
		From inv.tblStorageDocsDtl D
		INNER JOIN sal.tblSaleOrderDtl S ON D.BaseProcessID = S.ProcessID AND D.BaseProcessNo = S.ProcessNo AND 
											D.BaseFiscalYear = S.FiscalYear AND D.BaseSerialNo = S.SerialNo AND 
											D.BaseDocRowNo = S.DocRowNo ' + @StrSelect2 + '
		INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = S.ProcessID AND H.ProcessNo = S.ProcessNo AND 
											H.FiscalYear = S.FiscalYear AND H.SerialNo = S.SerialNo 
		INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		Where ' + @StrWhere

	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
