USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [phr].[FunGetInsuranceTypeName]
(
	@InsuranceTypeID VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(50) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Declare @StrResult AS NVarChar(50)

	Select @StrResult = InsuranceTypeName
	From   phr.tblInsuranceTypeDtl
	Where  InsuranceTypeID = @InsuranceTypeID AND LanguageID = @LanguageID

	Return @StrResult

END -- ======================================================
GO
