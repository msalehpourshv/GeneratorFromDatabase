USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/05/03
-- Viewed By	 : 
-- Last Modified : 1392/05/02
-- Last Modified : TakroSystem\Zia
-- Description	 : <Pay Orders>
-- ----------------------------------------------
-- گزارش لیست برگه های دستور پرداخت
-- ==============================================
Create PROCEDURE [trs].[RptPayOrderDocs_Sum]
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
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhereG	NVarChar(max);

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
	set @StrWhere = '(D.ProcessID=' + LTrim(Str(@ProcessID)) + ') AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'
	SET @StrWhereG = ''
	If	(@DebitCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'H.DebitCode') 
	If	(@DebitCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'H.DebitCode') 
	If	(@DebitCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'H.DebitCode') 
	If	(@DebitCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'H.DebitCode') 

	If	(@CreditCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'H.CreditCode') 
	If	(@CreditCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'H.CreditCode') 
	If	(@CreditCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'H.CreditCode') 
	If	(@CreditCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'H.CreditCode') 

	If	(@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + @DocDateFr + ''''
	If	(@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DocDateTo + ''''

	--If	(@UsanceDateFr Is Not Null)
	--	SET @StrWhere = @StrWhere + ' AND D.ChequeDate >= ''' + @UsanceDateFr + ''''
	--If	(@UsanceDateTo Is Not Null)
	--	SET @StrWhere = @StrWhere + ' AND D.ChequeDate <= ''' + @UsanceDateTo + ''''

	If (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If	(@AmountFr Is Not Null)
		SET @StrWhereG = @StrWhereG + ' AND (AmountSum1+AmountSum2+AmountSum3 >= ' + LTrim(Str(@AmountFr,20)) + ' )'
	If	(@AmountTo Is Not Null)
		SET @StrWhereG = @StrWhereG + ' AND (AmountSum1+AmountSum2+AmountSum3 <= ' + LTrim(Str(@AmountTo,20)) + ')'

	if (@PaidY = 1) or (@PaidN = 1) 
	begin
		if (@PaidY = 0)
			set @StrWhere = @StrWhere + ' and ((select count(*) from trs.tblPayHdr where (BaseProcessID = H.ProcessID) and (BaseProcessNo = H.ProcessNo) and (BaseFiscalYear = H.FiscalYear) and (BaseSerialNo = H.SerialNo)) = 0)'
		if (@PaidN = 0)
			set @StrWhere = @StrWhere + ' and ((select count(*) from trs.tblPayHdr where (BaseProcessID = H.ProcessID) and (BaseProcessNo = H.ProcessNo) and (BaseFiscalYear = H.FiscalYear) and (BaseSerialNo = H.SerialNo)) > 0)'
	end

	SET @StrSelect = '
	SELECT * 
	FROM (
		SELECT  H.FiscalYear, H.SerialNo, H.DocDate, H.DebitCode,H.DescHdr, 
				pub.GetCodeName(H.DebitCode,  ' + @LangID + ') AS DebitNameHdr,
				sum(case when D.PayTypeID in (1,5) then D.Amount else 0 end) AmountSum1,
				sum(case when D.PayTypeID in (6,16,26) then D.Amount else 0 end) AmountSum2,
				sum(case when D.PayTypeID in (8,18,28) then D.Amount else 0 end) AmountSum3
		FROM	trs.tblPayDtl D
					INNER JOIN trs.tblPayHdr H ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
		WHERE	' + @StrWhere + '
		GROUP BY H.FiscalYear, H.SerialNo, H.DocDate, H.DebitCode,H.DescHdr 
		) A
	WHERE 1=1 ' + @StrWhereG

	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields

	-----------------------------------------------------
	Print @StrSelect
	Exec sp_executesql @StrSelect;

END
GO
