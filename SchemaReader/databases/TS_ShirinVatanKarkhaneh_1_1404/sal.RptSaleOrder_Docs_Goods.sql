USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1387/02/14
-- Viewed By	 : 
-- Last Modified : 1389/06/25
-- Last Modifier : TakroSystem\Zia
-- Description   : لیست سفارشات یک کالا 
-- =============================================
CREATE PROCEDURE [sal].[RptSaleOrder_Docs_Goods] 
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = NULL,
	@FiscalYearTo	Int = NULL,
	@SerialNoFr		Int = NULL,
	@SerialNoTo		Int = NULL,
	@GoodsID		VarChar(20),
	@DateFr			Char(10) = NULL,
	@DateTo			Char(10) = NULL,
	@AgreeNoFr		VarChar(20) = NULL,
	@AgreeNoTo		VarChar(20) = NULL,
	@OrderCode1		Int = NULL,
	@OrderCode2		Int = NULL,
	@OrderCode3		Int = NULL,
	@OrderCode4		Int = NULL,
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@SortFields		NVarChar(100) = NULL,
	@RepOptions		VarChar(20) = '0', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

Declare @DocStep	Int;
Declare @DecRet		Bit; 
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '0';
	IF (@ProcessNo  Is Null)	SET @ProcessNo  = 1
	IF (@SortFields Is Null)	SET @SortFields = 'FiscalYear,SerialNo,DocRowNo'

	IF (@FiscalYearFr	Is Null)	SET @SerialNoFr		= Null;
	IF (@FiscalYearTo	Is Null)	SET @SerialNoTo		= Null;
	IF (@SerialNoFr		Is Null)	SET @FiscalYearFr	= Null;
	IF (@SerialNoTo		Is Null)	SET @FiscalYearTo   = Null;

	IF (@OrderCode1 Is Null)	SET @OrderCode1 = 0
	IF (@OrderCode2 Is Null)	SET @OrderCode2 = 0
	IF (@OrderCode3 Is Null)	SET @OrderCode3 = 0
	IF (@OrderCode4 Is Null)	SET @OrderCode4 = 0

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @DecRet		= Substring(@RepOptions, 1, 1);
	SET @DocStep	= Substring(@RepOptions, 2, 1);
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = ' (D.ProcessID=180) AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ') AND (GoodsID=''' + @GoodsID + ''')'

	If (@FiscalYearFr	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@DateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate>=''' + @DateFr + ''')'
	If (@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @DateTo + ''')'

	If (@DocStep > 0)
		Set @StrWhere = @StrWhere + ' AND (D.DocStep = ' + Str(@DocStep) + ')'

	If	(@OrderCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @OrderCode1, 'D.AcntCode') 
	If	(@OrderCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @OrderCode2, 'D.AcntCode') 
	If	(@OrderCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @OrderCode3, 'D.AcntCode') 
	If	(@OrderCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @OrderCode4, 'D.AcntCode') 

	If	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	If	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	If	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	If	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	if (@DecRet = 1)
		set @StrSelect = '
			(
				SELECT	IsNull(Sum(GoodsQuantity), 0) AS SoldRet
				FROM    inv.tblStorageDocsDtl
				WHERE   (ProcessID=100) and BaseProcessID = SD.ProcessID AND BaseProcessNo = SD.ProcessNo AND BaseFiscalYear = SD.FiscalYear AND BaseSerialNo = SD.SerialNo AND	BaseDocRowNo = SD.DocRowNo
			)'
	else
		set @StrSelect = 'cast(0 as float)'

	SET @StrSelect = '
	SELECT	T.*, [pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName
	FROM
	(
		SELECT	D.*, 
				(
					SELECT	IsNull(Sum(GoodsQuantity), 0)
					FROM	sal.tblSaleOrderDtl
					WHERE	(ProcessID=185) and BaseProcessID=D.ProcessID AND BaseProcessNo=D.ProcessNo AND BaseFiscalYear=D.FiscalYear AND BaseSerialNo=D.SerialNo AND BaseDocRowNo=D.DocRowNo
				) AS CancelQuantity,
				(
					-- Sold Pure Qty = sum of sold qty - sum of sold return qty
					SElECT IsNull(Sum(SOLD.GoodsQuantity - SOLD.SoldRet), 0)
					FROM
					(
						SELECT	SD.GoodsQuantity, ' + @StrSelect + ' AS SoldRet
						FROM	inv.tblStorageDocsDtl SD
						WHERE	(SD.ProcessID=90) AND SD.BaseProcessID = D.ProcessID AND SD.BaseProcessNo = D.ProcessNo AND SD.BaseFiscalYear = D.FiscalYear AND SD.BaseSerialNo = D.SerialNo AND SD.BaseDocRowNo = D.DocRowNo
					) AS SOLD
				) AS SoldQuantity
		FROM	sal.tblSaleOrderDtl AS D
					INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		WHERE   ' + @StrWhere + '
	) T '

	SET @StrSelect = @StrSelect + '
	ORDER BY ' + @SortFields
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
