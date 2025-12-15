USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/01/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : <لیست اسناد بچ یک محصول>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_BatchDocs]
	@SelectedGoods	int = 0,
	@SelectedStore	int = 0,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@BatchNoFr		varchar(20) = Null,
	@BatchNoTo		varchar(20) = Null,
	@FiscalYearFr	int = Null,
	@SerialNoFr		int = Null,
	@FiscalYearTo	int = Null,
	@SerialNoTo		int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SortFields		nvarchar(100) = Null,
	@RepOptions		varchar(10) = '',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
BEGIN
	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';
	if (@SelectedStore	Is Null)	set @SelectedStore = 0;
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;

	if (@SelectedAcnt1	Is Null)	set @SelectedAcnt1 = 0;
	if (@SelectedAcnt2	Is Null)	set @SelectedAcnt2 = 0;
	if (@SelectedAcnt3	Is Null)	set @SelectedAcnt3 = 0;
	if (@SelectedAcnt4	Is Null)	set @SelectedAcnt4 = 0;

	if (@FiscalYearFr Is Null)	set @SerialNoFr = Null;
	if (@FiscalYearTo Is Null)	set @SerialNoTo = Null;
	if (@SerialNoFr	Is Null)	set @FiscalYearFr = Null;
	if (@SerialNoTo	Is Null)	set @FiscalYearTo = Null;
	if (@SortFields	Is Null)	set @SortFields = 'GoodsID';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	--set @Inc = Substring(@RepOptions, 1, 1);
	--set @Dec = Substring(@RepOptions, 2, 1);
	---------------------------------------------------------------------------
	-- where section ----------------------------------------------------------
	set @StrWhere = '(D.BatchNo <> '''') and (D.BatchNo <> ''0'') and (D.ProcessID in (80,72,73))';

	if (@SerialNoFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	if (@SerialNoTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	if (@DocDateFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	if (@BatchNoFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.BatchNo >= ''' + ltrim(@BatchNoFr) + ''')'
	if (@BatchNoTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.BatchNo <= ''' + ltrim(@BatchNoTo) + ''')'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	if (@SelectedStore > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 
	-- select section ---------------------------------------------------------

	set @StrSelect = '
	select	D.StoreID, D.BatchNo, D.FiscalYear, D.SerialNo, D.DocDate,
			D.AcntCode, pub.GetCodeName(D.AcntCode, 1) AcntName,
			D.GoodsID, [pub].[funGetGoodsName](D.GoodsID, ' + LTrim(RTrim(@LangID)) + ') As GoodsName, D.GoodsQuantity
	from	inv.tblStorageDocsDtl D
	where	' + @StrWhere + '
	order By ' + @SortFields

	print @StrSelect;
	exec sp_executesql @StrSelect;
END
GO
