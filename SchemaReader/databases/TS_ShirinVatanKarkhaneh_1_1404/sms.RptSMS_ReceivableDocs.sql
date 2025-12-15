USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/03/12
-- Viewed By	 : 
-- Last Modified : 1390/11/09
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Receivable Documents Report>
-- ----------------------------------------------
-- گزارش اسناد دریافتنی
-- ==============================================
CREATE PROCEDURE [sms].[RptSMS_ReceivableDocs]
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
BEGIN   

	SET NOCOUNT ON;

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
	select M.*
	into #tbl_Rec_Last
	from 
	(
		select V.*,(
					select top 1 ProcessID
					from trs.tblPayDtl I 
					where I.PayTypeID in (6, 26) 
						and I.VolumeFiscalYear = V.VolumeFiscalYear 
						and I.VolumeRowNo = V.VolumeRowNo 
						and I.EventNo = V.EventNo
					) ProcessID
		from
		(
			SELECT VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
			FROM   trs.tblPayDtl D
			WHERE  D.PayTypeID in (6, 26)
			GROUP  BY VolumeFiscalYear, VolumeRowNo
		) V	
	) M
	where M.ProcessID in (1,10,17,20,21,23,40)
	
	SELECT @StrWhere = '(1=1)'
	
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
	select T.*, A.AcntName FirstCreditName, AH.SMSMobile
	from
	(
		SELECT	D.ChequeNo, D.ChequeDate, D.Amount,
				Substring(
				isnull((
					SELECT Top 1 CreditCode
					FROM	trs.tblPayDtl
					WHERE	ProcessID IN (1,10) 
							AND PayTypeID IN (6,26) 
							AND VolumeFiscalYear = D.VolumeFiscalYear 
							AND VolumeRowNo = D.VolumeRowNo
							AND EventNo = 1
				),''''),' + ltrim(str(@AcntPartStart)) + ', ' + ltrim(str(@AcntPartLen)) +') FirstCreditCode
		FROM	trs.tblPayDtl D
					inner join #tbl_Rec_Last L on L.VolumeFiscalYear=D.VolumeFiscalYear and L.VolumeRowNo=D.VolumeRowNo and L.EventNo=D.EventNo
		WHERE	D.PayTypeID IN (6,26)
	) T left join acc.tblAcntDtl A on A.AcntCode = T.FirstCreditCode and A.PartNumber = ' + ltrim(str(@AcntPartNo)) + '
		left join acc.tblAcnt AH on AH.AcntCode = A.AcntCode
	where ' + @StrWhere + '
	order by FirstCreditCode '

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
