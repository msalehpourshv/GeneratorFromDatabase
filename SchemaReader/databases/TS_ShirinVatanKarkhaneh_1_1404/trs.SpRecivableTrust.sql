USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Sadeghi
-- Create date   : 1391/08/15
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE [trs].[SpRecivableTrust] 
	@DocDate			Char(10) = Null, -- تاریخ 
	@languageID			Char(10) = Null
WITH ENCRYPTION
As
BEGIN
SELECT D.*, BH.AcntCode2, BH.BankCode, BD.BankName, BD.BankAddress, 2 AS ChequeState, LD.LocationName,
				0 AS DateDuration,
				pub.GetCodeName(D.DebitCode, @languageID) AS DebitName, 
				pub.GetCodeName(D.CreditCode, @languageID) AS CreditName,
				pub.GetBankName(D.DebitCode, @languageID) AS DebitNameB, 
				pub.GetBankName(D.CreditCode, @languageID) AS CreditNameB,
				BT.BankTypeName FROM trs.tblPayDtl D
INNER JOIN (
	SELECT VolumeFiscalYear,VolumeRowNo,ChequeNo,Amount FROM trs.tblPayDtl
	WHERE ProcessID=31
	EXCEPT
	SELECT VolumeFiscalYear,VolumeRowNo,ChequeNo,Amount FROM trs.tblPayDtl
	WHERE ProcessID=32
			) A
ON A.VolumeFiscalYear = D.VolumeFiscalYear AND A.VolumeRowNo = D.VolumeRowNo
LEFT JOIN trs.tblOurBanks AS BH ON BH.BankCode = D.CreditCode  
LEFT JOIN trs.tblOurBanksDtl AS BD ON BH.BankCode = BD.BankCode 
LEFT JOIN pub.tblLocationsDtl AS LD ON LD.LocationID = D.LocationID AND LD.LanguageID = @languageID
LEFT JOIN trs.tblBankTypesDtl BT ON D.BankTypeID = BT.BankTypeID AND BT.LanguageID = @languageID
where D.ProcessID=31 AND ( (D.ChequeDate <>'' and D.ChequeDate<=@DocDate) or  (D.EndDate_PayableTrust <>'' and D.EndDate_PayableTrust<=@DocDate) or (D.ChequeDate='' and D.EndDate_PayableTrust=''))
order by FiscalYear,	SerialNo,	RowNo,VolumeFiscalYear,VolumeRowNo

END
GO
