USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION pln.funGetIdleTimes
(
	@IdleTimeID varchar(20) ,
	@LanguageID TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN

	DECLARE @IdleTimeName NVarChar(200)

	Set @IdleTimeName = N'-'

	SELECT @IdleTimeName = IdleTimeName
	From pub.tblIdleTimes
	Where IdleTimeID=@IdleTimeID

	RETURN @IdleTimeName 


END


GO
