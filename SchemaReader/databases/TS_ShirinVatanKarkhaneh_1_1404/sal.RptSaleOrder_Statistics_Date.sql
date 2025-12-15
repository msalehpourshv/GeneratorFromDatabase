USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1386/11/14
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 1392/05/22
-- Last Modifier : TakroSystem\Zia
-- Description   : آمار (یا وضعیت) سفارش یک کالا یا یک سفارش دهنده
-- ==============================================
CREATE PROCEDURE [sal].[RptSaleOrder_Statistics_Date]
	@ProcessNo		Int = 1,
	@GoodsIDFr		VarChar(20) = NULL,
	@GoodsIDTo		VarChar(20) = NULL,
	@AcntCodeFr		VarChar(20) = NULL,
	@AcntCodeTo		VarChar(20) = NULL,
	@AgreeNoFr		VarChar(20) = NULL,
	@AgreeNoTo		VarChar(20) = NULL,
	@SelectedGoods	Int = NULL, 
	@SelectedStore	Int = NULL, 
	@SelectedAcnt1	Int = NULL, 
	@SelectedAcnt2	Int = NULL, 
	@SelectedAcnt3	Int = NULL, 
	@SelectedAcnt4	Int = NULL, 
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@SorDateFr		Char(10) = NULL,
	@SorDateTo		Char(10) = NULL,
	@SalDateFr		Char(10) = NULL,
	@SalDateTo		Char(10) = NULL,
	@RepOptions		VarChar(20) = '1002', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
Declare @RemainOnly	Bit; -- فقط سفارشاتی که مانده دارند (سفارش با تحویل برابر نیست) بیاید؟
Declare @DecRet		Bit; 
Declare @DocStep	Int;

Declare @StrSelect	NVarChar(max);
Declare @StrWhere	NVarChar(max);
Declare @StrFrom	NVarChar(max);
DECLARE @StrWhereS	NVarChar(max);
DECLARE @StrWhereX	NVarChar(max);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

