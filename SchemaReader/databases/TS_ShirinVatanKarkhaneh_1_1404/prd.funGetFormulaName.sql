USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prd].[funGetFormulaName] 
(
	@ProductID Varchar(20) ,
	@SerialNo int
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	-- Declare the return variable here
	DECLARE @FormulaName NVarChar(50)
	Declare @prdFormulaWithAccept	bit

	SELECT @prdFormulaWithAccept = SettingValue from pub.tblSettings where SettingKey = 'prdSeparateAcceptFormulaWithNonAccept'
	set @prdFormulaWithAccept=ISNULL(@prdFormulaWithAccept,0)

	Set @FormulaName = N'-'

	SELECT TOP 1 @FormulaName = FormulaName
    FROM prd.tblFormulasHdr 
    WHERE ProductID = SUBSTRING(@ProductID,1,LEN(ProductID)) AND SerialNo = @SerialNo
	and (@prdFormulaWithAccept ='False' or (@prdFormulaWithAccept ='True' and  AcceptFormula =1))
	order by LEN(ProductID) DESC

	-- Return the result of the function
	RETURN @FormulaName 

END
GO
