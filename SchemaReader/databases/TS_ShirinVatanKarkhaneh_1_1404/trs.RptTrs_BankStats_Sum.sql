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
CREATE PROCEDURE [trs].[RptTrs_BankStats_Sum]
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
	
	SELECT @StrWhere = '(BankState=3)'

	IF	(@SelectedBank > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedBank, 'BH.BankCode') 
		
	-----------------------------------------------------------------
	set @StrSelect = '
	select BH.BankCode, BD.BankName, AcntCode1, 
			isnull((
				select SUM(Debit-Credit)
				from acc.tblVoucherDtl
				where (VchKind<>0) and (AcntCode=BH.AcntCode1) and (DocDate<''' + @SelectedDate + ''')
			),0) RemainOfYesterday,
			isnull((
				select SUM(Debit-Credit)
				from acc.tblVoucherDtl
				where (VchKind<>0) and (AcntCode=BH.AcntCode1) and (DocDate<=''' + @SelectedDate + ''')
			),0) RemainOfToday,
			isnull((
				select SUM(Amount)
				from trs.tblPayDtl
				where PayTypeID in (6,16,26) 
					and ProcessID in (20,21)
					and (DebitCode=BH.BankCode) 
					and (DocDate=''' + @SelectedDate + ''')
			),0) TodayRecReceive,
			isnull((
				select SUM(Amount)
				from trs.tblPayDtl
				where PayTypeID in (6,16,26) 
					and ProcessID in (22)
					and (DebitCode=BH.BankCode) 
					and (DocDate=''' + @SelectedDate + ''')
			),0) TodayRecReceipt,
			isnull((
				select SUM(Amount)
				from trs.tblPayDtl
				where PayTypeID in (8,18,28) 
					and ProcessID in (2,25)
					and (CreditCode=BH.BankCode) 
					and (DocDate=''' + @SelectedDate + ''')
			),0) TodayPayPaid,
			isnull((
				select SUM(Amount)
				from trs.tblPayDtl
				where PayTypeID in (8,18,28) 
					and ProcessID in (27)
					and (DebitCode=BH.BankCode) 
					and (DocDate=''' + @SelectedDate + ''')
			),0) TodayPayReceipt
	from trs.tblOurBanks BH
		inner join trs.tblOurBanksDtl BD on BD.BankCode=BH.BankCode
	where ' + @StrWhere + '
	order by BankName '

	/* ---------------------------------------------------------------------------- */

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