Declare @SoldOnly	Bit; 
DECLARE @round_val	int;
Begin --============== S T A R T  C O D E ===================================================

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
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '10';
	If (@ProcessNo	Is Null)	SET @ProcessNo  = 1;

	If (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	If (@SelectedStore Is Null) SET @SelectedStore = 0;

	IF (@SelectedAcnt1 Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2 Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3 Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4 Is Null)	SET @SelectedAcnt4 = 0

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @RemainOnly	= Substring(@RepOptions, 1, 1);
	SET @DecRet		= Substring(@RepOptions, 2, 1);
	SET @DocStep	= Substring(@RepOptions, 3, 1);
	SET @SoldOnly	= Substring(@RepOptions, 4, 1);
	
	select @round_val = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'	
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '(D.ProcessID=180)'
	
	if (@ProcessNo <> 0)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	-- Goods
	If (@GoodsIDFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID>=''' + @GoodsIDFr + ''')'
	If (@GoodsIDTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID<=''' + @GoodsIDTo + ''')'
	If	(@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	IF (@SorDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate>=''' + @SorDateFr + ''')' 
	IF (@SorDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @SorDateTo + ''')'

	-- Acnt
	if (@AcntCodeFr is not null)
		set @StrWhere = @StrWhere + ' AND (D.AcntCode>=''' + @AcntCodeFr + ''')'
	if (@AcntCodeTo is not null)
		SET @StrWhere = @StrWhere + ' AND (D.AcntCode<=''' + @AcntCodeTo + ''')'

	If	(@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode') 
	If	(@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode') 
	If	(@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode') 
	If	(@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode') 

	-- Visitor
	If	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	If	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	If	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	If	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')

	-- AgreeNo
	If (@AgreeNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AgreeNo>=''' + @AgreeNoFr + '''' 
	If (@AgreeNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.AgreeNo<=''' + @AgreeNoTo + '''' 

	-- DocStep
	If (@DocStep > 0)
		Set @StrWhere = @StrWhere + ' AND (D.DocStep = ' + Str(@DocStep) + ')'
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	declare @Where_Balance nvarchar(2000)
	
	set @Where_Balance = '(1=1)'

	if (@SelectedStore <> 0)
		set @Where_Balance = @Where_Balance + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'StoreID')
	
	if (@DecRet = 1) 
		set @StrSelect = '
			(
				SELECT	IsNull(Sum(GoodsQuantity), 0) AS SoldRet
				FROM    inv.tblStorageDocsDtl
				WHERE   (BaseProcessID = SD.ProcessID)
					AND (BaseProcessNo = SD.ProcessNo) 
					AND (BaseFiscalYear = SD.FiscalYear) 
					AND (BaseSerialNo = SD.SerialNo) 
					AND	(BaseDocRowNo = SD.DocRowNo)
			)'
	else
		set @StrSelect = 'cast(0 as float)'

	set @StrWhereS = '(SD.ProcessID=90)'
	
	If (@SalDateFr Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (SD.DocDate>=''' + @SalDateFr + ''')' 
	If (@SalDateTo Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (SD.DocDate<=''' + @SalDateTo + ''')'

	--- extended ------------------------------------------------
	
	set @StrWhereX = '(1=1)'
	
	-- مقدار تحویل داده شده بیشتر از صفر باشد
	if (@SoldOnly = 1)
		set @StrWhereX = @StrWhereX + ' AND (Round(SoldQuantity,' + ltrim(str(@round_val)) + ')>0)'

	-- مقدار تحویل داده شده برابر با خالص سفارش نباشد
	if (@RemainOnly = 1)
		set @StrWhereX = @StrWhereX + ' AND (Round(OrderQuantity-SoldQuantity,' + ltrim(str(@round_val)) + ')>0)'

	Set @StrSelect = '
	select M.*, [pub].[funGetGoodsName](M.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (M.GoodsID), '''') BarCode,
		   [pub].GetCodeName(M.AcntCode, ' + @LangID + ') As AcntName
	from
	(
		SELECT	DocDate, AcntCode, GoodsID, 
				Sum(OrderQuantity) OrderQuantity, 
				Sum(SoldQuantity) SoldQuantity 
		FROM
		(
			SELECT	D.DocDate, D.AcntCode, D.GoodsID,
					(D.GoodsQuantity - 
						(
							SELECT	IsNull(Sum(GoodsQuantity), 0)
							FROM	sal.tblSaleOrderDtl
							WHERE	(BaseProcessID = D.ProcessID) 
								AND (BaseProcessNo = D.ProcessNo) 
								AND (BaseFiscalYear = D.FiscalYear) 
								AND (BaseSerialNo = D.SerialNo) 
								AND (BaseDocRowNo = D.DocRowNo)
						)
					) AS OrderQuantity,
					(
						-- sum of sold qty 
						SELECT IsNull(Sum(Sold), 0)
						FROM
						(
							SELECT	GoodsQuantity AS Sold
							FROM	inv.tblStorageDocsDtl SD
							WHERE	' + @StrWhereS + '
								AND SD.BaseProcessID = D.ProcessID 
								AND SD.BaseProcessNo = D.ProcessNo 
								AND SD.BaseFiscalYear = D.FiscalYear 
								AND SD.BaseSerialNo = D.SerialNo 
								AND SD.BaseDocRowNo = D.DocRowNo
								AND SD.GoodsID = D.GoodsID
						) Sale
					) AS SoldQuantity
			FROM    sal.tblSaleOrderDtl AS D
						INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			WHERE   ' + @StrWhere + '
		) T  
		WHERE ' + @StrWhereX + '
		GROUP BY T.DocDate, T.GoodsID, T.AcntCode
	) M
	INNER JOIN inv.tblGoods S ON S.GoodsID = SUBSTRING(M.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND S.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	ORDER BY M.DocDate, M.GoodsID, M.AcntCode'
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
