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
Create PROCEDURE [inv].[RptUseReq_List_Detailed]
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
declare @SelectedStore2	Int;

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	if (@SortFields Is Null) set @SortFields = 'FiscalYear, SerialNo'
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
	set @SelectedStore	= pub.funSplitString(@RepInfo, '@', 6);
	set @SelectedStore2	= pub.funSplitString(@RepInfo, '@', 7);

	--set @P1	= Substring(@RepOptions, 1, 1);
	--set @P2	= Substring(@RepOptions, 2, 1);
	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = '(D.ProcessID = ' + LTrim(Str(@ProcessID)) + ') AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

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
	IF (@SelectedStore2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')


	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	---------------------------------------------------------------------------
	---- S E L E C T ----------------------------------------------------------
	Set @StrSelect = '
	SELECT	DISTINCT D.*, GD.GoodsName, U.UnitName, pub.GetCodeName(D.AcntCode, ' + @LangID + ') As AcntName
	,Isnull(Cast((select sum(S.GoodsQuantity  )  from inv.tblStorageDocsDtl S where  S.BaseProcessID = D.ProcessID AND S.BaseProcessNo = D.ProcessNo AND S.BaseFiscalYear = D.FiscalYear AND S.BaseSerialNo = D.SerialNo AND S.BaseDocRowNo = D.DocRowNo and ProcessID in (110,115,120)) as float ),0) UseGoodsQuantity
	,Isnull(Cast((select sum(S.GoodsQuantity  )  from inv.tblStoresRequestsDtl S where  S.BaseProcessID = D.ProcessID AND S.BaseProcessNo = D.ProcessNo AND S.BaseFiscalYear = D.FiscalYear AND S.BaseSerialNo = D.SerialNo AND S.BaseDocRowNo = D.DocRowNo and ProcessID in (128)) as float ),0) RqstCncl
	FROM    inv.tblStoresRequestsDtl D
				LEFT JOIN inv.tblGoods    GH ON GH.GoodsID = D.GoodsID 
				LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID = D.GoodsID 
				LEFT JOIN inv.tblUnitsDtl U  ON  U.UnitID = GH.UnitID 
	WHERE   ' + @StrWhere + '
	ORDER BY ' + @SortFields
	---------------------------------------------------------------------------
	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
