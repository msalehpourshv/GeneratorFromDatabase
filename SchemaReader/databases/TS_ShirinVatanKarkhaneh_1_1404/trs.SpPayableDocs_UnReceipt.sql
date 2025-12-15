USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 87/05/10
-- Viewed By	 : 
-- Last Modified : 87/05/12
-- Description	 : 
-- ----------------------------------------------
-- جمع اسناد پرداختنی وصول نشده یک بانک
-- ==============================================
CREATE PROCEDURE [trs].[SpPayableDocs_UnReceipt]
	@BankCode	AS VarChar(20),
	@DocDate	AS VarChar(10)
WITH ENCRYPTION
As
DECLARE @StrSelect	AS NVarChar(4000)
Begin 
	
	if (@BankCode is null) or (@BankCode = '')
		SELECT	IsNull(Sum(PD.Amount), 0)
		FROM	trs.tblPayDtl AS PD 
				INNER JOIN
				(
					SELECT	VolumeFiscalYear, VolumeRowNo
					FROM	trs.tblPayDtl
					WHERE	PayTypeID IN(8, 28) AND ProcessID = 2 AND ChequeDate <= @DocDate
					EXCEPT  
					SELECT	VolumeFiscalYear, VolumeRowNo
					FROM	trs.tblPayDtl
					WHERE	PayTypeID IN(8, 28) AND ProcessID IN (27, 28)
				)	AS A
				ON A.VolumeFiscalYear = PD.VolumeFiscalYear AND A.VolumeRowNo = PD.VolumeRowNo 
		WHERE	PayTypeID IN(8, 28) AND PD.ProcessID = 2 
	else	
		SELECT	IsNull(Sum(PD.Amount), 0)
		FROM	trs.tblPayDtl AS PD 
				INNER JOIN
				(
					SELECT	VolumeFiscalYear, VolumeRowNo
					FROM	trs.tblPayDtl
					WHERE	PayTypeID IN(8, 28) AND ProcessID = 2 AND ChequeDate <= @DocDate
					EXCEPT  
					SELECT	VolumeFiscalYear, VolumeRowNo
					FROM	trs.tblPayDtl
					WHERE	PayTypeID IN(8, 28) AND ProcessID IN (27, 28)
				)	AS A
				ON A.VolumeFiscalYear = PD.VolumeFiscalYear AND A.VolumeRowNo = PD.VolumeRowNo 
		WHERE	PayTypeID IN(8, 28) AND PD.ProcessID = 2 AND 
				PD.CreditCode = @BankCode
End
GO
