USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Zia
-- Create date   : 1386/11/15
-- Viewed By	 : 
-- Last Modified : 1392/03/01
-- Last Modifier : TakroSystem\Zia
-- Description   : لیست سفارشات
-- =============================================
CREATE PROCEDURE [sal].[RptSaleOrder_Docs_Ex_Inner]
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
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@SortFields		VarChar(100) = NULL,
	@RepOptions		VarChar(20) = '21', -- bit array
	@RepInfo		VarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhereX	NVarChar(max);
DECLARE @StrSale	nvarchar(2000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @DocStep	int;
DECLARE @SaleState	int;
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '21';
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

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;

	SET @DocStep	= Substring(@RepOptions, 1, 1);
	SET @SaleState	= Substring(@RepOptions, 2, 1);
	
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
	IF	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	IF	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	IF	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	IF	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')

	-- DocStep
	If (@DocStep > 0 and @DocStep < 9)
		SET @StrWhere = @StrWhere + ' AND (H.DocStep=' + LTrim(Str(@DocStep)) + ')'
		
	set @StrWhereX = '(1=1)'

	set @StrSale = '
	isnull((
		select count(*)
		from inv.tblStorageDocsDtl
		where (ProcessID=90) and (BaseProcessID=H.ProcessID) and (BaseProcessNo=H.ProcessNo) and (BaseFiscalYear=H.FiscalYear)and (BaseSerialNo=H.SerialNo)
	),0)'
	
	-- without sale
	If (@SaleState = 1)
	SET @StrWhere = @StrWhere + ' and (' + @StrSale + '=0) '
		
	-- with sale
	If (@SaleState = 2)
	SET @StrWhere = @StrWhere + ' and (' + @StrSale + '>0) '
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	select	H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.DocDate, H.AcntCode
	from sal.tblSaleOrderHdr H
	where ' + @StrWhere
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
