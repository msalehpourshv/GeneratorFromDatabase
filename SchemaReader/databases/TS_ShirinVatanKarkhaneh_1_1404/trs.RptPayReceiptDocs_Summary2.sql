USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/06/04
-- Viewed By	 : 
-- Last Modified : 1389/02/20
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : گزارش دریافتها و پرداختها - خلاصه
-- =============================================
Create PROCEDURE [trs].[RptPayReceiptDocs_Summary2] 
	@ProcessID			Int = 0, /* 0 = [1,2]; 1 = Receipt; 2 = Payment; 3 = ReceiptMisc; 4 = PayMisc; */
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DateFr				Char(10) = Null,
	@DateTo				Char(10) = Null,
	@DebitCode1			Int = 0, -- بدهکار
	@DebitCode2			Int = 0,
	@DebitCode3			Int = 0,
	@DebitCode4			Int = 0,
	@CreditCode1		Int = 0, -- بستانکار
	@CreditCode2		Int = 0,
	@CreditCode3		Int = 0,
	@CreditCode4		Int = 0,
	@VisitorCode1		Int = 0, -- بازاریاب
	@VisitorCode2		Int = 0, 
	@VisitorCode3		Int = 0, 
	@VisitorCode4		Int = 0, 
	@CollectorCode1		Int = 0, -- کد تحصیلدار
	@CollectorCode2		Int = 0, 
	@CollectorCode3		Int = 0, 
	@CollectorCode4		Int = 0, 
	@BehalfID			VarChar(20) = Null, -- از بابت
	@DescMask			NVarChar(100) = Null, -- قسمتی از شرح
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION	
As
DECLARE @StrSelect	NVarChar(3000)
DECLARE @StrFrom	NVarChar(1000)
DECLARE @BaseDate	NVarChar(10)
DECLARE @LangID		Char(1)
DECLARE @SessionNo  VarChar(10)
DECLARE @ReportID   VarChar(10)
DECLARE @year		Char(4)
DECLARE @HasSgn1	bit;
DECLARE @HasSgn2	bit;
DECLARE @HasSgn3	bit;
DECLARE @HasSgn4	bit;
DECLARE @HasSgn5	bit;
DECLARE @NotSgn1	bit;
DECLARE @NotSgn2	bit;
DECLARE @NotSgn3	bit;
DECLARE @NotSgn4	bit;
DECLARE @NotSgn5	bit;
DECLARE @Sgn1		int;
DECLARE @Sgn2		int;
DECLARE @Sgn3		int;
DECLARE @Sgn4		int;
DECLARE @Sgn5		int;
DECLARE @db_0000   nvarchar(50)

