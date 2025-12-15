USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/19
-- Viewed By	 : 
-- Last Modified : 1393/05/22
-- Last Modifier : TakroSystem\Hamid
-- Description	 : <PettyCash Account>
-- ----------------------------------------------
-- یک شماره برگ مربوط به تنخواه
-- ==============================================
CREATE PROCEDURE [trs].[RptTrs_PettyCash_Doc]
	@ProcessID		Int = 5,
	@ProcessNo		Int = 1,
	@FiscalYear		Int,
	@SerialNo		Int,
	@FiscalYearTo	Int,
	@SerialNoTo		Int,
	@ExtraParams	NVarChar(200)
WITH ENCRYPTION
As
DECLARE @LanguageID Int
DECLARE @trs_PettyCashPrintWithConfirm BIT
BEGIN   -----------------  B E G I N   T O   C O D E  --------------------------

	SET @LanguageID = pub.funGetCurrentLanguageID();
	SET @trs_PettyCashPrintWithConfirm = 'False'

	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;

	SELECT @trs_PettyCashPrintWithConfirm = isnull(SettingValue, 0)
	FROM pub.tblSettings
	WHERE SettingKey = 'trs_PettyCashPrintWithConfirm'


	SELECT	D.*, H.OurBankCode, H.DocDate, H.Amount, H.VchNo, H.DescHdr,
			pub.GetBankName(H.OurBankCode, @LanguageID) OurBankName,
			pub.GetUserName(H.SessionNo) AS UserName,
			pub.GetCodeName(D.CostAcntCode, 1) AS CostAcntName1,
			[acc].[funPartAcntName](D.CostAcntCode,1) + ' ' + [acc].[funPartAcntName](D.CostAcntCode,2) CostAcntName,
			acc.funGetAcntFullName(D.CostAcntCode) As CostAcntFullName,
			pub.GetCodeName(pub.funSplitString(D.CostAcntCode, '', 1), 1) CostAcntName1
	FROM	trs.tblPettyCashDtl D
				INNER JOIN trs.tblPettyCashHdr H ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND	D.SerialNo = H.SerialNo
			
	WHERE	 H.ProcessID  = @ProcessID  AND H.ProcessNo = @ProcessNo AND
			(H.FiscalYear >= @FiscalYear) AND (H.SerialNo >= @SerialNo) AND
			(H.FiscalYear <= @FiscalYearTo) AND (H.SerialNo <= @SerialNoTo) AND
			(@trs_PettyCashPrintWithConfirm='False' OR H.DocStep=2)
	order by D.SerialNo,D.DocRowNo
END
GO
