USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1388/05/24
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : کد یک نوع و مقدار عددی آنرا گرفته و عنوان آن را بر می گرداند
-- ==============================================
CREATE FUNCTION [pub].[funGetTypeText]
(
	@TypeID		Int,
	@TypeValue	NVarChar(500),
	@LanguageID	Int
)
RETURNS NVarChar(500)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Res NVarchar(500)
	SET @Res = @TypeValue
	
	SELECT @Res	= TypeText
	FROM pub.tblTypeValues
	WHERE TypeID = @TypeID AND LTrim(Str(TypeValue)) = LTrim(@TypeValue) AND LanguageID = @LanguageID
	
	RETURN @Res
END
GO
