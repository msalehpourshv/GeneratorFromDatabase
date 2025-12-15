USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/05/08
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ----------------------------------------------
-- جمع اسناد پرداختنی وصول نشده یک بانک
-- ==============================================
CREATE FUNCTION [trs].[funPayableDocs_UnReceipt]
(
	@BankCode	AS VarChar(20),
	@DocDate	AS VarChar(10)
)
RETURNS float
WITH ENCRYPTION
As
Begin 
	DECLARE @Res AS float;

	SELECT	@Res = IsNull(Sum(D.Amount), 0)
	FROM	trs.tblPayDtl AS D 
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
			ON A.VolumeFiscalYear = D.VolumeFiscalYear AND A.VolumeRowNo = D.VolumeRowNo 
	WHERE	PayTypeID IN(8, 28) AND 
			D.ProcessID = 2 AND 
			D.CreditCode = @BankCode

	RETURN @Res;
End
GO
