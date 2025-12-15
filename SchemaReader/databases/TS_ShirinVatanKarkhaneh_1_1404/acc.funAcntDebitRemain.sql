USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Creation date : 1388/02/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : مانده بدهکاری یک حساب
-- =============================================
CREATE FUNCTION [acc].[funAcntDebitRemain]
(
	@FullAcntCode VarChar(20)
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS float

	SELECT	@Result = IsNull(Sum(Debit-Credit), 0)
	FROM	acc.tblVoucherDtl
	WHERE	(VchKind <> 0) AND (AcntCode LIKE @FullAcntCode)

	RETURN @Result
END
GO
