USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		 Sadeghi, Hadi
-- Create date: 06-05-2007 (1386/11/24)
-- Description: <Receivable Documents Paid To Banks >
-- ----------------------------------------------
-- ==============================================
Create PROCEDURE [trs].[SpReceivableDocsBank]
	@ProcessID			TinyInt = 21, 
	/*  20  =  همه چکهای واگذار شده		*/
	/*  21  =  وصول نشده				*/
	/*  22  =  وصول شده					*/
	/*  23  =  برگشتی به صندوق			*/
	/*  24  =  برگشتی به صاحب چک		*/
	@ProcessNo			TinyInt = 1,
	@SerialNoFrom		Int = Null,
	@SerialNoTo			Int = Null,
	@DebitCodeFrom		VarChar(20) = Null,
	@DebitCodeTo		VarChar(20) = Null,
	@DateFrom			VarChar(20) = Null,
	@DateTo				VarChar(20) = Null,
	@UsanceDateFrom		VarChar(20) = Null, -- تاریخ سررسید از
	@UsanceDateTo		VarChar(20) = Null, -- تاریخ سررسید تا
	@VolumeRowFrom		Int = Null, -- شماره ردیف دفتر از
	@VolumeRowTo		Int = Null, -- شماره ردیف دفتر تا
	@ChequeNoFrom		NVarChar(20) = Null,
	@ChequeNoTo			NVarChar(20) = Null,
	@ChequeNoNewFrom		NVarChar(20) = Null,
	@ChequeNoNewTo			NVarChar(20) = Null,
	@AmountFrom			BigInt = Null,
	@AmountTo			BigInt = Null,
	@CityName			NVarChar(50) = Null,
	@BankName			NVarChar(50) = Null,
	@BranchCode			NVarChar(20) = Null,
	@BranchName			NVarChar(50) = Null,
	@AccountNo			NVarChar(20) = Null,
	@SortFields			NVarChar(300) = Null, -- لیست فیلدها برای مرتب سازی
	@LanguageID			TinyInt = 1,
	@BaseProcessID		Int = Null,
	@SerialNo			Int = Null,
	@FiscalYear			Int = NULL,
	@BankSnNoFrom		int,
	@BankSnNoTo			int,
	@DocDate			varchar(10) = NULL,
	@UserID				Int,
	@UserIsAdmin		bit
WITH ENCRYPTION
As
Declare @StrSelect		NVarChar(4000);
Declare @StrProcessID	NVarChar(20);
Declare @BaseDate		NVarChar(10);
Declare @StrWhere		NVarChar(500);
Begin   

   
	Set NoCount On;
	
--	UPDATE trs.tblPayDtl SET LockerSessionNo = 0
--	WHERE DateAdd(Minute,5,ModifiedDate) < GetDate()
	
