USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/03/02
-- Viewed By	 : 
-- Last Modified : 1388/10/10
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : <Receivable Document Report>
-- ----------------------------------------------
-- گزارش برگ اسناد دریافتنی
-- ==============================================
Create PROCEDURE [trs].[RptReceivableDoc]
	@ProcessID			Int,
	@ProcessNo			Int = 1,
	@FiscalYear			Int,
	@SerialNo			Int,
	@FiscalYearTo		Int,
	@SerialNoTo			Int,
	@IncludeImage		Bit = 0, -- شامل تصویر سند باشد یا نه؟
	@DebtorType			Char = 'A', -- کد حسابداری است یا کد بانک
	@CreditorType		Char = 'A', -- کد حسابداری است یا کد بانک
	@LanguageID			TinyInt = 1,
	@ExtraParams		NVarChar(255) = Null
WITH ENCRYPTION
As
Begin   

	SET NOCOUNT ON;

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	IF (@DebtorType Is Null)	SET @DebtorType = 'A';
	IF (@CreditorType Is Null)	SET @CreditorType = 'A';
	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@IncludeImage Is Null)	SET @IncludeImage = 0;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;

	If @IncludeImage = 1
	Begin
		SELECT	PD.*, 
				PH.VchNo, 
				PH.DescHdr,
				BTD.BankTypeName, 
				LD.LocationName, 
				DI.ImageContent ImageContent,
				pub.GetCodeName(PD.DebitCode, @LanguageID) AS DebitNameA,
				pub.GetCodeName(PD.CreditCode, @LanguageID) AS CreditNameA,
				pub.GetBankName(PD.DebitCode, @LanguageID) AS DebitNameB,
				pub.GetBankName(PD.CreditCode, @LanguageID) AS CreditNameB,
				BH.BranchCode AS BranchCode3,
				BH.BankAccountNo, 
				BD.BankName, 
				BD.BranchName AS BranchName3, 
				BD.AccountOwnerName, 
				pub.GetUserName(PH.SessionNo) AS UserName,
				pub.GetUserName(PH.SessionNo1) AS UserName1,
				CASE WHEN PayTypeID in (7,8,18,28) THEN [trs].[funGetPayChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) ELSE [trs].[funGetChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) END FirstCreditCode ,
				[pub].[GetCodeName](CASE WHEN PayTypeID in (7,8,18,28) THEN [trs].[funGetPayChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) ELSE [trs].[funGetChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) END,@LanguageID) FirstCreditName
		FROM	trs.tblPayHdr AS PH 
					INNER JOIN trs.tblPayDtl PD       ON PD.ProcessID = PH.ProcessID AND PD.ProcessNo = PH.ProcessNo AND PD.FiscalYear = PH.FiscalYear AND PD.SerialNo = PH.SerialNo
					LEFT JOIN trs.tblBankTypesDtl BTD ON BTD.BankTypeID = PD.BankTypeID AND BTD.LanguageID = @LanguageID
					LEFT JOIN pub.tblLocationsDtl LD  ON LD.LocationID = PD.LocationID AND LD.LanguageID = @LanguageID
					LEFT JOIN pub.tblDocsImages DI    ON PD.ProcessID = DI.ProcessID AND PD.ProcessNo = DI.ProcessNo AND PD.FiscalYear = DI.FiscalYear AND PD.SerialNo = DI.SerialNo AND PD.RowNo = DI.RowNo
					LEFT JOIN trs.tblOurBanks BH      ON BH.BankCode = PD.DebitCode
					LEFT JOIN trs.tblOurBanksDtl BD   ON BD.BankCode = PD.DebitCode AND BD.LanguageID = @LanguageID
		WHERE	(PD.ProcessID = @ProcessID) AND (PD.ProcessNo = @ProcessNo) AND 
				(PD.FiscalYear >= @FiscalYear) AND (PD.SerialNo >= @SerialNo) AND
				(PD.FiscalYear <= @FiscalYearTo) AND (PD.SerialNo <= @SerialNoTo) AND
				(PD.PayTypeID IN (6, 26,18))
		ORDER BY PD.DocRowNo
	END
	ELSE
	BEGIN
		SELECT	PD.*, 
				PH.VchNo, 
				PH.DescHdr,
				BTD.BankTypeName, 
				LD.LocationName, 
				Null AS ImageContent,
				pub.GetCodeName(PD.DebitCode, @LanguageID) AS DebitNameA,
				pub.GetCodeName(PD.CreditCode, @LanguageID) AS CreditNameA,
				pub.GetBankName(PD.DebitCode, @LanguageID) AS DebitNameB,
				pub.GetBankName(PD.CreditCode, @LanguageID) AS CreditNameB,
				BH.BranchCode AS BranchCode3, 
				BH.BankAccountNo, 
				BD.BankName, 
				BD.BranchName AS BranchName3, 
				BD.AccountOwnerName,
				pub.GetUserName(PH.SessionNo) AS UserName,
				pub.GetUserName(PH.SessionNo1) AS UserName1,
				CASE WHEN PayTypeID in (7,8,18,28) THEN [trs].[funGetPayChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) ELSE [trs].[funGetChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) END FirstCreditCode ,
				[pub].[GetCodeName](CASE WHEN PayTypeID in (7,8,18,28) THEN [trs].[funGetPayChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) ELSE [trs].[funGetChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) END,@LanguageID) FirstCreditName
		FROM	trs.tblPayHdr AS PH 
					INNER JOIN trs.tblPayDtl PD       ON PD.ProcessID = PH.ProcessID AND PD.ProcessNo = PH.ProcessNo AND PD.FiscalYear = PH.FiscalYear AND PD.SerialNo = PH.SerialNo
					LEFT JOIN trs.tblBankTypesDtl BTD ON BTD.BankTypeID = PD.BankTypeID AND BTD.LanguageID = @LanguageID
					LEFT JOIN pub.tblLocationsDtl LD  ON LD.LocationID = PD.LocationID AND LD.LanguageID = @LanguageID
					LEFT JOIN pub.tblDocsImages DI    ON PD.ProcessID = DI.ProcessID AND PD.ProcessNo = DI.ProcessNo AND PD.FiscalYear = DI.FiscalYear AND PD.SerialNo = DI.SerialNo AND PD.RowNo = DI.RowNo
					LEFT JOIN trs.tblOurBanks BH      ON BH.BankCode = PD.DebitCode
					LEFT JOIN trs.tblOurBanksDtl BD   ON BD.BankCode = PD.DebitCode AND BD.LanguageID = @LanguageID
		WHERE	(PD.ProcessID = @ProcessID) AND (PD.ProcessNo = @ProcessNo) AND 
				(PD.FiscalYear >= @FiscalYear) AND (PD.SerialNo >= @SerialNo) AND
				(PD.FiscalYear <= @FiscalYearTo) AND (PD.SerialNo <= @SerialNoTo) AND
				(PD.PayTypeID IN (6, 26,18))
		ORDER BY PD.DocRowNo
	End
End
GO
