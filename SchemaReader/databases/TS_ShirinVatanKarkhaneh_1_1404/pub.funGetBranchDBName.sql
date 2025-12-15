USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetBranchDBName]
(
)
	RETURNS  NVarChar(50) 
WITH ENCRYPTION
AS

BEGIN

	Return LEFT(db_name(), Len(db_name()) - 4) + '0000'

END











GO
