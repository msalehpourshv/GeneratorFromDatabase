USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Zia
-- Create date   : 1386/11/15
-- Viewed By	 : 
-- Last Modified : 1391/04/12
-- Last Modifier : TakroSystem\Zia
-- Description   : لیست سفارشات
-- =============================================
CREATE PROCEDURE [sal].[RptSaleOrder_Header]
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = NULL,
	@SerialNoFr		Int = NULL,
	@FiscalYearTo	Int = NULL,
	@SerialNoTo		Int = NULL,
	@DocDateFr		Char(10) = NULL,
	@DocDateTo		Char(10) = NULL,
	@OrdDateFr		Char(10) = NULL,
	@OrdDateTo		Char(10) = NULL,
	@DelDateFr		Char(10) = NULL,
	@DelDateTo		Char(10) = NULL,
	@SelectedAcnt1	Int = NULL,
	@SelectedAcnt2	Int = NULL,
	@SelectedAcnt3	Int = NULL,
	@SelectedAcnt4	Int = NULL,
	@SelectedVisitor1	Int = NULL,
	@SelectedVisitor2	Int = NULL,
	@SelectedVisitor3	Int = NULL,
	@SelectedVisitor4	Int = NULL,
	@SortFields		VarChar(100) = NULL,
	@RepOptions		VarChar(20) = '0100', -- bit array
	@RepInfo		VarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @DocStep	int;
DECLARE @DecRet		bit;
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '0100';
	IF (@ProcessNo	Is Null)	SET @ProcessNo  = 1;

	If (@FiscalYearFr	Is Null) SET @SerialNoFr	= Null;
	If (@FiscalYearTo	Is Null) SET @SerialNoTo	= Null;
	If (@SerialNoFr		Is Null) SET @FiscalYearFr	= Null;
	If (@SerialNoTo		Is Null) SET @FiscalYearTo  = Null;
	If (@SortFields		Is Null) SET @SortFields    = 'FiscalYear, SerialNo';

	IF (@SelectedAcnt1 Is Null) SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null) SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null) SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null) SET @SelectedAcnt4 = 0;

	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0;
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0;
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0;
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0;

	SET @DocStep	= Substring(@RepOptions, 1, 1);
	SET @DecRet		= Substring(@RepOptions, 2, 1);

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = ' (H.ProcessID=180) AND (H.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	If (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear>' + LTrim(Str(@FiscalYearFr)) + ') OR (H.FiscalYear=' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo>=' + LTrim(Str(@SerialNoFr)) + ')) '
	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear<' + LTrim(Str(@FiscalYearTo)) + ') OR (H.FiscalYear=' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo<=' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate>=''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate<=''' + @DocDateTo + ''')'

	If (@OrdDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.OrderDate>=''' + @OrdDateFr + ''')'
	If (@OrdDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.OrderDate<=''' + @OrdDateTo + ''')'

	If (@DelDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DeliveryDate>=''' + @DelDateFr + ''')'
	If (@DelDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DeliveryDate<=''' + @DelDateTo + ''')'

	-- Acnt
	IF	(@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode') 
	IF	(@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode') 
	IF	(@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode') 
	IF	(@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode') 

	-- Visitor
	IF	(@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode')
	IF	(@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode')
	IF	(@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode')
	IF	(@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode')

	-- DocStep
	If (@DocStep Is Not Null) and (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (H.DocStep=' + Str(@DocStep) + ')'
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	SELECT	H.*,F.VisitPathID1, F.VisitPathID2, F.VisitPathID3, F.VisitPathID4, F.AcntName,
			F.Address1 Address, F.Tel, F.Fax, F.OtherTels, F.ZipCode, F.Mobile,
			(
				select sum(D.GoodsQuantity*D.GoodsPrice)
				from sal.tblSaleOrderDtl D
				where (D.ProcessID=H.ProcessID) and (D.ProcessNo=H.ProcessNo) and (D.FiscalYear=H.FiscalYear) and (D.SerialNo=H.SerialNo)
			) SumPrice,
			isnull((
				select sum(Debit-Credit)
				from acc.tblVoucherDtl V
				where (V.VchKind <> 0) and (V.AcntCode=H.AcntCode)
			),0) DebitRemain
	FROM	sal.tblSaleOrderHdr H
			outer apply acc.funGetCodeInfo(H.AcntCode) F 
	WHERE   ' + @StrWhere + '
	ORDER BY ' + @SortFields
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
