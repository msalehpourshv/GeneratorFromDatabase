USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetStoreKeeperNameFromStore] 
(
	@StoreID Varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @StoreKeeperName NVarChar(20)

	Set @StoreKeeperName = N'-'

	SELECT @StoreKeeperName = StoreKeeperName
	From inv.tblStoreKeepersDtl
	Where LanguageID=@LanguageID AND 
          StoreKeeperID = (SELECT StoreKeeperID
						   From inv.tblStores
						   Where StoreID=@StoreID)

	-- Return the result of the function
	RETURN @StoreKeeperName 

END
GO
