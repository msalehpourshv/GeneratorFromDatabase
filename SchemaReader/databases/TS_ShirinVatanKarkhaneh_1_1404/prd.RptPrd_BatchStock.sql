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
-- Description   : <لیست مغایرت مواد ارسالی به بچ با فرمول تولید>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_BatchStock]
	@GoodsID		varchar(20) = '0',
	@SelectedStore	Int = Null,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
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
	set @StrWhere = '(GoodsID = ''' + @GoodsID + ''')';

	if (@SerialNoFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	if (@SerialNoTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	if (@DocDateFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	if (@SelectedStore > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	-- select section ---------------------------------------------------------

	set @StrSelect = '
	select	StoreID, BatchNo, 
			sum(case when EnterKind > 0 then GoodsQuantity else 0 end) as Qty_Input,
			sum(case when EnterKind < 0 then GoodsQuantity else 0 end) as Qty_Output
	from inv.tblStorageDocsDtl D
	where ' + @StrWhere + '
	group by StoreID, BatchNo
	order By StoreID, BatchNo '

	print @StrSelect;
	exec sp_executesql @StrSelect;
END
GO
