USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetSaleTypesName] 
(
	@SaleTypeID VARCHAR(20),
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @SaleTypeName NVarChar(50)

	Set @SaleTypeName = N'-'

	SELECT @SaleTypeName = SaleTypeName
	From sal.tblSaleTypesDtl
	Where LanguageID = @LanguageID AND SaleTypeID = @SaleTypeID

	-- Return the result of the function
	RETURN @SaleTypeName 

END














GO
