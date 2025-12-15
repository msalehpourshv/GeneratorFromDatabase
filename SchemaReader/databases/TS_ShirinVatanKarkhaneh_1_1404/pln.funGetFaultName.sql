USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION pln.funGetFaultName
(
	@FaultID varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	DECLARE @FaultName NVarChar(200)

	Set @FaultName = N'-'

	SELECT @FaultName = FaultName
	From pln.tblFaults
	Where FaultID=@FaultID

	RETURN @FaultName 

END
GO
