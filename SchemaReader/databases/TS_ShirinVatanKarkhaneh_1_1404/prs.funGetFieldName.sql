USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prs].[funGetFieldName] 
(
	@FieldID	Char(20) ,
	@LanguageID	TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @FieldName NVarChar(50)

	Set @FieldName = N'-'

	SELECT @FieldName = FieldName 
	From  prs.tblStudyFieldsDtl
	Where LanguageID = @LanguageID AND FieldID = @FieldID 

	-- Return the result of the function
	RETURN @FieldName 

END
GO
