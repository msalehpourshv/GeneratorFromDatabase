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
-- Description	 : لیست برگه های درخواست مصرف
-- ==============================================
CREATE PROCEDURE [inv].[RptUseReq_List_Summary]
	@ProcessID			Int = 230, 
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = 0,
	@SerialNoFr			Int = 0,
	@FiscalYearTo		Int = 0,
	@SerialNoTo			Int = 0,
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedGoods		Int = 0, 
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SortFields			NVarChar(100) = Null,  -- لیست فیلدها برای مرتب کردن
	@RepOptions			VarChar(20) = '1', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	if (@SortFields Is Null) set @SortFields = 'H.FiscalYear, H.SerialNo'
	if (@ProcessNo  Is Null) set @ProcessNo  = 1;
	if (@RepInfo	Is Null) set @RepInfo	= '1@1@1';

	if (@SelectedAcnt1 Is Null)	set @SelectedAcnt1 = 0;
	if (@SelectedAcnt2 Is Null)	set @SelectedAcnt2 = 0;
	if (@SelectedAcnt3 Is Null)	set @SelectedAcnt3 = 0;
	if (@SelectedAcnt4 Is Null)	set @SelectedAcnt4 = 0;
	if (@SelectedGoods Is Null)	set @SelectedGoods = 0;
	if (@SelectedStore Is Null)	set @SelectedStore = 0;

	if (@FiscalYearFr Is Null)	set @SerialNoFr = Null;
	if (@FiscalYearTo Is Null)	set @SerialNoTo = Null;
	if (@SerialNoFr	Is Null)	set @FiscalYearFr = Null;
	if (@SerialNoTo	Is Null)	set @FiscalYearTo = Null;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	--set @P1	= Substring(@RepOptions, 1, 1);
	--set @P2	= Substring(@RepOptions, 2, 1);
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = '(H.ProcessID = ' + LTrim(Str(@ProcessID)) + ') AND (H.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)	
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (H.DocDate  = ''' + @DocDateFr + ''')'
		Else
		Begin
			IF (@DocDateFr Is Not Null) 
				SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'
		End

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')
	---------------------------------------------------------------------------
	---- S E L E C T ----------------------------------------------------------
	Set @StrSelect = '
		SELECT	DISTINCT H.*, pub.GetCodeName(H.AcntCode, ' + @LangID + ') As AcntName
		FROM	inv.tblStoresRequestsHdr H
		INNER JOIN inv.tblStoresRequestsDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H. ProcessNo And
												  D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
		WHERE   ' + @StrWhere + '
		ORDER BY ' + @SortFields
	---------------------------------------------------------------------------
	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
