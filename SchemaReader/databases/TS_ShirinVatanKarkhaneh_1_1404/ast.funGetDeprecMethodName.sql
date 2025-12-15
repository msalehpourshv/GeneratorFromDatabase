USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/11/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : شماره نوع استهلاک را گرفته و نام آنرا برمی گرداند
-- ==============================================
CREATE FUNCTION [ast].[funGetDeprecMethodName]
(
	@DeprecMethodID	TinyInt
)
RETURNS NVarChar(100)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @DeprecMethodName NVarChar(100)

	SELECT	@DeprecMethodName = 
		CASE @DeprecMethodID
			WHEN 1 THEN 'مستقیم'
			WHEN 2 THEN 'نزولی'
			WHEN 3 THEN 'بدون روش'
		END

	RETURN @DeprecMethodName
END
GO
