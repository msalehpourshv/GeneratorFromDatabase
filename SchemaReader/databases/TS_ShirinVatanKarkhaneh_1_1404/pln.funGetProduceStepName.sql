USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION pln.funGetProduceStepName 
(
	@ProductID	varChar(20) ,
	@ProduceStepID	int
)
RETURNS NVarChar(100)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @ProduceStepName NVarChar(50)
	Set @ProduceStepName = N'-'

	SELECT @ProduceStepName = ProduceStepName
	From   pln.tblProduceStepDtl
	Where ProductID = @ProductID AND ProduceStepID = @ProduceStepID 

	-- Return the result of the function
	RETURN @ProduceStepName 

END
GO
