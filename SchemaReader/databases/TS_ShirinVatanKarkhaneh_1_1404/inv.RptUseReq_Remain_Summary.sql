USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/08/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : لیست درخواستهای مصرف مانده - تفصیلی
-- ==============================================
CREATE PROCEDURE [inv].[RptUseReq_Remain_Summary]
	@ProcessNo			int = 1,
	@FiscalYearFr		int = Null,
	@SerialNoFr			int = Null,
	@FiscalYearTo		int = Null,
	@SerialNoTo			int = Null,
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedGoods		Int = 0, 
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SortFields			NVarChar(100) = NULL,
	@RepOptions			VarChar(20) = '1', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @PID_USE	VarChar(3);
DECLARE @PID_RET	VarChar(3);

DECLARE @PID_REQ	VarChar(3);
DECLARE @PID_CNL	VarChar(3);

CREATE TABLE #tblUse
(
	ProcessID	int Null,
	ProcessNo	int Null,
	FiscalYear	int Null,
	SerialNo	int Null,
	DocRowNo	int Null,
	Qty			float Null
)
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	If (@SortFields Is Null) Set @SortFields = 'FiscalYear, SerialNo'
	If (@ProcessNo  Is Null) Set @ProcessNo = 1;
	If (@RepInfo	Is Null) SET @RepInfo = '1@1@1';

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

	SET @PID_USE = '110';	-- Use 
	SET @PID_RET = '115';	-- Use Return 
	SET @PID_REQ = '230';	-- Use Request
	SET @PID_CNL = '235';	-- Use Request Cancel
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = ' (D.ProcessID  = ' + @PID_REQ + ') AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

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
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	INSERT INTO #tblUse
	-- UseReq -> Use
	SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity -
			(
				SELECT	IsNULL(Sum(GoodsQuantity), 0)
				FROM    inv.tblStorageDocsDtl
				WHERE   (ProcessID = ' + @PID_RET + ') and (BaseProcessID = S.ProcessID) AND (BaseProcessNo = S.ProcessNo) AND	(BaseFiscalYear = S.FiscalYear) AND (BaseSerialNo = S.SerialNo) AND	(BaseDocRowNo = S.DocRowNo)
			) AS Qty
	FROM	inv.tblStoresRequestsDtl C 
				INNER JOIN inv.tblStorageDocsDtl S ON S.BaseProcessID = C.ProcessID AND S.BaseProcessNo = C.ProcessNo AND S.BaseFiscalYear = C.FiscalYear AND S.BaseSerialNo = C.SerialNo AND S.BaseDocRowNo = C.DocRowNo
	WHERE	(S.ProcessID = ' + @PID_USE + ')'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	Set @StrSelect = '
	SELECT	DISTINCT T.FiscalYear, T.SerialNo, T.DocDate, T.AcntCode, 
			[pub].GetCodeName(T.AcntCode, 1) As AcntName
	FROM
	(
		SELECT	D.FiscalYear, D.SerialNo, D.DocDate, D.AcntCode, D.ConfirmQuantity,
				(
					SELECT	IsNull(Sum(CNL.ConfirmQuantity), 0)
					FROM	inv.tblStoresRequestsDtl CNL
					WHERE	(CNL.ProcessID = ' + @PID_CNL + ') and (CNL.BaseProcessID  = D.ProcessID) AND (CNL.BaseProcessNo = D.ProcessNo) AND	(CNL.BaseFiscalYear = D.FiscalYear) AND (CNL.BaseSerialNo  = D.SerialNo) AND (CNL.BaseDocRowNo = D.DocRowNo)
				) AS CanceledQty, IsNull(SUM(U.Qty), 0) AS UsedQty
		FROM	inv.tblStoresRequestsDtl D
					LEFT JOIN #tblUse U ON U.ProcessID = D.ProcessID AND U.ProcessNo = D.ProcessNo AND U.FiscalYear = D.FiscalYear AND U.SerialNo = D.SerialNo AND U.DocRowNo = D.DocRowNo
		WHERE   ' + @StrWhere + '
		GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, D.ConfirmQuantity
	) T 
	WHERE (T.UsedQty < T.ConfirmQuantity - T.CanceledQty) 
	ORDER BY ' + @SortFields
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
