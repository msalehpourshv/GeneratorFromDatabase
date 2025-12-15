USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE sms.RptSMS_ReceivableDocs_SHV
	@AcntPartNo		int = 2,
	@AcntPartStart	int = 8,
	@AcntPartLen	int = 7,
	@CreditCode1	Int = 0, -- بستانکار
	@CreditCode2	Int = 0,
	@CreditCode3	Int = 0,
	@CreditCode4	Int = 0,
	@UsanceDateFr	VarChar(10) = Null, -- تاریخ سررسید از
	@UsanceDateTo	VarChar(10) = Null, --تاریخ سررسید تا
	@RepOptions		varchar(20)= '0',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrSelect	NVarChar(max);
DECLARE @MobileReq	bit;

DECLARE @LangID		Char(1)
DECLARE @SessionNo	VarChar(10)
DECLARE @ReportID	VarChar(10)

DECLARE @Current_FY Int

BEGIN   

	SET NOCOUNT ON;

	Select @Current_FY = FiscalYear From TS_ShirinVatanKarkhaneh_1_0000.pub.tblFiscalYears Where IsDefault = 1

	-- Init Variables -----------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'

	IF (@CreditCode1 Is Null)	SET @CreditCode1 = 0;
	IF (@CreditCode2 Is Null)	SET @CreditCode2 = 0;
	IF (@CreditCode3 Is Null)	SET @CreditCode3 = 0;
	IF (@CreditCode4 Is Null)	SET @CreditCode4 = 0;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @MobileReq  = Substring(@RepOptions, 1, 1);
	-----------------------------------------------------------------
	SELECT M.*
	INTO #tbl_Rec_Last
	FROM 
	(
		Select (
				Select Top 1 ProcessID From trs.tblPayDtl I 
				Where 1 = 1
                  --And I.PayTypeID in (6, 26) 
				  And I.VolumeFiscalYear = V.VolumeFiscalYear 
				  And I.VolumeRowNo = V.VolumeRowNo 
				  And I.EventNo = V.EventNo
			   ) ProcessID, V.*
		From
		(
			Select ProcessNo, FiscalYear, SerialNo, DocRowNo, DocDate, 
			Case When ProcessID = 1 Then CreditCode
				 When ProcessID = 2 Then DebitCode
			Else '' End AcntCode, CurrencyTypeID, pub.funGetCurrencyTypesName(CurrencyTypeID, 1) CurrencyTypeName, CurrencyAmount, 
			VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
			From   trs.tblPayDtl D
            Where 1 = 1
              --And M.ProcessID  IN(1,10,17,20,21,23,40)
              And ProcessID  IN(1, 10)
              And ProcessNo  IN(1)
              And FiscalYear IN(@Current_FY)
              --And M.SerialNo   IN(185)
              And DocDate >= '1403/03/31'
              --And D.PayTypeID in (6, 26)
			Group By ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, DocDate, CreditCode, DebitCode, CurrencyTypeID, CurrencyAmount, ReceiptAcntCode, VolumeFiscalYear, VolumeRowNo
		) V	
	) M
	Where 1 = 1

	SET @StrWhere = 'SerialNo Not IN(Select SerialNo From sms.tbl_SHV_SMS_List Where ProcessID = 1 And ProcessNo = 1 And FiscalYear = ' + LTrim(RTrim(Str(@Current_FY))) + ')'
	
	IF	(@CreditCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'T.FirstCreditCode') 
	IF	(@CreditCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'T.FirstCreditCode') 
	IF	(@CreditCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'T.FirstCreditCode') 
	IF	(@CreditCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'T.FirstCreditCode') 

	IF (@UsanceDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (T.ChequeDate>=''' + @UsanceDateFr + ''')'
	IF (@UsanceDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (T.ChequeDate<=''' + @UsanceDateTo + ''')'

	if (@MobileReq = 1)
		set @StrWhere = @StrWhere + ' and (AH.CodeClosed=0) and (AH.SMSMobile<>'''')'

	SET @StrSelect = '
	SELECT T.*, Case When AD.FirstName <> '''' Then AD.FirstName + '' '' + AD.LastName Else AD.AcntName End AcntName, IsNull(AH.SMSMobile, '''') SMSMobile
	FROM
	(
		SELECT	L.ProcessID, L.ProcessNo, L.FiscalYear, L.SerialNo, L.DocDate, L.AcntCode, D.ChequeNo, D.ChequeDate, D.Amount, L.CurrencyTypeID, L.CurrencyTypeName, L.CurrencyAmount,
				Substring(
				IsNull((
                        SELECT Top 1 CreditCode
                        FROM	trs.tblPayDtl
                        WHERE 1 = 1
                          AND ProcessID  IN (1,10) 
                          AND ProcessNo  IN (1)
                          AND FiscalYear IN(' + LTrim(RTrim(Str(@Current_FY))) + ')
                          --AND SerialNo   IN(1211)
						  AND DocDate >= ''1403/03/31''
                          --AND PayTypeID  IN (6,26) 
                          AND VolumeFiscalYear = D.VolumeFiscalYear 
                          AND VolumeRowNo = D.VolumeRowNo
                          AND EventNo = 1
				),''''),' + ltrim(str(@AcntPartStart)) + ', ' + ltrim(str(@AcntPartLen)) +') FirstCreditCode
		FROM	trs.tblPayDtl D
		INNER JOIN #tbl_Rec_Last L on D.ProcessID = L.ProcessID And D.ProcessNo = L.ProcessNo And D.FiscalYear = L.FiscalYear And 
		                              D.SerialNo = L.SerialNo And D.DocRowNo = L.DocRowNo And L.VolumeFiscalYear=D.VolumeFiscalYear and 
									  L.VolumeRowNo=D.VolumeRowNo and L.EventNo=D.EventNo
		WHERE 1 = 1
          --AND D.PayTypeID IN (6,26)
	) T 
	left join acc.tblAcntDtl AD on AD.AcntCode = Case When Len(T.AcntCode) > 6 Then SubString(T.AcntCode, 7, 20) Else T.AcntCode End --and A.PartNumber = ' + ltrim(str(@AcntPartNo)) + '
	left join acc.tblAcnt    AH on AH.AcntCode = Case When Len(T.AcntCode) > 6 Then SubString(T.AcntCode, 7, 20) Else T.AcntCode End
	WHERE ' + @StrWhere + '
	ORDER BY T.ProcessID, T.ProcessNo, T.FiscalYear, T.SerialNo, T.DocDate '

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
