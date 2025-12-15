USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/02/31
-- Viewed By	 : 
-- Last Modified : 1391/02/19
-- Description	 : <Payable Document Report>
-- ----------------------------------------------
-- گزارش برگ اسناد پرداختنی
-- ==============================================
Create PROCEDURE [trs].[RptPayableDoc] 
	@ProcessID		Int,
	@ProcessNo		Int = 1,
	@FiscalYear		Int,
	@SerialNo		Int,
	@FiscalYearTo	Int,
	@SerialNoTo		Int,
	@IncludeImage	Bit = 0, -- شامل تصویر سند باشد یا نه؟
	@LanguageID		TinyInt = 1

WITH ENCRYPTION
As
Declare @PT_Cheque		TinyInt
Declare @PT_Payable		TinyInt
Declare @PT_Payable_NonTrade TinyInt
Begin   

	Set NoCount On;

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;

	SELECT	@PT_Cheque	= 7				-- نوع دریافت و پرداخت = چک شرکت 
	SELECT	@PT_Payable = 8				-- اسناد پرداختنی تجاری
	SELECT	@PT_Payable_NonTrade = 28	-- اسناد پرداختنی غیر تجاری

	If @IncludeImage = 1
	Begin
		SELECT	PD.ProcessID, PD.ProcessNo, PD.FiscalYear, PD.SerialNo, PD.RowNo, PD.VolumeRowNo, PD.VolumeFiscalYear,
				PD.DocDate, PD.ChequeNo, PD.ChequeDate, PD.Amount, PD.RowDesc AS RecDesc,
				PH.DebitCode AS DebitCodeH, PD.DebitCode AS DebitCodeD,
				PH.CreditCode AS CreditCodeH, PD.CreditCode AS CreditCodeD,
				PH.VchNo, PH.DocDate AS DocDateH, PH.DescHdr AS DescH, 
				BD1.BankName AS BankNameH, 
				BD2.BankCode AS BankCodeD,
				pub.funGetLocationName(PD.LocationID,1) AS BankCity,
				PD.BranchCode AS BranchCodeD, PD.BranchName BranchNameD,
				pub.funGetLocationName(PD.LocationID,1) AS BankAddressD,
				pub.funGetBankTypeName(PD.BankTypeID,1) AS BankNameD,
				AccountNo BankAccountNo,				
				 DI.ImageContent,
				pub.GetCodeName(PH.DebitCode, @LanguageID) AS DebitNameH,
								case when PD.ProcessID in (28) then 
				pub.GetBankName(PD.DebitCode, @LanguageID) 
				else
				pub.GetCodeName(PD.DebitCode, @LanguageID) 
				end AS DebitNameD,

				pub.GetCodeName(PD.CreditCode, @LanguageID) AS CreditNameD,
				pub.GetUserName(PH.SessionNo) AS UserName,
				pub.GetUserName(PH.SessionNo1) AS UserName1,
				 PD.DocRowNo,
				pub.GetCodeName(isnull((select DebitCode from trs.tblPayDtl X where X.VolumeFiscalYear = PD.VolumeFiscalYear and X.VolumeRowNo = PD.VolumeRowNo and X.PayTypeID = PD.PayTypeID and X.EventNo = PD.EventNo - 1),''),1) CustomerName
		FROM  trs.tblPayDtl AS PD 
				INNER JOIN trs.tblPayHdr AS PH ON PD.ProcessID = PH.ProcessID AND PD.ProcessNo = PH.ProcessNo AND PD.FiscalYear = PH.FiscalYear AND  PD.SerialNo = PH.SerialNo 
				LEFT JOIN trs.tblOurBanksDtl AS BD1	ON PD.CreditCode = BD1.BankCode AND BD1.LanguageID = @LanguageID
				LEFT JOIN trs.tblBankChequesDtl AS BC ON  BD1.BankCode = BC.BankCode and PD.ChequeBookID = BC.ChequeBookID AND PD.ChequeNo >= BC.FromChequeNo AND PD.ChequeNo <= BC.ToChequeNo
				LEFT JOIN trs.tblOurBanksDtl AS BD2	ON BC.BankCode = BD2.BankCode AND BD2.LanguageID = @LanguageID
				LEFT JOIN trs.tblOurBanks AS B ON BD2.BankCode = B.BankCode
				LEFT JOIN pub.tblDocsImages DI ON PD.ProcessID = DI.ProcessID AND PD.ProcessNo = DI.ProcessNo AND PD.FiscalYear = DI.FiscalYear AND  PD.SerialNo = DI.SerialNo AND PD.RowNo = DI.RowNo
		WHERE	PH.ProcessID  = @ProcessID  AND PH.ProcessNo  = @ProcessNo AND 
				PayTypeID IN (@PT_Cheque, @PT_Payable, @PT_Payable_NonTrade) AND
				(PD.FiscalYear >= @FiscalYear) AND (PD.SerialNo >= @SerialNo) AND
				(PD.FiscalYear <= @FiscalYearTo) AND (PD.SerialNo <= @SerialNoTo)
		ORDER BY PD.DocRowNo
	End
	Else
	Begin
		SELECT	PD.ProcessID, PD.ProcessNo, PD.FiscalYear, PD.SerialNo, PD.RowNo, PD.VolumeRowNo, PD.VolumeFiscalYear,
				PD.DocDate, PD.ChequeNo, PD.ChequeDate, PD.Amount, PD.RowDesc AS RecDesc,
				PH.DebitCode AS DebitCodeH, PD.DebitCode AS DebitCodeD,
				PH.CreditCode AS CreditCodeH, PD.CreditCode AS CreditCodeD,
				PH.VchNo, PH.DocDate AS DocDateH, PH.DescHdr AS DescH, 
				BD1.BankName AS BankNameH, 
				BD2.BankCode AS BankCodeD, 
				pub.funGetLocationName(PD.LocationID,1) AS BankCity,
				PD.BranchCode AS BranchCodeD, PD.BranchName BranchNameD,
				pub.funGetLocationName(PD.LocationID,1) AS BankAddressD,
				pub.funGetBankTypeName(PD.BankTypeID,1) AS BankNameD,
				AccountNo BankAccountNo,
				Cast(Null AS Image) AS ImageContent,
				pub.GetCodeName(PH.DebitCode, @LanguageID) AS DebitNameH,
				case when PD.ProcessID in (28) then 
				pub.GetBankName(PD.DebitCode, @LanguageID) 
				else
				pub.GetCodeName(PD.DebitCode, @LanguageID) 
				end AS DebitNameD,
				pub.GetCodeName(PD.CreditCode, @LanguageID) AS CreditNameD,
				pub.GetUserName(PH.SessionNo) AS UserName,
				pub.GetUserName(PH.SessionNo1) AS UserName1,
				 PD.DocRowNo,
				pub.GetCodeName(isnull((select DebitCode from trs.tblPayDtl X where X.VolumeFiscalYear = PD.VolumeFiscalYear and X.VolumeRowNo = PD.VolumeRowNo and X.PayTypeID = PD.PayTypeID and X.EventNo = PD.EventNo - 1),''),1) CustomerName
		FROM  trs.tblPayDtl AS PD 
				INNER JOIN trs.tblPayHdr AS PH ON PD.ProcessID = PH.ProcessID AND PD.ProcessNo = PH.ProcessNo AND PD.FiscalYear = PH.FiscalYear AND  PD.SerialNo = PH.SerialNo 
				LEFT JOIN trs.tblOurBanksDtl AS BD1	ON PD.CreditCode = BD1.BankCode AND BD1.LanguageID = @LanguageID
				LEFT JOIN trs.tblBankChequesDtl AS BC ON  BD1.BankCode = BC.BankCode and PD.ChequeBookID = BC.ChequeBookID AND PD.ChequeNo >= BC.FromChequeNo AND PD.ChequeNo <= BC.ToChequeNo
				LEFT JOIN trs.tblOurBanksDtl AS BD2	ON BC.BankCode = BD2.BankCode AND BD2.LanguageID = @LanguageID
				LEFT JOIN trs.tblOurBanks AS B ON BD2.BankCode = B.BankCode
		WHERE	PH.ProcessID  = @ProcessID  AND PH.ProcessNo  = @ProcessNo AND PayTypeID IN (@PT_Cheque, @PT_Payable, @PT_Payable_NonTrade) AND (PD.FiscalYear >= @FiscalYear) AND (PD.SerialNo >= @SerialNo) AND (PD.FiscalYear <= @FiscalYearTo) AND (PD.SerialNo <= @SerialNoTo)
		ORDER BY PD.DocRowNo
	End
End
GO