Begin -- ======================= S T A R T   C O D E =========================================

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Init -----------------------------------------------------------------------------------
	SET NOCOUNT ON;

	If (@RepInfo	Is Null)		SET @RepInfo    = '1@1@1'
	If (@ProcessID  Is Null)		SET @ProcessID  = 1
	If (@ProcessNo  Is Null)		SET @ProcessNo  = 1

	IF (@DebitCode1 Is Null)		SET @DebitCode1 = 0
	IF (@DebitCode2 Is Null)		SET @DebitCode2 = 0
	IF (@DebitCode3 Is Null)		SET @DebitCode3 = 0
	IF (@DebitCode4 Is Null)		SET @DebitCode4 = 0

	IF (@CreditCode1 Is Null)		SET @CreditCode1 = 0
	IF (@CreditCode2 Is Null)		SET @CreditCode2 = 0
	IF (@CreditCode3 Is Null)		SET @CreditCode3 = 0
	IF (@CreditCode4 Is Null)		SET @CreditCode4 = 0

	IF (@VisitorCode1 Is Null)		SET @VisitorCode1 = 0
	IF (@VisitorCode2 Is Null)		SET @VisitorCode2 = 0
	IF (@VisitorCode3 Is Null)		SET @VisitorCode3 = 0
	IF (@VisitorCode4 Is Null)		SET @VisitorCode4 = 0

	IF (@CollectorCode1 Is Null)	SET @CollectorCode1 = 0
	IF (@CollectorCode2 Is Null)	SET @CollectorCode2 = 0
	IF (@CollectorCode3 Is Null)	SET @CollectorCode3 = 0
	IF (@CollectorCode4 Is Null)	SET @CollectorCode4 = 0

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null
	IF (@SerialNoFr Is Null)		SET @FiscalYearFr = Null
	IF (@SerialNoTo Is Null)		SET @FiscalYearTo = Null

	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	SET @LangID = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID = pub.funSplitString(@RepInfo, '@', 3);
	SET @year = RIGHT(db_name(),4)


	
	SET @Sgn1		= pub.funSplitString(@RepInfo, '@', 6);
	SET @Sgn2		= pub.funSplitString(@RepInfo, '@', 7);
	SET @Sgn3		= pub.funSplitString(@RepInfo, '@', 8);
	SET @Sgn4		= pub.funSplitString(@RepInfo, '@', 9);
	SET @Sgn5		= pub.funSplitString(@RepInfo, '@', 10);	
	SET @HasSgn1	= pub.funSplitString(@RepInfo, '@', 11);
	SET @HasSgn2	= pub.funSplitString(@RepInfo, '@', 12);
	SET @HasSgn3	= pub.funSplitString(@RepInfo, '@', 13);
	SET @HasSgn4	= pub.funSplitString(@RepInfo, '@', 14);
	SET @HasSgn5	= pub.funSplitString(@RepInfo, '@', 15);
	SET @NotSgn1	= pub.funSplitString(@RepInfo, '@', 16);
	SET @NotSgn2	= pub.funSplitString(@RepInfo, '@', 17);
	SET @NotSgn3	= pub.funSplitString(@RepInfo, '@', 18);
	SET @NotSgn4	= pub.funSplitString(@RepInfo, '@', 19);
	SET @NotSgn5	= pub.funSplitString(@RepInfo, '@', 20);
	

	--------------------------------------------------------------------------------------------

	-- S E L E C T -----------------------------------------------------------------------------
	-- Select *,pub.funFarsiDateAddDays(''Day'', DocDate, DateDuration) BaseDate 	from ( )H
	Set @StrSelect = '
	SELECT	Distinct H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.DocDate, D.DebitCode, D.CreditCode, H.VchNo, H.DescHdr, 
			CASE WHEN (H.ProcessID = 1 OR H.ProcessID = 40) THEN pub.GetBankName(D.DebitCode, ' + @LangID + ') ELSE pub.GetCodeName(D.DebitCode, ' + @LangID + ')  END AS DebtorNameHdr,
			CASE WHEN (H.ProcessID = 2 OR H.ProcessID = 40) THEN pub.GetBankName(D.CreditCode,' + @LangID + ') ELSE pub.GetCodeName(D.CreditCode, ' + @LangID + ') END AS CreditorNameHdr,	
			( select sum(Amount*DateDuration)/sum(Amount)
				from (
					SELECT	 ChequeDate,Amount,	case When ChequeDate='''' then 1 else  pub.funFarsiDateDiff(''Day'', DocDate , ChequeDate)  end  AS DateDuration
					FROM	trs.tblPayDtl
						WHERE	Amount>0 AND ProcessID = H.ProcessID AND ProcessNo = H.ProcessNo AND	FiscalYear = H.FiscalYear AND SerialNo = H.SerialNo
							and DebitCode=D.DebitCode and  CreditCode=D.CreditCode	)a ) DateDuration,
							
			[pub].[GetUserName](H.SessionNo1) AS UserName,
			(
				SELECT	SUM(Amount) Amount
				FROM	trs.tblPayDtl
				WHERE	ProcessID = H.ProcessID AND ProcessNo = H.ProcessNo AND	FiscalYear = H.FiscalYear AND SerialNo = H.SerialNo
				 and DebitCode=D.DebitCode and  CreditCode=D.CreditCode
			) AS Amount	   , '''' ChequeDate,0 ChequeNo,'''' ChequeNoNew,'''' NationalIDNumber
	, 0 DocRowNo,0 AtomCount
	FROM	trs.tblPayHdr AS H 
	inner join 	trs.tblPayDtl AS D
				on D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND	D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
	WHERE	H.FiscalYear = ' + @year + ' and ( ' + LTrim(Str(@ProcessNo))+' = 0  or H.ProcessNo = ' + LTrim(Str(@ProcessNo)) +')'
	

	If	(@ProcessID > 0)
		SET @StrSelect = @StrSelect + ' AND H.ProcessID = ' + LTrim(Str(@ProcessID))
	Else
		SET @StrSelect = @StrSelect + ' AND H.ProcessID < 3'
	
	If	(@SerialNoFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	If	(@SerialNoTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	If	(@DateFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND H.DocDate >= ''' + @DateFr + ''''
	If	(@DateTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND H.DocDate <= ''' + @DateTo + ''''

	If	(@DebitCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'D.DebitCode') 
	If	(@DebitCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'D.DebitCode') 
	If	(@DebitCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'D.DebitCode') 
	If	(@DebitCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'D.DebitCode') 

	If	(@CreditCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'D.CreditCode') 
	If	(@CreditCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'D.CreditCode') 
	If	(@CreditCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'D.CreditCode') 
	If	(@CreditCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'D.CreditCode') 

	If	(@VisitorCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode') 
	If	(@VisitorCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode') 
	If	(@VisitorCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode') 
	If	(@VisitorCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode') 

	If	(@CollectorCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode1, 'H.CollectorAcntCode') 
	If	(@CollectorCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode2, 'H.CollectorAcntCode') 
	If	(@CollectorCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode3, 'H.CollectorAcntCode') 
	If	(@CollectorCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode4, 'H.CollectorAcntCode') 

	If (@DescMask Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (Replace(H.DescHdr, '' '', '''') LIKE N''%' + RTrim(Replace(@DescMask, ' ', '')) + '%'')'

	If (@BehalfID Is Not Null) and (@BehalfID <> '0')
		SET @StrSelect = @StrSelect + ' AND (H.BehalfID = ''' + @BehalfID + ''')'
	If (@BehalfID = '0')
		SET @StrSelect = @StrSelect + ' AND (H.BehalfID = '''')'
			--------------------------------------------------------------------------------------------
		Declare @DonotFilterAcc2Trs AS bit
		SET @DonotFilterAcc2Trs = 0
		SELECT @DonotFilterAcc2Trs = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'DonotFilterAcc2Trs'
		
if @DonotFilterAcc2Trs=0 	
begin		
	
	DECLARE	@UserID		Int;
	DECLARE	@UserIsAdmin bit;

	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);


	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblOurBanks
	END TRY
	BEGIN CATCH
	END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 CREATE TABLE #tblOurBanks
	(
		CreditCode 			Varchar(20)collate arabic_cs_as null
	)
	if (@UserIsAdmin = 0)
	begin
	
		if @ProcessID =2 
		 begin
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrSelect =  @StrSelect + '  and  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
		end 
	 if @ProcessID =1 
		begin 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrSelect =  @StrSelect + '  and (  D.DebitCode in (SELECT   CreditCode	FROM  #tblOurBanks     ) 
												or   D.DebitCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
		end 
		if @ProcessID =40
		begin 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
				Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
				Insert into  #tblAcntCode (AcntCode) SELECT  Distinct DebitCode 	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
		
			SET @StrSelect =  @StrSelect + '  and ( ( D.DebitCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) or  D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    )  )
												  or  ( D.DebitCode in (SELECT   AcntCode		FROM  #tblAcntCode    ) or  D.CreditCode in (SELECT   AcntCode		FROM  #tblAcntCode    )  ) ) '
		end 


	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null
end
	-- Sort ------------------------------------------------------------------------------------


	
	IF @Sgn1 <> '-1' and @HasSgn1 = 1
		Set @StrSelect = @StrSelect + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN1)=' + str(@Sgn1) + ' '
	IF @Sgn2 <> '-1' and @HasSgn2 = 1
		Set @StrSelect = @StrSelect + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN2)=' + str(@Sgn2) + ' '
	IF @Sgn3 <> '-1' and @HasSgn3 = 1
		Set @StrSelect = @StrSelect + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN3)=' + str(@Sgn3) + ' '
	IF @Sgn4 <> '-1' and @HasSgn4 = 1
		Set @StrSelect = @StrSelect + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN4)=' + str(@Sgn4) + ' '
	IF @Sgn5 <> '-1' and @HasSgn5 = 1
		Set @StrSelect = @StrSelect + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN5)=' + str(@Sgn5) + ' '

	IF @HasSgn1 = 1
		Set @StrSelect = @StrSelect + ' And H.SgnSN1<>0 '
	IF @HasSgn2 = 1
		Set @StrSelect = @StrSelect + ' And H.SgnSN2<>0 '
	IF @HasSgn3 = 1
		Set @StrSelect = @StrSelect + ' And H.SgnSN3<>0 '
	IF @HasSgn4 = 1
		Set @StrSelect = @StrSelect + ' And H.SgnSN4<>0 '
	IF @HasSgn5 = 1
		Set @StrSelect = @StrSelect + ' And H.SgnSN5<>0 '

	IF @NotSgn1 = 1
		Set @StrSelect = @StrSelect + ' And H.SgnSN1=0 '
	IF @NotSgn2 = 1								  
		Set @StrSelect = @StrSelect + ' And H.SgnSN2=0 '
	IF @NotSgn3 = 1								  
		Set @StrSelect = @StrSelect + ' And H.SgnSN3=0 '
	IF @NotSgn4 = 1								  
		Set @StrSelect = @StrSelect + ' And H.SgnSN4=0 '
	IF @NotSgn5 = 1								  
		Set @StrSelect = @StrSelect + ' And H.SgnSN5=0 '

	SET @StrSelect = @StrSelect + '	ORDER BY H.SerialNo '

	-- Run -------------------------------------------------------------------------------------
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
