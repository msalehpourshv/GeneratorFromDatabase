USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [acc].[funGetAcntName]
(
	@AcntCode AS VarChar(20),
	@AcntPart TinyInt,
	@LanguageID TinyInt
)
RETURNS NVarChar(250)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS NVarChar(250)

	SELECT	@Result = AcntName
	FROM	acc.tblAcntDtl
	WHERE	AcntCode = @AcntCode AND 
			PartNumber = @AcntPart AND 
			LanguageID = @LanguageID

	RETURN isnull(@Result,'')
END
GO
