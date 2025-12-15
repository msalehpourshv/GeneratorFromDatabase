USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/05/25
-- Viewed By	 : 
-- Last Modified : 1393/04/11
-- Last Modifier : TakroSystem\Hamid
-- Description   :
-- =================================================================
Create PROCEDURE [pub].[RptCustomerCreditInfo]
	@AcntCode1	int = 0,
	@AcntCode2	int = 0,
	@AcntCode3	int = 0,
	@AcntCode4	int = 0,
	@RepOptions	NVarChar(200) = '111',
	@RepInfo	NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;
DECLARE	@AcntCode	varchar(20);
DECLARE	@RemainTo	float;
DECLARE	@RemainVar	float;
DECLARE	@ord		int;
DECLARE	@LayerLen	int;
DECLARE	@StartLayerIndex	int;
DECLARE	@AcntPartNumber	int;
DECLARE	@prc		float;
DECLARE	@dat		char(10);

DECLARE	@Today	char(10);

BEGIN
	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	if (@RepInfo	Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions	Is Null)	set @RepOptions = '1'

	if (@AcntCode1 Is Null)		set @AcntCode1 = 0;
	if (@AcntCode2 Is Null)		set @AcntCode2 = 0;
	if (@AcntCode3 Is Null)		set @AcntCode3 = 0;
	if (@AcntCode4 Is Null)		set @AcntCode4 = 0;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SELECT @Today	= left(pub.funFarsiDate(GetDate()), 10);
	
	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'
	
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'
	
	SELECT @AcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	create table #tblResult1
	(
		AcntCode			varchar(20) collate arabic_cs_as,
		RemainFr			float,
		Purchase			float,
		CheqPaid			float,
		CheqRcpt			float,
		CheqCurr			float,
		CheqRetr			float,
		CashBill			float,
		SalePric			float,
		SaleRetr			float,
		SaleRetP			float,
		SaleDisc			float,
		SaleInvc			float,
		IvcAvgFn			char(10) null,
		IvcAvgRe			char(10) null,
		RecAvgFn			char(10) null,
		RemainTo			float,
		MaxDebitRemain		float,
		MaxReceivableRemain	float,
		ComplementCredit	float,
		AccountRemain		float,
		ManagerView         varchar(500) ,
		VisitorView         varchar(500) 		

	);

	create table #tblAcnt1
	(
		AcntCode	varchar(20) collate arabic_cs_as
	);
	------------------------------------------------------------------------
	-- WHERE SECTION -------------------------------------------------------

	-- enlist acnt codes -------------
	set @StrWhere = '(AcntCode <> '''')';

	if (@AcntCode1 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode1, 'D.AcntCode')
	if (@AcntCode2 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode2, 'D.AcntCode')
	if (@AcntCode3 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode3, 'D.AcntCode')
	if (@AcntCode4 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode4, 'D.AcntCode')

	set @StrSelect = 
		' INSERT INTO #tblAcnt1 ' +
		' SELECT DISTINCT AcntCode ' + 
		' FROM acc.tblVoucherDtl D ' + 
		' WHERE ' + @StrWhere
	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	-----------------------------------

	insert into #tblResult1
	select AcntCode,0,0,0,0,0,0,0,0,0,0,0,0,'','','',0,0,0,0,0,'',''
	from #tblAcnt1

	-- Remain From
	update #tblResult1
	set RemainFr =
	(
		select IsNull(Sum(D.Debit-D.Credit), 0)
		from acc.tblVoucherDtl D
		where (D.AcntCode = #tblResult1.AcntCode) and (D.VchKind = 2) -- prim docs
	)

	select ProcessID, AcntCode, sum(SidePriceSum + GoodsPrice) PayableAmount
	into #tbl_X_Group
	from
	(
		select H.ProcessID, H.AcntCode, H.SidePriceSum,
			IsNull((
				select Sum(D.GoodsPrice*D.GoodsQuantity)
				from inv.tblStorageDocsDtl D 
				where H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
			),0) GoodsPrice
		from inv.vwStorageDocsHdr H 
		where (H.ProcessID in (55, 90)) and (AcntCode <> '')
	) M
	group by ProcessID, AcntCode

	-- Buy
	update #tblResult1
	set Purchase = 
		isnull((
			select PayableAmount
			from #tbl_X_Group G
			where (G.ProcessID = 55) and (G.AcntCode = #tblResult1.AcntCode)
		),0)
	
	-- Cheques Paid
	update #tblResult1
	set CheqPaid = 
	(
		select IsNull(Sum(Amount), 0)
		from trs.tblPayDtl D
		where   (D.EventNo=1)
			and (D.ProcessID in (1,10))
			and (D.PayTypeID in (6,26))
			and (D.CreditCode = #tblResult1.AcntCode)
	)

	-- Cheques Receipt
	--update #tblResult1
	--set CheqRcpt = 
	--(
	--	select IsNull(Sum(Amount), 0)
	--	from trs.tblPayDtl D
	--	where   (D.ProcessID in (12,22))
	--		and (D.PayTypeID in (6,26))
	--		and	
	--		(
	--			SELECT  top 1 CreditCode
	--			FROM	trs.tblPayDtl X
	--			WHERE	(X.EventNo=1)
	--				AND	(X.ProcessID IN (1,10))
	--				AND (X.PayTypeID=D.PayTypeID)
	--				AND (X.VolumeFiscalYear=D.VolumeFiscalYear)
	--				AND (X.VolumeRowNo=D.VolumeRowNo)
	--		) = #tblResult1.AcntCode
	--)

	--update #tblResult1
	--set CheqRcpt = CheqRcpt + [trs].[funReceivableDocs_PaidReceipt_Sum](R.AcntCode, 1, @Today)
	--from #tblResult1 R

	-- Cheques Returned
	update #tblResult1
	set CheqRetr = 
	(
		select IsNull(Sum(Amount), 0)
		from trs.tblPayDtl D
		where   (D.ProcessID in (13,18,24))
			and (D.PayTypeID in (6,26))
			and	
			(
				SELECT  top 1 CreditCode
				FROM	trs.tblPayDtl X
				WHERE	(X.EventNo=1)
					AND	(X.ProcessID IN (1,10))
					AND (X.PayTypeID=D.PayTypeID)
					AND (X.VolumeFiscalYear=D.VolumeFiscalYear)
					AND (X.VolumeRowNo=D.VolumeRowNo)
			) = #tblResult1.AcntCode
	)

	
	-- Cheques Not Receipt
	update #tblResult1
	set CheqCurr = [trs].[funReceivableDocs_UnReceipt_Sum](R.AcntCode, 1, @Today)
	from #tblResult1 R

	update #tblResult1 set CheqRcpt=CheqPaid-CheqCurr
	-- Cash Bill
	update #tblResult1
	set CashBill = 
	(
		select IsNull(Sum(Amount), 0)
		from trs.tblPayDtl a
		inner join #tblResult1 b
		on a.CreditCode=b.AcntCode 
		where   (ProcessID in (1))
			and (PayTypeID in (1,2,3,4,35))
	)


	-- sale
	update #tblResult1
	set SalePric = 
	(
		select IsNull(Sum(D.GoodsPrice*D.GoodsQuantity),0)
		from inv.tblStorageDocsDtl D 
		where (ProcessID = 90) and (D.AcntCode = #tblResult1.AcntCode)
	)

	-- Sale Ret
	update #tblResult1
	set SaleRetr =
	(
		select IsNull(Sum(D.GoodsPrice*D.GoodsQuantity),0)
		from inv.tblStorageDocsDtl D 
		where (ProcessID = 100) and (D.AcntCode = #tblResult1.AcntCode)
	)

	-- sale invoice 
	update #tblResult1
	set SaleInvc = 
		isnull((
			select PayableAmount
			from #tbl_X_Group G
			where (G.ProcessID = 90) and (G.AcntCode = #tblResult1.AcntCode)
		),0)

	-- Sale Ret Percent
	update #tblResult1
	set SaleRetP = (SaleRetr  * 100) / SaleInvc
	where (SaleInvc > 0)

	-- Sale Discount
	update #tblResult1
	set SaleDisc = 
	(
		select IsNull(Sum(Discount+Discount2+Discount3+TotalLineDiscount), 0)
		from inv.tblStorageDocsHdr
		where (ProcessID = 90) and (AcntCode = #tblResult1.AcntCode)
	)

	-- Invoices Average
	update #tblResult1
	set IvcAvgFn =
 		pub.funFarsiDateAddDays('Day', @Today,
		(
			select IsNull(Sum((T.PriceDtl+T.SidePriceSum) * pub.funFarsiDateDiff('Day', @Today, T.DocDate) ), 0)
			from 
			(
				select H.DocDate,H.SidePriceSum,H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,
						(
							select sum(D.GoodsQuantity*D.GoodsPrice) 
							from inv.tblStorageDocsDtl D 
							where D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo
						) PriceDtl
				from inv.vwStorageDocsHdr H
				where (H.ProcessID=90) and (H.AcntCode=#tblResult1.AcntCode)
			) T
		) / SaleInvc
		)
	where (SaleInvc > 0)

	-- Invoices Average Re
	update #tblResult1
	set IvcAvgRe = ''

	-- Cheques Average
	update #tblResult1
	set RecAvgFn = 
		pub.funFarsiDateAddDays('Day', @Today,
		(
			select IsNull(Sum( Amount * pub.funFarsiDateDiff('Day', @Today, ChequeDate) ), 0)
			from trs.tblPayDtl D
			where ProcessID in (1,10) and PayTypeID in (6,26) and #tblResult1.AcntCode =
			(
				SELECT Top 1 CreditCode
				FROM	trs.tblPayDtl
				WHERE	(ProcessID IN (1,10)) AND 
						(PayTypeID IN (6,26)) AND 
						(VolumeFiscalYear = D.VolumeFiscalYear) AND 
						(VolumeRowNo = D.VolumeRowNo)
				ORDER By EventNo ASC
			)
		) / CheqPaid )
	where (CheqPaid > 0)
	
	-- Remain To
	update #tblResult1
	set RemainTo = 
	(
		select IsNull(Sum(Debit-Credit), 0)
		from acc.tblVoucherDtl D
		where AcntCode = #tblResult1.AcntCode and (D.VchKind <> 3) and (D.VchKind <> 4) -- finish docs
	)
	
	-- MaxDebitRemain
	update #tblResult1
	set MaxDebitRemain = 
	(
		select IsNull(MaxDebitRemain, 0)
		from acc.tblAcnt AC
		where PartNumber = @AcntPartNumber AND AC.AcntCode = RTRIM(SUBSTRING(#tblResult1.AcntCode,@StartLayerIndex ,@LayerLen))
	)
	
	-- MaxReceivableRemain
	update #tblResult1
	set MaxReceivableRemain = 
	(
		select IsNull(MaxReceivableRemain, 0)
		from acc.tblAcnt AC
		where PartNumber = @AcntPartNumber AND AC.AcntCode = RTRIM(SUBSTRING(#tblResult1.AcntCode,@StartLayerIndex ,@LayerLen))
	)
	
	-- ComplementCredit
	update #tblResult1
	set ComplementCredit = 
	(
		select IsNull(ComplementCredit, 0)
		from acc.tblAcnt AC
		where PartNumber = @AcntPartNumber AND AC.AcntCode = RTRIM(SUBSTRING(#tblResult1.AcntCode,@StartLayerIndex ,@LayerLen))
	)
	
	-- AccountRemain
	update #tblResult1
	set AccountRemain = 
	(
		SELECT	(IsNull(Sum(Debit), 0) - IsNull(Sum(Credit), 0)) As AccountRemain
		FROM	acc.tblVoucherDtl D
		WHERE D.AcntCode = #tblResult1.AcntCode and (D.VchKind <> 3) and (D.VchKind <> 4)
	)
	

	-- ManagerView
	update #tblResult1
	set ManagerView = 
	(
		select IsNull(ManagerView, '')
		from acc.tblAcntDtl AC
		where PartNumber = @AcntPartNumber AND AC.AcntCode = RTRIM(SUBSTRING(#tblResult1.AcntCode,@StartLayerIndex ,@LayerLen))
	)
	-- VisitorView
	update #tblResult1
	set VisitorView = 
	(
		select IsNull(VisitorView, '')
		from acc.tblAcntDtl AC
		where PartNumber = @AcntPartNumber AND AC.AcntCode = RTRIM(SUBSTRING(#tblResult1.AcntCode,@StartLayerIndex ,@LayerLen))
	)
	
	-------------------------------------------------
	declare @sumPrc float
	declare @sumDay bigint
	
	set @sumDay = 0
	set @sumPrc = 0
	
	declare csr_rem cursor for
		select AcntCode, RemainTo
		from #tblResult1
		where (RemainTo > 0)
		
	open csr_rem 
	fetch next from csr_rem into @AcntCode, @RemainTo
	
	while (@@FETCH_STATUS = 0)
	begin
		declare csr_ivc cursor for
			select  ROW_NUMBER() over (order by H.DocDate, H.SerialNo) row,
					H.DocDate, H.SidePriceSum+(
						select sum(D.GoodsQuantity*D.GoodsPrice) 
						from inv.tblStorageDocsDtl D 
						where D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo
					) PriceDtl
			from inv.vwStorageDocsHdr H
			where (H.ProcessID=90) and (H.AcntCode=@AcntCode)
			order by 1 desc
		
		open csr_ivc 
		fetch next from csr_ivc into @ord, @dat, @prc
		
		while (@@FETCH_STATUS = 0)
		begin
			if (@RemainTo <= 0) break;
			
			set @sumPrc = @sumPrc + @prc
			set @sumDay = @sumDay + @prc*(pub.funFarsiDateDiff('Day', @Today, @dat))

			set @RemainTo = @RemainTo - @prc
			fetch next from csr_ivc into @ord, @dat, @prc
		end;

		close csr_ivc  
		deallocate csr_ivc 

		if (@sumPrc > 0)
		begin
			update #tblResult1
			set IvcAvgRe = pub.funFarsiDateAddDays('Day', @Today, round(@sumDay/@sumPrc, 0))
			where AcntCode = @AcntCode
		end
				
		fetch next from csr_rem into @AcntCode, @RemainTo
	end

	close csr_rem 
	deallocate csr_rem 
	 
	-- SELECT SECTION -------------------------------
	select *
	from #tblResult1
	-------------------------------------------------
END
GO
