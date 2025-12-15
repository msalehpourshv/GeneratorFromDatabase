USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/10/28
-- Viewed By	 : 
-- Last Modified : 1388/07/14
-- Last Modifier : TakroSystem\Ahmadnejad
-- ----------------------------------------------
-- Description	 : لیست کل چکهای دریافتی
-- ==============================================
Create PROCEDURE [trs].[SpReceivableDocsAll]
	@ResultCategory		TinyInt = 10, -- Not Used (Only for Sync)
	@IncludeReceive		Bit = 1,  -- Not Used (Only for Sync)
	@IncludePaidPerson	Bit = 0,  -- Not Used (Only for Sync)
	@IncludePaidBank	Bit = 0,  -- Not Used (Only for Sync)
	@IncludeTransfer	Bit = 0,  -- Not Used (Only for Sync)
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
	@ProcessID			Int = NULL,
	@FiscalYear			Int = NULL,
	@DocDate			varchar(10) = NULL,
	@UserID				Int,
	@UserIsAdmin		bit
WITH ENCRYPTION
As
Declare @StrWhere	NVarChar(max);
Declare @StrSelect	NVarChar(max);
Declare @StrResult	NVarChar(max);
Declare @StrPID		NVarChar(max);

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

	SET NoCount On;

--	UPDATE trs.tblPayDtl SET LockerSessionNo = 0
--	WHERE DateAdd(Minute,5,ModifiedDate) < GetDate()
	
