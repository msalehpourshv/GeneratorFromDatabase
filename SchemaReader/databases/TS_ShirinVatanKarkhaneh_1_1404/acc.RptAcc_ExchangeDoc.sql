USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1392/02/09
-- Viewed By	 : 
-- Last Modified : 1392/02/09
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- =============================================
CREATE PROCEDURE [acc].[RptAcc_ExchangeDoc]
	@ProcessID		Int = 420,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null
WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;
	
	select	H.*, D.AcntCode, D.DocRowNo, D.CurrencyRemainAmount, D.ExchangeAmount, D.NativeRemainAmount, 
			pub.GetCodeName(D.AcntCode, 1) AcntName, pub.GetCodeName(H.ExchangeAcntCode, 1) ExchangeAcntName
	from	acc.tblAccExchangeDtl D
				inner join acc.tblAccExchangeHdr H on H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	WHERE 	D.ProcessID = @ProcessID AND D.ProcessNo = @ProcessNo AND
			D.FiscalYear >= @FiscalYear AND D.SerialNo >= @SerialNo AND
			D.FiscalYear <= @FiscalYearTo AND D.SerialNo <= @SerialNoTo
END
GO
