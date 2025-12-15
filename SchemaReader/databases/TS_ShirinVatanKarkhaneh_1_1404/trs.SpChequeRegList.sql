USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1402/02/25
-- Viewed By	 : 
-- Last Modified :
-- Last Modifier :
-- ----------------------------------------------
-- Description	 : لیست کل چکها
-- ==============================================
Create PROCEDURE trs.SpChequeRegList
	@PayRecive			TinyInt = 1, 
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
	@UserIsAdmin		bit,
	@ExtraParams		NvarChar(200)
WITH ENCRYPTION
As
Declare @StrWhere	NVarChar(max);
Declare @StrSelect	NVarChar(max);
 
Declare @BaseDate			Char(10)
Declare @Transfer			Varchar(10)
Declare @StrPayTypeID		Varchar(10)
Declare @StrProcessID		Varchar(10)
Declare @StrDebitName		VarChar(500)
Declare @StrCreditName		VarChar(500)
Declare @OK					bit
Declare @NotOk				bit
Begin   

	SET NoCount On;

--	UPDATE trs.tblPayDtl SET LockerSessionNo = 0
--	WHERE DateAdd(Minute,5,ModifiedDate) < GetDate()
	
--	UPDATE trs.tblPayHdr SET LockerSessionNo = 0
--	WHERE DateAdd(Minute,5,ModifiedDate) < GetDate()
	

	SET @OK		= pub.funSplitString(@ExtraParams, '@', 1);
	SET @NotOk	= pub.funSplitString(@ExtraParams, '@', 2);

	-- Init Variables -----------------------------------------------
	if @PayRecive=1
		SET @StrProcessID		='1,10'
	else
		SET @StrProcessID		='2,25,28'
	if @PayRecive=1
		SET @StrPayTypeID		= '6, 26' /*        اسناد دریافتنی  */
	else
		SET @StrPayTypeID		= '6,7,8,18,28' /*        اسناد پرداختنی  */



	Select @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	Select @StrWhere = ' PD.PayTypeID IN (' + @StrPayTypeID + ') and  PD.ProcessID IN (' + @StrProcessID + ')'

	IF @ProcessNo >0 
		Select @StrWhere = @StrWhere + ' AND PD.ProcessNo = ' + LTRim(Str(@ProcessNo))
		
	If (@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND PD.DocDate <= ''' + @DateTo + ''''

	If	(@VolumeRowTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND PD.VolumeRowNo <= ' + Str(@VolumeRowTo)
			
	If	Not @DocDate Is Null 
		SET @StrWhere = @StrWhere + ' AND PD.DocDate <= ''' + RTRim(@DocDate) + ''''
	
	If	Not @DebitCodeFrom Is Null 
		SET @StrWhere = @StrWhere + ' AND LEFT(RTrim(PD.DebitCode),' + STR(LEN(RTrim(@DebitCodeFrom))) + ') >= ''' + RTRim(@DebitCodeFrom) + ''''
	If	Not @DebitCodeTo Is Null 
		SET @StrWhere = @StrWhere + ' AND LEFT(RTrim(PD.DebitCode),' + STR(LEN(RTrim(@DebitCodeTo))) + ') <= ''' + RTRim(@DebitCodeTo) + ''''

	If	Not @CreditCodeFrom Is Null 
		SET @StrWhere = @StrWhere + ' AND LEFT(RTrim(PD.CreditCode),' + STR(LEN(RTrim(@CreditCodeFrom))) + ') >= ''' + RTRim(@CreditCodeFrom) + ''''
	If	Not @CreditCodeTo Is Null 
		SET @StrWhere = @StrWhere + ' AND LEFT(RTrim(PD.CreditCode),' + STR(LEN(RTrim(@CreditCodeTo))) + ') <= ''' + RTRim(@CreditCodeTo) + ''''

	If	Not @UsanceDateFrom Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(PD.ChequeDate) >= ''' + RTrim(@UsanceDateFrom) + ''''
	If	Not @UsanceDateTo Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(PD.ChequeDate) <= ''' + RTrim(@UsanceDateTo) + ''''

	If	Not @DateFrom Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(PD.DocDate) >= ''' + RTrim(@DateFrom) + ''''
	If	Not @DateTo Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(PD.DocDate) <= ''' + RTrim(@DateTo) + ''''

	If	Not @VolumeRowFrom Is Null 
		SET @StrWhere = @StrWhere + ' AND PD.VolumeRowNo >= ' + Str(@VolumeRowFrom)
	If	Not @VolumeRowTo Is Null 
		SET @StrWhere = @StrWhere + ' AND PD.VolumeRowNo <= ' + Str(@VolumeRowTo)

	If	Not @ChequeNoFrom Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(PD.ChequeNo) >= ''' + RTrim(@ChequeNoFrom) + ''''
	If	Not @ChequeNoTo Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(PD.ChequeNo) <= ''' + RTrim(@ChequeNoTo) + ''''

	If	Not @ChequeNoNewFrom Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(PD.ChequeNoNew) >= ''' + RTrim(@ChequeNoNewFrom) + ''''
	If	Not @ChequeNoNewTo Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(PD.ChequeNoNew) <= ''' + RTrim(@ChequeNoNewTo) + ''''

	If	Not @SerialNoFrom Is Null 
		SET @StrWhere = @StrWhere + ' AND PD.SerialNo >= ' + Str(@SerialNoFrom)
	If	Not @SerialNoTo Is Null 
		SET @StrWhere = @StrWhere + ' AND PD.SerialNo <= ' + Str(@SerialNoTo) 

	If	Not @AmountFrom Is Null 
		SET @StrWhere = @StrWhere + ' AND PD.Amount >= ' + LTRIM(Str(@AmountFrom,30))
	If	Not @AmountTo Is Null 
		SET @StrWhere = @StrWhere + ' AND PD.Amount <= ' + LTRIM(Str(@AmountTo,30))

	If	Not @CityName Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(LD.LocationName)) Like N''%' + LTrim(RTrim(@CityName)) + '%'''
	If	Not @BankName Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(BT.BankTypeName)) Like N''%' + LTrim(RTrim(@BankName)) + '%'''
	If	Not @BranchCode Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(PD.BranchCode)) = ''' + LTrim(RTrim(@BranchCode)) + ''''
	If	Not @AccountNo Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(LTrim(PD.AccountNo)) = ''' + LTrim(RTrim(@AccountNo)) + ''''



-------------------------------------------------
	
	--	Hint >>	VolumeFiscalYear & LockerSessionNo & BranchCode 
	--			& BranchName & AccOwnerName & LocationID & BankTypeID is required
	Set @StrSelect = '
		SELECT	ProcessID,ProcessNo,FiscalYear,SerialNo,ltrim(str(FiscalYear))+''/''+ltrim(str(SerialNo)) FSSerialNo
		,PayTypeID,ltrim(str(VolumeFiscalYear))+''/''+ltrim(str(VolumeRowNo)) Volume
		,VolumeFiscalYear,VolumeRowNo,ChequeNo,ChequeNoNew,NationalIDNumber,AccOwnerName,AccountNo,ChequeDate,Amount
		, BT.BankTypeName,   pub.funGetLocationName(PD.LocationID,' + LTrim(Str(@LanguageID)) + ') AS BankCity				
		,CASE WHEN (PD.ProcessID IN (2, 13, 18, 24)) 
					THEN pub.GetCodeName(PD.DebitCode, ' + LTrim(Str(@LanguageID)) + ') 
					ELSE pub.GetBankName(PD.DebitCode, ' + LTRim(Str(@LanguageID)) + ') 
				END AS DebitName
		,CASE WHEN (PD.ProcessID IN (1, 10, 17, 18)) 
					THEN pub.GetCodeName(PD.CreditCode, ' + LTrim(Str(@LanguageID)) + ') 
					ELSE pub.GetBankName(PD.CreditCode, ' + LTRim(Str(@LanguageID)) + ') 
				END AS CreditName,RegChequeNoNewIN,RegChequeNoNewOut
		FROM	trs.tblPayDtl AS PD
				LEFT JOIN trs.tblBankTypesDtl AS BT ON
					BT.BankTypeID = PD.BankTypeID AND BT.LanguageID = ' + LTRim(Str(@LanguageID)) + '
				
		WHERE	1=1 and ' +@StrWhere

	if @OK<>@NotOk
	begin
		if @PayRecive=1
		begin
			if @OK= 1
				Set @StrSelect = @StrSelect  + ' and RegChequeNoNewIN=1 '
			if @NotOk= 1
				Set @StrSelect = @StrSelect  + ' and RegChequeNoNewIN=0 '
		end 
		else
		begin
			if @OK= 1
				Set @StrSelect = @StrSelect  + ' and RegChequeNoNewOut=1 '
			if @NotOk= 1
				Set @StrSelect = @StrSelect  + ' and RegChequeNoNewOut=0 '
		end 
	end

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

End

GO
