USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [inv].[funGetStoreAddress] 
(
	@StoreID Varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @StoreAddress NVarChar(20)

	Set @StoreAddress = N'-'

	SELECT @StoreAddress = inv.tblStoresDtl.Address
	From inv.tblStoresDtl
	Where LanguageID = @LanguageID AND StoreID = @StoreID

	-- Return the result of the function
	RETURN @StoreAddress 

END
GO
