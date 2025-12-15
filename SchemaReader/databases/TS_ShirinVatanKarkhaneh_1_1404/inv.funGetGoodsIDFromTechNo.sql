USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Seyyed Mahdi Mostafavi
-- Create date   : 1403/08/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [inv].[funGetGoodsIDFromTechNo] 
(
	@TechnicalNo varchar(50) 
)
RETURNS NVarChar(20)
WITH ENCRYPTION
AS

BEGIN

	-- Declare the return variable here
	DECLARE @GoodsID NVarChar(20)

	Set @GoodsID = N''

	SELECT @GoodsID = GoodsID
	From inv.tblGoods
	Where TechnicalNo=@TechnicalNo

	-- Return the result of the function
	RETURN @GoodsID 

END







GO
