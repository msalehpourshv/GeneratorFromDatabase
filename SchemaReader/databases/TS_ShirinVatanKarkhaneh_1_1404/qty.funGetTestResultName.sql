USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [qty].[funGetTestResultName]
(
	@TestResultID	Varchar(20),
	@LanguageID		Tinyint
)
RETURNS Varchar(50)
WITH ENCRYPTION
AS
BEGIN
	
	DECLARE @ResultVar Varchar(50)

	SELECT @ResultVar = TestResultName
	FROM qty.tblTestResultsDtl
	WHERE TestResultID = @TestResultID AND @LanguageID=LanguageID

	RETURN @ResultVar

END

GO
