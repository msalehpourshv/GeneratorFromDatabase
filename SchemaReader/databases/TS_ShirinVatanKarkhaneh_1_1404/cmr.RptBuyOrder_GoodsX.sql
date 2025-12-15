USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/02/10
-- Viewed By	 : 
-- Last Modified : 1388/04/16
-- Last Modifier : TakroSystem\Zia
-- Description	 : لیست سفارش خرید یک کالا
-- ==============================================
Create PROCEDURE [cmr].[RptBuyOrder_GoodsX]
	@ProcessNo		Int = 1,
	@GoodsID		VarChar(20) = Null, 
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0, 
	@AgreeNoFr		varchar(20) = null,
	@AgreeNoTo		varchar(20) = null,
	@SortFields		NVarChar(100) = NULL,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE @PID_ORD	VarChar(3);
DECLARE @PID_REQ	VarChar(3);
DECLARE @PID_BUY	VarChar(3);
DECLARE @PID_BUY_RET VarChar(3);
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
Begin --============== S T A R T  C O D E ===================================================

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NoCount On;

	-- I N I T ----------------------------------------------------------------
	IF (@ProcessNo		Is Null)	SET @ProcessNo  = 1;
	IF (@RepInfo		Is Null)	SET @RepInfo	= '1@1@1';
	IF (@GoodsID		Is Null)	SET @GoodsID	= '';

	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	IF (@SortFields		Is Null)	SET @SortFields     = 'FiscalYear, SerialNo';
	IF (@GoodsID		Is Null)	SET @GoodsID		= '';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @PID_REQ = '150';
	SET @PID_ORD = '160';
	SET @PID_BUY = '55';
	SET @PID_BUY_RET = '60';	-- ProcessID for Buy Return
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = ' D.ProcessID  = ' + @PID_ORD + ' AND 
		D.ProcessNo = ' + LTrim(Str(@ProcessNo)) 

	if @GoodsID <> ''
		SET @StrWhere = @StrWhere + ' AND D.GoodsID  = ''' + @GoodsID + ''''

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
	SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, D.GoodsID, 
			[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
			IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,
			D.GoodsQuantity OrderedQty,
			(
				SELECT	IsNull(Sum(CNL.GoodsQuantity), 0)
				FROM	cmr.tblOrderDtl AS CNL
				WHERE	CNL.BaseProcessID = D.ProcessID AND CNL.BaseProcessNo = D.ProcessNo AND CNL.BaseFiscalYear = D.FiscalYear AND CNL.BaseSerialNo = D.SerialNo AND CNL.BaseDocRowNo = D.DocRowNo
			) AS CanceledQty
	INTO #tbl_RptBuyOrder_GoodsX_Ord
	FROM cmr.tblOrderDtl AS D
	WHERE  ' + @StrWhere + '

	select *
	into #tbl_RptBuyOrder_GoodsX_Buy
	from
	(
		-- ORDER -> BUY
		SELECT	BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, 
				FiscalYear, SerialNo, DocRowNo, S.DocDate, GoodsQuantity -
				(
					SELECT	IsNULL(Sum(GoodsQuantity), 0)
					FROM    inv.tblStorageDocsDtl
					WHERE   (ProcessID = ' + @PID_BUY_RET + ') and BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND BaseDocRowNo = S.DocRowNo 
				) AS Qty
		FROM	inv.tblStorageDocsDtl S
		WHERE	(S.ProcessID = ' + @PID_BUY + ') and (S.BaseProcessID = ' + @PID_ORD + ')
		UNION all
		-- ORDER -> RECEIPT -> BUY
		SELECT	R.BaseProcessID, R.BaseProcessNo, R.BaseFiscalYear, R.BaseSerialNo, R.BaseDocRowNo, 
				S.FiscalYear, S.SerialNo, S.DocRowNo, S.DocDate, S.GoodsQuantity -
				(
					SELECT	IsNULL(Sum(GoodsQuantity), 0)
					FROM    inv.tblStorageDocsDtl
					WHERE   (ProcessID = ' + @PID_BUY_RET + ') and BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND	BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND	BaseDocRowNo = S.DocRowNo 
				) AS Qty
		FROM	inv.tblInvTempReceiptDtl R
					INNER JOIN inv.tblStorageDocsDtl S ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
		WHERE (S.ProcessID = ' + @PID_BUY + ') and (R.BaseProcessID = ' + @PID_ORD + ')
	) B

	SELECT	D.*, B.Qty BoughtQty, B.FiscalYear BuyFiscalYear, B.SerialNo BuySerialNo, B.DocRowNo BuyDocRowNo, B.DocDate BuyDocDate,	[pub].GetCodeName(D.AcntCode, ' + @LangID + ') As AcntName
	FROM #tbl_RptBuyOrder_GoodsX_Ord D
			inner join #tbl_RptBuyOrder_GoodsX_Buy B on B.BaseProcessID = D.ProcessID AND B.BaseProcessNo = D.ProcessNo AND B.BaseFiscalYear = D.FiscalYear AND B.BaseSerialNo = D.SerialNo AND B.BaseDocRowNo = D.DocRowNo
	ORDER BY ' + @SortFields + ', B.FiscalYear, B.SerialNo, B.DocRowNo'
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
