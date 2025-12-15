USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetCurrencyTypesName] 
(
	@CurrencyTypeID VARCHAR(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Declare the return variable here
	DECLARE @CurrencyTypesName NVarChar(50)

	Set @CurrencyTypesName = '-'

	SELECT @CurrencyTypesName = CurrencyTypeName 
	From pub.tblCurrencyTypesDtl 
	Where LanguageID=@LanguageID AND CurrencyTypeID=@CurrencyTypeID

	-- Return the result of the function
	RETURN @CurrencyTypesName 

END









GO
