USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [qty].[funGetExaminationName]
(
	@ExaminationID		Varchar(20),
	@LanguageID	TinyInt
)
RETURNS Nvarchar(50)
WITH ENCRYPTION
AS
BEGIN
	
	DECLARE @ResultVar Nvarchar(50)

	SELECT @ResultVar = ExaminationName 
	FROM	qty.tblExaminationsDtl 
	WHERE ExaminationID = @ExaminationID AND LanguageID = @LanguageID

	RETURN @ResultVar

END
GO
