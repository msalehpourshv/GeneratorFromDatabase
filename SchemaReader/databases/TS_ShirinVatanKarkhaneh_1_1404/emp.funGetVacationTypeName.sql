USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [emp].[funGetVacationTypeName]
(
	@VacationTypeID VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(50) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	Declare @VacationTypeName AS NVarChar(50)
	SET @VacationTypeName = ''

	Select @VacationTypeName = VacationTypeName
	From   emp.tblVacationTypesDtl
	Where  VacationTypeID = @VacationTypeID AND LanguageID = @LanguageID

	Return @VacationTypeName

END -- ======================================================
GO
