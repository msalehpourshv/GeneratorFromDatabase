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
Create PROCEDURE [trs].[RptReceivableDocs] 
	@ProcessID			Int = 1,  -- < 1: Cheques In Cash > < 2: Cheques Not In Cash > < 3: Returned Cheques >
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
	@DocDateFr			VarChar(10) = Null,
	@DocDateTo			VarChar(10) = Null,
	@UsanceDateFr		VarChar(10) = Null, -- تاریخ سررسید از
	@UsanceDateTo		VarChar(10) = Null, --تاریخ سررسید تا
	@VolumeYearFr		Int = Null,			-- شماره ردیف دفتر از
	@VolumeRowFr		Int = Null,			-- شماره ردیف دفتر از
	@VolumeYearTo		Int = Null,			-- شماره ردیف دفتر تا
	@VolumeRowTo		Int = Null,			-- شماره ردیف دفتر تا
	@ChequeNoFr			VarChar(20) = Null, -- شماره چک از
	@ChequeNoTo			VarChar(20) = Null, -- شماره چک تا
	@AmountFr			VarChar(20) = Null, -- مبلغ از // dont use bigint
	@AmountTo			VarChar(20) = Null, -- مبلغ تا // dont use bigint
	@CityName			NVarChar(50) = Null,
	@BankName			NVarChar(50) = Null,
	@BranchCode			NVarChar(20) = Null,
	@BranchName			NVarChar(20) = Null, -- Not Used
	@AccountNo			NVarChar(20) = Null,  -- شماره حساب بانکی
	@AccountOwnerName	NVarChar(50) = Null,
	@AccountOwnerType	Bit = Null,  -- نوع صاحب حساب
	@VisitorCode1		Int = 0, 
	@VisitorCode2		Int = 0,
	@VisitorCode3		Int = 0,
	@VisitorCode4		Int = 0,
	@SortFields			NVarChar(100) = Null, -- لیست فیلدها برای مرتب سازی
	@RepOptions			NVarChar(100) = '1000111', -- آرایه بیتی
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @IncludeCash		Bit;  --  مربوط به صندوق 
DECLARE @IncludePerson		Bit;  --  مربوط به اشخاص 
DECLARE @IncludeBank		Bit;  -- مربوط به بانکها 
DECLARE @IncludeTransfer	Bit;  -- مربوط به انتقال 
DECLARE @IncludeConfirmed0	Bit;  
DECLARE @IncludeConfirmed1	Bit;  
DECLARE @RecPrims		Bit;  
DECLARE @RecNoPrims		Bit;  

DECLARE @StrWhere			NVarChar(max);
DECLARE @StrSelect			NVarChar(max);
DECLARE @StrResult			NVarChar(max);
DECLARE @StrPID				NVarChar(max);

DECLARE @ReceivePrim		TinyInt
DECLARE @Receive			TinyInt
DECLARE @ReceiveReceipt		TinyInt
DECLARE @ReceiveRet			TinyInt

DECLARE @PaidPerson			TinyInt
DECLARE @PaidPersonRetCash	TinyInt
DECLARE @PaidPersonRetOwner TinyInt

DECLARE @PaidBankPrim		TinyInt
DECLARE @PaidBank			TinyInt
DECLARE @PaidBankReceipt	TinyInt
DECLARE @PaidBankRetCash	TinyInt
DECLARE @PaidBankRetOwner	TinyInt

DECLARE @BaseDate		Char(10)
DECLARE @Transfer		Varchar(10)
DECLARE @StrPayTypeID	Varchar(10)
DECLARE @StrBaseDate	nVarchar(20)

DECLARE	@TrsCalcAvgByDocDate bit;
DECLARE	@StrDebitName	VarChar(500)
DECLARE @StrCreditName	VarChar(500)
DECLARE @LangID			Char(1)
DECLARE @SessionNo		VarChar(10)
DECLARE @ReportID		VarChar(10)
declare @UseCurrency		bit;
declare @ChequeIsDigital	bit;
DECLARE @StrAcntWhere		NVarChar(4000);
DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;

