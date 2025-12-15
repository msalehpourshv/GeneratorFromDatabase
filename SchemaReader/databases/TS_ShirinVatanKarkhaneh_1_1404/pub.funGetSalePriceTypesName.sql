USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetSalePriceTypesName] 
(
	@SalePriceTypeID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Declare the return variable here
	DECLARE @SalePriceTypeName NVarChar(50)

	Set @SalePriceTypeName = N'-'

	SELECT @SalePriceTypeName = SalePriceTypeName 
	From sal.tblSalePriceTypesDtl 
	Where LanguageID = @LanguageID AND SalePriceTypeID = @SalePriceTypeID

	-- Return the result of the function
	RETURN @SalePriceTypeName 

END







GO
