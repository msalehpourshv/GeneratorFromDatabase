USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid	
-- Create date   : 1394/09/10
-- Viewed By		 : Hadi Sadeghi
-- Last Modified : 
-- Last Modifier : 
-- Description   : گزارش وضعیت یک رسید موقت
-- =============================================
Create PROCEDURE [inv].[RptStateTempReceipt_Situation]
	@ProcessID				Int = 170, 
	@ProcessNo				Int = 1,
	@FiscalYearFr			Int = Null,
	@SerialNoFr				Int = Null,
	@FiscalYearTo			Int = Null,
	@SerialNoTo				Int = Null,
	@DocDateFr				Char(10) = Null,
	@DocDateTo				Char(10) = Null,
	@SelectedGoods			Int = 0, 
	@SelectedAcnt1			Int = 0, 
	@SelectedAcnt2			Int = 0, 
	@SelectedAcnt3			Int = 0, 
	@SelectedAcnt4			Int = 0,
	@RepInfo				NVarChar(100) = '1@1@1',
	@ExtraParams			NVarChar(500) = ''

WITH ENCRYPTION
AS

DECLARE @StrSelect	    NVarChar(Max);
DECLARE @StrSelect1	    NVarChar(Max);
DECLARE @StrSelect2	    NVarChar(Max);
DECLARE @StrSelect3	    NVarChar(Max);
DECLARE @StrWhere	    NVarChar(Max);
DECLARE @StrWhereBuy	NVarChar(Max);

DECLARE @StrGoodsID		VarChar(100);
DECLARE @StrGoodsName	VarChar(100);
DECLARE @StrQuantity	VarChar(100);
DECLARE @StrGoodsUnit	VarChar(100);
DECLARE @StrOrderDuration VarChar(100);
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
DECLARE	@SortType		Int;

BEGIN --============== S T A R T  C O D E ===================================================

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	IF (@ProcessNo  Is Null) SET @ProcessNo  = 1;
	IF (@RepInfo	Is Null) SET @RepInfo	= '1@1@1';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;

	IF (@SelectedAcnt1	 	 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	 	 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	 	 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	 	 Is Null)	SET @SelectedAcnt4 = 0;
		
	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @SortType= pub.funSplitString(@ExtraParams, '@', 1);	


	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = 'D.ProcessID = 170 AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	if @ProcessID=175
	Set @StrWhere = @StrWhere + ' and IsNull(D.CancelQty,0) >0'
	
	Set @StrWhereBuy = 'where 1=1 '

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate = ''' + @DocDateFr + ''')'
		Else
		Begin
			IF (@DocDateFr Is Not Null) 
				SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		End
		
	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
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

select * into #tbl
from inv.tblInvTempReceiptDtl where 1=0
	
	Set @StrSelect1 = '	
	insert into #tbl 
	select * from inv.tblInvTempReceiptDtl D
	where ' + @StrWhere + '
 '

	---- R U N ----------------------------------------------------------------
	--Print '--================================================'
	Print @StrSelect1;
	Exec sp_executesql @StrSelect1;
	---------------------------------------------------------------------------
	Set @StrSelect1 = '	select * 
	, case when SubUnitQuantity01=0 then 0 else SubUnitQuantity01/SubUnitQuantity end *100 SubUnitQuantity02
	, case when SubUnitQuantity11=0 then 0 else SubUnitQuantity11/SubUnitQuantity end *100  SubUnitQuantity12
	, case when SubUnitQuantity21=0 then 0 else SubUnitQuantity21/SubUnitQuantity end *100  SubUnitQuantity22
	, case when SubUnitQuantity31=0 then 0 else SubUnitQuantity31/SubUnitQuantity end *100  SubUnitQuantity32
	, case when SubUnitQuantity41=0 then 0 else SubUnitQuantity41/SubUnitQuantity end *100  SubUnitQuantity42
	 from (
	select AcntCode,GoodsID ,SubUnitID
	,inv.funGetUnitName(SubUnitID,'+@LangID+') AS SubUnitName
	,pub.GetCodeName(AcntCode,'+@LangID+') AcntName
	,pub.funGetGoodsName(GoodsID,'+@LangID+') AS GoodsName,
	sum(SubUnitQuantity) SubUnitQuantity
	,isnull( ( select sum(SubUnitQuantity) from #tbl D2 where Recognition =0  and D.AcntCode=D2.AcntCode and D.GoodsID=D2.GoodsID and D.SubUnitID=D2.SubUnitID),0) SubUnitQuantity01
	,isnull(  ( select sum(ConfirmQuantity) from #tbl D2 where  Recognition =1  and D.AcntCode=D2.AcntCode and D.GoodsID=D2.GoodsID and D.SubUnitID=D2.SubUnitID),0)SubUnitQuantity11
	,isnull( ( select sum(ConfirmQuantity) from #tbl D2 where Recognition =2  and D.AcntCode=D2.AcntCode and D.GoodsID=D2.GoodsID and D.SubUnitID=D2.SubUnitID),0)SubUnitQuantity21
	,isnull(  ( select sum(ConfirmQuantity) from #tbl D2 where Recognition =3  and D.AcntCode=D2.AcntCode and D.GoodsID=D2.GoodsID and D.SubUnitID=D2.SubUnitID),0)SubUnitQuantity31
	,isnull(  ( select sum(ConfirmQuantity) from #tbl D2 where Recognition =4  and D.AcntCode=D2.AcntCode and D.GoodsID=D2.GoodsID and D.SubUnitID=D2.SubUnitID),0)SubUnitQuantity41
from #tbl D
Group by  AcntCode,GoodsID ,SubUnitID)
T
'
if @SortType=1
	Set @StrSelect1 = @StrSelect1 +'order by AcntCode '
if @SortType=2
	Set @StrSelect1 = @StrSelect1 +'order by AcntName '
if @SortType=3
	Set @StrSelect1 = @StrSelect1 +'order by GoodsID '
if @SortType=4
	Set @StrSelect1 = @StrSelect1 +'order by GoodsName '
if @SortType=5
	Set @StrSelect1 = @StrSelect1 +'order by SubUnitQuantity '

Print @StrSelect1;
	Exec sp_executesql @StrSelect1;
	

 
END
GO
