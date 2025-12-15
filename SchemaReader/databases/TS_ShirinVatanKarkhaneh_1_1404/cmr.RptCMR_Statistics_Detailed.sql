USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/10/17
-- Viewed By	 : 
-- Last Modified : 1388/04/16
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : آمار (یا وضعیت) درخواست کالاها - تفصیلی
-- =============================================
CREATE PROCEDURE [cmr].[RptCMR_Statistics_Detailed]
	@ProcessNo		TinyInt = 1,
	@SelectedGoods	Int = 0, 
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0, 
	@RemainOnly		Bit = 0,    -- فقط درخواستهائی که مانده دارند (سفارش با خرید برابر نیست) بیاید؟
	@GroupByAcnt	Bit = 0,	-- گروه بندی بر اساس کد درخواست کننده باشد یا کد کالا؟
	@RepInfo		NVarChar(100) = '1@1@1' ,
	@ExtraParams	NVarChar(500) = ''
	
WITH ENCRYPTION
AS 
Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(2000);
Declare @StrFrom	NVarChar(2000);
Declare @CodeField	VarChar(200);
Declare @NameField	NVarChar(200);

DECLARE @PID_BUY		VarChar(3);
DECLARE @PID_BUY_RET	VarChar(3);
DECLARE @PID_REQ		VarChar(3);
DECLARE @PID_REQ_CNL	VarChar(3);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @DescDtl		NVarChar(200);

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

	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1;

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @PID_BUY = '55';		-- Buy ProcessID
	SET @PID_BUY_RET = '60';	-- Buy Return ProcessID
	SET @PID_REQ = '150';		-- Buy Request
	SET @PID_REQ_CNL = '155';	-- BuyRequest Cancel
	
	SET @DescDtl		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = ' D.ProcessID  = ' + @PID_REQ + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	-- Acnt
	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	
	If (@DescDtl <> '' And @DescDtl Is Not Null)
		SET @StrWhere = @StrWhere + 'AND (D.DescDtl Like N''%' + LTrim(@DescDtl) + '%'')'
			
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
			INSERT INTO #tblBUY
			-- CMR -> BUY
			SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = ' + @PID_BUY_RET + '
					) AS Qty
			FROM	cmr.tblCMRDtl C INNER JOIN inv.tblStorageDocsDtl S
						ON S.BaseProcessID = C.ProcessID AND S.BaseProcessNo = C.ProcessNo AND S.BaseFiscalYear = C.FiscalYear AND S.BaseSerialNo = C.SerialNo AND S.BaseDocRowNo = C.DocRowNo
			WHERE	S.ProcessID = ' + @PID_BUY + '
			UNION all
			-- CMR -> ORDER -> BUY
			SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = ' + @PID_BUY_RET + '
					) AS Qty
			FROM	cmr.tblCMRDtl C 
					INNER JOIN cmr.tblOrderDtl O
					ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
					INNER JOIN inv.tblStorageDocsDtl S
					ON S.BaseProcessID = O.ProcessID AND S.BaseProcessNo = O.ProcessNo AND S.BaseFiscalYear = O.FiscalYear AND S.BaseSerialNo = O.SerialNo AND S.BaseDocRowNo = O.DocRowNo
			WHERE S.ProcessID = ' + @PID_BUY + '
			UNION all
			-- CMR -> RECEIPT -> BUY
			SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = ' + @PID_BUY_RET + '
					) AS Qty
			FROM	cmr.tblCMRDtl C 
					LEFT JOIN inv.tblInvTempReceiptDtl R
					ON R.BaseProcessID = C.ProcessID AND R.BaseProcessNo = C.ProcessNo AND R.BaseFiscalYear = C.FiscalYear AND R.BaseSerialNo = C.SerialNo AND R.BaseDocRowNo = C.DocRowNo
					INNER JOIN inv.tblStorageDocsDtl S
					ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
			WHERE S.ProcessID = ' + @PID_BUY + '
			UNION all
			-- CMR -> ORDER -> RECEIPT -> BUY
			SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = ' + @PID_BUY_RET + '
					) AS Qty
			FROM	cmr.tblCMRDtl C
						INNER JOIN cmr.tblOrderDtl O ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
						LEFT  JOIN inv.tblInvTempReceiptDtl R ON R.BaseProcessID = O.ProcessID AND R.BaseProcessNo = O.ProcessNo AND R.BaseFiscalYear = O.FiscalYear AND R.BaseSerialNo = O.SerialNo AND R.BaseDocRowNo = O.DocRowNo
						INNER JOIN inv.tblStorageDocsDtl S ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
			WHERE S.ProcessID = ' + @PID_BUY

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect = '
	SELECT	T.GoodsID, T.AcntCode, Sum(T.ConfirmQuantity) AS RequestedQty, 
			Sum(T.CanceledQty) AS CanceledQty, Sum(T.BoughtQty) AS BoughtQty,
			[pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName,
			[pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		    IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode
	FROM
	(
		SELECT	D.GoodsID, D.AcntCode, 
				D.ConfirmQuantity, 
				(
					SELECT	IsNull(Sum(CNL.ConfirmQuantity), 0)
					FROM	cmr.tblCMRDtl AS CNL
					WHERE	CNL.BaseProcessID  = D.ProcessID AND CNL.BaseProcessNo = D.ProcessNo AND
							CNL.BaseFiscalYear = D.FiscalYear AND CNL.BaseSerialNo  = D.SerialNo AND
							CNL.BaseDocRowNo   = D.DocRowNo AND CNL.ProcessID = ' + @PID_REQ_CNL + '
				) AS CanceledQty,
				IsNull(SUM(BUY.Qty), 0) AS BoughtQty
		FROM    cmr.tblCMRDtl AS D
					LEFT JOIN #tblBUY BUY ON BUY.ProcessID = D.ProcessID AND BUY.ProcessNo = D.ProcessNo AND BUY.FiscalYear = D.FiscalYear AND BUY.SerialNo = D.SerialNo AND BUY.DocRowNo = D.DocRowNo
		WHERE   ' + @StrWhere + '
		GROUP BY D.GoodsID, D.AcntCode, D.ConfirmQuantity, D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo
	) T 
	GROUP BY T.GoodsID, T.AcntCode '

	-- مقدار خریداری شده کل برابر با خالص سفارش کل نباشد
	If (@RemainOnly = 1)
		SET @StrSelect = @StrSelect + '
	HAVING Sum(T.ConfirmQuantity) - Sum(T.CanceledQty) <> Sum(T.BoughtQty) '

	---- S O R T --------------------------------------------------------------
	SET @StrSelect = @StrSelect + '
	ORDER BY T.GoodsID, T.AcntCode '
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
