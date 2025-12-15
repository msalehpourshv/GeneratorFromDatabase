USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [phr].[FunGetPatientName]
(
	@PatientID VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(50) 
WITH ENCRYPTION
AS

Begin -- ====================================================

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	Declare @StrResult AS NVarChar(50)

	Select @StrResult = PatientName + ' ' + PatientLastName
	From   phr.tblPatientDtl
	Where  PatientID = @PatientID AND LanguageID = @LanguageID

	Return @StrResult

END -- ======================================================
GO
