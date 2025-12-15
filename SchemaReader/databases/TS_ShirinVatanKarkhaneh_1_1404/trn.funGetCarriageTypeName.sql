USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trn].[funGetCarriageTypeName] 
(
	@CarriageTypeID VARCHAR(20),
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @CarriageTypeName NVarChar(50)

	Set @CarriageTypeName = N'-'

	SELECT @CarriageTypeName = CarriageTypeName
	From trn.tblCarriageTypesDtl
	Where LanguageID = @LanguageID AND CarriageTypeID = @CarriageTypeID

	-- Return the result of the function
	RETURN @CarriageTypeName 

END














GO
