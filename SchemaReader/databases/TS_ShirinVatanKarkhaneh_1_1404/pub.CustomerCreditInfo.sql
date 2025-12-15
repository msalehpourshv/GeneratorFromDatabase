USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO


-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1393/11/12
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   :
-- =================================================================
CREATE PROCEDURE [pub].[CustomerCreditInfo]
	@AcntCode	varchar(20),
	@AcntCodeType	 int
	-- if @AcntCodeType=1  @AcntCode	is full '11111 11111  1111  111'
	--  if @AcntCodeType=2  @AcntCode	is single     '11111'
WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)
DECLARE 
@AcntCode1	varchar(20),
@AcntCode2	varchar(20),
@AcntCode3	varchar(20),
@AcntCode4	varchar(20)
	
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;
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
		AcntCode				varchar(20) collate arabic_cs_as,
		RemainFr				float,
		Purchase				float,
		CheqPaid				float,
		CheqRcpt				float,
		CheqCurr				float,
		CheqRetr				float,
		CashBill				float,
		SalePric				float,
		SaleRetr				float,
		SaleRetP				float,
		SaleDisc				float,
		SaleInvc				float,
		IvcAvgFn				char(10) null,
		IvcAvgRe				char(10) null,
		RecAvgFn				char(10) null,
		RemainTo				float,
		MaxDebitRemain			float,
		MaxReceivableRemain		float,
		ComplementCredit		float,
		AccountRemain			float,
		ManagerView         	varchar(500) ,
		VisitorView         	varchar(500) ,		
		MaxReturnCheque			bigint,
		MaxReturnChequeDays		int,
		MaxDaysAfterExpiration  int 
	);

	create table #tblAcnt1
	(
		AcntCode	varchar(20) collate arabic_cs_as
	);
	------------------------------------------------------------------------
	-- WHERE SECTION -------------------------------------------------------
DECLARE	@Layer1	int;
DECLARE	@Layer2	int;
DECLARE	@Layer3	int;
DECLARE	@Layer4	int;

SELECT    @Layer1= Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
FROM         pub.tblCodeLayer
WHERE     (TableName = N'acc.tblAcnt') and PartNumber=1

SELECT    @Layer2= Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
FROM         pub.tblCodeLayer
WHERE     (TableName = N'acc.tblAcnt') and PartNumber=2

SELECT    @Layer3= Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
FROM         pub.tblCodeLayer
WHERE     (TableName = N'acc.tblAcnt') and PartNumber=3

SELECT    @Layer4= Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
FROM         pub.tblCodeLayer
WHERE     (TableName = N'acc.tblAcnt') and PartNumber=4

if @AcntCodeType=1
begin
set  @AcntCode1 = SUBSTRING( @AcntCode ,1,@Layer1)
set  @AcntCode2 = SUBSTRING( @AcntCode ,@Layer1+2,@Layer2)
set  @AcntCode3 = SUBSTRING( @AcntCode ,@Layer1+@Layer2+4,@Layer2)
set  @AcntCode4 = SUBSTRING( @AcntCode ,@Layer1+@Layer2+@Layer3+6,@Layer4)
	end 
	else
	begin

set  @AcntCode2 = @AcntCode 
	end

if (@AcntCode1 Is Null)		set @AcntCode1 = '';
	if (@AcntCode2 Is Null)		set @AcntCode2 = '';
	if (@AcntCode3 Is Null)		set @AcntCode3 = '';
	if (@AcntCode4 Is Null)		set @AcntCode4 = '';

	-- enlist acnt codes -------------
	set @StrWhere = '(AcntCode <> '''')';

	if (@AcntCode1 <> '')
		set @StrWhere = @StrWhere + ' AND substring (D.AcntCode,1, ' +cast(@Layer1 as varchar(2)) + ')='''+ @AcntCode1 +''''
	if (@AcntCode2 <> '')
		set @StrWhere = @StrWhere + ' AND substring (D.AcntCode,'+cast(@Layer1+2 as varchar(2))+', '+ cast(@Layer2 as varchar(2)) + ')='''+ @AcntCode2 +''''
	if (@AcntCode3 <> '')
		set @StrWhere = @StrWhere + ' AND substring (D.AcntCode,'+cast(@Layer2+2 as varchar(2))+', '+ cast(@Layer3 as varchar(2)) + ') ='''+ @AcntCode3 +''''
	if (@AcntCode4 <> '')
		set @StrWhere = @StrWhere + ' AND substring (D.AcntCode,'+cast(@Layer3+2 as varchar(2))+', '+ cast(@Layer4 as varchar(2)) + ') ='''+ @AcntCode4 +''''

	
	--select  @AcntCode1,@AcntCode2,@AcntCode3,@AcntCode4
	
	set @StrSelect = 
		' INSERT INTO #tblAcnt1 ' +
		' SELECT DISTINCT AcntCode ' + 
		' FROM acc.tblVoucherDtl D ' + 
		' WHERE ' + @StrWhere
	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	-----------------------------------
	Insert Into #tblResult1
	Select AcntCode, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', 0, 0, 0, 0, 0, '', '', 0, 0, 0
	From #tblAcnt1

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
	update #tblResult1
	set CheqRcpt = 
	(
		select IsNull(Sum(Amount), 0)
		from trs.tblPayDtl D
		where   (D.ProcessID in (12,22))
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

	update #tblResult1
	set CheqRcpt = CheqRcpt + [trs].[funReceivableDocs_PaidReceipt_Sum](R.AcntCode, 1, @Today)
	from #tblResult1 R

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

	-- Cash Bill
	update #tblResult1
	set CashBill = 0

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
	
	------------------------------------
	update #tblResult1
	set MaxDaysAfterExpiration = 
	(
		select  isnull(MaxDaysAfterExpiration,0)
		from acc.tblAcnt AC
		where PartNumber = @AcntPartNumber AND AC.AcntCode = RTRIM(SUBSTRING(#tblResult1.AcntCode,@StartLayerIndex ,@LayerLen))
	)
	update #tblResult1
	set MaxReturnCheque = 
	(
		select  isnull(MaxReturnCheque,0)
		from acc.tblAcnt AC
		where PartNumber = @AcntPartNumber AND AC.AcntCode = RTRIM(SUBSTRING(#tblResult1.AcntCode,@StartLayerIndex ,@LayerLen))
	)
 	update #tblResult1
	set MaxReturnChequeDays = 
	(
		select  isnull(MaxReturnChequeDays,0)
		from acc.tblAcnt AC
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
	select * 	from #tblResult1
	-------------------------------------------------
END
GO
