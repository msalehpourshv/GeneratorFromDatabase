USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetStoreKeeperName] 
(
	@StoreKeeperID  Varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @StoreKeeperName NVarChar(50)

	Set @StoreKeeperName = N'-'

	SELECT @StoreKeeperName = StoreKeeperName
	From inv.tblStoreKeepersDtl
	Where LanguageID=@LanguageID AND StoreKeeperID=@StoreKeeperID

	-- Return the result of the function
	RETURN @StoreKeeperName 

END










GO
