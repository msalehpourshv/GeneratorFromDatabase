USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sal].[funGetCustomerKindName]
(
	@CustomerKindID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @CustomerKindName NVarChar(50)

	Set @CustomerKindName = N'-'

	SELECT @CustomerKindName = CustomerKindName 
	From  sal.tblCustomerKindsDtl
	Where LanguageID = @LanguageID AND CustomerKindID = @CustomerKindID

	-- Return the result of the function
	RETURN @CustomerKindName 

END
GO
