USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1391/03/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : آمار فروش - توزیع - وصول
-- ==============================================
CREATE PROCEDURE [sal].[RptSaleOrder_Stats]
	@ProcessNo		Int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SelectedStore		Int = Null,
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@SaleTypeID		VarChar(20) = Null,
	@SortFields		VarChar(100) = Null,
	@RepOptions		VarChar(100) = '21000000',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhereO	NVarChar(max);
DECLARE @StrWhereS	NVarChar(max);
DECLARE @StrWhereP	NVarChar(max);

DECLARE @DecRet		bit;
DECLARE @DocStep	int;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE @SerialNoFrom	Int;
DECLARE @SerialNoTo		Int;
DECLARE @FiscalYearFrom	Int;
DECLARE @FiscalYearTo	Int;
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '1000000';
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1;

	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @FiscalYearFrom	= pub.funSplitString(@RepInfo, '@', 6);
	set @SerialNoFrom	= pub.funSplitString(@RepInfo, '@', 7);
	set @FiscalYearTo	= pub.funSplitString(@RepInfo, '@', 8);
	set @SerialNoTo		= pub.funSplitString(@RepInfo, '@', 9);
	
	SET @DocStep	= Substring(@RepOptions, 1, 1);
	SET @DecRet		= Substring(@RepOptions, 2, 1);
	
	---------------------------------------------------------
	-- Where Clause -----------------------------------------
	SET @StrWhereO = '(H.ProcessID=180)'
	SET @StrWhereS = '(H.ProcessID=90)'
	SET @StrWhereP = '(H.ProcessID=1) and (H.PayTypeID in (1,6,16,26))'

	set @StrWhere = ''

	If (@ProcessNo Is Not Null)
	begin
		SET @StrWhere = ' AND (H.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'
		SET @StrWhereO = @StrWhereO + @StrWhere
		--SET @StrWhereS = @StrWhereS + @StrWhere
	end;

	
	If @FiscalYearFrom Is Not Null and @FiscalYearFrom>0
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear>=' + LTrim(Str(@FiscalYearFrom)) + ')'
	If @FiscalYearTo Is Not Null and @FiscalYearTo>0
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear<=' + LTrim(Str(@FiscalYearTo)) + ')'
	If @SerialNoFrom Is Not Null and @SerialNoFrom>0
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo>=' + LTrim(Str(@SerialNoFrom)) + ')'
	If @SerialNoTo Is Not Null and @SerialNoTo>0
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo<=' + LTrim(Str(@SerialNoTo)) + ')'

	IF (@DocDateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (H.DocDate>=''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		Set @StrWhere = @StrWhere + ' AND (H.DocDate<=''' + @DocDateTo + ''')'

	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode') + ')'

	set @StrWhereO = @StrWhereO + @StrWhere
	set @StrWhereS = @StrWhereS + @StrWhere
	set @StrWhereP = @StrWhereP + @StrWhere

	set @StrWhere = ''

	-- Acnt Filter 
	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	set @StrWhereO = @StrWhereO + @StrWhere
	set @StrWhereS = @StrWhereS + @StrWhere

	-- Acnt Filter 
	If (@SelectedAcnt1 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.CreditCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.CreditCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.CreditCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.CreditCode')

	If (@SelectedStore > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 
	If (@SelectedStore > 0)
		SET @StrWhereO = @StrWhereO + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 

	If (@SaleTypeID Is Not Null)
		Set @StrWhereS = @StrWhereS + ' AND (H.SaleTypeID=''' + @SaleTypeID + ''')'

	If (@DocStep > 0)
		Set @StrWhereO = @StrWhereO + ' AND (H.DocStep=' + LTrim(Str(@DocStep)) + ')'

	---------------------------------------------------------
	-- SELECT Clause ----------------------------------------
	create table #tbl_Sale_SaleAndPayments2_Dates
	(
		DocDate char(10) collate arabic_cs_as not null 
	);
	
	create table #tbl_Sale_SaleAndPayments2_O
	(
		DocDate char(10) collate arabic_cs_as not null,
		ACount float,
		Amount float
	);

	create table #tbl_Sale_SaleAndPayments2_S
	(
		DocDate char(10) collate arabic_cs_as not null,
		ACount float,
		Amount float
	);

	create table #tbl_Sale_SaleAndPayments2_P
	(
		DocDate char(10) collate arabic_cs_as not null,
		ACount float,
		Amount float
	);

	SET @StrSelect = '
	insert	into #tbl_Sale_SaleAndPayments2_O
	select X.DocDate, Count(*), SUM(X.Price)
	from 
	(
		select	H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.DocDate,
				(
					select sum(D.GoodsQuantity*D.GoodsPrice)
					from sal.tblSaleOrderDtl D
					where (H.ProcessID=D.ProcessID) and (H.ProcessNo=D.ProcessNo) and (H.FiscalYear=D.FiscalYear) and (H.SerialNo=D.SerialNo)
				) Price
		from	sal.tblSaleOrderHdr H
		where ' + @StrWhereO + '
	) X
	Group by X.DocDate '

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	SET @StrSelect = '
	insert	into #tbl_Sale_SaleAndPayments2_S
	select X.DocDate, Count(*), SUM(X.Price)
	from 
	(
		select	H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.DocDate,
				(
					select sum(D.GoodsQuantity*D.GoodsPrice)
					from inv.tblStorageDocsDtl D
					where (H.ProcessID=D.ProcessID) and (H.ProcessNo=D.ProcessNo) and (H.FiscalYear=D.FiscalYear) and (H.SerialNo=D.SerialNo)
				) + H.SidePriceSum Price
		from	inv.vwStorageDocsHdr H
		where ' + @StrWhereS + '
	) X
	Group by X.DocDate '

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect = '
	insert	into #tbl_Sale_SaleAndPayments2_P
	select	X.DocDate, count(*), sum(X.Amount)
	from	
	(
		select ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate, Sum(Amount) Amount
		from trs.tblPayDtl H
		where ' + @StrWhereP + '
		group by ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate
	) X
	Group By X.DocDate '

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect = '
	insert	into #tbl_Sale_SaleAndPayments2_Dates(DocDate)
	select	H.DocDate
	from	sal.tblSaleOrderHdr H
	where ' + @StrWhereO + '
	union 
	select	H.DocDate
	from	inv.tblStorageDocsHdr H
	where ' + @StrWhereS + '
	union
	select	H.DocDate
	from	trs.tblPayDtl H
	where ' + @StrWhereP

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
	
	select D.DocDate, 
			ISNULL(O.ACount, 0) Count_O,
			ISNULL(S.ACount, 0) Count_S,
			ISNULL(P.ACount, 0) Count_P,
			ISNULL(O.Amount, 0) Amount_O,
			ISNULL(S.Amount, 0) Amount_S,
			ISNULL(P.Amount, 0) Amount_P
	from  #tbl_Sale_SaleAndPayments2_Dates D
		left join #tbl_Sale_SaleAndPayments2_O O on O.DocDate=D.DocDate
		left join #tbl_Sale_SaleAndPayments2_S S on S.DocDate=D.DocDate
		left join #tbl_Sale_SaleAndPayments2_P P on P.DocDate=D.DocDate
	order by D.DocDate
End
GO
