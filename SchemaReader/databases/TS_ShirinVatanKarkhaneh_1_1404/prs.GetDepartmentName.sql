USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [prs].[GetDepartmentName]
(
	@DepartmentID VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(50) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	DECLARE @StrResult AS NVarChar(50)
	SET @StrResult = '-'

	SELECT @StrResult = DepartmentName
	FROM prs.tblDepartmentsDtl
	WHERE DepartmentID = @DepartmentID 
	  AND LanguageID = @LanguageID

	RETURN @StrResult

END -- ======================================================

















GO
