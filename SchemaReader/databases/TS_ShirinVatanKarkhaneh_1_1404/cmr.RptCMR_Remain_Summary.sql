USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/10/16
-- Viewed By	 : 
-- Last Modified : 1393/08/03
-- Last Modifier : TakroSystem\Hamid
-- Description: لیست درخواستهای خریداری نشده - خلاصه
-- ==============================================
Create PROCEDURE [cmr].[RptCMR_Remain_Summary]
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
Declare @StrSelect1	NVarChar(Max);
Declare @StrSelect2	NVarChar(Max);
Declare @StrSelect3	NVarChar(Max);
DECLARE @StrWhere	NVarChar(2000);

DECLARE @PID_BUY		VarChar(3);
DECLARE @PID_BUY_RET	VarChar(3);
DECLARE @PID_REQ		VarChar(3);
DECLARE @PID_REQ_CNL	VarChar(3);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE @invcalcBuyRetInBuyReq	bit;

DECLARE @bolShowBuyRetRemain	bit;
DECLARE @bolShowConfirmedBuy    bit;
DECLARE @StrShowBuyRetRemain	NVarChar(2000);

CREATE TABLE #tblBUY
(
	ProcessID	TinyInt Null,
	ProcessNo	TinyInt Null,
	FiscalYear	SmallInt Null,
	SerialNo	Int Null,
	DocRowNo	Int Null,
	Qty			Float Null,
	AgreeNo		VarChar Null
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

	SET @PID_BUY = '55';		-- Buy ProcessID
	SET @PID_BUY_RET = '60';	-- Buy Return ProcessID
	SET @PID_REQ = '150';		-- Buy Request
	SET @PID_REQ_CNL = '155';	-- BuyRequest Cancel
	
	SET @bolShowBuyRetRemain	= Substring(@RepOptions, 1, 1)
	SET @bolShowConfirmedBuy	= Substring(@RepOptions, 3, 1)
	
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
	---------------------------------------------------------------------------

	SELECT @invcalcBuyRetInBuyReq=SettingValue FROM pub.tblSettings
    WHERE SettingKey='invcalcBuyRetInBuyReq'
	 
	 
	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = ' D.ProcessID = ' + @PID_REQ + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

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
    IF @bolShowConfirmedBuy = 'True'
	     SET  @StrWhere = @StrWhere + ' AND ' + 'D.DocStep=2'
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
--IF @invcalcBuyRetInBuyReq='True'
IF @bolShowBuyRetRemain='True'

 BEGIN
	SET @StrSelect1 = '
	INSERT INTO #tblBUY
	-- CMR -> BUY
	SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo,S.GoodsQuantity ' + @StrShowBuyRetRemain + ' AS Qty, OH.AgreeNo
   FROM	cmr.tblCMRDtl C INNER JOIN inv.tblStorageDocsDtl S
			ON S.BaseProcessID = C.ProcessID AND S.BaseProcessNo = C.ProcessNo AND S.BaseFiscalYear = C.FiscalYear AND S.BaseSerialNo = C.SerialNo AND S.BaseDocRowNo = C.DocRowNo
		LEFT JOIN cmr.tblOrderDtl O
		ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
		LEFT JOIN cmr.tblOrderHdr OH
		ON OH.ProcessID = O.ProcessID AND OH.ProcessNo = O.ProcessNo AND OH.FiscalYear = O.FiscalYear AND OH.SerialNo = O.SerialNo											
	WHERE	S.ProcessID = ' + @PID_BUY + '
	UNION all
	-- CMR -> ORDER -> BUY
	SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo,S.GoodsQuantity ' + @StrShowBuyRetRemain + ' AS Qty, OH.AgreeNo
   FROM	cmr.tblCMRDtl C 
		INNER JOIN cmr.tblOrderDtl O
		ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
		LEFT JOIN cmr.tblOrderHdr OH
		ON OH.ProcessID = O.ProcessID AND OH.ProcessNo = O.ProcessNo AND OH.FiscalYear = O.FiscalYear AND OH.SerialNo = O.SerialNo										
		INNER JOIN inv.tblStorageDocsDtl S
		ON S.BaseProcessID = O.ProcessID AND S.BaseProcessNo = O.ProcessNo AND S.BaseFiscalYear = O.FiscalYear AND S.BaseSerialNo = O.SerialNo AND S.BaseDocRowNo = O.DocRowNo
	WHERE S.ProcessID = ' + @PID_BUY + '
	UNION all ' 
	Print @StrSelect1;
	
	SET @StrSelect2 = '
	-- CMR -> RECEIPT -> BUY
	SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo,S.GoodsQuantity ' + @StrShowBuyRetRemain + ' AS Qty, OH.AgreeNo
	FROM	cmr.tblCMRDtl C 
		LEFT JOIN cmr.tblOrderDtl O
		ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
		LEFT JOIN cmr.tblOrderHdr OH
		ON OH.ProcessID = O.ProcessID AND OH.ProcessNo = O.ProcessNo AND OH.FiscalYear = O.FiscalYear AND OH.SerialNo = O.SerialNo						
		LEFT JOIN inv.tblInvTempReceiptDtl R
		ON R.BaseProcessID = C.ProcessID AND R.BaseProcessNo = C.ProcessNo AND R.BaseFiscalYear = C.FiscalYear AND R.BaseSerialNo = C.SerialNo AND R.BaseDocRowNo = C.DocRowNo
		INNER JOIN inv.tblStorageDocsDtl S
		ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
	WHERE S.ProcessID = ' + @PID_BUY + '
	UNION all
	-- CMR -> ORDER -> RECEIPT -> BUY
	SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo,S.GoodsQuantity ' + @StrShowBuyRetRemain + ' AS Qty, OH.AgreeNo
   FROM	cmr.tblCMRDtl C
		INNER JOIN cmr.tblOrderDtl O
		ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
		LEFT JOIN cmr.tblOrderHdr OH
		ON OH.ProcessID = O.ProcessID AND OH.ProcessNo = O.ProcessNo AND OH.FiscalYear = O.FiscalYear AND OH.SerialNo = O.SerialNo				
		LEFT JOIN inv.tblInvTempReceiptDtl R
		ON R.BaseProcessID = O.ProcessID AND R.BaseProcessNo = O.ProcessNo AND R.BaseFiscalYear = O.FiscalYear AND R.BaseSerialNo = O.SerialNo AND R.BaseDocRowNo = O.DocRowNo
		INNER JOIN inv.tblStorageDocsDtl S
		ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
  WHERE S.ProcessID = ' + @PID_BUY

	Print @StrSelect2;
	
	SET @StrSelect3 = @StrSelect1 + @StrSelect2
	Exec sp_executesql @StrSelect3;
END

--IF @invcalcBuyRetInBuyReq='False'
IF @bolShowBuyRetRemain='False'

 BEGIN
	SET @StrSelect1 = '
	INSERT INTO #tblBUY
	-- CMR -> BUY
	SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity AS Qty, OH.AgreeNo
   FROM	cmr.tblCMRDtl C INNER JOIN inv.tblStorageDocsDtl S
			ON S.BaseProcessID = C.ProcessID AND S.BaseProcessNo = C.ProcessNo AND S.BaseFiscalYear = C.FiscalYear AND S.BaseSerialNo = C.SerialNo AND S.BaseDocRowNo = C.DocRowNo
		LEFT JOIN cmr.tblOrderDtl O
		ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
		LEFT JOIN cmr.tblOrderHdr OH
		ON OH.ProcessID = O.ProcessID AND OH.ProcessNo = O.ProcessNo AND OH.FiscalYear = O.FiscalYear AND OH.SerialNo = O.SerialNo											
	WHERE	S.ProcessID = ' + @PID_BUY + '
	UNION all
	-- CMR -> ORDER -> BUY
	SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity AS Qty, OH.AgreeNo
   FROM	cmr.tblCMRDtl C 
		INNER JOIN cmr.tblOrderDtl O
		ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
		LEFT JOIN cmr.tblOrderHdr OH
		ON OH.ProcessID = O.ProcessID AND OH.ProcessNo = O.ProcessNo AND OH.FiscalYear = O.FiscalYear AND OH.SerialNo = O.SerialNo										
		INNER JOIN inv.tblStorageDocsDtl S
		ON S.BaseProcessID = O.ProcessID AND S.BaseProcessNo = O.ProcessNo AND S.BaseFiscalYear = O.FiscalYear AND S.BaseSerialNo = O.SerialNo AND S.BaseDocRowNo = O.DocRowNo
	WHERE S.ProcessID = ' + @PID_BUY + '
	UNION all '
	
	Print @StrSelect1;
	
	SET @StrSelect2 = '	
	-- CMR -> RECEIPT -> BUY
	SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity AS Qty, OH.AgreeNo
	FROM	cmr.tblCMRDtl C 
		LEFT JOIN cmr.tblOrderDtl O
		ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
		LEFT JOIN cmr.tblOrderHdr OH
		ON OH.ProcessID = O.ProcessID AND OH.ProcessNo = O.ProcessNo AND OH.FiscalYear = O.FiscalYear AND OH.SerialNo = O.SerialNo						
		LEFT JOIN inv.tblInvTempReceiptDtl R
		ON R.BaseProcessID = C.ProcessID AND R.BaseProcessNo = C.ProcessNo AND R.BaseFiscalYear = C.FiscalYear AND R.BaseSerialNo = C.SerialNo AND R.BaseDocRowNo = C.DocRowNo
		INNER JOIN inv.tblStorageDocsDtl S
		ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
	WHERE S.ProcessID = ' + @PID_BUY + '
	UNION all
	-- CMR -> ORDER -> RECEIPT -> BUY
	SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity AS Qty, OH.AgreeNo
   FROM	cmr.tblCMRDtl C
		INNER JOIN cmr.tblOrderDtl O
		ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
		LEFT JOIN cmr.tblOrderHdr OH
		ON OH.ProcessID = O.ProcessID AND OH.ProcessNo = O.ProcessNo AND OH.FiscalYear = O.FiscalYear AND OH.SerialNo = O.SerialNo				
		LEFT JOIN inv.tblInvTempReceiptDtl R
		ON R.BaseProcessID = O.ProcessID AND R.BaseProcessNo = O.ProcessNo AND R.BaseFiscalYear = O.FiscalYear AND R.BaseSerialNo = O.SerialNo AND R.BaseDocRowNo = O.DocRowNo
		INNER JOIN inv.tblStorageDocsDtl S
		ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
  WHERE S.ProcessID = ' + @PID_BUY

	Print @StrSelect2;
	
	SET @StrSelect3 = @StrSelect1 + @StrSelect2
	Exec sp_executesql @StrSelect3;
END





SET @StrSelect1 = '
		SELECT	DISTINCT T.FiscalYear, T.SerialNo, T.DocDate, T.AcntCode, T.GoodsRemain,
			[pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName, T.AgreeNo,
			[pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		    IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode
		FROM
		(
		SELECT	D.FiscalYear, D.SerialNo, D.DocDate, D.AcntCode, D.GoodsID,
				D.ConfirmQuantity AS RequestedQty, 
				(
					SELECT	IsNull(Sum(CNL.ConfirmQuantity), 0)
					FROM	cmr.tblCMRDtl AS CNL
					WHERE	CNL.BaseProcessID  = D.ProcessID AND CNL.BaseProcessNo = D.ProcessNo AND
							CNL.BaseFiscalYear = D.FiscalYear AND CNL.BaseSerialNo  = D.SerialNo AND
							CNL.BaseDocRowNo   = D.DocRowNo AND CNL.ProcessID = ' + @PID_REQ_CNL + '
				) AS CanceledQty,
				IsNull(SUM(BUY.Qty), 0) AS BoughtQty, IsNull(BUY.AgreeNo,0) As AgreeNo,
				[inv].[funGetGoodsRemain](NULL,NULL,D.FiscalYear,NULL,NULL,NULL,D.GoodsID,'''',D.DocDate,0) As GoodsRemain
		FROM    cmr.tblCMRDtl AS D
					LEFT JOIN #tblBUY BUY ON BUY.ProcessID = D.ProcessID AND BUY.ProcessNo = D.ProcessNo AND BUY.FiscalYear = D.FiscalYear AND BUY.SerialNo = D.SerialNo AND BUY.DocRowNo = D.DocRowNo
		WHERE   ' + @StrWhere + '
		GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, D.GoodsID, D.ConfirmQuantity, BUY.AgreeNo
		) T 
		-- مقدار خریداری شده کمتر از خالص سفارش باشد
		WHERE round((T.RequestedQty - T.CanceledQty )-T.BoughtQty ,7)>0 
		ORDER BY ' + @SortFields
---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect1;
	
	Exec sp_executesql @StrSelect1;
	---------------------------------------------------------------------------
End
GO
