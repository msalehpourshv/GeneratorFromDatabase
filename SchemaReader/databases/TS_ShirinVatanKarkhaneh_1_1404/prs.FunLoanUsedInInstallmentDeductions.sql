USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/6/07
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [prs].[FunLoanUsedInInstallmentDeductions]
(
	@PersonnelID Varchar(20),
	@LoanTypeID  Varchar(20),
	@ReceiptDate Varchar(20)
)
RETURNS BIT 
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Resault BIT

	SET @Resault = 'False'

	SELECT TOP 1 @Resault='True' FROM prs.tblInstallmentDeductionsDtl
	WHERE PersonnelID=@PersonnelID AND LoanTypeID=@LoanTypeID AND ReceiptDate=@ReceiptDate

	RETURN @Resault
END





GO
