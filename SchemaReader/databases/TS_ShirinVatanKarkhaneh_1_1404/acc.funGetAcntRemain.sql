USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [acc].[funGetAcntRemain]
(
	@AcntCode	VarChar(20),
	@AcntStart	TinyInt,
	@AcntLen	TinyInt
)
RETURNS BigInt
WITH ENCRYPTION
BEGIN -- === S T A R T ===========================================

	DECLARE @Result AS BigInt

	SELECT	@Result = IsNull(Sum(Debit - Credit), 0)
	FROM	acc.tblVoucherDtl
	WHERE	(VchKind <> 0) AND (Substring(AcntCode, @AcntStart, @AcntLen) = @AcntCode)
 
	RETURN @Result
END   -- === E N D ===============================================






















GO
