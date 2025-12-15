USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/10/17
-- Viewed By	 : 
-- Last Modified : 1393/08/03
-- Last Modifier : TakroSystem\Hamid
-- Description	 : لیست سفارشات خریداری نشده - تفصیلی
-- ==============================================
Create PROCEDURE [cmr].[RptBuyOrder_Remain_Detailed]
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SelectedGoods		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SortFields			NVarChar(100) = NULL,
	@RepOptions			varchar(20) = '1',
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
Declare @StrSelect	NVarChar(Max);
Declare @StrWhere	NVarChar(2000);
DECLARE @PID_BUY		VarChar(3);
DECLARE @PID_BUY_RET	VarChar(3);
DECLARE @PID_REQ		VarChar(3);
DECLARE @PID_REQ_CNL	VarChar(3);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @bolShowBuyRetRemain	bit;
DECLARE @StrShowBuyRetRemain	NVarChar(2000);

DECLARE @bolShowAllOrders		bit;
DECLARE @StrShowAllOrders		NVarChar(2000);

DECLARE @isCanceled				bit;

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
	If (@SortFields Is Null) Set @SortFields = 'FiscalYear, SerialNo'
	If (@ProcessNo  Is Null) Set @ProcessNo  = 1;
	IF (@RepInfo	Is Null) SET @RepInfo	= '1@1@1';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @isCanceled	= pub.funSplitString(@RepInfo, '@', 7);

	SET @PID_BUY = '55';		-- Buy ProcessID
	SET @PID_BUY_RET = '60';	-- Buy Return ProcessID
	SET @PID_REQ = '160';		-- Buy Order
	SET @PID_REQ_CNL = '165';	-- Buy Order Cancel
	
	SET @bolShowBuyRetRemain	= Substring(@RepOptions, 1, 1)
	SET @bolShowAllOrders		= Substring(@RepOptions, 2, 1)
	
	IF @bolShowBuyRetRemain = 'True'
		SET @StrShowBuyRetRemain = 
			'- (
				SELECT	IsNULL(Sum(GoodsQuantity), 0)
				FROM    inv.tblStorageDocsDtl
				WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
						BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
						BaseDocRowNo = S.DocRowNo AND ProcessID = ' + @PID_BUY_RET + '
			  )'
	ELSE
		SET @StrShowBuyRetRemain = ''	

	-- ======		
	IF @bolShowAllOrders = 'True'
		SET @StrShowAllOrders = '
			-- مقدار خریداری شده کمتر از خالص سفارش باشد
			WHERE (T.BoughtQty < T.RequestConfirmQTY - T.CanceledQty)' 
	ELSE
		SET @StrShowAllOrders = ''
				
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = ' D.ProcessID  = ' + @PID_REQ + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
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

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

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
			-- CMR -> BUY
			SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo,S.GoodsQuantity ' + @StrShowBuyRetRemain + ' AS Qty
			FROM	cmr.tblOrderDtl C INNER JOIN inv.tblStorageDocsDtl S
						ON S.BaseProcessID = C.ProcessID AND S.BaseProcessNo = C.ProcessNo AND S.BaseFiscalYear = C.FiscalYear AND S.BaseSerialNo = C.SerialNo AND S.BaseDocRowNo = C.DocRowNo
			WHERE	S.ProcessID = ' + @PID_BUY + '
			UNION all
			-- CMR -> RECEIPT -> BUY
			SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo,S.GoodsQuantity ' + @StrShowBuyRetRemain + ' AS Qty
			FROM	cmr.tblOrderDtl C 
					LEFT JOIN inv.tblInvTempReceiptDtl R ON R.BaseProcessID = C.ProcessID AND R.BaseProcessNo = C.ProcessNo AND R.BaseFiscalYear = C.FiscalYear AND R.BaseSerialNo = C.SerialNo AND R.BaseDocRowNo = C.DocRowNo
					INNER JOIN inv.tblStorageDocsDtl S ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
			WHERE S.ProcessID = ' + @PID_BUY 

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	if @isCanceled = 0
		Begin
		Set @StrSelect = '
			SELECT	T.*, [pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName,
					[pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				    IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode,
					ISNULL(C.DescDtl,'''') CmrDescDtl ,ISNULL(C.DescDtl2,'''') CmrDescDtl2
			FROM
			(
				SELECT	D.ProcessID,D.ProcessNo,D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, D.GoodsID, 
						D.GoodsQuantity RequestedQty, D.ConfirmQuantity As RequestConfirmQTY,D.DescDtl,D.DescDtl2,
						(
							SELECT	IsNull(Sum(CNL.ConfirmQuantity), 0)
							FROM	cmr.tblOrderDtl AS CNL
							WHERE	CNL.BaseProcessID  = D.ProcessID AND CNL.BaseProcessNo = D.ProcessNo AND
									CNL.BaseFiscalYear = D.FiscalYear AND CNL.BaseSerialNo  = D.SerialNo AND
									CNL.BaseDocRowNo   = D.DocRowNo AND CNL.ProcessID = ' + @PID_REQ_CNL + '
						) AS CanceledQty,
						IsNull(SUM(BUY.Qty), 0) AS BoughtQty, IsNull(OH.AgreeNo,0) As AgreeNo
				FROM	cmr.tblOrderDtl AS D
							LEFT JOIN #tblBUY BUY ON BUY.ProcessID = D.ProcessID AND BUY.ProcessNo = D.ProcessNo AND BUY.FiscalYear = D.FiscalYear AND BUY.SerialNo = D.SerialNo AND BUY.DocRowNo = D.DocRowNo
				INNER JOIN cmr.tblOrderHdr OH
						   ON OH.ProcessID = D.ProcessID AND OH.ProcessNo = D.ProcessNo AND OH.FiscalYear = D.FiscalYear AND OH.SerialNo = D.SerialNo			
				WHERE   ' + @StrWhere + '
				GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, D.GoodsID, D.GoodsQuantity, 
					     D.ConfirmQuantity, OH.AgreeNo,D.DescDtl,D.DescDtl2
			) T 
			INNER JOIN cmr.tblOrderDtl H ON H.ProcessID = T.ProcessID AND H.ProcessNo = T.ProcessNo AND H.FiscalYear = T.FiscalYear AND H.SerialNo = T.SerialNo AND H.DocRowNo = T.DocRowNo AND H.GoodsID = T.GoodsID
			LEFT JOIN cmr.tblCMRDtl C ON C.ProcessID = H.BaseProcessID AND C.ProcessNo = H.BaseProcessNo AND C.FiscalYear = H.BaseFiscalYear AND C.SerialNo = H.BaseSerialNo  AND C.DocRowNo = H.BaseDocRowNo AND C.GoodsID = H.GoodsID
			
			' + @StrShowAllOrders

			SET @StrSelect = @StrSelect + '
			ORDER BY ' + @SortFields
			---------------------------------------------------------------------------

			---- R U N ----------------------------------------------------------------
			Print @StrSelect;
			Exec sp_executesql @StrSelect;
			---------------------------------------------------------------------------
		end
	if @isCanceled = 1
		Begin
		Set @StrSelect = '
			SELECT	T.*, [pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName,
					[pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				    IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode,
					ISNULL(C.DescDtl,'''') CmrDescDtl ,ISNULL(C.DescDtl2,'''') CmrDescDtl2
			FROM
			(
				SELECT	D.ProcessID,D.ProcessNo,D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, D.GoodsID, 
						D.GoodsQuantity RequestedQty, D.ConfirmQuantity As RequestConfirmQTY,D.DescDtl,D.DescDtl2,
						(
							SELECT	IsNull(Sum(CNL.ConfirmQuantity), 0)
							FROM	cmr.tblOrderDtl AS CNL
							WHERE	CNL.BaseProcessID  = D.ProcessID AND CNL.BaseProcessNo = D.ProcessNo AND
									CNL.BaseFiscalYear = D.FiscalYear AND CNL.BaseSerialNo  = D.SerialNo AND
									CNL.BaseDocRowNo   = D.DocRowNo AND CNL.ProcessID = ' + @PID_REQ_CNL + '
						) AS CanceledQty,
						IsNull(SUM(BUY.Qty), 0) AS BoughtQty, IsNull(OH.AgreeNo,0) As AgreeNo
				FROM	cmr.tblOrderDtl AS D
							LEFT JOIN #tblBUY BUY ON BUY.ProcessID = D.ProcessID AND BUY.ProcessNo = D.ProcessNo AND BUY.FiscalYear = D.FiscalYear AND BUY.SerialNo = D.SerialNo AND BUY.DocRowNo = D.DocRowNo
				INNER JOIN cmr.tblOrderHdr OH
						   ON OH.ProcessID = D.ProcessID AND OH.ProcessNo = D.ProcessNo AND OH.FiscalYear = D.FiscalYear AND OH.SerialNo = D.SerialNo			
				WHERE   ' + @StrWhere + '
				GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, D.GoodsID, D.GoodsQuantity, 
					     D.ConfirmQuantity, OH.AgreeNo,D.DescDtl,D.DescDtl2
			) T 
			INNER JOIN cmr.tblOrderDtl H ON H.ProcessID = T.ProcessID AND H.ProcessNo = T.ProcessNo AND H.FiscalYear = T.FiscalYear AND H.SerialNo = T.SerialNo AND H.DocRowNo = T.DocRowNo AND H.GoodsID = T.GoodsID
			LEFT JOIN cmr.tblCMRDtl C ON C.ProcessID = H.BaseProcessID AND C.ProcessNo = H.BaseProcessNo AND C.FiscalYear = H.BaseFiscalYear AND C.SerialNo = H.BaseSerialNo  AND C.DocRowNo = H.BaseDocRowNo AND C.GoodsID = H.GoodsID
			
			' + @StrShowAllOrders

			SET @StrSelect = @StrSelect + '
			Where T.RequestConfirmQTY - T.CanceledQty >0
			ORDER BY ' + @SortFields
			---------------------------------------------------------------------------

			---- R U N ----------------------------------------------------------------
			Print @StrSelect;
			Exec sp_executesql @StrSelect;
			---------------------------------------------------------------------------
		end
END
GO
