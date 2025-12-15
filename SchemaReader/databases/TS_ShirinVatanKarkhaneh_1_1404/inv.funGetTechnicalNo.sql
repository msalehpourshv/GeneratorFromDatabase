USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetTechnicalNo] 
(
	@GoodsID varchar(20) 
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @TechnicalNo NVarChar(50)

	Set @TechnicalNo = N'-'

	SELECT @TechnicalNo = TechnicalNo
	From inv.tblGoods
	Where GoodsID=@GoodsID

	-- Return the result of the function
	RETURN @TechnicalNo

END









GO
