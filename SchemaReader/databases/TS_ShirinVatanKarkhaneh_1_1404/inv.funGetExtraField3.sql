USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [inv].[funGetExtraField3] 
(
	@GoodsID Varchar(20)
)
RETURNS NVarChar(500)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @ExtraFieldName NVarChar(50)

	Set @ExtraFieldName = N'-'

	SELECT @ExtraFieldName = ExtraField3
	From inv.tblGoods
	Where GoodsID=@GoodsID

	-- Return the result of the function
	RETURN @ExtraFieldName

END









GO
