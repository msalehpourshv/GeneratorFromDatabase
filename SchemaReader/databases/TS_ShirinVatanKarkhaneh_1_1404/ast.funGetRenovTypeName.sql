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
-- Description	 : شماره نوع تعمیر را گرفته و نام آنرا برمی گرداند
-- ==============================================
CREATE FUNCTION [ast].[funGetRenovTypeName] 
(
	@RenovTypeID TinyInt
)
RETURNS NVarChar(100)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @DeprecMethodName NVarChar(100)

	-- Get Last EventID
	SELECT	@DeprecMethodName = 
		CASE @RenovTypeID
			WHEN 1 THEN 'افزایش'
			WHEN 2 THEN 'گسترش و الحاق'
			WHEN 3 THEN 'هزینه'			
		END

	RETURN @DeprecMethodName
END
GO