--	UPDATE trs.tblPayHdr SET LockerSessionNo = 0
--	WHERE DateAdd(Minute,5,ModifiedDate) < GetDate()
	
	-- Init Variables -----------------------------------------------
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

	SET @Transfer			= 40      /* انتقال اسناد بین صندوق ها  */

	If	@IncludeReceive = 0 AND	@IncludePaidPerson = 0 AND	@IncludePaidBank = 0 
		SET @IncludeReceive = 1

	Select @StrPID = ''
	Select @StrResult = ''
	Select @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	Select @StrWhere = ' PD2.PayTypeID IN (' + @StrPayTypeID + ')'
	IF @ProcessNo >0 
		Select @StrWhere = @StrWhere + ' AND PD2.ProcessNo = ' + LTRim(Str(@ProcessNo))
		
	If (@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND PD2.DocDate <= ''' + @DateTo + ''''

	If	(@VolumeRowTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND PD2.VolumeRowNo <= ' + Str(@VolumeRowTo)
	
	If	(@SerialNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND NOT (PD2.SerialNo = ' + Str(@SerialNo) + 
									' AND PD2.FiscalYear= ' + Str(@FiscalYear) + 
									' AND PD2.ProcessID= ' + Str(@ProcessID)+')' 
	
	-----------------------------------------------------------------
	If (@ResultCategory = 1)	-- Available
	Begin
		SET @StrDebitName  = 'pub.GetBankName(PD.DebitCode, ' + LTRim(Str(@LanguageID)) + ')'
		SET @StrCreditName = '
				CASE WHEN (PD.ProcessID IN (23, 40))
					THEN pub.GetBankName(PD.CreditCode, ' + LTRim(Str(@LanguageID)) + ')
					ELSE pub.GetCodeName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ')
				END'
	End
	Else If (@ResultCategory = 2) -- UnAvailable
	Begin
		SET @StrDebitName = '
				CASE WHEN (PD.ProcessID IN (2, 12))
					THEN pub.GetCodeName(PD.DebitCode, ' + LTrim(Str(@LanguageID)) + ')
					ELSE pub.GetBankName(PD.DebitCode, ' + LTrim(Str(@LanguageID)) + ') 
				END'
		SET @StrCreditName = '
				CASE WHEN (PD.ProcessID = 12)
					THEN pub.GetCodeName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ')
					ELSE pub.GetBankName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ') 
				END'
	End
	Else If (@ResultCategory = 3) -- Returned
	Begin
		SET @StrDebitName  = 'pub.GetCodeName(PD.DebitCode, ' + LTrim(Str(@LanguageID)) + ')'
		SET @StrCreditName = '				
				CASE WHEN (PD.ProcessID IN (17, 18))
					THEN pub.GetCodeName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ')
					ELSE pub.GetBankName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ') 
				END'
	End

	--	Hint >>	VolumeFiscalYear & LockerSessionNo & BranchCode 
	--			& BranchName & AccOwnerName & LocationID & BankTypeID is required
	Set @StrSelect = '
		SELECT	PD.ProcessID, PD.FiscalYear, PD.SerialNo, PD.VolumeRowNo, BT.BankTypeName, PD.VolumeFiscalYear,
				PD.AccountNo,PD.ChequeIsDigital, PD.ChequeNo, PD.ChequeNoNew, PD.NationalIDNumber  ,PD.ChequeDate, PD.Amount, LD.LocationName AS BankCity, PD.DocDate,
				PD.BranchCode, PD.AccOwnerName, PD.LocationID, PD.BankTypeID, 
				pub.funGetLocationName(PD.LocationID,' + LTrim(Str(@LanguageID)) + ') AS BankCity, 
				pub.funGetBankTypeName(PD.BankTypeID,' + LTrim(Str(@LanguageID)) + ') AS BankTypeName,
				PD.DebitCode, PD.CreditCode, VOL.FirstCreditCode, [pub].[funGetLockerSessionNo](PD.ProcessID,PD.ProcessNo,PD.FiscalYear,PD.SerialNo,'''',''trs.tblPayHdr'') LockerSessionNo,
				CASE WHEN (PD.ProcessID IN (2, 13, 18, 24)) 
					THEN pub.GetCodeName(PD.DebitCode, ' + LTrim(Str(@LanguageID)) + ') 
					ELSE pub.GetBankName(PD.DebitCode, ' + LTRim(Str(@LanguageID)) + ') 
				END AS DebitName,
				CASE WHEN (PD.ProcessID IN (1, 10, 17, 18)) 
					THEN pub.GetCodeName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ') 
					ELSE pub.GetBankName(PD.CreditCode, ' + LTRim(Str(@LanguageID)) + ') 
				END AS CreditName,
				pub.GetCodeName(VOL.FirstCreditCode, ' + LTrim(Str(@LanguageID)) + ')  AS FirstCreditName,
				[pub].[funFarsiDateDiff](''Day'', ''' + @BaseDate + ''', PD.ChequeDate) AS DateDuration, 
				PD.FollowUpNumber
		FROM	trs.tblPayDtl AS PD
				LEFT JOIN pub.tblLocationsDtl AS LD ON
					LD.LocationID = PD.LocationID AND LD.LanguageID = ' + LTRim(Str(@LanguageID)) + '
				LEFT JOIN trs.tblBankTypesDtl AS BT ON
					BT.BankTypeID = PD.BankTypeID AND BT.LanguageID = ' + LTRim(Str(@LanguageID)) + '
				LEFT JOIN 
				(
					SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo,
							(
								SELECT Top 1 CreditCode
								FROM	trs.tblPayDtl
								WHERE	ProcessID IN (1,10) AND 
										PayTypeID IN (6,26) AND 
										VolumeFiscalYear = PD2.VolumeFiscalYear AND
										VolumeRowNo = PD2.VolumeRowNo
								ORDER By EventNo ASC
							) AS FirstCreditCode
					FROM	trs.tblPayDtl AS PD2
					WHERE	' + @StrWhere + '
					GROUP BY VolumeFiscalYear, VolumeRowNo
				 ) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
                      PD.VolumeRowNo = VOL.VolumeRowNo --AND PD.EventNo = VOL.EventNo
		WHERE	 PD.PayTypeID IN (' + @StrPayTypeID + ')'
		 
		IF @ProcessNo > 0
			Set @StrSelect = @StrSelect + ' AND PD.ProcessNo = ' + LTRim(Str(@ProcessNo))
		
	/* ---------------------------------------------------------------------------- */
	SET @StrResult = @StrSelect + ' AND (ProcessID IN (1,10)) '
		
	If	Not @DocDate Is Null 
		SET @StrResult = @StrResult + ' AND PD.DocDate <= ''' + RTRim(@DocDate) + ''''
	
	If	Not @DebitCodeFrom Is Null 
		SET @StrResult = @StrResult + ' AND LEFT(RTrim(PD.DebitCode),' + STR(LEN(RTrim(@DebitCodeFrom))) + ') >= ''' + RTRim(@DebitCodeFrom) + ''''
	If	Not @DebitCodeTo Is Null 
		SET @StrResult = @StrResult + ' AND LEFT(RTrim(PD.DebitCode),' + STR(LEN(RTrim(@DebitCodeTo))) + ') <= ''' + RTRim(@DebitCodeTo) + ''''

	If	Not @CreditCodeFrom Is Null 
		SET @StrResult = @StrResult + ' AND LEFT(RTrim(PD.CreditCode),' + STR(LEN(RTrim(@CreditCodeFrom))) + ') >= ''' + RTRim(@CreditCodeFrom) + ''''
	If	Not @CreditCodeTo Is Null 
		SET @StrResult = @StrResult + ' AND LEFT(RTrim(PD.CreditCode),' + STR(LEN(RTrim(@CreditCodeTo))) + ') <= ''' + RTRim(@CreditCodeTo) + ''''

	If	Not @UsanceDateFrom Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(PD.ChequeDate) >= ''' + RTrim(@UsanceDateFrom) + ''''
	If	Not @UsanceDateTo Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(PD.ChequeDate) <= ''' + RTrim(@UsanceDateTo) + ''''

	If	Not @DateFrom Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(PD.DocDate) >= ''' + RTrim(@DateFrom) + ''''
	If	Not @DateTo Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(PD.DocDate) <= ''' + RTrim(@DateTo) + ''''

	If	Not @VolumeRowFrom Is Null 
		SET @StrResult = @StrResult + ' AND PD.VolumeRowNo >= ' + Str(@VolumeRowFrom)
	If	Not @VolumeRowTo Is Null 
		SET @StrResult = @StrResult + ' AND PD.VolumeRowNo <= ' + Str(@VolumeRowTo)

	If	Not @ChequeNoFrom Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(PD.ChequeNo) >= ''' + RTrim(@ChequeNoFrom) + ''''
	If	Not @ChequeNoTo Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(PD.ChequeNo) <= ''' + RTrim(@ChequeNoTo) + ''''

	If	Not @ChequeNoNewFrom Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(PD.ChequeNoNew) >= ''' + RTrim(@ChequeNoNewFrom) + ''''
	If	Not @ChequeNoNewTo Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(PD.ChequeNoNew) <= ''' + RTrim(@ChequeNoNewTo) + ''''

	If	Not @SerialNoFrom Is Null 
		SET @StrResult = @StrResult + ' AND PD.SerialNo >= ' + Str(@SerialNoFrom)
	If	Not @SerialNoTo Is Null 
		SET @StrResult = @StrResult + ' AND PD.SerialNo <= ' + Str(@SerialNoTo) 

	If	Not @AmountFrom Is Null 
		SET @StrResult = @StrResult + ' AND PD.Amount >= ' + LTRIM(Str(@AmountFrom,30))
	If	Not @AmountTo Is Null 
		SET @StrResult = @StrResult + ' AND PD.Amount <= ' + LTRIM(Str(@AmountTo,30))

	If	Not @CityName Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(LTrim(LD.LocationName)) Like N''%' + LTrim(RTrim(@CityName)) + '%'''
	If	Not @BankName Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(LTrim(BT.BankTypeName)) Like N''%' + LTrim(RTrim(@BankName)) + '%'''
	If	Not @BranchCode Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(LTrim(PD.BranchCode)) = ''' + LTrim(RTrim(@BranchCode)) + ''''
	If	Not @AccountNo Is Null 
		SET @StrResult = @StrResult + ' AND RTrim(LTrim(PD.AccountNo)) = ''' + LTrim(RTrim(@AccountNo)) + ''''
-------------------------------------------------
	Declare @DonotFilterAcc2Trs AS bit
	SET @DonotFilterAcc2Trs = 0
	SELECT @DonotFilterAcc2Trs = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DonotFilterAcc2Trs'
		
if @DonotFilterAcc2Trs=0 	
begin


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

	If Not @SortFields Is Null
		SET @StrResult = @StrResult + ' ORDER BY ' + @SortFields

	Print @StrResult;
	Exec sp_executesql @StrResult;

End
GO
