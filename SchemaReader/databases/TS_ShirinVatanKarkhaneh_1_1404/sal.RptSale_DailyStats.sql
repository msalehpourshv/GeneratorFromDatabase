USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1388/06/04
-- Viewed By	 : 
-- Last Modified : 1389/12/15
-- Last Modifier : TakroSystem\Zia
-- Description	 : آمار فروش ویزیتورها
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_DailyStats]
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SelectedGoods		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedVisitor1	Int = 0, 
	@SelectedVisitor2	Int = 0, 
	@SelectedVisitor3	Int = 0, 
	@SelectedVisitor4	Int = 0, 
	@RepOptions			VarChar(10) = '110', -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrWhereSM		NVarChar(2000);
DECLARE @StrWhereSH		NVarChar(2000);
DECLARE @StrWhereSR		NVarChar(2000);
DECLARE @StrWhereP		NVarChar(2000);
DECLARE @StrWhereR		NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '110001';
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;
	IF (@SelectedVisitor1 Is Null)	SET @SelectedVisitor1 = 0;
	IF (@SelectedVisitor2 Is Null)	SET @SelectedVisitor2 = 0;
	IF (@SelectedVisitor3 Is Null)	SET @SelectedVisitor3 = 0;
	IF (@SelectedVisitor4 Is Null)	SET @SelectedVisitor4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------

	-- Where Clause -----------------------------------------
	Set @StrWhere = ''
	Set @StrWhereP = ''
	Set @StrWhereR = ''
	Set @StrWhereSH = ''
	Set @StrWhereSM = ''
	Set @StrWhereSR = ''

	IF (@DocDateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		Set @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode') + ')'
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode') + ')'
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode') + ')'
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode') + ')'
		
	-- sale 
	set @StrWhereSM = @StrWhere
	If (@SelectedAcnt1 > 0)
		SET @StrWhereSM = @StrWhereSM + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereSM = @StrWhereSM + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereSM = @StrWhereSM + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereSM = @StrWhereSM + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
		
	SET @StrWhereSH = @StrWhereSM 

	If (@SelectedGoods > 0)
		SET @StrWhereSM = @StrWhereSM + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	If (@SelectedStore > 0)
		SET @StrWhereSM = @StrWhereSM + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	set @StrWhereSR = @StrWhereSM
	
	SET @StrWhereSH = '(D.ProcessID = 90)' + @StrWhereSH
	set @StrWhereSM = '(D.ProcessID = 90)' + @StrWhereSM
	set @StrWhereSR = '(D.ProcessID = 100)' + @StrWhereSR
	
	-- rec
	set @StrWhereR = '(D.ProcessID = 1)' + @StrWhere

	If (@SelectedAcnt1 > 0)
		SET @StrWhereR = @StrWhereR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.CreditCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereR = @StrWhereR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.CreditCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereR = @StrWhereR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.CreditCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereR = @StrWhereR + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.CreditCode')
	-- pay
	set @StrWhereP = '(D.ProcessID = 2)' + @StrWhere

	If (@SelectedAcnt1 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.DebitCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.DebitCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.DebitCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereP = @StrWhereP + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.DebitCode')

	---------------------------------------------------------
	
	create table #tblSale_DailyStats_Result
	(
		DocDate	char(10),
		SAL		float,
		RET		float,
		DSC		float,
		DSC2	float,
		REC		float,
		CHQ		float,
		PAY		float
	);
				
	-- SELECT Clause ----------------------------------------
	SET @StrSelect = '
	insert into	#tblSale_DailyStats_Result(DocDate, SAL, RET, DSC, DSC2, REC, CHQ, PAY)
	SELECT	D.DocDate, isnull(sum(D.GoodsPrice*D.GoodsQuantity), 0), 0, isnull(sum(D.DiscountDtl),0), 0, 0, 0, 0
	FROM	inv.tblStorageDocsDtl D 
	WHERE	' + @StrWhereSM + '
	GROUP BY D.DocDate'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect = '
	insert into #tblSale_DailyStats_Result(DocDate, SAL, RET, DSC, DSC2, REC, CHQ, PAY)
	SELECT	D.DocDate, 0, isnull(sum(D.GoodsPrice*D.GoodsQuantity), 0), 0, 0, 0, 0, 0
	FROM inv.tblStorageDocsDtl D 
	WHERE ' + @StrWhereSR + '
	GROUP BY D.DocDate'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	if (@SelectedGoods = 0)
	begin
		SET @StrSelect = '
		insert into #tblSale_DailyStats_Result(DocDate, SAL, RET, DSC, DSC2, REC, CHQ, PAY)
		SELECT	T.DocDate, 0, 0, isnull(sum(T.Discount+T.Discount2), 0), isnull(sum(T.DiscountX), 0), 0, 0, 0
		FROM 
		(
			select D.DocDate, D.Discount, D.Discount2+D.Discount3 Discount2, 
					isnull((
						select SUM(B.Price)
						from sal.tblDistributionsDtl D2
							inner join sal.tblAfterSaleBillDtl B on B.BaseProcessID=D2.BaseSaleProcessID and B.BaseProcessNo=D2.BaseSaleProcessNo and B.BaseFiscalYear=D2.BaseSaleFiscalYear and B.BaseSerialNo=D2.BaseSaleSerialNo
						where D2.ProcessID = D.BaseDistributionProcessID and D2.SerialNo = D.BaseDistributionSerialNo
					),0) DiscountX
			FROM inv.tblStorageDocsHdr D		
			WHERE ' + @StrWhereSH + '
		) T
		GROUP BY T.DocDate'

		Print @StrSelect;
		Exec sp_executesql @StrSelect;
	end
	
	SET @StrSelect = '
	insert into #tblSale_DailyStats_Result(DocDate, SAL, RET, DSC, DSC2, REC, CHQ, PAY)
	SELECT	D.DocDate, 0, 0, 0, 0, isnull(sum(D.Amount), 0) REC, 0, 0
	FROM	trs.tblPayDtl D 
	WHERE (PayTypeID=1) and ' + @StrWhereR + '
	GROUP BY D.DocDate'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	
	SET @StrSelect = '
	insert into #tblSale_DailyStats_Result(DocDate, SAL, RET, DSC, DSC2, REC, CHQ, PAY)
	SELECT	D.DocDate, 0, 0, 0, 0, 0, isnull(sum(D.Amount), 0) REC, 0
	FROM	trs.tblPayDtl D 
	WHERE (PayTypeID>1) and ' + @StrWhereR + '
	GROUP BY D.DocDate'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	SET @StrSelect = '
	insert into #tblSale_DailyStats_Result(DocDate, SAL, RET, DSC, DSC2, REC, CHQ, PAY)
	SELECT	D.DocDate, 0, 0, 0, 0, 0, 0, isnull(sum(D.Amount), 0) PAY
	FROM	trs.tblPayDtl D 
	WHERE ' + @StrWhereP + '
	GROUP BY D.DocDate'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
	select	DocDate, 
			isnull(sum(SAL), 0) SumAmountSAL,
			isnull(sum(RET), 0) SumAmountRET,
			isnull(sum(DSC), 0) SumAmountDSC,
			isnull(sum(DSC2), 0) SumAmountDSC2,
			isnull(sum(REC), 0) SumAmountREC,
			isnull(sum(CHQ), 0) SumAmountCHQ,
			isnull(sum(PAY), 0) SumAmountPAY
	from	#tblSale_DailyStats_Result
	group by DocDate
	order by DocDate
End
GO
