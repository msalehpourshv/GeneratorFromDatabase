USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [ast].[funGetLocateName] 
(
	@LocateID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @LocateName NVarChar(50)

	Set @LocateName = N'-'

	SELECT @LocateName = LocateName 
	From ast.tblLocatesDtl
	Where LanguageID = @LanguageID AND LocateID = @LocateID

	-- Return the result of the function
	RETURN @LocateName 

END













GO
