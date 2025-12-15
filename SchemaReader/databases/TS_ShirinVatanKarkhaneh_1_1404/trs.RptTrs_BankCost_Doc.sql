USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/03/02
-- Viewed By	 : 
-- Last Modified : 1388/10/09
-- Last Modifier : Ahmadnejad
-- Description	 : برگ هزینه بانکی
-- ==============================================
CREATE PROCEDURE [trs].[RptTrs_BankCost_Doc]
	@ProcessID		Int = 6,
	@ProcessNo		Int = 1,
	@FiscalYear		Int,
	@SerialNo		Int,
	@FiscalYearTo	Int,
	@SerialNoTo		Int,
	@LanguageID		TinyInt = 1
WITH ENCRYPTION
As
Begin   

	SET NoCount On;

	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;

	SELECT	D.*, H.DocDate, H.OurBankCode, H.VchNo, H.DescHdr, 
			BD.BankName, BD.BranchName, BD.BankAddress, BH.BranchCode, BH.BankAccountNo,
			pub.GetUserName(H.SessionNo) AS UserName,
			pub.GetCodeName(D.CostAcntCode, 1) CostAcntName
	FROM	trs.tblPettyCashDtl AS D
				INNER JOIN trs.tblPettyCashHdr AS H	ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
				LEFT  JOIN trs.tblOurBanksDtl AS BD ON H.OurBankCode = BD.BankCode AND BD.LanguageID = @LanguageID
				LEFT  JOIN trs.tblOurBanks AS BH ON H.OurBankCode = BH.BankCode
	WHERE	(H.ProcessID = @ProcessID) AND (H.ProcessNo = @ProcessNo) AND 
			(D.FiscalYear >= @FiscalYear) AND (D.SerialNo >= @SerialNo) AND
			(D.FiscalYear <= @FiscalYearTo) AND (D.SerialNo <= @SerialNoTo)
End
GO