BEGIN   

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1
	If (@SortFields Is Null)	SET @SortFields = 'FiscalYear, SerialNo'
	IF (@FiscalYearFr Is Null)	SET @SerialNoFr	= Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo	= Null;

	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	IF (@VolumeYearFr Is Null)	SET @VolumeRowFr = Null;
	IF (@VolumeYearTo Is Null)	SET @VolumeRowTo = Null;

	IF (@VolumeRowFr Is Null)	SET @VolumeYearFr = Null;
	IF (@VolumeRowTo Is Null)	SET @VolumeYearTo = Null;

	IF (@DebitCode1 Is Null)	SET @DebitCode1 = 0;
	IF (@DebitCode2 Is Null)	SET @DebitCode2 = 0;
	IF (@DebitCode3 Is Null)	SET @DebitCode3 = 0;
	IF (@DebitCode4 Is Null)	SET @DebitCode4 = 0;

	IF (@CreditCode1 Is Null)	SET @CreditCode1 = 0;
	IF (@CreditCode2 Is Null)	SET @CreditCode2 = 0;
	IF (@CreditCode3 Is Null)	SET @CreditCode3 = 0;
	IF (@CreditCode4 Is Null)	SET @CreditCode4 = 0;

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;

	SET @IncludeCash	= Cast(Cast(SubString(@RepOptions, 1, 1) As Int) As Bit)
	SET @IncludePerson	= Cast(Cast(SubString(@RepOptions, 2, 1) As Int) As Bit)
	SET @IncludeBank	= Cast(Cast(SubString(@RepOptions, 3, 1) As Int) As Bit)
	SET @IncludeTransfer= Cast(Cast(SubString(@RepOptions, 4, 1) As Int) As Bit)
	SET @IncludeConfirmed0= Cast(Cast(SubString(@RepOptions, 5, 1) As Int) As Bit)
	SET @IncludeConfirmed1= Cast(Cast(SubString(@RepOptions, 6, 1) As Int) As Bit)
	SET @RecNoPrims	= Cast(Cast(SubString(@RepOptions, 7, 1) As Int) As Bit)
	SET @RecPrims	= Cast(Cast(SubString(@RepOptions, 8, 1) As Int) As Bit)
	SET @UseCurrency	= Cast(Cast(SubString(@RepOptions, 9, 1) As Int) As Bit)
	Set @ChequeIsDigital = Cast(Cast(SubString(@RepOptions, 10, 1) As Int) As Bit)
	
		
	select @TrsCalcAvgByDocDate = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'TrsCalcAvgByDocDate'

	SET @StrPayTypeID		= '6, 26' /*        اسناد دریافتنی  */

	SET @ReceivePrim		= 10      /*  (دریافت چک (اول دوره  */
	SET @Receive			= 1       /*             دریافت چک  */
	SET @ReceiveReceipt		= 12      /*             وصول   چک  */
	SET @ReceiveRet			= 13      /*             برگشت  چک  */

	SET @PaidPerson			= 2   /*                      واگذاری به اشخاص  */
	SET @PaidPersonRetCash	= 17  /*  برگشت چک واگذاری به اشخاص  به  صندوق  */
	SET @PaidPersonRetOwner	= 18  /*  برگشت چک واگذاری به اشخاص به صاحب چک  */

	SET @PaidBankPrim		= 20  /*           (واگذاری به بانکها (اول دوره  */
	SET @PaidBank			= 21  /*                      واگذاری به بانکها  */
	SET @PaidBankReceipt	= 22  /*              وصول چک واگذاری به بانکها  */
	SET @PaidBankRetCash	= 23  /*  برگشت چک واگذاری به بانکها  به  صندوق  */
	SET @PaidBankRetOwner	= 24  /*  برگشت چک واگذاری به بانکها به صاحب چک  */

	SET @Transfer			= 40  /* انتقال اسناد بین صندوق ها  */

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

		SET @CampaignID		  = pub.funSplitString(@RepInfo, '@', 6);
	SET @VisitPathID1	  = pub.funSplitString(@RepInfo, '@', 7);
	SET @VisitPathID2	  = pub.funSplitString(@RepInfo, '@', 8);
	SET @VisitPathID3	  = pub.funSplitString(@RepInfo, '@', 9);
	SET @VisitPathID4	  = pub.funSplitString(@RepInfo, '@', 10);
	SET @SalesRoomClass	  = pub.funSplitString(@RepInfo, '@', 11);

	IF	@IncludeCash = 0 AND @IncludePerson = 0 AND	@IncludeBank = 0 
		SET @IncludeCash = 1

	SELECT @StrPID = ''
	SELECT @StrResult = ''
	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	SELECT @StrWhere = ' D2.PayTypeID IN (' + @StrPayTypeID + ') AND 
                         D2.ProcessNo = ' + LTrim(Str(@ProcessNo))
	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D2.DocDate <= ''' + @DocDateTo + ''')'

	IF (@VolumeRowTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D2.VolumeRowNo <= ' + Str(@VolumeRowTo)
	
	IF (@AccountOwnerType IS Not Null)
		SET @StrWhere = @StrWhere + ' AND D2.AccountOwnerType = ' + Str(@AccountOwnerType)

	IF (@AccountOwnerName IS Not Null)
		SET @StrWhere = @StrWhere + ' AND D2.AccOwnerName like ''%' + @AccountOwnerName + '%''' 

	If (@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'D2.VisitorAcntCode') + ')'
	If (@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'D2.VisitorAcntCode') + ')'
	If (@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'D2.VisitorAcntCode') + ')'
	If (@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'D2.VisitorAcntCode') + ')'
	
	If @ChequeIsDigital = 1
		SET @StrWhere = @StrWhere + ' AND ChequeIsDigital = 1'
	If @ChequeIsDigital = 0
		SET @StrWhere = @StrWhere + ' '
--=========================

	Declare @CustomerPartNo			int;
	DECLARE @CustomerPartStart		int;
	DECLARE @CustomerPartLayerLen	int;

		
	select @CustomerPartNo=[acc].[FunGetAcntInfoForRemain](1)
	select @CustomerPartStart=[acc].[FunGetAcntInfoForRemain](2)
	select @CustomerPartLayerLen= [acc].[FunGetAcntInfoForRemain](3)


	set @StrAcntWhere=' '

	If  @CampaignID > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'CampaignID') 

	If  @VisitPathID1 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'VisitPathID1') 
		
	If  @VisitPathID2 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'VisitPathID2') 
		
	If  @VisitPathID3 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'VisitPathID3') 
		
	If  @VisitPathID4 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'VisitPathID4') 
		
	If @SalesRoomClass > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SalesRoomClass, 'SalesRoomClass') 
		
	If  @StrAcntWhere <> ''
		SET @StrAcntWhere = '
		INNER JOIN (Select AcntCode AcntC From acc.tblAcnt Where PartNumber = ' + LTrim(RTrim(Str(@CustomerPartNo))) + ' 
		'+  @StrAcntWhere +'
		) a 
		ON Cast(Substring(D.CreditCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC 
		or Cast(Substring(D.DebitCode , ' + Str(@CustomerPartStart) + ', ' + Str(@CustomerPartLayerLen) + ') AS VarChar(20)) = a.AcntC '
			

	--=========================
	
	
	-----------------------------------------------------------------
	IF (@ProcessID = 1)	-- Available
	Begin
		SET @StrDebitName  = 'pub.GetBankName(D.DebitCode, ' + @LangID + ')'
		SET @StrCreditName = '
				CASE WHEN (D.ProcessID IN (23, 40))
					THEN pub.GetBankName(D.CreditCode, ' + @LangID + ')
					ELSE pub.GetCodeName(D.CreditCode, ' + @LangID + ')
				END'
	End
	Else IF (@ProcessID = 2) -- UnAvailable
	Begin
		SET @StrDebitName = '
				CASE WHEN (D.ProcessID IN (2, 12))
					THEN pub.GetCodeName(D.DebitCode, ' + @LangID + ')
					ELSE pub.GetBankName(D.DebitCode, ' + @LangID + ') 
				END'
		SET @StrCreditName = '
				CASE WHEN (D.ProcessID = 12)
					THEN pub.GetCodeName(D.CreditCode, ' + @LangID + ')
					ELSE pub.GetBankName(D.CreditCode, ' + @LangID + ') 
				END'
	End
	Else IF (@ProcessID = 3) -- Returned
	Begin
		SET @StrDebitName  = 'pub.GetCodeName(D.DebitCode, ' + @LangID + ')'
		SET @StrCreditName = '				
				CASE WHEN (D.ProcessID IN (17, 18))
					THEN pub.GetCodeName(D.CreditCode, ' + @LangID + ')
					ELSE pub.GetBankName(D.CreditCode, ' + @LangID + ') 
				END'
	End
	
	if (@TrsCalcAvgByDocDate = 1)
	set @StrBaseDate = 'D.DocDate'
	else
	set @StrBaseDate = '''' + @BaseDate + ''''

Declare @ProcessID2 as Varchar(100)
set @ProcessID2 ='0'
	if (@RecNoPrims = 1)
				SET @ProcessID2 = @ProcessID2 + ',' + LTrim(Str(@Receive))
			if (@RecPrims = 1)
				SET @ProcessID2 = @ProcessID2 + ',' + LTrim(Str(@ReceivePrim))
	
	
declare @Result1 as varchar(max)
SET @Result1= ''
exec [pub].[funGetColumnsWithoutXColumns] 
@SchemaName='trs',@tableName='tblPayDtl',
				@ColumnsName='Amount' ,
				@CompressTableName='D'
				,@Result=@Result1 output
				
		set @Result1=str(@UseCurrency) +' UseCurrency,isnull((SELECT C.CurrencyTypeName From  pub.tblCurrencyTypesDtl AS C Where H.CurrencyTypeID = C.CurrencyTypeID),'''') CurrencyTypeName,H.CurrencyRate CurrencyRateH,H.CurrencyTypeID CurrencyTypeIDH,'+@Result1
				
if (@UseCurrency=1)				
		set @Result1='case when H.CurrencyRate=0 then 0 Else  D.Amount/H.CurrencyRate end Amount,'		+@Result1
		else
		set @Result1='D.Amount,'		+@Result1
		
	SET @StrSelect = '
		SELECT	' + @Result1 + ', LD.LocationName AS BankCity, BT.BankTypeName, VOL.FirstCreditCode, 
				' + @StrDebitName + ' AS DebitName, ' + @StrCreditName + ' AS CreditName,
				pub.GetCodeName(VOL.FirstCreditCode, ' + @LangID + ')  AS FirstCreditName,
				[pub].[funFarsiDateDiff](''Day'', ' + @StrBaseDate + ', D.ChequeDate) AS DateDuration,
				H.VchNo,pub.GetCodeName(D.VisitorAcntCode, '+ STR(@LangID) +') VisitorAcntName				
		FROM	trs.tblPayDtl AS D
					INNER JOIN trs.tblPayHdr AS H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					LEFT  JOIN trs.tblBankTypesDtl AS BT ON BT.BankTypeID = D.BankTypeID AND BT.LanguageID = ' + @LangID + '
					LEFT  JOIN pub.tblLocationsDtl AS LD ON	LD.LocationID = D.LocationID AND LD.LanguageID = ' + @LangID + '
					INNER JOIN 
					(
						SELECT	D2.VolumeFiscalYear, D2.VolumeRowNo, Max(D2.EventNo) AS EventNo,
								(
									SELECT Top 1 CreditCode
									FROM	trs.tblPayDtl
									WHERE	ProcessID IN (1,10) AND 
											PayTypeID IN (6,26) AND 
											VolumeFiscalYear = D2.VolumeFiscalYear AND 
											VolumeRowNo = D2.VolumeRowNo
									ORDER By EventNo ASC
								) AS FirstCreditCode
						FROM	trs.tblPayDtl AS D2
						WHERE	' + @StrWhere + '
						GROUP BY D2.VolumeFiscalYear, D2.VolumeRowNo
					 ) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
					'+@StrAcntWhere+'
			WHERE	 D.PayTypeID IN (' + @StrPayTypeID + ') AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	
	/* -------------- Category <1> (Available Cheques) --------------------------- */
	IF (@ProcessID = 1) /*  چکهای موجود در صندوق  */
	Begin
		set @StrPID = '0'
		/* موجود واگذار نشده */
		IF (@IncludeCash = 1)
		Begin
			if (@RecNoPrims = 1)
				SET @StrPID = @StrPID + ',' + LTrim(Str(@Receive))
			if (@RecPrims = 1)
				SET @StrPID = @StrPID + ',' + LTrim(Str(@ReceivePrim))
		End

		/* موجود مسترد از اشخاص */
		IF (@IncludePerson = 1) 
		Begin
			IF @StrPID <> '' 
				SET @StrPID = @StrPID + ', '
			SET @StrPID = @StrPID + LTrim(Str(@PaidPersonRetCash)) 
		End

		/* موجود مسترد از بانک */
		IF (@IncludeBank = 1)
		Begin
			IF @StrPID <> '' 
				SET @StrPID = @StrPID + ', '
			SET @StrPID = @StrPID + LTrim(Str(@PaidBankRetCash)) 
		End

		/* انتقال بین صندوق */
		IF (@IncludeTransfer = 1)
		Begin
			IF @StrPID <> '' 
				SET @StrPID = @StrPID + ', '
			SET @StrPID = @StrPID + LTrim(Str(@Transfer))
		End
	End 
	/* -------------- Category <2> (Not Available Cheques) ----------------------- */
	Else IF (@ProcessID = 2)    /*  چکهای خارج شده از صندوق  */
	Begin
		/* وصول شده در صندوق */
		IF (@IncludeCash = 1)
			SET @StrPID = @StrPID + LTrim(Str(@ReceiveReceipt))

		/* واگذار شده به بانک */
		IF (@IncludeBank = 1)
		Begin
			IF (@StrPID <> '')
				SET @StrPID = @StrPID + ', '
			SET @StrPID = @StrPID + LTrim(Str(@PaidBank)) + ',' + LTrim(Str(@PaidBankPrim)) + ',' + LTrim(Str(@PaidBankReceipt))

			IF (@CreditCode1 > 0) Or (@CreditCode2 > 0) Or (@CreditCode3 > 0) Or (@CreditCode4 > 0) 
				SET @StrPID = @StrPID + ',' + LTrim(Str(@Transfer))
		End

		/* واگذار شده به اشخاص */
		IF (@IncludePerson = 1)
		Begin
			IF (@StrPID <> '')
				SET @StrPID = @StrPID + ', '
			SET @StrPID = @StrPID + LTrim(Str(@PaidPerson))
		End

		/* انتقال بین صندوق */
		IF (@IncludeTransfer = 1)
		Begin
			IF (@StrPID <> '')
				SET @StrPID = @StrPID + ', '
			SET @StrPID = @StrPID + LTrim(Str(@Transfer))
		End
	End
	/* -------------- Category <3> (Returned Cheques) ---------------------------- */
	Else IF (@ProcessID = 3)    /***  چکهای برگشت خورده به صاحب چک  ***/ 
	Begin
		/* برگشت در صندوق */
		IF @IncludeCash = 1
			SET @StrPID = @StrPID + LTrim(Str(@ReceiveRet))

		/* برگشت از واگذاری به اشخاص */
		IF (@IncludePerson = 1)
		Begin
			IF @StrPID <> '' 
				SET @StrPID = @StrPID + ', '
			SET @StrPID = @StrPID + LTrim(Str(@PaidPersonRetOwner))
		End

		/* برگشت از واگذاری به بانک */
		IF (@IncludeBank = 1)
		Begin
			IF @StrPID <> '' 
				SET @StrPID = @StrPID + ', '
			SET @StrPID = @StrPID + LTrim(Str(@PaidBankRetOwner))
		End
	End
	/* ---------------------------------------------------------------------------- */
	IF @StrPID <> ''
		SET @StrResult = @StrSelect + ' AND D.ProcessID IN (' + @StrPID + ')'

	IF (@FiscalYearFr Is Not Null)
		SET @StrResult = @StrResult + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	IF (@FiscalYearTo Is Not Null)
		SET @StrResult = @StrResult + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	IF (@VolumeYearFr Is Not Null)
		SET @StrResult = @StrResult + ' AND (D.VolumeFiscalYear > ' + LTrim(Str(@VolumeYearFr)) + ' OR
		(D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearFr)) + ' AND D.VolumeRowNo >= ' + LTrim(Str(@VolumeRowFr)) + ')) '

	IF (@VolumeYearTo Is Not Null)
		SET @StrResult = @StrResult + ' AND (D.VolumeFiscalYear < ' + LTrim(Str(@VolumeYearTo)) + ' OR
		(D.VolumeFiscalYear = ' + LTrim(Str(@VolumeYearTo)) + ' AND D.VolumeRowNo <= ' + LTrim(Str(@VolumeRowTo)) + ')) '

	IF	(@DebitCode1 > 0)
		SET @StrResult = @StrResult + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'D.DebitCode') 
	IF	(@DebitCode2 > 0)
		SET @StrResult = @StrResult + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'D.DebitCode') 
	IF	(@DebitCode3 > 0)
		SET @StrResult = @StrResult + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'D.DebitCode') 
	IF	(@DebitCode4 > 0)
		SET @StrResult = @StrResult + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'D.DebitCode') 

	IF	(@CreditCode1 > 0)
		SET @StrResult = @StrResult + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'D.CreditCode') 
	IF	(@CreditCode2 > 0)
		SET @StrResult = @StrResult + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'D.CreditCode') 
	IF	(@CreditCode3 > 0)
		SET @StrResult = @StrResult + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'D.CreditCode') 
	IF	(@CreditCode4 > 0)
		SET @StrResult = @StrResult + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'D.CreditCode') 

	IF (@DocDateFr Is Not Null)
		SET @StrResult = @StrResult + ' AND D.DocDate >= ''' + @DocDateFr + ''''
	IF (@DocDateTo Is Not Null)
		SET @StrResult = @StrResult + ' AND D.DocDate <= ''' + @DocDateTo + ''''

	IF (@UsanceDateFr Is Not Null)
		SET @StrResult = @StrResult + ' AND D.ChequeDate >= ''' + @UsanceDateFr + ''''
	IF (@UsanceDateTo Is Not Null)
		SET @StrResult = @StrResult + ' AND D.ChequeDate <= ''' + @UsanceDateTo + ''''

	IF (@ChequeNoFr Is Not Null)
		SET @StrResult = @StrResult + ' AND D.ChequeNo >= ''' + LTrim(RTrim(@ChequeNoFr)) + ''''
	IF (@ChequeNoTo Is Not Null)
		SET @StrResult = @StrResult + ' AND D.ChequeNo <= ''' + LTrim(RTrim(@ChequeNoTo)) + ''''

	IF (@AmountFr Is Not Null)
		SET @StrResult = @StrResult + ' AND D.Amount >= ' + LTrim(@AmountFr)
	IF (@AmountTo Is Not Null)
		SET @StrResult = @StrResult + ' AND D.Amount <= ' + LTrim(@AmountTo)

	IF (@CityName Is Not Null)
		SET @StrResult = @StrResult + ' AND RTrim(LTrim(LD.LocationName)) Like N''%' + LTrim(RTrim(@CityName)) + '%'''
	IF (@BankName Is Not Null)
		SET @StrResult = @StrResult + ' AND RTrim(LTrim(BT.BankTypeName)) Like N''%' + LTrim(RTrim(@BankName)) + '%'''
	IF (@BranchCode Is Not Null)
		SET @StrResult = @StrResult + ' AND RTrim(LTrim(D.BranchCode)) = ''' + LTrim(RTrim(@BranchCode)) + ''''
	IF (@AccountNo Is Not Null)
		SET @StrResult = @StrResult + ' AND RTrim(LTrim(D.AccountNo)) = ''' + LTrim(RTrim(@AccountNo)) + ''''

	if (@IncludeConfirmed0 = 0)
		SET @StrResult = @StrResult + ' AND (D.IsConfirmed<>0) '
	if (@IncludeConfirmed1 = 0)
		SET @StrResult = @StrResult + ' AND (D.IsConfirmed<>1) '

	IF (@SortFields Is Not Null)
		SET @StrResult = @StrResult + ' ORDER BY ' + @SortFields

	Print @StrResult;
	Exec sp_executesql @StrResult;
End
GO
