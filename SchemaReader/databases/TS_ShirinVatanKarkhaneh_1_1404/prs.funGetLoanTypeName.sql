USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prs].[funGetLoanTypeName] 
(
	@LoanTypeID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @LoanTypeName NVarChar(50)

	Set @LoanTypeName = N'-'

	SELECT @LoanTypeName = LoanTypeName 
	From prs.tblLoanTypesDtl 
	Where LanguageID = @LanguageID AND LoanTypeID = @LoanTypeID

	-- Return the result of the function
	RETURN @LoanTypeName 

END
GO
