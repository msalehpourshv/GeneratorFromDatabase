USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1387/02/10
-- Viewed By	 : 
-- Last Modified : 1388/04/16
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : آمار (یا وضعیت) سفارش کالاها - خلاصه
-- =============================================
CREATE PROCEDURE [cmr].[RptBuyOrder_Statistics_Summary]
	@ProcessNo		Int = 1,
	@SelectedGoods	Int = 0, 
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0, 
	@RemainOnly		Bit = 0,    -- فقط درخواستهائی که مانده دارند (سفارش با خرید برابر نیست) بیاید؟
	@GroupByAcnt	Bit = 0,	-- گروه بندی بر اساس کد درخواست کننده باشد یا کد کالا؟
	@AgreeNoFr		varchar(20) = null,
	@AgreeNoTo		varchar(20) = null,
	@RepInfo		NVarChar(100) = '1@1@1' 
WITH ENCRYPTION
AS 
Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(2000);
Declare @StrFrom	NVarChar(2000);

Declare @CodeField	VarChar(20);
Declare @NameField	NVarChar(200);

DECLARE @PID_ORD		VarChar(3);
DECLARE @PID_ORD_CNL	VarChar(3);
DECLARE @PID_BUY		VarChar(3);
DECLARE @PID_BUY_RET	VarChar(3);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

CREATE TABLE #tblBUY
(
	ProcessID	TinyInt Null,
	ProcessNo	TinyInt Null,
	FiscalYear	SmallInt Null,
	SerialNo	Int Null,
	DocRowNo	Int Null,
	Qty			Float Null
)
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
	
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	If (@ProcessNo  Is Null) Set @ProcessNo  = 1;

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @PID_ORD = '160';		-- ProcessID for Order
	SET @PID_ORD_CNL = '165';	-- ProcessID for Order Cancel
	SET @PID_BUY = '55';		-- ProcessID for Buy
	SET @PID_BUY_RET = '60';	-- ProcessID for Buy Cancel
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = ' D.ProcessID  = ' + LTrim(Str(@PID_ORD)) + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	If (@AgreeNoFr is not null)
		SET @StrWhere = @StrWhere + ' AND (D.AgreeNo>=''' + @AgreeNoFr + ''')'
	If (@AgreeNoTo is not null)
		SET @StrWhere = @StrWhere + ' AND (D.AgreeNo<=''' + @AgreeNoTo + ''')'

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
			INSERT INTO #tblBUY
			-- ORDER -> BUY
			SELECT	O.ProcessID, O.ProcessNo, O.FiscalYear, O.SerialNo, O.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = ' + @PID_BUY_RET + '
					) AS Qty
			FROM	cmr.tblOrderDtl O INNER JOIN inv.tblStorageDocsDtl S
					ON S.BaseProcessID = O.ProcessID AND S.BaseProcessNo = O.ProcessNo AND S.BaseFiscalYear = O.FiscalYear AND S.BaseSerialNo = O.SerialNo AND S.BaseDocRowNo = O.DocRowNo
			WHERE	S.ProcessID = ' + @PID_BUY + '
			UNION all
			-- ORDER -> RECEIPT -> BUY
			SELECT	O.ProcessID, O.ProcessNo, O.FiscalYear, O.SerialNo, O.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = ' + @PID_BUY_RET + '
					) AS Qty
			FROM	cmr.tblOrderDtl O
					INNER JOIN inv.tblInvTempReceiptDtl R
					ON R.BaseProcessID = O.ProcessID AND R.BaseProcessNo = O.ProcessNo AND R.BaseFiscalYear = O.FiscalYear AND R.BaseSerialNo = O.SerialNo AND R.BaseDocRowNo = O.DocRowNo
					INNER JOIN inv.tblStorageDocsDtl S
					ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
			WHERE S.ProcessID = ' + @PID_BUY 

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	If (@GroupByAcnt = 1)
	Begin
		Set @CodeField = 'AcntCode'
		Set @NameField = '[pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName, '''' BarCode'
	End
	Else
	Begin
		Set @CodeField = 'GoodsID'
		Set @NameField = '[pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
						  IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode'
	End

	Set @StrSelect = '
	SELECT	T.' + @CodeField + ', ' + @NameField + ', Sum(T.GoodsQuantity) OrderedQty, 
			Sum(T.CanceledQty) CanceledQty, Sum(T.BoughtQty) BoughtQty
	FROM
	(
		SELECT	D.' + @CodeField + ', D.GoodsQuantity, 
				(
				SELECT	IsNull(Sum(CNL.GoodsQuantity), 0)
				FROM	cmr.tblOrderDtl AS CNL
				WHERE	CNL.BaseProcessID  = D.ProcessID  AND CNL.BaseProcessNo = D.ProcessNo AND
						CNL.BaseFiscalYear = D.FiscalYear AND CNL.BaseSerialNo  = D.SerialNo  AND
						CNL.BaseDocRowNo   = D.DocRowNo AND CNL.ProcessID = ' + @PID_ORD_CNL + '
				) AS CanceledQty,
				IsNull(SUM(BUY.Qty), 0) AS BoughtQty
		FROM    cmr.tblOrderDtl AS D
					LEFT JOIN #tblBUY BUY ON	BUY.ProcessID = D.ProcessID AND BUY.ProcessNo = D.ProcessNo AND BUY.FiscalYear = D.FiscalYear AND BUY.SerialNo = D.SerialNo AND BUY.DocRowNo = D.DocRowNo
		WHERE   ' + @StrWhere + '
		GROUP BY D.GoodsID, D.AcntCode, D.GoodsQuantity, D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo
	) T 
	GROUP BY T.' + @CodeField

	-- مقدار خریداری شده کل برابر با خالص سفارش کل نباشد
	If (@RemainOnly = 1)
		Set @StrSelect = @StrSelect + '
	HAVING Sum(T.GoodsQuantity) - Sum(T.CanceledQty) <> Sum(T.BoughtQty) '

	---- S O R T --------------------------------------------------------------
	Set @StrSelect = @StrSelect + '
	ORDER BY T.' + @CodeField
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
