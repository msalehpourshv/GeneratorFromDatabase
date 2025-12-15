USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funProductSerialUsed]
(
	@ProductSerialID		BigInt
)
RETURNS Bit
WITH ENCRYPTION
AS
BEGIN

	RETURN (SELECT COUNT(*) from inv.tblStorageDocsSerials where ProductSerialID=@ProductSerialID)

END
GO
