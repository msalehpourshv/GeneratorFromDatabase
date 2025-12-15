USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		Sadeghi, Hadi
-- Create date: 06-02-2007 (1386/11/24)
-- Description: <Receivable Documents >
-- ----------------------------------------------
-- ==============================================
Create PROCEDURE [trs].[SpReceivableDocs]
	@ResultCategory		TinyInt = 1, 
	/* ------ Description ------- */
	/*  1 = چکهای موجود در صندوق  */
	/*  2 = چکهای پاس شده         */
	/*  3 = چکهای برگشت خورده     */
	/* -------------------------- */
	@IncludeReceive		Bit = 1,  /* ---  مربوط به صندوق --- */
	@IncludePaidPerson	Bit = 1,  /* ---  مربوط به اشخاص --- */
	@IncludePaidBank	Bit = 1,  /* --- مربوط به بانکها --- */
	@IncludeTransfer	Bit = 0,  /* --- مربوط به انتقال --- */
	@ProcessNo			TinyInt = 1,
	@SerialNoFrom		Int = Null,
	@SerialNoTo			Int = Null,
	@DebitCodeFrom		VarChar(20) = Null, -- کد بدهکار از
	@DebitCodeTo		VarChar(20) = Null, -- کد بدهکار تا
	@CreditCodeFrom		VarChar(20) = Null, -- کد بستانکار از
	@CreditCodeTo		VarChar(20) = Null, -- کد بستانکار تا
	@DateFrom			VarChar(20) = Null,
	@DateTo				VarChar(20) = Null,
	@UsanceDateFrom		VarChar(20) = Null, -- تاریخ سررسید از
	@UsanceDateTo		VarChar(20) = Null, --تاریخ سررسید تا
	@VolumeRowFrom		Int = Null,			-- شماره ردیف دفتر از
	@VolumeRowTo		Int = Null,			-- شماره ردیف دفتر تا
	@ChequeNoFrom		VarChar(20) = Null, -- شماره چک از
	@ChequeNoTo			VarChar(20) = Null, -- شماره چک تا
	@ChequeNoNewFrom		VarChar(20) = Null, -- شماره چک از
	@ChequeNoNewTo			VarChar(20) = Null, -- شماره چک تا
	@AmountFrom			BigInt = Null, -- مبلغ از
	@AmountTo			BigInt = Null, -- مبلغ تا
	@CityName			NVarChar(50) = Null,
	@BankName			NVarChar(50) = Null,
	@BranchCode			NVarChar(20) = Null,
	@AccountNo			NVarChar(20) = Null,  -- شماره حساب بانکی
	@SortFields			NVarChar(300) = Null, -- لیست فیلدها برای مرتب سازی
	@LanguageID			TinyInt = 1,
	@SerialNo			Int = Null,
	@ProcessID			TinyInt = NULL,
	@FiscalYear			INT = NULL,
	@DocDate			varchar(10) = NULL	,
	@UserID				Int,
	@UserIsAdmin		bit
WITH ENCRYPTION
As
Declare @StrWhere	NVarChar(2000);
Declare @StrSelect	NVarChar(2000);
Declare @StrResult	NVarChar(4000);
Declare @StrPID		NVarChar(2000);

Declare @ReceivePrim		TinyInt
Declare @Receive			TinyInt
Declare @ReceiveReceipt		TinyInt
Declare @ReceiveRet			TinyInt

Declare @PaidPerson			TinyInt
Declare @PaidPersonRetCash	TinyInt
Declare @PaidPersonRetOwner	TinyInt

Declare @PaidBankPrim		TinyInt
Declare @PaidBank			TinyInt
Declare @PaidBankReceipt	TinyInt
Declare @PaidBankRetCash	TinyInt
Declare @PaidBankRetOwner	TinyInt

Declare @BaseDate			Char(10)
Declare @Transfer			Varchar(10)
Declare @StrPayTypeID		Varchar(10)

Declare @StrDebitName		VarChar(500)
Declare @StrCreditName		VarChar(500)
Begin   

	Set NoCount On;

--	UPDATE trs.tblPayDtl SET LockerSessionNo = 0
--	WHERE DateAdd(Minute,5,ModifiedDate) < GetDate()
	
