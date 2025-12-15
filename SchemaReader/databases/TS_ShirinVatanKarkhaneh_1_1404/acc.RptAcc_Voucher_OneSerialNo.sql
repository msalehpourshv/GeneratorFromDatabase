USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : Takrosystem\Zia
-- Create date   : 1391/07/11
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : < گزارش یک سند حسابداری >
-- =============================================
CREATE PROCEDURE [acc].[RptAcc_Voucher_OneSerialNo]
	@SerialNo	int
WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	DocRowNo, AcntCode, pub.GetCodeName(AcntCode,1) AcntName, Debit, Credit, RecDesc
	FROM	acc.tblVoucherDtl
	WHERE	SerialNo = @SerialNo
	ORDER BY DocRowNo
END
GO
