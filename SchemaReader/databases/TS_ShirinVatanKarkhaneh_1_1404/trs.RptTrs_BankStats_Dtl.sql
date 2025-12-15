USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1392/09/18
-- Viewed By	 : 
-- Last Modified : 1392/09/18
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Receivable Documents Report>
-- ==============================================
CREATE PROCEDURE [trs].[RptTrs_BankStats_Dtl]
	@ProcessNo		Int = 1,
	@SelectedBank	Int = 0,
	@SelectedDate	char(10) = null,
	@SortFields		NVarChar(100) = Null, -- لیست فیلدها برای مرتب سازی
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrSelect	NVarChar(max);

DECLARE @LangID		Char(1)
DECLARE @SessionNo	VarChar(10)
DECLARE @ReportID	VarChar(10)
BEGIN   
	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1
	If (@SortFields Is Null)	SET @SortFields = ''

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	-- WHERE Section -------------------------------------------------------------------------------------------

	if (@SelectedDate is null) set @SelectedDate = pub.funFarsiDate(GetDate())
	
	SELECT @StrWhere = '(D.ProcessNo = ' + LTRim(Str(@ProcessNo)) + ')'

	IF	(@SelectedBank > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedBank, 'D.DebitCode') 
		
	-----------------------------------------------------------------
	create table #tblBank_Stats_Banks
	(
		BankCode	varchar(20) collate arabic_cs_as not null,
		BankName	nvarchar(100) not null,
		AcntCode1	varchar(20) not null,
		RemainYD	float not null,
		RemainTD	float not null,
		RReceive	float not null,
		RReceipt	float not null,
		PPayPaid	float not null,
		PReceipt	float not null
	)
	
	insert into #tblBank_Stats_Banks
	exec [trs].[RptTrs_BankStats_Sum] @ProcessNo, @SelectedBank, @SelectedDate, @SortFields, @RepInfo
	
	select T.*, B.AcntCode1, B.BankName, B.PPayPaid, B.PReceipt, B.RemainTD, B.RemainYD, B.RReceipt, B.RReceive, DG.DocGroupName, BT.BankTypeName
	from
	(
		select DebitCode BankCode, 1 DocGroupCode, Amount, D.ChequeDate, D.ChequeNo, D.AccountNo, D.BankTypeID, D.BranchName
		from trs.tblPayDtl D
				inner join #tblBank_Stats_Banks B on B.BankCode = D.DebitCode
		where PayTypeID in (6,16,26) and ProcessID in (20,21)
			and (DebitCode=B.BankCode) 
			and (DocDate=@SelectedDate)
		----------------
		union all
		----------------
		select DebitCode BankCode, 2 DocGroupCode, Amount, D.ChequeDate, D.ChequeNo, D.AccountNo, D.BankTypeID, D.BranchName
		from trs.tblPayDtl D
				inner join #tblBank_Stats_Banks B on B.BankCode = D.DebitCode
		where PayTypeID in (6,16,26) and ProcessID in (22)
			and (DebitCode=B.BankCode) 
			and (DocDate=@SelectedDate)
		----------------
		union all
		----------------
		select DebitCode BankCode, 3 DocGroupCode, Amount, D.ChequeDate, D.ChequeNo, D.AccountNo, D.BankTypeID, D.BranchName
		from trs.tblPayDtl D
				inner join #tblBank_Stats_Banks B on B.BankCode = D.DebitCode
		where PayTypeID in (8,18,28) and ProcessID in (2,25)
			and (CreditCode=B.BankCode) 
			and (DocDate=@SelectedDate)
		----------------
		union all
		----------------
		select DebitCode BankCode, 4 DocGroupCode, Amount, D.ChequeDate, D.ChequeNo, D.AccountNo, D.BankTypeID, D.BranchName
		from trs.tblPayDtl D
				inner join #tblBank_Stats_Banks B on B.BankCode = D.DebitCode
		where PayTypeID in (8,18,28) and ProcessID in (27)
			and (DebitCode=B.BankCode) 
			and (DocDate=@SelectedDate)		
	) T inner join #tblBank_Stats_Banks B on B.BankCode = T.BankCode
		inner join 
		(
			select 1 DocGroupCode, 'دریافت اسناد دریافتنی' as DocGroupName
			union
			select 2, 'وصول اسناد دریافتنی'
			union
			select 3, 'پرداخت اسناد پرداختنی'
			union
			select 4, 'وصول اسناد پرداختنی'
		) DG on DG.DocGroupCode = T.DocGroupCode
		inner join trs.tblBankTypesDtl BT on BT.BankTypeID = T.BankTypeID
	order by BankName, DocGroupCode
			
	/* ---------------------------------------------------------------------------- */
End
GO