--	UPDATE trs.tblPayHdr SET LockerSessionNo = 0
--	WHERE DateAdd(Minute,5,ModifiedDate) < GetDate()
	
	Select @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	
	If (@ProcessID = 20) OR (@ProcessID = 21)
		Set @StrProcessID = '20, 21'
	Else
		Set @StrProcessID = LTrim(Str(@ProcessID))

	Set @StrWhere = ' PD2.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@ProcessID = 20)	-- All Cheques Requested
		Set @StrWhere = @StrWhere + ' AND PD2.ProcessID IN(' + @StrProcessID + ')'

	If (@DateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND PD2.DocDate <= ''' + @DateTo + ''''

	If	(@VolumeRowTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND PD2.VolumeRowNo <= ' + LTrim(Str(@VolumeRowTo))

	If	(@SerialNo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND NOT (PD2.SerialNo = ' + Str(@SerialNo) + 
									' AND PD2.FiscalYear= ' + Str(@FiscalYear) + 
									' AND PD2.ProcessID= ' + Str(@BaseProcessID)+')' 

	Set @StrSelect = '
		SELECT PD.*, pub.GetCodeName(PD.FirstCreditCode, ' + LTrim(Str(@LanguageID)) + ') AS FirstCreditName
		FROM
		(
			SELECT PD.ProcessID ChequeState, PD.FiscalYear, PD.SerialNo, PD.DocDate, PD.Amount,
					 PD.VolumeFiscalYear, PD.VolumeRowNo, PD.EventNo, PD.AccountNo,PD.ChequeIsDigital, PD.ChequeNo,PD.ChequeNoNew,PD.NationalIDNumber, PD.ChequeDate, [pub].[funGetLockerSessionNo](PD.ProcessID,PD.ProcessNo,PD.FiscalYear,PD.SerialNo,'''',''trs.tblPayHdr'') LockerSessionNo, 
					 PD.DebitCode, PD.CreditCode, PD.BranchCode, PD.BranchName,PD.AccOwnerName, pub.funGetLocationName(PD.LocationID,' + LTrim(Str(@LanguageID)) + ') AS LocationName, pub.funGetBankTypeName(PD.BankTypeID,' + LTrim(Str(@LanguageID)) + ') BankTypeName, ' +
					 Case When @ProcessID = 24 Then 'pub.GetCodeName(PD.DebitCode, ' + LTrim(Str(@LanguageID)) + ')' Else 'pub.GetBankName(PD.DebitCode, ' + LTrim(Str(@LanguageID)) + ')' END + ' AS DebitName, 
					 pub.GetBankName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ') AS CreditName, 
					 trs.funGetChequeOwner(PD.VolumeFiscalYear, PD.VolumeRowNo,PD.PayTypeID) AS FirstCreditCode,
					 Case When PD.ChequeDate <> '''' And PD.ChequeDate Is Not Null Then 
						[pub].[funFarsiDateDiff](''Day'', ''' + @BaseDate + ''', PD.ChequeDate)
					 Else '''' End DateDuration, BankSnNo, 
					 FollowUpNumber
			FROM	 trs.tblPayDtl AS PD
					 INNER JOIN 
					 (
						SELECT VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo 
						FROM   trs.tblPayDtl AS PD2
						WHERE  ' + @StrWhere + '
						GROUP  BY VolumeFiscalYear, VolumeRowNo
					 ) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
								 PD.VolumeRowNo = VOL.VolumeRowNo AND 
								 PD.EventNo = VOL.EventNo
			WHERE	PD.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ' AND 
					ProcessID IN (' + @StrProcessID + ')
		) AS PD WHERE 1=1 '

	/* ---------------------------------------------------------------------------- */
	If	Not @DocDate Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.DocDate <= ''' + @DocDate + ''''
	
	If	Not @DebitCodeFrom Is Null 
		If @ProcessID <= 21  
			Set @StrSelect = @StrSelect + ' AND RTrim(PD.DebitCode) >= ''' + RTRim(@DebitCodeFrom) + ''''
		Else
			Set @StrSelect = @StrSelect + ' AND RTrim(PD.CreditCode) >= ''' + RTRim(@DebitCodeFrom) + ''''

	If	Not @DebitCodeTo Is Null 
		If @ProcessID <= 21  
			Set @StrSelect = @StrSelect + ' AND RTrim(PD.DebitCode) <= ''' + RTRim(@DebitCodeTo) + ''''
		Else
			Set @StrSelect = @StrSelect + ' AND RTrim(PD.CreditCode) <= ''' + RTRim(@DebitCodeTo) + ''''

	If	Not @UsanceDateFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeDate) >= ''' + RTrim(@UsanceDateFrom) + ''''
	If	Not @UsanceDateTo Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeDate) <= ''' + RTrim(@UsanceDateTo) + ''''

	If	Not @DateFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.DocDate) >= ''' + RTrim(@DateFrom) + ''''
	If	Not @DateTo Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.DocDate) <= ''' + RTrim(@DateTo) + ''''

	If	Not @VolumeRowFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.VolumeRowNo >= ' + Str(@VolumeRowFrom)
	If	Not @VolumeRowTo Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.VolumeRowNo <= ' + Str(@VolumeRowTo)

	If	Not @ChequeNoFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeNo) >= ''' + RTrim(@ChequeNoFrom) + ''''
	If	Not @ChequeNoTo Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeNo) <= ''' + RTrim(@ChequeNoTo) + ''''

	If	Not @ChequeNoNewFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeNoNew) >= ''' + RTrim(@ChequeNoNewFrom) + ''''
	If	Not @ChequeNoNewTo Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeNoNew) <= ''' + RTrim(@ChequeNoNewTo) + ''''

	If	Not @SerialNoFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.SerialNo >= ' + Str(@SerialNoFrom)
	If	Not @SerialNoTo Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.SerialNo <= ' + Str(@SerialNoTo) 

	If	Not @AmountFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.Amount >= ' + LTRIM(Str(@AmountFrom,30))
	If	Not @AmountTo Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.Amount <= ' + LTRIM(Str(@AmountTo,30))

	If	Not @BankSnNoFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.BankSnNo >= ' + Str(@BankSnNoFrom)
	If	Not @BankSnNoTo Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.BankSnNo <= ' + Str(@BankSnNoTo)
		
	If	Not @CityName Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(LTrim(PD.LocationName)) = ''' + LTrim(RTrim(@CityName)) + ''''
	If	Not @BankName Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(LTrim(PD.BankTypeName)) = ''' + LTrim(RTrim(@BankName)) + ''''
	If	Not @BranchCode Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(LTrim(PD.BranchCode)) = ''' + LTrim(RTrim(@BranchCode)) + ''''
	If	Not @BranchName Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(LTrim(PD.BranchName)) = ''' + LTrim(RTrim(@BranchCode)) + ''''
	If	Not @AccountNo Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(LTrim(PD.AccountNo)) = ''' + LTrim(RTrim(@AccountNo)) + ''''

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
			SET @StrSelect =  @StrSelect + '  and  ( PD.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   PD.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null

end

	If Not @SortFields Is Null
		Set @StrSelect = @StrSelect + ' ORDER BY ' + @SortFields

	print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
