USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prs].[funGetStudyName] 
(
	@StudyID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @StudyName NVarChar(50)

	Set @StudyName = N'-'

	SELECT @StudyName = StudyName 
	From  prs.tblStudiesDtl
	Where LanguageID = @LanguageID AND StudyID = @StudyID

	-- Return the result of the function
	RETURN @StudyName 

END
GO