--	UPDATE trs.tblPayHdr SET LockerSessionNo = 0
--	WHERE DateAdd(Minute,5,ModifiedDate) < GetDate()
	-- بروز رسانی Eventهای تکراری
	UPDATE trs.tblPayDtl
	SET EventNo = EVN
	FROM trs.tblPayDtl a
	INNER JOIN (
				SELECT ROW_NUMBER()over(partition by a.VolumeFiscalYear,a.VolumeRowNo Order By DocDate,a.VolumeRowNo,ProcessID) EVN,
					   a.* 
				FROM trs.tblPayDtl a
				INNER JOIN ( 
							SELECT VolumeFiscalYear,
								   VolumeRowNo,
								   ChequeNo,
								   EventNo 
							FROM trs.tblPayDtl
							WHERE VolumeRowNo > 0 and ProcessID <> 41
							GROUP BY VolumeFiscalYear,VolumeRowNo,ChequeNo,EventNo
							HAVING COUNT(*) > 1) b ON a.VolumeFiscalYear = b.VolumeFiscalYear 
												  AND a.VolumeRowNo = b.VolumeRowNo 
												  AND a.ChequeNo = b.ChequeNo 
							)b ON a.ProcessID = b.ProcessID 
							  AND a.ProcessNo = b.ProcessNo 
							  AND a.FiscalYear = b.FiscalYear 
							  AND a.SerialNo = b.SerialNo 
							  AND a.RowNo=b.RowNo
				WHERE a.EventNo <> EVN 
				  AND (SELECT COUNT(*) 
					   FROM trs.tblPayDtl c 
					   WHERE a.VolumeFiscalYear = c.VolumeFiscalYear 
					     AND a.VolumeRowNo = c.VolumeRowNo 
						 AND a.ChequeNo = c.ChequeNo 
						 AND a.DocDate = c.DocDate)=1
	-- بابت تسک‌های - T9878/T10299/T10551/T10321 

	-- Init Variables -----------------------------------------------
	Set @StrPayTypeID		= '6, 26' /*        اسناد دریافتنی  */

	Set @ReceivePrim		= 10      /*  (دریافت چک (اول دوره  */
	Set @Receive			= 1       /*             دریافت چک  */
	Set @ReceiveReceipt		= 12      /*             وصول   چک  */
	Set @ReceiveRet			= 13      /*             برگشت  چک  */

	Set @PaidPerson			= 2   /*                      واگذاری به اشخاص  */
	Set @PaidPersonRetCash	= 17  /*  برگشت چک واگذاری به اشخاص  به  صندوق  */
	Set @PaidPersonRetOwner	= 18  /*  برگشت چک واگذاری به اشخاص به صاحب چک  */

	Set @PaidBankPrim		= 20  /*           (واگذاری به بانکها (اول دوره  */
	Set @PaidBank			= 21  /*                      واگذاری به بانکها  */
	Set @PaidBankReceipt	= 22  /*              وصول چک واگذاری به بانکها  */
	Set @PaidBankRetCash	= 23  /*  برگشت چک واگذاری به بانکها  به  صندوق  */
	Set @PaidBankRetOwner	= 24  /*  برگشت چک واگذاری به بانکها به صاحب چک  */

	Set @Transfer			= 40      /* انتقال اسناد بین صندوق ها  */

	If	@IncludeReceive = 0 AND	@IncludePaidPerson = 0 AND	@IncludePaidBank = 0 
		Set @IncludeReceive = 1

	Select @StrPID = ''
	Select @StrResult = ''
	Select @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	Select @StrWhere = ' PD2.PayTypeID IN (' + @StrPayTypeID + ') AND 
                         PD2.ProcessNo = ' + LTRim(Str(@ProcessNo))
	If (@DateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND PD2.DocDate <= ''' + @DateTo + ''''

	If	(@VolumeRowTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND PD2.VolumeRowNo <= ' + Str(@VolumeRowTo)
	
	If	(@VolumeRowFrom Is Not Null)
		Set @StrWhere = @StrWhere + ' AND PD2.VolumeRowNo >= ' + Str(@VolumeRowFrom)
	
	If	(@SerialNo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND NOT (PD2.SerialNo = ' + Str(@SerialNo) + 
									' AND PD2.FiscalYear= ' + Str(@FiscalYear) + 
									' AND PD2.ProcessID= ' + Str(@ProcessID)+')' 
	
	-----------------------------------------------------------------
	If (@ResultCategory = 1)	-- Available
	Begin
		Set @StrDebitName  = 'pub.GetBankName(PD.DebitCode, ' + LTRim(Str(@LanguageID)) + ')'
		Set @StrCreditName = '
				CASE WHEN (PD.ProcessID IN (23, 40))
					THEN pub.GetBankName(PD.CreditCode, ' + LTRim(Str(@LanguageID)) + ')
					ELSE pub.GetCodeName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ')
				END'
	End
	Else If (@ResultCategory = 2) -- UnAvailable
	Begin
		Set @StrDebitName = '
				CASE WHEN (PD.ProcessID IN (2, 12))
					THEN pub.GetCodeName(PD.DebitCode, ' + LTrim(Str(@LanguageID)) + ')
					ELSE pub.GetBankName(PD.DebitCode, ' + LTrim(Str(@LanguageID)) + ') 
				END'
		Set @StrCreditName = '
				CASE WHEN (PD.ProcessID = 12)
					THEN pub.GetCodeName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ')
					ELSE pub.GetBankName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ') 
				END'
	End
	Else If (@ResultCategory = 3) -- Returned
	Begin
		Set @StrDebitName  = 'pub.GetCodeName(PD.DebitCode, ' + LTrim(Str(@LanguageID)) + ')'
		Set @StrCreditName = '				
				CASE WHEN (PD.ProcessID IN (17, 18))
					THEN pub.GetCodeName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ')
					ELSE pub.GetBankName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ') 
				END'
	End

	--	Hint >>	VolumeFiscalYear & LockerSessionNo & BranchCode 
	--			& BranchName & AccOwnerName & LocationID & BankTypeID is required

	Set @StrSelect = '
		SELECT	PD.ProcessID, PD.FiscalYear, PD.SerialNo, PD.VolumeFiscalYear, PD.VolumeRowNo, PD.DocDate, PD.AccountNo, PD.ChequeIsDigital,
				PD.ChequeNo,PD.ChequeNoNew,PD.NationalIDNumber ,PD.ChequeDate, PD.Amount, pub.funGetLocationName(PD.LocationID,' + LTrim(Str(@LanguageID)) + ') AS BankCity, 
				pub.funGetBankTypeName(PD.BankTypeID,' + LTrim(Str(@LanguageID)) + ') AS BankTypeName, [pub].[funGetLockerSessionNo](PD.ProcessID,PD.ProcessNo,PD.FiscalYear,PD.SerialNo,'''',''trs.tblPayHdr'') LockerSessionNo,
				PD.BranchCode, PD.BranchName, PD.AccOwnerName, PD.LocationID, PD.BankTypeID, VOL.FirstCreditCode, 
				PD.DebitCode, PD.CreditCode, ' + @StrDebitName + ' AS DebitName, ' + @StrCreditName + ' AS CreditName,
				PD.VisitorAcntCode, pub.GetCodeName(PD.VisitorAcntCode, 1) VisitorAcntName,
				pub.GetCodeName(VOL.FirstCreditCode, ' + LTrim(Str(@LanguageID)) + ')  AS FirstCreditName,
				[pub].[funFarsiDateDiff](''Day'', ''' + @BaseDate + ''', PD.ChequeDate) AS DateDuration,
				ISNULL(PD.FollowUpNumber,''0'') FollowUpNumber
		FROM	trs.tblPayDtl PD
				INNER JOIN 
				(
				Select a.*,trs.funGetChequeOwner(a.VolumeFiscalYear,a.VolumeRowNo,6) FirstCreditCode 
				from (SELECT VolumeFiscalYear, VolumeRowNo, Max(EventNo) EventNo
					FROM trs.tblPayDtl PD2
					WHERE ' + @StrWhere + '
					GROUP BY VolumeFiscalYear,VolumeRowNo
					)a 
				 ) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
                      PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
				INNER JOIN trs.tblBankTypesDtl BD
                ON PD.BankTypeID = BD.BankTypeID
		WHERE PD.PayTypeID IN (' + @StrPayTypeID + ') AND PD.ProcessNo = ' + LTRim(Str(@ProcessNo))

	/* -------------- Category <1> (Available Cheques) --------------------------- */
	If @ResultCategory = 1 /*  چکهای موجود در صندوق  */
	Begin
		/* موجود واگذار نشده */
		If (@IncludeReceive = 1)
		Begin
			Set @StrPID = @StrPID + LTRim(Str(@ReceivePrim)) + ',' + LTRim(Str(@Receive)) 

		End

		/* موجود مسترد از اشخاص */
		If (@IncludePaidPerson = 1) 
		Begin
			If @StrPID <> '' 
				Set @StrPID = @StrPID + ', '
			Set @StrPID = @StrPID + LTRim(Str(@PaidPersonRetCash)) 
		End

		/* موجود مسترد از بانک */
		If (@IncludePaidBank = 1)
		Begin
			If @StrPID <> '' 
				Set @StrPID = @StrPID + ', '
			Set @StrPID = @StrPID + LTRim(Str(@PaidBankRetCash)) 
		End

		/* انتقال بین صندوق */
		If (@IncludeTransfer = 1)
		Begin
			If @StrPID <> '' 
				Set @StrPID = @StrPID + ', '
			Set @StrPID = @StrPID + LTRim(Str(@Transfer))
		End
	End 
	/* -------------- Category <2> (Not Available Cheques) ----------------------- */
	Else If @ResultCategory = 2    /*  چکهای خارج شده از صندوق  */
	Begin
		/* وصول شده در صندوق */
		If (@IncludeReceive = 1)
			Set @StrPID = @StrPID + LTRim(Str(@ReceiveReceipt))

		/* واگذار شده به بانک */
		If (@IncludePaidBank = 1)
		Begin
			If @StrPID <> '' 
				Set @StrPID = @StrPID + ', '
			Set @StrPID = @StrPID + LTRim(Str(@PaidBank)) + ',' + LTRim(Str(@PaidBankPrim)) + ',' + LTrim(Str(@PaidBankReceipt))

			If (@CreditCodeFrom Is Not Null)
				Set @StrPID = @StrPID + ',' + LTRim(Str(@Transfer))
		End

		/* واگذار شده به اشخاص */
		If (@IncludePaidPerson = 1)
		Begin
			If @StrPID <> '' 
				Set @StrPID = @StrPID + ', '
			Set @StrPID = @StrPID + LTRim(Str(@PaidPerson))
		End

		/* انتقال بین صندوق */
		If (@IncludeTransfer = 1)
		Begin
			If @StrPID <> '' 
				Set @StrPID = @StrPID + ', '
			Set @StrPID = @StrPID + LTRim(Str(@Transfer))
		End
	End
	/* -------------- Category <3> (Returned Cheques) ---------------------------- */
	Else If @ResultCategory = 3    /***  چکهای برگشت خورده به صاحب چک  ***/ 
	Begin
		/* برگشت در صندوق */
		If @IncludeReceive = 1
			Set @StrPID = @StrPID + LTRim(Str(@ReceiveRet))

		/* برگشت از واگذاری به اشخاص */
		If @IncludePaidPerson = 1
		Begin
			If @StrPID <> '' 
				Set @StrPID = @StrPID + ', '
			Set @StrPID = @StrPID + LTRim(Str(@PaidPersonRetOwner))
		End

		/* برگشت از واگذاری به بانک */
		If @IncludePaidBank = 1
		Begin
			If @StrPID <> '' 
				Set @StrPID = @StrPID + ', '
			Set @StrPID = @StrPID + LTRim(Str(@PaidBankRetOwner))
		End
	End
	
	/* ---------------------------------------------------------------------------- */
		
	If @StrPID <> ''
		Set @StrResult = @StrSelect + ' AND ProcessID IN (' + @StrPID + ')'
		
	If	Not @DocDate Is Null 
		Set @StrResult = @StrResult + ' AND PD.DocDate <= ''' + @DocDate + ''''

	If	Not @DebitCodeFrom Is Null 
		SET @StrResult = @StrResult + ' AND LEFT(RTrim(PD.DebitCode),' + STR(LEN(RTrim(@DebitCodeFrom))) + ') >= ''' + RTRim(@DebitCodeFrom) + ''''
	If	Not @DebitCodeTo Is Null 
		SET @StrResult = @StrResult + ' AND LEFT(RTrim(PD.DebitCode),' + STR(LEN(RTrim(@DebitCodeTo))) + ') <= ''' + RTRim(@DebitCodeTo) + ''''

	If	Not @CreditCodeFrom Is Null 
		SET @StrResult = @StrResult + ' AND LEFT(RTrim(PD.CreditCode),' + STR(LEN(RTrim(@CreditCodeFrom))) + ') >= ''' + RTRim(@CreditCodeFrom) + ''''
	If	Not @CreditCodeTo Is Null 
		SET @StrResult = @StrResult + ' AND LEFT(RTrim(PD.CreditCode),' + STR(LEN(RTrim(@CreditCodeTo))) + ') <= ''' + RTRim(@CreditCodeTo) + ''''

	If	Not @UsanceDateFrom Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(PD.ChequeDate) >= ''' + RTrim(@UsanceDateFrom) + ''''
	If	Not @UsanceDateTo Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(PD.ChequeDate) <= ''' + RTrim(@UsanceDateTo) + ''''

	If	Not @DateFrom Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(PD.DocDate) >= ''' + RTrim(@DateFrom) + ''''
	If	Not @DateTo Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(PD.DocDate) <= ''' + RTrim(@DateTo) + ''''

	If	Not @VolumeRowFrom Is Null 
		Set @StrResult = @StrResult + ' AND PD.VolumeRowNo >= ' + Str(@VolumeRowFrom)
	If	Not @VolumeRowTo Is Null 
		Set @StrResult = @StrResult + ' AND PD.VolumeRowNo <= ' + Str(@VolumeRowTo)

	If	Not @ChequeNoFrom Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(PD.ChequeNo) >= ''' + RTrim(@ChequeNoFrom) + ''''
	If	Not @ChequeNoTo Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(PD.ChequeNo) <= ''' + RTrim(@ChequeNoTo) + ''''

	If	Not @ChequeNoNewFrom Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(PD.ChequeNoNew) >= ''' + RTrim(@ChequeNoNewFrom) + ''''
	If	Not @ChequeNoNewTo Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(PD.ChequeNoNew) <= ''' + RTrim(@ChequeNoNewTo) + ''''

	If	Not @SerialNoFrom Is Null 
		Set @StrResult = @StrResult + ' AND PD.SerialNo >= ' + Str(@SerialNoFrom)
	If	Not @SerialNoTo Is Null 
		Set @StrResult = @StrResult + ' AND PD.SerialNo <= ' + Str(@SerialNoTo) 

	If	Not @AmountFrom Is Null 
		Set @StrResult = @StrResult + ' AND PD.Amount >= ' + LTRIM(Str(@AmountFrom,30))
	If	Not @AmountTo Is Null 
		Set @StrResult = @StrResult + ' AND PD.Amount <= ' + LTRIM(Str(@AmountTo,30))

	If	Not @CityName Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(LTrim(pub.funGetLocationName(PD.LocationID,' + LTrim(Str(@LanguageID)) + '))) Like N''%' + LTrim(RTrim(@CityName)) + '%'''
	If	Not @BankName Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(LTrim(BD.BankTypeName)) Like N''%' + LTrim(RTrim(@BankName)) + '%'''
	If	Not @BranchCode Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(LTrim(PD.BranchCode)) = ''' + LTrim(RTrim(@BranchCode)) + ''''
	If	Not @AccountNo Is Null 
		Set @StrResult = @StrResult + ' AND RTrim(LTrim(PD.AccountNo)) = ''' + LTrim(RTrim(@AccountNo)) + ''''



------------------------------------------
	Declare @DonotFilterAcc2Trs AS bit
	SET @DonotFilterAcc2Trs = 0
	SELECT @DonotFilterAcc2Trs = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DonotFilterAcc2Trs'
		
if @DonotFilterAcc2Trs=0 	
begin


	--SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	--SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);


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
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrResult =  @StrResult + '  and  ( PD.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   PD.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null

end
------------------------------------------------------------------------------------------------------

	If Not @SortFields Is Null
		Set @StrResult = @StrResult + ' ORDER BY ' + @SortFields

	Print @StrResult;
	Exec sp_executesql @StrResult;
End
GO
