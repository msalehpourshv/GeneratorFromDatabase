USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/02/30
-- Viewed By	 : 
-- Last Modified : 1386/08/28
-- Description	 : <Pays And Receipts Report>
-- ----------------------------------------------
-- گزارش دریافتها و پرداختها - تفصیلی
-- ==============================================
CREATE PROCEDURE [trs].[RptPayReceiptDocs_Exp]
	@ProcessID			Int = 0, /* 0 = [1,2]; 1 = Receipt; 2 = Payment; 3 = ReceiptMisc; 4 = PayMisc; */
	@ProcessID2			Int = 0, /* 0 = [1,2]; 1 = Receipt; 2 = Payment; 3 = ReceiptMisc; 4 = PayMisc; */
	@ProcessNo			Int = 1,
	@DebitCode			VarChar(20) = Null,
	@CreditCode			VarChar(20) = Null,
	@SerialNoFrom		Int = Null,
	@SerialNoTo			Int = Null,
	@DateFrom			VarChar(20) = Null,
	@DateTo				VarChar(20) = Null,
	@UsanceDateFrom		VarChar(20) = Null, -- از تاریخ سررسید
	@UsanceDateTo		VarChar(20) = Null, -- تا تاریخ سررسید
	@AmountFrom			BigInt = Null,
	@AmountTo			BigInt = Null,
	@OrderNoFrom		VarChar(20) = Null, -- از شماره چک یا فیش
	@OrderNoTo			VarChar(20) = Null, -- تا شماره چک یا فیش
	@DescMask			NVarChar(100)= Null, -- جزئی از شرح سند دریافت یا پرداخت
	@SortFields			NVarChar(100)= Null,
	@LanguageID			TinyInt = 1
WITH ENCRYPTION
As
Declare @StrSelect	NVarChar(3000)
Declare @StrFrom	NVarChar(1000)
Begin -- ======================= S T A R T   C O D E =========================================

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Init -----------------------------------------------------------------------------------
	Set NoCount On;

	If (@ProcessNo  Is Null) Set @ProcessNo  = 1
	If	(@LanguageID Is Null) Set @LanguageID = 1
	If (@SortFields Is Null) Set @SortFields = 'SerialNo, ProcessID'
	--------------------------------------------------------------------------------------------
	-- S E L E C T -----------------------------------------------------------------------------
	Set @StrSelect = '
	SELECT PD.ProcessID, PD.FiscalYear, PD.SerialNo, PD.PayTypeID, PD.Amount, PD.RowDesc, PD.DocDate, 
			 PD.BranchCode,  PD.BranchName,  PD.AccountNo,  PD.DebitCode,  PD.AccOwnerName, PD.ChequeNo, 
	 	 	 PD.BranchCode2, PD.BranchName2, PD.AccountNo2, PD.CreditCode, PD.AccOwnerName2, PD.ChequeDate, 
			 PH.DebitCode AS DebitCodeHdr, PH.CreditCode AS CreditCodeHdr, PH.VchNo, PH.DescHdr, PD.VolumeRowNo, 
			 Case When (PH.ProcessID = 1) Then pub.GetBankName(PH.DebitCode, ' + LTRim(Str(@LanguageID)) + ') Else pub.GetCodeName(PH.DebitCode, ' + LTRim(Str(@LanguageID)) + ')  End AS DebtorNameHdr,
			 Case When (PH.ProcessID = 2) Then pub.GetBankName(PH.CreditCode,' + LTRim(Str(@LanguageID)) + ') Else pub.GetCodeName(PH.CreditCode, ' + LTRim(Str(@LanguageID)) + ') End AS CreditorNameHdr,
			 Case When (PD.ProcessID = 1) Then pub.GetBankName(PD.DebitCode, ' + LTRim(Str(@LanguageID)) + ') Else pub.GetCodeName(PD.DebitCode, ' + LTRim(Str(@LanguageID)) + ')  End AS DebtorName,
			 Case When (PD.ProcessID = 2) Then pub.GetBankName(PD.CreditCode,' + LTRim(Str(@LanguageID)) + ') Else pub.GetCodeName(PD.CreditCode, ' + LTRim(Str(@LanguageID)) + ') End AS CreditorName,
			 [pub].[GetUserName](PH.SessionNo1) AS UserName, PD.RowNo, LD.LocationName,
			 pub.funGetBankTypeName(PD.BankTypeID,  ' + LTRim(Str(@LanguageID)) + ') AS DebitBankTypeName,
			 pub.funGetBankTypeName(PD.BankTypeID2, ' + LTrim(Str(@LanguageID)) + ') AS CreditBankTypeName
	FROM	 trs.tblPayDtl PD 
			 INNER JOIN trs.tblPayHdr AS PH ON
			 	PD.ProcessID  = PH.ProcessID  AND PD.ProcessNo = PH.ProcessNo AND
			 	PD.FiscalYear = PH.FiscalYear AND PD.SerialNo  = PH.SerialNo
			 LEFT JOIN pub.tblLocationsDtl AS LD ON
				PD.LocationID2 = LD.LocationID AND LD.LanguageID = ' + LTrim(Str(@LanguageID)) + '
	WHERE	 PD.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If	(@ProcessID > 0)
		Set @StrSelect = @StrSelect + ' AND PD.ProcessID = ' + LTrim(Str(@ProcessID))
	Else
		Set @StrSelect = @StrSelect + ' AND PD.ProcessID < 3'
	
	If	Not @DebitCode Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.DebitCode) = ''' + RTRim(@DebitCode) + ''''
	If	Not @CreditCode Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.CreditCode) = ''' + RTrim(@CreditCode) + ''''

	If	Not @SerialNoFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.SerialNo >= ' + Str(@SerialNoFrom)
	If	Not @SerialNoTo Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.SerialNo <= ' + Str(@SerialNoTo) 

	If	Not @UsanceDateFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeDate) >= ''' + RTrim(@UsanceDateFrom) + ''''
	If	Not @UsanceDateTo Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeDate) <= ''' + RTrim(@UsanceDateTo) + ''''

	If	Not @DateFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.DocDate) >= ''' + RTrim(@DateFrom) + ''''
	If	Not @DateTo Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.DocDate) <= ''' + RTrim(@DateTo) + ''''

	If	Not @AmountFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.Amount >= ' + Str(@AmountFrom)
	If	Not @AmountTo Is Null 
		Set @StrSelect = @StrSelect + ' AND PD.Amount <= ' + Str(@AmountTo)

	If	Not @OrderNoFrom Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeNo) >= ''' + RTrim(@OrderNoFrom) + ''''
	If	Not @OrderNoTo Is Null 
		Set @StrSelect = @StrSelect + ' AND RTrim(PD.ChequeNo) <= ''' + RTrim(@OrderNoTo) + ''''

	If (@DescMask Is Not Null)
		Set @StrSelect = @StrSelect + ' AND (Replace(PH.DescHdr, '' '', '''') LIKE N''%' + RTrim(Replace(@DescMask, ' ', '')) + '%'')' -- OR
--                                           Replace(PH.DescHdr, '' '', '''') LIKE  ''%' + RTrim(Replace(@DescMask, ' ', '')) + '%'' )'
	-- Sort ------------------------------------------------------------------------------------
	Set @StrSelect = @StrSelect + ' ORDER BY ' + @SortFields
	--------------------------------------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End










GO
