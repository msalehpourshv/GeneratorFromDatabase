USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : Takrosystem\Zia
-- Create date   : 1386/12/19
-- Viewed By	 : 
-- Last Modified : 1393/06/06
-- Description	 : < دفتر حسابداری یک کد حسابداری >
-- =============================================
CREATE PROCEDURE [acc].[RptAcc_AccountingBook_OneCode]
	@FullAcntCode	VarChar(20),
	@SerialNoFr		int = 0,
	@SerialNoTo		int = 999999,
	@DocDateFr		char(10) = '0000/00/00',
	@DocDateTo		char(10) = '9999/99/99'
WITH ENCRYPTION
AS
BEGIN

	SET NOCOUNT ON;

	SELECT	DocDate, SerialNo, Debit, Credit, RecDesc
	FROM	acc.tblVoucherDtl
	WHERE (VchKind <> 0) 
		and (Left(AcntCode, LEN(@FullAcntCode)) = @FullAcntCode)
		and (SerialNo >= @SerialNoFr) 
		and (SerialNo <= @SerialNoTo)
		and (DocDate >= @DocDateFr) 
		and (DocDate <= @DocDateTo)
	ORDER BY DocDate, SerialNo, (Case When (Credit=0) Then 1 Else 2 End)
END
GO
