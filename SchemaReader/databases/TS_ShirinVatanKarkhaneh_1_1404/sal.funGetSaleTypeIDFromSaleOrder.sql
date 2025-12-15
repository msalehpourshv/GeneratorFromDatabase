USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sal].[funGetSaleTypeIDFromSaleOrder]
(
	@ProcessID SMALLINT ,
	@ProcessNo TINYINT,
	@FiscalYear SMALLINT,
	@SerialNo	INT
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @SaleTypeID VarChar(20)

	Set @SaleTypeID = ''

	SELECT  @SaleTypeID =  SaleTypeID
	From  sal.tblSaleOrderHdr
	Where  	ProcessID = @ProcessID AND
			ProcessNo = @ProcessNo AND
			FiscalYear = @FiscalYear AND
			SerialNo  = @SerialNo

	-- Return the result of the function
	RETURN @SaleTypeID 

END
GO
