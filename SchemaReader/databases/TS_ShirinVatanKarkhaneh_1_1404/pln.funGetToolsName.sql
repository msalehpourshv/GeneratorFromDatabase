USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION pln.funGetToolsName
(
	@ToolsID varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	DECLARE @ToolsName NVarChar(200)

	Set @ToolsName = N'-'

	SELECT @ToolsName = ToolName
	From pln.tblTools
	Where ToolID=@ToolsID

	RETURN @ToolsName 

END


GO
