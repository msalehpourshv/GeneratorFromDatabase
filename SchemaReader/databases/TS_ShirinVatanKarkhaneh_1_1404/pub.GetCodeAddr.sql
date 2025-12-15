USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[GetCodeAddr]
(
	@AcntCode VarChar(20)
)
RETURNS NVarChar(200)
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

 Return N'Adress of AcntCode';

End   -- === E N D ===============================================










GO
