USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1388/02/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   :  
-- =============================================
CREATE FUNCTION [pub].[UN]
(
	@SessionNo int
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ResultVar AS NVarChar(50)

	SELECT @ResultVar = pub.funGetUserName(@SessionNo, Substring(db_name(), 1, Len(db_name()) - 4) + '0000')

	RETURN @ResultVar
END
GO
