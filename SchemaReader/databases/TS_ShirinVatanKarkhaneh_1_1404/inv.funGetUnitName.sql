USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetUnitName] 
(
	@UnitID varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Declare the return variable here
	DECLARE @UnitName NVarChar(50)

	Set @UnitName = N'-'

	SELECT @UnitName = UnitName
	From inv.tblUnitsDtl
	Where LanguageID=@LanguageID AND UnitID=@UnitID

	-- Return the result of the function
	RETURN @UnitName 

END









GO
