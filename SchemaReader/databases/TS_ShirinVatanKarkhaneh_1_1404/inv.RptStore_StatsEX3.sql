USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/04/24
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description   : <Store Statistics>
-- ----------------------------------------------
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_StatsEX3]
	@ProcessID		Int = 90,
	@ProcessNo		Int = 1,
	@FiscalFr		Int = Null,
	@SerialFr		Int = Null,
	@FiscalTo		Int = Null,
	@SerialTo		Int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SelectedPath1		int = 0,
	@SelectedPath2		int = 0,
	@SelectedPath3		int = 0,
	@SelectedPath4		int = 0,
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@SelectedStore		Int = 0, 
	@AcntCode			varchar(20) = '110101',
	@VisitPathID		varchar(20) = '04',
	@RepOptions			VarChar(20) = '2034', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrGroup	NVarChar(max);
DECLARE @StrWhereA  nvarchar(max);
DECLARE @StrAcnt	VarChar(512);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @PartStart	Int;
DECLARE @PartLen	Int;
DECLARE @PartNo		int;
DECLARE @DocStep	int;
DECLARE @Count		int;
DECLARE @VPathNo	int;
DECLARE @StrPath	varchar(20);
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables & Default Values ----------------------------------------
	IF (@ProcessNo Is Null)		SET @ProcessNo = 1
	IF (@RepOptions Is Null)	SET @RepOptions = '2034';

	IF (@SelectedStore Is Null)		SET @SelectedStore = 0
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0
	IF (@SelectedPath1 Is Null)		SET @SelectedPath1 = 0
	IF (@SelectedPath2 Is Null)		SET @SelectedPath2 = 0
	IF (@SelectedPath3 Is Null)		SET @SelectedPath3 = 0
	IF (@SelectedPath4 Is Null)		SET @SelectedPath4 = 0
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0

	If (@FiscalFr Is Null)	SET @SerialFr = Null;
	If (@FiscalTo Is Null)	SET @SerialTo = Null;
	If (@SerialFr Is Null)	SET @FiscalFr = Null;
	If (@SerialTo Is Null)	SET @FiscalTo = Null;

	SET @PartNo		= Substring(@RepOptions, 1, 1)
	SET @DocStep	= Substring(@RepOptions, 2, 1)
	SET @VPathNo	= Substring(@RepOptions, 3, 1)
	SET @Count		= Substring(@RepOptions, 4, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	if (@PartNo	= 0)
	begin
		set @PartStart = 1
		set @PartLen = 20
	end
	else
		exec [acc].[SpAcc_PartInfo] @PartNo, @PartStart out, @PartLen out

	set @StrAcnt = 'Substring(H.AcntCode,' + ltrim(str(@PartStart)) + ',' + ltrim(str(@PartLen)) + ')'
	set @StrPath = 'VisitPathID' + ltrim(str(@VPathNo))
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	Set @StrWhere = '(H.ProcessID in (' + ltrim(str(@ProcessID)) + '))'

	IF (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	If (@SerialFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear>' + LTrim(Str(@FiscalFr)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalFr)) + ' AND H.SerialNo>=' + LTrim(Str(@SerialFr)) + '))' 
	If (@SerialTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear<' + LTrim(Str(@FiscalTo)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalTo)) + ' AND H.SerialNo<=' + LTrim(Str(@SerialTo)) + '))' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate>=''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (H.DocDate<=''' + @DocDateTo + ''')'

	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'

	set @StrWhere = @StrWhere + ' AND (AH.' + ltrim(@StrPath) + '=''' + ltrim(@VisitPathID) + ''')'
	set @StrWhere = @StrWhere + ' AND (AH.AcntCode=''' + ltrim(@AcntCode) + ''')'
	
	set @StrWhereA = '(1=1)'
	
	if (@SelectedPath1 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPath1, 'AH.VisitPathID1')
	if (@SelectedPath2 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPath2, 'AH.VisitPathID2')
	if (@SelectedPath3 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPath3, 'AH.VisitPathID3')
	if (@SelectedPath4 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPath4, 'AH.VisitPathID4')
	------------------------------------------------------------------
	-- Select Clause ---------------------------------------------------
	set @StrAcnt = 'substring(H.AcntCode,' + ltrim(str(@PartStart)) + ',' + ltrim(str(@PartLen)) + ')'
	
	SET @StrSelect = '
	select	H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,H.DocDesc, H.DocDate,H.DocStep,
			' + @StrAcnt + ' AcntCode,AD.AcntName,
			(
				select sum(D.GoodsQuantity*D.GoodsPrice)
				from inv.tblStorageDocsDtl D
				where D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo
			) + H.SidePriceSum Price
	from inv.vwStorageDocsHdr H
			inner join acc.tblAcnt AH on AH.AcntCode=' + @StrAcnt + ' and AH.PartNumber=' + ltrim(str(@PartNo)) + '
			inner join acc.tblAcntDtl AD on AD.AcntCode=AH.AcntCode and AD.PartNumber=AH.PartNumber
	where ' + @StrWhere + '
	order by H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo'

	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
