USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [acc].[funGetServiceFaultName] 
(
	@ServiceFaultType VarChar(20) ,
	@LanguageID		  TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @ServiceFaultName NVarChar(100)

	Set @ServiceFaultName = N'-'

	SELECT @ServiceFaultName = ServiceFaultName
	From  acc.tblServiceFaultDtl
	Where LanguageID = @LanguageID AND ServiceFaultID = @ServiceFaultType 

	-- Return the result of the function
	RETURN @ServiceFaultName 

END
GO
