USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trn].[funGetTransportationKindName] 
(
	@TransportationKindID VARCHAR(20),
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @TransportationKindName NVarChar(50)

	Set @TransportationKindName = N'-'

	SELECT @TransportationKindName = TransportationKindName
	From trn.tblTransportationKindDtl
	Where LanguageID = @LanguageID AND TransportationKindID= @TransportationKindID

	-- Return the result of the function
	RETURN @TransportationKindName 

END

GO
