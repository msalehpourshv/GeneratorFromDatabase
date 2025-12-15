USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION pln.funGetToolName
(
	@ToolID varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN


	DECLARE @ToolName NVarChar(200)

	Set @ToolName = N'-'

	SELECT @ToolName = ToolName
	From pln.tblTools
	Where ToolID=@ToolID

	RETURN @ToolName 

END









GO
