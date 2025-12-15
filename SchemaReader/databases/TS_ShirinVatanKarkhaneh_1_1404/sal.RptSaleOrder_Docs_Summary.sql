USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1387/02/14
-- Viewed By	 : 
-- Last Modified : 1389/06/16
-- Last Modifier : TakroSystem\zIA
-- Description   : لیست سفارشات فروش- خلاصه
-- =============================================
CREATE PROCEDURE [sal].[RptSaleOrder_Docs_Summary] 
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = NULL,
	@FiscalYearTo	Int = NULL,
	@SerialNoFr		Int = NULL,
	@SerialNoTo		Int = NULL,
	@DocDateFr		Char(10) = NULL,
	@DocDateTo		Char(10) = NULL,
	@OrdDateFr		Char(10) = NULL,
	@OrdDateTo		Char(10) = NULL,
	@DelDateFr		Char(10) = NULL,
	@DelDateTo		Char(10) = NULL,
	@SelectedOrder1	Int = NULL,
	@SelectedOrder2	Int = NULL,
	@SelectedOrder3	Int = NULL,
	@SelectedOrder4	Int = NULL,
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@DocStep		Int = 0,
	@RemainOnly		Bit = 0,    -- فقط سفارشاتی که مانده دارند (سفارش با تحویل برابر نیست) بیاید؟
	@SortFields		NVarChar(100) = NULL,
	@RepOptions		NVarChar(20) = '1', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrSelect2	NVarChar(1000);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @StrWhere2	NVarChar(1000);

DECLARE @StrPID_ORD	VarChar(3);
DECLARE @StrPID_SAL	VarChar(3);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @DecRet		bit;

DECLARE @GetRemainSaleOrder AS  Nvarchar(5);

Begin --============== S T A R T  C O D E ===================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Set NoCount On;

	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '1';
	IF (@DocStep < 1)			SET @DocStep	= Null;
	IF (@ProcessNo	   Is Null) SET @ProcessNo  = 1;
	IF (@RemainOnly	   Is Null) SET @RemainOnly = 0;

	IF (@SelectedOrder1 Is Null)	SET @SelectedOrder1 = 0;
	IF (@SelectedOrder2 Is Null)	SET @SelectedOrder2 = 0;
	IF (@SelectedOrder3 Is Null)	SET @SelectedOrder3 = 0;
	IF (@SelectedOrder4 Is Null)	SET @SelectedOrder4 = 0;

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;

	If (@FiscalYearFr	Is Null) SET @SerialNoFr	= Null;
	If (@FiscalYearTo	Is Null) SET @SerialNoTo	= Null;
	If (@SerialNoFr		Is Null) SET @FiscalYearFr	= Null;
	If (@SerialNoTo		Is Null) SET @FiscalYearTo  = Null;
	If (@SortFields		Is Null) SET @SortFields    = 'FiscalYear, SerialNo';

	SET @DecRet	= Substring(@RepOptions, 1, 1);

	SET @StrPID_ORD = '180'; -- Sale Order ProcessID
	SET @StrPID_SAL = '90';  -- Sale ProcessID

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @GetRemainSaleOrder = 'False'
	SELECT @GetRemainSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GetRemainSaleOrder'

	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	--SET @StrWhere = ' (D.AutoOrder = 0) and D.ProcessID  = ' + LTrim(Str(@StrPID_ORD)) + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	SET @StrWhere = ' D.ProcessID  = ' + LTrim(Str(@StrPID_ORD)) + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate>=''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @DocDateTo + ''')'

	If (@OrdDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.OrderDate>=''' + @OrdDateFr + ''')'
	If (@OrdDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.OrderDate<=''' + @OrdDateTo + ''')'

	If (@DelDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DeliveryDate>=''' + @DelDateFr + ''')'
	If (@DelDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DeliveryDate<=''' + @DelDateTo + ''')'

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
	If (@DocStep Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep = ' + Str(@DocStep) + ')'
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	IF @GetRemainSaleOrder = 'True'
		SET @StrSelect2 = 'AND SD.BaseDocRowNo = D.DocRowNo'
	Else
		SET @StrSelect2 = ''

	IF (@DecRet = 1) 
		SET @StrSelect = '
			(
				SELECT	IsNull(Sum(GoodsQuantity), 0) AS SoldRet
				FROM    inv.tblStorageDocsDtl
				WHERE   BaseProcessID = SD.ProcessID AND BaseProcessNo = SD.ProcessNo AND BaseFiscalYear = SD.FiscalYear AND BaseSerialNo = SD.SerialNo AND	BaseDocRowNo = SD.DocRowNo
			)'
	else
		set @StrSelect = 'cast(0 as float)'

	Set @StrSelect = '
	SELECT	DISTINCT T.*, [pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName
	FROM
	(
		SELECT	D.FiscalYear, D.SerialNo, D.DocDate, D.AcntCode, D.OrderDate, D.DeliveryDate, D.GoodsQuantity ConfirmQuantity,
				(
					SELECT	IsNull(Sum(GoodsQuantity), 0)
					FROM	sal.tblSaleOrderDtl
					WHERE	BaseProcessID = D.ProcessID AND BaseProcessNo = D.ProcessNo AND BaseFiscalYear = D.FiscalYear AND BaseSerialNo = D.SerialNo AND BaseDocRowNo = D.DocRowNo 
				) AS CancelQty,
				(
					-- Sold Pure Qty = sum of sold qty - sum of sold return qty
					SELECT IsNull(Sum(Sold - SoldRet), 0)
					FROM
					(
						SELECT	GoodsQuantity AS Sold, ' + @StrSelect + ' AS SoldRet
						FROM	inv.tblStorageDocsDtl SD
						WHERE	SD.ProcessID = ' + @StrPID_SAL + ' AND SD.BaseProcessID = D.ProcessID AND SD.BaseProcessNo = D.ProcessNo AND SD.BaseFiscalYear = D.FiscalYear AND SD.BaseSerialNo = D.SerialNo ' + @StrSelect2 + '
					) SaleAndRet
				) AS SoldQty
		FROM	sal.tblSaleOrderDtl AS D
					INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		WHERE   ' + @StrWhere + '
	) T '
	
	IF @GetRemainSaleOrder = 'True'
		SET @StrWhere2 = 'WHERE (T.SoldQty < T.ConfirmQuantity - T.CancelQty)'
	Else
		SET @StrWhere2 = 'WHERE T.SoldQty < 1'
	
	If (@RemainOnly = 1)
	SET @StrSelect = @StrSelect + ' ' + @StrWhere2

	SET @StrSelect = @StrSelect + '
	ORDER BY ' + @SortFields
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
