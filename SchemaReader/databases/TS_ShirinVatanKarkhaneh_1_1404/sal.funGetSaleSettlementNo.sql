USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sal].[funGetSaleSettlementNo]
(
	@BaseSaleFiscalYear Int = 96,
	@BaseSaleSerialNo	Int = 1
)
RETURNS INT
WITH ENCRYPTION            
AS
BEGIN

	Declare @SettlementNo Int

	-- ===========================================
	Select Top 1 @SettlementNo = D.SerialNo
	From trs.tblSettlementDtl D
	Where D.BaseSaleFiscalYear = @BaseSaleFiscalYear And D.BaseSaleSerialNo = @BaseSaleSerialNo

	-- ===========================================
	RETURN ISNULL(@SettlementNo, -1)

END	
GO
