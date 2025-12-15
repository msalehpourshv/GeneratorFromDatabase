USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [qty].[FunGetResultType]
(
	@TestID		Varchar(20)
)
RETURNS Tinyint
WITH ENCRYPTION
AS
BEGIN
	DECLARE @ResultVar Tinyint

	SELECT @ResultVar = ResultType
	FROM qty.tblTests
	WHERE TestID = @TestID 

	RETURN @ResultVar
END
GO
