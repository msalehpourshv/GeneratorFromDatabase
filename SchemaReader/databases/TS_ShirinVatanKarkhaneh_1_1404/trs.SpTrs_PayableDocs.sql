USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/27
-- Viewed By	 : 
-- Last Modified : 1391/12/03
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Payable Documents Report>
-- ----------------------------------------------
-- گزارش اسناد پرداختنی
-- ==============================================
Create PROCEDURE [trs].[SpTrs_PayableDocs]
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DebitCode1			Int = 0, -- بدهکار
	@DebitCode2			Int = 0,
	@DebitCode3			Int = 0,
	@DebitCode4			Int = 0,
	@CreditCode1		Int = 0, -- بستانکار
	@CreditCode2		Int = 0,
	@CreditCode3		Int = 0,
	@CreditCode4		Int = 0,
	@DocDateFr			Char(10) = Null, -- از تاریخ پرداخت
	@DocDateTo			Char(10) = Null, -- تا تاریخ پرداخت
	@UsanceDateFr		Char(10) = Null, -- از تاریخ سررسید
	@UsanceDateTo		Char(10) = Null, -- تا تاریخ سررسید
	@ChequeNoFr			VarChar(20) = Null, -- از شماره چک
	@ChequeNoTo			VarChar(20) = Null, -- تا شماره چک
	@VolumeYearFr		Int = Null, -- شماره ردیف دفتر
	@VolumeRowFr		Int = Null, 
	@VolumeYearTo		Int = Null,
	@VolumeRowTo		Int = Null,
	@AmountFr			BigInt = Null, -- مبلغ پرداختی
	@AmountTo			BigInt = Null,
	@SortFields			NVarChar(100) = Null,
	@RepOptions			VarChar(10) = '10000',  -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
Declare @StrSelect		NVarChar(max);
Declare @StrWhere		NVarChar(max);

Declare @ShowUnreceipt	bit; -- وصول نشده ها
Declare @ShowReceipt	bit; -- وصول شده ها
Declare @ShowReturned	bit; -- برگشتی ها
Declare @ShowDailyChq	bit; -- چک روز
Declare @PayableTrust	bit; -- اسناد تضمینی

Declare @StrPrefix		NVarChar(10)
Declare @StrPID			NVarChar(20)
Declare @StrTID			NVarChar(20)

