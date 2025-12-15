USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [phr].[FunGetInsuranceName]
(
	@InsuranceID VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(50) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Declare @StrResult AS NVarChar(50)

	Select @StrResult = InsuranceName
	From   phr.tblInsuranceDtl
	Where  InsuranceID = @InsuranceID AND LanguageID = @LanguageID

	Return @StrResult

END -- ======================================================
GO
