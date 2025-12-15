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
create  PROCEDURE [trs].[SpTrs_ReceivableDocs_Warn]
	@ProcessID			Int = 1,  -- < 1: Cheques In Cash > < 2: Cheques Not In Cash > < 3: Returned Cheques >
	@ProcessNo			Int = 0,
	@UsanceDateTo		VarChar(10) = Null, --تاریخ سررسید تا
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

DECLARE @StrWhere			NVarChar(2000);
DECLARE @StrWhereI			NVarChar(2000);
DECLARE @StrSelect			NVarChar(2000);
DECLARE @StrResult			NVarChar(4000);
DECLARE @StrPID				NVarChar(2000);

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
declare @UserIsAdmin   bit  
declare @CurrentUserID as varchar(10) = ''
BEGIN   

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 0
	If (@SortFields Is Null)	SET @SortFields = 'FiscalYear, SerialNo'

	SET @IncludeCash	= Cast(Cast(SubString(@RepOptions, 1, 1) As Int) As Bit)
	SET @IncludePerson	= Cast(Cast(SubString(@RepOptions, 2, 1) As Int) As Bit)
	SET @IncludeBank	= Cast(Cast(SubString(@RepOptions, 3, 1) As Int) As Bit)
	SET @IncludeTransfer= Cast(Cast(SubString(@RepOptions, 4, 1) As Int) As Bit)
	SET @IncludeConfirmed0= Cast(Cast(SubString(@RepOptions, 5, 1) As Int) As Bit)
	SET @IncludeConfirmed1= Cast(Cast(SubString(@RepOptions, 6, 1) As Int) As Bit)
	SET @RecNoPrims	= Cast(Cast(SubString(@RepOptions, 7, 1) As Int) As Bit)
	SET @RecPrims	= Cast(Cast(SubString(@RepOptions, 8, 1) As Int) As Bit)
		
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
	set @CurrentUserID = pub.funSplitString(@RepInfo, '@', 4);
	set @UserIsAdmin = pub.funSplitString(@RepInfo, '@', 5);

	IF	@IncludeCash = 0 AND @IncludePerson = 0 AND	@IncludeBank = 0 
		SET @IncludeCash = 1

	SELECT @StrPID = ''
	SELECT @StrResult = ''
	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	
	SELECT @StrWhere = ' D.PayTypeID IN (' + @StrPayTypeID + ')'
	SELECT @StrWhereI = ' D2.PayTypeID IN (' + @StrPayTypeID + ')'

	if (@ProcessNo is not null) and (@ProcessNo <> 0)
	begin
		set @StrWhereI = @StrWhereI + ' and D2.ProcessNo = ' + LTrim(Str(@ProcessNo))
		set @StrWhere = @StrWhere + ' and D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	end
	
		------Check user Acess In Acc Codes----------------------------------------------------------
	
	
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
	IF (@UserIsAdmin = 0)
	BEGIN
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @CurrentUserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @CurrentUserID; 
			SET @StrWhere =  @StrWhere + '   And  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
	END 

	-----------------------------------------------------------------

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

	SET @StrSelect = '
	SELECT	D.*, LD.LocationName AS BankCity, BT.BankTypeName, H.VchNo,
			' + @StrDebitName + ' DebitName, ' + @StrCreditName + ' CreditName
	FROM	trs.tblPayDtl AS D
				INNER JOIN trs.tblPayHdr AS H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				LEFT  JOIN trs.tblBankTypesDtl AS BT ON BT.BankTypeID = D.BankTypeID AND BT.LanguageID = ' + @LangID + '
				LEFT  JOIN pub.tblLocationsDtl AS LD ON	LD.LocationID = D.LocationID AND LD.LanguageID = ' + @LangID + '
				INNER JOIN 
				(
					SELECT	D2.VolumeFiscalYear, D2.VolumeRowNo, Max(D2.EventNo) AS EventNo
					FROM	trs.tblPayDtl D2
					WHERE	' + @StrWhereI + '
					GROUP BY D2.VolumeFiscalYear, D2.VolumeRowNo
				 ) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
	WHERE	 ' + @StrWhere

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

	IF (@UsanceDateTo Is Not Null)
		SET @StrResult = @StrResult + ' AND D.ChequeDate <= ''' + @UsanceDateTo + ''''

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
