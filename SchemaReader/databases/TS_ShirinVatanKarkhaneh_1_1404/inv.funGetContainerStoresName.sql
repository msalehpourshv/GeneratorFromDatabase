USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetContainerStoresName] 
(
	@ContainerStoresID  Varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @ContainerStoresName NVarChar(50)

	Set @ContainerStoresName = N' '

	SELECT @ContainerStoresName = ContainerStoresName
	From inv.tblContainerPosInStoresDtl
	Where LanguageID=@LanguageID AND ContainerStoresID=@ContainerStoresID

	-- Return the result of the function
	RETURN @ContainerStoresName 

END










GO
