USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION pln.funGetProductionLineName
(
	@ProductionLineID varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	DECLARE @ProductionLineName NVarChar(200)

	Set @ProductionLineName = N'-'

	SELECT @ProductionLineName = ProductionLineName
	From pln.tblProductionLinesDtl
	Where ProductionLineID=@ProductionLineID

	RETURN @ProductionLineName 

END
GO