DECLARE @LangID					Char(1)
DECLARE @SessionNo				VarChar(10)
DECLARE @ReportID				VarChar(10)
DECLARE @ChequeIsDigital		VarChar(10)
Begin   
	SET NoCount On;
	
	-- Init
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '1100'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1
	If (@SortFields Is Null)	SET @SortFields = 'ChequeDate'

	If (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	If (@VolumeYearFr Is Null)	SET @VolumeRowFr = Null;
	If (@VolumeYearTo Is Null)	SET @VolumeRowTo = Null;
	If (@VolumeRowFr Is Null)	SET @VolumeYearFr = Null;
	If (@VolumeRowTo Is Null)	SET @VolumeYearTo = Null;

	IF (@DebitCode1 Is Null)	SET @DebitCode1 = 0
	IF (@DebitCode2 Is Null)	SET @DebitCode2 = 0
	IF (@DebitCode3 Is Null)	SET @DebitCode3 = 0
	IF (@DebitCode4 Is Null)	SET @DebitCode4 = 0

	IF (@CreditCode1 Is Null)	SET @CreditCode1 = 0
	IF (@CreditCode2 Is Null)	SET @CreditCode2 = 0
	IF (@CreditCode3 Is Null)	SET @CreditCode3 = 0
	IF (@CreditCode4 Is Null)	SET @CreditCode4 = 0
	
	SET @ShowUnreceipt	= Substring(@RepOptions, 1, 1) -- وصول نشده ها
	SET @ShowReceipt	= Substring(@RepOptions, 2, 1) -- وصول شده ها
	SET @ShowReturned	= Substring(@RepOptions, 3, 1) -- برگشتی ها
	SET @ShowDailyChq	= Substring(@RepOptions, 4, 1) -- چک روز
	SET @PayableTrust	= Substring(@RepOptions, 5, 1) -- اسناد تضمینی

	
	if (@ShowDailyChq = 1)
		set @StrTID = '7,8,28'
	else
		set @StrTID = '8,28'

	SET	@LangID				= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			= pub.funSplitString(@RepInfo, '@', 3);
	Set @ChequeIsDigital	= pub.funSplitString(@RepInfo, '@', 6);

	SET @StrSelect = '';
	set @StrPID = '0'

	----------------------------------------------------------------------------------------
			
	If (@ShowUnreceipt = 1)
		set @StrPID	= @StrPID + ',2,25'
	If (@ShowReceipt = 1) 
		set @StrPID	= @StrPID + ',27'
	If (@ShowReturned = 1)
		set @StrPID	= @StrPID + ',28'
		
	If (@PayableTrust = 1)
	begin
		set @StrPID	=  '33,34'
		set @StrTID= '7,8,18,28'
	end		
	
	set @StrPrefix = 'D'
		
	set @StrWhere = '(D.ProcessNo=' + ltrim(STR(@ProcessNo)) + ')
	    AND (D.PayTypeID in (' + @StrTID + '))
		AND (D.ProcessID in (' + @StrPID + '))'
		
	If	(@DebitCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, @StrPrefix + '.DebitCode') 
	If	(@DebitCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, @StrPrefix + '.DebitCode') 
	If	(@DebitCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, @StrPrefix + '.DebitCode') 
	If	(@DebitCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, @StrPrefix + '.DebitCode') 

	If	(@CreditCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, @StrPrefix + '.CreditCode') 
	If	(@CreditCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, @StrPrefix + '.CreditCode') 
	If	(@CreditCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, @StrPrefix + '.CreditCode') 
	If	(@CreditCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, @StrPrefix + '.CreditCode') 

	If	(@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (' + @StrPrefix + '.DocDate >= ''' + @DocDateFr + ''')'
	If	(@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (' + @StrPrefix + '.DocDate <= ''' + @DocDateTo + ''')'

	If	(@UsanceDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate >= ''' + @UsanceDateFr + ''')'
	If	(@UsanceDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeDate <= ''' + @UsanceDateTo + ''')'

	If	(@ChequeNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNo >= ''' + LTrim(@ChequeNoFr) + ''')'
	If	(@ChequeNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ChequeNo <= ''' + LTrim(@ChequeNoTo) + ''')'

	If (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@VolumeYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.VolumeFiscalYear > ' + LTrim(Str(@VolumeYearFr)) + ' OR (D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearFr)) + ' AND D.VolumeRowNo >= ' + LTrim(Str(@VolumeRowFr)) + ')) '

	If (@VolumeYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.VolumeFiscalYear < ' + LTrim(Str(@VolumeYearTo)) + ' OR (D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearTo)) + ' AND D.VolumeRowNo <= ' + LTrim(Str(@VolumeRowTo)) + ')) '

	If	(@AmountFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.Amount >= ' + LTrim(Str(@AmountFr)) + ')'
	If	(@AmountTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.Amount <= ' + LTrim(Str(@AmountTo)) + ')'

	If @ChequeIsDigital = 1
		SET @StrWhere = @StrWhere + ' AND D.ChequeIsDigital = 1'
	If @ChequeIsDigital = 0
		SET @StrWhere = @StrWhere + ' '
	
	/* ================================================= */

	/* ======= Create Main String Query Section ======== */
	SET @StrSelect = '
	SELECT	D.*, BH.AcntCode2, BH.BankCode, BD.BankName, BD.BankAddress, 
			pub.GetCodeName(D.DebitCode, '  + @LangID + ') AS DebitName, 
			pub.GetCodeName(D.CreditCode, ' + @LangID + ') AS CreditName,
			pub.GetBankName(D.DebitCode, '  + @LangID + ') AS DebitNameB, 
			pub.GetBankName(D.CreditCode, ' + @LangID + ') AS CreditNameB,
			BT.BankTypeName, LD.LocationName
	FROM	trs.tblPayDtl D 
			LEFT  JOIN trs.tblPayHdr H ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
			LEFT  JOIN trs.tblOurBanks BH ON BH.BankCode = D.CreditCode  
			LEFT  JOIN trs.tblOurBanksDtl BD ON BH.BankCode = BD.BankCode 
			LEFT  JOIN pub.tblLocationsDtl LD ON LD.LocationID = D.LocationID AND LD.LanguageID = ' + @LangID + '
			LEFT  JOIN trs.tblBankTypesDtl BT ON D.BankTypeID = BT.BankTypeID AND BT.LanguageID = ' + @LangID + '
			INNER JOIN trs.vwLastEvent_Payment [LAST] ON [LAST].VolumeFiscalYear=D.VolumeFiscalYear and [LAST].VolumeRowNo=D.VolumeRowNo and [LAST].EventNo=D.EventNo and [LAST].ChequeNo=D.ChequeNo			
	WHERE ' + @StrWhere + '
	ORDER BY ' + @SortFields

	Print @StrSelect
	Exec sp_executesql @StrSelect;
End
GO
