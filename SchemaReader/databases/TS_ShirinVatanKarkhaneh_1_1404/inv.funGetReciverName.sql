USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetReciverName] 
(
	@LocationID Char(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Declare the return variable here
	DECLARE @ReciverName NVarChar(50)

	Set @ReciverName = N' '

	SELECT @ReciverName = ReciverName 
	From inv.tblGoodsReciverDtl
	Where LanguageID = @LanguageID AND ReciverID = @LocationID

	-- Return the result of the function
	RETURN @ReciverName 

END












GO
