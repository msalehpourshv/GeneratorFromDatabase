USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/05/03
-- Viewed By	 : 
-- Last Modified : 1389/12/22
-- Last Modified : TakroSystem\Zia
-- Description	 : <Pay Orders>
-- ----------------------------------------------
-- گزارش لیست برگه های دستور پرداخت
-- ==============================================
CREATE PROCEDURE [trs].[RptPayOrderDocs]
	@ProcessID		Int = 41,
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DebitCode1		Int = 0, -- بدهکار
	@DebitCode2		Int = 0,
	@DebitCode3		Int = 0,
	@DebitCode4		Int = 0,
	@CreditCode1	Int = 0, -- بستانکار
	@CreditCode2	Int = 0,
	@CreditCode3	Int = 0,
	@CreditCode4	Int = 0,
	@DocDateFr		Char(10) = Null, -- از تاریخ پرداخت
	@DocDateTo		Char(10) = Null, -- تا تاریخ پرداخت
	@UsanceDateFr	Char(10) = Null, -- از تاریخ سررسید
	@UsanceDateTo	Char(10) = Null, -- تا تاریخ سررسید
	@AmountFr		BigInt = Null, -- مبلغ پرداختی
	@AmountTo		BigInt = Null,
	@SortFields		NVarChar(100) = Null,
	@RepOptions		VarChar(10) = '11',
	@RepInfo		NVarChar(100) = Null
WITH ENCRYPTION
As
DECLARE @StrSelect	NVarChar(4000);

DECLARE @LangID		Char(1)
DECLARE @SessionNo	VarChar(10)
DECLARE @ReportID	VarChar(10)

DECLARE @PaidY		VarChar(10);
DECLARE @PaidN		VarChar(10);

BEGIN  

	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	If (@SortFields Is Null)	SET @SortFields = 'DocDate'
	IF (@RepOptions Is Null)	SET @RepOptions = '11';

	If (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	IF (@DebitCode1 Is Null)	SET @DebitCode1 = 0;
	IF (@DebitCode2 Is Null)	SET @DebitCode2 = 0;
	IF (@DebitCode3 Is Null)	SET @DebitCode3 = 0;
	IF (@DebitCode4 Is Null)	SET @DebitCode4 = 0;

	IF (@CreditCode1 Is Null)	SET @CreditCode1 = 0;
	IF (@CreditCode2 Is Null)	SET @CreditCode2 = 0;
	IF (@CreditCode3 Is Null)	SET @CreditCode3 = 0;
	IF (@CreditCode4 Is Null)	SET @CreditCode4 = 0;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @PaidY	= Substring(@RepOptions, 1, 1);
	SET @PaidN	= Substring(@RepOptions, 2, 1);
	-----------------------------------------------------------------

	SET @StrSelect = '
	SELECT	D.*, H.DebitCode AS DebitCodeHdr, H.CreditCode AS CreditCodeHdr,
			H.CollectorAcntCode, H.VchNo, H.DescHdr, 
			pub.GetUserName(H.SessionNo1) AS UserName, 
			pub.GetCodeName(H.DebitCode, ' + @LangID + ') AS DebitNameHdr,
			pub.GetCodeName(H.CreditCode, ' + @LangID + ') AS CreditNameHdr,
			case when (D.ChequeDate = '''') then 0 else pub.funFarsiDateDiff(''Day'', H.DocDate, D.ChequeDate) end AS Duration
	FROM	trs.tblPayDtl AS D
				INNER JOIN trs.tblPayHdr AS H ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
	WHERE	(D.ProcessID = ' + LTrim(Str(@ProcessID)) + ') AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	If	(@DebitCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'H.DebitCode') 
	If	(@DebitCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'H.DebitCode') 
	If	(@DebitCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'H.DebitCode') 
	If	(@DebitCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'H.DebitCode') 

	If	(@CreditCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'D.CreditCode') 
	If	(@CreditCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'D.CreditCode') 
	If	(@CreditCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'D.CreditCode') 
	If	(@CreditCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'D.CreditCode') 

	If	(@DocDateFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.DocDate >= ''' + @DocDateFr + ''''
	If	(@DocDateTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.DocDate <= ''' + @DocDateTo + ''''

	If	(@UsanceDateFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.ChequeDate >= ''' + @UsanceDateFr + ''''
	If	(@UsanceDateTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.ChequeDate <= ''' + @UsanceDateTo + ''''

	If (@FiscalYearFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If	(@AmountFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (D.Amount >= ' + LTrim(Str(@AmountFr)) + ')'
	If	(@AmountTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (D.Amount <= ' + LTrim(Str(@AmountTo)) + ')'

	if (@PaidY = 1) or (@PaidN = 1) 
	begin
		if (@PaidY = 0)
			set @StrSelect = @StrSelect + ' and ((select count(*) from trs.tblPayHdr where (BaseProcessID = H.ProcessID) and (BaseFiscalYear = H.FiscalYear) and (BaseSerialNo = H.SerialNo)) = 0)'
		if (@PaidN = 0)
			set @StrSelect = @StrSelect + ' and ((select count(*) from trs.tblPayHdr where (BaseProcessID = H.ProcessID) and (BaseFiscalYear = H.FiscalYear) and (BaseSerialNo = H.SerialNo)) > 0)'
	end
	
	SET @StrSelect = @StrSelect + ' 
		ORDER BY ' + @SortFields

	-----------------------------------------------------
	Print @StrSelect
	Exec sp_executesql @StrSelect;
	
END
GO
