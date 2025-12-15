USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1402/02/31
-- Viewed By	 : 
-- Last Modified :
-- Last Modifier :
-- ----------------------------------------------
-- Description	 : گزارش مقایسه‌ای اسناد دريافتني پرداختني
-- ==============================================
Create PROCEDURE trs.SpRptTreasury_ReceivablePayable
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
	@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
As
Declare @StrWhere	NVarChar(max);
Declare @StrSelect	NVarChar(max);
 
Declare @StrPayTypeID		Varchar(10)
Declare @StrProcessID		Varchar(50)
Declare @inBank				bit
Begin   

	SET NoCount On;

	SET @inBank			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 

	SET @StrPayTypeID		= '6,26,7,8,28'  
	SET @StrProcessID		= '1,2,3,4,10,17,20,21,23,25'  

	Select @StrWhere = ' PD.PayTypeID IN (' + @StrPayTypeID + ') and  PD.ProcessID IN (' + @StrProcessID + ')'

	if @inBank='True'
		Select @StrWhere = @StrWhere + ' AND  (LST.ProcessID in ( 10,17,20,21,23,25) or (PD.ProcessID IN (1,3) and PD.PayTypeID IN (6,26)) or (PD.ProcessID IN (2,4) and PD.PayTypeID IN (7,8,28))  ) '
		 
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
		SET @StrWhere = @StrWhere + ' AND RTrim(PD.ChequeNo) >= ''' + RTrim(@ChequeNoFrom)  + ''''
	If	Not @ChequeNoTo Is Null 
		SET @StrWhere = @StrWhere + ' AND RTrim(PD.ChequeNo) <= ''' + RTrim(@ChequeNoTo)  + ''''

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
	SELECT	
		Distinct PD.PayTypeID,ltrim(str(PD.VolumeFiscalYear))+'/'+ltrim(str(PD.VolumeRowNo)) Volume
		,PD.VolumeFiscalYear,PD.VolumeRowNo,ChequeNo,ChequeNoNew,ChequeDate
		,LST.ProcessID ,LST.ProcessNo
		INto #PayDtl
		FROM	trs.tblPayDtl PD
				Inner JOIN (
							Select PDI.ProcessID,PDI.ProcessNo,PDI.PayTypeID,PDI.VolumeFiscalYear,PDI.VolumeRowNo
							From trs.tblPayDtl PDI
							Inner Join
								(
									SELECT VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo,PayTypeID
									FROM trs.tblPayDtl
									WHERE PayTypeID In (6,26,7,8,28) 			
									GROUP BY VolumeFiscalYear, VolumeRowNo,PayTypeID
								) VL on VL.VolumeFiscalYear=PDI.VolumeFiscalYear and VL.VolumeRowNo=PDI.VolumeRowNo and VL.EventNo=PDI.EventNo and VL.PayTypeID=PDI.PayTypeID
							Where PDI.PayTypeID In (6,26,7,8,28)
						  ) LST ON LST.ProcessNo=PD.ProcessNo and LST.PayTypeID=PD.PayTypeID and [LST].VolumeFiscalYear=PD.VolumeFiscalYear and [LST].VolumeRowNo=PD.VolumeRowNo --and [LST].EventNo=D.EventNo
		
		WHERE	1=1 and  PD.PayTypeID IN (6,26,7,8,2) and  PD.ProcessID IN (1,2,3,4,10,25) AND  LST.ProcessID in (1,2,3,4,10,17,20,21,23,25) 		 
		Order by PD.ChequeDate,VolumeFiscalYear,VolumeRowNo 

	Set @StrSelect = ' 
		select a.* 
			,( select  top 1 	    ltrim(str(PD.FiscalYear))+''/''+ltrim(str(PD.SerialNo)) from 	trs.tblPayDtl PD
					where  a.ProcessID=PD.ProcessID and  a.ProcessNo=PD.ProcessNo and a.PayTypeID=PD.PayTypeID and a.VolumeFiscalYear=PD.VolumeFiscalYear and a.VolumeRowNo=PD.VolumeRowNo 
					Order by DocDate  Desc, ChequeDate,VolumeFiscalYear,VolumeRowNo
			)
			FSSerialNo
		from (
		SELECT	Distinct PD.ProcessID,PD.ProcessNo,PD.PayTypeID,ltrim(str(PD.VolumeFiscalYear))+''/''+ltrim(str(PD.VolumeRowNo)) Volume
		--,ltrim(str(PD.FiscalYear))+''/''+ltrim(str(PD.SerialNo)) FSSerialNo
		--,PD.FiscalYear,PD.SerialNo
		,PD.VolumeFiscalYear,PD.VolumeRowNo,isnull(PD.ChequeNo ,'''') ChequeNo,isnull(PD.ChequeNoNew ,'''') ChequeNoNew,NationalIDNumber,AccOwnerName,AccountNo
		,isnull(PD.ChequeDate,'''')ChequeDate, BT.BankTypeName,   pub.funGetLocationName(PD.LocationID,' + LTrim(Str(@LanguageID)) + ') AS BankCity				
		, Case When PD.ProcessID in (1,3,10,21,23) then pub.GetCodeName(CreditCode, 1)  else pub.GetCodeName(DebitCode, 1) end AS CreditName 
		, isnull(Case When PD.ProcessID in (1,3,10,21,23) then pub.GetBankName(DebitCode, 1)  else pub.GetBankName(CreditCode, 1) end ,'''')AS BankName
		, isnull(Case When PD.ProcessID in (1,3,10,21,23) then Amount  else 0 end ,0)AS AmountReciveable
		, isnull(Case When PD.ProcessID in (1,3,10,21,23) then 0  else Amount end ,0) AS AmountPayable
		,DebitCode	,CreditCode, PD.BankTypeID,ProcessName,LST.ProcessID LSTProcessID
		FROM	trs.tblPayDtl PD
				Inner join #PayDtl LST
				ON LST.ProcessID=PD.ProcessID and  LST.ProcessNo=PD.ProcessNo and LST.PayTypeID=PD.PayTypeID and [LST].VolumeFiscalYear=PD.VolumeFiscalYear and [LST].VolumeRowNo=PD.VolumeRowNo 
			LEFT JOIN trs.tblBankTypesDtl AS BT ON BT.BankTypeID = PD.BankTypeID AND BT.LanguageID = ' + LTRim(Str(@LanguageID)) + '	
			left join pub.tblProcess p on PD.ProcessID=p.ProcessID and  PD.ProcessNo=p.ProcessNo
		WHERE	1=1 and ' +@StrWhere + '
		) a
		Order by ChequeDate,VolumeFiscalYear,VolumeRowNo '
			
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
