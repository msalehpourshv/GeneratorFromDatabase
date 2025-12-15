USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1392/09/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description   : <کالای ارسالی دریافت نشده>
-- =================================================================
CREATE PROCEDURE [inv].[RptStore_SentNotRetEx]
	@ProcessID		Int = 130,
	@ProcessNo		Int = Null,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@SelectedGoods	Int = Null,
	@SelectedAcnt1	Int = Null,
	@SelectedAcnt2	Int = Null,
	@SelectedAcnt3	Int = Null,
	@SelectedAcnt4	Int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SortFields		NVarChar(100) = Null,
	@RepOptions		VarChar(10) = '',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhereS	NVarChar(2000)
DECLARE @StrWhereR	NVarChar(2000)

DECLARE @RetProcessID	Int;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;
BEGIN

	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;
	if (@SelectedAcnt1	Is Null)	set @SelectedAcnt1 = 0;
	if (@SelectedAcnt2	Is Null)	set @SelectedAcnt2 = 0;
	if (@SelectedAcnt3	Is Null)	set @SelectedAcnt3 = 0;
	if (@SelectedAcnt4	Is Null)	set @SelectedAcnt4 = 0;

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	if (@SortFields is null)	set @SortFields = 'GoodsID';
	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------

	-- where section ----------------------------------------------------------
	--- common --- 
	set @StrWhereS = '(1=1)';
	set @StrWhereR = '(1=1)';

	set @RetProcessID = 0;
	
	if @ProcessID = 130 set @RetProcessID = 135;
	if @ProcessID = 136 set @RetProcessID = 131;

	IF (@ProcessNo Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	If (@DocDateFr Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (D.DocDate>=''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (D.DocDate<=''' + @DocDateTo + ''')'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	if (@SelectedGoods > 0)
		set @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	set @StrWhereR = @StrWhereS
	
	--- send only --- 
	IF (@SerialNoFr Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (D.FiscalYear>' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo>=' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhereS = @StrWhereS + ' AND (D.FiscalYear<' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear=' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo<=' + LTrim(Str(@SerialNoTo)) + '))' 
	---------------------------------------------------------------------------
	-- select section ---------------------------------------------------------
	
	SET @StrSelect = '
	select M.*, G.GoodsName, pub.GetCodeName(AcntCode, 1) AcntName
	from
	(
		select	T.AcntCode, T.GoodsID, sum(T.GoodsQuantity) RemainQuantity
		from	(
					select D.AcntCode, D.GoodsID, D.GoodsQuantity
					from inv.tblStorageDocsDtl D
					where (D.ProcessID=' + ltrim(str(@ProcessID)) + ') and ' + @StrWhereS + '
					union all
					select D.AcntCode, D.GoodsID, 0-D.GoodsQuantity
					from inv.tblStorageDocsDtl D
					where (D.ProcessID=' + ltrim(str(@RetProcessID)) + ') and ' + @StrWhereR + '
				) T
		group by T.AcntCode, T.GoodsID
	) M	inner join inv.tblGoodsDtl G on G.GoodsID = M.GoodsID
	where RemainQuantity>0
	order by ' + @SortFields

	print @StrSelect;
	exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
